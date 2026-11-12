use luau_decompiler::{decompile, quality::ValidationMode, Config};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::time::Instant;

fn main() {
    let mut config = Config::default();
    let mut iterations = 10usize;
    let mut cached = false;
    let mut paths = Vec::new();
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--config" => {
                config = serde_json::from_slice(
                    &std::fs::read(args.next().expect("config path")).expect("read config"),
                )
                .expect("parse config")
            }
            "--iterations" => {
                iterations = args
                    .next()
                    .expect("iterations")
                    .parse()
                    .expect("integer iterations")
            }
            "--cache" => cached = true,
            _ if arg.starts_with('-') => panic!("unknown argument {arg}"),
            _ => paths.push(arg),
        }
    }
    assert!((2..=100).contains(&iterations) && !paths.is_empty() && paths.len() <= 16);

    config.validation.mode = ValidationMode::Check;
    config.validation.max_cache_bytes = if cached { 16 * 1024 * 1024 } else { 0 };
    config.validate().expect("valid configuration");
    let inputs: Vec<_> = paths
        .iter()
        .map(|path| std::fs::read(path).expect("read bytecode"))
        .collect();
    let mut rows = Vec::new();
    let mut complete = true;
    for (input_index, (path, input)) in paths.iter().zip(&inputs).enumerate() {
        let mut source_hash = None;
        for iteration in 0..iterations {
            let start = Instant::now();
            let result = decompile(input, &config);
            let wall_ns = start.elapsed().as_nanos();
            let cohort = if input_index == 0 && iteration == 0 {
                "cold_worker_uncached"
            } else if cached && iteration > 0 {
                "warm_worker_result_cache_requested"
            } else {
                "warm_worker_uncached"
            };
            match result {
                Ok(output) => {
                    let hash = format!("{:x}", Sha256::digest(output.source.as_bytes()));
                    if let Some(expected) = &source_hash {
                        assert_eq!(expected, &hash, "output changed between validation runs");
                    }
                    source_hash = Some(hash.clone());
                    complete &= output.complete;
                    rows.push(json!({"path":path,"input_index":input_index,"iteration":iteration,"cohort":cohort,"wall_ns":wall_ns,"source_sha256":hash,"stats":output.stats,"validation":output.validation}));
                }
                Err(error) => {
                    complete = false;
                    rows.push(json!({"path":path,"iteration":iteration,"cohort":cohort,"wall_ns":wall_ns,"error":error}));
                }
            }
        }
    }
    println!("{}", serde_json::to_string_pretty(&json!({"schema":1,"config":config,"complete_reconstruction":complete,"note":"Fresh process per cache mode; first observation includes analyzer worker/definition startup. Later uncached observations reuse the worker. Cache-requested cohorts report the actual cache_hit field. These are quality checks, not behavioral equivalence tests.","results":rows})).unwrap());
    if !complete {
        std::process::exit(1);
    }
}
