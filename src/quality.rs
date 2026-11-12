use crate::platform::Instant;
use crate::{Config, Error, Result};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
#[cfg(not(target_arch = "wasm32"))]
use std::io::{Read, Write};
#[cfg(not(target_arch = "wasm32"))]
use std::path::{Path, PathBuf};
#[cfg(not(target_arch = "wasm32"))]
use std::process::{Child, ChildStdin, ChildStdout, Command, Stdio};
#[cfg(not(target_arch = "wasm32"))]
use std::sync::{
    atomic::{AtomicBool, AtomicUsize, Ordering},
    mpsc, Arc, Mutex, OnceLock,
};
use std::time::Duration;

pub const ANALYZER_REVISION: &str = "12a6ba75883272c79b66b59815efef4c574196f6";
pub const ROBLOX_DEFINITIONS_SHA256: &str =
    "d6d1e40a142fc3dcb1a70759256fb990d1110953dfd7eef667ff254b2e5b54af";

pub const ANALYZER_RESIDENT_BYTES: usize = 192 * 1024 * 1024;

#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum ValidationMode {
    Off,
    #[default]
    Check,
    StrictRequired,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct ProjectContext {
    pub entry: String,
    pub modules: BTreeMap<String, String>,
    pub requires: BTreeMap<String, String>,
    pub external_globals: BTreeMap<String, String>,
    pub instance_types: BTreeMap<String, String>,
}
impl Default for ProjectContext {
    fn default() -> Self {
        Self {
            entry: "main".into(),
            modules: BTreeMap::new(),
            requires: BTreeMap::new(),
            external_globals: BTreeMap::new(),
            instance_types: BTreeMap::new(),
        }
    }
}
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct ValidationConfig {
    pub mode: ValidationMode,
    pub analyzer_path: Option<String>,
    pub definitions_path: Option<String>,
    pub max_workers: usize,
    pub timeout_ms: u64,
    pub max_attempts: usize,
    pub max_cache_bytes: usize,
    pub project: ProjectContext,
}
impl Default for ValidationConfig {
    fn default() -> Self {
        Self {
            mode: ValidationMode::Check,
            analyzer_path: None,
            definitions_path: None,
            max_workers: 2,
            timeout_ms: 10_000,
            max_attempts: 3,
            max_cache_bytes: 16 * 1024 * 1024,
            project: ProjectContext::default(),
        }
    }
}
impl ValidationConfig {
    pub fn validate(&self) -> Result<()> {
        if !(1..=4).contains(&self.max_workers)
            || !(100..=120_000).contains(&self.timeout_ms)
            || !(1..=4).contains(&self.max_attempts)
            || self.max_cache_bytes > 64 * 1024 * 1024
        {
            return Err(Error::new(
                "config",
                "validation worker, deadline, attempt or cache bound is invalid",
            ));
        }
        if self.project.modules.len() > 256
            || self.project.requires.len() > 1024
            || self.project.external_globals.len() > 256
            || self.project.instance_types.len() > 1024
        {
            return Err(Error::new(
                "config",
                "validation project exceeds module/contract limits",
            ));
        }
        let bytes: usize = self
            .project
            .modules
            .iter()
            .chain(&self.project.requires)
            .chain(&self.project.external_globals)
            .chain(&self.project.instance_types)
            .map(|(k, v)| k.len() + v.len())
            .sum();
        if bytes > 8 * 1024 * 1024
            || self.project.entry.len() > 256
            || self.project.entry.is_empty()
        {
            return Err(Error::new(
                "config",
                "validation project exceeds byte/name limits",
            ));
        }
        Ok(())
    }
}
#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum GateStatus {
    Passed,
    Failed,
    #[default]
    NotRun,
    Unavailable,
}
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct QualityDiagnostic {
    pub category: String,
    pub message: String,
    pub module: String,
    pub line: usize,
    pub column: usize,
    pub end_line: usize,
    pub end_column: usize,
    pub proto: Option<usize>,
    pub pc: Option<usize>,
    pub binding: Option<String>,
    pub transformation: Option<String>,
    pub pc_start: Option<usize>,
    pub pc_end: Option<usize>,
    pub generated_node_id: Option<usize>,
    pub mapping_precision: String,
}
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ValidationAttempt {
    pub strategy: String,
    pub source_sha256: String,
    pub syntax: GateStatus,
    pub compilation: GateStatus,
    pub strict_analysis: GateStatus,
    pub diagnostic_count: usize,
    pub reason: String,
}
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct QualityReport {
    pub output_policy: crate::config::OutputPolicy,
    pub meaningful_typing: MeaningfulTypingReport,
    pub reconstruction_complete: bool,
    pub syntax: GateStatus,
    pub compilation: GateStatus,
    pub strict_analysis: GateStatus,
    pub required_passed: bool,
    pub diagnostics: Vec<QualityDiagnostic>,
    pub missing_dependencies: Vec<String>,
    pub external_globals: Vec<String>,
    pub external_assumptions: Vec<String>,
    pub explicit_any: usize,
    pub inferred_any: usize,
    pub inferred_unknown: usize,
    pub type_traversal_exhausted: bool,
    pub external_contract_any: usize,
    pub external_contract_unknown: usize,
    pub unmeasured_external_contracts: Vec<String>,
    pub type_assertions: usize,
    pub expressions_analyzed: usize,
    pub attempts: Vec<ValidationAttempt>,
    pub analyzer_revision: String,
    pub analyzer_sha256: Option<String>,
    pub definitions_sha256: Option<String>,
    pub context_sha256: String,
    pub elapsed_micros: u64,
    pub cache_hit: bool,
    pub behavioral_test_outcome: String,
    pub selected_strategy: String,
    pub compiler_micros: u64,
    pub analyzer_micros: u64,
    pub recovery_transform_failures: Vec<QualityDiagnostic>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct MeaningfulTypingReport {
    pub passed: bool,
    pub emitted_annotations: usize,
    pub useful_annotations: usize,
    pub runtime_annotations: usize,
    pub eligible_bindings: usize,
    pub annotated_bindings: usize,
    pub binding_coverage_percent: usize,
    pub useful_annotation_percent: usize,
    pub failures: Vec<String>,
}

pub fn meaningful_typing(
    types: &crate::types::TypeReport,
    quality: &QualityReport,
    config: &Config,
) -> MeaningfulTypingReport {
    let covered = types
        .annotated_bindings
        .saturating_add(types.annotated_parameters)
        .saturating_add(types.annotated_variadics);
    let eligible = types
        .emittable_bindings
        .saturating_add(types.emittable_variadics);
    let coverage = if eligible == 0 {
        100
    } else {
        covered
            .saturating_mul(100)
            .checked_div(eligible)
            .unwrap_or(0)
            .min(100)
    };
    let useful_percent = types
        .emitted_useful_annotations
        .saturating_mul(100)
        .checked_div(types.emitted_annotations)
        .unwrap_or(0)
        .min(100);
    let mut report = MeaningfulTypingReport {
        emitted_annotations: types.emitted_annotations,
        useful_annotations: types.emitted_useful_annotations,
        runtime_annotations: types.emitted_runtime_annotations,
        eligible_bindings: eligible,
        annotated_bindings: covered,
        binding_coverage_percent: coverage,
        useful_annotation_percent: useful_percent,
        ..MeaningfulTypingReport::default()
    };
    let limits = &config.meaningful_typing;
    for contract in &types.unapplied_external_contracts {
        report.failures.push(format!("supplied binding contract {contract} is not checked by the final source; retain its annotation or remove/change the supplied contract"));
    }
    if quality.type_traversal_exhausted {
        report.failures.push("bounded recursive type-quality traversal exhausted its budget; complete metrics are unavailable".into());
    }
    if report.runtime_annotations < limits.min_runtime_annotations {
        report.failures.push(format!("runtime binding/signature annotations {} are below required {}; unrelated aliases alone do not establish a typed interface", report.runtime_annotations, limits.min_runtime_annotations));
    }
    if types.emitted_useful_annotations < limits.min_useful_annotations {
        report.failures.push(format!(
            "useful annotations {} are below required {}",
            types.emitted_useful_annotations, limits.min_useful_annotations
        ));
    }
    if coverage < limits.min_binding_coverage_percent {
        report.failures.push(format!(
            "binding annotation coverage {coverage}% is below required {}%",
            limits.min_binding_coverage_percent
        ));
    }
    if useful_percent < limits.min_useful_annotation_percent {
        report.failures.push(format!(
            "useful annotation coverage {useful_percent}% is below required {}%",
            limits.min_useful_annotation_percent
        ));
    }
    let explicit_any = quality.explicit_any.max(types.emitted_explicit_any);
    if explicit_any > limits.max_explicit_any {
        report.failures.push(format!(
            "explicit any count {explicit_any} exceeds required maximum {}",
            limits.max_explicit_any
        ));
    }
    let inferred_any = quality.inferred_any.max(types.inferred_any);
    if inferred_any > limits.max_inferred_any {
        report.failures.push(format!(
            "inferred any count {} exceeds required maximum {}",
            inferred_any, limits.max_inferred_any
        ));
    }
    if quality.external_contract_any > limits.max_external_any {
        report.failures.push(format!(
            "supplied external contract any count {} exceeds required maximum {}",
            quality.external_contract_any, limits.max_external_any
        ));
    }
    if quality.external_contract_unknown > limits.max_external_unknown {
        report.failures.push(format!(
            "supplied external contract unknown count {} exceeds required maximum {}",
            quality.external_contract_unknown, limits.max_external_unknown
        ));
    }
    if quality.unmeasured_external_contracts.len() > limits.max_unmeasured_external_contracts {
        report.failures.push(format!(
            "{} external contracts cannot be measured by the bounded type parser",
            quality.unmeasured_external_contracts.len()
        ));
    }
    if quality.inferred_unknown > limits.max_inferred_unknown {
        report.failures.push(format!(
            "inferred unknown count {} exceeds required maximum {}",
            quality.inferred_unknown, limits.max_inferred_unknown
        ));
    }
    if quality.type_assertions > limits.max_type_assertions {
        report.failures.push(format!(
            "type assertion count {} exceeds required maximum {}",
            quality.type_assertions, limits.max_type_assertions
        ));
    }
    if quality.selected_strategy == "faithful_baseline" {
        report
            .failures
            .push("unannotated recovery is not verified typed output".into());
    }
    report.passed = report.failures.is_empty();
    report
}

fn digest(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}
#[cfg(not(target_arch = "wasm32"))]
type FileStamp = (u64, Option<std::time::SystemTime>, String);
#[cfg(not(target_arch = "wasm32"))]
static FILE_HASHES: OnceLock<Mutex<BTreeMap<PathBuf, FileStamp>>> = OnceLock::new();
#[cfg(not(target_arch = "wasm32"))]
fn file_hash(path: &Path) -> std::result::Result<String, String> {
    let metadata = std::fs::metadata(path).map_err(|e| e.to_string())?;
    let stamp = (metadata.len(), metadata.modified().ok());
    let hashes = FILE_HASHES.get_or_init(|| Mutex::new(BTreeMap::new()));
    if let Ok(cache) = hashes.lock() {
        if let Some((len, modified, hash)) = cache.get(path) {
            if *len == stamp.0 && *modified == stamp.1 {
                return Ok(hash.clone());
            }
        }
    }
    if metadata.len() > 64 * 1024 * 1024 {
        return Err("tool/definition file exceeds 64MiB".into());
    }
    let mut file = std::fs::File::open(path).map_err(|e| e.to_string())?;
    let mut state = Sha256::new();
    let mut chunk = [0u8; 8192];
    let mut total = 0;
    loop {
        let count = file.read(&mut chunk).map_err(|e| e.to_string())?;
        if count == 0 {
            break;
        }
        total += count;
        if total > 64 * 1024 * 1024 {
            return Err("tool/definition file grew beyond limit".into());
        }
        state.update(&chunk[..count]);
    }
    let hash = format!("{:x}", state.finalize());
    if let Ok(mut cache) = hashes.lock() {
        if cache.len() >= 32 {
            cache.pop_first();
        }
        cache.insert(path.to_owned(), (stamp.0, stamp.1, hash.clone()));
    }
    Ok(hash)
}
#[cfg(not(target_arch = "wasm32"))]
fn bounded_file(path: &Path, limit: usize) -> std::result::Result<Vec<u8>, String> {
    let mut bytes = Vec::new();
    let file = std::fs::File::open(path).map_err(|e| e.to_string())?;
    if file.metadata().map_err(|e| e.to_string())?.len() > limit as u64 {
        return Err("tool/definition file exceeds limit".into());
    }
    file.take(limit as u64 + 1)
        .read_to_end(&mut bytes)
        .map_err(|e| e.to_string())?;
    if bytes.len() > limit {
        return Err("tool/definition file exceeds limit".into());
    }
    Ok(bytes)
}
#[cfg(not(target_arch = "wasm32"))]
fn locations(config: &Config) -> (PathBuf, PathBuf) {
    let exe = std::env::current_exe().ok();
    let bin = exe.as_ref().and_then(|p| p.parent());
    let analyzer = config
        .validation
        .analyzer_path
        .as_ref()
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            let packaged = bin.map(|p| {
                p.join(if cfg!(windows) {
                    "luau-quality.exe"
                } else {
                    "luau-quality"
                })
            });
            packaged.filter(|p| p.is_file()).unwrap_or_else(|| {
                PathBuf::from(if cfg!(windows) {
                    ".tools/luau-quality.exe"
                } else {
                    ".tools/luau-quality"
                })
            })
        });
    let definitions = config
        .validation
        .definitions_path
        .as_ref()
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            let packaged = bin
                .and_then(|p| p.parent())
                .map(|p| p.join("definitions/roblox.d.luau"));
            packaged
                .filter(|p| p.is_file())
                .unwrap_or_else(|| PathBuf::from("definitions/roblox.d.luau"))
        });
    (analyzer, definitions)
}

