use luau_decompiler::structure::RecoveredBindingInfo;
use luau_decompiler::type_ast::{parse_type, PackTail, TypeExpr, TypePack};
use luau_decompiler::{
    ast::{Expr, Function, Stmt},
    bytecode::{self, MetadataType},
    format, types, Config,
};

fn module() -> bytecode::Module {
    bytecode::decode(
        include_bytes!("fixtures/arithmetic.O1.D2.bc"),
        &Default::default(),
    )
    .unwrap()
}
fn binding(id: usize, name: &str, parameter: bool) -> RecoveredBindingInfo {
    RecoveredBindingInfo {
        proto: 0,
        id,
        register: if parameter { 0 } else { id },
        first_pc: 0,
        last_pc: 1,
        name: name.into(),
        debug_name: Some(name.into()),
        parameter,
        captured: false,
        capture_mode: "none",
    }
}
fn config() -> Config {
    let mut c = Config::default();
    c.validation.mode = luau_decompiler::quality::ValidationMode::Off;
    c
}
fn function(parameters: &[&str], vararg: bool, body: Vec<Stmt>) -> Expr {
    Expr::Function(Box::new(Function {
        origin: Some(0),
        parameters: parameters.iter().map(|s| s.to_string()).collect(),
        vararg,
        body,
    }))
}
fn typed(
    body: &[Stmt],
    module: &bytecode::Module,
    bindings: &[RecoveredBindingInfo],
    config: &Config,
) -> (String, types::TypeReport) {
    let (a, r) = types::reconstruct(body, module, bindings, config).unwrap();
    let (s, _) = format::format_typed(body, config, &a, module.main, bindings).unwrap();
    (s, r)
}

