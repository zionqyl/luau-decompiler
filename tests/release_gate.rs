#[cfg(windows)]
#[test]
fn mandatory_gate_invalidates_stale_success_when_behavior_tests_are_missing() {
    use std::{
        fs,
        path::Path,
        process::Command,
        time::{SystemTime, UNIX_EPOCH},
    };
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let unique = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let isolated = root.join(format!(
        "artifacts/gate-negative-{}-{unique}",
        std::process::id()
    ));
    fs::create_dir_all(isolated.join("scripts")).unwrap();
    fs::create_dir_all(isolated.join("artifacts")).unwrap();
    fs::write(
        isolated.join("scripts/validate.ps1"),
        include_str!("../scripts/validate.ps1"),
    )
    .unwrap();
    fs::write(
        isolated.join("scripts/env.ps1"),
        "# Isolated negative gate: no toolchain or compiler should be invoked.\n",
    )
    .unwrap();
    fs::write(
        isolated.join("artifacts/release-gate.json"),
        br#"{"schema":2,"passed":true,"state":"old-success"}"#,
    )
    .unwrap();
    let output = Command::new("powershell.exe")
        .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-File"])
        .arg(isolated.join("scripts/validate.ps1"))
        .arg("-Release")
        .output()
        .unwrap();
    assert!(
        !output.status.success(),
        "a missing behavior test cannot produce a valid release gate"
    );
    let gate: serde_json::Value =
        serde_json::from_slice(&fs::read(isolated.join("artifacts/release-gate.json")).unwrap())
            .unwrap();
    assert_eq!(
        gate["passed"], false,
        "stale successful gate must be invalidated"
    );
    assert_eq!(gate["state"], "failed");
    assert!(gate["error"]
        .as_str()
        .unwrap()
        .contains("Required release-gate target is missing"));
}

#[cfg(windows)]
#[test]
fn mandatory_gate_invalidates_stale_success_when_package_manifest_is_unavailable_or_invalid() {
    use std::{
        fs,
        path::Path,
        process::Command,
        time::{SystemTime, UNIX_EPOCH},
    };
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let unique = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    for (case, manifest, expected) in [
        ("missing", None, "Cargo.toml is missing"),
        (
            "invalid",
            Some("[package]\nversion = \"not-a-version\"\n"),
            "Cargo.toml must declare a valid release package version",
        ),
    ] {
        let isolated = root.join(format!(
            "artifacts/gate-manifest-negative-{}-{unique}-{case}",
            std::process::id()
        ));
        fs::create_dir_all(isolated.join("scripts")).unwrap();
        fs::create_dir_all(isolated.join("artifacts")).unwrap();
        fs::create_dir_all(isolated.join("tests")).unwrap();
        fs::write(
            isolated.join("scripts/validate.ps1"),
            include_str!("../scripts/validate.ps1"),
        )
        .unwrap();
        for target in [
            "oracle_protocol",
            "oracle_runtime",
            "behavior",
            "reconstruction",
            "profile_behavior",
            "profiles",
            "applications",
            "generated_programs",
            "scale_behavior",
            "v3_semantics",
            "v3_repeated_entry",
            "types_v3_behavior",
            "quality_v3",
            "native_v3_model",
            "profile_hash_layout_v3",
        ] {
            fs::write(isolated.join(format!("tests/{target}.rs")), "").unwrap();
        }
        let requirements: serde_json::Value =
            serde_json::from_str(include_str!("release-requirements-rc.json")).unwrap();
        for target in requirements["mandatory_targets"].as_array().unwrap() {
            fs::write(
                isolated.join(format!("tests/{}.rs", target.as_str().unwrap())),
                "",
            )
            .unwrap();
        }
        if let Some(manifest) = manifest {
            fs::write(isolated.join("Cargo.toml"), manifest).unwrap();
        }
        fs::write(
            isolated.join("artifacts/release-gate.json"),
            br#"{"schema":3,"passed":true,"state":"old-success"}"#,
        )
        .unwrap();
        let output = Command::new("powershell.exe")
            .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-File"])
            .arg(isolated.join("scripts/validate.ps1"))
            .arg("-Release")
            .output()
            .unwrap();
        assert!(
            !output.status.success(),
            "invalid package must fail: {case}"
        );
        let gate: serde_json::Value = serde_json::from_slice(
            &fs::read(isolated.join("artifacts/release-gate.json")).unwrap(),
        )
        .unwrap();
        assert_eq!(gate["passed"], false, "stale success in {case}");
        assert_eq!(gate["state"], "failed");
        assert!(gate["error"].as_str().unwrap().contains(expected));
    }
}
