#[path = "support/generator.rs"]
mod generator;
mod support;

use luau_decompiler::{
    input::InputFormat, processing::process, quality::ValidationMode, Config, NameStyle,
    OutputPolicy,
};
use serde_json::json;
use std::{fs, path::Path};

fn indexed(equals: usize, callable: bool) -> String {
    let delimiter = "=".repeat(equals);
    let table = if callable {
        "setmetatable({foo='indexed'},{__call=function(_, key) return 'called:'..key end})"
    } else {
        "{foo='indexed'}"
    };
    format!("local FancyTable={table}\nreturn FancyTable[ [{delimiter}[foo]{delimiter}] ]\n")
}

#[test]
fn long_string_indices_keep_separate_lexical_boundaries_without_validation() {
    for equals in 0..9 {
        for callable in [false, true] {
            for style in [
                NameStyle::SnakeCase,
                NameStyle::CamelCase,
                NameStyle::PascalCase,
            ] {
                let mut config = Config {
                    output_policy: OutputPolicy::Faithful,
                    naming: style,
                    ..Config::default()
                };
                config.validation.mode = ValidationMode::Off;
                config.naming_options.use_debug_names = false;
                let output = process(
                    indexed(equals, callable).as_bytes(),
                    InputFormat::LuauSource,
                    &config,
                )
                .unwrap();
                assert!(
                    output.source.contains(&format!(
                        "[ [{}[foo]{}]",
                        "=".repeat(equals),
                        "=".repeat(equals)
                    )),
                    "{}",
                    output.source
                );
                assert!(output.source.contains("foo"));
                assert!(output.complete);
            }
        }
    }
}

