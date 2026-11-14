mod service;

use luau_decompiler::{
    runtime::{DecompilePool, StreamOptions},
    Config,
};
use rayon::prelude::*;
use serde_json::json;
use sha2::{Digest, Sha256};
use std::fs::{self, File, OpenOptions};
use std::io::{self, Read, Write};
use std::path::{Path, PathBuf};
use std::time::{Duration, Instant};

const MAX_CORPUS_BYTES: usize = 256 * 1024 * 1024;
const MAX_CORPUS_FILES: usize = 4096;

const HELP: &str = concat!("luau-decompile ", env!("CARGO_PKG_VERSION"), "

Usage:
  luau-decompile capabilities
  luau-decompile doctor [--json] [--config CONFIG]
  luau-decompile decompile INPUT [-o OUTPUT] [--threads N] [--config CONFIG] [--stats] [--force]
                      [--strict-required | --no-validation] [--project CONTEXT.json]
                      [--quality-report REPORT.json]
                      [--input-format auto|luau-bytecode|luau-source|lua-source]
                      [--policy faithful|annotated|verified-typed]
                      [--entry-output script|function]
                      [--naming roblox|snake_case|camelCase|PascalCase] [--module-name NAME]
  luau-decompile batch --out-dir DIR [--threads N] [--window N] [--manifest FILE.json]
                      [--batch-input-mib N] [--batch-output-mib N] [--batch-report FILE.json]
                      [--config CONFIG] [--force] INPUT...
  luau-decompile serve [--listen 127.0.0.1:7879] [--workers N] [--queue N]
                      [--cpu-threads N] [--memory-mib N] [--timeout-ms N]
                      [--cache-mib N] [--token-env NAME] [--config CONFIG]
                      [--allow-remote]
  luau-decompile benchmark [--threads 1,2,4] [--iterations N] [--warmup N]
                          [-o REPORT.json] [--manifest FILE.json] [--config CONFIG] [--force] INPUT...

INPUT or OUTPUT '-' selects stdin or stdout for the decompile command.
Single-script decompilation defaults to one thread; --threads accepts 1..64.
Files are never overwritten unless --force is supplied. Config is JSON.
The bridge requires a 32..256 byte printable token in LUAU_DECOMPILER_TOKEN.
Benchmark latency measures complete per-script decompilation; input file I/O is excluded.
Each batch is limited to 4096 files; input and output windows have separate byte budgets.
Warm benchmarks preload at most 256 MiB of bytecode; their process memory is measured separately.
");

struct Args {
    command: String,
    config: Option<PathBuf>,
    output: Option<PathBuf>,
    output_dir: Option<PathBuf>,
    threads: String,
    iterations: usize,
    warmup: usize,
    stats: bool,
    force: bool,
    listen: String,
    workers: usize,
    queue: usize,
    timeout_ms: u64,
    cache_mib: usize,
    memory_mib: usize,
    cpu_threads: usize,
    token_env: String,
    inputs: Vec<PathBuf>,
    manifest: Option<PathBuf>,
    batch_window: usize,
    batch_input_mib: usize,
    batch_output_mib: usize,
    batch_report: Option<PathBuf>,
    strict_required: bool,
    no_validation: bool,
    quality_report: Option<PathBuf>,
    project: Option<PathBuf>,
    input_format: Option<luau_decompiler::input::InputFormat>,
    output_policy: Option<luau_decompiler::OutputPolicy>,
    entry_output: Option<luau_decompiler::EntryOutput>,
    naming: Option<luau_decompiler::NameStyle>,
    module_name: Option<String>,
    allow_remote: bool,
    json: bool,
}

fn parse(args: impl IntoIterator<Item = String>) -> Result<Args, String> {
    let mut args = args.into_iter();
    let command = args.next().unwrap_or_else(|| "help".into());
    let default_threads = std::thread::available_parallelism()
        .map(|n| n.get())
        .unwrap_or(1)
        .min(8);
    let default_thread_spec = if command == "benchmark" {
        "1,2,4".into()
    } else if command == "decompile" {
        "1".into()
    } else {
        default_threads.to_string()
    };
    let mut result = Args {
        command,
        config: None,
        output: None,
        output_dir: None,
        threads: default_thread_spec,
        iterations: 5,
        warmup: 1,
        stats: false,
        force: false,
        listen: "127.0.0.1:7879".into(),
        workers: default_threads,
        queue: 32,
        timeout_ms: 10000,
        cache_mib: 32,
        memory_mib: 1024,
        cpu_threads: default_threads,
        token_env: "LUAU_DECOMPILER_TOKEN".into(),
        inputs: Vec::new(),
        manifest: None,
        batch_window: 8,
        batch_input_mib: 64,
        batch_output_mib: 128,
        batch_report: None,
        strict_required: false,
        no_validation: false,
        quality_report: None,
        project: None,
        input_format: None,
        output_policy: None,
        entry_output: None,
        naming: None,
        module_name: None,
        allow_remote: false,
        json: false,
    };
    let mut positional = false;
    while let Some(arg) = args.next() {
        if positional {
            result.inputs.push(arg.into());
            continue;
        }
        if arg == "--" {
            positional = true;
            continue;
        }
        if arg == "-" || !arg.starts_with('-') {
            result.inputs.push(arg.into());
            continue;
        }
        if arg == "--help" || arg == "-h" {
            result.command = "help".into();
            continue;
        }
        let allowed = match arg.as_str() {
            "--config" => true,
            "--json" => result.command == "doctor",
            "--input-format" | "--policy" | "--entry-output" | "--naming" | "--module-name" => true,
            "--allow-remote" => result.command == "serve",
            "--strict-required" | "--no-validation" | "--project" => true,
            "--quality-report" => result.command == "decompile",
            "--stats" => matches!(result.command.as_str(), "decompile" | "batch"),
            "--force" => matches!(result.command.as_str(), "decompile" | "batch" | "benchmark"),
            "-o" | "--output" => matches!(result.command.as_str(), "decompile" | "benchmark"),
            "--out-dir" => result.command == "batch",
            "--batch-report" => result.command == "batch",
            "--window" | "--batch-input-mib" | "--batch-output-mib" => result.command == "batch",
            "--manifest" => matches!(result.command.as_str(), "batch" | "benchmark"),
            "--threads" => matches!(result.command.as_str(), "decompile" | "batch" | "benchmark"),
            "--iterations" | "--warmup" => result.command == "benchmark",
            "--listen" | "--workers" | "--queue" | "--timeout-ms" | "--cache-mib"
            | "--memory-mib" | "--cpu-threads" | "--token-env" => result.command == "serve",
            _ => return Err(format!("unknown option {arg}")),
        };
        if !allowed {
            return Err(format!(
                "option {arg} is not supported by {}",
                result.command
            ));
        }
        if arg == "--stats" {
            result.stats = true;
            continue;
        }
        if arg == "--json" {
            result.json = true;
            continue;
        }
        if arg == "--allow-remote" {
            result.allow_remote = true;
            continue;
        }
        if arg == "--strict-required" {
            result.strict_required = true;
            continue;
        }
        if arg == "--no-validation" {
            result.no_validation = true;
            continue;
        }
        if arg == "--force" {
            result.force = true;
            continue;
        }
        let value = args
            .next()
            .ok_or_else(|| format!("option {arg} requires a value"))?;
        match arg.as_str() {
            "--config" => result.config = Some(value.into()),
            "--naming" => {
                result.naming = Some(match value.as_str() {
                    "roblox" => luau_decompiler::NameStyle::Roblox,
                    "snake_case" => luau_decompiler::NameStyle::SnakeCase,
                    "camelCase" => luau_decompiler::NameStyle::CamelCase,
                    "PascalCase" => luau_decompiler::NameStyle::PascalCase,
                    _ => {
                        return Err(
                            "--naming expects roblox, snake_case, camelCase or PascalCase".into(),
                        )
                    }
                })
            }
            "--module-name" => result.module_name = Some(value),
            "--input-format" => {
                result.input_format = Some(match value.as_str() {
                    "auto" => luau_decompiler::input::InputFormat::Auto,
                    "luau-bytecode" | "luau_bytecode" => {
                        luau_decompiler::input::InputFormat::LuauBytecode
                    }
                    "luau-source" | "luau_source" => {
                        luau_decompiler::input::InputFormat::LuauSource
                    }
                    "lua-source" | "lua_source" => luau_decompiler::input::InputFormat::LuaSource,
                    _ => {
                        return Err(
                            "--input-format expects auto, luau-bytecode, luau-source or lua-source"
                                .into(),
                        )
                    }
                })
            }
            "--policy" => {
                result.output_policy = Some(match value.as_str() {
                    "faithful" => luau_decompiler::OutputPolicy::Faithful,
                    "annotated" => luau_decompiler::OutputPolicy::Annotated,
                    "verified-typed" | "verified_typed" => {
                        luau_decompiler::OutputPolicy::VerifiedTyped
                    }
                    _ => {
                        return Err("--policy expects faithful, annotated or verified-typed".into())
                    }
                })
            }
            "--entry-output" => {
                result.entry_output = Some(match value.as_str() {
                    "script" => luau_decompiler::EntryOutput::Script,
                    "function" => luau_decompiler::EntryOutput::Function,
                    _ => return Err("--entry-output expects script or function".into()),
                })
            }
            "--quality-report" => result.quality_report = Some(value.into()),
            "--project" => result.project = Some(value.into()),
            "-o" | "--output" => result.output = Some(value.into()),
            "--out-dir" => result.output_dir = Some(value.into()),
            "--batch-report" => result.batch_report = Some(value.into()),
            "--manifest" => result.manifest = Some(value.into()),
            "--window" => result.batch_window = number(&arg, &value)?,
            "--batch-input-mib" => result.batch_input_mib = number(&arg, &value)?,
            "--batch-output-mib" => result.batch_output_mib = number(&arg, &value)?,
            "--threads" => result.threads = value,
            "--iterations" => result.iterations = number(&arg, &value)?,
            "--warmup" => result.warmup = number(&arg, &value)?,
            "--listen" => result.listen = value,
            "--workers" => result.workers = number(&arg, &value)?,
            "--queue" => result.queue = number(&arg, &value)?,
            "--timeout-ms" => result.timeout_ms = number(&arg, &value)?,
            "--cache-mib" => result.cache_mib = number(&arg, &value)?,
            "--memory-mib" => result.memory_mib = number(&arg, &value)?,
            "--cpu-threads" => result.cpu_threads = number(&arg, &value)?,
            "--token-env" => result.token_env = value,
            _ => return Err(format!("unknown option {arg}")),
        }
    }
    Ok(result)
}

fn number<T: std::str::FromStr>(option: &str, value: &str) -> Result<T, String> {
    value
        .parse()
        .map_err(|_| format!("{option}: invalid integer {value:?}"))
}

fn bounded_read(path: &Path, limit: usize) -> Result<Vec<u8>, String> {
    let mut bytes = Vec::new();
    let input: Box<dyn Read> = if path == Path::new("-") {
        Box::new(io::stdin())
    } else {
        Box::new(File::open(path).map_err(|error| format!("{}: {error}", path.display()))?)
    };
    input
        .take(limit.saturating_add(1) as u64)
        .read_to_end(&mut bytes)
        .map_err(|error| format!("{}: {error}", path.display()))?;
    if bytes.len() > limit {
        return Err(format!("{}: input exceeds {limit} bytes", path.display()));
    }
    Ok(bytes)
}

fn write_output(path: Option<&Path>, bytes: &[u8], force: bool) -> Result<(), String> {
    if path.is_none() || path == Some(Path::new("-")) {
        return io::stdout()
            .lock()
            .write_all(bytes)
            .map_err(|error| format!("stdout: {error}"));
    }
    let path = path.unwrap();
    let mut options = OpenOptions::new();
    options.write(true);
    if force {
        options.create(true).truncate(true);
    } else {
        options.create_new(true);
    }
    let mut file = options.open(path).map_err(|error| {
        format!(
            "{}: {error}; use --force to replace an existing output",
            path.display()
        )
    })?;
    file.write_all(bytes)
        .map_err(|error| format!("{}: {error}", path.display()))
}

fn load_corpus(inputs: &[PathBuf], limit: usize) -> Result<Vec<Vec<u8>>, String> {
    if inputs.is_empty() {
        return Err("at least one input file is required".into());
    }
    if inputs.len() > MAX_CORPUS_FILES {
        return Err(format!("corpus exceeds {MAX_CORPUS_FILES} files"));
    }
    if inputs.iter().any(|path| path == Path::new("-")) {
        return Err("stdin is only supported by the decompile command".into());
    }
    let mut total = 0usize;
    let mut corpus = Vec::with_capacity(inputs.len());
    for path in inputs {
        let bytes = bounded_read(path, limit.min(MAX_CORPUS_BYTES.saturating_sub(total)))?;
        total = total
            .checked_add(bytes.len())
            .ok_or("corpus size overflow")?;
        if total > MAX_CORPUS_BYTES {
            return Err("corpus exceeds 256 MiB".into());
        }
        corpus.push(bytes);
    }
    Ok(corpus)
}

fn thread_count(text: &str) -> Result<usize, String> {
    let count = number::<usize>("--threads", text)?;
    if !(1..=64).contains(&count) {
        return Err("thread count must be 1..64".into());
    }
    Ok(count)
}

#[derive(serde::Serialize)]
struct ResultMetadata<'a> {
    input_sha256: &'a str,
    #[serde(flatten)]
    stats: &'a luau_decompiler::Stats,
    complete: bool,
    quality: luau_decompiler::OutputQuality,
    profile: &'a str,
    fallback_prototypes: &'a [usize],
    bindings: &'a [luau_decompiler::structure::RecoveredBindingInfo],
    source_bindings: &'a [luau_decompiler::source::SourceBinding],
    source_functions: &'a [luau_decompiler::source::SourceFunction],
    assumptions: &'a [String],
    type_report: &'a luau_decompiler::types::TypeReport,
    validation: &'a luau_decompiler::quality::QualityReport,
    source_map: &'a [luau_decompiler::types::GeneratedRegion],
    closure_scope: &'a luau_decompiler::structure::ClosureScopeReport,
    baseline_source: &'a Option<String>,
}

