#![allow(dead_code)]
#[path = "../oracle/mod.rs"]
pub mod oracle;
use luau_decompiler::{decompile, Config};
use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::{
    fs,
    path::{Path, PathBuf},
    process::Command,
};

pub fn digest(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}

pub struct Toolset {
    pub profile: &'static str,
    pub compiler: PathBuf,
    pub runner: PathBuf,
    pub flags: &'static str,
    pub revision: String,
    pub compiler_hash: String,
    pub runner_hash: String,
}
impl Toolset {
    pub fn checked(root: &Path, version: u8) -> Self {
        let (profile, directory, flags, lock) = if version == 6 {
            let lock: Value =
                serde_json::from_slice(&fs::read(root.join("upstream.lock.json")).unwrap())
                    .unwrap();
            ("luau-v6", "luau", "", lock)
        } else {
            assert_eq!(version, 14);
            let lock: Value = serde_json::from_slice(
                &fs::read(root.join("upstream.profiles.lock.json")).unwrap(),
            )
            .unwrap();
            (
                "luau-v14",
                "luau-modern",
                "LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false",
                lock["profiles"]
                    .as_array()
                    .unwrap()
                    .iter()
                    .find(|entry| entry["tag"] == "0.746")
                    .unwrap()
                    .clone(),
            )
        };
        let compiler = root.join(format!(
            ".tools/{directory}/luau-compile{}",
            std::env::consts::EXE_SUFFIX
        ));
        let runner = if version == 6 {
            root.join(format!(".tools/vm-runner{}", std::env::consts::EXE_SUFFIX))
        } else {
            root.join(format!(
                ".tools/{directory}/vm-runner{}",
                std::env::consts::EXE_SUFFIX
            ))
        };
        let compiler_hash = digest(&fs::read(&compiler).unwrap());
        assert_eq!(
            compiler_hash,
            lock["windows_compiler_sha256"].as_str().unwrap(),
            "pinned compiler mismatch"
        );
        let stamp: Value = serde_json::from_slice(
            &fs::read(format!("{}.manifest.json", runner.display())).unwrap(),
        )
        .unwrap();
        let runner_hash = digest(&fs::read(&runner).unwrap());
        assert_eq!(stamp["protocol"], oracle::PROTOCOL);
        assert_eq!(stamp["runner_sha256"], runner_hash);
        assert_eq!(
            stamp["harness_sha256"],
            digest(&fs::read(root.join("tests/vm_runner.cpp")).unwrap()),
            "stale typed oracle"
        );
        assert_eq!(stamp["upstream_revision"], lock["revision"]);
        Self {
            profile,
            compiler,
            runner,
            flags,
            revision: lock["revision"].as_str().unwrap().into(),
            compiler_hash,
            runner_hash,
        }
    }
    pub fn compile(
        &self,
        path: &Path,
        optimization: usize,
        debug: usize,
    ) -> Result<Vec<u8>, String> {
        let mut command = Command::new(&self.compiler);
        command
            .arg("--binary")
            .arg(format!("-O{optimization}"))
            .arg(format!("-g{debug}"));
        if !self.flags.is_empty() {
            command.arg(format!("--fflags={}", self.flags));
        }
        let output = command
            .arg(path)
            .output()
            .map_err(|error| error.to_string())?;
        if !output.status.success() || output.stdout.first().is_none_or(|&byte| byte == 0) {
            return Err(format!(
                "compiler failed: {}",
                String::from_utf8_lossy(&output.stderr)
            ));
        }
        let expected = if self.profile == "luau-v6" { 6 } else { 14 };
        if output.stdout[0] != expected {
            return Err("compiler emitted unexpected format".into());
        }
        Ok(output.stdout)
    }
    pub fn observe(
        &self,
        bytecode: &[u8],
        directory: &Path,
        name: &str,
        arguments: &[oracle::Value],
    ) -> Result<oracle::Observation, String> {
        self.observe_with_probe(bytecode, directory, name, arguments, None)
    }
    pub fn observe_with_probe(
        &self,
        bytecode: &[u8],
        directory: &Path,
        name: &str,
        arguments: &[oracle::Value],
        probe: Option<&Path>,
    ) -> Result<oracle::Observation, String> {
        let bytecode_path = directory.join(format!("{name}.bc"));
        let argument_path = directory.join(format!("{name}.args"));
        fs::write(&bytecode_path, bytecode).map_err(|error| error.to_string())?;
        fs::write(&argument_path, oracle::encode_arguments(arguments)?)
            .map_err(|error| error.to_string())?;
        let mut command = Command::new(&self.runner);
        command.arg(bytecode_path).arg("--args").arg(argument_path);
        if let Some(probe) = probe {
            command.arg("--probe").arg(probe);
        }
        let output = command.output().map_err(|error| error.to_string())?;
        if !output.status.success() {
            return Err(format!(
                "oracle infrastructure failed: {}",
                String::from_utf8_lossy(&output.stderr)
            ));
        }
        oracle::Observation::decode(&output.stdout)
    }
    pub fn differential(
        &self,
        source: &Path,
        directory: &Path,
        optimization: usize,
        debug: usize,
        argument_sets: &[Vec<oracle::Value>],
    ) -> Result<Value, String> {
        self.differential_with_probes(source, directory, optimization, debug, argument_sets, None)
    }
    pub fn differential_with_probes(
        &self,
        source: &Path,
        directory: &Path,
        optimization: usize,
        debug: usize,
        argument_sets: &[Vec<oracle::Value>],
        probes: Option<&[Vec<u8>]>,
    ) -> Result<Value, String> {
        if probes.is_some_and(|probes| probes.len() != argument_sets.len()) {
            return Err("probe/input count mismatch".into());
        }
        fs::create_dir_all(directory).map_err(|error| error.to_string())?;
        let original = self.compile(source, optimization, debug)?;
        let config = Config {
            profile: self.profile.into(),
            ..Config::default()
        };
        let reconstructed = decompile(&original, &config).map_err(|error| error.to_string())?;
        let rebuilt_source = directory.join("reconstructed.luau");
        fs::write(&rebuilt_source, &reconstructed.source).map_err(|error| error.to_string())?;
        let rebuilt = self.compile(&rebuilt_source, optimization, debug)?;
        let mut observations = Vec::new();
        for (index, arguments) in argument_sets.iter().enumerate() {
            let probe = if let Some(probes) = probes {
                let path = directory.join(format!("trusted-probe-{index}.bc"));
                fs::write(&path, &probes[index]).map_err(|error| error.to_string())?;
                Some(path)
            } else {
                None
            };
            let expected = self.observe_with_probe(
                &original,
                directory,
                "original",
                arguments,
                probe.as_deref(),
            )?;
            if !expected.verified() || expected.outcome != oracle::Outcome::Return {
                return Err(format!("known-source application/probe failed or is incomplete for input {index}: {expected:?}"));
            }
            let actual = self.observe_with_probe(
                &rebuilt,
                directory,
                "rebuilt",
                arguments,
                probe.as_deref(),
            )?;
            if !expected.equivalent(&actual) {
                return Err(format!(
                    "typed mismatch for input {index}: expected={expected:?}; actual={actual:?}"
                ));
            }
            observations.push(json!({"input":arguments,"observation_sha256":digest(&expected.encode()?),"complete":true,"trusted_probe_sha256":probes.map(|probes|digest(&probes[index]))}));
        }
        Ok(json!({
            "profile":self.profile,"optimization":optimization,"debug":debug,
            "upstream_revision":self.revision,"compiler_sha256":self.compiler_hash,"oracle_sha256":self.runner_hash,
            "original_sha256":digest(&original),"reconstructed_source_sha256":digest(reconstructed.source.as_bytes()),
            "recompiled_sha256":digest(&rebuilt),"output_quality":reconstructed.quality,
            "fallback_prototypes":reconstructed.fallback_prototypes,"assumptions":reconstructed.assumptions,
            "typed_comparisons":argument_sets.len(),"observations":observations
        }))
    }
}