#[test]
fn source_return_inference_preserves_unknowns_arity_and_capture_mutation() {
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    let output=process(b"local function square(value:number) local result=value*value return result end local callback=function(value:number) return value+1 end return square(3),callback(4)",InputFormat::LuauSource,&config).unwrap();
    assert!(
        output.source.contains("square(value: number): number"),
        "{}",
        output.source
    );
    assert!(output.source.contains("local result: number"));
    assert!(
        output
            .source
            .contains("local callback: (number) -> (number)"),
        "{}",
        output.source
    );
    assert!(output.source_functions.iter().all(|function| matches!(
        function.origin,
        Some(luau_decompiler::types::TypeOrigin::Inference)
    )));
    for source in [
        "local captured=1 local function read() return captured end captured='changed' return read()",
        "local function vary(flag:boolean) if flag then return 1 end return 1,nil end return vary(true)",
        "local function partial(flag:boolean) if flag then return 1 end end return partial(false)",
        "local function arithmetic(value) return value+1 end return arithmetic(2)",
        "local function unknown() return external() end return unknown()",
        "local function mutate_record(input:{value:number},mutate:(unknown)->()) mutate(input) return input end return mutate_record",
        "local function alias_scope() type Alias=number local value:Alias=1 return value end return alias_scope",
        "local function generic_mutation<T>(input:T,mutate:(T)->()) mutate(input) return input end return generic_mutation",
    ] {
        let result=process(source.as_bytes(),InputFormat::LuauSource,&config).unwrap();
        assert!(result.source_functions.iter().all(|function|function.returns.is_none()),"{}",result.source);
    }
    let recursive = process(
        b"local function recursive(value:number) return recursive(value) end return recursive",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert!(recursive.source_functions[0].returns.is_none());
}

#[test]
fn nested_signature_functions_do_not_replace_runtime_function_identity() {
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    for source in [
        "local callback=function(unused:typeof(function():number return 0 end)):string return 'ok' end return callback(function():number return 0 end)",
        "local function callback(unused:typeof(function():number return 0 end)):string return 'ok' end local alias=callback return alias(function():number return 0 end)",
        "local callback=function():typeof(function():number return 0 end) return function():number return 1 end end return callback()()",
    ] {
        let output = process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
        for name in ["callback", "alias"] {
            if let Some(binding) = output.source_bindings.iter().find(|binding| binding.original_name == name) {
                assert!(binding.ty.is_none(), "{name}: {:?}\n{}", binding.ty, output.source);
            }
        }
        assert!(output.source_functions.iter().any(|function| function.type_only));
    }
}

#[test]
#[ignore = "requires pinned compiler, analyzer and typed oracle"]
fn nested_signature_function_identity_preserves_strict_types_and_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tools = support::Toolset::checked(root, 14);
    let directory = root.join("artifacts/rc3-reliability/source-signatures");
    fs::create_dir_all(&directory).unwrap();
    let analyzer = root.join(".tools/luau-modern/luau-analyze.exe");
    let programs = [
        ("anonymous_parameter", "local callback=function(unused:typeof(function():number return 0 end)):string return 'ok' end return callback(function():number return 0 end)"),
        ("named_alias", "local function callback(unused:typeof(function():number return 0 end)):string return 'ok' end local alias=callback return alias(function():number return 0 end)"),
        ("return_annotation", "local callback=function():typeof(function():number return 0 end) return function():number return 1 end end return callback()()"),
    ];
    let mut rows = Vec::new();
    for (id, source) in programs {
        let mut config = Config::default();
        config.validation.mode = ValidationMode::Off;
        let output = process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
        let original = directory.join(format!("{id}-original.luau"));
        let rebuilt = directory.join(format!("{id}-rebuilt.luau"));
        fs::write(&original, source).unwrap();
        fs::write(&rebuilt, &output.source).unwrap();
        let analysis = std::process::Command::new(&analyzer)
            .arg(&rebuilt)
            .output()
            .unwrap();
        assert!(
            analysis.status.success(),
            "{id}: {}\n{}",
            String::from_utf8_lossy(&analysis.stderr),
            output.source
        );
        let expected = tools
            .observe(
                &tools.compile(&original, 0, 0).unwrap(),
                &directory,
                "original",
                &[],
            )
            .unwrap();
        let actual = tools
            .observe(
                &tools.compile(&rebuilt, 2, 2).unwrap(),
                &directory,
                "rebuilt",
                &[],
            )
            .unwrap();
        assert!(
            expected.equivalent(&actual),
            "{id}: {expected:?} {actual:?}"
        );
        rows.push(json!({"id":id,"source_sha256":support::digest(source.as_bytes()),"output_sha256":support::digest(output.source.as_bytes()),"strict_passed":true,"verified":true,"expected":expected,"actual":actual,"functions":output.source_functions,"bindings":output.source_bindings}));
    }
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"passed":true,"version":env!("CARGO_PKG_VERSION"),"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"analyzer_sha256":support::digest(&fs::read(analyzer).unwrap()),"cases":rows})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned strict analyzer and typed oracle"]
fn inferred_source_signatures_verify_without_runtime_changes() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/source-rc2-types");
    fs::create_dir_all(&directory).unwrap();
    let tools = support::Toolset::checked(root, 14);
    let programs=[
        "local function square(value:number) local result=value*value return result end return square(-3),square(0),square(7)",
        "local function identity<T>(value:T) return value end return identity(4),identity('a\\000\\255'),identity(false)",
        "local callback=function(value:number) return value+1 end return callback(2),callback(-4)",
        "local function values(flag:boolean) if flag then return nil,'missing',nil end return 7,'found',nil end return values(true),values(false)",
        "local function none() end return select('#',none())",
        "local function text(value:number) return 'value:'..value end return text(4),text(-2)",
    ];
    let mut rows = Vec::new();
    for (id, source) in programs.iter().enumerate() {
        let config = Config {
            output_policy: OutputPolicy::VerifiedTyped,
            ..Config::default()
        };
        let output = process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
        assert!(
            output.validation.required_passed,
            "{}\n{:?}",
            output.source, output.validation
        );
        let original = directory.join("original.luau");
        let rebuilt = directory.join("rebuilt.luau");
        fs::write(&original, source).unwrap();
        fs::write(&rebuilt, &output.source).unwrap();
        let expected = tools
            .observe(
                &tools.compile(&original, 0, 0).unwrap(),
                &directory,
                "original",
                &[],
            )
            .unwrap();
        let actual = tools
            .observe(
                &tools.compile(&rebuilt, 2, 2).unwrap(),
                &directory,
                "rebuilt",
                &[],
            )
            .unwrap();
        assert!(expected.equivalent(&actual));
        rows.push(json!({"id":id,"source_sha256":support::digest(source.as_bytes()),"output_sha256":support::digest(output.source.as_bytes()),"validation":output.validation,"functions":output.source_functions,"expected":expected,"actual":actual,"verified":true}));
    }
    fs::write(
        directory.join("report.json"),
        serde_json::to_vec_pretty(
            &json!({"passed":true,"version":env!("CARGO_PKG_VERSION"),"rows":rows}),
        )
        .unwrap(),
    )
    .unwrap();
}

