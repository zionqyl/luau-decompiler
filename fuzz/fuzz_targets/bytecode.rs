#![no_main]
use libfuzzer_sys::fuzz_target;
use luau_decompiler::{bytecode, decompile, Config, Limits};

fuzz_target!(|input: &[u8]| {
    let config = Config {
        limits: Limits {
            max_bytes: 65536,
            max_strings: 512,
            max_string_bytes: 32768,
            max_protos: 64,
            max_instructions: 4096,
            max_constants: 1024,
            max_depth: 16,
            max_blocks: 1024,
            max_output_bytes: 262144,
            max_analysis_steps: 100000,
        },
        ..Config::default()
    };



    if bytecode::decode(input, &config.limits).is_ok() {
        let _ = decompile(input, &config);
    }
});