#[test]
fn full_type_syntax_is_structural_bounded_and_cannot_inject_code() {
    for source in [
        "number? | string",
        "{count: number, callback: (number, string?) -> (boolean, nil)}",
        "{[string]: {number}}",
        "((number) -> string) & ((string) -> number)",
        "<T, R...>(T, R...) -> (T, R...)",
        "{player: Player, positions: {Vector3}}",
        "RBXScriptSignal<>",
    ] {
        let ty = parse_type(source).unwrap();
        assert!(!ty.luau().is_empty());
        assert!(parse_type(&ty.luau()).is_ok(), "{}", ty.luau());
    }
    for source in [
        "number; error()",
        "number :: any",
        "number\nreturn 1",
        "{x:}",
        "function()end",
        "end",
    ] {
        assert!(parse_type(source).is_err(), "{source}");
    }
    assert!(parse_type(&format!("{}number{}", "{".repeat(100), "}".repeat(100))).is_err());
}
#[test]
fn identity_generics_preserve_an_interface_instead_of_sample_specialization() {
    let body = vec![
        Stmt::Local(
            vec!["identity".into()],
            vec![function(
                &["value"],
                false,
                vec![Stmt::Return(vec![Expr::name("value")])],
            )],
        ),
        Stmt::Local(
            vec!["numberResult".into()],
            vec![Expr::Call(
                Box::new(Expr::name("identity")),
                vec![Expr::Literal("1".into())],
            )],
        ),
        Stmt::Local(
            vec!["stringResult".into()],
            vec![Expr::Call(
                Box::new(Expr::name("identity")),
                vec![Expr::Literal("\"binary\"".into())],
            )],
        ),
        Stmt::Return(vec![Expr::name("identity")]),
    ];
    let bindings = vec![
        binding(0, "value", true),
        binding(1, "identity", false),
        binding(2, "numberResult", false),
        binding(3, "stringResult", false),
    ];
    let (source, report) = typed(&body, &module(), &bindings, &config());
    assert!(
        source.contains("function identity<T1>(value: T1): T1"),
        "{source}"
    );
    assert!(source.contains("numberResult: number"), "{source}");
    assert!(source.contains("stringResult: string"), "{source}");
    assert!(!source.contains("::"));
    assert_eq!(report.inferred_any, 0);
}
#[test]
fn arithmetic_does_not_guess_number_parameters_with_possible_metamethods() {
    let body = vec![Stmt::Return(vec![function(
        &["value"],
        false,
        vec![Stmt::Return(vec![Expr::binary(
            "+",
            Expr::name("value"),
            Expr::Literal("1".into()),
        )])],
    )])];
    let (source, report) = typed(&body, &module(), &[binding(0, "value", true)], &config());
    assert!(!source.contains("value: number"), "{source}");
    assert!(report.unknown_bindings > 0);
}
#[test]
fn metadata_parameter_tags_and_pc_intervals_are_preserved_without_tainting_reuse() {
    let mut module = module();
    module.protos[0].type_metadata.parameters = vec![MetadataType {
        tag: 2,
        source_offset: 123,
    }];
    let body = vec![Stmt::Return(vec![function(
        &["numberValue"],
        false,
        vec![
            Stmt::Local(
                vec!["laterString".into()],
                vec![Expr::Literal("\"value\"".into())],
            ),
            Stmt::Return(vec![Expr::name("numberValue"), Expr::name("laterString")]),
        ],
    )])];
    let mut later = binding(1, "laterString", false);
    later.register = 0;
    later.first_pc = 7;
    later.last_pc = 8;
    let (source, report) = typed(
        &body,
        &module,
        &[binding(0, "numberValue", true), later],
        &config(),
    );
    assert!(source.contains("numberValue: number"), "{source}");
    assert!(source.contains("laterString: string"), "{source}");
    assert!(report
        .preserved_metadata
        .iter()
        .any(|m| m.source_offset == 123 && m.tag == 2));
}
#[test]
fn assignment_joins_preserve_nil_and_alias_mutations() {
    let body = vec![
        Stmt::Local(vec!["value".into()], vec![Expr::Literal("nil".into())]),
        Stmt::Assign(vec![Expr::name("value")], vec![Expr::Literal("2".into())]),
        Stmt::Local(
            vec!["object".into()],
            vec![Expr::Table(vec![(
                Some(Expr::Literal("\"field\"".into())),
                Expr::Literal("1".into()),
            )])],
        ),
        Stmt::Local(vec!["alias".into()], vec![Expr::name("object")]),
        Stmt::Assign(
            vec![Expr::Field(Box::new(Expr::name("alias")), "field".into())],
            vec![Expr::Literal("\"changed\"".into())],
        ),
        Stmt::Return(vec![Expr::name("value"), Expr::name("object")]),
    ];
    let (source, _) = typed(
        &body,
        &module(),
        &[
            binding(0, "value", false),
            binding(1, "object", false),
            binding(2, "alias", false),
        ],
        &config(),
    );
    assert!(source.contains("value: number?"), "{source}");
    assert!(source.contains("number | string"), "{source}");
}
#[test]
fn known_roblox_contracts_recover_engine_types_without_name_guesses() {
    let body = vec![Stmt::Return(vec![function(
        &["player"],
        false,
        vec![
            Stmt::Local(
                vec!["character".into()],
                vec![Expr::Field(
                    Box::new(Expr::name("player")),
                    "Character".into(),
                )],
            ),
            Stmt::Local(vec!["position".into()], vec![Expr::Literal("nil".into())]),
            Stmt::If {
                condition: Expr::binary("~=", Expr::name("character"), Expr::Literal("nil".into())),
                yes: vec![Stmt::Assign(
                    vec![Expr::name("position")],
                    vec![Expr::Field(
                        Box::new(Expr::MethodCall(
                            Box::new(Expr::name("character")),
                            "GetPivot".into(),
                            vec![],
                        )),
                        "Position".into(),
                    )],
                )],
                no: vec![],
            },
            Stmt::Return(vec![Expr::Table(vec![
                (
                    Some(Expr::Literal("\"userId\"".into())),
                    Expr::Field(Box::new(Expr::name("player")), "UserId".into()),
                ),
                (
                    Some(Expr::Literal("\"displayName\"".into())),
                    Expr::Field(Box::new(Expr::name("player")), "DisplayName".into()),
                ),
                (
                    Some(Expr::Literal("\"position\"".into())),
                    Expr::name("position"),
                ),
            ])]),
        ],
    )])];
    let bindings = vec![
        binding(0, "player", true),
        binding(1, "character", false),
        binding(2, "position", false),
    ];
    let mut config = config();
    config
        .typing
        .binding_types
        .insert("p0:b0".into(), "Player".into());
    let (source, report) = typed(&body, &module(), &bindings, &config);
    assert!(source.contains("player: Player"), "{source}");
    assert!(source.contains("character: Model?"), "{source}");
    assert!(source.contains("position: Vector3?"), "{source}");
    assert!(report.api_definition_sha256.is_some());
    config.typing.binding_types.clear();
    let (source, _) = typed(&body, &module(), &bindings, &config);
    assert!(
        !source.contains("player: Player"),
        "name alone must not infer Player: {source}"
    );
}
#[test]
fn vararg_packs_and_trailing_nil_are_not_parenthesized_or_cast_to_clear_types() {
    let body = vec![Stmt::Return(vec![function(
        &[],
        true,
        vec![Stmt::Return(vec![
            Expr::Literal("1".into()),
            Expr::Literal("nil".into()),
            Expr::Vararg,
        ])],
    )])];
    let (source, _) = typed(&body, &module(), &[], &config());
    assert!(
        source.contains("function<T...>(...: T...): (number, nil, T...)"),
        "{source}"
    );
    assert!(source.contains("return 1, nil, ..."));
    assert!(!source.contains("::"));
    assert_eq!(
        TypePack {
            head: vec![TypeExpr::Number, TypeExpr::Nil],
            tail: Some(PackTail::Generic("R".into()))
        }
        .luau(),
        "(number, nil, R...)"
    );
}
#[test]
fn reformatting_tables_and_calls_preserves_list_expansion_and_self_scope() {
    let mut config = config();
    config.formatting.line_width = 40;
    let body = vec![
        Stmt::Local(
            vec!["same".into()],
            vec![function(
                &[],
                false,
                vec![Stmt::Return(vec![Expr::Global("same".into())])],
            )],
        ),
        Stmt::Return(vec![Expr::Table(vec![
            (None, Expr::Literal("1".into())),
            (None, Expr::Literal("2".into())),
            (None, Expr::Literal("3".into())),
            (
                None,
                Expr::Call(Box::new(Expr::Global("values".into())), vec![]),
            ),
        ])]),
    ];
    let (source, _) = typed(&body, &module(), &[], &config);
    assert!(source.contains("local same = function"), "{source}");
    assert!(source.contains("values(),\n"), "{source}");
    assert!(!source.contains("(values())"));
}