fn result_metadata(result: &luau_decompiler::Decompiled) -> ResultMetadata<'_> {
    ResultMetadata {
        input_sha256: &result.input_sha256,
        stats: &result.stats,
        complete: result.complete,
        quality: result.quality,
        profile: &result.profile,
        fallback_prototypes: &result.fallback_prototypes,
        bindings: &result.bindings,
        source_bindings: &result.source_bindings,
        source_functions: &result.source_functions,
        assumptions: &result.assumptions,
        type_report: &result.type_report,
        validation: &result.validation,
        source_map: &result.source_map,
        closure_scope: &result.closure_scope,
        baseline_source: &result.baseline_source,
    }
}

fn result_summary(result: &luau_decompiler::Decompiled) -> Result<serde_json::Value, String> {
    let mut value = serde_json::to_value(&result.stats).map_err(|e| e.to_string())?;
    value["complete"] = json!(result.complete);
    value["quality"] = json!(result.quality);
    value["profile"] = json!(result.profile);
    value["assumption_count"] = json!(result.assumptions.len());
    value["validation"] = json!({
        "required_passed": result.validation.required_passed,
        "syntax": result.validation.syntax,
        "compilation": result.validation.compilation,
        "strict_analysis": result.validation.strict_analysis,
        "diagnostic_count": result.validation.diagnostics.len(),
        "selected_strategy": result.validation.selected_strategy,
        "meaningful_typing": result.validation.meaningful_typing,
    });
    Ok(value)
}

