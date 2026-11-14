mod support;

use luau_decompiler::{
    ast::{Expr, Function, Stmt},
    bytecode,
    quality::ValidationMode,
    structure::RecoveredBindingInfo,
    type_ast::TypeExpr,
    types, Config,
};
use std::{fs, path::Path, process::Command};

fn binding(id: usize, name: &str) -> RecoveredBindingInfo {
    RecoveredBindingInfo {
        proto: 0,
        id,
        register: id,
        first_pc: 0,
        last_pc: 1,
        name: name.into(),
        printed_name: name.into(),
        name_hint: name.into(),
        name_role: "local",
        naming_origin: "debug_metadata",
        debug_name: Some(name.into()),
        parameter: false,
        captured: false,
        capture_mode: "none",
    }
}

fn annotations(body: &[Stmt], names: &[&str]) -> luau_decompiler::type_ast::Annotations {
    let module = bytecode::decode(
        include_bytes!("fixtures/arithmetic.O1.D2.bc"),
        &Default::default(),
    )
    .unwrap();
    let bindings: Vec<_> = names
        .iter()
        .enumerate()
        .map(|(id, name)| binding(id, name))
        .collect();
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    config.typing.aliases = false;
    types::reconstruct(body, &module, &bindings, &config)
        .unwrap()
        .0
}

fn local(name: &str, value: Expr) -> Stmt {
    Stmt::Local(vec![name.into()], vec![value])
}

fn string(value: &str) -> Expr {
    Expr::Literal(format!("{value:?}"))
}

fn service(argument: Expr) -> Expr {
    Expr::MethodCall(
        Box::new(Expr::Global("game".into())),
        "GetService".into(),
        vec![argument],
    )
}

#[test]
fn evaluated_class_literals_keep_precision_through_aliases_and_matching_joins() {
    let body = vec![
        local("serviceName", string("TweenService")),
        local("serviceAlias", Expr::name("serviceName")),
        local("service", service(Expr::name("serviceAlias"))),
        local("className", string("Part")),
        local(
            "part",
            Expr::Call(
                Box::new(Expr::Field(
                    Box::new(Expr::Global("Instance".into())),
                    "new".into(),
                )),
                vec![Expr::name("className")],
            ),
        ),
        local("joinedName", string("TweenService")),
        Stmt::If {
            condition: Expr::Global("flag".into()),
            yes: vec![Stmt::Assign(
                vec![Expr::name("joinedName")],
                vec![string("TweenService")],
            )],
            no: vec![],
        },
        local("joinedService", service(Expr::name("joinedName"))),
    ];
    let result = annotations(
        &body,
        &[
            "serviceName",
            "serviceAlias",
            "service",
            "className",
            "part",
            "joinedName",
            "joinedService",
        ],
    );
    assert_eq!(
        result.locals["service"],
        TypeExpr::Named("TweenService".into())
    );
    assert_eq!(result.locals["part"], TypeExpr::Named("Part".into()));
    assert_eq!(
        result.locals["joinedService"],
        TypeExpr::Named("TweenService".into())
    );
    for name in ["serviceName", "serviceAlias", "joinedName"] {
        assert_eq!(
            result.locals[name],
            TypeExpr::SingletonString("TweenService".into())
        );
    }
}

#[test]
fn conflicting_and_reference_captured_class_names_do_not_claim_one_class() {
    let reader = Expr::Function(Box::new(Function {
        origin: Some(0),
        parameters: vec![],
        vararg: false,
        body: vec![Stmt::Return(vec![service(Expr::name("serviceName"))])],
    }));
    for change in [
        Stmt::Assign(vec![Expr::name("serviceName")], vec![string("RunService")]),
        Stmt::If {
            condition: Expr::Global("flag".into()),
            yes: vec![Stmt::Assign(
                vec![Expr::name("serviceName")],
                vec![string("RunService")],
            )],
            no: vec![],
        },
    ] {
        let body = vec![
            local("serviceName", string("TweenService")),
            local("reader", reader.clone()),
            change,
            local("service", service(Expr::name("serviceName"))),
        ];
        let result = annotations(&body, &["serviceName", "reader", "service"]);
        let returns = result.functions[&0].returns.as_ref();
        assert!(
            returns.is_none_or(|pack| !pack.head.contains(&TypeExpr::Named("TweenService".into()))),
            "{result:?}"
        );
        assert_ne!(
            result.locals.get("service"),
            Some(&TypeExpr::Named("TweenService".into()))
        );
    }
}