#[cfg(not(target_arch = "wasm32"))]
pub fn context_fingerprint(config: &Config) -> String {
    let (analyzer, defs) = locations(config);
    let mut hash = Sha256::new();
    struct HashWriter<'a>(&'a mut Sha256);
    impl Write for HashWriter<'_> {
        fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
            self.0.update(bytes);
            Ok(bytes.len())
        }
        fn flush(&mut self) -> std::io::Result<()> {
            Ok(())
        }
    }
    hash.update(ANALYZER_REVISION.as_bytes());
    let _ = serde_json::to_writer(HashWriter(&mut hash), &config.validation);
    let _ = serde_json::to_writer(HashWriter(&mut hash), &config.typing.globals);
    if config.validation.mode != ValidationMode::Off {
        for path in [&analyzer, &defs] {
            hash.update(path.to_string_lossy().as_bytes());
            match file_hash(path) {
                Ok(value) => hash.update(value.as_bytes()),
                Err(error) => hash.update(format!("missing:{error}").as_bytes()),
            }
        }
    }
    format!("{:x}", hash.finalize())
}

#[cfg(not(target_arch = "wasm32"))]
fn checked_assets(config: &Config) -> std::result::Result<(String, String), String> {
    let (analyzer, definitions) = locations(config);
    let analyzer_hash = file_hash(&analyzer).map_err(|e| format!("analyzer: {e}"))?;
    let definitions_hash = file_hash(&definitions).map_err(|e| format!("definitions: {e}"))?;
    if config.validation.definitions_path.is_none() && definitions_hash != ROBLOX_DEFINITIONS_SHA256
    {
        return Err("pinned Roblox definition hash mismatch".into());
    }
    let manifest_path = PathBuf::from(format!("{}.manifest.json", analyzer.display()));
    let manifest: serde_json::Value =
        serde_json::from_slice(&bounded_file(&manifest_path, 64 * 1024)?)
            .map_err(|e| format!("analyzer provenance manifest: {e}"))?;
    if manifest["binary_sha256"].as_str() != Some(analyzer_hash.as_str())
        || manifest["upstream_revision"] != ANALYZER_REVISION
        || manifest["source_sha256"] != digest(include_bytes!("../tests/analyzer_runner.cpp"))
    {
        return Err("analyzer binary/source provenance mismatch; rebuild pinned analyzer".into());
    }
    Ok((analyzer_hash, definitions_hash))
}

