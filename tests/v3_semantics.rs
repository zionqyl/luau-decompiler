mod support;
use luau_decompiler::{
    bytecode::{self, Opcode},
    decompile, Config, ControlFlowMode,
};
use serde_json::{json, Value};
use std::{
    fs,
    path::{Path, PathBuf},
    process::Command,
};

const PROTECTED: &[&str] = &[
    "protected_results",
    "protected_nested",
    "protected_varargs",
    "protected_yield",
    "protected_xpcall_yield",
    "protected_stateful",
    "protected_c_targets",
    "protected_handler_error",
];
const STRUCTURAL: &[&str] = &[
    "cross_block_vararg_table",
    "cross_block_call_table",
    "hybrid_native_loops",
    "multret_parentheses_assertions",
];

fn observe_mode(
    tools: &support::Toolset,
    bytes: &[u8],
    directory: &Path,
    label: &str,
    args: &[support::oracle::Value],
    probe: Option<&Path>,
    enabled: bool,
) -> (support::oracle::Observation, Value) {
    let bytecode = directory.join(format!("{label}.bc"));
    let arguments = directory.join(format!("{label}.args"));
    fs::write(&bytecode, bytes).unwrap();
    fs::write(&arguments, support::oracle::encode_arguments(args).unwrap()).unwrap();
    let mut command = Command::new(&tools.runner);
    command
        .arg(bytecode)
        .arg("--args")
        .arg(arguments)
        .arg("--fastpcall")
        .arg(if enabled { "true" } else { "false" });
    if let Some(probe) = probe {
        command.arg("--probe").arg(probe);
    }
    let result = command.output().unwrap();
    assert!(
        result.status.success(),
        "oracle infrastructure: {}",
        String::from_utf8(result.stderr.clone()).unwrap()
    );
    let diagnostic = String::from_utf8(result.stderr).expect("flag evidence must be ASCII");
    let line = diagnostic
        .lines()
        .find(|line| line.starts_with("FASTPCALL seen="))
        .expect("runner lacks instruction guard evidence");
    let fields: Vec<_> = line.split_whitespace().collect();
    assert_eq!(fields.len(), 6);
    let seen: usize = fields[1].strip_prefix("seen=").unwrap().parse().unwrap();
    let eligible: usize = fields[2]
        .strip_prefix("eligible=")
        .unwrap()
        .parse()
        .unwrap();
    let eligible_lua: usize = fields[4]
        .strip_prefix("eligible_lua=")
        .unwrap()
        .parse()
        .unwrap();
    let eligible_c: usize = fields[5]
        .strip_prefix("eligible_c=")
        .unwrap()
        .parse()
        .unwrap();
    assert_eq!(eligible, eligible_lua + eligible_c);
    assert_eq!(
        fields[3],
        if enabled {
            "enabled=true"
        } else {
            "enabled=false"
        }
    );
    if enabled && label == "original" {
        assert!(
            seen > 0 && eligible > 0,
            "original bytecode ran no eligible fast protected call: {diagnostic}"
        );
    } else if !enabled {
        assert_eq!((seen, eligible), (0, 0));
    }
    (
        support::oracle::Observation::decode(&result.stdout).unwrap(),
        json!({"enabled":enabled,"instructions_observed":seen,"guard_eligible":eligible,"eligible_lua_targets":eligible_lua,"eligible_c_targets":eligible_c}),
    )
}