fn record(value: Expr) -> Expr {
    Expr::Table(vec![(Some(string("count")), value)])
}

fn hinted(id: usize, name: &str, hint: &str) -> RecoveredBindingInfo {
    let mut binding = binding(id, name);
    binding.debug_name = None;
    binding.naming_origin = "dataflow_role";
    binding.name_hint = hint.into();
    binding
}

fn scope_fixture() -> (Vec<Stmt>, Vec<RecoveredBindingInfo>) {
    let function = |parameter: &str, body| {
        Expr::Function(Box::new(Function {
            origin: None,
            parameters: vec![parameter.into()],
            vararg: false,
            body,
        }))
    };
    let body = vec![
        local("state_symbol", Expr::Literal("7".into())),
        local(
            "left_symbol",
            function(
                "left_value_symbol",
                vec![
                    local("nested_state_symbol", Expr::Literal("11".into())),
                    Stmt::Return(vec![Expr::binary(
                        "+",
                        Expr::name("left_value_symbol"),
                        Expr::name("state_symbol"),
                    )]),
                ],
            ),
        ),
        local(
            "right_symbol",
            function(
                "right_value_symbol",
                vec![Stmt::Return(vec![Expr::binary(
                    "+",
                    Expr::name("right_value_symbol"),
                    Expr::Literal("2".into()),
                )])],
            ),
        ),
        Stmt::Return(vec![
            Expr::Call(
                Box::new(Expr::name("left_symbol")),
                vec![Expr::Literal("1".into())],
            ),
            Expr::Call(
                Box::new(Expr::name("right_symbol")),
                vec![Expr::Literal("2".into())],
            ),
            Expr::name("state_symbol"),
        ]),
    ];
    let bindings = [
        ("state_symbol", "state"),
        ("left_symbol", "left"),
        ("left_value_symbol", "value"),
        ("nested_state_symbol", "state"),
        ("right_symbol", "right"),
        ("right_value_symbol", "value"),
    ]
    .into_iter()
    .enumerate()
    .map(|(id, (name, hint))| hinted(id, name, hint))
    .collect();
    (body, bindings)
}

#[test]
fn scope_display_names_reuse_siblings_but_preserve_ancestor_captures() {
    let (body, bindings) = scope_fixture();
    let config = Config::default();
    let display =
        luau_decompiler::presentation::DisplayNames::plan(&body, None, &bindings, &config).unwrap();
    assert_eq!(display.name("left_value_symbol"), "value");
    assert_eq!(display.name("right_value_symbol"), "value");
    assert_eq!(display.name("state_symbol"), "state");
    assert_eq!(display.name("nested_state_symbol"), "state_2");
    let mut fixed = hinted(7, "state", "ignored");
    fixed.naming_origin = "override";
    let body = vec![
        local("outer_symbol", Expr::Literal("1".into())),
        local(
            "callback",
            Expr::Function(Box::new(Function {
                origin: None,
                parameters: vec!["state".into()],
                vararg: false,
                body: vec![Stmt::Return(vec![Expr::name("outer_symbol")])],
            })),
        ),
    ];
    let display = luau_decompiler::presentation::DisplayNames::plan(
        &body,
        None,
        &[hinted(0, "outer_symbol", "state"), fixed],
        &config,
    )
    .unwrap();
    assert_eq!(display.name("state"), "state");
    assert_eq!(display.name("outer_symbol"), "state_2");
}

