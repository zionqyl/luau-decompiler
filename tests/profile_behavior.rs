mod oracle;
use luau_decompiler::{decompile, Config};
use serde::Deserialize;
use serde_json::json;
use sha2::{Digest, Sha256};
use std::{collections::BTreeMap, fs, path::Path, process::Command};

#[derive(Deserialize)]
struct Manifest {
    fixtures: Vec<Fixture>,
}
#[derive(Deserialize)]
struct Fixture {
    profile: String,
    version: u8,
    upstream_tag: String,
    upstream_revision: String,
    compiler_sha256: String,
    compiler_flags: String,
    source: String,
    source_sha256: String,
    optimization: usize,
    debug: usize,
    bytecode: String,
    sha256: String,
}
fn digest(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}
fn compiler_directory(tag: &str) -> &'static str {
    match tag {
        "0.726" => "luau-0.726",
        "0.730" => "luau-0.730",
        "0.746" => "luau-modern",
        _ => panic!("unlocked compiler tag {tag}"),
    }
}

fn compiler_process_summary(
    output: &std::process::Output,
    expected_source: &str,
    actual_source: &str,
) -> serde_json::Value {
    let prefix = &output.stdout[..output.stdout.len().min(128)];
    let binary_error = output.stdout.first() == Some(&0);
    json!({"process_success":output.status.success(),"exit_code":output.status.code(),"exit_status":output.status.to_string(),"bytecode_success":output.status.success()&&output.stdout.first().is_some_and(|byte|*byte!=0),"stdout_bytes":output.stdout.len(),"stdout_sha256":digest(&output.stdout),"stdout_prefix_hex":prefix.iter().map(|byte|format!("{byte:02x}")).collect::<String>(),"binary_error_packet":binary_error,"stdout_error_preview":if binary_error{Some(String::from_utf8_lossy(&output.stdout[1..output.stdout.len().min(1025)]).into_owned())}else{None},"stderr_bytes":output.stderr.len(),"stderr_sha256":digest(&output.stderr),"stderr_preview":String::from_utf8_lossy(&output.stderr[..output.stderr.len().min(1024)]),"expected_source_sha256":expected_source,"actual_source_sha256":actual_source})
}

#[test]
fn compiler_binary_error_packet_retains_diagnostics_with_empty_stderr() {
    #[cfg(unix)]
    use std::os::unix::process::ExitStatusExt;
    #[cfg(windows)]
    use std::os::windows::process::ExitStatusExt;
    let output = std::process::Output {
        status: std::process::ExitStatus::from_raw(0),
        stdout: b"\0compile failed\xff".to_vec(),
        stderr: Vec::new(),
    };
    let summary = compiler_process_summary(&output, "expected", "actual");
    assert_eq!(summary["exit_code"], 0);
    assert_eq!(summary["process_success"], true);
    assert_eq!(summary["bytecode_success"], false);
    assert_eq!(summary["binary_error_packet"], true);
    assert_eq!(
        summary["stdout_prefix_hex"],
        "00636f6d70696c65206661696c6564ff"
    );
    assert_eq!(summary["stderr_bytes"], 0);
    assert_eq!(summary["actual_source_sha256"], "actual");
}

#[test]
#[ignore = "requires scripts/setup-profiles.ps1 -BuildOracle; mandatory release gate"]
fn modern_profiles_behavior() {
    run_matrix(false);
}

#[test]
#[ignore = "targeted compiler-backed capture regressions; full matrix remains mandatory"]
fn modern_capture_regressions() {
    run_matrix(true);
}

