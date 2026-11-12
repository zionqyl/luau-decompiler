mod support;
use luau_decompiler::{
    bytecode::{self, Opcode},
    config::EntryInvocation,
    decompile, Config,
};
use serde_json::json;
use std::{fs, path::Path, process::Command};

const CASES: &[&str] = &[
    "numeric_state",
    "noncapturing_nested",
    "reference_capture",
    "value_capture_loop",
];
fn observe(
    tools: &support::Toolset,
    bytes: &[u8],
    directory: &Path,
    label: &str,
    args: &[support::oracle::Value],
) -> support::oracle::Observation {
    let code = directory.join(format!("{label}.bc"));
    let input = directory.join(format!("{label}.args"));
    fs::write(&code, bytes).unwrap();
    fs::write(&input, support::oracle::encode_arguments(args).unwrap()).unwrap();
    let output = Command::new(&tools.runner)
        .arg(code)
        .arg("--args")
        .arg(input)
        .arg("--repeat-entry")
        .arg("2")
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8(output.stderr.clone()).unwrap()
    );
    let count = String::from_utf8(output.stderr).unwrap();
    assert!(
        count
            .lines()
            .any(|line| line == "ENTRY invocations=2 requested=2"),
        "{count}"
    );
    support::oracle::Observation::decode(&output.stdout).unwrap()
}