#[test]
fn protected_table_reservation_keys_keep_general_syntax_and_literal_type_facts() {
    let module = module();
    let config = config();
    let bindings = [binding(0, "tableValue", false)];
    let body = |protected| {
        let literal = Expr::Literal("\"alpha\"".into());
        let key = if protected {
            Expr::Single(Box::new(literal))
        } else {
            literal
        };
        vec![Stmt::Local(
            vec!["tableValue".into()],
            vec![Expr::Table(
                (0..5)
                    .map(|_| (Some(key.clone()), Expr::Literal("nil".into())))
                    .collect(),
            )],
        )]
    };
    let (plain_annotations, _) =
        types::reconstruct(&body(false), &module, &bindings, &config).unwrap();
    let protected_body = body(true);
    let (protected_annotations, _) =
        types::reconstruct(&protected_body, &module, &bindings, &config).unwrap();
    assert_eq!(plain_annotations.locals, protected_annotations.locals);
    assert!(matches!(
        protected_annotations.locals.get("tableValue"),
        Some(TypeExpr::Record(fields)) if fields.get("alpha") == Some(&TypeExpr::Nil)
    ));
    for source in [
        format::format(&protected_body, &config).unwrap(),
        format::format_typed(
            &protected_body,
            &config,
            &protected_annotations,
            module.main,
            &bindings,
        )
        .unwrap()
        .0,
    ] {
        assert_eq!(source.matches("[(\"alpha\")] = nil").count(), 5, "{source}");
        assert!(!source.contains("alpha = nil"), "{source}");
    }
}

#[test]
fn optional_type_budget_failure_retains_faithful_source_and_shared_exhaustion_stops() {
    let input = include_bytes!("fixtures/arithmetic.O1.D2.bc");
    let mut c = config();
    c.typing.max_nodes = 64;
    let result = luau_decompiler::decompile(input, &c).unwrap();
    assert!(result.complete);
    assert!(!result.type_report.optional_failures.is_empty());
    assert!(!result.source.is_empty());
    c.limits.max_analysis_steps = 64;
    assert!(
        luau_decompiler::decompile(input, &c).is_err(),
        "shared reconstruction/work exhaustion cannot be hidden by presentation recovery"
    );
}

#[test]
fn annotation_verbosity_is_effective_and_source_maps_are_deterministic() {
    let body = vec![
        Stmt::Local(vec!["literal".into()], vec![Expr::Literal("3".into())]),
        Stmt::Return(vec![Expr::binary(
            "+",
            Expr::name("literal"),
            Expr::Literal("2".into()),
        )]),
    ];
    let module = module();
    let bindings = [binding(0, "literal", false)];
    let mut config = config();
    let (annotations, _) = types::reconstruct(&body, &module, &bindings, &config).unwrap();
    let (source, map) =
        format::format_typed(&body, &config, &annotations, module.main, &bindings).unwrap();
    assert!(source.contains("literal: number"));
    assert!(map
        .iter()
        .any(|r| r.kind == "expression" && r.first_column > 1));
    assert!(map.iter().any(|r| r.binding.as_deref() == Some("p0:b0")));
    assert!(map.iter().enumerate().all(|(index, r)| r.node_id == index));
    let (_, second) =
        format::format_typed(&body, &config, &annotations, module.main, &bindings).unwrap();
    assert_eq!(
        serde_json::to_value(map).unwrap(),
        serde_json::to_value(second).unwrap()
    );
    config.typing.verbosity = types::AnnotationVerbosity::Useful;
    let (source, report) = typed(&body, &module, &bindings, &config);
    assert!(!source.contains("literal: number"));
    assert_eq!(report.annotated_bindings, 0);
}

#[test]
fn type_metrics_visit_variadic_callbacks_applications_and_nested_types() {
    use luau_decompiler::type_ast::{Annotations, FunctionAnnotation};
    use std::collections::BTreeMap;
    for (contract, expected_any) in [
        ("(...any) -> (...any)", 2),
        ("{callback: (...any) -> (number, ...any)}", 2),
        ("Box<{value: any}>", 1),
        ("((...any) -> number) & ((string) -> (...any))", 2),
        ("{[string]: {any? | number}}", 1),
    ] {
        let ty = parse_type(contract).unwrap_or_else(|e| panic!("{contract}: {e}"));
        assert_eq!(ty.metrics().explicit_any, expected_any, "{contract}");
        assert!(!ty.useful(), "{contract}");
    }
    assert!(!parse_type("(...unknown) -> (...number)").unwrap().useful());
    assert!(parse_type("<T...>(T...) -> (T...)").unwrap().useful());
    let annotations = Annotations {
        functions: BTreeMap::from([(
            0,
            FunctionAnnotation {
                variadic: Some(PackTail::Variadic(Box::new(TypeExpr::Any))),
                returns: Some(TypePack {
                    head: vec![],
                    tail: Some(PackTail::Variadic(Box::new(TypeExpr::Any))),
                }),
                ..FunctionAnnotation::default()
            },
        )]),
        ..Annotations::default()
    };
    assert_eq!(types::annotation_counts(&annotations), (2, 0, 2));
}

#[test]
fn method_generics_include_record_self_but_api_receivers_remain_normalized() {
    let mut config = config();
    config
        .typing
        .globals
        .insert("object".into(), "{method: <Self, T>(Self, T) -> T}".into());
    config
        .typing
        .globals
        .insert("player".into(), "Player".into());
    let body = vec![
        Stmt::Local(
            vec!["result".into()],
            vec![Expr::MethodCall(
                Box::new(Expr::Global("object".into())),
                "method".into(),
                vec![Expr::Literal("7".into())],
            )],
        ),
        Stmt::Local(
            vec!["mouse".into()],
            vec![Expr::MethodCall(
                Box::new(Expr::Global("player".into())),
                "GetMouse".into(),
                vec![],
            )],
        ),
    ];
    let (source, _) = typed(
        &body,
        &module(),
        &[binding(0, "result", false), binding(1, "mouse", false)],
        &config,
    );
    assert!(source.contains("result: number"), "{source}");
    assert!(source.contains("mouse: Mouse"), "{source}");
}