fn run_matrix(captures_only: bool) {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let fixtures = root.join("tests/profile-fixtures");
    let manifest: Manifest =
        serde_json::from_slice(&fs::read(fixtures.join("manifest.json")).unwrap()).unwrap();
    assert!(
        manifest.fixtures.len() >= 1872,
        "profile coverage must not shrink"
    );
    let artifacts = root.join(if captures_only {
        "artifacts/profile-capture-regressions"
    } else {
        "artifacts/profile-behavior"
    });
    fs::create_dir_all(&artifacts).unwrap();
    let mut hashes = BTreeMap::new();
    let mut oracle_hashes = BTreeMap::new();
    let mut results = Vec::new();
    let mut failures = Vec::new();
    for fixture in manifest.fixtures {
        if captures_only
            && fixture.source != "recursive.luau"
            && fixture.source != "generic_for.luau"
        {
            continue;
        }
        let directory = compiler_directory(&fixture.upstream_tag);
        let compiler = root.join(format!(
            ".tools/{directory}/luau-compile{}",
            std::env::consts::EXE_SUFFIX
        ));
        let runner = root.join(format!(
            ".tools/{directory}/vm-runner{}",
            std::env::consts::EXE_SUFFIX
        ));
        let compiler_hash = hashes
            .entry(directory)
            .or_insert_with(|| digest(&fs::read(&compiler).unwrap()));
        assert_eq!(*compiler_hash, fixture.compiler_sha256, "compiler hash");
        oracle_hashes.entry(directory).or_insert_with(|| {
            let stamp: serde_json::Value = serde_json::from_slice(
                &fs::read(format!("{}.manifest.json", runner.display())).unwrap(),
            )
            .unwrap();
            assert_eq!(stamp["protocol"], oracle::PROTOCOL);
            assert_eq!(stamp["upstream_revision"], fixture.upstream_revision);
            assert_eq!(
                stamp["harness_sha256"],
                digest(&fs::read(root.join("tests/vm_runner.cpp")).unwrap()),
                "stale typed VM harness; rebuild profiles"
            );
            let hash = digest(&fs::read(&runner).unwrap());
            assert_eq!(stamp["runner_sha256"], hash);
            hash
        });
        let source = root.join("tests/corpus").join(&fixture.source);
        assert_eq!(
            digest(&fs::read(source).unwrap()),
            fixture.source_sha256,
            "known-source hash"
        );
        let bytes = fs::read(fixtures.join(&fixture.bytecode)).unwrap();
        assert_eq!(digest(&bytes), fixture.sha256, "fixture hash");
        assert_eq!(bytes[0], fixture.version);
        let name = fixture.bytecode.replace('/', "_");
        let output_path = artifacts.join(format!("{name}.luau"));
        let original_path = artifacts.join(format!("{name}.original.bc"));
        let rebuilt_path = artifacts.join(format!("{name}.rebuilt.bc"));
        fs::write(&original_path, &bytes).unwrap();
        let original_output = Command::new(&runner).arg(&original_path).output().unwrap();
        assert!(
            original_output.status.success(),
            "oracle harness infrastructure failed"
        );
        let original = oracle::Observation::decode(&original_output.stdout).unwrap();
        let configuration = Config {
            profile: fixture.profile.clone(),
            ..Config::default()
        };
        let reconstructed = decompile(&bytes, &configuration);
        let result: Result<serde_json::Value, String> = (|| {
            let reconstructed = reconstructed.map_err(|error| error.to_string())?;
            fs::write(&output_path, &reconstructed.source).unwrap();
            let mut command = Command::new(&compiler);
            command
                .arg("--binary")
                .arg(format!("-O{}", fixture.optimization))
                .arg(format!("-g{}", fixture.debug));
            if !fixture.compiler_flags.is_empty() {
                command.arg(format!("--fflags={}", fixture.compiler_flags));
            }
            let compiled = command.arg(&output_path).output().unwrap();
            if !compiled.status.success() || compiled.stdout.first().is_none_or(|&byte| byte == 0) {
                let actual_source = fs::read(&output_path)
                    .map(|bytes| digest(&bytes))
                    .unwrap_or_else(|error| format!("unreadable:{error}"));
                let mut diagnostic = compiler_process_summary(
                    &compiled,
                    &digest(reconstructed.source.as_bytes()),
                    &actual_source,
                );
                let stdout_path = output_path.with_extension("compiler.stdout.bin");
                let stderr_path = output_path.with_extension("compiler.stderr.bin");
                let status_path = output_path.with_extension("compiler.status.json");
                let mut write_errors = Vec::new();
                for (path, bytes) in [
                    (&stdout_path, &compiled.stdout),
                    (&stderr_path, &compiled.stderr),
                ] {
                    if let Err(error) = fs::write(path, bytes) {
                        write_errors.push(format!("{}:{error}", path.display()));
                    }
                }
                diagnostic["artifact_write_errors"] = json!(write_errors);
                if let Err(error) = fs::write(
                    &status_path,
                    serde_json::to_vec_pretty(&diagnostic).unwrap(),
                ) {
                    diagnostic["status_write_error"] = json!(error.to_string());
                }
                return Err(format!("recompilation failed: {diagnostic}"));
            }
            if compiled.stdout[0] != fixture.version {
                return Err("recompiled format mismatch".into());
            }
            fs::write(&rebuilt_path, compiled.stdout).unwrap();
            let rebuilt_output = Command::new(&runner).arg(&rebuilt_path).output().unwrap();
            if !rebuilt_output.status.success() {
                return Err("rebuilt oracle harness infrastructure failed".into());
            }
            let rebuilt = oracle::Observation::decode(&rebuilt_output.stdout)?;
            if !original.equivalent(&rebuilt) {
                return Err(format!("typed observations differ or are incomplete: original={original:?}; rebuilt={rebuilt:?}"));
            }
            Ok(
                json!({ "source_sha256":digest(reconstructed.source.as_bytes()), "observation_sha256":digest(&original_output.stdout), "complete_observation":true, "output_quality":reconstructed.quality, "fallback_prototypes":reconstructed.fallback_prototypes, "assumptions":reconstructed.assumptions, "recovered_bindings":reconstructed.bindings.len() }),
            )
        })();
        match result {
            Ok(evidence) => results.push(json!({"fixture":fixture.bytecode,"profile":fixture.profile,"upstream_revision":fixture.upstream_revision,"verified":true,"evidence":evidence})),
            Err(error) => {
                failures.push(format!("{}: {error}", fixture.bytecode));
                results.push(json!({"fixture":fixture.bytecode,"profile":fixture.profile,"upstream_revision":fixture.upstream_revision,"verified":false,"diagnostic":error}));
            }
        }
    }
    let report = json!({"schema_version":1,"oracle_protocol":oracle::PROTOCOL,"compiler_hashes":hashes,"oracle_hashes":oracle_hashes,"fixtures":results.len(),"verified":results.len()-failures.len(),"failures":failures,"results":results});
    fs::create_dir_all(root.join("docs/results")).unwrap();
    fs::write(
        root.join(if captures_only {
            "docs/results/profile-capture-regressions.json"
        } else {
            "docs/results/profile-behavior.json"
        }),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    eprintln!(
        "modern profiles: {}/{} complete typed comparisons",
        results.len() - failures.len(),
        results.len()
    );
    assert!(failures.is_empty(), "{} of {} modern profile cases failed; see docs/results/profile-behavior.json. First failures: {:?}", failures.len(), results.len(), &failures[..failures.len().min(10)]);
}