#[test]
fn scope_display_names_pin_type_dependencies_globals_and_unresolved_symbols() {
    let body = vec![
        local("Signal_internal", Expr::Table(vec![])),
        local("other_symbol", Expr::Global("print".into())),
        local(
            "callback",
            Expr::Function(Box::new(Function {
                origin: None,
                parameters: vec![],
                vararg: false,
                body: vec![Stmt::Return(vec![Expr::name("future_symbol")])],
            })),
        ),
        local("future_symbol", Expr::Literal("1".into())),
    ];
    let annotations = luau_decompiler::type_ast::Annotations {
        locals: std::collections::BTreeMap::from([(
            "other_symbol".into(),
            TypeExpr::Apply("Signal_internal.Signal".into(), vec![TypeExpr::Number]),
        )]),
        ..Default::default()
    };
    let bindings = [
        hinted(0, "Signal_internal", "Signal"),
        hinted(1, "other_symbol", "print"),
        hinted(2, "future_symbol", "future"),
    ];
    let display = luau_decompiler::presentation::DisplayNames::plan(
        &body,
        Some(&annotations),
        &bindings,
        &Config::default(),
    )
    .unwrap();
    assert_eq!(display.name("Signal_internal"), "Signal_internal");
    assert_eq!(display.name("other_symbol"), "print_2");
    assert_eq!(display.name("future_symbol"), "future_symbol");
}

#[test]
fn scope_display_collision_work_remains_linear_for_repeated_hints() {
    let names: Vec<_> = (0..200).map(|index| format!("symbol_{index}")).collect();
    let body: Vec<_> = names
        .iter()
        .map(|name| local(name, Expr::Literal("1".into())))
        .collect();
    let bindings: Vec<_> = names
        .iter()
        .enumerate()
        .map(|(id, name)| hinted(id, name, "value"))
        .collect();
    let mut config = Config::default();
    config.limits.max_analysis_steps = 3000;
    let display =
        luau_decompiler::presentation::DisplayNames::plan(&body, None, &bindings, &config).unwrap();
    assert_eq!(display.name(&names[0]), "value");
    assert_eq!(display.name(&names[199]), "value_200");
}

#[test]
fn scope_debug_hints_follow_configured_case_and_preserve_exact_overrides() {
    use luau_decompiler::{presentation::DisplayNames, NameStyle};
    let body = vec![
        local(
            "function_symbol",
            Expr::Function(Box::new(Function {
                origin: None,
                parameters: vec!["parameter_symbol".into()],
                vararg: false,
                body: vec![Stmt::Return(vec![Expr::name("parameter_symbol")])],
            })),
        ),
        local("local_symbol", Expr::Literal("1".into())),
        local("service_symbol", service(string("TweenService"))),
        local("KeepExactOverride", Expr::Literal("2".into())),
    ];
    let mut bindings: Vec<_> = [
        ("function_symbol", "GetPlayerCount"),
        ("parameter_symbol", "PlayerValue"),
        ("local_symbol", "TotalScore"),
        ("service_symbol", "TweenService"),
        ("KeepExactOverride", "UnusedHint"),
    ]
    .into_iter()
    .enumerate()
    .map(|(id, (symbol, debug))| {
        let mut binding = binding(id, symbol);
        binding.debug_name = Some(debug.into());
        binding
    })
    .collect();
    bindings[3].name_role = "service";
    bindings[4].naming_origin = "override";
    for (style, expected) in [
        (
            NameStyle::SnakeCase,
            [
                "get_player_count",
                "player_value",
                "total_score",
                "tween_service",
            ],
        ),
        (
            NameStyle::CamelCase,
            [
                "getPlayerCount",
                "playerValue",
                "totalScore",
                "tweenService",
            ],
        ),
        (
            NameStyle::PascalCase,
            [
                "GetPlayerCount",
                "PlayerValue",
                "TotalScore",
                "TweenService",
            ],
        ),
        (
            NameStyle::Roblox,
            [
                "getPlayerCount",
                "playerValue",
                "totalScore",
                "TweenService",
            ],
        ),
    ] {
        let config = Config {
            naming: style,
            ..Config::default()
        };
        let names = DisplayNames::plan(&body, None, &bindings, &config).unwrap();
        for (symbol, expected) in [
            "function_symbol",
            "parameter_symbol",
            "local_symbol",
            "service_symbol",
        ]
        .into_iter()
        .zip(expected)
        {
            assert_eq!(names.name(symbol), expected, "{style:?}");
        }
        assert_eq!(names.name("KeepExactOverride"), "KeepExactOverride");
    }
}

