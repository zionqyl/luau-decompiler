use luau_decompiler::{
    bytecode,
    cfg::Cfg,
    dataflow::{Definition, Ssa},
    Limits,
};

#[test]
fn debug_pc_intervals_expose_register_reuse() {
    let module = bytecode::decode(
        include_bytes!("fixtures/close_scopes.O0.D2.bc"),
        &Limits::default(),
    )
    .unwrap();
    let proto = &module.protos[module.main];
    let mut reused = false;
    for (index, local) in proto.locals.iter().enumerate() {
        assert!(local.start_pc <= local.end_pc);
        for other in &proto.locals[index + 1..] {
            if local.register == other.register
                && local.name != other.name
                && (local.end_pc <= other.start_pc || other.end_pc <= local.start_pc)
            {
                reused = true;
            }
        }
    }
    assert!(
        reused,
        "fixture must retain distinct debug scopes on a reused register"
    );
}

#[test]
fn joining_assignments_have_explicit_ssa_evidence() {
    let limits = Limits::default();
    let module = bytecode::decode(include_bytes!("fixtures/branches.O0.D2.bc"), &limits).unwrap();
    let mut joins = 0;
    for proto in &module.protos {
        let cfg = Cfg::build(proto, &limits).unwrap();
        let ssa = Ssa::analyze(proto, &cfg, &limits).unwrap();
        for definition in &ssa.definitions {
            if let Definition::Phi { incoming, .. } = definition {
                if incoming
                    .iter()
                    .map(|(_, value)| value)
                    .collect::<std::collections::BTreeSet<_>>()
                    .len()
                    > 1
                {
                    joins += 1;
                }
            }
        }
    }
    assert!(
        joins > 0,
        "binding recovery must consume joins rather than split their assignments"
    );
}

#[test]
fn recovered_binding_identity_splits_reuse_and_accepts_precise_override() {
    let bytes = include_bytes!("fixtures/binding_scopes_v2.O0.D2.bc");
    let result = luau_decompiler::decompile(bytes, &luau_decompiler::Config::default()).unwrap();
    let second = result
        .bindings
        .iter()
        .find(|b| b.debug_name.as_deref() == Some("second"))
        .unwrap();
    let third = result
        .bindings
        .iter()
        .find(|b| b.debug_name.as_deref() == Some("third"))
        .unwrap();
    assert_eq!(
        second.register, third.register,
        "fixture must reuse the storage location"
    );
    assert_ne!(
        second.id, third.id,
        "unrelated locals must recover separate binding identities"
    );
    assert!(
        result.source.contains("local second ="),
        "{}",
        result.source
    );
    assert!(result.source.contains("local third ="), "{}", result.source);
    assert!(
        !result.source.starts_with("local seed, first"),
        "declarations should be near definitions"
    );
    let mut config = luau_decompiler::Config::default();
    config.name_overrides.insert(
        format!("p{}:b{}", third.proto, third.id),
        "chosenThird".into(),
    );
    let overridden = luau_decompiler::decompile(bytes, &config).unwrap();
    assert!(overridden.source.contains("local chosenThird ="));
    assert!(overridden.source.contains("local second ="));
    let original_ids: Vec<_> = result
        .bindings
        .iter()
        .map(|b| (b.proto, b.id, b.register, b.first_pc, b.last_pc))
        .collect();
    config.naming = luau_decompiler::NameStyle::PascalCase;
    let pascal = luau_decompiler::decompile(bytes, &config).unwrap();
    assert_eq!(
        original_ids,
        pascal
            .bindings
            .iter()
            .map(|b| (b.proto, b.id, b.register, b.first_pc, b.last_pc))
            .collect::<Vec<_>>()
    );
}

#[test]
fn difficult_compiler_cfg_has_explicit_complete_fallback_quality() {
    let bytes = include_bytes!("fixtures/complex_loop_exits_v2.O2.D2.bc");
    let config = luau_decompiler::Config::default();
    let result = luau_decompiler::decompile(bytes, &config).unwrap();
    assert!(!result.fallback_prototypes.is_empty());
    assert!(result.source.contains("control_state"));
    let mut structured = config;
    structured.control_flow = luau_decompiler::ControlFlowMode::Structured;
    assert!(luau_decompiler::decompile(bytes, &structured)
        .unwrap_err()
        .message
        .contains("structured-region"));
}
