#[path = "oracle/mod.rs"]
mod oracle;
use luau_decompiler::{decompile, Config, NameStyle};
use oracle::Observation;
use serde::Deserialize;
use serde_json::json;
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

fn tool(variable: &str, name: &str) -> PathBuf {
    std::env::var_os(variable)
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join(".tools/luau")
                .join(format!("{name}{}", std::env::consts::EXE_SUFFIX))
        })
}
fn compiler() -> PathBuf {
    tool("LUAU_COMPILE", "luau-compile")
}
fn runner() -> PathBuf {
    std::env::var_os("LUAU_VM_RUNNER")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join(".tools")
                .join(format!("vm-runner{}", std::env::consts::EXE_SUFFIX))
        })
}
fn compile(
    compiler: &Path,
    path: &Path,
    optimization: usize,
    debug: usize,
) -> Result<Vec<u8>, String> {
    let output = Command::new(compiler)
        .arg("--binary")
        .arg(format!("-O{optimization}"))
        .arg(format!("-g{debug}"))
        .arg(path)
        .output()
        .map_err(|e| format!("{}: {e}", compiler.display()))?;
    if !output.status.success() || output.stdout.first().is_none_or(|&b| b == 0) {
        return Err(format!(
            "compiler failed; diagnostic bytes: {:?}",
            output.stderr
        ));
    }
    Ok(output.stdout)
}
fn execute(vm: &Path, bytes: &[u8], path: &Path) -> Result<Observation, String> {
    execute_args(vm, bytes, path, &[])
}
fn execute_args(
    vm: &Path,
    bytes: &[u8],
    path: &Path,
    values: &[oracle::Value],
) -> Result<Observation, String> {
    fs::write(path, bytes).map_err(|e| e.to_string())?;
    let args_path = path.with_extension("args");
    fs::write(&args_path, oracle::encode_arguments(values)?).map_err(|e| e.to_string())?;
    let output = Command::new(vm)
        .arg(path)
        .arg("--args")
        .arg(&args_path)
        .output()
        .map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err(format!(
            "oracle process failed: {:?}; diagnostic bytes {:?}",
            output.status.code(),
            output.stderr
        ));
    }
    fs::write(path.with_extension("obs"), &output.stdout).map_err(|e| e.to_string())?;
    Observation::decode(&output.stdout)
}
#[derive(Debug, Clone, Deserialize)]
struct RuntimeInput {
    name: String,
    values: Vec<oracle::Value>,
}