#[test]
fn known_local_parameter_mutation_keeps_table_field_types_conservative() {
    let body = vec![
        local(
            "mutate",
            Expr::Function(Box::new(Function {
                origin: Some(0),
                parameters: vec!["input".into()],
                vararg: false,
                body: vec![Stmt::Assign(
                    vec![Expr::Field(Box::new(Expr::name("input")), "count".into())],
                    vec![string("changed")],
                )],
            })),
        ),
        local("state", record(Expr::Literal("1".into()))),
        Stmt::Call(Expr::Call(
            Box::new(Expr::name("mutate")),
            vec![Expr::name("state")],
        )),
        local(
            "result",
            Expr::Field(Box::new(Expr::name("state")), "count".into()),
        ),
    ];
    let result = annotations(&body, &["mutate", "input", "state", "result"]);
    assert!(!result.locals.contains_key("result"));
    assert!(!result.locals.contains_key("state"));
}

#[test]
fn table_declaration_history_keeps_loop_widening_after_later_rebinding() {
    let body = vec![
        local("scalar", Expr::Literal("1".into())),
        local("state", record(Expr::Literal("0".into()))),
        Stmt::NumericFor {
            variable: "index".into(),
            start: Expr::Literal("1".into()),
            limit: Expr::Literal("3".into()),
            step: Expr::Literal("1".into()),
            body: vec![
                Stmt::Assign(
                    vec![Expr::name("state")],
                    vec![record(Expr::name("scalar"))],
                ),
                Stmt::Assign(vec![Expr::name("scalar")], vec![string("changed")]),
            ],
        },
        Stmt::Assign(
            vec![Expr::name("state")],
            vec![record(Expr::Literal("1".into()))],
        ),
        Stmt::Return(vec![Expr::Field(
            Box::new(Expr::name("state")),
            "count".into(),
        )]),
    ];
    let result = annotations(&body, &["scalar", "state", "index"]);
    assert!(!result.locals.contains_key("state"), "{:?}", result.locals);
}