pub fn validation_assets_ready(config: &Config) -> std::result::Result<(), String> {
    if config.validation.mode == ValidationMode::Off {
        return Ok(());
    }
    checked_assets(config).map(|_| ())
}

#[derive(Debug, Clone, Default, Deserialize)]
#[serde(deny_unknown_fields)]
struct WorkerResult {
    #[serde(default)]
    syntax: bool,
    #[serde(default)]
    compilation: bool,
    #[serde(default, rename = "strict")]
    strict_analysis: bool,
    #[serde(default)]
    diagnostics: Vec<QualityDiagnostic>,
    #[serde(default)]
    missing_dependencies: Vec<String>,
    #[serde(default)]
    external_globals: Vec<String>,
    #[serde(default)]
    explicit_any: usize,
    #[serde(default)]
    inferred_any: usize,
    #[serde(default)]
    inferred_unknown: usize,
    #[serde(default)]
    type_traversal_exhausted: bool,
    #[serde(default)]
    type_assertions: usize,
    #[serde(default)]
    expressions_analyzed: usize,
    #[serde(default)]
    compiler_micros: u64,
    #[serde(default)]
    analyzer_micros: u64,
}
#[cfg(not(target_arch = "wasm32"))]
struct WorkerIo {
    input: ChildStdin,
    output: ChildStdout,
    ready: bool,
}
#[cfg(not(target_arch = "wasm32"))]
struct AnalyzerWorker {
    key: String,
    busy: AtomicBool,
    broken: AtomicBool,
    child: Mutex<Child>,
    io: Mutex<WorkerIo>,
    _resident: Option<crate::execution::MemoryLease>,
}
#[cfg(not(target_arch = "wasm32"))]
impl Drop for AnalyzerWorker {
    fn drop(&mut self) {
        if let Ok(child) = self.child.get_mut() {
            let _ = child.kill();
            let _ = child.wait();
        }
    }
}
#[cfg(not(target_arch = "wasm32"))]
struct AnalyzerPool {
    workers: Vec<Arc<AnalyzerWorker>>,
}
#[cfg(not(target_arch = "wasm32"))]
static WORKERS: OnceLock<Mutex<AnalyzerPool>> = OnceLock::new();
#[cfg(not(target_arch = "wasm32"))]
struct CachedResult {
    key: String,
    value: WorkerResult,
    bytes: usize,
    _lease: Option<crate::execution::MemoryLease>,
}
#[derive(Default)]
#[cfg(not(target_arch = "wasm32"))]
struct ResultCache {
    entries: Vec<CachedResult>,
    bytes: usize,
}
#[cfg(not(target_arch = "wasm32"))]
static CACHE: OnceLock<Mutex<ResultCache>> = OnceLock::new();
#[cfg(not(target_arch = "wasm32"))]
static PENDING: AtomicUsize = AtomicUsize::new(0);
#[cfg(not(target_arch = "wasm32"))]
struct AnalyzerAdmission;
#[cfg(not(target_arch = "wasm32"))]
impl Drop for AnalyzerAdmission {
    fn drop(&mut self) {
        PENDING.fetch_sub(1, Ordering::AcqRel);
    }
}
#[cfg(not(target_arch = "wasm32"))]
fn frame_read(input: &mut impl Read) -> std::result::Result<Vec<u8>, String> {
    let mut h = [0; 4];
    input.read_exact(&mut h).map_err(|e| e.to_string())?;
    let n = u32::from_le_bytes(h) as usize;
    if n > 16 * 1024 * 1024 {
        return Err("analyzer frame exceeds 16MiB".into());
    }

    crate::execution::reserve_ast_capacity(n.saturating_mul(8).saturating_add(4096))
        .map_err(|e| e.to_string())?;
    let mut out = vec![0; n];
    input.read_exact(&mut out).map_err(|e| e.to_string())?;
    Ok(out)
}
#[cfg(not(target_arch = "wasm32"))]
fn result_bytes(value: &WorkerResult) -> usize {
    let diagnostics = value.diagnostics.capacity() * std::mem::size_of::<QualityDiagnostic>();
    let strings = value
        .diagnostics
        .iter()
        .map(|d| {
            d.category.capacity()
                + d.message.capacity()
                + d.module.capacity()
                + d.mapping_precision.capacity()
                + d.binding.as_ref().map_or(0, String::capacity)
                + d.transformation.as_ref().map_or(0, String::capacity)
        })
        .sum::<usize>();
    let lists = value.missing_dependencies.capacity() * std::mem::size_of::<String>()
        + value.external_globals.capacity() * std::mem::size_of::<String>();
    std::mem::size_of::<CachedResult>()
        + diagnostics
        + strings
        + lists
        + value
            .missing_dependencies
            .iter()
            .chain(&value.external_globals)
            .map(String::capacity)
            .sum::<usize>()
        + 256
}

const MAX_ANALYZER_REQUEST_BYTES: usize = 16 * 1024 * 1024;

fn external_contracts(config: &Config) -> impl Iterator<Item = (&String, &String)> {
    let mut typing = config.typing.globals.iter().peekable();
    let mut project = config.validation.project.external_globals.iter().peekable();
    std::iter::from_fn(move || {
        let ordering = match (typing.peek(), project.peek()) {
            (Some((left, _)), Some((right, _))) => left.cmp(right),
            (Some(_), None) => std::cmp::Ordering::Less,
            (None, Some(_)) => std::cmp::Ordering::Greater,
            (None, None) => return None,
        };
        match ordering {
            std::cmp::Ordering::Less => typing.next(),
            std::cmp::Ordering::Greater => project.next(),
            std::cmp::Ordering::Equal => {
                project.next();
                typing.next()
            }
        }
    })
}

#[derive(Clone, Copy, Debug)]
struct RequestPlan {
    wire_bytes: usize,
    declaration_bytes: usize,
    max_contract_bytes: usize,
}
fn add_request_bytes(total: &mut usize, amount: usize) -> std::result::Result<(), String> {
    *total = total
        .checked_add(amount)
        .filter(|size| *size <= MAX_ANALYZER_REQUEST_BYTES)
        .ok_or("analyzer request exceeds 16MiB")?;
    Ok(())
}
fn add_field_bytes(total: &mut usize, bytes: usize) -> std::result::Result<(), String> {
    add_request_bytes(total, 4)?;
    add_request_bytes(total, bytes)
}
fn request_plan(source: &str, config: &Config) -> std::result::Result<RequestPlan, String> {
    let project = &config.validation.project;
    let mut wire_bytes = 0;
    add_field_bytes(&mut wire_bytes, "LQRY/1".len())?;
    add_field_bytes(&mut wire_bytes, project.entry.len())?;
    add_field_bytes(&mut wire_bytes, source.len())?;
    for (name, ty) in &project.external_globals {
        if config.typing.globals.get(name).is_some_and(|old| old != ty) {
            return Err(format!(
                "conflicting external type contracts for {name:.128}"
            ));
        }
    }
    let mut declaration_bytes = 0;
    let mut max_contract_bytes = 0;
    for (name, ty) in external_contracts(config).chain(project.instance_types.iter()) {
        if ty.len() > 16384 {
            return Err("external/instance type contract exceeds 16384 bytes".into());
        }

        add_request_bytes(&mut declaration_bytes, 11)?;
        add_request_bytes(&mut declaration_bytes, name.len())?;
        add_request_bytes(&mut declaration_bytes, ty.len())?;
        max_contract_bytes = max_contract_bytes.max(ty.len());
    }
    add_field_bytes(&mut wire_bytes, declaration_bytes)?;

    add_request_bytes(&mut wire_bytes, 12)?;
    u32::try_from(project.modules.len()).map_err(|_| "wire module count overflow")?;
    u32::try_from(project.requires.len()).map_err(|_| "wire require count overflow")?;
    for (name, source) in &project.modules {
        if name == &project.entry {
            return Err("project modules must not overwrite the recovered entry".into());
        }
        add_field_bytes(&mut wire_bytes, name.len())?;
        add_field_bytes(&mut wire_bytes, source.len())?;
    }
    for (expression, name) in &project.requires {
        add_field_bytes(&mut wire_bytes, expression.len())?;
        add_field_bytes(&mut wire_bytes, name.len())?;
    }
    Ok(RequestPlan {
        wire_bytes,
        declaration_bytes,
        max_contract_bytes,
    })
}

