use luau_decompiler::execution::{CancellationToken, ExecutionContext, MemoryBudget};
use luau_decompiler::input::{detect, InputFormat};
use luau_decompiler::processing::{process, Processor};
use luau_decompiler::quality::{GateStatus, ValidationMode};
use luau_decompiler::{Config, OutputPolicy};
use sha2::{Digest, Sha256};
use std::time::{Duration, Instant};

fn config() -> Config {
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    config
}

#[test]
fn detection_uses_content_and_preserves_binary_packets() {
    let bytecode = include_bytes!("fixtures/arithmetic.O1.D2.bc");
    assert_eq!(
        detect(bytecode, InputFormat::Auto).unwrap().format,
        InputFormat::LuauBytecode
    );
    assert_eq!(
        detect(b"return 'hello'", InputFormat::Auto).unwrap().format,
        InputFormat::LuauSource
    );
    for source in [
        b"\nreturn 1".as_slice(),
        b"\tlocal value=1 return value".as_slice(),
        b"\r\nreturn 1".as_slice(),
    ] {
        assert_eq!(
            detect(source, InputFormat::Auto).unwrap().format,
            InputFormat::LuauSource
        );
        assert!(process(source, InputFormat::Auto, &config()).is_ok());
    }
    assert!(process(b"", InputFormat::LuauSource, &config()).is_ok());
    assert!(process(b" \n\t", InputFormat::LuauSource, &config()).is_ok());
    let bom = process(
        b"\xef\xbb\xbflocal name=1 return name",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert_eq!(bom.source_bindings[0].declaration_start, 9);
    assert!(detect(bytecode, InputFormat::LuauSource).is_err());
    assert!(detect(b"return 3", InputFormat::LuauBytecode).is_err());
    assert_eq!(
        process(bytecode, InputFormat::Auto, &config())
            .unwrap()
            .stats
            .input_bytes,
        bytecode.len()
    );
    for (bytes, name) in [
        (b"\x1bLua\x51\0\0".as_slice(), "standard Lua"),
        (b"\x1bLJ\x02\0".as_slice(), "LuaJIT"),
    ] {
        for format in [
            InputFormat::Auto,
            InputFormat::LuauBytecode,
            InputFormat::LuauSource,
            InputFormat::LuaSource,
        ] {
            let error = detect(bytes, format).unwrap_err();
            assert_eq!(error.stage, "input_format");
            assert!(error.message.contains(name));
        }
    }
    for bytes in [
        b"\xff\xfea\0".as_slice(),
        b"return '\xff'".as_slice(),
        b"\0broken".as_slice(),
        b"  \n".as_slice(),
    ] {
        assert!(detect(bytes, InputFormat::Auto).is_err());
    }
}

#[test]
fn source_path_retains_names_types_parentheses_and_exact_literal_bytes() {
    let source = b"--!strict\nlocal OriginalName: string = '\\000\\255--literal'\nlocal answer = 42\nlocal function values(): (number, nil) return 1, nil end\nreturn OriginalName, answer, (values())";
    let output = process(source, InputFormat::LuauSource, &config()).unwrap();
    assert_eq!(output.profile, "luau-source");
    assert_eq!(output.stats.prototypes, 0);
    assert!(output.source.contains("OriginalName: string"));
    assert!(output.source.contains("answer: number = 42"));
    assert!(output.source.contains("'\\000\\255--literal'"));
    assert!(output.source.contains("(values())"));
    assert_eq!(
        output.baseline_source.as_deref(),
        Some(
            format!(
                "{}{}",
                luau_decompiler::attribution::prefix(true),
                std::str::from_utf8(source)
                    .unwrap()
                    .strip_prefix("--!strict\n")
                    .unwrap()
            )
            .as_str()
        )
    );
    assert_eq!(output.input_sha256, format!("{:x}", Sha256::digest(source)));
    assert_eq!(output.type_report.emitted_explicit_any, 0);
}

#[test]
fn captured_or_later_assignments_prevent_unsound_literal_annotation() {
    let source =
        b"local state = 1\nlocal function update() state = 'changed' end\nupdate()\nreturn state";
    let output = process(source, InputFormat::Auto, &config()).unwrap();
    assert!(output.source.contains("local state = 1"));
    assert!(!output.source.contains("state: number"));
    let shadow = process(
        b"local item = 1 do local item = 'inside' item = false end return item",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert!(shadow.source.contains("local item: number = 1"));
    assert!(shadow.source.contains("local item = 'inside'"));
}

#[test]
fn source_formatter_respects_token_boundaries_and_functional_directives() {
    let source = b"--!strict\n-- SPDX-License-Identifier: MIT\n-- Copyright 2026 Test Author\n-- explanation removed\nlocal difference = 5 - -2\nlocal text = 1 .. '2'\nlocal marker = '-- explanation stays in data'\nreturn difference, text, marker";
    let output = process(source, InputFormat::Auto, &config()).unwrap();
    assert!(!output.source.contains("\n-- explanation removed"));
    assert!(output.source.contains("-- explanation stays in data"));
    assert!(output.source.contains("5 - - 2"));
    assert!(output.source.contains("1 .. '2'"));
    assert!(output.source.starts_with("--!strict"));
    assert!(output.source.contains("-- SPDX-License-Identifier: MIT"));
    assert!(output.source.contains("-- Copyright 2026 Test Author"));
    let late = process(
        b"local value:number=42\n--!strict\nreturn value",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert!(late.source.starts_with("--!strict\n"));
}

#[test]
fn source_indentation_respects_zero_spaces_spaces_and_tabs() {
    let mut config = config();
    for indent in ["", "  ", "\t"] {
        config.indent = indent.into();
        let output = process(
            b"local function value(): number return 42 end return value",
            InputFormat::LuauSource,
            &config,
        )
        .unwrap();
        assert!(
            output.source.contains(&format!("\n{indent}return 42\nend")),
            "{}",
            output.source
        );
        assert_eq!(config.indentation(), indent);
    }
}

#[test]
fn source_subset_rejects_bad_syntax_unsupported_dialects_and_type_functions() {
    for source in [
        "local x =",
        "if true then return 1",
        "local x = '\\400'",
        "return ... +",
        "local f = function() return ... end",
        "return `interpolation {x}`",
        "type function unsafe() return nil end",
        "local x = 1e+",
        "return '\\x0z'",
        "do return 1 local x = 2 end",
        "break",
        "return 1()",
        "local x = {}.field",
        "local x: (number,string) = 1",
        "local x: ...number = 1",
        "local f: (...number,number)->() = function()end",
        "local f: ({field:...number})->() = function()end",
    ] {
        assert!(
            process(source.as_bytes(), InputFormat::LuauSource, &config()).is_err(),
            "{source}"
        );
    }
    for source in [
        "local x: number = 2",
        "return 0b11",
        "return 1_000",
        "return '\\x00'",
        "goto done",
        "return 6 // 2",
        "local t={} for k,v in t do print(k,v) end",
        "local pairs=function(t) return t end for k,v in pairs({}) do print(k,v) end",
    ] {
        assert!(
            process(source.as_bytes(), InputFormat::LuaSource, &config()).is_err(),
            "{source}"
        );
    }
    let output = process(
        b"local total = 0 for index = 1, 4 do total = total + index end return total",
        InputFormat::LuaSource,
        &config(),
    )
    .unwrap();
    assert_eq!(output.profile, "lua51-source");
    assert_eq!(output.assumptions.len(), 1);
    assert!(process(
        b"for key,value in pairs({one=1}) do print(key,value) end",
        InputFormat::LuaSource,
        &config()
    )
    .is_ok());
    assert!(process(
        b"local function forward<T...>(...:T...):T... return ... end return forward(1,nil,'end')",
        InputFormat::LuauSource,
        &config()
    )
    .is_ok());
    let typed_loop = process(
        b"local sum=0 for index:number=1,4 do sum+=index end return sum",
        InputFormat::LuauSource,
        &config(),
    )
    .unwrap();
    assert!(typed_loop.source.contains("index: number"));
}

#[test]
fn safe_source_renaming_preserves_globals_properties_keys_and_capture_bindings() {
    let mut config = config();
    config.naming_options.use_debug_names = false;
    config.naming = luau_decompiler::NameStyle::CamelCase;
    let output = process(b"local player_score = 1 local function read_score() return player_score end local object = {player_score=player_score} return read_score(), object.player_score, math.abs(player_score), 'player_score'", InputFormat::Auto, &config).unwrap();
    assert!(output.source.contains("local playerScore: number"));
    assert!(output.source.contains("local function readScore()"));
    assert!(output.source.contains("player_score = playerScore"));
    assert!(output.source.contains("object.player_score"));
    assert!(output.source.contains("math.abs(playerScore)"));
    assert!(output.source.contains("'player_score'"));
    config.naming_options.use_debug_names = true;
    config.name_overrides.insert("p0:b0".into(), "score".into());
    let output = process(
        b"local original = 1 local function read() return original end return read()",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert!(output.source.contains("score: number"));
    assert!(output.source.contains("return score"));
    config.name_overrides.insert("p0:b0".into(), "math".into());
    assert!(process(
        b"local original=1 return math.abs(original)",
        InputFormat::Auto,
        &config
    )
    .is_err());
}

#[test]
fn module_qualified_source_types_follow_import_bindings_and_preserve_type_namespaces() {
    let source = b"local MyModule=require('./dep')\ntype MyModule=number\nexport type PublicItem=MyModule.Item\nlocal function consume<MyModule>(MyModule:number,value:MyModule.Item,genericValue:MyModule):MyModule\nlocal copy:MyModule.Item=value\nreturn genericValue\nend\ndo\nlocal MyModule=require('./other')\ntype InnerItem=MyModule.Item\nlocal inside:InnerItem={text='ok'}\nMyModule.accept(inside)\nend\nreturn MyModule,consume\n";
    let preserved = process(source, InputFormat::LuauSource, &config()).unwrap();
    assert!(preserved
        .source
        .contains("local MyModule = require('./dep')"));
    assert!(preserved
        .source
        .contains("export type PublicItem = MyModule.Item"));
    assert!(preserved.source.contains("type MyModule = number"));
    for style in [
        luau_decompiler::NameStyle::SnakeCase,
        luau_decompiler::NameStyle::CamelCase,
        luau_decompiler::NameStyle::PascalCase,
    ] {
        let mut config = config();
        config.naming_options.use_debug_names = false;
        config.naming = style;
        let output = process(source, InputFormat::LuauSource, &config).unwrap();
        let modules: Vec<_> = output
            .source_bindings
            .iter()
            .filter(|binding| binding.original_name == "MyModule")
            .collect();
        assert_eq!(modules.len(), 3);
        let outer = &modules[0].name;
        let parameter = &modules[1].name;
        let inner = &modules[2].name;
        let value = &output
            .source_bindings
            .iter()
            .find(|binding| binding.original_name == "value")
            .unwrap()
            .name;
        let copy = &output
            .source_bindings
            .iter()
            .find(|binding| binding.original_name == "copy")
            .unwrap()
            .name;
        assert_ne!(outer, parameter);
        assert_ne!(outer, inner);
        assert!(
            output
                .source
                .contains(&format!("export type PublicItem = {outer}.Item")),
            "{}",
            output.source
        );
        assert!(
            output.source.contains(&format!("{value}: {outer}.Item")),
            "{}",
            output.source
        );
        assert!(
            output.source.contains(&format!("{copy}: {outer}.Item")),
            "{}",
            output.source
        );
        assert!(
            output
                .source
                .contains(&format!("type InnerItem = {inner}.Item")),
            "{}",
            output.source
        );
        assert!(output.source.contains("type MyModule = number"));
        let compact: String = output
            .source
            .chars()
            .filter(|c| !c.is_whitespace())
            .collect();
        assert!(compact.contains("<MyModule>"));
        assert!(output.source.contains(": MyModule"));
        assert!(output.source.contains(".accept("));
        assert!(
            !modules[0].captured,
            "type-only references do not create runtime captures"
        );
    }
    let mut config = config();
    config.naming_options.use_debug_names = false;
    config
        .name_overrides
        .insert("p0:b0".into(), "ImportedContract".into());
    let output = process(b"local ModuleName=require('./dep') local function read(value:ModuleName.Item):ModuleName.Item return ModuleName.echo(value) end return read", InputFormat::LuauSource, &config).unwrap();
    assert!(output.source.contains("ImportedContract.Item"));
    assert!(output.source.contains("ImportedContract.echo(value)"));
    assert!(output.source_bindings[0].captured);
}

#[test]
fn source_type_queries_rename_references_without_creating_runtime_captures() {
    for (body, captured) in [("return value", false), ("return OuterValue+value", true)] {
        let source = format!("local OuterValue=1 local function callback(value:typeof(OuterValue)) {body} end return callback(2)");
        let mut config = config();
        config.naming_options.use_debug_names = false;
        config.naming = luau_decompiler::NameStyle::CamelCase;
        let output = process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
        assert_eq!(output.source_bindings[0].captured, captured);
        assert!(
            output.source.contains("typeof(outerValue)"),
            "{}",
            output.source
        );
    }
}

#[test]
#[ignore = "requires pinned independent analyzer and virtual module resolution"]
fn renamed_module_qualified_types_pass_final_strict_project_analysis() {
    let source = b"local MyModule=require('./dep')\ntype MyModule=number\nexport type PublicItem=MyModule.Item\nlocal function consume<MyModule>(MyModule:number,value:MyModule.Item,genericValue:MyModule):MyModule\nlocal copy:MyModule.Item=MyModule>0 and value or value\nreturn genericValue\nend\ndo\nlocal MyModule=require('./other')\ntype InnerItem=MyModule.Item\nlocal inside:InnerItem={text='ok'}\nMyModule.accept(inside)\nend\nreturn consume\n";
    for style in [
        luau_decompiler::NameStyle::SnakeCase,
        luau_decompiler::NameStyle::CamelCase,
        luau_decompiler::NameStyle::PascalCase,
    ] {
        let mut config = config();
        config.validation.mode = ValidationMode::StrictRequired;
        config.naming_options.use_debug_names = false;
        config.naming = style;
        config.validation.project.modules.insert(
            "dep".into(),
            "export type Item={value:number} return {}".into(),
        );
        config.validation.project.modules.insert("other".into(), "export type Item={text:string} local function accept(value:Item):() end return {accept=accept}".into());
        let output = process(source, InputFormat::LuauSource, &config).unwrap();
        assert_eq!(
            output.validation.syntax,
            GateStatus::Passed,
            "{:?}\n{}",
            output.validation,
            output.source
        );
        assert_eq!(
            output.validation.compilation,
            GateStatus::Passed,
            "{:?}\n{}",
            output.validation,
            output.source
        );
        assert_eq!(
            output.validation.strict_analysis,
            GateStatus::Passed,
            "{:?}\n{}",
            output.validation,
            output.source
        );
        assert!(output.validation.required_passed);
        assert_ne!(output.validation.selected_strategy, "original_source");
        assert_ne!(output.source_bindings[0].name, "MyModule");
        assert!(output.source.contains(&format!(
            "PublicItem = {}.Item",
            output.source_bindings[0].name
        )));
    }
}

#[test]
#[ignore = "requires pinned strict analyzer; authoritative binding contracts must survive source recovery"]
fn source_recovery_cannot_drop_authoritative_contracts_despite_other_useful_types() {
    let source = b"local x=42\nlocal a:number=1\nlocal b:number=2\nlocal c:number=3\nlocal d:number=4\nreturn x,a,b,c,d\n";
    for policy in [OutputPolicy::Annotated, OutputPolicy::VerifiedTyped] {
        let mut config = config();
        config.output_policy = policy;
        config.validation.mode = ValidationMode::StrictRequired;
        config
            .typing
            .binding_types
            .insert("p0:b0".into(), "string".into());
        let output = process(source, InputFormat::LuauSource, &config).unwrap();
        assert_eq!(
            output.source,
            format!(
                "{}{}",
                luau_decompiler::attribution::prefix(false),
                std::str::from_utf8(source).unwrap()
            )
        );
        assert_eq!(output.validation.selected_strategy, "original_source");
        assert_eq!(output.validation.syntax, GateStatus::Passed);
        assert_eq!(output.validation.compilation, GateStatus::Passed);
        assert_eq!(output.validation.strict_analysis, GateStatus::Passed);
        assert!(
            !output.validation.required_passed,
            "{:?}",
            output.validation
        );
        assert!(!output.validation.meaningful_typing.passed);
        assert_eq!(output.type_report.unapplied_external_contracts, ["p0:b0"]);
        assert!(output
            .validation
            .diagnostics
            .iter()
            .any(
                |diagnostic| diagnostic.category == "unapplied_external_contract"
                    && diagnostic.binding.as_deref() == Some("p0:b0")
            ));
        assert!(output
            .validation
            .attempts
            .iter()
            .any(|attempt| attempt.strategy == "annotated"
                && attempt.strict_analysis == GateStatus::Failed));
        assert_eq!(
            output.validation.meaningful_typing.binding_coverage_percent,
            80
        );
    }
    let mut config = config();
    config.output_policy = OutputPolicy::VerifiedTyped;
    config.validation.mode = ValidationMode::StrictRequired;
    config
        .typing
        .binding_types
        .insert("p0:b0".into(), "string".into());
    let matched = process(
        b"local x:string='ok' return x",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert!(
        matched.validation.required_passed,
        "{:?}",
        matched.validation
    );
    assert!(matched.type_report.unapplied_external_contracts.is_empty());
    config
        .typing
        .binding_types
        .insert("p0:b0".into(), "number".into());
    let conflicting = process(
        b"local x:string='ok' return x",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap_err();
    assert_eq!(conflicting.stage, "config");
    assert!(conflicting
        .message
        .contains("conflicts with an existing source annotation"));
}

#[test]
fn bounded_source_mutations_are_deterministic_bounded_and_never_panic() {
    let seeds = [
        "local count=1 return count",
        "local function f(...:number) return ... end return f(1,nil)",
        "local x={child={value=1}} x.child.value=2 return x.child.value",
        "local f:(...any)->(...any)=function(...) return ... end return f(1)",
    ];
    let mut config = config();
    config.limits.max_depth = 16;
    config.limits.max_bytes = 4096;
    config.limits.max_output_bytes = 16384;
    config.limits.max_analysis_steps = 20_000;
    for (seed, source) in seeds.iter().enumerate() {
        for mutation in 0..128usize {
            let mut bytes = source.as_bytes().to_vec();
            let position = (mutation * 17 + seed * 11) % bytes.len();
            match mutation % 4 {
                0 => {
                    bytes.remove(position);
                }
                1 => {
                    let alphabet = b"(){}:;,'-\n\xff";
                    bytes.insert(position, alphabet[(mutation / 4) % alphabet.len()]);
                }
                2 => {
                    bytes[position] ^= (mutation as u8).wrapping_add(1);
                }
                _ => {
                    bytes.truncate(position);
                }
            }
            let run = || {
                process(&bytes, InputFormat::Auto, &config)
                    .map(|result| (result.source, result.type_report.emitted_explicit_any))
            };
            let first = std::panic::catch_unwind(run).expect("source mutation panicked");
            let second = std::panic::catch_unwind(run).expect("source mutation panicked");
            match (first, second) {
                (Ok(first), Ok(second)) => assert_eq!(first, second),
                (Err(first), Err(second)) => assert_eq!(
                    (first.stage, first.offset, first.message),
                    (second.stage, second.offset, second.message)
                ),
                _ => panic!("source mutation changed its acceptance result"),
            }
        }
    }
}

#[test]
fn type_only_function_annotations_do_not_count_as_runtime_typing() {
    for (source, explicit_any) in [
        ("type Hidden=typeof(function(value:number):number return value end) return 42",0),
        ("type Hidden=typeof(function(...:any):any return ... end) return 42",2),
        ("type Hidden=typeof(function(value:any):any local item:any=value return item end) return 42",3),
    ] {
        let output=process(source.as_bytes(),InputFormat::LuauSource,&config()).unwrap();
        assert_eq!(output.type_report.emitted_runtime_annotations,0,"{:?}",output.type_report);
        assert_eq!(output.type_report.annotated_parameters,0);
        assert_eq!(output.type_report.annotated_returns,0);
        assert_eq!(output.type_report.annotated_variadics,0);
        assert_eq!(output.type_report.emittable_bindings,0);
        assert_eq!(output.type_report.emittable_variadics,0);
        assert!(output.type_report.emitted_annotations>0);
        assert!(output.source_bindings.iter().all(|binding|binding.type_only));
        assert!(output.source_functions.iter().all(|function|function.type_only));
        assert_eq!(output.type_report.emitted_explicit_any,explicit_any);
    }
}

#[test]
#[ignore = "requires pinned analyzer; hidden typeof annotations cannot satisfy runtime quality"]
fn type_only_annotations_cannot_satisfy_verified_runtime_typing() {
    let mut config = config();
    config.output_policy = OutputPolicy::VerifiedTyped;
    config.validation.mode = ValidationMode::StrictRequired;
    config.meaningful_typing.min_useful_annotation_percent = 50;
    let output = process(
        b"type Hidden=typeof(function(value:number):number return value end) return 42",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert_eq!(output.validation.syntax, GateStatus::Passed);
    assert_eq!(output.validation.compilation, GateStatus::Passed);
    assert_eq!(output.validation.strict_analysis, GateStatus::Passed);
    assert!(!output.validation.required_passed);
    assert_eq!(output.validation.meaningful_typing.runtime_annotations, 0);
    assert!(
        output
            .validation
            .meaningful_typing
            .failures
            .iter()
            .any(|failure| failure.contains("runtime")),
        "{:?}",
        output.validation.meaningful_typing
    );
}

#[test]
fn original_nested_any_is_reported_recursively_without_quality_inflation() {
    let output = process(
        b"local callback: (...any) -> (...any) = function(...) return ... end return callback",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert_eq!(output.type_report.emitted_explicit_any, 2);
    assert_eq!(output.type_report.emitted_useful_annotations, 0);
}

#[test]
fn source_binding_contracts_are_explicit_bounded_and_distinct_from_original_annotations() {
    let mut config = config();
    config
        .typing
        .binding_types
        .insert("p0:b1".into(), "Player".into());
    let output = process(
        b"local function read(player) return player.UserId end return read",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert!(output.source.contains("player: Player"));
    assert!(output
        .source_bindings
        .iter()
        .any(|evidence| evidence.id == "p0:b1"
            && matches!(
                evidence.origin,
                Some(luau_decompiler::types::TypeOrigin::ExternalContract)
            )));
    assert!(process(
        b"local function read(player: number) return player end return read",
        InputFormat::Auto,
        &config
    )
    .is_err());
    config
        .typing
        .binding_types
        .insert("p0:b999".into(), "number".into());
    assert!(process(b"return 1", InputFormat::Auto, &config).is_err());
}

#[test]
fn embedding_pool_reuses_workers_and_honors_cancellation_memory_and_batch_bounds() {
    let processor = Processor::new(2).unwrap();
    assert_eq!(processor.threads(), 2);
    let context = || ExecutionContext::new(CancellationToken::new(), None);
    let first = processor
        .process(
            b"local count = 1 return count",
            InputFormat::Auto,
            &config(),
            context(),
        )
        .unwrap();
    let second = processor
        .process(
            b"local count = 1 return count",
            InputFormat::Auto,
            &config(),
            context(),
        )
        .unwrap();
    assert_eq!(first.source, second.source);
    let token = CancellationToken::new();
    token.cancel();
    assert_eq!(
        processor
            .process(
                b"return 1",
                InputFormat::Auto,
                &config(),
                ExecutionContext::new(token, None)
            )
            .unwrap_err()
            .stage,
        "cancelled"
    );
    assert_eq!(
        processor
            .process(
                b"return 1",
                InputFormat::Auto,
                &config(),
                ExecutionContext::new(
                    CancellationToken::new(),
                    Some(Instant::now() - Duration::from_millis(1))
                )
            )
            .unwrap_err()
            .stage,
        "deadline"
    );
    let budget = MemoryBudget::new(128 * 1024);
    let bounded_context = context().with_memory(budget.clone()).unwrap();
    assert!(processor
        .process(
            b"local count = 1 return count",
            InputFormat::Auto,
            &config(),
            bounded_context
        )
        .is_ok());
    assert_eq!(budget.used(), 0);
    let inputs = vec![b"return 1".to_vec(), b"return 2".to_vec()];
    assert!(processor
        .process_batch(&inputs, InputFormat::Auto, &config(), context(), 1024)
        .is_err());
    let outputs = processor
        .process_batch(
            &inputs,
            InputFormat::Auto,
            &config(),
            context(),
            128 * 1024 * 1024,
        )
        .unwrap();
    assert!(outputs.iter().all(Result::is_ok));
}

#[test]
fn source_quality_counts_parameter_coverage_once_and_measures_all_annotation_slots() {
    let output = process(
        b"local function f(first:number,second,third) return first,second,third end return f",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert_eq!(output.type_report.emittable_bindings, 3);
    assert_eq!(output.type_report.annotated_bindings, 0);
    assert_eq!(output.type_report.annotated_parameters, 1);
    assert_eq!(output.type_report.emitted_annotations, 1);
    let mut quality = output.validation;
    luau_decompiler::quality::apply_output_policy(&mut quality, &output.type_report, &config());
    assert_eq!(quality.meaningful_typing.binding_coverage_percent, 33);
    let aliases = process(b"type Hidden={value:unknown} local callback:()->number=function()return 1 end return callback", InputFormat::Auto, &config()).unwrap();
    assert_eq!(aliases.type_report.emitted_annotations, 3);
    assert_eq!(aliases.type_report.emitted_useful_annotations, 2);
    assert!(aliases.source.contains("function(): number"));
    assert!(matches!(
        aliases.source_functions[0].origin,
        Some(luau_decompiler::types::TypeOrigin::Inference)
    ));
    let variadic = process(
        b"local function f(...:any) return ... end return f",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert_eq!(variadic.type_report.emitted_annotations, 1);
    assert_eq!(variadic.type_report.emitted_explicit_any, 1);
    let binding = &output.source_bindings[1];
    assert_eq!(binding.id, "p0:b1");
    assert_eq!(binding.original_name, "first");
    assert_eq!(binding.declaration_end - binding.declaration_start, 5);
    assert!(output.type_report.evidence.is_empty());
    let singleton = process(
        b"local value: 'any'='any' return value",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert_eq!(singleton.type_report.emitted_explicit_any, 0);
    let type_of = process(
        b"local any=1 local value:typeof(any)=1 return value",
        InputFormat::Auto,
        &config(),
    )
    .unwrap();
    assert_eq!(type_of.type_report.emitted_explicit_any, 0);
}

#[test]
fn faithful_source_retains_original_annotations_without_inventing_new_ones() {
    let mut config = config();
    config.output_policy = OutputPolicy::Faithful;
    let output = process(
        b"local original: number = 1 local nextValue = 2 return original, nextValue",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert!(output.source.contains("original: number"));
    assert!(!output.source.contains("nextValue: number"));
    assert_eq!(output.type_report.emitted_annotations, 1);
    config.naming_options.use_debug_names = false;
    let renamed = process(
        b"local OriginalName: number = 42 return OriginalName",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert!(renamed.source.contains("original_name: number"));
    assert_eq!(renamed.source_bindings[0].name, "original_name");
    assert_eq!(renamed.source_bindings[0].original_name, "OriginalName");
}

#[test]
#[ignore = "requires pinned independent analyzer assets"]
fn final_source_verified_policy_checks_positive_and_negative_and_preserves_original_types() {
    let mut config = Config {
        output_policy: OutputPolicy::VerifiedTyped,
        ..Config::default()
    };
    let positive = process(
        b"local total: number = 42 return total",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert_eq!(positive.validation.syntax, GateStatus::Passed);
    assert_eq!(positive.validation.compilation, GateStatus::Passed);
    assert_eq!(positive.validation.strict_analysis, GateStatus::Passed);
    assert!(
        positive.validation.required_passed,
        "{:?}",
        positive.validation.diagnostics
    );
    let snapshot = process(
        include_bytes!("source-corpus/player_snapshot.luau"),
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert_eq!(snapshot.validation.syntax, GateStatus::Passed);
    assert_eq!(snapshot.validation.compilation, GateStatus::Passed);
    assert_eq!(snapshot.validation.strict_analysis, GateStatus::Passed);
    assert!(
        snapshot.validation.required_passed,
        "{:?}",
        snapshot.validation.diagnostics
    );
    assert!(snapshot.source.contains("export type PlayerSnapshot"));
    assert!(snapshot.source.contains("player: Player"));
    assert!(snapshot.source.contains("character:GetPivot().Position"));
    let negative = process(
        b"local total: string = 42 return total",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert_eq!(negative.validation.strict_analysis, GateStatus::Failed);
    assert!(!negative.validation.required_passed);
    let broad = process(
        b"local callback: (...any) -> (...any) = function(...) return ... end return callback",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert!(!broad.validation.required_passed);
    for source in [
        b"type Hidden=unknown local total:number=42 return total".as_slice(),
        b"local function f(...:unknown):number return 1 end return f".as_slice(),
    ] {
        let unresolved = process(source, InputFormat::Auto, &config).unwrap();
        assert_eq!(unresolved.validation.strict_analysis, GateStatus::Passed);
        assert!(!unresolved.validation.meaningful_typing.passed);
        assert!(!unresolved.validation.required_passed);
    }
    config.validation.mode = ValidationMode::Off;
    assert!(process(b"local total = 1 return total", InputFormat::Auto, &config).is_err());
    config.output_policy = OutputPolicy::Faithful;
    config.validation.mode = ValidationMode::Check;
    config.naming_options.use_debug_names = false;
    let faithful = process(
        b"local OriginalName: number = 42 return OriginalName",
        InputFormat::Auto,
        &config,
    )
    .unwrap();
    assert_eq!(faithful.validation.selected_strategy, "faithful_source");
    assert_eq!(faithful.validation.strict_analysis, GateStatus::Passed);
    assert!(faithful.source.contains("original_name: number"));
    assert_eq!(faithful.source_bindings[0].name, "original_name");
    assert_eq!(
        faithful.validation.attempts.last().unwrap().source_sha256,
        format!("{:x}", Sha256::digest(faithful.source.as_bytes()))
    );
}
