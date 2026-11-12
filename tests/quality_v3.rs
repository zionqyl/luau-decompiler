use luau_decompiler::{
    bytecode,
    quality::{self, GateStatus, ValidationMode},
    Config,
};
use serde_json::json;
use std::{fs, path::Path, process::Command};

fn compile(source: &str, name: &str) -> Vec<u8> {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let dir = root.join("artifacts/quality-v3");
    fs::create_dir_all(&dir).unwrap();
    let path = dir.join(format!("{name}.luau"));
    fs::write(&path, source).unwrap();
    let output = Command::new(root.join(".tools/luau-modern/luau-compile.exe"))
        .args([
            "--binary",
            "-O0",
            "-g2",
            "-t1",
            "--fflags=LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false",
        ])
        .arg(&path)
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "compiler: {}",
        String::from_utf8_lossy(&output.stderr)
    );
    output.stdout
}

#[test]
fn strict_configuration_bounds_and_missing_tools_keep_faithful_source() {
    let mut config = Config::default();
    config.validation.mode = ValidationMode::StrictRequired;
    config.validation.analyzer_path = Some("artifacts/does-not-exist-analyzer.exe".into());
    let result =
        luau_decompiler::decompile(include_bytes!("fixtures/arithmetic.O1.D2.bc"), &config)
            .unwrap();
    assert!(result.complete && !result.source.is_empty());
    assert!(!result.validation.required_passed);
    assert_eq!(result.validation.strict_analysis, GateStatus::Unavailable);
    assert!(result.baseline_source.is_some());
    config.validation.max_attempts = 0;
    assert!(config.validate().is_err());
}