struct RequestWriter {
    bytes: Vec<u8>,
    limit: usize,
}
impl RequestWriter {
    fn new(limit: usize) -> std::result::Result<Self, String> {
        let mut bytes = Vec::new();
        bytes
            .try_reserve_exact(limit)
            .map_err(|_| "analyzer request allocation failed")?;
        Ok(Self { bytes, limit })
    }
    fn raw(&mut self, bytes: &[u8]) -> std::result::Result<(), String> {
        if bytes.len() > self.limit.saturating_sub(self.bytes.len()) {
            return Err("analyzer request exceeded its validated layout".into());
        }
        self.bytes.extend_from_slice(bytes);
        Ok(())
    }
    fn u32(&mut self, value: usize) -> std::result::Result<(), String> {
        let value: u32 = value.try_into().map_err(|_| "wire count overflow")?;
        self.raw(&value.to_le_bytes())
    }
    fn field(&mut self, value: &str) -> std::result::Result<(), String> {
        self.u32(value.len())?;
        self.raw(value.as_bytes())
    }
}

struct AnalyzerRequest {
    data: Vec<u8>,
    memory: Option<crate::execution::MemoryLease>,
}
fn request(source: &str, config: &Config) -> std::result::Result<AnalyzerRequest, String> {
    let plan = request_plan(source, config)?;
    let memory = crate::execution::reserve_auxiliary(plan.wire_bytes.saturating_mul(33))
        .map_err(|e| e.to_string())?;

    let scratch = if plan.max_contract_bytes == 0 {
        None
    } else {
        crate::execution::reserve_auxiliary(plan.max_contract_bytes.saturating_mul(128))
            .map_err(|e| e.to_string())?
    };
    let project = &config.validation.project;
    for (name, ty) in external_contracts(config) {
        if !crate::names::is_identifier(name) {
            return Err(format!("external global {name:?} is not an identifier"));
        }
        crate::type_ast::parse_type(ty).map_err(|e| format!("external type contract: {e}"))?;
    }

    for (name, ty) in &project.instance_types {
        if !crate::names::is_identifier(name) {
            return Err(format!("instance contract {name:?} requires a declared project root type; arbitrary children are not assumed"));
        }
        crate::type_ast::parse_type(ty).map_err(|e| format!("instance type contract: {e}"))?;
    }
    drop(scratch);
    let mut data = RequestWriter::new(plan.wire_bytes)?;
    data.field("LQRY/1")?;
    data.field(&project.entry)?;
    data.field(source)?;
    data.u32(plan.declaration_bytes)?;
    for (name, ty) in external_contracts(config).chain(project.instance_types.iter()) {
        data.raw(b"declare ")?;
        data.raw(name.as_bytes())?;
        data.raw(b": ")?;
        data.raw(ty.as_bytes())?;
        data.raw(b"\n")?;
    }
    data.u32(config.validation.timeout_ms as usize)?;
    data.u32(project.modules.len())?;
    for (k, v) in &project.modules {
        data.field(k)?;
        data.field(v)?;
    }
    data.u32(project.requires.len())?;
    for (k, v) in &project.requires {
        data.field(k)?;
        data.field(v)?;
    }
    if data.bytes.len() != plan.wire_bytes {
        return Err("analyzer request did not match its validated layout".into());
    }
    Ok(AnalyzerRequest {
        data: data.bytes,
        memory,
    })
}
#[cfg(not(target_arch = "wasm32"))]
fn obtain_worker(key: &str, config: &Config) -> std::result::Result<Arc<AnalyzerWorker>, String> {
    let mut state = WORKERS
        .get_or_init(|| {
            Mutex::new(AnalyzerPool {
                workers: Vec::new(),
            })
        })
        .lock()
        .map_err(|_| "analyzer pool poisoned")?;
    state
        .workers
        .retain(|w| !w.broken.load(Ordering::Acquire) || w.busy.load(Ordering::Acquire));
    if let Some(worker) = state
        .workers
        .iter()
        .find(|w| w.key == key && !w.busy.swap(true, Ordering::AcqRel))
    {
        return Ok(worker.clone());
    }
    let same = state.workers.iter().filter(|w| w.key == key).count();
    if same >= config.validation.max_workers {
        return Err("all bounded analyzer workers are busy".into());
    }
    if state.workers.len() >= 4 {
        if let Some(index) = state
            .workers
            .iter()
            .position(|w| !w.busy.load(Ordering::Acquire))
        {
            state.workers.remove(index);
        } else {
            return Err("global analyzer pool is saturated".into());
        }
    }
    let (analyzer, defs) = locations(config);
    let resident =
        crate::execution::reserve_auxiliary(ANALYZER_RESIDENT_BYTES).map_err(|e| e.to_string())?;
    let mut child = Command::new(analyzer)
        .arg(defs)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|e| e.to_string())?;
    let input = child.stdin.take().ok_or("analyzer stdin unavailable")?;
    let output = child.stdout.take().ok_or("analyzer stdout unavailable")?;
    let worker = Arc::new(AnalyzerWorker {
        key: key.into(),
        busy: AtomicBool::new(true),
        broken: AtomicBool::new(false),
        child: Mutex::new(child),
        io: Mutex::new(WorkerIo {
            input,
            output,
            ready: false,
        }),
        _resident: resident,
    });
    state.workers.push(worker.clone());
    Ok(worker)
}
#[cfg(not(target_arch = "wasm32"))]
fn analyze(
    source: &str,
    config: &Config,
    context: &str,
    deadline: Instant,
) -> std::result::Result<(WorkerResult, bool), String> {
    crate::execution::checkpoint().map_err(|e| e.to_string())?;
    if Instant::now() >= deadline {
        return Err("shared validation-phase deadline exceeded".into());
    }
    let budget = crate::execution::current_memory_budget()
        .map(|p| Arc::as_ptr(&p) as usize)
        .unwrap_or(0);
    let mut hash = Sha256::new();
    hash.update(context);
    hash.update(source);
    hash.update(budget.to_le_bytes());
    let key = format!("{:x}", hash.finalize());
    if let Ok(cache) = CACHE
        .get_or_init(|| Mutex::new(ResultCache::default()))
        .lock()
    {
        if let Some(entry) = cache.entries.iter().find(|entry| entry.key == key) {
            crate::execution::reserve_ast_capacity(entry.bytes).map_err(|e| e.to_string())?;
            return Ok((entry.value.clone(), true));
        }
    }
    let mut pending = PENDING.load(Ordering::Acquire);
    loop {
        if pending >= 16 {
            return Err("bounded analyzer request queue is full".into());
        }
        match PENDING.compare_exchange_weak(
            pending,
            pending + 1,
            Ordering::AcqRel,
            Ordering::Acquire,
        ) {
            Ok(_) => break,
            Err(actual) => pending = actual,
        }
    }
    let _admission = AnalyzerAdmission;
    let AnalyzerRequest {
        data,
        memory: _request_memory,
    } = request(source, config)?;
    let domain = format!("{context}/{budget}");
    let worker = loop {
        match obtain_worker(&domain, config) {
            Ok(worker) => break worker,
            Err(error) if error.contains("busy") || error.contains("saturated") => {
                crate::execution::checkpoint().map_err(|e| e.to_string())?;
                if Instant::now() >= deadline {
                    return Err("analyzer queue deadline exceeded".into());
                }
                std::thread::sleep(Duration::from_millis(5));
            }
            Err(error) => return Err(error),
        }
    };
    let reader = worker.clone();
    let (tx, rx) = mpsc::sync_channel(1);
    let execution = crate::execution::current_context();
    std::thread::spawn(move || {
        let _request_memory = _request_memory;
        let _admission = _admission;
        let operation = || {
            let mut io = reader
                .io
                .lock()
                .map_err(|_| "analyzer I/O poisoned".to_owned())?;
            if !io.ready {
                let ready: serde_json::Value = serde_json::from_slice(&frame_read(&mut io.output)?)
                    .map_err(|e| e.to_string())?;
                if ready["ready"] != true {
                    return Err(format!(
                        "analyzer definition initialization failed: {ready}"
                    ));
                }
                io.ready = true;
            }
            io.input
                .write_all(&(data.len() as u32).to_le_bytes())
                .and_then(|_| io.input.write_all(&data))
                .and_then(|_| io.input.flush())
                .map_err(|e| e.to_string())?;
            serde_json::from_slice::<WorkerResult>(&frame_read(&mut io.output)?)
                .map_err(|e| e.to_string())
        };
        let result = if let Some(context) = execution {
            crate::execution::with_context(context, operation)
        } else {
            operation()
        };
        if result.is_err() {
            reader.broken.store(true, Ordering::Release);
        }
        reader.busy.store(false, Ordering::Release);
        let _ = tx.send(result);
    });
    let result = loop {
        match rx.recv_timeout(Duration::from_millis(5)) {
            Ok(result) => break result,
            Err(mpsc::RecvTimeoutError::Disconnected) => {
                break Err("analyzer worker disconnected".into())
            }
            Err(mpsc::RecvTimeoutError::Timeout) => {}
        }
        if let Err(error) = crate::execution::checkpoint() {
            worker.broken.store(true, Ordering::Release);
            if let Ok(mut child) = worker.child.lock() {
                let _ = child.kill();
            }
            return Err(error.to_string());
        }
        if Instant::now() >= deadline {
            worker.broken.store(true, Ordering::Release);
            if let Ok(mut child) = worker.child.lock() {
                let _ = child.kill();
            }
            return Err("analyzer request deadline exceeded".into());
        }
    }?;
    let bytes = result_bytes(&result).saturating_add(key.capacity());
    if bytes <= config.validation.max_cache_bytes {
        if let Ok(mut cache) = CACHE.get().unwrap().lock() {
            while (cache.bytes + bytes > config.validation.max_cache_bytes
                || cache.entries.len() >= 128)
                && !cache.entries.is_empty()
            {
                let entry = cache.entries.remove(0);
                cache.bytes -= entry.bytes;
            }
            if let Ok(lease) = crate::execution::reserve_auxiliary(bytes) {
                cache.bytes += bytes;
                cache.entries.push(CachedResult {
                    key,
                    value: result.clone(),
                    bytes,
                    _lease: lease,
                });
            }
        }
    }
    Ok((result, false))
}

