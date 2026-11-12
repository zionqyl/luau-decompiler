#[path = "../tests/oracle/mod.rs"]
mod oracle;
use oracle::Observation;
use serde_json::json;

fn main() {
    let paths: Vec<_> = std::env::args().skip(1).collect();
    if paths.len() != 2 {
        eprintln!("usage: oracle_compare EXPECTED.obs ACTUAL.obs");
        std::process::exit(2);
    }
    let parse = |path: &str| {
        std::fs::read(path)
            .map_err(|e| format!("{path}: {e}"))
            .and_then(|bytes| Observation::decode(&bytes).map_err(|e| format!("{path}: {e}")))
    };
    let result =
        parse(&paths[0]).and_then(|expected| parse(&paths[1]).map(|actual| (expected, actual)));
    match result {
        Ok((expected, actual)) => {
            let matched = expected.equivalent(&actual);
            println!("{}", serde_json::to_string(&json!({"protocol": oracle::PROTOCOL, "matched": matched, "expected": expected, "actual": actual})).unwrap());
            if !matched {
                std::process::exit(1);
            }
        }
        Err(error) => {
            eprintln!("{error}");
            std::process::exit(2);
        }
    }
}