fn batch(args: &Args, config: &Config) -> Result<(), String> {
    let threads = thread_count(&args.threads)?;
    let directory = args
        .output_dir
        .as_deref()
        .ok_or("batch requires --out-dir")?;
    let mut outputs = Vec::with_capacity(args.inputs.len());
    let mut seen = std::collections::HashSet::new();
    for path in &args.inputs {
        let name = path
            .file_stem()
            .ok_or_else(|| format!("{}: invalid filename", path.display()))?;
        let mut filename = name.to_os_string();
        filename.push(".luau");
        let output = directory.join(filename);

        if !seen.insert(output.to_string_lossy().to_lowercase()) {
            return Err(format!("multiple inputs map to {}", output.display()));
        }
        if !args.force && output.exists() {
            return Err(format!(
                "{} exists; use --force to replace it",
                output.display()
            ));
        }
        outputs.push(output);
    }
    if args.inputs.is_empty() || args.inputs.len() > MAX_CORPUS_FILES {
        return Err(format!("batch requires 1..={MAX_CORPUS_FILES} files"));
    }
    if args.inputs.iter().any(|p| p == Path::new("-")) {
        return Err("batch stdin is unsupported; use a JSON path manifest".into());
    }
    let pool = DecompilePool::new(threads).map_err(|e| e.to_string())?;
    let mib = |n: usize| {
        n.checked_mul(1024 * 1024)
            .filter(|n| *n <= 16usize * 1024 * 1024 * 1024)
            .ok_or("stream byte budget exceeds 16 GiB")
    };
    let options = StreamOptions {
        window: args.batch_window,
        max_input_bytes: mib(args.batch_input_mib)?,
        max_source_bytes: mib(args.batch_output_mib)?,
    };
    fs::create_dir_all(directory).map_err(|error| format!("{}: {error}", directory.display()))?;
    let mut failures = 0usize;
    let mut structured = 0usize;
    let mut dispatcher = 0usize;
    let mut assumptions = 0usize;
    let mut quality_failures = 0usize;
    let inputs = args.inputs.iter().enumerate().map(|(index, path)| {
        bounded_read(path, config.limits.max_bytes)
            .map(|bytes| (index, bytes))
            .map_err(|message| luau_decompiler::Error::new("io", message))
    });
    let report = pool
        .stream(inputs, config, &options, |index, result| {
            let input = &args.inputs[index];
            let output = &outputs[index];
            match result {
                Ok(decompiled) => {
                    if !decompiled.complete {
                        return Err(luau_decompiler::Error::new(
                            "incomplete",
                            "batch reconstruction was incomplete",
                        ));
                    }
                    match decompiled.quality {
                        luau_decompiler::OutputQuality::Structured => structured += 1,
                        luau_decompiler::OutputQuality::Dispatcher => dispatcher += 1,
                    }
                    assumptions += usize::from(!decompiled.assumptions.is_empty());
                    quality_failures += usize::from(source_gate_failed(&decompiled));
                    write_output(Some(output), decompiled.source.as_bytes(), args.force)
                        .map_err(|e| luau_decompiler::Error::new("io", e))?;
                    if args.stats
                        || decompiled.quality == luau_decompiler::OutputQuality::Dispatcher
                        || !decompiled.assumptions.is_empty()
                        || source_gate_failed(&decompiled)
                    {
                        eprintln!(
                            "{}\t{}",
                            input.display(),
                            result_summary(&decompiled)
                                .map_err(|e| luau_decompiler::Error::new("json", e))?
                        );
                    }
                }
                Err(error) => {
                    failures += 1;
                    eprintln!("{}: {error}", input.display());
                }
            }
            Ok(())
        })
        .map_err(|e| e.to_string())?;
    if args.stats {
        eprintln!(
            "{}",
            serde_json::to_string(&report).map_err(|e| e.to_string())?
        );
    }
    if let Some(path) = &args.batch_report {
        let mut value = serde_json::to_value(&report).map_err(|e| e.to_string())?;
        value["structured_reconstructions"] = json!(structured);
        value["dispatcher_reconstructions"] = json!(dispatcher);
        value["reconstructions_with_assumptions"] = json!(assumptions);
        value["required_quality_failures"] = json!(quality_failures);
        let bytes = serde_json::to_vec_pretty(&value).map_err(|e| e.to_string())?;
        write_output(Some(path), &bytes, args.force)?;
    }
    if failures + quality_failures > 0 {
        Err(format!("{failures} reconstruction failures and {quality_failures} required quality failures among {} inputs; emitted faithful sources remain available", args.inputs.len()))
    } else {
        Ok(())
    }
}

