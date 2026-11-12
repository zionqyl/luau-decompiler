mod oracle;
use luau_decompiler::{
    bytecode::{self, Opcode},
    decompile,
    types::TypingMode,
    Config,
};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::{fs, path::Path, process::Command};

fn serialize_synthetic_template(module: &bytecode::Module) -> Vec<u8> {
    let mut body = vec![1, 0, 0, 1, 0, 0, 3];
    for instruction in &module.protos[0].code {
        body.extend_from_slice(&instruction.word.to_le_bytes());
    }
    body.push(3);
    for constant in &module.protos[0].constants[..2] {
        let bytecode::Constant::String(id) = constant else {
            unreachable!()
        };
        body.extend_from_slice(&[3, (*id + 1) as u8]);
    }
    match &module.protos[0].constants[2] {
        bytecode::Constant::Table(_) => body.extend_from_slice(&[5, 2, 0, 1]),
        bytecode::Constant::TableWithConstants(_) => {
            body.extend_from_slice(&[8, 2, 0]);
            body.extend_from_slice(&u32::MAX.to_le_bytes());
            body.push(1);
            body.extend_from_slice(&u32::MAX.to_le_bytes());
        }
        _ => unreachable!(),
    }
    body.extend_from_slice(&[0, 0, 0, 0, 0]);
    if module.version >= 11 {
        body.push(0);
    }
    let mut bytes = vec![module.version, 3, module.strings.len() as u8];
    for string in &module.strings {
        bytes.push(string.len() as u8);
        bytes.extend_from_slice(string);
    }
    bytes.extend_from_slice(&[0, 1]);
    if module.version >= 12 {
        assert!(body.len() < 128);
        bytes.push(body.len() as u8);
    }
    bytes.extend_from_slice(&body);
    bytes.push(0);
    bytes
}

