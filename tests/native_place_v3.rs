use luau_decompiler::bytecode::{self, Opcode};
use serde_json::{json, Value};
use std::{fs, path::Path, process::Command};

#[test]
fn controlled_native_fixture_catalog_keeps_distinct_identities_and_not_run_status() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let manifest: Value =
        serde_json::from_slice(&fs::read(root.join("fixtures/roblox-v3/manifest.json")).unwrap())
            .unwrap();
    assert_eq!(manifest["distinct_native_programs_planned"], 14);
    assert_eq!(manifest["native_programs_verified"], 0);
    assert_eq!(manifest["normal_engine_test_status"], "not_run");
    let cases = manifest["cases"].as_array().unwrap();
    assert_eq!(cases.len(), 14);
    let mut ids = std::collections::BTreeSet::new();
    let mut classes = std::collections::BTreeMap::new();
    for case in cases {
        let id = case["id"].as_str().unwrap();
        assert!(ids.insert(id));
        let bytes = fs::read(
            root.join("fixtures/roblox-v3")
                .join(case["source_file"].as_str().unwrap()),
        )
        .unwrap();
        use sha2::Digest;
        assert_eq!(
            case["source_sha256"],
            format!("{:x}", sha2::Sha256::digest(&bytes))
        );
        *classes.entry(case["class"].as_str().unwrap()).or_insert(0) += 1;
        assert_eq!(case["native_extraction"], "not_run");
    }
    assert_eq!(classes.get("ModuleScript"), Some(&11));
    assert_eq!(classes.get("LocalScript"), Some(&2));
    assert_eq!(classes.get("Script"), Some(&1));
}

#[test]
#[ignore = "requires Windows PowerShell and pinned official compiler; fixture preparation only, never a native-client behavioral pass"]
fn validate_prepared_native_place_and_host_instruction_inventory() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let status = Command::new("powershell.exe")
        .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-File"])
        .arg(root.join("scripts/verify-native-fixtures.ps1"))
        .status()
        .unwrap();
    assert!(status.success());
    let manifest: Value =
        serde_json::from_slice(&fs::read(root.join("fixtures/roblox-v3/manifest.json")).unwrap())
            .unwrap();
    let mut rows = Vec::new();
    for case in manifest["cases"].as_array().unwrap() {
        let id = case["id"].as_str().unwrap();
        let bytes =
            fs::read(root.join(format!("artifacts/native-v3-host-compile/{id}.bc"))).unwrap();
        let module = bytecode::decode(&bytes, &Default::default()).unwrap();
        let fastpcall = module
            .protos
            .iter()
            .flat_map(|p| &p.code)
            .filter(|i| i.op == Opcode::FastPcall)
            .count();
        if id == "ProtectedCalls" {
            assert!(
                fastpcall > 0,
                "Version14 alone cannot certify FASTPCALL coverage"
            );
        }
        rows.push(json!({"id":id,"host_format":module.version,"host_prototypes":module.protos.len(),"host_instructions":module.protos.iter().map(|p|p.code.len()).sum::<usize>(),"host_fastpcall_instructions":fastpcall,"native_engine_instruction_inventory":"not_run"}));
    }
    fs::write(root.join("docs/results/native-place-v3-host-instructions.json"),serde_json::to_vec_pretty(&json!({"schema":1,"host_inputs":rows.len(),"normal_engine_native_programs_verified":0,"scope":"Official host compiler preparation inventory, not normal-engine/client extraction evidence","results":rows})).unwrap()).unwrap();
}