#[test]
fn scalar_calls_clear_return_packs_and_zero_results_adjust_to_nil() {
    for (values_type, scalar, expected) in [
        ("() -> (number, nil)", true, vec![TypeExpr::Number]),
        (
            "() -> (number, nil)",
            false,
            vec![TypeExpr::Number, TypeExpr::Nil],
        ),
        ("() -> ()", true, vec![TypeExpr::Nil]),
        ("() -> ()", false, vec![]),
    ] {
        let mut config = config();
        config
            .typing
            .globals
            .insert("forward".into(), "<T...>(T...) -> (T...)".into());
        config
            .typing
            .globals
            .insert("values".into(), values_type.into());
        let values = Expr::Call(Box::new(Expr::Global("values".into())), vec![]);
        let value = if scalar {
            Expr::Single(Box::new(values))
        } else {
            values
        };
        let body = vec![Stmt::Return(vec![function(
            &[],
            false,
            vec![Stmt::Return(vec![Expr::Call(
                Box::new(Expr::Global("forward".into())),
                vec![value],
            )])],
        )])];
        let (annotations, _) = types::reconstruct(&body, &module(), &[], &config).unwrap();
        assert_eq!(
            annotations.functions[&0]
                .returns
                .as_ref()
                .unwrap_or_else(|| panic!(
                    "{values_type} scalar={scalar}: {:?}",
                    annotations.functions
                ))
                .head,
            expected,
            "{values_type} scalar={scalar}"
        );
    }
}

#[test]
fn reference_captured_scalars_use_mutation_history_and_bound_exhaustion() {
    for (initial, assigned, expected) in [
        (
            "1",
            "\"changed\"",
            TypeExpr::union(TypeExpr::Number, TypeExpr::String),
        ),
        ("nil", "7", TypeExpr::Optional(Box::new(TypeExpr::Number))),
    ] {
        let body = vec![
            Stmt::Local(vec!["value".into()], vec![Expr::Literal(initial.into())]),
            Stmt::Local(
                vec!["callback".into()],
                vec![function(
                    &[],
                    false,
                    vec![Stmt::Return(vec![Expr::name("value")])],
                )],
            ),
            Stmt::Local(vec!["alias".into()], vec![Expr::name("callback")]),
            Stmt::Assign(
                vec![Expr::name("value")],
                vec![Expr::Literal(assigned.into())],
            ),
            Stmt::Local(
                vec!["result".into()],
                vec![Expr::Call(Box::new(Expr::name("alias")), vec![])],
            ),
            Stmt::Return(vec![Expr::name("result")]),
        ];
        let bindings = [
            binding(0, "value", false),
            binding(1, "callback", false),
            binding(2, "alias", false),
            binding(3, "result", false),
        ];
        let (annotations, report) =
            types::reconstruct(&body, &module(), &bindings, &config()).unwrap();
        assert_eq!(
            annotations.functions[&0].returns,
            Some(TypePack {
                head: vec![expected.clone()],
                tail: None,
            }),
            "{initial} -> {assigned}: {:?}",
            annotations.functions
        );
        assert_eq!(annotations.locals.get("result"), Some(&expected));
        assert!(report.iterations < config().typing.max_iterations);
        let mut bounded = config();
        bounded.typing.max_iterations = 1;
        let (annotations, _) = types::reconstruct(&body, &module(), &bindings, &bounded).unwrap();
        assert!(annotations.functions[&0].returns.is_none());
        assert!(!annotations.locals.contains_key("callback"));
        assert!(!annotations.locals.contains_key("alias"));
        assert!(!annotations.locals.contains_key("result"));
    }
}

#[test]
fn unknown_mutation_escapes_transitive_records_collections_cycles_and_captures() {
    for family in ["record", "array", "dictionary", "cycle", "capture"] {
        let child = Expr::Table(vec![(
            Some(Expr::Literal("\"value\"".into())),
            Expr::Literal("1".into()),
        )]);
        let key = match family {
            "array" => None,
            "dictionary" => Some(Expr::Global("key".into())),
            _ => Some(Expr::Literal("\"child\"".into())),
        };
        let mut body = vec![
            Stmt::Local(vec!["child".into()], vec![child]),
            Stmt::Local(
                vec!["root".into()],
                vec![Expr::Table(vec![(key, Expr::name("child"))])],
            ),
            Stmt::Local(vec!["alias".into()], vec![Expr::name("child")]),
        ];
        if family == "cycle" {
            body.push(Stmt::Assign(
                vec![Expr::Field(Box::new(Expr::name("child")), "parent".into())],
                vec![Expr::name("root")],
            ));
        }
        let target = if family == "capture" {
            body.push(Stmt::Local(
                vec!["callback".into()],
                vec![function(
                    &[],
                    false,
                    vec![Stmt::Return(vec![Expr::name("root")])],
                )],
            ));
            Expr::name("callback")
        } else {
            Expr::name("root")
        };
        body.push(Stmt::Call(Expr::Call(
            Box::new(Expr::Global("mutate".into())),
            vec![target],
        )));
        body.push(Stmt::Local(
            vec!["result".into()],
            vec![Expr::Field(Box::new(Expr::name("alias")), "value".into())],
        ));
        let bindings = [
            binding(0, "child", false),
            binding(1, "root", false),
            binding(2, "alias", false),
            binding(3, "callback", false),
            binding(4, "result", false),
        ];
        let (annotations, _) = types::reconstruct(&body, &module(), &bindings, &config()).unwrap();
        for name in ["child", "root", "alias", "result"] {
            assert!(
                !annotations.locals.contains_key(name),
                "stale {family}/{name}: {:?}",
                annotations.locals
            );
        }
    }
}