#[cfg(target_arch = "wasm32")]
#[derive(serde::Deserialize)]
struct BrowserAssets {
    schema: u32,
    engine_version: String,
    analyzer_sha256: String,
    definitions_sha256: String,
    source_sha256: String,
    upstream_revision: String,
}

#[cfg(target_arch = "wasm32")]
fn browser_assets() -> std::result::Result<BrowserAssets, String> {
    let encoded = crate::wasm_api::validation_assets()?;
    if encoded.len() > 8192 {
        return Err("browser validation asset descriptor exceeds limit".into());
    }
    let assets: BrowserAssets =
        serde_json::from_str(&encoded).map_err(|e| format!("browser validation assets: {e}"))?;
    if assets.schema != 1
        || assets.engine_version != env!("CARGO_PKG_VERSION")
        || assets.upstream_revision != ANALYZER_REVISION
        || assets.source_sha256 != digest(include_bytes!("../tests/analyzer_runner.cpp"))
        || assets.analyzer_sha256.len() != 64
        || !assets
            .analyzer_sha256
            .bytes()
            .all(|b| b.is_ascii_hexdigit())
        || assets.definitions_sha256.len() != 64
        || !assets
            .definitions_sha256
            .bytes()
            .all(|b| b.is_ascii_hexdigit())
    {
        return Err(
            "browser engine/analyzer/schema provenance mismatch; reload matching static assets"
                .into(),
        );
    }
    Ok(assets)
}

#[cfg(target_arch = "wasm32")]
fn checked_assets(config: &Config) -> std::result::Result<(String, String), String> {
    if config.validation.analyzer_path.is_some() {
        return Err("browser validation cannot invoke filesystem analyzer executables".into());
    }
    let assets = browser_assets()?;
    if config.validation.definitions_path.is_none()
        && assets.definitions_sha256 != ROBLOX_DEFINITIONS_SHA256
    {
        return Err("pinned browser Roblox definitions hash mismatch".into());
    }
    if config
        .validation
        .definitions_path
        .as_deref()
        .is_some_and(|p| p != "memory:custom")
    {
        return Err(
            "browser definition overrides require an explicit in-memory definition document".into(),
        );
    }
    Ok((assets.analyzer_sha256, assets.definitions_sha256))
}

#[cfg(target_arch = "wasm32")]
pub fn context_fingerprint(config: &Config) -> String {
    let mut hash = Sha256::new();
    hash.update(ANALYZER_REVISION);
    hash.update(env!("CARGO_PKG_VERSION"));
    if let Ok(bytes) = serde_json::to_vec(&config.validation) {
        hash.update(bytes);
    }
    if let Ok(bytes) = serde_json::to_vec(&config.typing.globals) {
        hash.update(bytes);
    }
    if let Ok(assets) = browser_assets() {
        hash.update(assets.analyzer_sha256);
        hash.update(assets.definitions_sha256);
    }
    format!("{:x}", hash.finalize())
}

#[cfg(target_arch = "wasm32")]
fn analyze(
    source: &str,
    config: &Config,
    _context: &str,
    deadline: Instant,
) -> std::result::Result<(WorkerResult, bool), String> {
    crate::execution::checkpoint().map_err(|e| e.to_string())?;
    if Instant::now() >= deadline {
        return Err("shared validation-phase deadline exceeded".into());
    }
    let AnalyzerRequest {
        data,
        memory: _memory,
    } = request(source, config)?;
    let result = crate::wasm_api::analyze_frame(&data)?;
    if result.len() > 16 * 1024 * 1024 {
        return Err("browser analyzer result exceeds16MiB".into());
    }
    crate::execution::reserve_ast_capacity(result.len().saturating_mul(8))
        .map_err(|e| e.to_string())?;
    crate::execution::checkpoint().map_err(|e| e.to_string())?;
    if Instant::now() >= deadline {
        return Err("shared validation-phase deadline exceeded".into());
    }
    let result: WorkerResult =
        serde_json::from_str(&result).map_err(|e| format!("browser analyzer response: {e}"))?;
    Ok((result, false))
}

pub fn validate_reconstruction(
    reconstruction: &mut crate::structure::Reconstruction,
    _module: &crate::bytecode::Module,
    config: &Config,
) -> Result<QualityReport> {
    validate_document(reconstruction, config, false)
}

pub fn validate_source(
    source: &mut String,
    baseline: &mut Option<String>,
    type_report: &mut crate::types::TypeReport,
    config: &Config,
) -> Result<QualityReport> {
    config.validate()?;
    let config = config.effective();
    let mut reconstruction = crate::structure::Reconstruction {
        source: std::mem::take(source),
        baseline_source: baseline.take(),
        metadata_source: None,
        type_report: std::mem::take(type_report),
        source_map: Vec::new(),
        baseline_source_map: Vec::new(),
        metadata_source_map: Vec::new(),
        baseline_format_micros: 0,
        constructor_transformations: Vec::new(),
        closure_scope: crate::structure::ClosureScopeReport {
            requested: config.closures.entry_invocation,
            compiler_sharing_contract: false,
            restrictions: Vec::new(),
            assumptions: Vec::new(),
        },
        body: Vec::new(),
        body_origin: 0,
        fallback_prototypes: Vec::new(),
        recovered_bindings: Vec::new(),
    };
    let result = validate_document(&mut reconstruction, &config, true);
    *source = reconstruction.source;
    *baseline = reconstruction.baseline_source;
    *type_report = reconstruction.type_report;
    result
}

