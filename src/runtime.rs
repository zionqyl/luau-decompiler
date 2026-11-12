use crate::parallel as rayon;
use crate::{
    decompile,
    execution::{self, ExecutionContext},
    Config, Decompiled, Error, Result,
};
use rayon::prelude::*;
use serde::Serialize;

pub struct DecompilePool {
    pool: rayon::ThreadPool,
}
impl DecompilePool {
    pub fn new(threads: usize) -> Result<Self> {
        if !(1..=256).contains(&threads) {
            return Err(Error::new("config", "CPU pool threads must be in 1..=256"));
        }
        let pool = rayon::ThreadPoolBuilder::new()
            .num_threads(threads)
            .thread_name(|n| format!("decompile-cpu-{n}"))
            .build()
            .map_err(|e| Error::new("threads", e.to_string()))?;
        Ok(Self { pool })
    }
    pub fn threads(&self) -> usize {
        self.pool.current_num_threads()
    }
    pub fn install<T: Send>(&self, work: impl FnOnce() -> T + Send) -> T {
        self.pool.install(work)
    }
    #[cfg(not(target_arch = "wasm32"))]
    pub fn spawn(&self, work: impl FnOnce() + Send + 'static) {
        self.pool.spawn(work)
    }
    pub fn decompile(
        &self,
        input: &[u8],
        config: &Config,
        context: ExecutionContext,
    ) -> Result<Decompiled> {
        self.install(|| execution::with_context(context, || decompile(input, config)))
    }

    pub fn stream<K, I, F>(
        &self,
        input: I,
        config: &Config,
        options: &StreamOptions,
        mut sink: F,
    ) -> Result<StreamSummary>
    where
        K: Send,
        I: IntoIterator<Item = Result<(K, Vec<u8>)>>,
        F: FnMut(K, Result<Decompiled>) -> Result<()>,
    {
        config.validate()?;
        if !(1..=1024).contains(&options.window)
            || options.max_input_bytes == 0
            || options.max_input_bytes < config.limits.max_bytes
            || options.max_source_bytes / 2 < config.limits.max_output_bytes
        {
            return Err(Error::new("config", "stream window must be 1..=1024; input budget must admit max_bytes; source budget must admit twice max_output_bytes for allocation capacity"));
        }
        let slots = options
            .window
            .min(options.max_source_bytes / config.limits.max_output_bytes / 2)
            .min(options.max_input_bytes / config.limits.max_bytes);
        let mut source = input.into_iter();
        let mut summary = StreamSummary::default();
        let context = execution::current_context();
        loop {
            execution::checkpoint()?;
            let mut chunk = Vec::with_capacity(slots);
            let mut bytes = 0usize;
            while chunk.len() < slots {
                let item = source.next();
                let Some(item) = item else { break };
                let (id, input) = item?;
                if input.capacity() > config.limits.max_bytes {
                    return Err(Error::new(
                        "memory",
                        "one streaming input exceeds the configured input budget",
                    ));
                }
                bytes += input.capacity();
                chunk.push((id, input));
            }
            if chunk.is_empty() {
                break;
            }
            summary.peak_buffered_input_bytes = summary.peak_buffered_input_bytes.max(bytes);
            let measured: Vec<_> = self.install(|| {
                chunk
                    .into_par_iter()
                    .map(|(id, input)| {
                        let run =
                            || crate::processing::process(&input, config.input_format, config);
                        let scope = context
                            .as_ref()
                            .map(ExecutionContext::fork_input_scope)
                            .transpose();
                        let (result, retained_scope) = match scope {
                            Ok(Some(scope)) => {
                                (execution::with_context(scope.clone(), run), Some(scope))
                            }
                            Ok(None) => (run(), None),
                            Err(error) => (Err(error), None),
                        };
                        (id, result, retained_scope)
                    })
                    .collect()
            });
            let retained: usize = measured
                .iter()
                .filter_map(|(_, result, _)| result.as_ref().ok())
                .map(|r| r.source.capacity())
                .sum();
            summary.peak_retained_source_bytes = summary.peak_retained_source_bytes.max(retained);
            for (id, result, _retained_scope) in measured {
                summary.submitted += 1;
                if let Ok(result) = &result {
                    summary.succeeded += 1;
                    summary.source_bytes += result.source.len();
                } else {
                    summary.failed += 1;
                }
                sink(id, result)?;
            }
        }
        Ok(summary)
    }
}

#[derive(Debug, Clone)]
pub struct StreamOptions {
    pub window: usize,
    pub max_input_bytes: usize,
    pub max_source_bytes: usize,
}
impl Default for StreamOptions {
    fn default() -> Self {
        Self {
            window: 8,
            max_input_bytes: 64 * 1024 * 1024,
            max_source_bytes: 128 * 1024 * 1024,
        }
    }
}
#[derive(Debug, Clone, Default, Serialize)]
pub struct StreamSummary {
    pub submitted: usize,
    pub succeeded: usize,
    pub failed: usize,
    pub source_bytes: usize,
    pub peak_buffered_input_bytes: usize,
    pub peak_retained_source_bytes: usize,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::execution::CancellationToken;
    #[test]
    fn streaming_order_errors_and_reused_pool_are_explicit() {
        let pool = DecompilePool::new(2).unwrap();
        let config = Config::default();
        let fixture = include_bytes!("../tests/fixtures/arithmetic.O1.D2.bc").to_vec();
        let mut seen = Vec::new();
        let inputs = (0..20).map(|id| Ok((id, if id == 7 { vec![255] } else { fixture.clone() })));
        let report = pool
            .stream(inputs, &config, &StreamOptions::default(), |id, result| {
                seen.push((id, result.is_ok()));
                Ok(())
            })
            .unwrap();
        assert_eq!(
            seen.iter().map(|item| item.0).collect::<Vec<_>>(),
            (0..20).collect::<Vec<_>>()
        );
        assert_eq!(
            (report.submitted, report.succeeded, report.failed),
            (20, 19, 1)
        );
        assert!(report.peak_retained_source_bytes <= StreamOptions::default().max_source_bytes);
        let token = CancellationToken::new();
        token.cancel();
        assert_eq!(
            pool.decompile(&fixture, &config, ExecutionContext::new(token, None))
                .unwrap_err()
                .stage,
            "cancelled"
        );
    }
    #[test]
    fn streaming_input_resource_scopes_release_each_window() {
        let pool = DecompilePool::new(2).unwrap();
        let mut config = Config::default();
        config.validation.mode = crate::quality::ValidationMode::Off;
        let fixture = include_bytes!("../tests/fixtures/arithmetic.O1.D2.bc").to_vec();
        let budget = crate::execution::MemoryBudget::new(4 * 1024 * 1024);
        let context = ExecutionContext::new(CancellationToken::new(), None)
            .with_work_limit(config.limits.max_analysis_steps)
            .with_memory(budget.clone())
            .unwrap();
        execution::with_context(context, || {
            let inputs = (0..100).map(|id| Ok((id, fixture.clone())));
            let report = pool
                .stream(inputs, &config, &StreamOptions::default(), |_, result| {
                    assert!(result.is_ok());
                    Ok(())
                })
                .unwrap();
            assert_eq!(report.succeeded, 100);
            assert_eq!(budget.used(), 64 * 1024);
        });
        assert_eq!(budget.used(), 0);
        assert!(budget.peak() < 4 * 1024 * 1024);
    }
}