#[test]
#[ignore = "requires pinned parser/compiler, strict analyzer and typed behavioral oracle"]
fn scope_display_output_passes_strict_analysis_and_preserves_captures() {
    use luau_decompiler::type_ast::{Annotations, FunctionAnnotation, TypePack};
    let (body, bindings) = scope_fixture();
    let function = FunctionAnnotation {
        parameters: vec![Some(TypeExpr::Number)],
        returns: Some(TypePack {
            head: vec![TypeExpr::Number],
            tail: None,
        }),
        ..Default::default()
    };
    let annotations = Annotations {
        locals: std::collections::BTreeMap::from([
            ("state_symbol".into(), TypeExpr::Number),
            ("nested_state_symbol".into(), TypeExpr::Number),
        ]),
        functions: std::collections::BTreeMap::from([(0, function.clone()), (1, function)]),
        strict: true,
        ..Default::default()
    };
    let mut config = Config::default();
    config.validation.mode = ValidationMode::StrictRequired;
    let (mut source, regions) =
        luau_decompiler::format::format_typed(&body, &config, &annotations, 0, &bindings).unwrap();
    assert!(
        source.contains("local function left(value: number)"),
        "{source}"
    );
    assert!(
        source.contains("local function right(value: number)"),
        "{source}"
    );
    assert!(source.contains("local state_2: number = 11"), "{source}");
    assert!(source.contains("return value + state"), "{source}");
    assert_eq!(
        regions
            .iter()
            .filter(|region| region.printed_name.as_deref() == Some("value")
                && region.binding.is_some())
            .count(),
        4
    );
    let finalized = source.clone();
    let quality = luau_decompiler::quality::validate_source(
        &mut source,
        &mut None,
        &mut types::TypeReport::default(),
        &config,
    )
    .unwrap();
    assert!(
        quality.required_passed,
        "{:?}\n{source}",
        quality.diagnostics
    );
    assert_eq!(source, finalized);
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let destination = root.join("artifacts/rc5-types/scope-display");
    fs::create_dir_all(&destination).unwrap();
    let original = destination.join("original.luau");
    fs::write(&original,"local state=7 local function left(value) local nestedState=11 return value+state end local function right(value) return value+2 end return left(1),right(2),state").unwrap();
    let recovered = destination.join("recovered.luau");
    fs::write(&recovered, &source).unwrap();
    let expected = tools
        .observe(
            &tools.compile(&original, 0, 2).unwrap(),
            &destination,
            "original",
            &[],
        )
        .unwrap();
    let actual = tools
        .observe(
            &tools.compile(&recovered, 0, 2).unwrap(),
            &destination,
            "rebuilt",
            &[],
        )
        .unwrap();
    assert!(expected.verified() && actual.verified() && expected.equivalent(&actual));
}

#[test]
fn captured_table_rebinding_retains_both_declaration_shapes_and_return_types() {
    let body = vec![
        local("state", record(Expr::Literal("1".into()))),
        local(
            "read",
            Expr::Function(Box::new(Function {
                origin: Some(0),
                parameters: vec![],
                vararg: false,
                body: vec![Stmt::Return(vec![Expr::Field(
                    Box::new(Expr::name("state")),
                    "count".into(),
                )])],
            })),
        ),
        Stmt::Assign(vec![Expr::name("state")], vec![record(string("changed"))]),
        Stmt::Return(vec![Expr::Call(Box::new(Expr::name("read")), vec![])]),
    ];
    let result = annotations(&body, &["state", "read"]);
    let state = result.locals["state"].luau();
    assert!(
        state.contains("number") && state.contains("string"),
        "{state}"
    );
    let returned = result.functions[&0].returns.as_ref().unwrap().head[0].luau();
    assert!(
        returned.contains("number") && returned.contains("string"),
        "{returned}"
    );
}

#[test]
fn unused_callback_parameters_expose_unknown_without_a_meaningless_generic() {
    let body = vec![local(
        "callback",
        Expr::Function(Box::new(Function {
            origin: Some(0),
            parameters: vec!["eventValue".into()],
            vararg: false,
            body: vec![Stmt::Return(vec![])],
        })),
    )];
    let result = annotations(&body, &["callback", "eventValue"]);
    let callback = &result.functions[&0];
    assert!(callback.generics.is_empty());
    assert_eq!(callback.parameters, vec![Some(TypeExpr::Unknown)]);
    assert!(callback.returns.as_ref().unwrap().head.is_empty());
}

#[test]
fn known_closures_do_not_hide_opaque_mutation_of_captured_tables() {
    let body = vec![
        local("state", record(Expr::Literal("1".into()))),
        local(
            "read",
            Expr::Function(Box::new(Function {
                origin: Some(0),
                parameters: vec![],
                vararg: false,
                body: vec![Stmt::Return(vec![Expr::Field(
                    Box::new(Expr::name("state")),
                    "count".into(),
                )])],
            })),
        ),
        Stmt::Call(Expr::Call(
            Box::new(Expr::Global("mutate".into())),
            vec![Expr::name("state")],
        )),
        local("result", Expr::Call(Box::new(Expr::name("read")), vec![])),
    ];
    let result = annotations(&body, &["state", "read", "result"]);
    assert!(!result.locals.contains_key("result"));
    assert!(result.functions[&0].returns.is_none());
}

