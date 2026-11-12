#[path = "oracle/mod.rs"]
mod oracle;
use oracle::{encode_arguments, Observation, Outcome, Value};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

fn tool(variable: &str, default: &str) -> PathBuf {
    std::env::var_os(variable)
        .map(PathBuf::from)
        .unwrap_or_else(|| Path::new(env!("CARGO_MANIFEST_DIR")).join(default))
}
fn compile(source: &str, name: &str, directory: &Path) -> PathBuf {
    let path = directory.join(format!("{name}.luau"));
    fs::write(&path, source).unwrap();
    let compiler = tool("LUAU_COMPILE", ".tools/luau/luau-compile.exe");
    let result = Command::new(compiler)
        .args(["--binary", "-O0", "-g0"])
        .arg(&path)
        .output()
        .unwrap();
    assert!(
        result.status.success(),
        "compiler diagnostic bytes {:?}",
        result.stderr
    );
    let bytecode = directory.join(format!("{name}.bc"));
    fs::write(&bytecode, result.stdout).unwrap();
    bytecode
}
fn execute(path: &Path, args: &[Value], probe: Option<&Path>) -> Observation {
    let argument_path = path.with_extension("args");
    fs::write(&argument_path, encode_arguments(args).unwrap()).unwrap();
    let runner = tool("LUAU_VM_RUNNER", ".tools/vm-runner.exe");
    let mut command = Command::new(runner);
    command.arg(path).arg("--args").arg(argument_path);
    if let Some(probe) = probe {
        command.arg("--probe").arg(probe);
    }
    let output = command.output().unwrap();
    assert!(
        output.status.success(),
        "runner diagnostic bytes {:?}",
        output.stderr
    );
    fs::write(path.with_extension("obs"), &output.stdout).unwrap();
    Observation::decode(&output.stdout).unwrap()
}

#[test]
#[ignore = "requires official compiler and typed runner; mandatory release gate"]
fn actual_vm_oracle_has_no_stringification_or_tuple_collisions() {
    let directory = Path::new(env!("CARGO_MANIFEST_DIR")).join("artifacts/oracle-conformance");
    fs::create_dir_all(&directory).unwrap();
    let pairs = [
        ("return 1", "return '1'"),
        ("return nil", "return 'nil'"),
        ("return 'a\\tb'", "return 'a', 'b'"),
        ("return '\\255'", "return '\\254'"),
        ("return '\\r\\n'", "return '\\n'"),
        ("return", "return nil"),
        ("print(1)", "print('1')"),
        ("print(nil)", "print('nil')"),
        ("print('a'); warn('b')", "warn('b'); print('a')"),
        ("error('nil', 0)", "error(nil, 0)"),
        ("error('bad\\000\\255', 0)", "error('bad\\000\\254', 0)"),
        (
            "local a=buffer.fromstring('x'); return a,a",
            "return buffer.fromstring('x'), buffer.fromstring('x')",
        ),
    ];
    for (index, (a, b)) in pairs.iter().enumerate() {
        let a = execute(&compile(a, &format!("a{index}"), &directory), &[], None);
        let b = execute(&compile(b, &format!("b{index}"), &directory), &[], None);
        assert!(
            a.verified() && b.verified(),
            "negative pair must be complete"
        );
        assert!(!a.equivalent(&b), "false positive in negative pair {index}");
    }
    let forward = compile("print(...); return ...", "forward", &directory);
    let input = vec![
        Value::Number((-0f64).to_bits()),
        Value::Number(0x7ff8_0000_0000_005a),
        Value::String(vec![0, 255, 254, 9, 13, 10]),
        Value::Nil,
    ];
    let observation = execute(&forward, &input, None);
    assert_eq!(observation.terminal, input);
    assert_eq!(observation.events[0].values, input);
    let opaque = execute(&compile("return {}", "opaque", &directory), &[], None);
    assert!(!opaque.verified());
    assert!(!opaque.equivalent(&opaque));
    let error = execute(
        &compile("error(false,0)", "error_bool", &directory),
        &[],
        None,
    );
    assert_eq!(error.outcome, Outcome::Error);
    assert_eq!(error.terminal, vec![Value::Boolean(false)]);
    let factory = compile(
        "return function(value) return value*2 end",
        "factory",
        &directory,
    );
    let probe = compile("local f=...; return f(3), f(7)", "probe", &directory);
    let observation = execute(&factory, &[], Some(&probe));
    assert!(observation.verified());
    assert_eq!(
        observation.terminal,
        vec![
            Value::Number(6f64.to_bits()),
            Value::Number(14f64.to_bits())
        ]
    );
    let empty = directory.join("empty.bc");
    fs::write(&empty, []).unwrap();
    let vm = tool("LUAU_VM_RUNNER", ".tools/vm-runner.exe");
    assert!(
        !Command::new(&vm)
            .arg(&empty)
            .output()
            .unwrap()
            .status
            .success(),
        "empty bytecode cannot be a successful observation"
    );
    assert!(
        !Command::new(&vm)
            .arg(&factory)
            .arg("--probe")
            .arg(&empty)
            .output()
            .unwrap()
            .status
            .success(),
        "an explicitly supplied empty probe cannot be silently skipped"
    );
    let report = serde_json::json!({"schema":1,"oracle_protocol":oracle::PROTOCOL,"negative_collision_pairs":pairs.len(),"negative_pairs_passed":pairs.len(),"raw_ieee_and_binary_argument_roundtrip":true,"opaque_observations_are_incomplete":true,"typed_error_false_preserved":true,"separate_probe_verified":true,"empty_inputs_and_probes_are_rejected":true});
    fs::write(
        directory.join("report.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
}