#[test]
#[ignore = "requires pinned compiler and typed official VM; mandatory in scripts/validate.ps1"]
fn compiler_matrix_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let compiler = compiler();
    let vm = runner();
    assert!(
        compiler.is_file(),
        "LUAU_COMPILE must point to the pinned compiler"
    );
    assert!(
        vm.is_file(),
        "build the typed oracle with scripts/build-vm.ps1"
    );
    let artifact_dir = root.join("artifacts/validation");
    fs::create_dir_all(&artifact_dir).unwrap();
    let mut corpus: Vec<_> = fs::read_dir(root.join("tests/corpus"))
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|path| path.extension().is_some_and(|e| e == "luau"))
        .collect();
    corpus.sort();
    let mut rows = Vec::new();
    let mut failures = Vec::new();
    let input_path = root.join("tests/runtime-inputs.json");
    let runtime_inputs: BTreeMap<String, Vec<RuntimeInput>> = if input_path.is_file() {
        serde_json::from_slice(&fs::read(input_path).unwrap()).unwrap()
    } else {
        BTreeMap::new()
    };
    for path in corpus {
        let name = path
            .file_stem()
            .unwrap()
            .to_str()
            .expect("corpus filename must be UTF-8");
        let input_cases = runtime_inputs.get(name).cloned().unwrap_or_else(|| {
            vec![RuntimeInput {
                name: "default".into(),
                values: vec![],
            }]
        });
        assert!(
            !input_cases.is_empty(),
            "a corpus source cannot have zero runtime inputs"
        );
        for optimization in 0..=2 {
            for debug in 0..=2 {
                let bytes =
                    compile(&compiler, &path, optimization, debug).expect("fixture compilation");
                for input in &input_cases {
                    assert!(
                        !input.name.is_empty()
                            && input
                                .name
                                .bytes()
                                .all(|b| b.is_ascii_alphanumeric() || b == b'_'),
                        "invalid input case name"
                    );
                    let key = format!("{name}.O{optimization}.D{debug}.{}", input.name);
                    let expected = execute_args(
                        &vm,
                        &bytes,
                        &artifact_dir.join(format!("{key}.original.bc")),
                        &input.values,
                    )
                    .expect("valid complete oracle frame");
                    if !expected.verified() {
                        rows.push(json!({"case": key, "status": "incomplete_original_observation", "expected": expected}));
                        failures.push(format!(
                            "{key}: original observation is incomplete or a harness failure"
                        ));
                        continue;
                    }
                    match decompile(&bytes, &Config::default()) {
                        Err(error) => {
                            rows.push(json!({"case": key, "status": "rejected", "error": error}));
                            failures.push(format!("{key}: {error}"));
                        }
                        Ok(result) => {
                            let out_path = artifact_dir.join(format!("{key}.luau"));
                            fs::write(&out_path, &result.source).unwrap();
                            let recompiled = match compile(
                                &compiler,
                                &out_path,
                                optimization,
                                debug,
                            ) {
                                Ok(bytes) => bytes,
                                Err(error) => {
                                    rows.push(json!({"case": key, "status": "recompile_failed", "error": error}));
                                    failures.push(format!("{key}: {error}"));
                                    continue;
                                }
                            };
                            let actual = execute_args(
                                &vm,
                                &recompiled,
                                &artifact_dir.join(format!("{key}.recompiled.bc")),
                                &input.values,
                            );
                            match actual {
                                Ok(actual) => {
                                    let equal = expected.equivalent(&actual);
                                    let status = if equal {
                                        "passed"
                                    } else if !actual.verified() {
                                        "incomplete_output_observation"
                                    } else {
                                        "behavior_failed"
                                    };
                                    rows.push(json!({"case": key, "status": status, "expected": expected, "actual": actual, "stats": result.stats}));
                                    if !equal {
                                        failures.push(format!("{key}: typed behavior mismatch or incomplete observation"));
                                    }
                                }
                                Err(error) => {
                                    rows.push(json!({"case": key, "status": "oracle_failed", "error": error}));
                                    failures.push(format!("{key}: {error}"));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let passed = rows.iter().filter(|row| row["status"] == "passed").count();
    let report = json!({"schema": 2, "oracle_protocol": oracle::PROTOCOL, "upstream_revision": luau_decompiler::UPSTREAM_REVISION,
        "comparison": "typed complete observations; exact IEEE bits, raw bytes, tuple counts, ordered effects and error values; incomplete never passes",
        "matrix": "all corpus scripts x O0/O1/O2 x D0/D1/D2 x declared typed runtime inputs", "cases": rows.len(), "passed": passed, "results": rows});
    fs::write(
        artifact_dir.join("report.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    println!(
        "typed behavioral differential coverage: {passed}/{}; artifacts/validation/report.json",
        rows.len()
    );
    assert!(
        failures.is_empty(),
        "{} failures:\n{}",
        failures.len(),
        failures.join("\n")
    );
}

#[test]
#[ignore = "requires official compiler and typed VM"]
fn renaming_does_not_change_properties_or_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let compiler = compiler();
    let vm = runner();
    let bytes = compile(
        &compiler,
        &root.join("tests/corpus/names_strings.luau"),
        1,
        2,
    )
    .unwrap();
    let dir = root.join("artifacts/naming");
    fs::create_dir_all(&dir).unwrap();
    let expected = execute(&vm, &bytes, &dir.join("original.bc")).unwrap();
    for (index, style) in [
        NameStyle::SnakeCase,
        NameStyle::CamelCase,
        NameStyle::PascalCase,
    ]
    .into_iter()
    .enumerate()
    {
        let mut config = Config {
            naming: style,
            indent: "\t".into(),
            ..Config::default()
        };
        config
            .name_overrides
            .insert("p0:r0".into(), "ExplicitBinding".into());
        let result = decompile(&bytes, &config).unwrap();
        assert!(result.source.contains("ExplicitBinding"));
        assert!(
            result.source.contains("playerScore"),
            "property key must survive renaming"
        );
        let source_path = dir.join(format!("{index}.luau"));
        fs::write(&source_path, &result.source).unwrap();
        let bytecode = compile(&compiler, &source_path, 1, 2).unwrap();
        let actual = execute(&vm, &bytecode, &dir.join(format!("{index}.bc"))).unwrap();
        assert!(
            expected.equivalent(&actual),
            "typed naming behavior differs: expected {expected:?}, actual {actual:?}"
        );
    }
}
