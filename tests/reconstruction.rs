#[path = "oracle/mod.rs"]
mod oracle;
use luau_decompiler::{decompile, Config, ControlFlowMode};
use std::{
    fs,
    path::{Path, PathBuf},
    process::Command,
};

fn compiler() -> PathBuf {
    std::env::var_os("LUAU_COMPILE")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            Path::new(env!("CARGO_MANIFEST_DIR")).join(".tools/luau/luau-compile.exe")
        })
}
fn compile(path: &Path, optimization: usize, debug: usize) -> Vec<u8> {
    let output = Command::new(compiler())
        .arg("--binary")
        .arg(format!("-O{optimization}"))
        .arg(format!("-g{debug}"))
        .arg(path)
        .output()
        .unwrap();
    assert!(
        output.status.success() && output.stdout.first().is_some_and(|&b| b != 0),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    output.stdout
}
fn execute(
    bytes: &[u8],
    directory: &Path,
    name: &str,
    args: &[oracle::Value],
) -> oracle::Observation {
    let path = directory.join(format!("{name}.bc"));
    let arguments = directory.join(format!("{name}.args"));
    fs::write(&path, bytes).unwrap();
    fs::write(&arguments, oracle::encode_arguments(args).unwrap()).unwrap();
    let vm = std::env::var_os("LUAU_VM_RUNNER")
        .map(PathBuf::from)
        .unwrap_or_else(|| Path::new(env!("CARGO_MANIFEST_DIR")).join(".tools/vm-runner.exe"));
    let output = Command::new(vm)
        .arg(path)
        .arg("--args")
        .arg(arguments)
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    oracle::Observation::decode(&output.stdout).unwrap()
}

#[test]
#[ignore = "requires the pinned compiler and typed VM oracle; mandatory release gate"]
fn typed_dispatcher_and_binding_differential() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/reconstruction");
    fs::create_dir_all(&directory).unwrap();
    let mut comparisons = 0;
    for name in [
        "complex_loop_exits_v2",
        "binding_scopes_v2",
        "short_circuit",
        "methods",
        "close_scopes",
        "evaluation_order",
    ] {
        for optimization in 0..=2 {
            for debug in [0, 2] {
                let original = compile(
                    &root.join(format!("tests/corpus/{name}.luau")),
                    optimization,
                    debug,
                );
                for mode in [ControlFlowMode::Auto, ControlFlowMode::Dispatcher] {
                    let config = Config {
                        control_flow: mode,
                        ..Config::default()
                    };
                    let result = decompile(&original, &config).unwrap_or_else(|e| {
                        panic!("{name} O{optimization} D{debug} {mode:?}: {e}")
                    });
                    let source = directory.join("recompiled.luau");
                    fs::write(&source, &result.source).unwrap();
                    let recompiled = compile(&source, optimization, debug);
                    for seed in [-3.0, 0.0, 1.0, 7.0] {
                        let args = [oracle::Value::Number(f64::to_bits(seed))];
                        let expected = execute(&original, &directory, "original", &args);
                        let actual = execute(&recompiled, &directory, "actual", &args);
                        assert!(expected.equivalent(&actual),"{name} O{optimization} D{debug} {mode:?} seed{seed}:\n{expected:?}\n{actual:?}\n{}",result.source);
                        comparisons += 1;
                    }
                }
            }
        }
    }
    fs::write(
        directory.join("report.json"),
        serde_json::to_vec_pretty(&serde_json::json!({
            "schema":1,"oracle":"LOBS/1","complete":true,"typed_comparisons":comparisons,
            "sources":6,"optimization_levels":[0,1,2],"debug_levels":[0,2],
            "control_flow_modes":["auto","dispatcher"],"runtime_seeds":[-3,0,1,7]
        }))
        .unwrap(),
    )
    .unwrap();
}

#[test]
#[ignore = "requires the pinned compiler and typed VM oracle; mandatory release gate"]
fn typed_feature_differential() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/features");
    fs::create_dir_all(&directory).unwrap();
    let mut comparisons = 0;
    for name in [
        "branch_constructor",
        "thread_environment",
        "vector_constants",
        "native_captures",
        "dynamic_hash_keys",
        "nested_branch_join",
    ] {
        for optimization in 0..=2 {
            for debug in 0..=2 {
                let original = compile(
                    &root.join(format!("tests/semantic-corpus/{name}.luau")),
                    optimization,
                    debug,
                );
                let mut config = Config::default();
                if name == "vector_constants" {
                    config.vector_constructor = Some("vector.create".into());
                }
                let result = decompile(&original, &config)
                    .unwrap_or_else(|e| panic!("{name} O{optimization} D{debug}: {e}"));
                let source = directory.join("recompiled.luau");
                fs::write(&source, &result.source).unwrap();
                let recompiled = compile(&source, optimization, debug);
                for seed in [-3.0, 0.0, 1.0, 7.0] {
                    let args = [oracle::Value::Number(f64::to_bits(seed))];
                    let expected = execute(&original, &directory, "original", &args);
                    let actual = execute(&recompiled, &directory, "actual", &args);
                    assert!(
                        expected.equivalent(&actual),
                        "{name} O{optimization} D{debug} seed{seed}:\n{expected:?}\n{actual:?}\n{}",
                        result.source
                    );
                    comparisons += 1;
                }
            }
        }
    }
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&serde_json::json!({
        "schema":1,"oracle":"LOBS/1","complete":true,"typed_comparisons":comparisons,
        "sources":6,"optimization_levels":[0,1,2],"debug_levels":[0,1,2],"runtime_seeds":[-3,0,1,7],
        "assumptions":{"vector_constants":"trusted immutable vector.create with upstream three-component vector semantics"}
    })).unwrap()).unwrap();
}

#[test]
#[ignore = "requires the pinned compiler and typed VM oracle; mandatory release gate"]
fn typed_large_scope_capture_differential() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/scope-captures");
    fs::create_dir_all(&directory).unwrap();
    let mut source = String::from("local seed = ... or 1\nlocal callbacks = {}\n");
    for index in 1..=256 {
        source.push_str(&format!("do local value = seed + {index}; callbacks[{index}] = function(delta) value += delta; return value end end\n"));
    }
    source.push_str("local total = 0\nfor index = 1, 256 do total += callbacks[index](index); total += callbacks[index](1) end\nreturn total\n");
    let original_path = directory.join("original.luau");
    fs::write(&original_path, source).unwrap();
    let mut comparisons = 0;
    for optimization in [0, 2] {
        let original = compile(&original_path, optimization, 2);
        let result = decompile(&original, &Config::default()).unwrap();
        let output_path = directory.join("recompiled.luau");
        fs::write(&output_path, &result.source).unwrap();
        let recompiled = compile(&output_path, optimization, 2);
        for seed in [-3.0, 0.0, 1.0, 7.0] {
            let args = [oracle::Value::Number(f64::to_bits(seed))];
            let expected = execute(&original, &directory, "original", &args);
            let actual = execute(&recompiled, &directory, "actual", &args);
            assert!(
                expected.equivalent(&actual),
                "scope capture O{optimization} seed{seed}: {expected:?} / {actual:?}"
            );
            comparisons += 1;
        }
    }
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&serde_json::json!({"schema":1,"oracle":"LOBS/1","complete":true,"typed_comparisons":comparisons,"capturing_functions":256,"optimization_levels":[0,2],"debug":2,"runtime_seeds":[-3,0,1,7]})).unwrap()).unwrap();
}
