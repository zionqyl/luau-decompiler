pub mod ast;
pub mod attribution;
pub mod bindings;
pub mod bytecode;
pub mod cfg;
pub mod config;
pub mod dataflow;
pub mod error;
pub mod execution;
pub mod executors;
pub mod format;
pub mod input;
pub mod names;
mod parallel;
pub mod platform;
pub mod processing;
pub mod profiles;
pub mod quality;
pub mod runtime;
pub mod source;
pub mod structure;
pub mod type_ast;
pub mod types;
#[cfg(target_arch = "wasm32")]
mod wasm_api;

use crate::parallel as rayon;
pub use config::{
    ClosureConfig, Config, ControlFlowMode, EntryInvocation, EntryOutput, Limits, MeaningfulTyping,
    NameStyle, NamingOptions, OutputPolicy,
};
pub use error::{Error, Result};
pub use execution::{CancellationToken, ExecutionContext, MemoryBudget};
pub use input::InputFormat;
use platform::Instant;
pub use processing::{process, process_source, Processor};
use serde::Serialize;

pub const UPSTREAM_REVISION: &str = "8cc289fae430d9b0c22bde209fe5cf2d01751ff1";

#[derive(Debug, Clone, Serialize)]
pub struct Stats {
    pub input_bytes: usize,
    pub output_bytes: usize,
    pub prototypes: usize,
    pub instructions: usize,
    pub source_statements: usize,
    pub parse_micros: u64,
    pub decode_micros: u64,
    pub reconstruct_micros: u64,
    pub type_infer_micros: u64,
    pub format_micros: u64,
    pub validation_micros: u64,
    pub total_micros: u64,
    pub cpu_pool_threads: usize,
}
#[derive(Debug, Clone, Serialize)]
pub struct Decompiled {
    pub complete: bool,
    pub input_sha256: String,
    pub source: String,
    pub stats: Stats,
    pub quality: OutputQuality,
    pub profile: String,
    pub representation: Option<bytecode::Representation>,
    pub fallback_prototypes: Vec<usize>,
    pub bindings: Vec<structure::RecoveredBindingInfo>,
    pub source_bindings: Vec<source::SourceBinding>,
    pub source_functions: Vec<source::SourceFunction>,
    pub assumptions: Vec<String>,
    pub type_report: types::TypeReport,
    pub validation: quality::QualityReport,
    pub baseline_source: Option<String>,
    pub source_map: Vec<types::GeneratedRegion>,
    pub closure_scope: structure::ClosureScopeReport,
}

#[derive(Debug, Clone, Copy, Serialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum OutputQuality {
    Structured,
    Dispatcher,
}

pub fn decompile(input: &[u8], config: &Config) -> Result<Decompiled> {
    let config = config.effective();
    execution::with_default_scope(config.limits.max_analysis_steps, || {
        decompile_inner(input, &config)
    })
}

