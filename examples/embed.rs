use luau_decompiler::execution::{CancellationToken, ExecutionContext};
use luau_decompiler::input::InputFormat;
use luau_decompiler::processing::Processor;
use luau_decompiler::{Config, OutputPolicy};
use std::time::{Duration, Instant};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let processor = Processor::new(2)?;
    let config = Config {
        output_policy: OutputPolicy::VerifiedTyped,
        ..Config::default()
    };
    let cancellation = CancellationToken::new();
    let context =
        ExecutionContext::new(cancellation, Some(Instant::now() + Duration::from_secs(15)));
    let result = processor.process(
        b"local answer: number = 42\nreturn answer\n",
        InputFormat::LuauSource,
        &config,
        context,
    )?;
    if result.validation.required_passed {
        print!("{}", result.source);
    } else {
        eprintln!("{}", serde_json::to_string_pretty(&result)?);
        return Err(
            "verified typed quality gate failed; faithful source retained in the structured result"
                .into(),
        );
    }
    Ok(())
}