#[test]
fn duplicate_template_string_bytes_reject_with_precise_unsupported_location() {
    use bytecode::{Constant, Instruction, Module, Proto};
    for prefilled in [false, true] {
        for separate_pool_entries in [false, true] {
            let template = if prefilled {
                Constant::TableWithConstants(vec![(0, None), (1, None)])
            } else {
                Constant::Table(vec![0, 1])
            };
            let mut module = Module {
                version: if prefilled { 14 } else { 6 },
                type_version: 3,
                strings: if separate_pool_entries {
                    vec![vec![0, 255], vec![0, 255]]
                } else {
                    vec![vec![0, 255]]
                },
                protos: vec![Proto {
                    max_stack: 1,
                    num_params: 0,
                    num_upvalues: 0,
                    is_vararg: true,
                    flags: 0,
                    code: vec![
                        Instruction {
                            pc: 0,
                            word: Opcode::PrepVarargs as u32,
                            aux: None,
                            op: Opcode::PrepVarargs,
                        },
                        Instruction {
                            pc: 1,
                            word: (Opcode::DupTable as u32) | (2 << 16),
                            aux: None,
                            op: Opcode::DupTable,
                        },
                        Instruction {
                            pc: 2,
                            word: (Opcode::Return as u32) | (2 << 16),
                            aux: None,
                            op: Opcode::Return,
                        },
                    ],
                    constants: vec![
                        Constant::String(0),
                        Constant::String(usize::from(separate_pool_entries)),
                        template,
                    ],
                    children: Vec::new(),
                    line_defined: 0,
                    debug_name: None,
                    locals: Vec::new(),
                    upvalue_names: Vec::new(),
                    type_metadata: Default::default(),
                }],
                main: 0,
                userdata_types: Default::default(),
            };
            let error = match luau_decompiler::structure::decompile_module_report(
                &module,
                &Config::default(),
            ) {
                Ok(_) => panic!("duplicate key bytes cannot silently lose physical capacity"),
                Err(error) => error,
            };
            assert_eq!(error.stage, "structure");
            assert_eq!(error.proto, Some(0));
            assert_eq!(error.pc, Some(1));
            assert!(error
                .message
                .contains("unsupported physical template layout"));
            let encoded = serialize_synthetic_template(&module);
            bytecode::decode(&encoded, &Config::default().limits).expect(
                "duplicate byte values behind distinct key indices are valid serialized bytecode",
            );
            let full_error = decompile(&encoded, &Config::default()).unwrap_err();
            assert_eq!(full_error.stage, "structure");
            assert_eq!(full_error.proto, Some(0));
            assert_eq!(full_error.pc, Some(1));
            assert!(full_error
                .message
                .contains("unsupported physical template layout"));
            if separate_pool_entries {
                module.strings[1][1] = 254;
                bytecode::decode(
                    &serialize_synthetic_template(&module),
                    &Config::default().limits,
                )
                .unwrap();
                assert!(luau_decompiler::structure::decompile_module_report(
                    &module,
                    &Config::default(),
                )
                .is_ok());
            }
        }
    }
}
fn digest(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}
fn shape(bytes: &[u8], config: &Config) -> serde_json::Value {
    let module = bytecode::decode(bytes, &config.limits).unwrap();
    let p = &module.protos[module.main];
    let allocation = p
        .code
        .iter()
        .find(|i| matches!(i.op, Opcode::NewTable | Opcode::DupTable))
        .unwrap();
    json!({"opcode":format!("{:?}",allocation.op),"hash_hint":if allocation.op==Opcode::NewTable{Some(allocation.b())}else{None},"array_hint":allocation.aux})
}
#[test]
#[ignore = "requires all pinned modern compilers/typed VMs; regression for constructor key syntax and physical layout"]
fn hash_reservations_preserve_layout_across_presentation_profiles() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let corpus = root.join("tests/profile-fixtures");
    let manifest: serde_json::Value =
        serde_json::from_slice(&fs::read(corpus.join("manifest.json")).unwrap()).unwrap();
    let fixtures: Vec<_> = manifest["fixtures"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|f| f["source"] == "hash_table_layout.luau")
        .collect();
    assert_eq!(fixtures.len(), 72);
    let artifacts = root.join("artifacts/profile-hash-layout-v3");
    fs::create_dir_all(&artifacts).unwrap();
    let mut results = Vec::new();
    let mut failed = 0;
    for fixture in fixtures {
        let tag = fixture["upstream_tag"].as_str().unwrap();
        let directory = match tag {
            "0.726" => "luau-0.726",
            "0.730" => "luau-0.730",
            "0.746" => "luau-modern",
            _ => panic!("unpinned compiler"),
        };
        let compiler = root.join(format!(
            ".tools/{directory}/luau-compile{}",
            std::env::consts::EXE_SUFFIX
        ));
        let runner = root.join(format!(
            ".tools/{directory}/vm-runner{}",
            std::env::consts::EXE_SUFFIX
        ));
        assert_eq!(
            digest(&fs::read(&compiler).unwrap()),
            fixture["compiler_sha256"]
        );
        let stamp: serde_json::Value = serde_json::from_slice(
            &fs::read(format!("{}.manifest.json", runner.display())).unwrap(),
        )
        .unwrap();
        assert_eq!(
            stamp["harness_sha256"],
            digest(&fs::read(root.join("tests/vm_runner.cpp")).unwrap())
        );
        assert_eq!(stamp["runner_sha256"], digest(&fs::read(&runner).unwrap()));
        let fixture_path = corpus.join(fixture["bytecode"].as_str().unwrap());
        let bytes = fs::read(&fixture_path).unwrap();
        assert_eq!(digest(&bytes), fixture["sha256"]);
        let native = Command::new(&runner).arg(&fixture_path).output().unwrap();
        assert!(native.status.success());
        let original = oracle::Observation::decode(&native.stdout).unwrap();
        assert!(original.complete);
        for mode in [TypingMode::Off, TypingMode::Annotated] {
            let label = if mode == TypingMode::Off {
                "off"
            } else {
                "annotated"
            };
            let mut config = Config {
                profile: fixture["profile"].as_str().unwrap().into(),
                ..Config::default()
            };
            config.typing.mode = mode;
            let stem = fixture["bytecode"].as_str().unwrap().replace('/', "_");
            let work = artifacts.join(label);
            fs::create_dir_all(&work).unwrap();
            let source_path = work.join(format!("{stem}.luau"));
            let rebuilt_path = work.join(format!("{stem}.bc"));
            let reconstructed = decompile(&bytes, &config).unwrap();
            fs::write(&source_path, &reconstructed.source).unwrap();
            let mut command = Command::new(&compiler);
            command
                .arg("--binary")
                .arg(format!("-O{}", fixture["optimization"]))
                .arg(format!("-g{}", fixture["debug"]));
            if let Some(flags) = fixture["compiler_flags"].as_str().filter(|f| !f.is_empty()) {
                command.arg(format!("--fflags={flags}"));
            }
            let compiled = command.arg(&source_path).output().unwrap();
            assert!(
                compiled.status.success() && compiled.stdout.first().is_some_and(|b| *b != 0),
                "compiler failed for{}:{label}: status{} stdout{}bytes stderr{:?}",
                fixture["bytecode"],
                compiled.status,
                compiled.stdout.len(),
                compiled.stderr
            );
            fs::write(&rebuilt_path, &compiled.stdout).unwrap();
            let observed = Command::new(&runner).arg(&rebuilt_path).output().unwrap();
            assert!(observed.status.success());
            let rebuilt = oracle::Observation::decode(&observed.stdout).unwrap();
            fs::write(work.join(format!("{stem}.original.lobs")), &native.stdout).unwrap();
            fs::write(work.join(format!("{stem}.rebuilt.lobs")), &observed.stdout).unwrap();
            let original_shape = shape(&bytes, &config);
            let rebuilt_shape = shape(&compiled.stdout, &config);
            let verified = original.equivalent(&rebuilt) && original_shape == rebuilt_shape;
            failed += usize::from(!verified);
            results.push(json!({"case_id":format!("{}/{label}",fixture["bytecode"].as_str().unwrap()),"fixture":fixture["bytecode"],"typing":label,"profile":fixture["profile"],"compiler_sha256":fixture["compiler_sha256"],"runner_sha256":stamp["runner_sha256"],"source_sha256":digest(reconstructed.source.as_bytes()),"original_shape":original_shape,"rebuilt_shape":rebuilt_shape,"original_observation":original,"rebuilt_observation":rebuilt,"syntax":reconstructed.validation.syntax,"strict_analysis":reconstructed.validation.strict_analysis,"verified":verified}));
        }
    }
    assert_eq!(results.len(), 144);
    fs::write(root.join("docs/results/profile-hash-layout-v3.json"),serde_json::to_vec_pretty(&json!({"schema":1,"oracle_protocol":oracle::PROTOCOL,"fixtures":72,"presentation_profiles":["off","annotated"],"cases":results.len(),"verified":results.len()-failed,"failed":failed,"observation_normalization":"none; exact ordered typed effects and return tuples","results":results})).unwrap()).unwrap();
    assert_eq!(
        failed, 0,
        "hash layout changed in{failed}/144 cases; see docs/results/profile-hash-layout-v3.json"
    );
}