#[test]
#[ignore = "requires pinned compilers and independent behavioral oracle"]
fn generated_source_families_are_parsed_formatted_and_compared() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/source-rc2-generated");
    fs::create_dir_all(&directory).unwrap();
    let mut rows = Vec::new();
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for family in 0..generator::FAMILIES.len() {
            for seed in [1, 7, 19] {
                let source = generator::program_from_axes(family, seed);
                let mut config = Config::default();
                config.validation.mode = ValidationMode::Off;
                config.naming_options.use_debug_names = false;
                config.naming = if seed == 7 {
                    NameStyle::CamelCase
                } else {
                    NameStyle::SnakeCase
                };
                let output = process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
                let original = directory.join("original.luau");
                let rebuilt = directory.join("rebuilt.luau");
                fs::write(&original, &source).unwrap();
                fs::write(&rebuilt, &output.source).unwrap();
                let original = tools.compile(&original, 0, 0).unwrap();
                let rebuilt = tools.compile(&rebuilt, 2, 2).unwrap();
                for input in [-3.0f64, 0.0, 7.0] {
                    let arguments = [
                        support::oracle::Value::Number(input.to_bits()),
                        support::oracle::Value::String(vec![0, 255, 9]),
                    ];
                    let expected = tools
                        .observe(&original, &directory, "original", &arguments)
                        .unwrap();
                    let actual = tools
                        .observe(&rebuilt, &directory, "rebuilt", &arguments)
                        .unwrap();
                    assert!(
                        expected.equivalent(&actual),
                        "{version}/{family}/{seed}/{input}: {expected:?} != {actual:?}"
                    );
                    rows.push(json!({"id":format!("v{version}/{}/{seed}/{input}",generator::FAMILIES[family]),"source_sha256":support::digest(source.as_bytes()),"output_sha256":support::digest(output.source.as_bytes()),"expected":expected,"actual":actual,"verified":true}));
                }
            }
        }
    }
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for seed in [0, 1, 7, 19] {
            let source = if seed == 0 {
                generator::program(0)
            } else {
                generator::compositional_stateful_program(seed)
            };
            let mut config = Config::default();
            config.validation.mode = ValidationMode::Off;
            config.naming_options.use_debug_names = false;
            config.naming = NameStyle::CamelCase;
            let output = process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
            let original = directory.join("extra-original.luau");
            let rebuilt = directory.join("extra-rebuilt.luau");
            fs::write(&original, &source).unwrap();
            fs::write(&rebuilt, &output.source).unwrap();
            let original = tools.compile(&original, 0, 0).unwrap();
            let rebuilt = tools.compile(&rebuilt, 2, 2).unwrap();
            let probe = if seed != 0 {
                let source = directory.join("stateful-probe.luau");
                fs::write(&source,"local callback=... local a,b,c,d=callback(1) local e,f,g,h=callback(-1) local i,j,k,l=callback(0) return a,b,c,d,e,f,g,h,i,j,k,l").unwrap();
                let bytes = tools.compile(&source, 0, 0).unwrap();
                let path = directory.join("stateful-probe.bc");
                fs::write(&path, bytes).unwrap();
                Some(path)
            } else {
                None
            };
            for input in [-3.0f64, 0.0, 7.0] {
                let arguments = [
                    support::oracle::Value::Number(input.to_bits()),
                    support::oracle::Value::String(vec![0, 255, 9]),
                ];
                let expected = tools
                    .observe_with_probe(
                        &original,
                        &directory,
                        "extra-original",
                        &arguments,
                        probe.as_deref(),
                    )
                    .unwrap();
                let actual = tools
                    .observe_with_probe(
                        &rebuilt,
                        &directory,
                        "extra-rebuilt",
                        &arguments,
                        probe.as_deref(),
                    )
                    .unwrap();
                assert!(expected.equivalent(&actual));
                rows.push(json!({"id":format!("v{version}/extra/{seed}/{input}"),"source_sha256":support::digest(source.as_bytes()),"output_sha256":support::digest(output.source.as_bytes()),"expected":expected,"actual":actual,"verified":true}));
            }
        }
    }
    assert_eq!(rows.len(), 168);
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"passed":true,"version":env!("CARGO_PKG_VERSION"),"legacy_generator_capacity":generator::PROGRAMS,"cases":56,"comparisons":rows})).unwrap()).unwrap();
}

