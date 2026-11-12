use crate::execution::{self, ExecutionContext};
use crate::input::{self, InputFormat};
use crate::parallel as rayon;
use crate::platform::Instant;
use crate::{Config, Decompiled, Error, OutputQuality, Result, Stats};
use rayon::prelude::*;

pub fn process_source(source: &str, config: &Config) -> Result<Decompiled> {
    process(source.as_bytes(), InputFormat::LuauSource, config)
}

pub fn process(input: &[u8], format: InputFormat, config: &Config) -> Result<Decompiled> {
    execution::with_default_scope(config.limits.max_analysis_steps, || {
        let config = config.effective();
        config.validate()?;
        execution::checkpoint()?;
        if input.len() > config.limits.max_bytes {
            return Err(Error::new("limit", "input exceeds max_bytes"));
        }
        let detected = input::detect(input, format)?;
        if detected.format == InputFormat::LuauBytecode {
            return crate::decompile(input, &config);
        }
        let start = Instant::now();
        let source = std::str::from_utf8(if detected.utf8_bom {
            &input[3..]
        } else {
            input
        })
        .map_err(|error| {
            Error::new("input_encoding", error.to_string()).at_offset(error.valid_up_to())
        })?;
        let mut source =
            crate::source::process(source, detected.format, &config).map_err(|mut error| {
                if detected.utf8_bom {
                    error.offset = error.offset.map(|offset| offset + 3);
                }
                error
            })?;
        if detected.utf8_bom {
            for binding in &mut source.bindings {
                binding.declaration_start += 3;
                binding.declaration_end += 3;
            }
            for function in &mut source.functions {
                function.signature_end += 3;
            }
        }
        let validation_start = Instant::now();
        let mut validation = crate::quality::validate_source(
            &mut source.source,
            &mut source.baseline_source,
            &mut source.type_report,
            &config,
        )?;
        if validation.selected_strategy == "original_source" {
            source.type_report = source.baseline_type_report;
            for function in &mut source.functions {
                if matches!(function.origin, Some(crate::types::TypeOrigin::Inference)) {
                    function.origin = None;
                    function.returns = None;
                }
            }
            for binding in &mut source.bindings {
                binding.name = binding.original_name.clone();
                if !matches!(
                    binding.origin,
                    Some(crate::types::TypeOrigin::SourceAnnotation)
                ) {
                    binding.ty = None;
                    binding.origin = None;
                }
            }
            validation.selected_strategy = "original_source".into();
            crate::quality::apply_output_policy(&mut validation, &source.type_report, &config);
        }
        let validation_micros = validation_start
            .elapsed()
            .as_micros()
            .min(u128::from(u64::MAX)) as u64;
        execution::checkpoint()?;
        let output_bytes = source.source.len();
        Ok(Decompiled {
            complete: true,
            input_sha256: {
                use sha2::Digest;
                format!("{:x}", sha2::Sha256::digest(input))
            },
            source: source.source,
            stats: Stats {
                input_bytes: input.len(),
                output_bytes,
                prototypes: 0,
                instructions: 0,
                source_statements: source.statements,
                parse_micros: source.parse_micros,
                decode_micros: 0,
                reconstruct_micros: 0,
                type_infer_micros: source.infer_micros,
                format_micros: source.format_micros,
                validation_micros,
                total_micros: start.elapsed().as_micros().min(u128::from(u64::MAX)) as u64,
                cpu_pool_threads: if rayon::current_thread_index().is_some() {
                    rayon::current_num_threads()
                } else {
                    1
                },
            },
            quality: OutputQuality::Structured,
            profile: if detected.format == InputFormat::LuaSource {
                "lua51-source"
            } else {
                "luau-source"
            }
            .into(),
            representation: None,
            fallback_prototypes: Vec::new(),
            bindings: Vec::new(),
            assumptions: if detected.format == InputFormat::LuaSource {
                vec!["Lua 5.1 compatible syntax subset with compatible standard-library/environment contracts; no dialect-runtime emulation".into()]
            } else {
                Vec::new()
            },
            type_report: source.type_report,
            validation,
            baseline_source: source.baseline_source,
            source_map: Vec::new(),
            source_bindings: source.bindings,
            source_functions: source.functions,
            closure_scope: crate::structure::ClosureScopeReport {
                requested: config.closures.entry_invocation,
                compiler_sharing_contract: false,
                restrictions: Vec::new(),
                assumptions: Vec::new(),
            },
        })
    })
}

pub struct Processor {
    pool: crate::runtime::DecompilePool,
}

impl Processor {
    pub fn new(threads: usize) -> Result<Self> {
        Ok(Self {
            pool: crate::runtime::DecompilePool::new(threads)?,
        })
    }

    pub fn threads(&self) -> usize {
        self.pool.threads()
    }

    pub fn process(
        &self,
        input: &[u8],
        format: InputFormat,
        config: &Config,
        context: ExecutionContext,
    ) -> Result<Decompiled> {
        self.pool
            .install(|| execution::with_context(context, || process(input, format, config)))
    }

    pub fn process_batch(
        &self,
        inputs: &[Vec<u8>],
        format: InputFormat,
        config: &Config,
        context: ExecutionContext,
        max_buffered_bytes: usize,
    ) -> Result<Vec<Result<Decompiled>>> {
        config.validate()?;
        let input_bytes = inputs
            .iter()
            .try_fold(0usize, |total, input| total.checked_add(input.len()))
            .ok_or_else(|| Error::new("limit", "batch input byte count overflow"))?;
        let output_bound = inputs
            .len()
            .checked_mul(config.limits.max_output_bytes)
            .ok_or_else(|| Error::new("limit", "batch output byte count overflow"))?;
        if inputs.len() > 1024
            || input_bytes
                .checked_add(output_bound)
                .is_none_or(|bytes| bytes > max_buffered_bytes)
        {
            return Err(Error::new(
                "limit",
                "batch exceeds its aggregate input/output buffer bound; use streaming windows",
            ));
        }
        let results = self.pool.install(|| {
            inputs
                .par_iter()
                .map(|input| {
                    let scope = context.fork_input_scope()?;
                    execution::with_context(scope, || process(input, format, config))
                })
                .collect::<Vec<_>>()
        });
        Ok(results)
    }
}
