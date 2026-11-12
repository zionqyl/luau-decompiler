mod support;
use serde_json::json;
use std::{fs, path::Path};
use support::{digest, Toolset};

#[test]
#[ignore = "requires pinned v6/v14 compilers and typed VMs; mandatory application-module gate"]
fn application_modules_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let artifacts = root.join("artifacts/applications");
    fs::create_dir_all(&artifacts).unwrap();
    let argument_sets: Vec<_> = [-3.0f64, 0.0, 1.0, 7.0]
        .iter()
        .map(|&seed| vec![support::oracle::Value::Number(seed.to_bits())])
        .collect();
    let mut results = Vec::new();
    let mut failures = Vec::new();
    for name in ["queue", "signal", "store", "lru_cache"] {
        let module = fs::read(root.join(format!("tests/application-corpus/{name}.luau"))).unwrap();
        let probe =
            fs::read(root.join(format!("tests/application-corpus/{name}.probe.luau"))).unwrap();
        let source = artifacts.join(format!("{name}.luau"));
        let mut combined = b"local module = (function()\n".to_vec();
        combined.extend_from_slice(&module);
        combined.extend_from_slice(b"\nend)()\n");
        combined.extend_from_slice(&probe);
        fs::write(&source, &combined).unwrap();
        let module_source = root.join(format!("tests/application-corpus/{name}.luau"));
        for version in [6, 14] {
            let tools = Toolset::checked(root, version);
            let mut probe_bytecodes = Vec::new();
            for seed in [-3, 0, 1, 7] {
                let path = artifacts.join(format!("{name}.v{version}.seed{seed}.probe.luau"));
                let mut trusted = b"local module = ...\nreturn (function(...)\n".to_vec();
                trusted.extend_from_slice(&probe);
                trusted.extend_from_slice(format!("\nend)({seed})\n").as_bytes());
                fs::write(&path, &trusted).unwrap();
                probe_bytecodes.push(tools.compile(&path, 0, 0).unwrap());
            }
            for optimization in 0..=2 {
                for debug in [0, 2] {
                    for mode in ["combined_program", "standalone_module"] {
                        let directory = artifacts
                            .join(format!("{name}/v{version}/O{optimization}D{debug}/{mode}"));
                        let checked_source = if mode == "standalone_module" {
                            &module_source
                        } else {
                            &source
                        };
                        let probes = if mode == "standalone_module" {
                            Some(probe_bytecodes.as_slice())
                        } else {
                            None
                        };
                        match tools.differential_with_probes(checked_source,&directory,optimization,debug,&argument_sets,probes) {
                    Ok(evidence)=>results.push(json!({"module":name,"mode":mode,"module_sha256":digest(&module),"probe_sha256":digest(&probe),"combined_source_sha256":digest(&combined),"verified":true,"evidence":evidence})),
                    Err(diagnostic)=>{
                        failures.push(format!("{name} v{version} O{optimization}D{debug} {mode}: {diagnostic}"));
                        results.push(json!({"module":name,"mode":mode,"profile":tools.profile,"optimization":optimization,"debug":debug,"verified":false,"diagnostic":diagnostic}));
                    }
                }
                    }
                }
            }
        }
    }
    let report = json!({"schema":1,"oracle_protocol":support::oracle::PROTOCOL,"module_count":4,"compiled_cases":results.len(),"runtime_inputs":argument_sets,"typed_comparisons":(results.len()-failures.len())*4,"failed_cases":failures.len(),"failures":failures,"results":results});
    fs::create_dir_all(root.join("docs/results")).unwrap();
    fs::write(
        root.join("docs/results/applications.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    assert!(
        failures.is_empty(),
        "{} application cases failed; first: {:?}",
        failures.len(),
        &failures[..failures.len().min(5)]
    );
}
