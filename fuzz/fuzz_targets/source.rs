#![no_main]
use libfuzzer_sys::fuzz_target;
use luau_decompiler::execution::{CancellationToken, ExecutionContext, MemoryBudget};
use luau_decompiler::input::InputFormat;
use luau_decompiler::processing::process;
use luau_decompiler::quality::ValidationMode;
use luau_decompiler::{execution, Config};
use std::time::{Duration, Instant};

fuzz_target!(|input: &[u8]| {
    if input.len() > 16384 {
        return;
    }
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    config.limits.max_bytes = 16384;
    config.limits.max_output_bytes = 65536;
    config.limits.max_depth = 16;
    config.limits.max_analysis_steps = 50000;
    config.typing.max_nodes = 8192;
    let context = ExecutionContext::new(
        CancellationToken::new(),
        Some(Instant::now() + Duration::from_secs(1)),
    )
    .with_memory(MemoryBudget::new(8 * 1024 * 1024))
    .unwrap();
    execution::with_context(context, || {
        let _ = process(input, InputFormat::LuauSource, &config);
    });
});