fn percentile(sorted: &[u128], fraction: usize) -> u128 {
    sorted[(sorted.len() * fraction).div_ceil(100).saturating_sub(1)]
}

fn source_gate_failed(result: &luau_decompiler::Decompiled) -> bool {
    !result.validation.required_passed
        || result.validation.syntax == luau_decompiler::quality::GateStatus::Failed
        || result.validation.compilation == luau_decompiler::quality::GateStatus::Failed
}

struct PhaseHistogram {
    counts: Box<[u64; 4096]>,
    samples: u64,
}
impl PhaseHistogram {
    fn new() -> Self {
        Self {
            counts: Box::new([0; 4096]),
            samples: 0,
        }
    }
    fn add(&mut self, micros: u64) {
        let index = if micros < 2048 {
            micros as usize
        } else {
            let power = micros.ilog2();
            2048 + (power as usize - 11) * 32 + ((micros - (1u64 << power)) >> (power - 5)) as usize
        };
        self.counts[index] += 1;
        self.samples += 1;
    }
    fn percentile(&self, p: u64) -> [u64; 2] {
        let target = self.samples.saturating_mul(p).div_ceil(100);
        let mut seen = 0;
        for (index, count) in self.counts.iter().enumerate() {
            seen += count;
            if *count > 0 && seen >= target {
                if index < 2048 {
                    return [index as u64, index as u64];
                }
                let power = (index - 2048) / 32 + 11;
                let step = 1u64 << (power - 5);
                let low = (1u64 << power) + ((index - 2048) % 32) as u64 * step;
                return [low, low.saturating_add(step - 1)];
            }
        }
        [0, 0]
    }
}