#[test]
fn dynamic_collection_aliases_and_captured_reads_lose_stale_types_after_mutation() {
    for key in [None, Some(Expr::Global("key".into()))] {
        let body = vec![
            Stmt::Local(
                vec!["child".into()],
                vec![Expr::Table(vec![(
                    Some(Expr::Literal("\"value\"".into())),
                    Expr::Literal("1".into()),
                )])],
            ),
            Stmt::Local(
                vec!["root".into()],
                vec![Expr::Table(vec![(key, Expr::name("child"))])],
            ),
            Stmt::Local(
                vec!["alias".into()],
                vec![Expr::Index(
                    Box::new(Expr::name("root")),
                    Box::new(Expr::Global("key".into())),
                )],
            ),
            Stmt::Local(
                vec!["read".into()],
                vec![function(
                    &[],
                    false,
                    vec![Stmt::Return(vec![Expr::Field(
                        Box::new(Expr::name("alias")),
                        "value".into(),
                    )])],
                )],
            ),
            Stmt::Call(Expr::Call(
                Box::new(Expr::Global("mutate".into())),
                vec![Expr::name("child")],
            )),
        ];
        let bindings = [
            binding(0, "child", false),
            binding(1, "root", false),
            binding(2, "alias", false),
            binding(3, "read", false),
        ];
        let (annotations, _) = types::reconstruct(&body, &module(), &bindings, &config()).unwrap();
        for name in ["child", "root", "alias", "read"] {
            assert!(
                !annotations.locals.contains_key(name),
                "{name}: {:?}",
                annotations.locals
            );
        }
        assert!(
            annotations.functions[&0].returns.is_none(),
            "{:?}",
            annotations.functions
        );
    }
}

#[test]
fn explicit_dynamic_callback_contract_remains_visible_to_quality_accounting() {
    let mut config = config();
    config
        .typing
        .binding_types
        .insert("p0:b0".into(), "(...any) -> (...any)".into());
    let body = [Stmt::Local(
        vec!["callback".into()],
        vec![Expr::Global("external".into())],
    )];
    let (annotations, report) =
        types::reconstruct(&body, &module(), &[binding(0, "callback", false)], &config).unwrap();
    assert!(annotations.locals.contains_key("callback"));
    assert_eq!(report.emitted_explicit_any, 2);
    assert_eq!(report.emitted_useful_annotations, 0);
    assert_eq!(report.inferred_any, 0);
    assert!(report
        .evidence
        .iter()
        .any(|e| matches!(e.origin, types::TypeOrigin::ExternalContract)
            && e.ty.metrics().explicit_any == 2));
}

#[test]
fn returned_records_and_optional_record_aliases_retain_mutation_dependencies() {
    let child = || {
        Expr::Table(vec![(
            Some(Expr::Literal("\"value\"".into())),
            Expr::Literal("1".into()),
        )])
    };
    let body = vec![
        Stmt::Local(
            vec!["make".into()],
            vec![function(
                &[],
                false,
                vec![Stmt::Return(vec![Expr::Table(vec![(
                    Some(Expr::Literal("\"child\"".into())),
                    child(),
                )])])],
            )],
        ),
        Stmt::Local(
            vec!["made".into()],
            vec![Expr::Call(Box::new(Expr::name("make")), vec![])],
        ),
        Stmt::Local(
            vec!["alias".into()],
            vec![Expr::Field(Box::new(Expr::name("made")), "child".into())],
        ),
        Stmt::Local(
            vec!["read".into()],
            vec![function(
                &[],
                false,
                vec![Stmt::Return(vec![Expr::Field(
                    Box::new(Expr::name("alias")),
                    "value".into(),
                )])],
            )],
        ),
        Stmt::Call(Expr::Call(
            Box::new(Expr::Global("mutate".into())),
            vec![Expr::name("made")],
        )),
    ];
    let bindings = [
        binding(0, "make", false),
        binding(1, "made", false),
        binding(2, "alias", false),
        binding(3, "read", false),
    ];
    let (annotations, _) = types::reconstruct(&body, &module(), &bindings, &config()).unwrap();
    for name in ["made", "alias", "read"] {
        assert!(
            !annotations.locals.contains_key(name),
            "{name}: {:?}",
            annotations.locals
        );
    }
    assert!(annotations.functions[&1].returns.is_none());
    let mut config = config();
    config
        .typing
        .binding_types
        .insert("p0:b0".into(), "{child: {value: number}}?".into());
    let body = vec![Stmt::Return(vec![function(
        &["input"],
        false,
        vec![Stmt::If {
            condition: Expr::binary("~=", Expr::name("input"), Expr::Literal("nil".into())),
            yes: vec![
                Stmt::Local(
                    vec!["alias".into()],
                    vec![Expr::Field(Box::new(Expr::name("input")), "child".into())],
                ),
                Stmt::Call(Expr::Call(
                    Box::new(Expr::Global("mutate".into())),
                    vec![Expr::name("input")],
                )),
                Stmt::Return(vec![Expr::Field(
                    Box::new(Expr::name("alias")),
                    "value".into(),
                )]),
            ],
            no: vec![],
        }],
    )])];
    let (annotations, _) = types::reconstruct(
        &body,
        &module(),
        &[binding(0, "input", true), binding(1, "alias", false)],
        &config,
    )
    .unwrap();
    assert!(!annotations.locals.contains_key("alias"));
    assert!(annotations.functions[&0].returns.is_none());
}

