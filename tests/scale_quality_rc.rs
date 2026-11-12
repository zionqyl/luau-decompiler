mod support;
use luau_decompiler::{quality::ValidationMode, Config, OutputPolicy};
use serde_json::json;
use std::{fs, path::Path};

#[test]
#[ignore = "requires generated scale fixtures, pinned compilers, strict analyzer and typed oracle"]
fn known_module_contracts_enable_a_verified_large_interface() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let path = root.join("artifacts/scale-corpus/large_module.bc");
    let bytes = fs::read(&path).unwrap();
    let directory = root.join("artifacts/scale-quality-rc");
    fs::create_dir_all(&directory).unwrap();
    let version = bytes[0];
    let tools = support::Toolset::checked(root, version);
    let mut config = Config {
        output_policy: OutputPolicy::Faithful,
        ..Config::default()
    };
    config.validation.mode = ValidationMode::Off;
    let inventory = luau_decompiler::decompile(&bytes, &config).unwrap();
    config.output_policy = OutputPolicy::Annotated;
    config.validation.mode = ValidationMode::StrictRequired;
    config.validation.timeout_ms = 30_000;
    config.validation.max_cache_bytes = 0;
    let unresolved = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(!unresolved.validation.required_passed);
    assert_eq!(
        unresolved.validation.strict_analysis,
        luau_decompiler::quality::GateStatus::Failed
    );
    for binding in inventory
        .bindings
        .iter()
        .filter(|binding| binding.parameter)
    {
        config.typing.binding_types.insert(
            format!("p{}:b{}", binding.proto, binding.id),
            "number".into(),
        );
    }
    assert_eq!(config.typing.binding_types.len(), 512);
    config.output_policy = OutputPolicy::VerifiedTyped;
    let result = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(
        result.validation.required_passed,
        "{:?}",
        result.validation.diagnostics
    );
    assert!(result.validation.meaningful_typing.passed);
    assert_eq!(result.validation.type_assertions, 0);
    let output_path = directory.join("module.luau");
    fs::write(&output_path, &result.source).unwrap();
    let recompiled = tools.compile(&output_path, 2, 2).unwrap();
    let mut comparisons = Vec::new();
    for seed in [-3.0f64, 0.0, 7.0] {
        let probe_source = directory.join(format!("probe-{seed}.luau"));
        fs::write(&probe_source, format!("local module=...\nlocal seed={seed}\nreturn module[1](seed),module[256](seed),module[512](seed)\n")).unwrap();
        let probe = directory.join(format!("probe-{seed}.bc"));
        fs::write(&probe, tools.compile(&probe_source, 0, 0).unwrap()).unwrap();
        let expected = tools
            .observe_with_probe(
                &bytes,
                &directory,
                &format!("original-{seed}"),
                &[],
                Some(&probe),
            )
            .unwrap();
        let actual = tools
            .observe_with_probe(
                &recompiled,
                &directory,
                &format!("recompiled-{seed}"),
                &[],
                Some(&probe),
            )
            .unwrap();
        assert_eq!(expected.outcome, support::oracle::Outcome::Return);
        assert_eq!(expected.terminal.len(), 3);
        assert!(expected
            .terminal
            .iter()
            .all(|value| matches!(value, support::oracle::Value::Number(_))));
        assert!(expected.verified() && expected.equivalent(&actual));
        comparisons.push(json!({"seed":seed,"expected":expected,"actual":actual,"verified":true}));
    }
    let report = json!({"schema":1,"passed":true,"unresolved_context":{"strict_analysis":unresolved.validation.strict_analysis,"required_passed":unresolved.validation.required_passed,"diagnostics":unresolved.validation.diagnostics.len()},"supplied_number_parameter_contracts":512,"input_sha256":support::digest(&bytes),"source_sha256":support::digest(result.source.as_bytes()),"recompiled_sha256":support::digest(&recompiled),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"configuration":config,"validation":result.validation,"types":result.type_report,"typed_comparisons":comparisons,"scope":"known generated512-function module; declared numeric parameter contracts, not guessed polymorphic interfaces"});
    fs::write(
        root.join("docs/results/scale-quality-rc.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
}