#[test]
#[ignore = "requires pinned parser/compiler and strict analyzer"]
fn retained_class_aliases_pass_actual_strict_analysis_without_casts() {
    let module = bytecode::decode(
        include_bytes!("fixtures/arithmetic.O1.D2.bc"),
        &Default::default(),
    )
    .unwrap();
    let body = vec![
        local("serviceName", string("TweenService")),
        local("serviceAlias", Expr::name("serviceName")),
        Stmt::Call(Expr::Call(
            Box::new(Expr::Global("print".into())),
            vec![Expr::name("serviceAlias")],
        )),
        local("service", service(Expr::name("serviceAlias"))),
        local("className", string("Part")),
        Stmt::Call(Expr::Call(
            Box::new(Expr::Global("print".into())),
            vec![Expr::name("className")],
        )),
        local(
            "part",
            Expr::Call(
                Box::new(Expr::Field(
                    Box::new(Expr::Global("Instance".into())),
                    "new".into(),
                )),
                vec![Expr::name("className")],
            ),
        ),
        Stmt::Return(vec![Expr::name("service"), Expr::name("part")]),
    ];
    let names = [
        "serviceName",
        "serviceAlias",
        "service",
        "className",
        "part",
    ];
    let bindings: Vec<_> = names
        .iter()
        .enumerate()
        .map(|(id, name)| binding(id, name))
        .collect();
    let mut config = Config {
        naming: luau_decompiler::NameStyle::CamelCase,
        ..Config::default()
    };
    config.typing.aliases = false;
    config.validation.mode = ValidationMode::StrictRequired;
    let (annotations, mut report) = types::reconstruct(&body, &module, &bindings, &config).unwrap();
    let mut source =
        luau_decompiler::format::format_typed(&body, &config, &annotations, 0, &bindings)
            .unwrap()
            .0;
    assert!(source.contains("game:GetService(serviceAlias)"), "{source}");
    assert!(source.contains("Instance.new(className)"), "{source}");
    assert!(!source.contains("::"));
    let finalized = source.clone();
    let quality =
        luau_decompiler::quality::validate_source(&mut source, &mut None, &mut report, &config)
            .unwrap();
    assert!(
        quality.required_passed,
        "{:?}\n{source}",
        quality.diagnostics
    );
    assert_eq!(source, finalized);
    assert_eq!(quality.inferred_any, 0);
    assert_eq!(quality.inferred_unknown, 0);
}

#[test]
#[ignore = "requires pinned compilers, strict analyzer and typed behavioral oracle"]
fn captured_table_rebinding_compiles_strictly_and_preserves_repeated_reads() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/rc5-types/table-rebinding");
    fs::create_dir_all(&destination).unwrap();
    let source = destination.join("original.luau");
    fs::write(&source,"local state={count=1} local function read() return state.count end local before=read() state={count='changed'} return before,read(),nil").unwrap();
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for optimization in [0, 2] {
            let directory = destination.join(format!("v{version}-O{optimization}"));
            fs::create_dir_all(&directory).unwrap();
            let original = tools.compile(&source, optimization, 2).unwrap();
            let mut config = Config::default();
            config.validation.mode = ValidationMode::Off;
            let result = luau_decompiler::decompile(&original, &config).unwrap();
            let recovered = directory.join("recovered.luau");
            fs::write(&recovered, &result.source).unwrap();
            let analysis = Command::new(root.join(".tools/luau-modern/luau-analyze.exe"))
                .arg(&recovered)
                .output()
                .unwrap();
            assert!(
                analysis.status.success(),
                "v{version}/O{optimization}: {}\n{}",
                String::from_utf8_lossy(&analysis.stderr),
                result.source
            );
            let rebuilt = tools.compile(&recovered, optimization, 2).unwrap();
            let expected = tools
                .observe(&original, &directory, "original", &[])
                .unwrap();
            let actual = tools.observe(&rebuilt, &directory, "rebuilt", &[]).unwrap();
            assert!(expected.verified() && actual.verified() && expected.equivalent(&actual));
        }
    }
}

