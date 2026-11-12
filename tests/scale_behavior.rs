mod support;
use serde_json::json;
use std::{fs, path::Path};
use support::{digest, Toolset};

#[test]
#[ignore = "requires benchmarks/generate-scale.ps1 and pinned typed VM; run before scale measurements"]
fn large_scale_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let corpus = root.join("artifacts/scale-corpus");
    let manifest: serde_json::Value =
        serde_json::from_slice(&fs::read(corpus.join("manifest.json")).unwrap()).unwrap();
    let version = manifest["bytecode_version"].as_u64().unwrap() as u8;
    let tools = Toolset::checked(root, version);
    assert_eq!(manifest["compiler_sha256"], tools.compiler_hash);
    let inputs: Vec<_> = [-3.0f64, 0.0, 1.0, 7.0]
        .iter()
        .map(|&value| vec![support::oracle::Value::Number(value.to_bits())])
        .collect();
    let mut results = Vec::new();
    let mut failures = Vec::new();
    for case in manifest["cases"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|case| case["category"] != "many_independent_inputs")
    {
        let name = case["name"].as_str().unwrap();
        let source = corpus.join(case["source"].as_str().unwrap());
        assert_eq!(digest(&fs::read(&source).unwrap()), case["source_sha256"]);
        let fixture = fs::read(corpus.join(case["bytecode"].as_str().unwrap())).unwrap();
        assert_eq!(digest(&fixture), case["bytecode_sha256"]);
        assert_eq!(
            tools.compile(&source, 2, 2).unwrap(),
            fixture,
            "benchmark fixture must exactly match known-source compilation"
        );
        let directory = root.join(format!("artifacts/scale-behavior/{name}"));
        fs::create_dir_all(&directory).unwrap();
        let mut probes = Vec::new();
        if let Some(probe_file) = case["probe"].as_str() {
            let probe = fs::read(corpus.join(probe_file)).unwrap();
            assert_eq!(digest(&probe), case["probe_sha256"]);
            for seed in [-3, 0, 1, 7] {
                let mut wrapped = format!(
                    "local module = ...\nassert(#module == {})\nreturn (function(...)\n",
                    case["scale"].as_u64().unwrap()
                )
                .into_bytes();
                wrapped.extend_from_slice(&probe);
                wrapped.extend_from_slice(format!("\nend)({seed})\n").as_bytes());
                let path = directory.join(format!("seed{seed}.probe.luau"));
                fs::write(&path, &wrapped).unwrap();
                probes.push(tools.compile(&path, 0, 0).unwrap());
            }
        }
        let probes = if probes.is_empty() {
            None
        } else {
            Some(probes.as_slice())
        };
        match tools.differential_with_probes(&source,&directory,2,2,&inputs,probes) {
            Ok(evidence)=>results.push(json!({"name":name,"source_sha256":case["source_sha256"],"fixture_sha256":case["bytecode_sha256"],"verified":true,"evidence":evidence})),
            Err(error)=>{
                failures.push(format!("{name}: {error}"));
                results.push(json!({"name":name,"verified":false,"diagnostic":error}));
            }
        }
    }
    let report = json!({"schema":1,"oracle_protocol":support::oracle::PROTOCOL,"scope":"two large scale programs only; 2000 independent inputs not included","input_count":results.len(),"runtime_inputs":inputs,"typed_comparisons":(results.len()-failures.len())*4,"failures":failures,"results":results});
    fs::create_dir_all(root.join("docs/results")).unwrap();
    fs::write(
        root.join("docs/results/scale-behavior.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    assert_eq!(results.len(), 2);
    assert!(
        failures.is_empty(),
        "scale reconstruction/behavior failed: {failures:?}"
    );
}