#[test]
#[ignore = "requires pinned compiler and rebuilt typed official VM; mandatory v0.3 instruction-feature gate"]
fn protected_calls_have_actual_instruction_and_fast_runtime_evidence() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let mode = Command::new(&tools.runner)
        .arg("--runtime-flags")
        .output()
        .unwrap();
    assert!(mode.status.success());
    assert_eq!(
        String::from_utf8(mode.stdout).unwrap().trim(),
        "LuauFastpcall=false",
        "flag default/provenance changed"
    );
    let directory = root.join("artifacts/v3-semantics/protected");
    fs::create_dir_all(&directory).unwrap();
    let probe_source = directory.join("stateful-probe.luau");
    fs::write(&probe_source,"local run=...\nlocal first=table.pack(run(2))\nprint('first',first.n,table.unpack(first,1,first.n))\nlocal second=table.pack(run(-3))\nprint('second',second.n,table.unpack(second,1,second.n))\nlocal third=table.pack(run(4))\nreturn third.n,table.unpack(third,1,third.n)\n").unwrap();
    let probe = directory.join("stateful-probe.bc");
    fs::write(&probe, tools.compile(&probe_source, 0, 0).unwrap()).unwrap();
    let mut results = Vec::new();
    let mut comparisons = 0usize;
    for &name in PROTECTED {
        for optimization in [1, 2] {
            for debug in [0, 2] {
                let source = root.join(format!("tests/v3-semantic-corpus/{name}.luau"));
                let original = tools.compile(&source, optimization, debug).unwrap();
                let module = bytecode::decode(&original, &Config::default().limits).unwrap();
                let opcodes:Vec<_>=module.protos.iter().enumerate().flat_map(|(pid,p)|p.code.iter().filter(|i|i.op==Opcode::FastPcall).map(move|i|json!({"proto":pid,"pc":i.pc,"protected_id":i.a(),"explicit_arguments":i.b()}))).collect();
                assert!(
                    !opcodes.is_empty(),
                    "{name} O{optimization}D{debug} does not exercise FASTPCALL"
                );
                for (pid, p) in module.protos.iter().enumerate() {
                    for (index, i) in p
                        .code
                        .iter()
                        .enumerate()
                        .filter(|(_, i)| i.op == Opcode::FastPcall)
                    {
                        bytecode::verify_fastcall_fallback(&module, pid, index)
                            .unwrap_or_else(|e| panic!("{name} pc{}: {e}", i.pc));
                    }
                }
                let reconstructed = decompile(&original, &Config::default())
                    .unwrap_or_else(|e| panic!("{name} O{optimization}D{debug}: {e}"));
                assert!(reconstructed.complete);
                let rebuilt_source =
                    directory.join(format!("{name}.O{optimization}.D{debug}.luau"));
                fs::write(&rebuilt_source, &reconstructed.source).unwrap();
                let rebuilt = tools.compile(&rebuilt_source, optimization, debug).unwrap();
                let inputs: Vec<Vec<support::oracle::Value>> = if name == "protected_stateful" {
                    vec![vec![]]
                } else {
                    [-3.0f64, 0.0, 1.0, 7.0]
                        .iter()
                        .map(|x| vec![support::oracle::Value::Number(x.to_bits())])
                        .collect()
                };
                let mut observations = Vec::new();
                for (input, args) in inputs.iter().enumerate() {
                    for enabled in [false, true] {
                        let trusted_probe =
                            (name == "protected_stateful").then_some(probe.as_path());
                        let (expected, original_runtime) = observe_mode(
                            &tools,
                            &original,
                            &directory,
                            "original",
                            args,
                            trusted_probe,
                            enabled,
                        );
                        let (actual, reconstructed_runtime) = observe_mode(
                            &tools,
                            &rebuilt,
                            &directory,
                            "rebuilt",
                            args,
                            trusted_probe,
                            enabled,
                        );
                        if enabled && name == "protected_c_targets" {
                            assert!(
                                original_runtime["eligible_c_targets"].as_u64().unwrap() > 0,
                                "C target fast path was not exercised"
                            );
                        }
                        if enabled && name == "protected_yield" {
                            assert!(
                                original_runtime["eligible_c_targets"].as_u64().unwrap() > 0
                                    && original_runtime["eligible_lua_targets"].as_u64().unwrap()
                                        > 0,
                                "both yielding target kinds must run"
                            );
                        }
                        assert!(
                            expected.verified(),
                            "{name}: original observation incomplete {expected:?}"
                        );
                        assert!(expected.equivalent(&actual),"{name} O{optimization}D{debug} input{input} fast={enabled}:\n{expected:?}\n{actual:?}\n{}",reconstructed.source);
                        observations.push(json!({"input":input,"arguments":args,"original_runtime":original_runtime,"reconstructed_runtime":reconstructed_runtime,"typed_observation_sha256":support::digest(&expected.encode().unwrap()),"complete":true}));
                        comparisons += 1;
                    }
                }
                results.push(json!({"case":name,"optimization":optimization,"debug":debug,"source_sha256":support::digest(&fs::read(&source).unwrap()),"original_sha256":support::digest(&original),"reconstructed_source_sha256":support::digest(reconstructed.source.as_bytes()),"recompiled_sha256":support::digest(&rebuilt),"target_instructions":opcodes,"observations":observations,"same_loaded_closure_sequence":name=="protected_stateful"}));
            }
        }
    }
    assert_eq!(results.len(), PROTECTED.len() * 4);
    assert_eq!(comparisons, 232);
    let report = json!({"schema":1,"oracle_protocol":support::oracle::PROTOCOL,"complete":true,"required_families":PROTECTED,"distinct_source_programs":PROTECTED.len(),"compiled_cases":results.len(),"typed_comparisons":comparisons,"optimization_levels":[1,2],"debug_levels":[0,2],"runtime_modes":[false,true],"upstream_revision":tools.revision,"compiler_sha256":tools.compiler_hash,"runner_sha256":tools.runner_hash,"harness_sha256":support::digest(&fs::read(root.join("tests/vm_runner.cpp")).unwrap()),"guard_evidence":"Read-only pinned VM interrupt observation checks opcode89 and all fastpath guards; every enabled original-bytecode execution has an eligible call in a yieldable coroutine. Recompiled source may use the ordinary protected-call fallback instead; its actual counters remain separate.","stateful_probe_sha256":support::digest(&fs::read(probe).unwrap()),"results":results});
    fs::create_dir_all(root.join("docs/results")).unwrap();
    fs::write(
        root.join("docs/results/v3-protected-calls.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
}

#[test]
#[ignore = "requires pinned compiler and typed official VM; mandatory v0.3 structural-feature gate"]
fn cross_block_tables_and_hybrid_native_loops_have_typed_evidence() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let directory = root.join("artifacts/v3-semantics/structural");
    fs::create_dir_all(&directory).unwrap();
    let inputs: Vec<_> = [-3.0f64, 0.0, 1.0, 7.0]
        .iter()
        .map(|x| vec![support::oracle::Value::Number(x.to_bits())])
        .collect();
    let mut results = Vec::new();
    let mut comparisons = 0;
    for &name in STRUCTURAL {
        for optimization in 0..=2 {
            for debug in [0, 2] {
                let source = root.join(format!("tests/v3-semantic-corpus/{name}.luau"));
                let original = tools.compile(&source, optimization, debug).unwrap();
                let module = bytecode::decode(&original, &Config::default().limits).unwrap();
                let target_count = module
                    .protos
                    .iter()
                    .flat_map(|p| p.code.iter())
                    .filter(|i| {
                        if name == "hybrid_native_loops" {
                            matches!(i.op, Opcode::ForNPrep | Opcode::ForGLoop)
                        } else {
                            i.op == Opcode::SetList && i.c() == 0
                        }
                    })
                    .count();
                assert!(target_count > 0, "fixture feature disappeared: {name}");
                let mut cross_block_sites = Vec::new();
                if name.starts_with("cross_block_") {
                    for (pid, proto) in module.protos.iter().enumerate() {
                        let cfg =
                            luau_decompiler::cfg::Cfg::build(proto, &Config::default().limits)
                                .unwrap();
                        for (index, store) in proto
                            .code
                            .iter()
                            .enumerate()
                            .filter(|(_, i)| i.op == Opcode::SetList && i.c() == 0)
                        {
                            if let Some(origin) = proto.code[..index]
                                .iter()
                                .rposition(|i| i.op == Opcode::NewTable && i.a() == store.a())
                            {
                                if cfg.instruction_block[origin] != cfg.instruction_block[index] {
                                    cross_block_sites.push(json!({"proto":pid,"constructor_pc":proto.code[origin].pc,"open_store_pc":store.pc}));
                                }
                            }
                        }
                    }
                    assert!(
                        !cross_block_sites.is_empty(),
                        "{name} no longer contains a constructor/open SETLIST across blocks"
                    );
                }
                if name == "hybrid_native_loops" {
                    assert!(
                        module
                            .protos
                            .iter()
                            .any(|p| p.code.iter().any(|i| i.op == Opcode::ForNPrep)),
                        "numeric loop feature disappeared"
                    );
                    assert!(
                        module
                            .protos
                            .iter()
                            .any(|p| p.code.iter().any(|i| i.op == Opcode::ForGLoop)),
                        "generic loop feature disappeared"
                    );
                }
                let modes: &[ControlFlowMode] = if name == "hybrid_native_loops" {
                    &[ControlFlowMode::Auto, ControlFlowMode::Dispatcher]
                } else {
                    &[ControlFlowMode::Auto]
                };
                for &mode in modes {
                    let config = Config {
                        control_flow: mode,
                        ..Config::default()
                    };
                    let result = decompile(&original, &config)
                        .unwrap_or_else(|e| panic!("{name} O{optimization}D{debug} {mode:?}: {e}"));
                    if mode == ControlFlowMode::Dispatcher {
                        assert_eq!(result.quality, luau_decompiler::OutputQuality::Dispatcher);
                        assert!(result.source.matches("for ").count() >= 2);
                    }
                    let path =
                        directory.join(format!("{name}.O{optimization}.D{debug}.{mode:?}.luau"));
                    fs::write(&path, &result.source).unwrap();
                    let rebuilt = tools.compile(&path, optimization, debug).unwrap();
                    let mut observations = Vec::new();
                    for (input, args) in inputs.iter().enumerate() {
                        let expected = tools
                            .observe(&original, &directory, "original", args)
                            .unwrap();
                        let actual = tools
                            .observe(&rebuilt, &directory, "rebuilt", args)
                            .unwrap();
                        assert!(
                            expected.equivalent(&actual),
                            "{name} {mode:?} input{input}: {expected:?}\n{actual:?}\n{}",
                            result.source
                        );
                        observations.push(json!({"input":input,"observation_sha256":support::digest(&expected.encode().unwrap()),"complete":true}));
                        comparisons += 1;
                    }
                    results.push(json!({"case":name,"optimization":optimization,"debug":debug,"mode":format!("{mode:?}"),"target_instructions":target_count,"cross_block_open_result_sites":cross_block_sites,"original_sha256":support::digest(&original),"source_sha256":support::digest(&fs::read(&source).unwrap()),"reconstructed_source_sha256":support::digest(result.source.as_bytes()),"output_quality":result.quality,"fallback_prototypes":result.fallback_prototypes,"observations":observations}));
                }
            }
        }
    }
    assert_eq!(comparisons, 120);
    assert_eq!(results.len(), 30);
    let report = json!({"schema":1,"oracle_protocol":support::oracle::PROTOCOL,"complete":true,"required_families":STRUCTURAL,"distinct_source_programs":4,"compiled_cases":24,"reconstruction_cases":results.len(),"typed_comparisons":comparisons,"compiler_sha256":tools.compiler_hash,"runner_sha256":tools.runner_hash,"upstream_revision":tools.revision,"results":results});
    fs::write(
        root.join("docs/results/v3-structural-semantics.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
}

#[test]
fn required_semantic_feature_catalog_is_present_and_distinct() {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mut names = std::collections::BTreeSet::new();
    for name in PROTECTED.iter().chain(STRUCTURAL) {
        assert!(names.insert(name));
        assert!(root
            .join(format!("tests/v3-semantic-corpus/{name}.luau"))
            .is_file());
    }
    assert_eq!(names.len(), 12);
}

#[test]
fn protected_fallback_proof_rejects_identity_count_and_effect_changes() {
    use bytecode::{Constant, Instruction, Module, Proto};
    let abc = |op: Opcode, a: u32, b: u32, c: u32| op as u32 | (a << 8) | (b << 16) | (c << 24);
    let mut module = Module {
        version: 14,
        type_version: 3,
        strings: vec![b"pcall".to_vec()],
        userdata_types: Default::default(),
        main: 0,
        protos: vec![Proto {
            type_metadata: Default::default(),
            max_stack: 3,
            num_params: 0,
            num_upvalues: 0,
            is_vararg: false,
            flags: 0,
            code: vec![
                Instruction {
                    pc: 0,
                    op: Opcode::FastPcall,
                    word: abc(Opcode::FastPcall, 0, 1, 2),
                    aux: None,
                },
                Instruction {
                    pc: 1,
                    op: Opcode::GetImport,
                    word: abc(Opcode::GetImport, 0, 1, 0),
                    aux: Some(1 << 30),
                },
                Instruction {
                    pc: 3,
                    op: Opcode::Call,
                    word: abc(Opcode::Call, 0, 2, 2),
                    aux: None,
                },
                Instruction {
                    pc: 4,
                    op: Opcode::Return,
                    word: abc(Opcode::Return, 0, 2, 0),
                    aux: None,
                },
            ],
            constants: vec![Constant::String(0), Constant::Import(1 << 30)],
            children: vec![],
            line_defined: 0,
            debug_name: None,
            locals: vec![],
            upvalue_names: vec![],
        }],
    };
    assert_eq!(Opcode::FastPcall as u8, 89);
    assert_eq!(Opcode::from_byte(89), Some(Opcode::FastPcall));
    let proof = bytecode::verify_fastcall_fallback(&module, 0, 0).unwrap();
    assert_eq!(proof.call_index, 2);
    module.protos[0].code[0].word = abc(Opcode::FastPcall, 2, 1, 2);
    assert!(bytecode::verify_fastcall_fallback(&module, 0, 0).is_err());
    module.protos[0].code[0].word = abc(Opcode::FastPcall, 0, 2, 2);
    assert!(bytecode::verify_fastcall_fallback(&module, 0, 0)
        .unwrap_err()
        .message
        .contains("argument count"));
    module.protos[0].code[0].word = abc(Opcode::FastPcall, 0, 1, 2);
    module.strings[0] = b"xpcall".to_vec();
    assert!(bytecode::verify_fastcall_fallback(&module, 0, 0)
        .unwrap_err()
        .message
        .contains("function path"));
    module.strings[0] = b"pcall".to_vec();
    module.protos[0].code[2].aux = Some(0);
    assert!(bytecode::verify_fastcall_fallback(&module, 0, 0).is_err());
    module.protos[0].code[2].aux = None;
    module.protos[0].code[1].op = Opcode::SetGlobal;
    assert!(bytecode::verify_fastcall_fallback(&module, 0, 0)
        .unwrap_err()
        .message
        .contains("effectful"));
}

#[test]
fn reused_parameter_storage_gets_a_new_binding_name() {
    use bytecode::{Instruction, Module, Proto};
    let instruction = |pc, op: Opcode, word, aux| Instruction {
        pc,
        op,
        word: word | op as u32,
        aux,
    };
    let mut child = Proto {
        type_metadata: Default::default(),
        max_stack: 1,
        num_params: 1,
        num_upvalues: 0,
        is_vararg: false,
        flags: 0,
        code: vec![
            instruction(0, Opcode::LoadNil, 0, None),
            instruction(1, Opcode::NewTable, 0, Some(0)),
            instruction(3, Opcode::Return, 2 << 16, None),
        ],
        constants: vec![],
        children: vec![],
        line_defined: 0,
        debug_name: None,
        locals: vec![],
        upvalue_names: vec![],
    };
    let mut main = child.clone();
    main.num_params = 0;
    main.children = vec![0];
    main.code = vec![
        instruction(0, Opcode::NewClosure, 0, None),
        instruction(1, Opcode::Return, 2 << 16, None),
    ];
    child.children.clear();
    let module = Module {
        version: 14,
        type_version: 3,
        strings: vec![],
        userdata_types: Default::default(),
        protos: vec![child, main],
        main: 1,
    };
    let result =
        luau_decompiler::structure::decompile_module_report(&module, &Config::default()).unwrap();
    let reused: Vec<_> = result
        .recovered_bindings
        .iter()
        .filter(|b| b.proto == 0 && b.register == 0 && !b.parameter)
        .collect();
    assert!(
        !reused.is_empty(),
        "fixture must split parameter storage reuse"
    );
    assert!(
        reused
            .iter()
            .all(|binding| !binding.name.starts_with("argument_")),
        "later bindings borrowed parameter-style names: {reused:?}"
    );
    assert!(result
        .recovered_bindings
        .iter()
        .any(|b| b.proto == 0 && b.parameter && b.name.starts_with("argument_")));
}

#[test]
fn naming_switches_preserve_debug_evidence_and_binding_overrides() {
    let bytes = include_bytes!("fixtures/binding_scopes_v2.O0.D2.bc");
    let mut config = Config::default();
    config.naming_options.use_debug_names = false;
    config.naming_options.infer_descriptive_names = false;
    let result = decompile(bytes, &config).unwrap();
    let third = result
        .bindings
        .iter()
        .find(|b| b.debug_name.as_deref() == Some("third"))
        .expect("debug evidence must remain available when presentation names are disabled");
    assert!(third.name.starts_with("local_"), "{}", third.name);
    let identity = format!("p{}:b{}", third.proto, third.id);
    config.name_overrides.insert(identity, "chosen_name".into());
    let overridden = decompile(bytes, &config).unwrap();
    assert!(overridden
        .bindings
        .iter()
        .any(|b| b.proto == third.proto && b.id == third.id && b.name == "chosen_name"));
    assert!(overridden.source.contains("chosen_name"));
}

#[test]
fn ssa_call_hints_use_literal_usage_without_claiming_a_class() {
    use bytecode::{Constant, Instruction, Module, Proto};
    let instruction = |pc, op: Opcode, a: u32, b: u32, c: u32, aux| Instruction {
        pc,
        op,
        word: op as u32 | (a << 8) | (b << 16) | (c << 24),
        aux,
    };
    let proto = Proto {
        type_metadata: Default::default(),
        max_stack: 3,
        num_params: 0,
        num_upvalues: 0,
        is_vararg: false,
        flags: 0,
        code: vec![
            instruction(0, Opcode::GetGlobal, 0, 0, 0, Some(0)),
            instruction(2, Opcode::LoadK, 2, 1, 0, None),
            instruction(3, Opcode::NameCall, 0, 0, 0, Some(2)),
            instruction(5, Opcode::Call, 0, 3, 2, None),
            instruction(6, Opcode::Return, 0, 2, 0, None),
        ],
        constants: vec![
            Constant::String(0),
            Constant::String(1),
            Constant::String(2),
        ],
        children: vec![],
        line_defined: 0,
        debug_name: None,
        locals: vec![],
        upvalue_names: vec![],
    };

    let module = Module {
        version: 14,
        type_version: 3,
        strings: vec![
            b"provider".to_vec(),
            b"Players".to_vec(),
            b"GetService".to_vec(),
        ],
        userdata_types: Default::default(),
        protos: vec![proto],
        main: 0,
    };
    let mut config = Config::default();
    config.naming_options.use_debug_names = false;
    let result = luau_decompiler::structure::decompile_module_report(&module, &config).unwrap();
    let binding = result
        .recovered_bindings
        .iter()
        .find(|b| b.first_pc == 5 && b.register == 0)
        .unwrap();
    assert_eq!(binding.name, "players_service");
    assert_eq!(binding.debug_name, None);
    assert!(
        result.source.contains("provider")
            && result.source.contains(":GetService(")
            && result.source.contains("\"Players\""),
        "{}",
        result.source
    );
    assert!(!result.source.contains(": Players"));
    config.naming = luau_decompiler::NameStyle::CamelCase;
    let camel = luau_decompiler::structure::decompile_module_report(&module, &config).unwrap();
    assert_eq!(
        camel
            .recovered_bindings
            .iter()
            .find(|b| b.first_pc == 5 && b.register == 0)
            .unwrap()
            .name,
        "playersService"
    );
    config.naming_options.infer_descriptive_names = false;
    let stable = luau_decompiler::structure::decompile_module_report(&module, &config).unwrap();
    assert!(stable
        .recovered_bindings
        .iter()
        .find(|b| b.first_pc == 5 && b.register == 0)
        .unwrap()
        .name
        .starts_with("local"));
}