fn decompile_inner(input: &[u8], config: &Config) -> Result<Decompiled> {
    let start = Instant::now();
    config.validate()?;
    execution::checkpoint()?;
    let module = bytecode::decode_with_options(
        input,
        &config.limits,
        &config.profile,
        &config.bytecode_encoding,
    )?;
    execution::admit_module(&module)?;
    for key in config.name_overrides.keys() {
        let (p, target) = key[1..].split_once(':').expect("validated override key");
        let proto: usize = p.parse().expect("validated proto index");
        let register = target
            .strip_prefix('r')
            .map(|r| r.parse::<usize>().expect("validated register index"));
        if module
            .protos
            .get(proto)
            .is_none_or(|p| register.is_some_and(|r| r >= p.max_stack as usize))
        {
            return Err(Error::new(
                "config",
                format!("override {key} refers to an absent binding"),
            ));
        }
    }
    let decode_micros = start.elapsed().as_micros().min(u64::MAX as u128) as u64;
    let reconstruct_start = Instant::now();
    let mut reconstruction = structure::decompile_module_report(&module, config)?;
    let reconstruct_micros = (reconstruct_start
        .elapsed()
        .as_micros()
        .min(u64::MAX as u128) as u64)
        .saturating_sub(reconstruction.baseline_format_micros);
    let mut type_infer_micros = 0u64;
    let mut format_micros = reconstruction.baseline_format_micros;
    if config.typing.mode != types::TypingMode::Off {
        let presentation = (|| -> Result<_> {
            let inference_start = Instant::now();
            let inferred = types::reconstruct(
                &reconstruction.body,
                &module,
                &reconstruction.recovered_bindings,
                config,
            );
            type_infer_micros = inference_start.elapsed().as_micros().min(u64::MAX as u128) as u64;
            let (annotations, mut report) = inferred?;
            let format_start = Instant::now();
            let formatted = format::format_typed(
                &reconstruction.body,
                config,
                &annotations,
                module.main,
                &reconstruction.recovered_bindings,
            );
            format_micros = format_micros
                .saturating_add(format_start.elapsed().as_micros().min(u64::MAX as u128) as u64);
            let (typed_source, source_map) = formatted?;
            let metadata_annotations =
                types::metadata_annotations(&annotations, &report, &reconstruction.body);
            let counts = types::emitted_annotation_counts(
                &metadata_annotations,
                &reconstruction.body,
                config,
            )?;
            report.metadata_emitted_annotations = counts.annotations;
            report.metadata_emitted_runtime_annotations = counts.runtime_annotations;
            report.metadata_annotated_bindings = metadata_annotations.locals.len();
            report.metadata_annotated_returns = metadata_annotations
                .functions
                .values()
                .filter(|function| function.returns.is_some())
                .count();
            report.metadata_annotated_variadics = metadata_annotations
                .functions
                .values()
                .filter(|function| function.variadic.is_some())
                .count();
            report.metadata_annotated_parameters = metadata_annotations
                .functions
                .values()
                .map(|function| {
                    function
                        .parameters
                        .iter()
                        .filter(|parameter| parameter.is_some())
                        .count()
                })
                .sum();
            report.metadata_emitted_useful_annotations = counts.useful_annotations;
            report.metadata_emitted_explicit_any = counts.explicit_any;
            let mut metadata = None;
            if config.validation.mode != quality::ValidationMode::Off
                && config.validation.max_attempts > 1
                && (!metadata_annotations.locals.is_empty()
                    || metadata_annotations
                        .functions
                        .values()
                        .any(|f| f.parameters.iter().any(Option::is_some)))
            {
                let format_start = Instant::now();
                let formatted = format::format_typed(
                    &reconstruction.body,
                    config,
                    &metadata_annotations,
                    module.main,
                    &reconstruction.recovered_bindings,
                );
                format_micros =
                    format_micros.saturating_add(
                        format_start.elapsed().as_micros().min(u64::MAX as u128) as u64,
                    );
                match formatted {
                    Ok((source, map)) if source != typed_source => metadata = Some((source, map)),
                    Ok(_) => {}
                    Err(error) if types::recoverable_presentation_error(&error) => {
                        report.optional_failures.push((&error).into())
                    }
                    Err(error) => return Err(error),
                }
            }
            Ok((typed_source, source_map, report, metadata))
        })();
        match presentation {
            Ok((typed_source, source_map, report, metadata)) => {
                reconstruction.baseline_source =
                    Some(std::mem::replace(&mut reconstruction.source, typed_source));
                reconstruction.baseline_source_map =
                    std::mem::replace(&mut reconstruction.source_map, source_map);
                reconstruction.type_report = report;
                if let Some((source, map)) = metadata {
                    reconstruction.metadata_source = Some(source);
                    reconstruction.metadata_source_map = map;
                }
            }
            Err(error) if types::recoverable_presentation_error(&error) => {
                reconstruction
                    .type_report
                    .optional_failures
                    .push((&error).into());
                reconstruction.type_report.limitations.push("Optional typing/presentation exhausted its supported stage budget; the faithful reconstruction is retained.".into());
            }
            Err(error) => return Err(error),
        }
    }
    let validation_start = Instant::now();
    let validation = quality::validate_reconstruction(&mut reconstruction, &module, config)?;
    let validation_micros = validation_start.elapsed().as_micros().min(u64::MAX as u128) as u64;
    execution::checkpoint()?;
    let source = reconstruction.source;
    let mut type_report = reconstruction.type_report;
    type_report.constructor_transformations = reconstruction.constructor_transformations;
    if source.len() > config.limits.max_output_bytes {
        return Err(Error::new(
            "limit",
            "formatted source exceeds max_output_bytes",
        ));
    }
    let mut assumptions: Vec<String> = config
        .vector_constructor
        .iter()
        .map(|path| format!("trusted immutable vector constructor {path}"))
        .collect();
    assumptions.extend(reconstruction.closure_scope.assumptions.iter().cloned());
    if !reconstruction.closure_scope.restrictions.is_empty() {
        assumptions.push("single entry invocation required for reported DUPCLOSURE sites".into());
    }
    Ok(Decompiled {
        complete: true,
        input_sha256: {
            use sha2::Digest;
            format!("{:x}", sha2::Sha256::digest(input))
        },
        quality: if reconstruction.fallback_prototypes.is_empty() {
            OutputQuality::Structured
        } else {
            OutputQuality::Dispatcher
        },
        profile: profiles::for_version(module.version)
            .expect("validated profile")
            .id
            .into(),
        representation: Some(bytecode::representation(input, &config.bytecode_encoding)?),
        fallback_prototypes: reconstruction.fallback_prototypes,
        bindings: reconstruction.recovered_bindings,
        source_bindings: Vec::new(),
        source_functions: Vec::new(),
        type_report,
        validation,
        baseline_source: reconstruction.baseline_source,
        source_map: reconstruction.source_map,
        closure_scope: reconstruction.closure_scope,
        assumptions,
        stats: Stats {
            input_bytes: input.len(),
            output_bytes: source.len(),
            prototypes: module.protos.len(),
            instructions: module.protos.iter().map(|p| p.code.len()).sum(),
            source_statements: 0,
            parse_micros: 0,
            decode_micros,
            reconstruct_micros,
            type_infer_micros,
            format_micros,
            validation_micros,
            total_micros: start.elapsed().as_micros().min(u64::MAX as u128) as u64,
            cpu_pool_threads: if rayon::current_thread_index().is_some() {
                rayon::current_num_threads()
            } else {
                1
            },
        },
        source,
    })
}

pub fn decompile_with_threads(input: &[u8], config: &Config, threads: usize) -> Result<Decompiled> {
    if !(1..=256).contains(&threads) {
        return Err(Error::new("config", "threads must be in 1..=256"));
    }
    if threads == 1 {
        return decompile(input, config);
    }
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(threads)
        .build()
        .map_err(|e| Error::new("threads", e.to_string()))?;
    pool.install(|| decompile(input, config))
}

pub fn decompile_batch(
    inputs: &[Vec<u8>],
    config: &Config,
    threads: usize,
) -> Result<Vec<Result<Decompiled>>> {
    use rayon::prelude::*;
    config.validate()?;
    if !(1..=256).contains(&threads) {
        return Err(Error::new("config", "threads must be in 1..=256"));
    }
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(threads.min(inputs.len().max(1)))
        .build()
        .map_err(|e| Error::new("threads", e.to_string()))?;
    Ok(pool.install(|| {
        inputs
            .par_iter()
            .map(|input| decompile(input, config))
            .collect()
    }))
}