#[test]
#[ignore = "requires the pinned official analyzer/Roblox definitions; mandatory v0.3 strict quality gate"]
fn independent_strict_analysis_and_finite_recovery() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mut config = Config::default();
    config.validation.mode = ValidationMode::StrictRequired;
    let mut rows = Vec::new();
    let bytes = compile(
        "local function update(value: number): number return value+2 end; return update",
        "typed_number",
    );
    let typed = luau_decompiler::decompile(&bytes, &config).unwrap();
    fs::write(
        root.join("artifacts/quality-v3/typed_number.result.json"),
        serde_json::to_vec_pretty(&typed).unwrap(),
    )
    .unwrap();
    assert!(
        typed.validation.required_passed,
        "{:?}",
        typed.validation.diagnostics
    );
    assert_eq!(typed.validation.syntax, GateStatus::Passed);
    assert_eq!(typed.validation.compilation, GateStatus::Passed);
    assert!(typed.type_report.emitted_useful_annotations > 0);
    assert_eq!(typed.validation.type_assertions, 0);
    rows.push(json!({"id":"typed_number","source":typed.source,"quality":typed.validation,"types":typed.type_report}));

    let bytes = compile("return UserSuppliedButMissingAPI(1)", "missing_global");
    let failed = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(failed.complete && !failed.validation.required_passed);
    assert!(failed.source.contains("UserSuppliedButMissingAPI"));
    assert_eq!(failed.validation.syntax, GateStatus::Passed);
    assert_eq!(failed.validation.compilation, GateStatus::Passed);
    assert_eq!(failed.validation.strict_analysis, GateStatus::Failed);
    assert!(failed
        .validation
        .external_globals
        .iter()
        .any(|g| g == "UserSuppliedButMissingAPI"));
    assert!(failed
        .validation
        .diagnostics
        .iter()
        .any(|d| d.proto.is_some()));
    rows.push(json!({"id":"missing_global","source":failed.source,"quality":failed.validation}));

    let bytes = compile(
        "local m=require('./dep');return m.double(2)",
        "project_resolution",
    );
    let unresolved = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(!unresolved.validation.required_passed);
    assert!(!unresolved.validation.missing_dependencies.is_empty());
    rows.push(json!({"id":"unresolved_module","quality":unresolved.validation}));
    config.validation.project.modules.insert(
        "dep".into(),
        "return {double=function(value:number):number return value*2 end}".into(),
    );
    let resolved = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(
        resolved.validation.required_passed,
        "{:?}",
        resolved.validation.diagnostics
    );
    let cached = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(cached.validation.required_passed && cached.validation.cache_hit);
    rows.push(json!({"id":"resolved_module_and_cache","quality":cached.validation}));
    config.validation.project.modules.insert(
        "dep".into(),
        "return {double=function(value:string):string return value end}".into(),
    );
    let changed = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(!changed.validation.required_passed);
    assert_ne!(
        changed.validation.context_sha256,
        resolved.validation.context_sha256
    );
    rows.push(json!({"id":"changed_project_hash_and_argument_type","quality":changed.validation}));
    config.validation.project.modules.clear();

    let bytes = compile("local value=1;return value", "recovery");
    let module = bytecode::decode_with_options(&bytes, &config.limits, "auto", "upstream").unwrap();
    let mut reconstruction =
        luau_decompiler::structure::decompile_module_report(&module, &config).unwrap();
    reconstruction.source = "--!strict\nlocal value: string=1\nreturn value\n".into();
    reconstruction.baseline_source = Some("local value=1\nreturn value\n".into());
    reconstruction.metadata_source =
        Some("--!strict\nlocal value: number=1\nreturn value\n".into());
    reconstruction.type_report.metadata_emitted_annotations = 1;
    reconstruction
        .type_report
        .metadata_emitted_useful_annotations = 1;
    let recovered =
        quality::validate_reconstruction(&mut reconstruction, &module, &config).unwrap();
    assert!(recovered.required_passed);
    assert_eq!(recovered.selected_strategy, "metadata_only");
    assert_eq!(recovered.attempts.len(), 2);
    assert!(reconstruction.source.contains("value: number"));
    assert!(!reconstruction.source.contains("::"));
    rows.push(json!({"id":"supported_annotation_strategy_recovery","source":reconstruction.source,"quality":recovered}));

    config.validation.max_attempts = 1;
    reconstruction.source = "--!strict\nlocal value: string=1\nreturn value\n".into();
    let exhausted =
        quality::validate_reconstruction(&mut reconstruction, &module, &config).unwrap();
    assert!(!exhausted.required_passed);
    assert_eq!(exhausted.attempts.len(), 1);
    assert!(reconstruction.baseline_source.is_some());
    rows.push(json!({"id":"recovery_exhaustion_retains_baseline","quality":exhausted}));
    config.validation.max_attempts = 3;
    reconstruction.source = "return (\n".into();
    reconstruction.metadata_source = None;
    let syntax = quality::validate_reconstruction(&mut reconstruction, &module, &config).unwrap();
    assert!(syntax.required_passed);
    assert_eq!(syntax.selected_strategy, "faithful_baseline");
    rows.push(json!({"id":"invalid_optional_printer_rollback","quality":syntax}));

    let mut config = Config::default();
    config.validation.mode = ValidationMode::StrictRequired;
    let bytes=compile("return function(player) local character=player.Character;local position=nil;if character~=nil then position=character:GetPivot().Position end;return {userId=player.UserId,displayName=player.DisplayName,position=position} end","roblox_snapshot");
    let mut inventory = config.clone();
    inventory.validation.mode = ValidationMode::Off;
    let first = luau_decompiler::decompile(&bytes, &inventory).unwrap();
    let player = first
        .bindings
        .iter()
        .find(|b| b.parameter && b.debug_name.as_deref() == Some("player"))
        .unwrap();
    config
        .typing
        .binding_types
        .insert(format!("p{}:b{}", player.proto, player.id), "Player".into());
    let snapshot = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(
        snapshot.validation.required_passed,
        "proved fresh-record reconstruction must remove temporary prefill types: {:?}",
        snapshot.validation.diagnostics
    );
    assert_eq!(snapshot.validation.syntax, GateStatus::Passed);
    assert_eq!(snapshot.validation.compilation, GateStatus::Passed);
    assert!(snapshot.source.contains("Player") && snapshot.source.contains("Vector3"));
    assert!(!snapshot.source.contains("::"));
    assert_eq!(snapshot.validation.strict_analysis, GateStatus::Passed);
    rows.push(json!({"id":"roblox_snapshot_record_history_strict_rejection","historical_negative_repaired":true,"expected_strict":"passed","source":snapshot.source,"quality":snapshot.validation,"types":snapshot.type_report}));
    let bytes=compile("return function(player) local character=player.Character;local position=nil;if character~=nil then position=character:GetPivot().Position end;return position end","roblox_position");
    let first = luau_decompiler::decompile(&bytes, &inventory).unwrap();
    let player = first
        .bindings
        .iter()
        .find(|b| b.parameter && b.debug_name.as_deref() == Some("player"))
        .unwrap();
    config.typing.binding_types.clear();
    config
        .typing
        .binding_types
        .insert(format!("p{}:b{}", player.proto, player.id), "Player".into());
    let position = luau_decompiler::decompile(&bytes, &config).unwrap();
    assert!(
        position.validation.required_passed,
        "{:?}\n{}",
        position.validation.diagnostics, position.source
    );
    rows.push(json!({"id":"roblox_optional_character_pivot_position","expected_strict":"passed","source":position.source,"quality":position.validation,"types":position.type_report}));

    fs::create_dir_all(root.join("docs/results")).unwrap();
    fs::write(root.join("docs/results/strict-v3.json"),serde_json::to_vec_pretty(&json!({"schema":1,"passed":true,"cases":rows.len(),"required_ids":rows.iter().map(|r|r["id"].clone()).collect::<Vec<_>>(),"results":rows,"behavioral_equivalence":"not established by strict analysis; independent typed VM tests are separate"})).unwrap()).unwrap();
}
