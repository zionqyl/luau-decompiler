mod support;
use luau_decompiler::{
    bindings::RecoveredBindings, bytecode, cfg::Cfg, dataflow::Ssa, decompile,
    quality::ValidationMode, types::TypingMode, Config, NameStyle,
};
use std::{fs, path::Path};

#[test]
#[ignore = "requires pinned compiler and typed VM"]
fn button_capture_lifetimes_preserve_event_snapshots_and_factory_state() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let directory = root.join("artifacts/rc5-recovery");
    fs::create_dir_all(&directory).unwrap();
    let fixture = root.join("tests/corpus/button_controller.luau");
    for optimization in [0, 1, 2] {
        for debug in [0, 2] {
            let original = tools.compile(&fixture, optimization, debug).unwrap();
            let mut config = Config::default();
            config.typing.mode = TypingMode::Off;
            config.validation.mode = ValidationMode::Off;
            let result = decompile(&original, &config).unwrap();
            let source = directory.join(format!("button.O{optimization}.D{debug}.luau"));
            fs::write(&source, &result.source).unwrap();
            let rebuilt = tools.compile(&source, optimization, debug).unwrap();
            let expected = tools
                .observe(&original, &directory, "original", &[])
                .unwrap();
            let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
            assert!(expected.verified() && actual.verified());
            assert!(
                expected.equivalent(&actual),
                "O{optimization}D{debug}\n{expected:?}\n{actual:?}\n{}",
                result.source
            );
            if debug == 0 {
                assert!(result.source.contains("is_pressed"), "{}", result.source);
                assert!(result.source.contains("is_enabled"), "{}", result.source);
                assert!(result.source.contains("on_click_end"), "{}", result.source);
                assert!(
                    result.source.contains("on_click_start"),
                    "{}",
                    result.source
                );
            }
            let module = bytecode::decode(&original, &config.limits).unwrap();
            assert!(module.protos.iter().any(|proto| proto
                .code
                .iter()
                .any(|instruction| instruction.op == bytecode::Opcode::Capture
                    && instruction.a() == 1)));
            if optimization == 1 && debug == 0 {
                let proto = module
                    .protos
                    .iter()
                    .find(|proto| proto.num_params == 3)
                    .unwrap();
                let cfg = Cfg::build(proto, &config.limits).unwrap();
                let ssa = Ssa::analyze(proto, &cfg, &config.limits).unwrap();
                let bindings =
                    RecoveredBindings::analyze(proto, &cfg, &ssa, &config.limits).unwrap();
                assert!(bindings
                    .bindings
                    .iter()
                    .any(|captured| captured.reference_cell
                        && bindings
                            .bindings
                            .iter()
                            .any(|earlier| earlier.register == captured.register
                                && !earlier.reference_cell
                                && earlier.last_pc < captured.first_pc)));
                config.naming = NameStyle::Roblox;
                let styled = decompile(&original, &config).unwrap();
                assert!(styled.source.contains("isPressed"));
                assert!(styled.source.contains("isEnabled"));
                assert!(styled.source.contains("onClickEnd, onClickStart"));
                assert!(styled.source.contains(".MouseButton1Down"));
                assert_eq!(styled.source, decompile(&original, &config).unwrap().source);
                let source = directory.join("button.roblox.luau");
                fs::write(&source, &styled.source).unwrap();
                let rebuilt = tools.compile(&source, 1, 0).unwrap();
                let actual = tools.observe(&rebuilt, &directory, "roblox", &[]).unwrap();
                assert!(expected.equivalent(&actual));
            }
        }
    }
}

#[test]
#[ignore = "requires pinned compiler and typed VM"]
fn closing_cells_and_fresh_closure_identity_remain_distinct() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let directory = root.join("artifacts/rc5-recovery-neighbors");
    fs::create_dir_all(&directory).unwrap();
    for fixture in ["close_scopes", "closure_identity"] {
        for optimization in [0, 2] {
            let original = tools
                .compile(
                    &root.join(format!("tests/corpus/{fixture}.luau")),
                    optimization,
                    0,
                )
                .unwrap();
            let mut config = Config::default();
            config.typing.mode = TypingMode::Off;
            config.validation.mode = ValidationMode::Off;
            let result = decompile(&original, &config).unwrap();
            let source = directory.join(format!("{fixture}.O{optimization}.luau"));
            fs::write(&source, &result.source).unwrap();
            let rebuilt = tools.compile(&source, optimization, 0).unwrap();
            let expected = tools
                .observe(&original, &directory, "original", &[])
                .unwrap();
            let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
            assert!(expected.verified() && actual.verified());
            assert!(
                expected.equivalent(&actual),
                "{fixture} O{optimization}\n{expected:?}\n{actual:?}\n{}",
                result.source
            );
        }
    }
}

#[test]
#[ignore = "requires pinned compiler and typed VM"]
fn property_snapshots_precede_mutable_callee_resolution() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let directory = root.join("artifacts/rc5-recovery-callee");
    fs::create_dir_all(&directory).unwrap();
    let cases = [
        ("captured", "local selected = function(value) return 'old', value end\nlocal object = setmetatable({}, { __index = function() selected = function(value) return 'new', value end return 7 end })\nlocal value = object.Value\nreturn selected(value)\n"),
        ("global", "selectedGlobal = function(value) return 'old', value end\nlocal object = setmetatable({}, { __index = function() selectedGlobal = function(value) return 'new', value end return 7 end })\nlocal value = object.Value\nreturn selectedGlobal(value)\n"),
        ("method", "local target = { method = function(self, value) return 'old', value end }\nlocal object = setmetatable({}, { __index = function() target.method = function(self, value) return 'new', value end return 7 end })\nlocal value = object.Value\nreturn target:method(value)\n"),
    ];
    for (name, program) in cases {
        let fixture = directory.join(format!("{name}.luau"));
        fs::write(&fixture, program).unwrap();
        for optimization in [0, 2] {
            let original = tools.compile(&fixture, optimization, 0).unwrap();
            let mut config = Config::default();
            config.typing.mode = TypingMode::Off;
            config.validation.mode = ValidationMode::Off;
            let result = decompile(&original, &config).unwrap();
            let source = directory.join(format!("{name}.rebuilt.O{optimization}.luau"));
            fs::write(&source, &result.source).unwrap();
            let rebuilt = tools.compile(&source, optimization, 0).unwrap();
            let expected = tools
                .observe(&original, &directory, "original", &[])
                .unwrap();
            let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
            assert!(
                expected.verified() && actual.verified() && expected.equivalent(&actual),
                "{expected:?}\n{actual:?}\n{}",
                result.source
            );
        }
    }
}