#[test]
fn opaque_table_returns_are_not_assumed_to_allocate_distinct_objects() {
    for direct_write in [false, true] {
        let mut config = config();
        config
            .typing
            .globals
            .insert("factory".into(), "() -> {child: {value: number}}".into());
        let mut body = vec![
            Stmt::Local(
                vec!["first".into()],
                vec![Expr::Call(Box::new(Expr::Global("factory".into())), vec![])],
            ),
            Stmt::Local(
                vec!["second".into()],
                vec![Expr::Call(Box::new(Expr::Global("factory".into())), vec![])],
            ),
        ];
        if direct_write {
            body.push(Stmt::Assign(
                vec![Expr::Field(
                    Box::new(Expr::Field(Box::new(Expr::name("first")), "child".into())),
                    "value".into(),
                )],
                vec![Expr::Literal("\"changed\"".into())],
            ));
        } else {
            body.push(Stmt::Call(Expr::Call(
                Box::new(Expr::Global("mutate".into())),
                vec![Expr::name("first")],
            )));
        }
        let (annotations, _) = types::reconstruct(
            &body,
            &module(),
            &[binding(0, "first", false), binding(1, "second", false)],
            &config,
        )
        .unwrap();
        assert!(
            !annotations.locals.contains_key("first"),
            "{:?}",
            annotations.locals
        );
        assert!(
            !annotations.locals.contains_key("second"),
            "{:?}",
            annotations.locals
        );
    }
}

#[test]
fn formatter_keeps_authoritative_function_contracts_and_counts_emitted_slots() {
    use luau_decompiler::type_ast::{Annotations, FunctionAnnotation, FunctionType};
    use std::collections::BTreeMap;
    let body = vec![Stmt::Local(
        vec!["identity".into()],
        vec![function(
            &["value"],
            false,
            vec![Stmt::Return(vec![Expr::name("value")])],
        )],
    )];
    let signature = FunctionAnnotation {
        generics: vec!["T".into()],
        parameters: vec![Some(TypeExpr::Generic("T".into()))],
        returns: Some(TypePack {
            head: vec![TypeExpr::Generic("T".into())],
            tail: None,
        }),
        ..FunctionAnnotation::default()
    };
    let mut annotations = Annotations {
        locals: BTreeMap::from([("identity".into(), parse_type("(number) -> string").unwrap())]),
        functions: BTreeMap::from([(0, signature)]),
        ..Annotations::default()
    };
    let mut config = config();
    let source = format::format_typed(&body, &config, &annotations, module().main, &[])
        .unwrap()
        .0;
    assert!(source.contains("local identity:"), "{source}");
    assert!(!source.contains("local function identity"), "{source}");
    let counts = types::emitted_annotation_counts(&annotations, &body, &config).unwrap();
    assert_eq!(
        (
            counts.annotations,
            counts.runtime_annotations,
            counts.useful_annotations,
            counts.explicit_any
        ),
        (3, 3, 3, 0)
    );
    annotations.locals.insert(
        "identity".into(),
        TypeExpr::Function(Box::new(FunctionType {
            generics: vec!["T".into()],
            parameters: vec![TypeExpr::Generic("T".into())],
            returns: TypePack {
                head: vec![TypeExpr::Generic("T".into())],
                tail: None,
            },
            ..FunctionType::default()
        })),
    );
    let source = format::format_typed(&body, &config, &annotations, module().main, &[])
        .unwrap()
        .0;
    assert!(source.contains("local function identity<T>"), "{source}");
    let counts = types::emitted_annotation_counts(&annotations, &body, &config).unwrap();
    assert_eq!(
        (
            counts.annotations,
            counts.runtime_annotations,
            counts.useful_annotations,
            counts.explicit_any
        ),
        (2, 2, 2, 0)
    );
    config.formatting.local_functions = false;
    let source = format::format_typed(&body, &config, &annotations, module().main, &[])
        .unwrap()
        .0;
    assert!(source.contains("local identity:"), "{source}");
    let counts = types::emitted_annotation_counts(&annotations, &body, &config).unwrap();
    assert_eq!(
        (
            counts.annotations,
            counts.runtime_annotations,
            counts.useful_annotations,
            counts.explicit_any
        ),
        (3, 3, 3, 0)
    );
}

