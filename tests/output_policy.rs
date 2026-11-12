use luau_decompiler::{
    config::OutputPolicy,
    quality::{self, GateStatus, QualityReport},
    types::TypeReport,
    Config,
};

#[test]
fn verified_policy_requires_validation_and_typing() {
    let mut config = Config {
        output_policy: OutputPolicy::VerifiedTyped,
        ..Config::default()
    };
    assert_eq!(
        config.effective().validation.mode,
        quality::ValidationMode::StrictRequired
    );
    config.validation.mode = quality::ValidationMode::Off;
    assert!(config.validate().is_err());
    config.validation.mode = quality::ValidationMode::Check;
    config.typing.mode = luau_decompiler::types::TypingMode::Off;
    assert!(config.validate().is_err());
}

#[test]
fn strict_success_does_not_replace_meaningful_typing() {
    let config = Config::default();
    let quality = QualityReport {
        syntax: GateStatus::Passed,
        compilation: GateStatus::Passed,
        strict_analysis: GateStatus::Passed,
        selected_strategy: "annotated".into(),
        ..QualityReport::default()
    };
    let mut types = TypeReport::default();
    assert!(!quality::meaningful_typing(&types, &quality, &config).passed);
    types.emitted_annotations = 1;
    types.emitted_useful_annotations = 1;
    assert!(!quality::meaningful_typing(&types, &quality, &config).passed);
    types.emittable_bindings = 4;
    types.annotated_bindings = 3;
    types.emitted_annotations = 4;
    types.emitted_runtime_annotations = 4;
    types.emitted_useful_annotations = 4;
    assert!(quality::meaningful_typing(&types, &quality, &config).passed);
    types.annotated_bindings = 2;
    assert!(!quality::meaningful_typing(&types, &quality, &config).passed);
    types.annotated_bindings = 4;
    types.emitted_explicit_any = 1;
    assert!(!quality::meaningful_typing(&types, &quality, &config).passed);
    types.emitted_explicit_any = 0;
    let baseline = QualityReport {
        selected_strategy: "faithful_baseline".into(),
        ..quality
    };
    assert!(!quality::meaningful_typing(&types, &baseline, &config).passed);
}

#[test]
fn missing_assets_never_verify_and_faithful_output_survives() {
    let mut config = Config {
        output_policy: OutputPolicy::VerifiedTyped,
        ..Config::default()
    };
    config.validation.analyzer_path = Some("artifacts/missing-rc-analyzer.exe".into());
    let result =
        luau_decompiler::decompile(include_bytes!("fixtures/arithmetic.O1.D2.bc"), &config)
            .unwrap();
    assert!(result.complete && !result.source.is_empty());
    assert!(result.baseline_source.is_some());
    assert!(!result.validation.required_passed);
    assert_eq!(result.validation.strict_analysis, GateStatus::Unavailable);

    let mut source = "local answer: number = 42\nreturn answer\n".to_owned();
    let original = source.clone();
    let report =
        quality::validate_source(&mut source, &mut None, &mut TypeReport::default(), &config)
            .unwrap();
    assert!(!report.required_passed);
    assert_eq!(
        source,
        format!("{}{original}", luau_decompiler::attribution::prefix(false))
    );
}

#[test]
#[ignore = "requires pinned independent analyzer and Roblox definitions"]
fn nested_external_dynamic_contracts_are_visible_and_cannot_verify() {
    use luau_decompiler::{process, InputFormat};
    let mut config = Config {
        output_policy: OutputPolicy::VerifiedTyped,
        ..Config::default()
    };
    config
        .validation
        .project
        .external_globals
        .insert("dynamicFunction".into(), "(...any) -> (...any)".into());
    let result = process(
        b"local answer: number = 42\nreturn dynamicFunction, answer",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert_eq!(result.validation.strict_analysis, GateStatus::Passed);
    assert_eq!(result.validation.external_contract_any, 2);
    assert!(!result.validation.meaningful_typing.passed);
    assert!(!result.validation.required_passed);
    assert!(!result.validation.external_assumptions.is_empty());
    config
        .validation
        .project
        .external_globals
        .insert("dynamicFunction".into(), "(number) -> unknown".into());
    let result = process(
        b"local answer: number = 42\nreturn dynamicFunction, answer",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert_eq!(result.validation.strict_analysis, GateStatus::Passed);
    assert_eq!(result.validation.external_contract_unknown, 1);
    assert!(!result.validation.required_passed);
    config.validation.project.external_globals.clear();
    let result = process(
        b"type Unused = number\nlocal function value() return 1 end\nreturn value",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert_eq!(result.validation.strict_analysis, GateStatus::Passed);
    assert_eq!(result.validation.meaningful_typing.runtime_annotations, 1);
    assert!(result.source.contains("local function value(): number"));
    assert!(result.validation.meaningful_typing.passed);
    assert!(result.validation.required_passed);
    let result = process(
        b"type Unused = number\nlocal function value(input) return input end\nreturn value",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert_eq!(result.validation.strict_analysis, GateStatus::Passed);
    assert_eq!(result.validation.meaningful_typing.runtime_annotations, 0);
    assert!(!result.validation.meaningful_typing.passed);
    assert!(!result.validation.required_passed);
}