fn validate_document(
    reconstruction: &mut crate::structure::Reconstruction,
    config: &Config,
    source_input: bool,
) -> Result<QualityReport> {
    crate::attribution::finalize(
        &mut reconstruction.source,
        &mut reconstruction.source_map,
        config.limits.max_output_bytes,
    )?;
    if let Some(source) = &mut reconstruction.baseline_source {
        crate::attribution::finalize(
            source,
            &mut reconstruction.baseline_source_map,
            config.limits.max_output_bytes,
        )?;
    }
    if let Some(source) = &mut reconstruction.metadata_source {
        crate::attribution::finalize(
            source,
            &mut reconstruction.metadata_source_map,
            config.limits.max_output_bytes,
        )?;
    }
    let start = Instant::now();
    let deadline = (start + Duration::from_millis(config.validation.timeout_ms)).min(
        crate::execution::current_context()
            .and_then(|c| c.deadline)
            .unwrap_or(start + Duration::from_millis(config.validation.timeout_ms)),
    );
    let context = context_fingerprint(config);
    let mut report = QualityReport {
        output_policy: config.output_policy,
        reconstruction_complete: true,
        required_passed: config.validation.mode != ValidationMode::StrictRequired
            && config.output_policy != crate::config::OutputPolicy::VerifiedTyped,
        analyzer_revision: ANALYZER_REVISION.into(),
        context_sha256: context.clone(),
        behavioral_test_outcome: "not_run; independent controlled differential tests are separate"
            .into(),
        selected_strategy: "annotated".into(),
        ..QualityReport::default()
    };
    if config.typing.mode == crate::types::TypingMode::Off
        || (reconstruction.baseline_source.is_none()
            && !reconstruction.type_report.optional_failures.is_empty())
    {
        report.selected_strategy = if source_input {
            "faithful_source"
        } else {
            "faithful_baseline"
        }
        .into();
    }
    for (name, ty) in config
        .typing
        .binding_types
        .iter()
        .chain(&config.typing.globals)
        .chain(&config.validation.project.external_globals)
        .chain(&config.validation.project.instance_types)
    {
        report
            .external_assumptions
            .push(format!("external contract {name}: {ty}"));
        match crate::type_ast::parse_type(ty) {
            Ok(ty) => {
                let metrics = ty.metrics();
                report.external_contract_any = report
                    .external_contract_any
                    .saturating_add(metrics.explicit_any);
                report.external_contract_unknown = report
                    .external_contract_unknown
                    .saturating_add(metrics.unknown);
            }
            Err(_) => report.unmeasured_external_contracts.push(name.clone()),
        }
    }
    if let Some(hash) = &reconstruction.type_report.api_definition_sha256 {
        report.external_assumptions.push(format!("static Roblox API definition snapshot {hash}; runtime/project availability is an external contract"));
    }
    for failure in &reconstruction.type_report.optional_failures {
        report.recovery_transform_failures.push(QualityDiagnostic {
            category: failure.stage.clone(),
            message: failure.message.clone(),
            proto: failure.proto,
            pc: failure.pc,
            transformation: Some("optional_presentation_rollback".into()),
            ..QualityDiagnostic::default()
        });
    }
    if config.validation.mode == ValidationMode::Off {
        apply_output_policy(&mut report, &reconstruction.type_report, config);
        return Ok(report);
    }
    match checked_assets(config) {
        Ok((analyzer, definitions)) => {
            report.analyzer_sha256 = Some(analyzer);
            report.definitions_sha256 = Some(definitions);
        }
        Err(message) => {
            report.syntax = GateStatus::Unavailable;
            report.compilation = GateStatus::Unavailable;
            report.strict_analysis = GateStatus::Unavailable;
            report.diagnostics.push(QualityDiagnostic {
                category: "environment".into(),
                message,
                ..QualityDiagnostic::default()
            });
            apply_output_policy(&mut report, &reconstruction.type_report, config);
            report.elapsed_micros = start.elapsed().as_micros().min(u64::MAX as u128) as u64;
            return Ok(report);
        }
    }
    let initial_strategy = match report.selected_strategy.as_str() {
        "faithful_source" => "faithful_source",
        "faithful_baseline" => "faithful_baseline",
        _ => "annotated",
    };
    #[derive(Clone, Copy, PartialEq, Eq)]
    enum Candidate {
        Initial,
        Metadata,
        Baseline,
    }
    let mut selected_candidate = Candidate::Initial;
    let mut candidates = vec![(
        initial_strategy,
        reconstruction.source.as_str(),
        Candidate::Initial,
    )];
    if let Some(metadata) = &reconstruction.metadata_source {
        if metadata != &reconstruction.source {
            candidates.push(("metadata_only", metadata.as_str(), Candidate::Metadata));
        }
    }
    if let Some(baseline) = &reconstruction.baseline_source {
        if baseline != &reconstruction.source {
            candidates.push((
                if source_input {
                    "original_source"
                } else {
                    "faithful_baseline"
                },
                baseline.as_str(),
                Candidate::Baseline,
            ));
        }
    }
    for (strategy, source, candidate) in candidates.into_iter().take(config.validation.max_attempts)
    {
        crate::execution::checkpoint()?;
        crate::execution::charge_work(source.len().div_ceil(16))?;
        if Instant::now() >= deadline {
            report.diagnostics.push(QualityDiagnostic {
                category: "deadline".into(),
                message: "shared validation-phase deadline exhausted before next recovery attempt"
                    .into(),
                ..QualityDiagnostic::default()
            });
            break;
        }
        match analyze(source, config, &context, deadline) {
            Ok((result, hit)) => {
                if !hit {
                    report.compiler_micros = report
                        .compiler_micros
                        .saturating_add(result.compiler_micros);
                    report.analyzer_micros = report
                        .analyzer_micros
                        .saturating_add(result.analyzer_micros);
                }
                let status = |b| {
                    if b {
                        GateStatus::Passed
                    } else {
                        GateStatus::Failed
                    }
                };
                report.attempts.push(ValidationAttempt{strategy:strategy.into(),source_sha256:digest(source.as_bytes()),syntax:status(result.syntax),compilation:status(result.compilation),strict_analysis:status(result.strict_analysis),diagnostic_count:result.diagnostics.len(),reason:if strategy=="annotated"{"validate actual formatted output".into()}else{"roll back optional annotation/presentation transformations; preserve runtime expressions".into()}});
                let choose = report.attempts.len() == 1
                    || (result.syntax
                        && result.compilation
                        && (result.strict_analysis
                            || report.syntax != GateStatus::Passed
                            || report.compilation != GateStatus::Passed));
                if choose {
                    report.syntax = status(result.syntax);
                    report.compilation = status(result.compilation);
                    report.strict_analysis = status(result.strict_analysis);
                    report.diagnostics = result.diagnostics;
                    report.missing_dependencies = result.missing_dependencies;
                    report.external_globals = result.external_globals;
                    report.explicit_any = result.explicit_any;
                    report.inferred_any = result.inferred_any;
                    report.inferred_unknown = result.inferred_unknown;
                    report.type_traversal_exhausted = result.type_traversal_exhausted;
                    report.type_assertions = result.type_assertions;
                    report.expressions_analyzed = result.expressions_analyzed;
                    report.cache_hit = hit;
                    report.selected_strategy = strategy.into();
                    selected_candidate = candidate;
                }
                if report.strict_analysis == GateStatus::Passed {
                    break;
                }
            }
            Err(error) => {
                crate::execution::checkpoint()?;
                report.attempts.push(ValidationAttempt {
                    strategy: strategy.into(),
                    source_sha256: digest(source.as_bytes()),
                    syntax: GateStatus::Unavailable,
                    compilation: GateStatus::Unavailable,
                    strict_analysis: GateStatus::Unavailable,
                    diagnostic_count: 1,
                    reason: error.clone(),
                });
                report.diagnostics.push(QualityDiagnostic {
                    category: "analyzer".into(),
                    message: error,
                    ..QualityDiagnostic::default()
                });
                if report.attempts.len() == 1 {
                    report.syntax = GateStatus::Unavailable;
                    report.compilation = GateStatus::Unavailable;
                    report.strict_analysis = GateStatus::Unavailable;
                }
                break;
            }
        }
    }
    if selected_candidate == Candidate::Baseline {
        if let Some(source) = reconstruction.baseline_source.take() {
            reconstruction.source = source;
        }
        reconstruction.source_map = std::mem::take(&mut reconstruction.baseline_source_map);
        reconstruction.type_report.emitted_annotations = 0;
        reconstruction.type_report.emitted_runtime_annotations = 0;
        reconstruction.type_report.annotated_bindings = 0;
        reconstruction.type_report.annotated_parameters = 0;
        reconstruction.type_report.annotated_returns = 0;
        reconstruction.type_report.annotated_variadics = 0;
        reconstruction.type_report.emitted_useful_annotations = 0;
        reconstruction.type_report.emitted_explicit_any = 0;
        reconstruction.type_report.unapplied_external_contracts =
            config.typing.binding_types.keys().cloned().collect();
    } else if selected_candidate == Candidate::Metadata {
        if let Some(source) = reconstruction.metadata_source.take() {
            reconstruction.source = source;
        }
        reconstruction.source_map = std::mem::take(&mut reconstruction.metadata_source_map);
        reconstruction.type_report.emitted_annotations =
            reconstruction.type_report.metadata_emitted_annotations;
        reconstruction.type_report.emitted_runtime_annotations = reconstruction
            .type_report
            .metadata_emitted_runtime_annotations;
        reconstruction.type_report.annotated_bindings =
            reconstruction.type_report.metadata_annotated_bindings;
        reconstruction.type_report.annotated_parameters =
            reconstruction.type_report.metadata_annotated_parameters;
        reconstruction.type_report.annotated_returns =
            reconstruction.type_report.metadata_annotated_returns;
        reconstruction.type_report.annotated_variadics =
            reconstruction.type_report.metadata_annotated_variadics;
        reconstruction.type_report.emitted_useful_annotations = reconstruction
            .type_report
            .metadata_emitted_useful_annotations;
        reconstruction.type_report.emitted_explicit_any =
            reconstruction.type_report.metadata_emitted_explicit_any;
    }
    let region_index = if report.diagnostics.is_empty() {
        None
    } else {
        Some(RegionIndex::new(&reconstruction.source_map)?)
    };
    for diagnostic in &mut report.diagnostics {
        if diagnostic.module != config.validation.project.entry {
            continue;
        }
        if let Some(region) = region_index
            .as_ref()
            .and_then(|index| index.find(diagnostic.line, diagnostic.column))
        {
            diagnostic.proto = region.proto;
            diagnostic.pc_start = region.first_pc;
            diagnostic.pc_end = region.last_pc;
            diagnostic.pc = region
                .first_pc
                .filter(|_| region.first_pc == region.last_pc);
            diagnostic.generated_node_id = Some(region.node_id);
            diagnostic.mapping_precision = if diagnostic.pc.is_some() {
                "instruction"
            } else if region.binding.is_some() {
                "binding_interval"
            } else {
                "generated_node_function"
            }
            .into();
            diagnostic.binding = region.binding.clone();
            diagnostic.transformation = region.transformations.last().cloned();
        }
    }
    apply_output_policy(&mut report, &reconstruction.type_report, config);
    report.elapsed_micros = start.elapsed().as_micros().min(u64::MAX as u128) as u64;
    Ok(report)
}