fn benchmark(args: &Args, config: &Config) -> Result<(), String> {
    if !(1..=10000).contains(&args.iterations) || args.warmup > 1000 {
        return Err("iterations must be 1..10000; warmup must be 0..1000".into());
    }
    let counts: Vec<usize> = args
        .threads
        .split(',')
        .map(thread_count)
        .collect::<Result<_, _>>()?;
    if counts.is_empty() || counts.len() > 16 {
        return Err("benchmark requires 1..16 thread counts".into());
    }
    let corpus = load_corpus(&args.inputs, config.limits.max_bytes)?;
    if corpus.len().saturating_mul(args.iterations) > 1_000_000 {
        return Err("benchmark exceeds the one-million latency-sample limit".into());
    }
    let input_bytes: usize = corpus.iter().map(Vec::len).sum();
    let manifest: Vec<_> = args.inputs.iter().zip(&corpus).map(|(path, input)| json!({"path": path, "bytes": input.len(), "sha256": format!("{:x}", Sha256::digest(input))})).collect();
    let mut rows = Vec::new();
    let mut required_quality_failures = 0usize;
    let mut reference_hashes: Option<Vec<[u8; 32]>> = None;
    for threads in counts {
        let pool = rayon::ThreadPoolBuilder::new()
            .num_threads(threads)
            .build()
            .map_err(|error| error.to_string())?;
        for _ in 0..args.warmup {
            let warmup: Vec<_> = pool.install(|| {
                corpus
                    .par_iter()
                    .map(|input| {
                        luau_decompiler::processing::process(input, config.input_format, config)
                            .map(|result| result.source.len())
                    })
                    .collect()
            });
            if let Some((index, error)) = warmup
                .into_iter()
                .enumerate()
                .find_map(|(index, result)| result.err().map(|error| (index, error)))
            {
                return Err(format!(
                    "benchmark warmup failed for {}: {error}",
                    args.inputs[index].display()
                ));
            }
        }
        let mut latencies = Vec::with_capacity(corpus.len() * args.iterations);
        let mut source_bytes = 0usize;
        let mut output_hashes = Vec::new();
        let mut structured = 0usize;
        let mut dispatcher = 0usize;
        let mut with_assumptions = 0usize;
        let mut strict_passed = 0usize;
        let mut strict_failed = 0usize;
        let mut strict_unavailable = 0usize;
        let mut validation_cache_hits = 0usize;
        let mut quality_failures = 0usize;
        let mut phases = [0u128; 6];
        let mut phase_histograms: [PhaseHistogram; 6] =
            std::array::from_fn(|_| PhaseHistogram::new());
        let started = Instant::now();
        for _ in 0..args.iterations {
            let measured: Vec<_> = pool.install(|| {
                corpus
                    .par_iter()
                    .map(|input| {
                        let start = Instant::now();
                        let result = luau_decompiler::processing::process(
                            input,
                            config.input_format,
                            config,
                        );
                        (start.elapsed().as_nanos(), result)
                    })
                    .collect()
            });
            let mut hashes = Vec::with_capacity(corpus.len());
            for (index, (latency, result)) in measured.into_iter().enumerate() {
                let result = result.map_err(|error| {
                    format!(
                        "benchmark decompilation failed for {}: {error}",
                        args.inputs[index].display()
                    )
                })?;
                if !result.complete {
                    return Err(format!(
                        "incomplete reconstruction during benchmark: {}",
                        args.inputs[index].display()
                    ));
                }
                match result.quality {
                    luau_decompiler::OutputQuality::Structured => structured += 1,
                    luau_decompiler::OutputQuality::Dispatcher => dispatcher += 1,
                }
                with_assumptions += usize::from(!result.assumptions.is_empty());
                quality_failures += usize::from(source_gate_failed(&result));
                match result.validation.strict_analysis {
                    luau_decompiler::quality::GateStatus::Passed => strict_passed += 1,
                    luau_decompiler::quality::GateStatus::Failed => strict_failed += 1,
                    _ => strict_unavailable += 1,
                }
                validation_cache_hits += usize::from(result.validation.cache_hit);
                for ((sum, histogram), value) in phases.iter_mut().zip(&mut phase_histograms).zip([
                    result.stats.decode_micros,
                    result.stats.reconstruct_micros,
                    result.stats.type_infer_micros,
                    result.stats.format_micros,
                    result.stats.validation_micros,
                    result.stats.parse_micros,
                ]) {
                    *sum += u128::from(value);
                    histogram.add(value);
                }
                latencies.push(latency);
                source_bytes += result.source.len();
                hashes.push(Sha256::digest(result.source.as_bytes()).into());
            }
            if let Some(reference) = &reference_hashes {
                if reference != &hashes {
                    return Err("nondeterministic output detected during benchmark".into());
                }
            } else {
                reference_hashes = Some(hashes.clone());
            }
            output_hashes = hashes;
        }
        let elapsed = started.elapsed();
        required_quality_failures += quality_failures;
        latencies.sort_unstable();
        rows.push(json!({
            "threads": threads, "iterations": args.iterations, "scripts": corpus.len() * args.iterations,
            "elapsed_ns": elapsed.as_nanos(), "latency_p50_ns": percentile(&latencies, 50),
            "latency_p95_ns": percentile(&latencies, 95), "latency_max_ns": latencies.last(),
            "scripts_per_second": (corpus.len() * args.iterations) as f64 / elapsed.as_secs_f64(),
            "input_bytes_per_second": (input_bytes * args.iterations) as f64 / elapsed.as_secs_f64(),
            "source_bytes": source_bytes,
            "complete_reconstructions": structured + dispatcher,
            "structured_reconstructions": structured, "dispatcher_reconstructions": dispatcher,
            "reconstructions_with_assumptions": with_assumptions,
            "strict_passed":strict_passed,"strict_failed":strict_failed,"strict_not_run_or_unavailable":strict_unavailable,"analyzer_cache_hits":validation_cache_hits,
            "required_quality_failures":quality_failures,
            "phase_cpu_or_wait_micros_summed":{"decode":phases[0],"reconstruction":phases[1],"type_inference":phases[2],"formatting":phases[3],"validation":phases[4],"source_parsing":phases[5]},
            "phase_latency_distributions": (["decode","reconstruction","type_inference","formatting","validation","source_parsing"].iter().zip(&phase_histograms).map(|(name,h)|json!({"phase":name,"samples":h.samples,"p50_micros_bounds":h.percentile(50),"p95_micros_bounds":h.percentile(95)})).collect::<Vec<_>>()),
            "phase_distribution_precision":"exact integer microseconds below2048; inclusive logarithmic bounds above (32buckets/poweroftwo); fixed192KiB measurement storage",
            "output_sha256": output_hashes.iter().map(|hash| hash.iter().map(|b| format!("{b:02x}")).collect::<String>()).collect::<Vec<_>>()
        }));
    }
    let report = json!({
        "schema": 1, "package_version": env!("CARGO_PKG_VERSION"), "os": std::env::consts::OS,
        "architecture": std::env::consts::ARCH, "logical_cpus": std::thread::available_parallelism().map(|n| n.get()).unwrap_or(1),
        "legacy_upstream_revision": "8cc289fae430d9b0c22bde209fe5cf2d01751ff1", "semantic_profiles":luau_decompiler::profiles::capabilities(), "config": config,
        "timing": "complete decompile calls; excludes corpus I/O and worker pool creation; wall throughput includes output hashing",
        "peak_memory_bytes": null, "peak_memory_note": "measure externally in an isolated process; see benchmark scripts",
        "corpus": manifest, "results": rows,"required_quality_failures":required_quality_failures
    });
    let mut bytes = serde_json::to_vec_pretty(&report).map_err(|error| error.to_string())?;
    bytes.push(b'\n');
    write_output(args.output.as_deref(), &bytes, args.force)?;
    if required_quality_failures > 0 {
        Err(format!("{required_quality_failures} benchmark results failed a required source/strict-analysis gate; the measurement report was retained"))
    } else {
        Ok(())
    }
}

