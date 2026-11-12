mod support;
use luau_decompiler::input::InputFormat;
use luau_decompiler::processing::process;
use luau_decompiler::{Config, NameStyle};
use serde_json::json;
use std::{fs, path::Path};

const PROGRAMS: &[(&str, &str)] = &[
    ("method_receiver", "local seed=... local object={base=seed} function object:combine(value:number):number return self.base+value end return object:combine(4), object.base"),
    ("mutable_capture", "local seed=... local counter=seed local function add(delta:number):number counter+=delta return counter end return add(1),add(-2),counter"),
    ("adjusted_pack", "local seed=... local function values(value:number):(number,nil,number) return value,nil,value+1 end local function forward(...) return select('#',...),... end return forward((values(seed)))"),
    ("protected_error", "local seed=... local ok,message=pcall(function() error('failed:'..seed,0) end) return ok,message"),
    ("table_alias", "local seed=... local root={child={value=seed}} local alias=root.child for index=1,3 do alias.value=alias.value+index end return root.child.value,alias==root.child"),
    ("generic_identity", "local seed=... local function identity<T>(value:T):T return value end return identity(seed),identity('binary\\000\\255')"),
    ("typed_callback", "local seed=... type Callback=(number)->number local function apply(callback:Callback,value:number):number return callback(value) end return apply(function(value:number):number return value*2 end,seed)"),
    ("stateful_calls", "local seed=... local value=seed local function update(delta) value=value+delta return value,nil end local a,b=update(1) local c,d=update(2) return a,b,c,d,value"),
    ("loop_exit", "local seed=... local total=0 repeat total=total+1 if total>2 then break end until total>seed return total"),
    ("conditional_table", "local seed=... local key='value' local record={[key]=if seed>0 then seed else -seed,other=nil} return record.value,record.other"),
    ("scalars_effects", "local seed=... local difference=seed- -2 local text=1 .. '2' print(difference,text,'\\000\\255') return difference,text,type(seed)"),
    ("zero_pack", "local function none() end local function forward(...) return select('#',...),... end return forward((none()))"),
];

#[test]
#[ignore = "requires pinned compilers and typed behavioral oracles"]
fn original_source_to_formatted_source_preserves_typed_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/source-input-rc");
    fs::create_dir_all(&destination).unwrap();
    let mut rows = Vec::new();
    let mut failures = Vec::new();
    let mut comparisons = 0;
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for &(family, source) in PROGRAMS {
            for style in [
                None,
                Some(NameStyle::CamelCase),
                Some(NameStyle::PascalCase),
            ] {
                let mut config = Config::default();
                config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
                config.formatting.line_width = 40;
                config.naming_options.use_debug_names = style.is_none();
                config.naming = style.unwrap_or(NameStyle::SnakeCase);
                for optimization in [0, 2] {
                    for debug in [0, 2] {
                        let identity =
                            format!("{family}/v{version}/{style:?}/O{optimization}/D{debug}");
                        let directory = destination.join(identity.replace(['/', ':'], "-"));
                        fs::create_dir_all(&directory).unwrap();
                        let outcome = (|| -> Result<_, String> {
                            let original_path = directory.join("original.luau");
                            fs::write(&original_path, source).map_err(|error| error.to_string())?;
                            let output =
                                process(source.as_bytes(), InputFormat::LuauSource, &config)
                                    .map_err(|error| error.to_string())?;
                            if !output.complete
                                || output.profile != "luau-source"
                                || output.stats.prototypes != 0
                            {
                                return Err(
                                    "source was not processed through the standalone source path"
                                        .into(),
                                );
                            }
                            let output_path = directory.join("formatted.luau");
                            fs::write(&output_path, &output.source)
                                .map_err(|error| error.to_string())?;
                            let original = tools.compile(&original_path, optimization, debug)?;
                            let formatted = tools.compile(&output_path, optimization, debug)?;
                            let mut inputs = Vec::new();
                            for seed in [-3.0f64, 0.0, 7.0] {
                                let arguments = [support::oracle::Value::Number(seed.to_bits())];
                                let expected = tools.observe(
                                    &original,
                                    &directory,
                                    &format!("original-{seed}"),
                                    &arguments,
                                )?;
                                let actual = tools.observe(
                                    &formatted,
                                    &directory,
                                    &format!("formatted-{seed}"),
                                    &arguments,
                                )?;
                                if !expected.equivalent(&actual) {
                                    return Err(format!("typed behavioral mismatch at input {seed}: {expected:?} != {actual:?}"));
                                }
                                comparisons += 1;
                                inputs
                                    .push(json!({"input":seed,"equivalent":true,"complete":true}));
                            }
                            Ok(
                                json!({"id":identity,"family":family,"source_sha256":support::digest(source.as_bytes()),"output_sha256":support::digest(output.source.as_bytes()),"configuration":config,"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"comparisons":inputs,"passed":true}),
                            )
                        })();
                        match outcome {
                            Ok(row) => rows.push(row),
                            Err(error) => {
                                failures.push(json!({"id":identity,"error":error}));
                            }
                        }
                    }
                }
            }
        }
    }
    let report = json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"source_path":"Rust parse and token-preserving print; no compile/decompile","source_families":PROGRAMS.len(),"compiled_cases":rows.len(),"typed_comparisons":comparisons,"cases":rows,"failures":failures,"passed":failures.is_empty(),"limits":"Controlled sources and runtime inputs only; strict quality tested separately"});
    fs::write(
        root.join("docs/results/source-input-rc.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    assert!(failures.is_empty(), "{failures:#?}");
    assert_eq!(comparisons, PROGRAMS.len() * 2 * 3 * 2 * 2 * 3);
}