pub fn apply_output_policy(
    report: &mut QualityReport,
    types: &crate::types::TypeReport,
    config: &Config,
) {
    report.diagnostics.retain(|d| {
        d.category != "meaningful_typing" && d.category != "unapplied_external_contract"
    });
    for contract in &types.unapplied_external_contracts {
        report.diagnostics.push(QualityDiagnostic {
            category: "unapplied_external_contract".into(),
            message: format!("supplied binding contract {contract} is not checked by the final source; faithful output is retained for inspection"),
            binding: Some(contract.clone()),
            ..QualityDiagnostic::default()
        });
    }
    report.meaningful_typing = meaningful_typing(types, report, config);
    if config.output_policy == crate::config::OutputPolicy::VerifiedTyped
        && !report.meaningful_typing.passed
    {
        for failure in &report.meaningful_typing.failures {
            report.diagnostics.push(QualityDiagnostic {
                category: "meaningful_typing".into(),
                message: failure.clone(),
                ..QualityDiagnostic::default()
            });
        }
    }
    report.required_passed = config.validation.mode != ValidationMode::StrictRequired
        || (report.syntax == GateStatus::Passed
            && report.compilation == GateStatus::Passed
            && report.strict_analysis == GateStatus::Passed
            && types.unapplied_external_contracts.is_empty());
    if config.output_policy == crate::config::OutputPolicy::VerifiedTyped {
        report.required_passed = report.meaningful_typing.passed
            && report.syntax == GateStatus::Passed
            && report.compilation == GateStatus::Passed
            && report.strict_analysis == GateStatus::Passed;
    }
}

struct RegionIndex<'a> {
    regions: Vec<(usize, &'a crate::types::GeneratedRegion)>,
    ends: Vec<(usize, usize)>,
    leaves: usize,
}

impl<'a> RegionIndex<'a> {
    fn new(regions: &'a [crate::types::GeneratedRegion]) -> Result<Self> {
        let leaves = regions.len().max(1).next_power_of_two();
        crate::execution::reserve_ast_capacity(
            regions
                .len()
                .saturating_mul(std::mem::size_of::<(usize, &crate::types::GeneratedRegion)>())
                .saturating_add(
                    leaves
                        .saturating_mul(2)
                        .saturating_mul(std::mem::size_of::<(usize, usize)>()),
                ),
        )?;
        let mut sorted: Vec<_> = regions.iter().enumerate().collect();
        sorted.sort_unstable_by_key(|(original, region)| {
            (region.first_line, region.first_column, *original)
        });
        let mut ends = vec![(0, 0); leaves * 2];
        for (index, (_, region)) in sorted.iter().enumerate() {
            ends[leaves + index] = (region.last_line, region.last_column);
        }
        for index in (1..leaves).rev() {
            ends[index] = ends[index * 2].max(ends[index * 2 + 1]);
        }
        Ok(Self {
            regions: sorted,
            ends,
            leaves,
        })
    }

    fn find(&self, line: usize, column: usize) -> Option<&'a crate::types::GeneratedRegion> {
        let point = (line, column);
        let upper = self
            .regions
            .partition_point(|(_, region)| (region.first_line, region.first_column) <= point);
        let mut best = None;
        self.search(1, 0, self.leaves, upper, point, &mut best);
        best.map(|(_, region)| region)
    }

    fn search(
        &self,
        node: usize,
        start: usize,
        end: usize,
        upper: usize,
        point: (usize, usize),
        best: &mut Option<(usize, &'a crate::types::GeneratedRegion)>,
    ) {
        if start >= upper || self.ends[node] < point {
            return;
        }
        if end - start == 1 {
            if let Some(&(original, region)) = self.regions.get(start) {
                let score = |r: &crate::types::GeneratedRegion| {
                    (
                        r.last_line.saturating_sub(r.first_line),
                        if r.last_line == r.first_line {
                            r.last_column.saturating_sub(r.first_column)
                        } else {
                            usize::MAX
                        },
                    )
                };
                if best.is_none_or(|(old_index, old)| {
                    (score(region), original) < (score(old), old_index)
                }) {
                    *best = Some((original, region));
                }
            }
            return;
        }
        let middle = start + (end - start) / 2;
        self.search(node * 2, start, middle, upper, point, best);
        self.search(node * 2 + 1, middle, end, upper, point, best);
    }
}

#[cfg(test)]
mod resource_tests {
    use super::*;
    use std::alloc::{GlobalAlloc, Layout, System};
    use std::cell::Cell;