#[test]
#[ignore = "requires pinned compiler, strict analyzer and typed behavioral oracle"]
fn reused_prototypes_report_printed_names_by_expanded_symbol() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/rc5-types/reused-prototype");
    fs::create_dir_all(&directory).unwrap();
    let tools = support::Toolset::checked(root, 14);
    let original_path = directory.join("original.luau");
    fs::write(&original_path,"local function make(value:number) return function(extra:number):number return value+extra end end local function first(extra:number,value:number) local callback=make(value) return callback,extra end local function second(other:number,value:number) local callback=make(value) return callback,other end return first,second").unwrap();
    let compiled = Command::new(&tools.compiler)
        .args(["--binary", "-O2", "-g2", "-t1"])
        .arg(format!("--fflags={}", tools.flags))
        .arg(&original_path)
        .output()
        .unwrap();
    assert!(compiled.status.success() && compiled.stdout.first().is_some_and(|byte| *byte != 0));
    let original = compiled.stdout;
    let mut config = Config::default();
    config.validation.mode = ValidationMode::StrictRequired;
    let result = luau_decompiler::decompile(&original, &config).unwrap();
    assert!(
        result.validation.required_passed,
        "{:?}\n{}",
        result.validation.diagnostics, result.source
    );
    let mut expanded = std::collections::BTreeMap::<_, Vec<_>>::new();
    for binding in &result.bindings {
        expanded
            .entry((binding.proto, binding.id))
            .or_default()
            .push(binding);
    }
    assert!(
        expanded.values().any(|bindings| {
            bindings
                .iter()
                .map(|binding| &binding.printed_name)
                .collect::<std::collections::BTreeSet<_>>()
                .len()
                > 1
        }),
        "{}",
        result.source
    );
    let mut checked = 0;
    for bindings in expanded.values().filter(|bindings| bindings.len() > 1) {
        for binding in bindings {
            let regions: Vec<_> = result
                .source_map
                .iter()
                .filter(|region| {
                    region.symbol.as_deref() == Some(binding.name.as_str())
                        && region.printed_name.is_some()
                })
                .collect();
            if regions.is_empty() {
                continue;
            }
            checked += 1;
            assert!(
                regions
                    .iter()
                    .all(|region| region.printed_name.as_deref()
                        == Some(binding.printed_name.as_str())),
                "{}: {:?}",
                binding.name,
                regions
            );
        }
    }
    assert!(checked >= 2);
    let recovered_path = directory.join("recovered.luau");
    fs::write(&recovered_path, &result.source).unwrap();
    let rebuilt = tools.compile(&recovered_path, 2, 2).unwrap();
    let probe_path = directory.join("probe.luau");
    fs::write(&probe_path,"local first,second=... local a,x=first(9,10) local b,y=second(19,20) return a(1),b(2),x,y,a==b,select('#',a(3),nil)").unwrap();
    let probe = directory.join("probe.bc");
    fs::write(&probe, tools.compile(&probe_path, 0, 0).unwrap()).unwrap();
    let expected = tools
        .observe_with_probe(&original, &directory, "original", &[], Some(&probe))
        .unwrap();
    let actual = tools
        .observe_with_probe(&rebuilt, &directory, "rebuilt", &[], Some(&probe))
        .unwrap();
    assert!(
        expected.verified() && actual.verified() && expected.equivalent(&actual),
        "{expected:?}\n{actual:?}"
    );
}