fn doctor(config: &Config, json_output: bool) -> Result<(), String> {
    let mut config = config.clone();
    if let Ok(executable) = std::env::current_exe() {
        if let Some(bin) = executable.parent() {
            if let Some(root) = bin
                .parent()
                .filter(|root| root.join("runtime-manifest.json").is_file())
            {
                if config.validation.analyzer_path.is_none() {
                    config.validation.analyzer_path = Some(
                        bin.join(format!("luau-quality{}", std::env::consts::EXE_SUFFIX))
                            .to_string_lossy()
                            .into_owned(),
                    );
                }
                if config.validation.definitions_path.is_none() {
                    config.validation.definitions_path = Some(
                        root.join("definitions/roblox.d.luau")
                            .to_string_lossy()
                            .into_owned(),
                    );
                }
            }
        }
    }
    config.output_policy = luau_decompiler::OutputPolicy::VerifiedTyped;
    config.typing.mode = luau_decompiler::types::TypingMode::Annotated;
    config.validation.mode = luau_decompiler::quality::ValidationMode::StrictRequired;
    config.validation.timeout_ms = config.validation.timeout_ms.min(10_000);
    config.validation.max_workers = 1;
    config.typing.binding_types.clear();
    config.name_overrides.clear();
    config.meaningful_typing = Default::default();
    let started = Instant::now();
    let assets = luau_decompiler::quality::validation_assets_ready(&config);
    let context = luau_decompiler::ExecutionContext::new(
        luau_decompiler::CancellationToken::new(),
        Some(started + Duration::from_secs(15)),
    )
    .with_work_limit(1_000_000);
    let operation = luau_decompiler::processing::Processor::new(1).and_then(|processor| {
        processor.process(
            b"--!strict\nlocal answer: number = 42\nreturn answer\n",
            luau_decompiler::input::InputFormat::LuauSource,
            &config,
            context,
        )
    });
    let passed = assets.is_ok()
        && operation
            .as_ref()
            .is_ok_and(|output| output.complete && output.validation.required_passed);
    let (validation, error) = match operation {
        Ok(output) => (Some(output.validation), None),
        Err(error) => (None, Some(error.to_string())),
    };
    let report = json!({"schema":1,"version":env!("CARGO_PKG_VERSION"),"passed":passed,
        "platform":std::env::consts::OS,"architecture":std::env::consts::ARCH,
        "validation_assets_ready":assets.is_ok(),"validation_assets_error":assets.err(),
        "known_operation":"one offline verified-typed local numeric binding; no execution of submitted code",
        "validation":validation,"error":error,"elapsed_millis":started.elapsed().as_millis(),
        "action":if passed {"Installation is ready for local verified-typed processing."} else {"Keep bin, analyzer manifest and definitions together; check the validation diagnostics and restore matching assets from the same release."}});
    if json_output {
        println!(
            "{}",
            serde_json::to_string_pretty(&report).map_err(|error| error.to_string())?
        );
    } else {
        println!(
            "luau-decompile {}: {}",
            env!("CARGO_PKG_VERSION"),
            if passed { "ready" } else { "diagnostic failed" }
        );
        println!("{}", report["action"].as_str().unwrap_or_default());
        if !passed {
            println!(
                "{}",
                serde_json::to_string_pretty(&report).map_err(|error| error.to_string())?
            );
        }
    }
    if passed {
        Ok(())
    } else {
        Err("installation diagnostic failed; inspect doctor --json".into())
    }
}