    #[test]
    fn recovery_attempts_use_the_supplied_phase_deadline() {
        let mut config = Config::default();
        let expired = Instant::now() - Duration::from_millis(1);
        for timeout in [100, 120_000] {
            config.validation.timeout_ms = timeout;
            let error = analyze("return 1", &config, "deadline-regression", expired).unwrap_err();
            assert_eq!(error, "shared validation-phase deadline exceeded");
        }
    }

    #[test]
    fn region_index_keeps_nested_binding_and_tie_locations() {
        let regions = [
            crate::types::GeneratedRegion {
                first_line: 1,
                last_line: 100,
                first_column: 1,
                last_column: 8,
                ..Default::default()
            },
            crate::types::GeneratedRegion {
                first_line: 20,
                last_line: 20,
                first_column: 2,
                last_column: 30,
                node_id: 1,
                ..Default::default()
            },
            crate::types::GeneratedRegion {
                first_line: 20,
                last_line: 20,
                first_column: 4,
                last_column: 10,
                node_id: 2,
                binding: Some("p0:b1".into()),
                ..Default::default()
            },
            crate::types::GeneratedRegion {
                first_line: 20,
                last_line: 20,
                first_column: 4,
                last_column: 10,
                node_id: 3,
                ..Default::default()
            },
        ];
        let index = RegionIndex::new(&regions).unwrap();
        assert_eq!(index.find(20, 4).unwrap().node_id, 2);
        assert_eq!(index.find(20, 10).unwrap().node_id, 2);
        assert_eq!(index.find(20, 11).unwrap().node_id, 1);
        assert_eq!(index.find(99, 99).unwrap().node_id, 0);
        assert!(index.find(101, 1).is_none());
        assert!(RegionIndex::new(&[]).unwrap().find(1, 1).is_none());
    }

    thread_local! {
        static OBSERVE_LARGE_ALLOCATIONS:Cell<bool> = const {Cell::new(false)};
        static LARGE_ALLOCATIONS:Cell<usize> = const {Cell::new(0)};
    }
    struct AllocationObserver;
    fn observe_allocation(bytes: usize) {
        if bytes >= 4096 {
            let _ = OBSERVE_LARGE_ALLOCATIONS.try_with(|enabled| {
                if enabled.get() {
                    let _ = LARGE_ALLOCATIONS.try_with(|count| count.set(count.get() + 1));
                }
            });
        }
    }

    unsafe impl GlobalAlloc for AllocationObserver {
        unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
            observe_allocation(layout.size());
            unsafe { System.alloc(layout) }
        }
        unsafe fn alloc_zeroed(&self, layout: Layout) -> *mut u8 {
            observe_allocation(layout.size());
            unsafe { System.alloc_zeroed(layout) }
        }
        unsafe fn dealloc(&self, pointer: *mut u8, layout: Layout) {
            unsafe { System.dealloc(pointer, layout) }
        }
        unsafe fn realloc(&self, pointer: *mut u8, layout: Layout, size: usize) -> *mut u8 {
            observe_allocation(size);
            unsafe { System.realloc(pointer, layout, size) }
        }
    }
    #[global_allocator]
    static ALLOCATION_OBSERVER: AllocationObserver = AllocationObserver;
    fn counted_large_allocations<T>(work: impl FnOnce() -> T) -> (T, usize) {
        struct Restore(bool);
        impl Drop for Restore {
            fn drop(&mut self) {
                OBSERVE_LARGE_ALLOCATIONS.with(|enabled| enabled.set(self.0));
            }
        }
        LARGE_ALLOCATIONS.with(|count| count.set(0));
        let _restore = Restore(OBSERVE_LARGE_ALLOCATIONS.with(|enabled| enabled.replace(true)));
        let result = work();
        (result, LARGE_ALLOCATIONS.with(Cell::get))
    }

    #[test]
    fn analyzer_request_rejections_precede_payload_and_contract_allocations() {
        use crate::execution::{with_context, CancellationToken, ExecutionContext, MemoryBudget};

        let source = " ".repeat(8192);
        let oversized = " ".repeat(MAX_ANALYZER_REQUEST_BYTES);
        let mut config = Config::default();
        config
            .typing
            .globals
            .insert("broken".into(), "not a valid type contract!".into());
        let budget = MemoryBudget::new(70 * 1024);
        let context = ExecutionContext::new(CancellationToken::new(), None)
            .with_memory(budget.clone())
            .unwrap();
        with_context(context, || {
            let (result, allocations) = counted_large_allocations(|| request(&source, &config));
            let error = match result {
                Ok(_) => panic!("request unexpectedly admitted"),
                Err(error) => error,
            };
            assert!(
                error.contains("memory"),
                "budget rejection must precede type parsing: {error}"
            );
            assert_eq!(
                allocations, 0,
                "request copied a payload before budget admission"
            );
            assert_eq!(budget.used(), 64 * 1024);
            let (result, allocations) =
                counted_large_allocations(|| request(&oversized, &Config::default()));
            let error = match result {
                Ok(_) => panic!("oversized request admitted"),
                Err(error) => error,
            };
            assert!(
                error.contains("16MiB"),
                "size preflight must precede admission/allocation: {error}"
            );
            assert_eq!(allocations, 0, "oversized request allocated a payload copy");
            assert_eq!(budget.used(), 64 * 1024);
        });
        assert_eq!(budget.used(), 0);
    }

    #[test]
    fn analyzer_request_preserves_exact_wire_layout_and_lease_lifetime() {
        use crate::execution::{with_context, CancellationToken, ExecutionContext, MemoryBudget};
        let mut config = Config::default();
        config
            .typing
            .globals
            .insert("zebra".into(), "number".into());
        config
            .typing
            .globals
            .insert("alpha".into(), "string".into());
        config
            .validation
            .project
            .external_globals
            .insert("middle".into(), "boolean".into());
        config
            .validation
            .project
            .external_globals
            .insert("zebra".into(), "number".into());
        config
            .validation
            .project
            .instance_types
            .insert("root".into(), "Model".into());
        config
            .validation
            .project
            .modules
            .insert("dependency".into(), "return 2".into());
        config
            .validation
            .project
            .requires
            .insert("\"dependency\"".into(), "dependency".into());
        let budget = MemoryBudget::new(512 * 1024);
        let context = ExecutionContext::new(CancellationToken::new(), None)
            .with_memory(budget.clone())
            .unwrap();
        with_context(context, || {
            let source = "return 1";
            let plan = request_plan(source, &config).unwrap();
            let request = match request(source, &config) {
                Ok(request) => request,
                Err(error) => panic!("{error}"),
            };
            assert_eq!(request.data.len(), plan.wire_bytes);
            assert_eq!(budget.used(), 64 * 1024 + plan.wire_bytes * 33);
            let mut position = 0;
            let mut field = || {
                let n = u32::from_le_bytes(request.data[position..position + 4].try_into().unwrap())
                    as usize;
                position += 4;
                let text = std::str::from_utf8(&request.data[position..position + n]).unwrap();
                position += n;
                text
            };
            assert_eq!(field(), "LQRY/1");
            assert_eq!(field(), "main");
            assert_eq!(field(), source);
            assert_eq!(field(),"declare alpha: string\ndeclare middle: boolean\ndeclare zebra: number\ndeclare root: Model\n");
            drop(request);
            assert_eq!(budget.used(), 64 * 1024);
        });
        assert_eq!(budget.used(), 0);
    }

    #[test]
    fn analyzer_frames_are_admitted_before_payload_read_and_released_with_scope() {
        use crate::execution::{with_context, CancellationToken, ExecutionContext, MemoryBudget};
        let budget = MemoryBudget::new(70 * 1024);
        let context = ExecutionContext::new(CancellationToken::new(), None)
            .with_memory(budget.clone())
            .unwrap();
        with_context(context, || {
            let error = frame_read(&mut &1024u32.to_le_bytes()[..]).unwrap_err();
            assert!(error.contains("memory"), "{error}");
            assert_eq!(budget.used(), 64 * 1024);
        });
        assert_eq!(budget.used(), 0);
        let mut oversized = &(16 * 1024 * 1024u32 + 1).to_le_bytes()[..];
        assert!(frame_read(&mut oversized).unwrap_err().contains("16MiB"));
    }
}
