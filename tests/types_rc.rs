mod support;

use luau_decompiler::{
    bytecode,
    config::{EntryOutput, OutputPolicy},
    quality::{GateStatus, ValidationMode},
    Config,
};
use serde_json::{json, Value};
use std::{fs, path::Path, process::Command};

fn compile(
    tools: &support::Toolset,
    path: &Path,
    optimization: usize,
    debug: usize,
    metadata: usize,
) -> Vec<u8> {
    let mut command = Command::new(&tools.compiler);
    command.args([
        "--binary",
        &format!("-O{optimization}"),
        &format!("-g{debug}"),
        &format!("-t{metadata}"),
    ]);
    if !tools.flags.is_empty() {
        command.arg(format!("--fflags={}", tools.flags));
    }
    let output = command.arg(path).output().unwrap();
    assert!(
        output.status.success() && output.stdout.first().is_some_and(|b| *b != 0),
        "{path:?}: {:?} {}",
        output.status,
        String::from_utf8_lossy(&output.stderr)
    );
    output.stdout
}

#[test]
fn function_entry_rejects_executor_wrapper_with_missing_live_capture_values() {
    let hex = "0d03010576616c75650002380301010000000afb0100004d0201cc0000000043020200300201cc00000000fb0100004d0101cc00000000820102000103010001000000001f02000000000004c6010000d90000001200010082000200000100000000000001";
    let bytes: Vec<_> = hex
        .as_bytes()
        .chunks_exact(2)
        .map(|pair| u8::from_str_radix(std::str::from_utf8(pair).unwrap(), 16).unwrap())
        .collect();
    let mut config = Config {
        entry_output: EntryOutput::Function,
        bytecode_encoding: "roblox_opcode227".into(),
        ..Config::default()
    };
    config.validation.mode = ValidationMode::Off;
    let error = luau_decompiler::decompile(&bytes, &config).unwrap_err();
    assert_eq!(error.stage, "entry");
    assert!(
        error.message.contains("live upvalue values are absent"),
        "{error}"
    );
    assert!(error.proto.is_some());
}

#[test]
fn immediately_initialized_closure_has_a_natural_typed_declaration() {
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    let result =
        luau_decompiler::decompile(include_bytes!("../fixtures/runtime/verified.bc"), &config)
            .unwrap();
    assert!(result.complete);
    assert!(
        result
            .source
            .contains("local function add(value: number): number\n"),
        "{}",
        result.source
    );
    assert!(
        result.source.contains("local answer: number = add(40)"),
        "{}",
        result.source
    );
    assert!(
        !result.source.contains("closure_ready"),
        "{}",
        result.source
    );
    assert!(!result.source.contains("\ndo\n"), "{}", result.source);
    assert!(!result.source.contains("...number"), "{}", result.source);
    assert!(!result.source.contains("number?"), "{}", result.source);
}