fn execute(mut args: Args) -> Result<(), String> {
    if matches!(args.command.as_str(), "help" | "-h" | "--help") {
        print!("{HELP}");
        return Ok(());
    }
    if matches!(args.command.as_str(), "--version" | "-V") {
        println!("luau-decompile {}", env!("CARGO_PKG_VERSION"));
        return Ok(());
    }
    let mut config: Config = if let Some(path) = &args.config {
        serde_json::from_slice(&bounded_read(path, 1024 * 1024)?)
            .map_err(|error| format!("{}: {error}", path.display()))?
    } else {
        Config::default()
    };
    if let Some(format) = args.input_format {
        config.input_format = format;
    }
    if let Some(policy) = args.output_policy {
        config.output_policy = policy;
    }
    if let Some(entry) = args.entry_output {
        config.entry_output = entry;
    }
    if let Some(naming) = args.naming {
        config.naming = naming;
    }
    if let Some(name) = &args.module_name {
        config.naming_options.module_name_hint = Some(name.clone());
    }
    if args.strict_required && args.no_validation {
        return Err("--strict-required and --no-validation conflict".into());
    }
    if args.strict_required {
        config.validation.mode = luau_decompiler::quality::ValidationMode::StrictRequired;
    }
    if args.no_validation {
        config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
    }
    if let Some(path) = &args.project {
        config.validation.project = serde_json::from_slice(&bounded_read(path, 8 * 1024 * 1024)?)
            .map_err(|e| format!("{}: {e}", path.display()))?;
    }
    config.validate().map_err(|error| error.to_string())?;
    if let Some(manifest) = &args.manifest {
        let paths: Vec<PathBuf> = serde_json::from_slice(&bounded_read(manifest, 4 * 1024 * 1024)?)
            .map_err(|e| format!("{}: {e}", manifest.display()))?;
        args.inputs.extend(paths);
    }
    match args.command.as_str() {
        "doctor" => {
            if !args.inputs.is_empty() {
                return Err("doctor accepts no input files".into());
            }
            doctor(&config, args.json)
        }
        "capabilities" => {
            let assets = luau_decompiler::quality::validation_assets_ready(&config);
            println!(
                "{}",
                serde_json::to_string_pretty(&json!({
                    "package_version": env!("CARGO_PKG_VERSION"),
                    "inputs": luau_decompiler::input::capabilities(),
                    "bytecode": luau_decompiler::profiles::capabilities(),
                    "output_policies": ["faithful", "annotated", "verified_typed"],
                    "default_configuration": Config::default(),
                    "validation_assets_ready": assets.is_ok(),
                    "validation_assets_error": assets.err(),
                }))
                .map_err(|e| e.to_string())?
            );
            Ok(())
        }
        "decompile" => {
            if args.inputs.len() != 1 {
                return Err("decompile requires exactly one input file or '-'".into());
            }
            let threads = thread_count(&args.threads)?;
            let bytes = bounded_read(&args.inputs[0], config.limits.max_bytes)?;
            let pool = luau_decompiler::processing::Processor::new(threads)
                .map_err(|error| error.to_string())?;
            let result = pool
                .process(
                    &bytes,
                    config.input_format,
                    &config,
                    luau_decompiler::execution::ExecutionContext::new(
                        luau_decompiler::execution::CancellationToken::new(),
                        None,
                    ),
                )
                .map_err(|error| error.to_string())?;
            write_output(args.output.as_deref(), result.source.as_bytes(), args.force)?;
            if let Some(path) = &args.quality_report {
                write_output(
                    Some(path),
                    &serde_json::to_vec_pretty(&result_metadata(&result))
                        .map_err(|e| e.to_string())?,
                    args.force,
                )?;
            }
            if args.stats
                || result.quality == luau_decompiler::OutputQuality::Dispatcher
                || !result.assumptions.is_empty()
                || source_gate_failed(&result)
            {
                eprintln!("{}", result_summary(&result)?);
            }
            if source_gate_failed(&result) {
                return Err("required source/strict-analysis gate failed; faithful source was retained and quality diagnostics are available via --quality-report/--stats".into());
            }
            Ok(())
        }
        "batch" => batch(&args, &config),
        "benchmark" => benchmark(&args, &config),
        "serve" => {
            if !args.inputs.is_empty() {
                return Err("serve does not accept input paths".into());
            }
            let token = std::env::var(&args.token_env).map_err(|_| {
                format!(
                    "set {} to a random 32..256 byte token before starting the bridge",
                    args.token_env
                )
            })?;
            let cache_bytes = args
                .cache_mib
                .checked_mul(1024 * 1024)
                .ok_or("cache size overflow")?;
            if cache_bytes > 1024 * 1024 * 1024 {
                return Err("cache capacity must not exceed 1024 MiB".into());
            }
            service::run(
                service::Options {
                    allow_remote: args.allow_remote,
                    listen: args.listen.parse().map_err(|_| {
                        "--listen requires a numeric IP:port, for example 127.0.0.1:7879"
                            .to_string()
                    })?,
                    token,
                    workers: args.workers,
                    queue: args.queue,
                    cache_bytes,
                    timeout: Duration::from_millis(args.timeout_ms),
                    cpu_threads: args.cpu_threads,
                    memory_bytes: args
                        .memory_mib
                        .checked_mul(1024 * 1024)
                        .filter(|n| *n <= 64usize * 1024 * 1024 * 1024)
                        .ok_or("aggregate memory budget must not exceed 64 GiB")?,
                },
                config,
            )
        }
        _ => Err(format!("unknown command {:?}; use --help", args.command)),
    }
}