#[test]
#[ignore = "requires pinned typed VMs with --repeat-entry; mandatory repeated-root-entry evidence"]
fn same_loaded_entry_has_explicit_scope_and_observed_identity() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let artifacts = root.join("artifacts/v3-repeated-entry");
    fs::create_dir_all(&artifacts).unwrap();
    let mut results = Vec::new();
    let mut failures = Vec::new();
    let mut unsupported = 0;
    let mut verified = 0;
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for &name in CASES {
            for optimization in [1, 2] {
                for debug in [0, 2] {
                    let source = root.join(format!("tests/v3-repeat-corpus/{name}.luau"));
                    let original = tools.compile(&source, optimization, debug).unwrap();
                    let module = bytecode::decode(&original, &Config::default().limits).unwrap();
                    let duplicates = module
                        .protos
                        .iter()
                        .flat_map(|p| p.code.iter())
                        .filter(|i| i.op == Opcode::DupClosure)
                        .count();
                    let mut repeated = Config::default();
                    repeated.typing.mode = luau_decompiler::types::TypingMode::Off;
                    repeated.validation.mode = luau_decompiler::quality::ValidationMode::Off;
                    repeated.closures.entry_invocation = EntryInvocation::Repeated;
                    repeated.closures.compiler_closure_sharing = duplicates > 0;
                    let rebuilt = decompile(&original, &repeated);
                    let case_id = format!("{name}/v{version}/O{optimization}D{debug}");
                    if name == "value_capture_loop" {
                        let diagnostic = rebuilt.expect_err(
                            "captured prototype caches must reject strict repeated-entry mode",
                        );
                        assert!(diagnostic.message.contains("repeated-entry"));
                        assert!(diagnostic.proto.is_some() && diagnostic.pc.is_some());
                        let mut single = repeated.clone();
                        single.closures.entry_invocation = EntryInvocation::Single;
                        single.closures.compiler_closure_sharing = false;
                        let baseline = decompile(&original, &single).unwrap();
                        let scope = baseline.closure_scope.clone();
                        assert!(!scope.restrictions.is_empty());
                        let path = artifacts.join(format!(
                            "{name}.v{version}.O{optimization}.D{debug}.single.luau"
                        ));
                        fs::write(&path, &baseline.source).unwrap();
                        let bytes = tools.compile(&path, optimization, debug).unwrap();
                        let args = [support::oracle::Value::Number(7.0f64.to_bits())];
                        let expected = observe(&tools, &original, &artifacts, "original", &args);
                        let actual = observe(&tools, &bytes, &artifacts, "single-scope", &args);
                        assert!(expected.verified() && actual.verified());
                        results.push(json!({"case_id":case_id,"source_sha256":support::digest(&fs::read(&source).unwrap()),"original_sha256":support::digest(&original),"target_duplicate_instructions":duplicates,"status":"unsupported_repeated_entry","verified":false,"strict_rejection":diagnostic,"single_scope_report":scope,"single_scope_repeated_observation_matches":expected.equivalent(&actual),"expected_observation":expected,"actual_single_scope_observation":actual,"compiler_sha256":tools.compiler_hash,"runner_sha256":tools.runner_hash}));
                        unsupported += 1;
                        continue;
                    }
                    let result = rebuilt.unwrap_or_else(|e| panic!("{case_id}: {e}"));
                    if name == "noncapturing_nested" {
                        assert!(duplicates >= 2);
                        assert!(result
                            .closure_scope
                            .assumptions
                            .iter()
                            .any(|a| a.contains("O1/O2")));
                        let mut missing_contract = repeated.clone();
                        missing_contract.closures.compiler_closure_sharing = false;
                        assert!(decompile(&original, &missing_contract)
                            .unwrap_err()
                            .message
                            .contains("compiler_closure_sharing"));
                    }
                    let path =
                        artifacts.join(format!("{name}.v{version}.O{optimization}.D{debug}.luau"));
                    fs::write(&path, &result.source).unwrap();
                    let rebuilt = tools.compile(&path, optimization, debug).unwrap();
                    let args = [support::oracle::Value::Number(7.0f64.to_bits())];
                    let expected = observe(&tools, &original, &artifacts, "original", &args);
                    let actual = observe(&tools, &rebuilt, &artifacts, "rebuilt", &args);
                    let matched = expected.equivalent(&actual);
                    if !matched {
                        failures.push(case_id.clone());
                    }
                    results.push(json!({"case_id":case_id,"source_sha256":support::digest(&fs::read(&source).unwrap()),"original_sha256":support::digest(&original),"source_output_sha256":support::digest(result.source.as_bytes()),"recompiled_sha256":support::digest(&rebuilt),"target_duplicate_instructions":duplicates,"status":if matched{"verified_under_explicit_compiler_contract"}else{"mismatch"},"verified":matched,"entry_invocations":2,"observations":expected,"actual":actual,"scope_report":result.closure_scope,"compiler_sha256":tools.compiler_hash,"runner_sha256":tools.runner_hash}));
                    verified += usize::from(matched);
                }
            }
        }
    }
    assert_eq!(results.len(), 32);
    assert_eq!(unsupported, 8);
    assert_eq!(verified, 24, "supported repeated-entry comparisons failed");
    let report = json!({"schema":1,"oracle_protocol":support::oracle::PROTOCOL,"required_families":CASES,"distinct_source_programs":4,"cases":results.len(),"verified_supported_cases":verified,"explicitly_unsupported_cases":unsupported,"all_cases_verified":false,"unexpected_mismatches":failures,"scope":"same loaded root closure and environment, two invocations; explicit O1/O2 output-compiler sharing contract for supported DUPCLOSURE subset; captured cache cases reject and retain observed mismatch evidence","results":results});
    fs::write(
        root.join("docs/results/v3-repeated-entry.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    assert!(
        failures.is_empty(),
        "unexpected repeated-entry mismatches {failures:?}"
    );
}

#[test]
fn repeated_entry_contract_is_explicit_and_part_of_config() {
    let config = Config::default();
    assert_eq!(config.closures.entry_invocation, EntryInvocation::Single);
    assert!(!config.closures.compiler_closure_sharing);
    let changed: Config = serde_json::from_value(
        json!({"closures":{"entry_invocation":"repeated","compiler_closure_sharing":true}}),
    )
    .unwrap();
    assert_ne!(
        serde_json::to_vec(&config).unwrap(),
        serde_json::to_vec(&changed).unwrap()
    );
}