#[test]
#[ignore = "requires pinned compilers, analyzer and typed oracle; required release candidate regression matrix"]
fn player_snapshot_strict_and_structural_behavior_matrix() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/types-rc-snapshot");
    fs::create_dir_all(&destination).unwrap();
    let source = root.join("tests/type-corpus/roblox_snapshot.luau");
    let probe_source = destination.join("snapshot-structural.probe.luau");
    fs::write(&probe_source, "local snapshot = ...\nlocal function pivot(self)\n print(\"pivot\", self.marker)\n return {Position = vector.create(1, -2, 3)}\nend\nlocal absent = snapshot({UserId=17,DisplayName=\"A\\000B\",Character=nil})\nlocal present = snapshot({UserId=29,DisplayName=\"Q\\255Z\",Character={marker=\"model\",GetPivot=pivot}})\nlocal keys = {}\nfor key in absent do table.insert(keys,key) end\nlocal presentKeys = {}\nfor key in present do table.insert(presentKeys,key) end\nreturn absent.userId,absent.displayName,absent.position,present.userId,present.displayName,present.position,table.concat(keys,\",\"),table.concat(presentKeys,\",\")\n").unwrap();
    let mut rows = Vec::new();
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        let probe = compile(&tools, &probe_source, 0, 0, 0);
        let probe_path = destination.join(format!("probe-v{version}.bc"));
        fs::write(&probe_path, &probe).unwrap();
        for optimization in [0, 2] {
            for debug in [0, 2] {
                for metadata in [0, 1] {
                    let id =
                        format!("PlayerSnapshot/v{version}/O{optimization}/D{debug}/T{metadata}");
                    let dir = destination.join(id.replace('/', "-"));
                    fs::create_dir_all(&dir).unwrap();
                    let bytes = compile(&tools, &source, optimization, debug, metadata);
                    let module = bytecode::decode(&bytes, &Default::default()).unwrap();
                    let mut config = Config::default();
                    config.validation.mode = ValidationMode::Off;
                    config.naming = luau_decompiler::NameStyle::CamelCase;
                    let inventory = luau_decompiler::decompile(&bytes, &config).unwrap();
                    let player = inventory
                        .bindings
                        .iter()
                        .find(|binding| {
                            binding.parameter && module.protos[binding.proto].num_params == 1
                        })
                        .unwrap();
                    let identity = format!("p{}:b{}", player.proto, player.id);
                    config
                        .typing
                        .binding_types
                        .insert(identity.clone(), "Player".into());
                    config.validation.mode = ValidationMode::StrictRequired;
                    config.output_policy = OutputPolicy::VerifiedTyped;
                    let result = luau_decompiler::decompile(&bytes, &config).unwrap();
                    let recovered_path = dir.join("recovered.luau");
                    fs::write(&recovered_path, &result.source).unwrap();
                    fs::write(
                        dir.join("result.json"),
                        serde_json::to_vec_pretty(&result).unwrap(),
                    )
                    .unwrap();
                    assert!(
                        result.validation.required_passed,
                        "{id}: {:?}\n{}",
                        result.validation, result.source
                    );
                    assert_eq!(result.validation.syntax, GateStatus::Passed, "{id}");
                    assert_eq!(result.validation.compilation, GateStatus::Passed, "{id}");
                    assert_eq!(
                        result.validation.strict_analysis,
                        GateStatus::Passed,
                        "{id}"
                    );
                    assert!(result.type_report.emitted_useful_annotations >= 3, "{id}");
                    assert_eq!(result.type_report.emitted_explicit_any, 0, "{id}");
                    assert!(!result.source.contains("::"), "{id}");
                    assert!(
                        !result.source.contains("number | string"),
                        "{id}: {}",
                        result.source
                    );
                    let rebuilt = compile(&tools, &recovered_path, optimization, debug, 0);
                    let expected = tools
                        .observe_with_probe(&bytes, &dir, "original", &[], Some(&probe_path))
                        .unwrap();
                    let actual = tools
                        .observe_with_probe(&rebuilt, &dir, "rebuilt", &[], Some(&probe_path))
                        .unwrap();
                    assert!(
                        expected.verified() && expected.equivalent(&actual),
                        "{id}: {expected:?} vs {actual:?}"
                    );
                    rows.push(json!({"id":id,"version":version,"optimization":optimization,"debug":debug,"metadata":metadata,"source_sha256":support::digest(&fs::read(&source).unwrap()),"input_sha256":support::digest(&bytes),"output_sha256":support::digest(result.source.as_bytes()),"recompiled_sha256":support::digest(&rebuilt),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"config":config,"external_contract":{"binding":identity,"type":"Player"},"types":result.type_report,"validation":result.validation,"behavior":{"boundary":"controlled structural Player/Model test doubles; not real Roblox userdata","native_engine_test":false,"expected":expected,"actual":actual,"verified":true},"verified":true}));
                }
            }
        }
    }
    assert_eq!(rows.len(), 16);
    let report = json!({"schema":1,"required_cases":16,"cases":rows.len(),"all_strict_passed":true,"structural_behavior_comparisons":16,"native_engine_behavior_comparisons":0,"source_identities":1,"oracle_protocol":"LOBS/1","test_binary_sha256":support::digest(&fs::read(std::env::current_exe().unwrap()).unwrap()),"results":rows});
    fs::write(
        root.join("docs/results/types-rc-snapshot.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
}

#[test]
#[ignore = "requires pinned compiler and typed oracle; required function-entry contract regression"]
fn explicit_function_entries_preserve_fixed_and_variadic_call_shapes() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/types-rc-function-entry");
    fs::create_dir_all(&destination).unwrap();
    let tools = support::Toolset::checked(root, 14);
    let mut rows = Vec::new();
    for (family, source) in [
        (
            "fixed",
            "return function(first,second) return first,second end",
        ),
        ("vararg", "return function(first,...) return first,... end"),
    ] {
        let dir = destination.join(family);
        fs::create_dir_all(&dir).unwrap();
        let source_path = dir.join("original.luau");
        fs::write(&source_path, source).unwrap();
        let bytes = compile(&tools, &source_path, 0, 2, 1);
        let module = bytecode::decode(&bytes, &Default::default()).unwrap();
        let entry = module.protos.iter().position(|p| p.num_params > 0).unwrap();
        assert!(module.main < 128 && entry < 128);
        assert_eq!(bytes.last(), Some(&(module.main as u8)));
        let mut dump = bytes.clone();
        *dump.last_mut().unwrap() = entry as u8;
        let mut config = Config::default();
        config.validation.mode = ValidationMode::Off;
        assert!(luau_decompiler::decompile(&dump, &config).is_err());
        config.entry_output = EntryOutput::Function;
        let result = luau_decompiler::decompile(&dump, &config).unwrap();
        let path = dir.join("recovered.luau");
        fs::write(&path, &result.source).unwrap();
        let rebuilt = compile(&tools, &path, 0, 2, 0);
        let probe_source = dir.join("probe.luau");
        fs::write(
            &probe_source,
            "local callback=...\nreturn callback(7,nil,\"tail\",nil)",
        )
        .unwrap();
        let probe = compile(&tools, &probe_source, 0, 0, 0);
        let probe_path = dir.join("probe.bc");
        fs::write(&probe_path, &probe).unwrap();
        let expected = tools
            .observe_with_probe(&bytes, &dir, "original", &[], Some(&probe_path))
            .unwrap();
        let actual = tools
            .observe_with_probe(&rebuilt, &dir, "rebuilt", &[], Some(&probe_path))
            .unwrap();
        assert!(
            expected.verified() && expected.equivalent(&actual),
            "{family}: {expected:?} vs {actual:?}"
        );
        rows.push(json!({"id":family,"input_dump_sha256":support::digest(&dump),"known_source_chunk_sha256":support::digest(&bytes),"output_sha256":support::digest(result.source.as_bytes()),"fixed_parameters":module.protos[entry].num_params,"vararg":module.protos[entry].is_vararg,"config":config,"expected":expected,"actual":actual,"native_dump":false,"verified":true}));
    }
    let report: Value = json!({"schema":1,"cases":2,"all_passed":true,"boundary":"compiler-generated packets with explicitly selected serialized function entries; native getter evidence is separate","results":rows});
    fs::write(
        root.join("docs/results/types-rc-function-entry.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
}

#[test]
#[ignore = "requires pinned compilers and typed oracle; required inference and constructor behavior matrix"]
fn inference_and_constructor_regressions_preserve_typed_observations() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/types-rc-behavior");
    fs::create_dir_all(&destination).unwrap();
    let families = ["array_constructor", "scalar_packs", "transitive_alias"];
    let mut rows = Vec::new();
    let mut comparisons = 0;
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for family in families {
            let source = root.join(format!("tests/rc-type-corpus/{family}.luau"));
            for optimization in [0, 2] {
                for debug in [0, 2] {
                    for metadata in [0, 1] {
                        let id =
                            format!("{family}/v{version}/O{optimization}/D{debug}/T{metadata}");
                        let dir = destination.join(id.replace('/', "-"));
                        fs::create_dir_all(&dir).unwrap();
                        let original = compile(&tools, &source, optimization, debug, metadata);
                        let mut config = Config::default();
                        config.validation.mode = ValidationMode::Off;
                        let result = luau_decompiler::decompile(&original, &config).unwrap();
                        let recovered = dir.join("recovered.luau");
                        fs::write(&recovered, &result.source).unwrap();
                        let rebuilt = compile(&tools, &recovered, optimization, debug, 0);
                        let mut inputs = Vec::new();
                        for seed in [-3, 0, 7] {
                            let probe = if family == "transitive_alias" {
                                let probe_source = dir.join(format!("probe-{seed}.luau"));
                                fs::write(&probe_source, format!("local callback=...\nreturn callback(function(reveal)\nlocal graph=reveal()\nif {seed}==0 then\ngraph.nested.entries[1].value=nil\nelse\ngraph.nested.entries[1].value=\"changed\\000\\255\"\nend\nend)\n")).unwrap();
                                let bytes = compile(&tools, &probe_source, 0, 0, 0);
                                let path = dir.join(format!("probe-{seed}.bc"));
                                fs::write(&path, bytes).unwrap();
                                Some(path)
                            } else {
                                None
                            };
                            let arguments = if probe.is_some() {
                                vec![]
                            } else {
                                vec![support::oracle::Value::Number((seed as f64).to_bits())]
                            };
                            let expected = tools
                                .observe_with_probe(
                                    &original,
                                    &dir,
                                    &format!("original-{seed}"),
                                    &arguments,
                                    probe.as_deref(),
                                )
                                .unwrap();
                            let actual = tools
                                .observe_with_probe(
                                    &rebuilt,
                                    &dir,
                                    &format!("rebuilt-{seed}"),
                                    &arguments,
                                    probe.as_deref(),
                                )
                                .unwrap();
                            assert!(
                                expected.verified() && expected.equivalent(&actual),
                                "{id} seed{seed}: {expected:?} vs {actual:?}"
                            );
                            comparisons += 1;
                            inputs.push(json!({"seed":seed,"expected":expected,"actual":actual,"verified":true}));
                        }
                        rows.push(json!({"id":id,"source_sha256":support::digest(&fs::read(&source).unwrap()),"input_sha256":support::digest(&original),"output_sha256":support::digest(result.source.as_bytes()),"recompiled_sha256":support::digest(&rebuilt),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"config":config,"type_report":result.type_report,"inputs":inputs,"complete":result.complete,"verified":true}));
                    }
                }
            }
        }
    }
    assert_eq!(rows.len(), 48);
    assert_eq!(comparisons, 144);
    fs::write(root.join("docs/results/types-rc-behavior.json"), serde_json::to_vec_pretty(&json!({"schema":1,"families":families,"required_cases":48,"cases":48,"required_typed_comparisons":144,"typed_comparisons":comparisons,"all_verified":true,"oracle_protocol":"LOBS/1","results":rows})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compiler and strict analyzer; required authoritative function-contract regression"]
fn explicit_local_function_contract_cannot_be_silently_dropped() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let directory = root.join("artifacts/types-rc-contracts");
    fs::create_dir_all(&directory).unwrap();
    let original = directory.join("identity.luau");
    fs::write(
        &original,
        "local function identity(value) return value end\nreturn identity\n",
    )
    .unwrap();
    let bytes = compile(&tools, &original, 2, 2, 1);
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    let inventory = luau_decompiler::decompile(&bytes, &config).unwrap();
    let binding = inventory
        .bindings
        .iter()
        .find(|binding| !binding.parameter && binding.debug_name.as_deref() == Some("identity"))
        .unwrap();
    config.typing.binding_types.insert(
        format!("p{}:b{}", binding.proto, binding.id),
        "(number) -> string".into(),
    );
    config.validation.mode = ValidationMode::StrictRequired;
    config.output_policy = OutputPolicy::VerifiedTyped;
    config.validation.max_attempts = 1;
    let rejected = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(
        rejected.source.contains("local identity:"),
        "{}",
        rejected.source
    );
    assert!(
        !rejected.validation.required_passed,
        "{:?}",
        rejected.validation
    );
    assert_eq!(rejected.validation.syntax, GateStatus::Passed);
    assert_eq!(rejected.validation.compilation, GateStatus::Passed);
    assert_eq!(rejected.validation.strict_analysis, GateStatus::Failed);
    assert_eq!(rejected.type_report.emitted_explicit_any, 0);
    assert_eq!(rejected.validation.type_assertions, 0);
    assert!(!rejected.validation.external_assumptions.is_empty());
    fs::write(directory.join("rejected.luau"), &rejected.source).unwrap();
    let initial_config = config.clone();
    config.validation.max_attempts = 3;
    let recovered = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(
        !recovered.validation.required_passed,
        "{:?}",
        recovered.validation
    );
    assert_eq!(
        recovered.validation.attempts[0].strict_analysis,
        GateStatus::Failed
    );
    assert_eq!(recovered.type_report.emitted_explicit_any, 0);
    fs::write(root.join("docs/results/types-rc-contracts.json"), serde_json::to_vec_pretty(&json!({"schema":1,"required_cases":2,"cases":2,"input_sha256":support::digest(&bytes),"compiler_sha256":tools.compiler_hash,"results":[{"id":"explicit_binding_contract_checked","config":initial_config,"source_sha256":support::digest(rejected.source.as_bytes()),"validation":rejected.validation,"types":rejected.type_report,"expected":"strict_rejection","verified_output":false,"passed":true},{"id":"recovery_cannot_report_verified_success_after_discarding_contract","config":config,"source_sha256":support::digest(recovered.source.as_bytes()),"validation":recovered.validation,"types":recovered.type_report,"expected":"verified_typed_rejection","verified_output":false,"passed":true}]})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers, strict analyzer and typed oracle; alias and opaque-return regressions"]
fn alias_dependencies_survive_logical_joins_loops_and_adjusted_shared_returns() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/rc2-types");
    fs::create_dir_all(&destination).unwrap();
    let families = [
        ("logical_alias", "return function(flag,mutate) local child={value=1} local alias=flag and child or nil mutate(alias) return child.value end", vec![(0,"boolean"),(1,"(unknown, ...unknown) -> ()")]),
        ("loop_alias", "return function(mutate) local child={value=1} local alias=nil for index=1,3 do mutate(alias) alias=child end return child.value end", vec![(0,"(unknown, ...unknown) -> ()")]),
        ("shared_return", "return function(factory,mutate) local cached=factory() mutate(factory()) return cached.value end", vec![(0,"() -> {value: number}"),(1,"(unknown, ...unknown) -> ()")]),
        ("shared_pack", "return function(factory,mutate) local marker,cached=factory() mutate(factory()) return marker,cached.value end", vec![(0,"() -> (number, {value: number}, nil)"),(1,"(unknown, ...unknown) -> ()")]),
        ("shared_effect", "return function(factory,mutate) local cached=factory() mutate() return cached.value end", vec![(0,"() -> {value: number}"),(1,"() -> ()")]),
        ("global_record", "return function() local cached=externalRecord mutate() return cached.value end", vec![]),
    ];
    let mut rows = Vec::new();
    let mut comparisons = 0;
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for (family, source, contracts) in &families {
            for optimization in [0, 2] {
                for debug in [0, 2] {
                    for metadata in [0, 1] {
                        let id =
                            format!("{family}/v{version}/O{optimization}/D{debug}/T{metadata}");
                        let directory = destination.join(id.replace('/', "-"));
                        fs::create_dir_all(&directory).unwrap();
                        let source_path = directory.join("original.luau");
                        fs::write(&source_path, source).unwrap();
                        let original = compile(&tools, &source_path, optimization, debug, metadata);
                        let mut config = Config::default();
                        config.validation.mode = ValidationMode::Off;
                        if *family == "global_record" {
                            config
                                .typing
                                .globals
                                .insert("externalRecord".into(), "{value: number}".into());
                            config
                                .typing
                                .globals
                                .insert("mutate".into(), "() -> ()".into());
                        }
                        let inventory = luau_decompiler::decompile(&original, &config).unwrap();
                        for (register, contract) in contracts {
                            let parameter = inventory
                                .bindings
                                .iter()
                                .find(|binding| binding.parameter && binding.register == *register)
                                .unwrap();
                            config.typing.binding_types.insert(
                                format!("p{}:b{}", parameter.proto, parameter.id),
                                (*contract).into(),
                            );
                        }
                        if version == 14
                            && optimization == 2
                            && debug == 2
                            && metadata == 0
                            && *family != "global_record"
                        {
                            config.validation.mode = ValidationMode::StrictRequired;
                        }
                        let result = luau_decompiler::decompile(&original, &config).unwrap();
                        assert!(result.complete, "{id}");
                        if config.validation.mode == ValidationMode::StrictRequired {
                            assert!(
                                result.validation.required_passed,
                                "{id}: {:?}",
                                result.validation
                            );
                            assert_eq!(
                                result.validation.strict_analysis,
                                GateStatus::Passed,
                                "{id}"
                            );
                        }
                        let stale =
                            luau_decompiler::type_ast::parse_type("{value:number}").unwrap();
                        assert!(
                            !result
                                .type_report
                                .evidence
                                .iter()
                                .any(|evidence| evidence.ty == stale
                                    && result.bindings.iter().any(|binding| !binding.parameter
                                        && format!("p{}:b{}", binding.proto, binding.id)
                                            == evidence.binding)),
                            "{id}: {:?}",
                            result.type_report.evidence
                        );
                        let rebuilt_source = directory.join("recovered.luau");
                        fs::write(&rebuilt_source, &result.source).unwrap();
                        let rebuilt = compile(&tools, &rebuilt_source, optimization, debug, 0);
                        let mut inputs = Vec::new();
                        for seed in [-3, 0, 7] {
                            let invocation = match *family {
                                "logical_alias" => format!("return callback({seed}~=0,mutate)"),
                                "loop_alias" => "return callback(mutate)".into(),
                                "global_record" => "local environment=getfenv(callback) environment.externalRecord=shared environment.mutate=mutate return callback()".into(),
                                _ => "return callback(factory,mutate)".into(),
                            };
                            let factory = if *family == "shared_pack" {
                                "return 9,shared,nil"
                            } else {
                                "return shared"
                            };
                            let mutate = if matches!(*family, "shared_effect" | "global_record") {
                                "shared.value=changed"
                            } else {
                                "for index=1,select('#',...) do local item=select(index,...) if type(item)=='table' then item.value=changed end end"
                            };
                            let probe_source = directory.join(format!("probe-{seed}.luau"));
                            fs::write(&probe_source,format!("local callback=...\nlocal shared={{value=1}}\nlocal changed=if {seed}==0 then nil elseif {seed}<0 then 'changed\\000\\255' else {seed}+0.5\nlocal function factory() {factory} end\nlocal function mutate(...) {mutate} end\n{invocation}\n")).unwrap();
                            let probe = compile(&tools, &probe_source, 0, 0, 0);
                            let probe_path = directory.join(format!("probe-{seed}.bc"));
                            fs::write(&probe_path, probe).unwrap();
                            let expected = tools
                                .observe_with_probe(
                                    &original,
                                    &directory,
                                    &format!("original-{seed}"),
                                    &[],
                                    Some(&probe_path),
                                )
                                .unwrap();
                            let actual = tools
                                .observe_with_probe(
                                    &rebuilt,
                                    &directory,
                                    &format!("recovered-{seed}"),
                                    &[],
                                    Some(&probe_path),
                                )
                                .unwrap();
                            assert!(
                                expected.verified()
                                    && actual.verified()
                                    && expected.equivalent(&actual),
                                "{id},seed={seed}: {expected:?} vs {actual:?}"
                            );
                            comparisons += 1;
                            inputs.push(json!({"seed":seed,"expected":expected,"actual":actual,"verified":true}));
                        }
                        rows.push(json!({"id":id,"source_sha256":support::digest(source.as_bytes()),"bytecode_sha256":support::digest(&original),"output_sha256":support::digest(result.source.as_bytes()),"recompiled_sha256":support::digest(&rebuilt),"config":config,"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"complete":result.complete,"validation":result.validation,"type_report":result.type_report,"inputs":inputs,"verified":true}));
                    }
                }
            }
        }
    }
    assert_eq!(rows.len(), 96);
    assert_eq!(comparisons, 288);
    fs::write(destination.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"families":families.iter().map(|family|family.0).collect::<Vec<_>>(),"cases":rows.len(),"typed_comparisons":comparisons,"oracle_protocol":"LOBS/1","all_verified":true,"rows":rows})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers, analyzer and typed oracle"]
fn later_scalar_iterations_preserve_strict_output_and_observed_returns() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/rc3-reliability/scalar-loop");
    fs::create_dir_all(&directory).unwrap();
    let source = "local x=1 local y=x for index=1,3 do y=x x='changed' end return y";
    let original_path = directory.join("original.luau");
    fs::write(&original_path, source).unwrap();
    let analyzer = root.join(".tools/luau-modern/luau-analyze.exe");
    let mut rows = Vec::new();
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for optimization in [0, 2] {
            let original = compile(&tools, &original_path, optimization, 2, 0);
            let mut config = Config::default();
            config.validation.mode = ValidationMode::Off;
            let output = luau_decompiler::decompile(&original, &config).unwrap();
            let rebuilt_path = directory.join(format!("v{version}-O{optimization}-rebuilt.luau"));
            fs::write(&rebuilt_path, &output.source).unwrap();
            let analysis = Command::new(&analyzer).arg(&rebuilt_path).output().unwrap();
            assert!(
                analysis.status.success(),
                "v{version}/O{optimization}: {}\n{}",
                String::from_utf8_lossy(&analysis.stderr),
                output.source
            );
            let rebuilt = compile(&tools, &rebuilt_path, optimization, 2, 0);
            let expected = tools
                .observe(&original, &directory, "original", &[])
                .unwrap();
            let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
            assert!(expected.equivalent(&actual));
            assert_eq!(
                actual.terminal,
                [support::oracle::Value::String(b"changed".to_vec())]
            );
            rows.push(json!({"id":format!("v{version}/O{optimization}"),"input_sha256":support::digest(&original),"source_sha256":support::digest(output.source.as_bytes()),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"strict_passed":true,"verified":true,"expected":expected,"actual":actual,"type_report":output.type_report}));
        }
    }
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"passed":true,"version":env!("CARGO_PKG_VERSION"),"analyzer_sha256":support::digest(&fs::read(analyzer).unwrap()),"cases":rows})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers, analyzer and typed oracle"]
fn captured_scalars_and_immediate_closures_preserve_strict_types_and_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/rc4-core/captures");
    fs::create_dir_all(&destination).unwrap();
    let analyzer = root.join(".tools/luau-modern/luau-analyze.exe");
    let families = [
        (
            "scalar_write",
            "local value=1 local callback=function() return value end value='changed' return callback()",
        ),
        (
            "delayed_initialization",
            "local value local callback=function() return value end local early=callback() value=7 return early,callback(),nil",
        ),
        (
            "callback_dependency",
            "local value=1 local callback=function() return value end local forward=function() return callback() end value='changed' return forward()",
        ),
        (
            "captured_writer",
            "local value=1 local callback=function() return value end local change=function() value='changed' end change() return callback()",
        ),
        (
            "immediate_scalar",
            include_str!("../fixtures/runtime/verified.luau"),
        ),
        (
            "recursive_reference",
            "local count: number=0 local callback callback=function(value: number): number count+=1 if value==0 then return count end return callback(value-1) end return callback(3)",
        ),
        (
            "value_capture_identity",
            "local previous local result={} for index=1,3 do local value=index local callback=function() return value end result[index]=callback previous=callback end return result[1](),result[2](),previous(),result[1]==result[2]",
        ),
    ];
    let mut rows = Vec::new();
    for (family, source) in families {
        let source_path = destination.join(format!("{family}.luau"));
        fs::write(&source_path, source).unwrap();
        for version in [6, 14] {
            let tools = support::Toolset::checked(root, version);
            for optimization in [0, 2] {
                let id = format!("{family}/v{version}/O{optimization}");
                let directory = destination.join(id.replace('/', "-"));
                fs::create_dir_all(&directory).unwrap();
                let original = compile(&tools, &source_path, optimization, 2, 1);
                let mut config = Config::default();
                config.validation.mode = ValidationMode::Off;
                let result = luau_decompiler::decompile(&original, &config).unwrap();
                let recovered_path = directory.join("recovered.luau");
                fs::write(&recovered_path, &result.source).unwrap();
                fs::write(
                    directory.join("result.json"),
                    serde_json::to_vec_pretty(&result).unwrap(),
                )
                .unwrap();
                let analysis = Command::new(&analyzer)
                    .arg(&recovered_path)
                    .output()
                    .unwrap();
                let required_strict =
                    !matches!(family, "recursive_reference" | "value_capture_identity");
                assert!(
                    analysis.status.success() || !required_strict,
                    "{id}: {}\n{}",
                    String::from_utf8_lossy(&analysis.stderr),
                    result.source
                );
                if family == "immediate_scalar" {
                    assert!(
                        result
                            .source
                            .contains("local function add(value: number): number\n"),
                        "{id}: {}",
                        result.source
                    );
                    assert!(
                        result.source.contains("local answer: number = "),
                        "{id}: {}",
                        result.source
                    );
                    if optimization == 0 {
                        assert!(
                            result.source.contains("local answer: number = add(40)"),
                            "{id}: {}",
                            result.source
                        );
                    }
                    assert!(
                        !result.source.contains("closure_ready"),
                        "{id}: {}",
                        result.source
                    );
                }
                let rebuilt = compile(&tools, &recovered_path, optimization, 2, 0);
                let expected = tools
                    .observe(&original, &directory, "original", &[])
                    .unwrap();
                let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
                assert!(
                    expected.verified() && actual.verified() && expected.equivalent(&actual),
                    "{id}: {expected:?} vs {actual:?}"
                );
                rows.push(json!({"id":id,"source_sha256":support::digest(source.as_bytes()),"input_sha256":support::digest(&original),"output_sha256":support::digest(result.source.as_bytes()),"recompiled_sha256":support::digest(&rebuilt),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"analyzer_sha256":support::digest(&fs::read(&analyzer).unwrap()),"complete":result.complete,"strict_required":required_strict,"strict_passed":analysis.status.success(),"strict_diagnostics":String::from_utf8_lossy(&analysis.stderr),"type_report":result.type_report,"config":config,"expected":expected,"actual":actual,"behavior_verified":true}));
            }
        }
    }
    assert_eq!(rows.len(), 28);
    fs::write(destination.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"oracle_protocol":"LOBS/1","families":families.iter().map(|(name,_)|name).collect::<Vec<_>>(),"cases":rows.len(),"behavior_verified":true,"rows":rows})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compiler, strict analyzer and typed oracle"]
fn verified_runtime_packet_is_readable_meaningfully_typed_and_behavioral() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/rc4-core/verified-packet");
    fs::create_dir_all(&directory).unwrap();
    let original = include_bytes!("../fixtures/runtime/verified.bc");
    let mut config = Config::default();
    config.validation.mode = ValidationMode::StrictRequired;
    config.output_policy = OutputPolicy::VerifiedTyped;
    let result = luau_decompiler::decompile(original, &config).unwrap();
    fs::write(
        directory.join("result.json"),
        serde_json::to_vec_pretty(&result).unwrap(),
    )
    .unwrap();
    assert!(result.complete);
    assert!(
        result.validation.required_passed,
        "{:?}\n{}",
        result.validation, result.source
    );
    assert_eq!(result.validation.strict_analysis, GateStatus::Passed);
    assert!(
        result
            .source
            .contains("local function add(value: number): number\n"),
        "{}",
        result.source
    );
    assert!(
        result.source.contains("local answer: number = add(40)"),
        "{}",
        result.source
    );
    assert!(
        !result.source.contains("closure_ready"),
        "{}",
        result.source
    );
    assert!(!result.source.contains("\ndo\n"), "{}", result.source);
    assert!(!result.source.contains("...number"), "{}", result.source);
    assert_eq!(result.type_report.emitted_explicit_any, 0);
    assert!(result.type_report.emitted_useful_annotations >= 3);
    let recovered = directory.join("recovered.luau");
    fs::write(&recovered, &result.source).unwrap();
    let tools = support::Toolset::checked(root, original[0]);
    let rebuilt = compile(&tools, &recovered, 0, 2, 0);
    let expected = tools
        .observe(original, &directory, "original", &[])
        .unwrap();
    let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
    assert!(expected.verified() && actual.verified() && expected.equivalent(&actual));
    assert_eq!(
        actual.terminal,
        [support::oracle::Value::Number(42f64.to_bits())]
    );
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"id":"fixtures/runtime/verified.bc","complete":result.complete,"input_sha256":support::digest(original),"source_sha256":support::digest(result.source.as_bytes()),"config":config,"type_report":result.type_report,"validation":result.validation,"expected":expected,"actual":actual,"behavior_verified":true,"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers and typed oracle"]
fn open_result_scratch_distinguishes_future_closed_and_active_captures() {
    use bytecode::Opcode;
    use luau_decompiler::{cfg::Cfg, dataflow::Ssa};
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/rc4-core/open-captures");
    fs::create_dir_all(&destination).unwrap();
    let families = [
        ("future_capture", "local function values(...) return ... end local array={values(1,nil,3)} local value=4 local callback=function(delta) value+=delta return value end return array[1],array[2],array[3],callback(2),nil"),
        ("closed_capture", "local callback do local a,b,c,d,e,f,g,h=string.byte('ABCDEFGH',1,8) local value=a+b+c+d+e+f+g+h callback=function(delta) value+=delta return value end end local function values(...) return ... end local array={values(1,nil,3)} return callback(2),array[1],array[2],array[3],nil"),
    ];
    let mut rows = Vec::new();
    for (family, source) in families {
        let path = destination.join(format!("{family}.luau"));
        fs::write(&path, source).unwrap();
        for version in [6, 14] {
            let tools = support::Toolset::checked(root, version);
            for optimization in [0, 2] {
                let id = format!("{family}/v{version}/O{optimization}");
                let directory = destination.join(id.replace('/', "-"));
                fs::create_dir_all(&directory).unwrap();
                let original = compile(&tools, &path, optimization, 2, 0);
                let module = bytecode::decode(&original, &Default::default()).unwrap();
                let mut qualifying = 0;
                for proto in &module.protos {
                    let cfg = Cfg::build(proto, &Default::default()).unwrap();
                    let ssa = Ssa::analyze(proto, &cfg, &Default::default()).unwrap();
                    for (index, instruction) in proto.code.iter().enumerate() {
                        if (instruction.op == Opcode::Call && instruction.c() == 0)
                            || (instruction.op == Opcode::GetVarargs && instruction.b() == 0)
                        {
                            let crossed = proto
                                .code
                                .iter()
                                .filter(|capture| {
                                    capture.op == Opcode::Capture
                                        && capture.a() == 1
                                        && capture.b() >= instruction.a()
                                        && !ssa.open_captures_before[index].contains(capture.b())
                                })
                                .count();
                            qualifying += crossed;
                        }
                    }
                }
                assert!(qualifying > 0, "{id} must contain an open range crossing an inactive reference-captured register");
                let mut config = Config::default();
                config.validation.mode = ValidationMode::Off;
                let result = luau_decompiler::decompile(&original, &config).unwrap();
                let recovered = directory.join("recovered.luau");
                fs::write(&recovered, &result.source).unwrap();
                let rebuilt = compile(&tools, &recovered, optimization, 2, 0);
                let expected = tools
                    .observe(&original, &directory, "original", &[])
                    .unwrap();
                let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
                assert!(
                    expected.verified() && actual.verified() && expected.equivalent(&actual),
                    "{id}: {expected:?} vs {actual:?}\n{}",
                    result.source
                );
                rows.push(json!({"id":id,"input_sha256":support::digest(&original),"source_sha256":support::digest(result.source.as_bytes()),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"qualifying_inactive_captures":qualifying,"expected":expected,"actual":actual,"behavior_verified":true}));
            }
        }
    }
    let negative_source = destination.join("active-capture.luau");
    fs::write(&negative_source, "local value=1 local callback=function() return value end value=2 local function values(...) return ... end return values() ").unwrap();
    let tools = support::Toolset::checked(root, 6);
    let negative = compile(&tools, &negative_source, 0, 2, 0);
    let mut module = bytecode::decode(&negative, &Default::default()).unwrap();
    let proto = &mut module.protos[module.main];
    let call = proto
        .code
        .iter()
        .position(|i| i.op == Opcode::Call && i.c() == 0)
        .unwrap();
    let old_register = proto.code[call].a();
    let active = proto
        .code
        .iter()
        .find(|i| i.op == Opcode::Capture && i.a() == 1)
        .unwrap()
        .b();
    assert!(active < old_register);
    let callee = proto.code[..call]
        .iter_mut()
        .rev()
        .find(|i| i.op == Opcode::Move && i.a() == old_register)
        .unwrap();
    callee.word = (callee.word & !(255 << 8)) | ((active as u32) << 8);
    proto.code[call].word = (proto.code[call].word & !(255 << 8)) | ((active as u32) << 8);
    let returned = proto.code[call + 1..]
        .iter_mut()
        .find(|i| i.op == Opcode::Return && i.b() == 0)
        .unwrap();
    returned.word = (returned.word & !(255 << 8)) | ((active as u32) << 8);
    assert_eq!(proto.code[call + 1].op, Opcode::CloseUpvals);
    let cfg = Cfg::build(proto, &Default::default()).unwrap();
    let ssa = Ssa::analyze(proto, &cfg, &Default::default()).unwrap();
    assert!(ssa.open_captures_before[call].contains(active));
    assert!(!ssa.open_captures_before[call + 2].contains(active));
    let error =
        luau_decompiler::structure::decompile_module(&module, &Config::default()).unwrap_err();
    assert_eq!(error.stage, "structure");
    assert!(
        error
            .message
            .contains("producer overwrites active reference-captured register"),
        "{error}"
    );
    fs::write(destination.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"cases":rows.len(),"rows":rows,"active_capture_negative":{"source_sha256":support::digest(&negative),"error":error.to_string(),"producer_before_close":true,"rejected":true}})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers and typed oracle"]
fn fresh_closure_identity_survives_output_optimization_and_repeated_entry() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/rc4-core/fresh-closures");
    fs::create_dir_all(&destination).unwrap();
    let families = [
        ("nested", "local function make() return function() return 7 end end local first,second=make(),make() return first==second,first(),second()", false),
        ("loop", "local callbacks={} for index=1,3 do callbacks[index]=function() return 7 end end return callbacks[1]==callbacks[2],callbacks[1](),callbacks[2]()", false),
        ("reference", "local function make() local value=1 local callback=function() return value end value=2 return callback end local first,second=make(),make() return first==second,first(),second()", false),
        ("value", "local shared=1 local function make() local value=shared return function() return value end end local first,second=make(),make() return first==second,first(),second()", false),
        ("repeated", "local callback=function() return 7 end local same=callback==previousCallback previousCallback=callback return same", true),
    ];
    let mut rows = Vec::new();
    for (family, source, repeated) in families {
        let source_path = destination.join(format!("{family}.luau"));
        fs::write(&source_path, source).unwrap();
        for version in [6, 14] {
            let tools = support::Toolset::checked(root, version);
            let original = compile(&tools, &source_path, 0, 2, 0);
            let module = bytecode::decode(&original, &Default::default()).unwrap();
            assert!(module
                .protos
                .iter()
                .flat_map(|p| &p.code)
                .all(|i| i.op != bytecode::Opcode::DupClosure));
            for output_optimization in [0, 2] {
                let id = format!("{family}/v{version}/input-O0/output-O{output_optimization}");
                let directory = destination.join(id.replace('/', "-"));
                fs::create_dir_all(&directory).unwrap();
                let mut config = Config::default();
                config.validation.mode = ValidationMode::Off;
                if repeated {
                    config.closures.entry_invocation =
                        luau_decompiler::config::EntryInvocation::Repeated;
                }
                let result = luau_decompiler::decompile(&original, &config).unwrap();
                assert!(
                    result.source.contains("closure_ready"),
                    "{id}: {}",
                    result.source
                );
                let path = directory.join("recovered.luau");
                fs::write(&path, &result.source).unwrap();
                let rebuilt = compile(&tools, &path, output_optimization, 2, 0);
                let observe = |bytes: &[u8], label: &str| {
                    if !repeated {
                        return tools.observe(bytes, &directory, label, &[]).unwrap();
                    }
                    let code = directory.join(format!("{label}.bc"));
                    fs::write(&code, bytes).unwrap();
                    let output = Command::new(&tools.runner)
                        .arg(code)
                        .args(["--repeat-entry", "2"])
                        .output()
                        .unwrap();
                    assert!(
                        output.status.success(),
                        "{id}: {}",
                        String::from_utf8_lossy(&output.stderr)
                    );
                    assert!(String::from_utf8_lossy(&output.stderr)
                        .contains("ENTRY invocations=2 requested=2"));
                    support::oracle::Observation::decode(&output.stdout).unwrap()
                };
                let expected = observe(&original, "original");
                let actual = observe(&rebuilt, "rebuilt");
                assert!(
                    expected.verified() && actual.verified() && expected.equivalent(&actual),
                    "{id}: {expected:?} vs {actual:?}\n{}",
                    result.source
                );
                assert_eq!(
                    actual.terminal.first(),
                    Some(&support::oracle::Value::Boolean(false))
                );
                rows.push(json!({"id":id,"input_sha256":support::digest(&original),"source_sha256":support::digest(result.source.as_bytes()),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"config":config,"entry_invocations":if repeated {2} else {1},"expected":expected,"actual":actual,"behavior_verified":true}));
            }
        }
    }
    assert_eq!(rows.len(), 20);
    fs::write(destination.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"cases":rows.len(),"rows":rows,"all_behavior_verified":true})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers and typed oracle"]
