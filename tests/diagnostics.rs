use luau_decompiler::{decompile, Config};

#[test]
fn overrides_fail_for_absent_or_colliding_bindings() {
    let bytes = include_bytes!("fixtures/arithmetic.O1.D2.bc");
    let mut config = Config::default();
    config
        .name_overrides
        .insert("p999:r0".into(), "value".into());
    assert!(decompile(bytes, &config)
        .unwrap_err()
        .to_string()
        .contains("absent binding"));
    config.name_overrides.clear();
    config.name_overrides.insert("p0:r0".into(), "print".into());
    assert!(decompile(bytes, &config)
        .unwrap_err()
        .to_string()
        .contains("collides"));
    config.name_overrides.clear();
    config.name_overrides.insert("p0:r0".into(), "same".into());
    config.name_overrides.insert("p0:r1".into(), "same".into());
    assert!(decompile(bytes, &config)
        .unwrap_err()
        .to_string()
        .contains("collides"));
    config.name_overrides.clear();
    config
        .name_overrides
        .insert("p00:r0".into(), "value".into());
    assert_eq!(decompile(bytes, &config).unwrap_err().stage, "config");
}

#[test]
fn resource_errors_precede_large_output() {
    let bytes = include_bytes!("fixtures/branches.O1.D2.bc");
    let mut config = Config::default();
    config.limits.max_bytes = 16;
    assert!(decompile(bytes, &config).is_err());
    config.limits.max_bytes = 1_000_000;
    config.limits.max_output_bytes = 8;
    let error = decompile(bytes, &config).unwrap_err();
    assert_eq!(error.stage, "limit");
    assert!(error.message.contains("budget") || error.message.contains("limit"));
}