#[test]
fn logical_aliases_preserve_reachable_mutation_dependencies() {
    for alias in [
        Expr::binary(
            "or",
            Expr::binary("and", Expr::Global("flag".into()), Expr::name("child")),
            Expr::Literal("nil".into()),
        ),
        Expr::binary("or", Expr::Literal("nil".into()), Expr::name("child")),
        Expr::IfElse(
            Box::new(Expr::Global("flag".into())),
            Box::new(Expr::name("child")),
            Box::new(Expr::Literal("nil".into())),
        ),
    ] {
        let body = vec![
            Stmt::Local(
                vec!["child".into()],
                vec![Expr::Table(vec![(
                    Some(Expr::Literal("\"value\"".into())),
                    Expr::Literal("1".into()),
                )])],
            ),
            Stmt::Local(vec!["alias".into()], vec![alias]),
            Stmt::Call(Expr::Call(
                Box::new(Expr::Global("mutate".into())),
                vec![Expr::name("alias")],
            )),
            Stmt::Local(
                vec!["result".into()],
                vec![Expr::Field(Box::new(Expr::name("child")), "value".into())],
            ),
        ];
        let (annotations, _) = types::reconstruct(
            &body,
            &module(),
            &[
                binding(0, "child", false),
                binding(1, "alias", false),
                binding(2, "result", false),
            ],
            &config(),
        )
        .unwrap();
        for name in ["child", "alias", "result"] {
            assert!(
                !annotations.locals.contains_key(name),
                "{name}: {:?}",
                annotations.locals
            );
        }
    }
}

#[test]
fn statement_and_loop_joins_preserve_aliases_across_iterations() {
    for later_iteration in [false, true] {
        let assign_alias = Stmt::Assign(vec![Expr::name("alias")], vec![Expr::name("child")]);
        let mutate_alias = Stmt::Call(Expr::Call(
            Box::new(Expr::Global("mutate".into())),
            vec![Expr::name("alias")],
        ));
        for branch in [false, true] {
            let mut body = vec![
                Stmt::Local(
                    vec!["child".into()],
                    vec![Expr::Table(vec![(
                        Some(Expr::Literal("\"value\"".into())),
                        Expr::Literal("1".into()),
                    )])],
                ),
                Stmt::Local(vec!["alias".into()], vec![Expr::Literal("nil".into())]),
            ];
            if branch {
                body.push(Stmt::If {
                    condition: Expr::Global("flag".into()),
                    yes: vec![assign_alias.clone()],
                    no: vec![],
                });
                body.push(mutate_alias.clone());
            } else {
                body.push(Stmt::While {
                    condition: Expr::Global("flag".into()),
                    body: if later_iteration {
                        vec![mutate_alias.clone(), assign_alias.clone()]
                    } else {
                        vec![assign_alias.clone()]
                    },
                });
                if !later_iteration {
                    body.push(mutate_alias.clone());
                }
            }
            body.push(Stmt::Local(
                vec!["result".into()],
                vec![Expr::Field(Box::new(Expr::name("child")), "value".into())],
            ));
            let (annotations, _) = types::reconstruct(
                &body,
                &module(),
                &[
                    binding(0, "child", false),
                    binding(1, "alias", false),
                    binding(2, "result", false),
                ],
                &config(),
            )
            .unwrap();
            assert!(
                !annotations.locals.contains_key("child")
                    && !annotations.locals.contains_key("result"),
                "branch={branch}, later_iteration={later_iteration}: {:?}",
                annotations.locals
            );
        }
    }
}

#[test]
fn opaque_returns_keep_aliases_when_expanded_or_scalarized_into_calls() {
    for (signature, scalar, invalidates) in [
        ("() -> {value: number}", false, true),
        ("() -> {value: number}", true, true),
        ("() -> (number, {value: number}, nil)", false, true),
        ("() -> (number, {value: number}, nil)", true, false),
        ("() -> (...{value: number})", false, true),
    ] {
        let mut config = config();
        config
            .typing
            .globals
            .insert("factory".into(), signature.into());
        let factory = || Expr::Call(Box::new(Expr::Global("factory".into())), vec![]);
        let names = if signature.contains("number,") {
            vec!["ignored".into(), "cached".into()]
        } else {
            vec!["cached".into()]
        };
        let body = vec![
            Stmt::Local(names, vec![factory()]),
            Stmt::Call(Expr::Call(
                Box::new(if invalidates {
                    Expr::Global("mutate".into())
                } else {
                    function(&["value"], false, vec![])
                }),
                vec![if !invalidates {
                    Expr::Single(Box::new(Expr::Call(
                        Box::new(function(
                            &[],
                            false,
                            vec![Stmt::Return(vec![
                                Expr::Literal("1".into()),
                                Expr::Table(vec![(
                                    Some(Expr::Literal("\"value\"".into())),
                                    Expr::Literal("1".into()),
                                )]),
                                Expr::Literal("nil".into()),
                            ])],
                        )),
                        vec![],
                    )))
                } else if scalar {
                    Expr::Single(Box::new(factory()))
                } else {
                    factory()
                }],
            )),
            Stmt::Local(
                vec!["result".into()],
                vec![Expr::Field(Box::new(Expr::name("cached")), "value".into())],
            ),
        ];
        let (annotations, _) = types::reconstruct(
            &body,
            &module(),
            &[
                binding(0, "cached", false),
                binding(1, "ignored", false),
                binding(2, "result", false),
            ],
            &config,
        )
        .unwrap();
        assert_eq!(
            annotations.locals.contains_key("result"),
            !invalidates,
            "{signature}, scalar={scalar}: {:?}",
            annotations.locals
        );
        if invalidates {
            assert!(
                !annotations.locals.contains_key("cached"),
                "{signature}: {:?}",
                annotations.locals
            );
        }
    }
}