fn nested_cfg_failure_retains_child_diagnostics_without_parent_panic() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/rc4-core/nested-cfg");
    fs::create_dir_all(&directory).unwrap();
    let source = "local function contains(values,target) for _,value in values do if value==target then return true end end return false end local function choose(entries,first,second) local total=0 for _,entry in entries do if contains(first,entry) or contains(second,entry) then total+=1 end end return total end return choose";
    let path = directory.join("original.luau");
    fs::write(&path, source).unwrap();
    let mut rows = Vec::new();
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        let original = compile(&tools, &path, 2, 2, 0);
        let module = bytecode::decode(&original, &Default::default()).unwrap();
        assert_eq!(
            luau_decompiler::cfg::Cfg::build(&module.protos[module.main], &Default::default())
                .unwrap()
                .blocks
                .len(),
            1
        );
        let mut config = Config::default();
        config.validation.mode = ValidationMode::Off;
        config.control_flow = luau_decompiler::ControlFlowMode::Structured;
        let structured = luau_decompiler::decompile(&original, &config).unwrap_err();
        assert_ne!(structured.proto, Some(module.main));
        config.control_flow = luau_decompiler::ControlFlowMode::Auto;
        let automatic = std::panic::catch_unwind(|| luau_decompiler::decompile(&original, &config))
            .expect("child reconstruction failure must not panic in the parent")
            .unwrap_err();
        assert_eq!(automatic.stage, "structure");
        assert_ne!(automatic.proto, Some(module.main));
        assert!(automatic.pc.is_some());
        assert_eq!(
            automatic.message,
            "unconditional edge crosses an unsupported structured region"
        );
        let probe_path = directory.join(format!("probe-v{version}.luau"));
        fs::write(
            &probe_path,
            "local choose=... return choose({1,3,9},{1,2},{3}),choose({7},{1},{2})",
        )
        .unwrap();
        let probe = compile(&tools, &probe_path, 0, 2, 0);
        let probe_bytes = directory.join(format!("probe-v{version}.bc"));
        fs::write(&probe_bytes, probe).unwrap();
        let observed = tools
            .observe_with_probe(
                &original,
                &directory,
                &format!("original-v{version}"),
                &[],
                Some(&probe_bytes),
            )
            .unwrap();
        assert!(observed.verified());
        assert_eq!(
            observed.terminal,
            [
                support::oracle::Value::Number(2f64.to_bits()),
                support::oracle::Value::Number(0f64.to_bits())
            ]
        );
        rows.push(json!({"id":format!("nested_cfg/v{version}/O2"),"input_sha256":support::digest(&original),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"original_observation":observed,"structured_error":structured.to_string(),"automatic_error":automatic.to_string(),"panic":false,"reconstruction_complete":false,"status":"unsupported_control_flow_with_contextual_diagnostic"}));
    }
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"cases":rows.len(),"rows":rows,"all_contextual_diagnostics":true,"reconstruction_successes":0})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers and typed oracle"]
fn formatted_parenthesized_calls_at_block_entries_compile_and_preserve_effects() {
    use luau_decompiler::ast::{Expr, Function, Stmt};
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/rc4-core/block-separators");
    fs::create_dir_all(&directory).unwrap();
    let call = |label: &str| {
        Stmt::Call(Expr::Call(
            Box::new(Expr::Function(Box::new(Function {
                origin: None,
                parameters: vec![],
                vararg: false,
                body: vec![Stmt::Call(Expr::Call(
                    Box::new(Expr::Global("print".into())),
                    vec![Expr::Literal(format!("\"{label}\""))],
                ))],
            }))),
            vec![],
        ))
    };
    let body = vec![
        call("root"),
        Stmt::If {
            condition: Expr::Literal("true".into()),
            yes: vec![call("if")],
            no: vec![call("else")],
        },
        Stmt::Do(vec![call("do")]),
        Stmt::Local(
            vec!["invoke".into()],
            vec![Expr::Function(Box::new(Function {
                origin: None,
                parameters: vec![],
                vararg: false,
                body: vec![call("function")],
            }))],
        ),
        Stmt::Call(Expr::Call(Box::new(Expr::name("invoke")), vec![])),
        Stmt::Local(vec!["value".into()], vec![Expr::Literal("1".into())]),
        call("after_assignment"),
        Stmt::Return(vec![Expr::Literal("\"done\"".into())]),
    ];
    let source = "(function() print('root') end)() if true then (function() print('if') end)() else (function() print('else') end)() end do (function() print('do') end)() end local function invoke() (function() print('function') end)() end invoke() local value=1; (function() print('after_assignment') end)() return 'done'";
    let original_path = directory.join("original.luau");
    fs::write(&original_path, source).unwrap();
    let formatted = luau_decompiler::format::format(&body, &Config::default()).unwrap();
    let formatted_path = directory.join("formatted.luau");
    fs::write(&formatted_path, &formatted).unwrap();
    assert!(!formatted.contains("then\n    ;"), "{formatted}");
    assert!(!formatted.contains("do\n    ;"), "{formatted}");
    assert!(formatted.contains("\n;(function("), "{formatted}");
    let mut rows = Vec::new();
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        let original = compile(&tools, &original_path, 0, 2, 0);
        let rebuilt = compile(&tools, &formatted_path, 0, 2, 0);
        let expected = tools
            .observe(&original, &directory, &format!("original-v{version}"), &[])
            .unwrap();
        let actual = tools
            .observe(&rebuilt, &directory, &format!("rebuilt-v{version}"), &[])
            .unwrap();
        assert!(
            expected.verified() && actual.verified() && expected.equivalent(&actual),
            "v{version}: {expected:?} vs {actual:?}"
        );
        rows.push(json!({"id":format!("block_separators/v{version}/O0"),"input_sha256":support::digest(&original),"source_sha256":support::digest(formatted.as_bytes()),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"expected":expected,"actual":actual,"compiled":true,"behavior_verified":true}));
    }
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"cases":rows.len(),"rows":rows,"all_behavior_verified":true})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compilers and typed oracle"]
fn getimport_inactive_padding_preserves_cached_and_fallback_observations() {
    use bytecode::{Constant, Opcode};
    fn read_varint(bytes: &[u8], cursor: &mut usize) -> usize {
        let mut value = 0usize;
        for shift in (0..35).step_by(7) {
            let part = bytes[*cursor];
            *cursor += 1;
            value |= ((part & 127) as usize) << shift;
            if part & 128 == 0 {
                return value;
            }
        }
        panic!("controlled compiler fixture has an invalid varint")
    }
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/rc4-core/import-padding");
    fs::create_dir_all(&destination).unwrap();
    let mut rows = Vec::new();
    let mut negative_identities = std::collections::BTreeSet::new();
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for fallback in [false, true] {
            let mode = if fallback { "fallback" } else { "cached" };
            let id = format!("getimport_padding/v{version}/{mode}");
            let directory = destination.join(format!("v{version}-{mode}"));
            fs::create_dir_all(&directory).unwrap();
            let source = format!("{}local first=_VERSION local second=math.huge print(first,second) local third=vector.one.X return first,second,third,nil", if fallback { "getfenv(0) " } else { "" });
            let source_path = directory.join("original.luau");
            fs::write(&source_path, &source).unwrap();
            let original = compile(&tools, &source_path, 1, 0, 0);
            let module = bytecode::decode(&original, &Default::default()).unwrap();
            assert_eq!(module.protos.len(), 1);
            let proto = &module.protos[0];
            let mut code_bytes = Vec::new();
            for instruction in &proto.code {
                code_bytes.extend_from_slice(&instruction.word.to_le_bytes());
                if let Some(aux) = instruction.aux {
                    code_bytes.extend_from_slice(&aux.to_le_bytes());
                }
            }
            let offsets = original
                .windows(code_bytes.len())
                .enumerate()
                .filter_map(|(offset, bytes)| (bytes == code_bytes).then_some(offset))
                .collect::<Vec<_>>();
            assert_eq!(
                offsets.len(),
                1,
                "controlled compiler code block must have an unambiguous serialized position"
            );
            let code_offset = offsets[0];
            let mut cursor = code_offset + code_bytes.len();
            assert_eq!(read_varint(&original, &mut cursor), proto.constants.len());
            let mut imports = std::collections::BTreeMap::new();
            for (index, constant) in proto.constants.iter().enumerate() {
                let tag = original[cursor];
                cursor += 1;
                match constant {
                    Constant::String(string) => {
                        assert_eq!(tag, 3);
                        assert_eq!(read_varint(&original, &mut cursor), string + 1);
                    }
                    Constant::Import(import) => {
                        assert_eq!(tag, 4);
                        assert_eq!(
                            u32::from_le_bytes(original[cursor..cursor + 4].try_into().unwrap()),
                            *import
                        );
                        imports.insert(index, cursor);
                        cursor += 4;
                    }
                    other => {
                        panic!("unexpected constant in controlled GETIMPORT fixture: {other:?}")
                    }
                }
            }
            let mut mutated = original.clone();
            let mut changes = Vec::new();
            let mut lengths = std::collections::BTreeSet::new();
            for (index, instruction) in proto.code.iter().enumerate() {
                if instruction.op != Opcode::GetImport {
                    continue;
                }
                let aux = instruction.aux.unwrap();
                let count = aux >> 30;
                lengths.insert(count);
                let mask = u32::MAX << (10 * (3 - count));
                let constant = instruction.d() as usize;
                let Constant::Import(import) = proto.constants[constant] else {
                    panic!("GETIMPORT fixture must reference an import")
                };
                let changed_import = (import & mask) | (0x1555_aaaa & !mask);
                let changed_aux = (aux & mask) | (0x2aa9_5555 & !mask);
                let import_offset = imports[&constant];
                let aux_offset = code_offset + instruction.pc * 4 + 4;
                mutated[import_offset..import_offset + 4]
                    .copy_from_slice(&changed_import.to_le_bytes());
                mutated[aux_offset..aux_offset + 4].copy_from_slice(&changed_aux.to_le_bytes());
                changes.push((
                    index,
                    constant,
                    aux_offset,
                    count,
                    import,
                    aux,
                    changed_import,
                    changed_aux,
                ));
            }
            assert_eq!(lengths, std::collections::BTreeSet::from([1, 2, 3]));
            let decoded = bytecode::decode(&mutated, &Default::default()).unwrap();
            let mut negatives = Vec::new();
            for (
                index,
                constant,
                aux_offset,
                count,
                _,
                original_aux,
                changed_import,
                changed_aux,
            ) in &changes
            {
                assert_eq!(
                    decoded.protos[0].constants[*constant],
                    Constant::Import(*changed_import)
                );
                assert_eq!(decoded.protos[0].code[*index].aux, Some(*changed_aux));
                for (kind, wrong) in [
                    ("active_index", changed_aux ^ (1 << 20)),
                    (
                        "path_count",
                        (changed_aux & !(3 << 30)) | ((count % 3 + 1) << 30),
                    ),
                ] {
                    let mut invalid = mutated.clone();
                    invalid[*aux_offset..*aux_offset + 4].copy_from_slice(&wrong.to_le_bytes());
                    let input_sha256 = support::digest(&invalid);
                    negative_identities.insert(input_sha256.clone());
                    let error = bytecode::decode(&invalid, &Default::default()).unwrap_err();
                    assert_eq!(error.stage, "validate");
                    assert_eq!(error.proto, Some(0));
                    assert_eq!(error.pc, Some(proto.code[*index].pc));
                    negatives.push(json!({"kind":kind,"input_sha256":input_sha256,"path_length":count,"original_auxiliary":original_aux,"padded_auxiliary":changed_aux,"mutated_auxiliary":wrong,"auxiliary_count":wrong>>30,"cached_import_id":changed_import,"expected_active_indices":(0..*count).map(|segment|(changed_import>>(20-10*segment))&1023).collect::<Vec<_>>(),"auxiliary_byte_offset":aux_offset,"pc":error.pc,"error":error.to_string(),"executed":false}));
                }
            }
            let mut config = Config {
                output_policy: OutputPolicy::Faithful,
                ..Config::default()
            };
            config.validation.mode = ValidationMode::Off;
            let result = luau_decompiler::decompile(&mutated, &config).unwrap();
            let recovered_path = directory.join("recovered.luau");
            fs::write(&recovered_path, &result.source).unwrap();
            let rebuilt = compile(&tools, &recovered_path, 1, 0, 0);
            let expected = tools
                .observe(&original, &directory, "original", &[])
                .unwrap();
            let altered = tools.observe(&mutated, &directory, "mutated", &[]).unwrap();
            let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
            assert!(
                expected.verified()
                    && altered.verified()
                    && actual.verified()
                    && expected.equivalent(&altered)
                    && altered.equivalent(&actual),
                "{id}: {expected:?} vs {altered:?} vs {actual:?}\n{}",
                result.source
            );
            assert_eq!(actual.events.len(), 1);
            assert_eq!(
                actual.events[0].values,
                [
                    support::oracle::Value::String(b"Luau".to_vec()),
                    support::oracle::Value::Number(f64::INFINITY.to_bits())
                ]
            );
            if version == 6 {
                assert_eq!(actual.outcome, support::oracle::Outcome::Error);
                assert_eq!(
                    actual.terminal,
                    [support::oracle::Value::String(
                        b"test:0: attempt to index vector with 'X'".to_vec()
                    )]
                );
            } else {
                assert_eq!(
                    actual.outcome,
                    support::oracle::Outcome::Return,
                    "{id}: {actual:?}"
                );
                assert_eq!(
                    actual.terminal,
                    [
                        support::oracle::Value::String(b"Luau".to_vec()),
                        support::oracle::Value::Number(f64::INFINITY.to_bits()),
                        support::oracle::Value::Number(1f64.to_bits()),
                        support::oracle::Value::Nil
                    ]
                );
            }
            rows.push(json!({"id":id,"input_sha256":support::digest(&original),"mutated_sha256":support::digest(&mutated),"source_sha256":support::digest(result.source.as_bytes()),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"path_lengths":[1,2,3],"mutations":changes,"negative_inputs":negatives,"environment":if fallback {"getfenv(0) disables safeenv before target GETIMPORT operations"} else {"pinned oracle sandbox initially has safeenv; nonnil standard-library import values are cache eligible"},"three_component_path":if version == 6 {"vector.one.X produces the preserved original error; pinned v6 VM has LuauVectorMetatable disabled, so this path cannot establish cached count-3 success"} else {"vector.one.X is present; cached and forced-unsafe fallback produce number 1"},"dispatch_counters":"not instrumented; branch eligibility follows pinned sandbox/getfenv/GETIMPORT implementation","expected":expected,"mutated":altered,"actual":actual,"behavior_verified":true}));
        }
    }
    assert_eq!(rows.len(), 4);
    let negative_rejection_checks: usize = rows
        .iter()
        .map(|row| row["negative_inputs"].as_array().unwrap().len())
        .sum();
    fs::write(destination.join("report.json"),serde_json::to_vec_pretty(&json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"cases":rows.len(),"negative_rejection_checks":negative_rejection_checks,"distinct_negative_inputs":negative_identities.len(),"rows":rows,"all_behavior_verified":true,"captured_programs_executed":0,"scope":"controlled compiler-derived padding mutations; cached/fallback branch eligibility is derived from pinned VM semantics, not measured dispatch counters"})).unwrap()).unwrap();
}