fn main() {
    if let Err(error) = parse(std::env::args().skip(1)).and_then(execute) {
        eprintln!("error: {error}");
        std::process::exit(1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn argument_errors_are_explicit() {
        assert!(parse(["decompile", "--wat", "1"].map(str::to_string)).is_err());
        assert!(parse(["decompile", "--config"].map(str::to_string)).is_err());
        assert_eq!(
            parse(["decompile", "-", "--stats"].map(str::to_string))
                .unwrap()
                .inputs,
            [PathBuf::from("-")]
        );
        assert!(thread_count("0").is_err());
        assert!(thread_count("65").is_err());
        assert_eq!(thread_count("2").unwrap(), 2);
    }

    #[test]
    fn roblox_naming_and_module_hint_remain_explicit_presentation_options() {
        let options = parse(
            [
                "decompile",
                "input.bc",
                "--naming",
                "roblox",
                "--module-name",
                "Button",
            ]
            .map(str::to_string),
        )
        .unwrap();
        assert_eq!(options.naming, Some(luau_decompiler::NameStyle::Roblox));
        assert_eq!(options.module_name.as_deref(), Some("Button"));
        assert!(parse(["decompile", "input.bc", "--naming", "guess"].map(str::to_string)).is_err());
        let mut config = Config::default();
        config.naming_options.module_name_hint = Some("Button\nModule".into());
        assert_eq!(config.validate().unwrap_err().stage, "config");
    }

    #[test]
    fn single_script_threads_default_to_one_and_validate_explicit_counts() {
        let defaults = parse(["decompile", "input.bc"].map(str::to_string)).unwrap();
        assert_eq!(defaults.threads, "1");
        let parallel =
            parse(["decompile", "input.bc", "--threads", "4"].map(str::to_string)).unwrap();
        assert_eq!(parallel.threads, "4");
        for invalid in ["0", "65", "1,4"] {
            let options =
                parse(["decompile", "absent-input.bc", "--threads", invalid].map(str::to_string))
                    .unwrap();
            let error = execute(options).unwrap_err();
            assert!(
                error.contains("thread") || error.contains("--threads"),
                "{error}"
            );
        }
    }

    #[test]
    fn percentile_uses_nearest_rank() {
        assert_eq!(percentile(&[1, 2, 3, 4, 5], 50), 3);
        assert_eq!(percentile(&[1], 95), 1);
        let mut histogram = PhaseHistogram::new();
        for value in [0, 1, 2047, 2048, 4095, 1_000_000, u64::MAX] {
            histogram.add(value);
        }
        let median = histogram.percentile(50);
        assert!(median[0] <= 2048 && 2048 <= median[1]);
        let upper = histogram.percentile(100);
        assert_eq!(upper[1], u64::MAX);
    }

    #[test]
    fn benchmark_required_quality_failure_returns_error_and_retains_report() {
        let root = Path::new(env!("CARGO_MANIFEST_DIR"));
        let directory = root.join("artifacts");
        fs::create_dir_all(&directory).unwrap();
        let report_path = directory.join(format!(
            "benchmark-required-gate-{}.json",
            std::process::id()
        ));
        let fixture = root.join("tests/fixtures/arithmetic.O1.D2.bc");
        let options = parse(
            [
                "benchmark",
                fixture.to_str().unwrap(),
                "--threads",
                "1",
                "--warmup",
                "0",
                "--iterations",
                "1",
                "-o",
                report_path.to_str().unwrap(),
                "--force",
            ]
            .map(str::to_string),
        )
        .unwrap();
        let mut config = Config::default();
        config.validation.mode = luau_decompiler::quality::ValidationMode::StrictRequired;
        config.validation.analyzer_path = Some(
            directory
                .join("no-such-benchmark-analyzer")
                .to_string_lossy()
                .into_owned(),
        );
        let error = benchmark(&options, &config).unwrap_err();
        assert!(
            error.contains("required source/strict-analysis gate"),
            "{error}"
        );
        let report: serde_json::Value =
            serde_json::from_slice(&fs::read(&report_path).unwrap()).unwrap();
        assert_eq!(report["required_quality_failures"], 1);
        assert_eq!(report["results"][0]["required_quality_failures"], 1);
        assert_eq!(report["results"][0]["strict_not_run_or_unavailable"], 1);
        assert_eq!(report["results"][0]["complete_reconstructions"], 1);
        config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
        benchmark(&options, &config).unwrap();
    }
}
