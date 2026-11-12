use luau_decompiler::{decompile, Config, Limits};
use std::path::PathBuf;

fn bounded_config() -> Config {
    Config {
        validation: luau_decompiler::quality::ValidationConfig {
            mode: luau_decompiler::quality::ValidationMode::Off,
            ..Default::default()
        },
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
    }
}

#[test]
fn malformed_fixture_mutations_never_panic_in_the_full_pipeline() {
    let config = bounded_config();
    let directory = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let mut paths: Vec<_> = std::fs::read_dir(directory)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|s| s == "bc"))
        .collect();
    paths.sort();
    let mut mutations = 0;
    let mut accepted = 0;
    for path in paths {
        let original = std::fs::read(&path).unwrap();
        let mut bytes = original.clone();
        for position in (0..bytes.len()).step_by(17) {
            for mask in [1, 128, 255] {
                bytes[position] ^= mask;
                let result = std::panic::catch_unwind(|| decompile(&bytes, &config));
                let result = result.unwrap_or_else(|_| {
                    panic!(
                        "pipeline panicked: {}, byte {position}, mask {mask}",
                        path.display()
                    )
                });
                if let Ok(decompiled) = result {
                    accepted += 1;
                    assert!(decompiled.source.len() <= config.limits.max_output_bytes);
                    assert_eq!(decompiled.stats.output_bytes, decompiled.source.len());
                }
                bytes[position] = original[position];
                mutations += 1;
            }
        }
    }
    assert!(mutations > 1000);
    eprintln!(
        "full pipeline: {mutations} mutations, {accepted} successful reconstructions, no panics"
    );
}

#[test]
fn deterministic_random_noise_is_bounded_without_panics() {
    let config = bounded_config();
    let mut state = 0x6c756175_6465636fu64;
    for iteration in 0..10000 {
        let mut bytes = vec![0u8; iteration % 257];
        for byte in &mut bytes {
            state ^= state << 13;
            state ^= state >> 7;
            state ^= state << 17;
            *byte = state as u8;
        }
        let _ = decompile(&bytes, &config);
    }
}