#[test]
#[ignore = "requires pinned compiler, analyzer and independent typed VM oracle"]
fn long_string_indexing_and_source_grammar_preserve_observed_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/source-rc2");
    fs::create_dir_all(&directory).unwrap();
    let tools = support::Toolset::checked(root, 14);
    let mut cases = Vec::new();
    for equals in [0, 1, 2, 5] {
        for callable in [false, true] {
            let source = indexed(equals, callable);
            let original_path = directory.join(format!("original-{equals}-{callable}.luau"));
            fs::write(&original_path, &source).unwrap();
            let original = tools.compile(&original_path, 2, 2).unwrap();
            for validation in [ValidationMode::Off, ValidationMode::Check] {
                for style in [
                    NameStyle::SnakeCase,
                    NameStyle::CamelCase,
                    NameStyle::PascalCase,
                ] {
                    let mut config = Config {
                        output_policy: OutputPolicy::Faithful,
                        naming: style,
                        ..Config::default()
                    };
                    config.validation.mode = validation;
                    config.naming_options.use_debug_names = false;
                    let output =
                        process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
                    let path = directory.join("formatted.luau");
                    fs::write(&path, &output.source).unwrap();
                    let rebuilt = tools.compile(&path, 2, 2).unwrap();
                    let expected = tools
                        .observe(&original, &directory, "original", &[])
                        .unwrap();
                    let actual = tools
                        .observe(&rebuilt, &directory, "formatted", &[])
                        .unwrap();
                    assert!(
                        expected.equivalent(&actual),
                        "{source}\n{}\n{expected:?}\n{actual:?}",
                        output.source
                    );
                    assert_eq!(
                        actual.terminal,
                        [support::oracle::Value::String(b"indexed".to_vec())]
                    );
                    cases.push(json!({"family":"long_string_index","delimiter_equals":equals,"callable":callable,"validation":validation,"style":style,"source_sha256":support::digest(source.as_bytes()),"output_sha256":support::digest(output.source.as_bytes()),"expected":expected,"actual":actual,"verified":true}));
                }
            }
        }
    }
    let grammar = [
        "local function id<T>(value:T):T return value end return id('a\\000\\255')",
        "local function empty():() end return select('#',(empty()))",
        "type R={value:number?} local r:R={value=nil} if r.value==nil then r.value=4 end return r.value",
        "local t={['foo']='indexed'} return t[ ( [==[foo]==] ) ]",
        "local x=0 repeat x+=1 if x==2 then continue end until x>3 return x",
        "local t={2,3} local n=0 for key,value in ipairs(t) do n+=key*value end return n",
        "local function f(...:number):(number,number?) return select('#',...),nil end return f(1,2,3)",
        "local n=0 local function factory() n+=1 return function(x:number):number n+=x return n end end local f=factory() return f(2),f(3),n",
        "type F=(number)->number local f:F=function(x:number):number return x+1 end return f(3)",
        "local ok,message=pcall(function() error('binary\\000\\255',0) end) return ok,message",
        "local t={} local alias=t t.self=t alias.value=4 return t.self==t,t.value",
        "local x=if false then 'a' elseif true then 'b' else 'c' return x",
    ];
    for (index, source) in grammar.iter().enumerate() {
        let path = directory.join("grammar-original.luau");
        fs::write(&path, source).unwrap();
        let mut config = Config::default();
        config.validation.mode = ValidationMode::Off;
        config.naming_options.use_debug_names = false;
        let output = process(source.as_bytes(), InputFormat::LuauSource, &config).unwrap();
        let formatted_path = directory.join("grammar-formatted.luau");
        fs::write(&formatted_path, &output.source).unwrap();
        let original = tools.compile(&path, 0, 0).unwrap();
        let rebuilt = tools.compile(&formatted_path, 2, 2).unwrap();
        let expected = tools
            .observe(&original, &directory, "grammar-original", &[])
            .unwrap();
        let actual = tools
            .observe(&rebuilt, &directory, "grammar-rebuilt", &[])
            .unwrap();
        assert!(
            expected.equivalent(&actual),
            "{source}\n{}\n{expected:?}\n{actual:?}",
            output.source
        );
        cases.push(json!({"family":"grammar","id":index,"source_sha256":support::digest(source.as_bytes()),"output_sha256":support::digest(output.source.as_bytes()),"expected":expected,"actual":actual,"verified":true}));
    }
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"version":env!("CARGO_PKG_VERSION"),"passed":true,"cases":cases,"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash})).unwrap()).unwrap();
}
