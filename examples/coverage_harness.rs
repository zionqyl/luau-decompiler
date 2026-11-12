#[cfg(feature = "coverage-harness")]
mod instrumented {
    use luau_decompiler::{
        decompile,
        execution::{self, CancellationToken, ExecutionContext, MemoryBudget},
        Config, Limits,
    };
    use serde::Deserialize;
    use serde_json::json;
    use std::ffi::CString;
    use std::io::{BufRead, Read, Write};
    use std::time::{Duration, Instant};

    unsafe extern "C" {
        fn __llvm_profile_write_file() -> std::os::raw::c_int;
        fn __llvm_profile_reset_counters();
        fn __llvm_profile_set_filename(filename: *const std::os::raw::c_char);
        fn __llvm_profile_begin_names() -> *const u8;
        fn __llvm_profile_end_names() -> *const u8;
    }
    #[cfg(windows)]
    #[link(name = "kernel32")]
    unsafe extern "system" {
        fn GetModuleHandleW(name: *const u16) -> *mut std::ffi::c_void;
    }
    #[derive(Deserialize)]
    #[serde(deny_unknown_fields)]
    struct Request {
        input_path: String,
        profile_path: String,
    }
    pub fn run() -> Result<(), String> {
        if std::env::args().nth(1).as_deref() == Some("--coverage-layout") {
            #[cfg(windows)]
            unsafe {
                let base = GetModuleHandleW(std::ptr::null()) as usize;
                let begin = __llvm_profile_begin_names() as usize;
                let end = __llvm_profile_end_names() as usize;
                println!(
                    "{}",
                    json!({"names_rva":begin-base,"names_bytes":end-begin})
                );
                return Ok(());
            }
            #[cfg(not(windows))]
            return Err("PE coverage layout requested on a non-Windows target".into());
        }
        std::panic::set_hook(Box::new(|_| {}));
        let mut config = Config {
            limits: Limits {
                max_bytes: 16 * 1024,
                max_strings: 256,
                max_string_bytes: 8192,
                max_protos: 16,
                max_instructions: 1024,
                max_constants: 512,
                max_depth: 8,
                max_blocks: 256,
                max_output_bytes: 64 * 1024,
                max_analysis_steps: 100_000,
            },
            ..Config::default()
        };
        config.typing.mode = luau_decompiler::types::TypingMode::Off;
        config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
        let stdin = std::io::stdin();
        let mut stdout = std::io::stdout().lock();
        for line in stdin.lock().lines() {
            let line = line.map_err(|e| e.to_string())?;
            if line.len() > 16384 {
                return Err("harness request line exceeds bound".into());
            }
            let request: Request = serde_json::from_str(&line).map_err(|e| e.to_string())?;
            if request.input_path.len() > 4096 || request.profile_path.len() > 4096 {
                return Err("harness path exceeds bound".into());
            }
            let mut bytes = Vec::new();
            std::fs::File::open(&request.input_path)
                .map_err(|e| e.to_string())?
                .take(config.limits.max_bytes as u64 + 1)
                .read_to_end(&mut bytes)
                .map_err(|e| e.to_string())?;
            let filename = CString::new(request.profile_path).map_err(|e| e.to_string())?;
            let memory = MemoryBudget::new(8 * 1024 * 1024);
            let context = ExecutionContext::new(
                CancellationToken::new(),
                Some(Instant::now() + Duration::from_secs(2)),
            )
            .with_work_limit(config.limits.max_analysis_steps)
            .with_memory(memory.clone())
            .map_err(|e| e.to_string())?;

            unsafe {
                __llvm_profile_set_filename(filename.as_ptr());
                __llvm_profile_reset_counters();
            }
            let start = Instant::now();
            let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                execution::with_context(context, || decompile(&bytes, &config))
            }));
            let elapsed = start.elapsed().as_micros();
            let profile_status = unsafe { __llvm_profile_write_file() };
            let output = match result {
                Ok(Ok(value)) => {
                    json!({"status":"accepted","complete":value.complete,"source_bytes":value.source.len(),"elapsed_micros":elapsed,"profile_status":profile_status,"accounted_peak_bytes":memory.peak()})
                }
                Ok(Err(error)) => {
                    json!({"status":"rejected","stage":error.stage,"elapsed_micros":elapsed,"profile_status":profile_status,"accounted_peak_bytes":memory.peak()})
                }
                Err(payload) => {
                    let message = payload
                        .downcast_ref::<String>()
                        .cloned()
                        .or_else(|| payload.downcast_ref::<&str>().map(|s| (*s).into()))
                        .unwrap_or_else(|| "non-string panic".into());
                    json!({"status":"panic","message":message.chars().take(512).collect::<String>(),"elapsed_micros":elapsed,"profile_status":profile_status,"accounted_peak_bytes":memory.peak()})
                }
            };
            serde_json::to_writer(&mut stdout, &output).map_err(|e| e.to_string())?;
            stdout.write_all(b"\n").map_err(|e| e.to_string())?;
            stdout.flush().map_err(|e| e.to_string())?;
            if profile_status != 0 {
                return Err("LLVM profile write failed".into());
            }
        }
        Ok(())
    }
}
#[cfg(feature = "coverage-harness")]
fn main() {
    if let Err(error) = instrumented::run() {
        eprintln!("{error}");
        std::process::exit(2);
    }
}
#[cfg(not(feature = "coverage-harness"))]
fn main() {
    eprintln!("Use scripts/fuzz-coverage.ps1, which builds --features coverage-harness with -Cinstrument-coverage.");
    std::process::exit(2);
}