#[test]
fn opaque_results_are_invalidated_by_unknown_effects_and_old_opaque_alias_writes() {
    for branch in [false, true] {
        let mut config = config();
        config
            .typing
            .globals
            .insert("factory".into(), "() -> {value: number}".into());
        let factory = || Expr::Call(Box::new(Expr::Global("factory".into())), vec![]);
        let mut body = if branch {
            vec![
                Stmt::Local(vec!["cached".into()], vec![Expr::Literal("nil".into())]),
                Stmt::If {
                    condition: Expr::Global("flag".into()),
                    yes: vec![Stmt::Assign(vec![Expr::name("cached")], vec![factory()])],
                    no: vec![Stmt::Assign(vec![Expr::name("cached")], vec![factory()])],
                },
            ]
        } else {
            vec![Stmt::Local(vec!["cached".into()], vec![factory()])]
        };
        body.push(Stmt::Call(Expr::Call(
            Box::new(Expr::Global("mutate".into())),
            vec![],
        )));
        body.push(Stmt::Local(vec!["newer".into()], vec![factory()]));
        body.push(Stmt::Assign(
            vec![Expr::Field(Box::new(Expr::name("cached")), "value".into())],
            vec![Expr::Literal("\"changed\"".into())],
        ));
        body.push(Stmt::Local(
            vec!["result".into()],
            vec![Expr::Field(Box::new(Expr::name("newer")), "value".into())],
        ));
        let (annotations, _) = types::reconstruct(
            &body,
            &module(),
            &[
                binding(0, "cached", false),
                binding(1, "newer", false),
                binding(2, "result", false),
            ],
            &config,
        )
        .unwrap();
        for name in ["cached", "newer", "result"] {
            assert!(
                !annotations.locals.contains_key(name),
                "{name}, branch={branch}: {:?}",
                annotations.locals
            );
        }
    }
}

#[test]
fn captured_reads_and_parent_records_do_not_keep_pre_mutation_field_types() {
    let make_child = || {
        Expr::Table(vec![(
            Some(Expr::Literal("\"value\"".into())),
            Expr::Literal("1".into()),
        )])
    };
    for captured in [false, true] {
        let mut body = vec![Stmt::Local(vec!["child".into()], vec![make_child()])];
        if captured {
            body.push(Stmt::Local(
                vec!["read".into()],
                vec![function(
                    &[],
                    false,
                    vec![Stmt::Return(vec![Expr::Field(
                        Box::new(Expr::name("child")),
                        "value".into(),
                    )])],
                )],
            ));
        } else {
            body.push(Stmt::Local(
                vec!["parent".into()],
                vec![Expr::Table(vec![(
                    Some(Expr::Literal("\"child\"".into())),
                    Expr::name("child"),
                )])],
            ));
        }
        body.push(Stmt::Assign(
            vec![Expr::Field(Box::new(Expr::name("child")), "value".into())],
            vec![Expr::Literal("\"changed\"".into())],
        ));
        if captured {
            body.push(Stmt::Local(
                vec!["result".into()],
                vec![Expr::Call(Box::new(Expr::name("read")), vec![])],
            ));
        }
        let (annotations, _) = types::reconstruct(
            &body,
            &module(),
            &[
                binding(0, "child", false),
                binding(1, "read", false),
                binding(2, "parent", false),
                binding(3, "result", false),
            ],
            &config(),
        )
        .unwrap();
        if captured {
            assert!(
                !annotations.locals.contains_key("result"),
                "{:?}",
                annotations.locals
            );
            assert!(annotations.functions[&0].returns.is_none());
        } else {
            let parent = annotations.locals.get("parent").unwrap();
            assert!(parent.luau().contains("string"), "{}", parent.luau());
        }
    }
}

#[test]
fn global_record_contracts_keep_shared_mutation_dependencies() {
    let mut config = config();
    config
        .typing
        .globals
        .insert("externalRecord".into(), "{value:number}".into());
    let body = vec![
        Stmt::Local(
            vec!["cached".into()],
            vec![Expr::Global("externalRecord".into())],
        ),
        Stmt::Call(Expr::Call(Box::new(Expr::Global("mutate".into())), vec![])),
        Stmt::Local(
            vec!["result".into()],
            vec![Expr::Field(Box::new(Expr::name("cached")), "value".into())],
        ),
    ];
    let (annotations, _) = types::reconstruct(
        &body,
        &module(),
        &[binding(0, "cached", false), binding(1, "result", false)],
        &config,
    )
    .unwrap();
    assert!(
        !annotations.locals.contains_key("cached"),
        "{:?}",
        annotations.locals
    );
    assert!(
        !annotations.locals.contains_key("result"),
        "{:?}",
        annotations.locals
    );
}

#[test]
fn later_scalar_loop_iterations_invalidate_dependent_binding_facts() {
    let body = vec![
        Stmt::Local(vec!["x".into()], vec![Expr::Literal("1".into())]),
        Stmt::Local(vec!["y".into()], vec![Expr::name("x")]),
        Stmt::NumericFor {
            variable: "index".into(),
            start: Expr::Literal("1".into()),
            limit: Expr::Literal("3".into()),
            step: Expr::Literal("1".into()),
            body: vec![
                Stmt::Assign(vec![Expr::name("y")], vec![Expr::name("x")]),
                Stmt::Assign(
                    vec![Expr::name("x")],
                    vec![Expr::Literal("\"changed\"".into())],
                ),
            ],
        },
        Stmt::Return(vec![Expr::name("y")]),
    ];
    let (annotations, report) = types::reconstruct(
        &body,
        &module(),
        &[
            binding(0, "x", false),
            binding(1, "y", false),
            binding(2, "index", false),
        ],
        &config(),
    )
    .unwrap();
    assert!(
        !annotations.locals.contains_key("y"),
        "{:?}",
        annotations.locals
    );
    assert!(!report.evidence.iter().any(|evidence| evidence.name == "y"));
}
