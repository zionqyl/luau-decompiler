use crate::{CancellationToken, Config, ExecutionContext, InputFormat, MemoryBudget, Processor};
use std::time::Duration;
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = globalThis, js_name = __luauValidate, catch)]
    fn validate_frame(frame: &[u8]) -> std::result::Result<String, JsValue>;
    #[wasm_bindgen(js_namespace = globalThis, js_name = __luauValidationAssets, catch)]
    fn assets_descriptor() -> std::result::Result<String, JsValue>;
}

pub(crate) fn analyze_frame(frame: &[u8]) -> std::result::Result<String, String> {
    validate_frame(frame).map_err(|e| format!("browser analyzer failed: {e:?}"))
}

pub(crate) fn validation_assets() -> std::result::Result<String, String> {
    assets_descriptor().map_err(|e| format!("browser validation assets unavailable: {e:?}"))
}

#[wasm_bindgen]
pub fn engine_memory() -> JsValue {
    wasm_bindgen::memory()
}

#[wasm_bindgen]
pub fn detect(input: &[u8], format: &str) -> String {
    let operation = || -> crate::Result<_> {
        if input.len() > 2 * 1024 * 1024 {
            return Err(crate::Error::new("limit", "browser input exceeds2MiB"));
        }
        let format: InputFormat = serde_json::from_str(
            &serde_json::to_string(format)
                .map_err(|e| crate::Error::new("config", e.to_string()))?,
        )
        .map_err(|e| crate::Error::new("input_format", e.to_string()))?;
        crate::input::detect(input, format)
    };
    match operation() {
        Ok(detected) => {
            serde_json::json!({"ok":true,"format":detected.format,"utf8_bom":detected.utf8_bom})
                .to_string()
        }
        Err(error) => serde_json::json!({"ok":false,"error":error}).to_string(),
    }
}

#[wasm_bindgen]
pub fn capabilities() -> String {
    use sha2::Digest;
    let analyzer_source_sha256 = format!(
        "{:x}",
        sha2::Sha256::digest(include_bytes!("../tests/analyzer_runner.cpp"))
    );
    serde_json::json!({
        "schema":1,"engine_version":env!("CARGO_PKG_VERSION"),
        "inputs":crate::input::capabilities(),"profiles":crate::profiles::capabilities(),
        "analyzer_revision":crate::quality::ANALYZER_REVISION,
        "analyzer_source_sha256":analyzer_source_sha256,
        "definitions_sha256":crate::quality::ROBLOX_DEFINITIONS_SHA256,
        "processing":"browser_local","pthreads":false,"instance_workers":1,
        "max_input_bytes":2*1024*1024,"max_output_bytes":8*1024*1024,
        "max_configuration_bytes":8*1024*1024,"max_deadline_ms":120_000,
        "max_engine_accounted_bytes":256*1024*1024,
        "attribution":{"author":crate::attribution::AUTHOR,"repository":crate::attribution::REPOSITORY,"mandatory":true},
        "offline_reuse":"not_advertised; static assets must be available"
    }).to_string()
}

#[wasm_bindgen]
pub fn process(
    input: &[u8],
    format: &str,
    config_json: &str,
    deadline_ms: u32,
    memory_limit: u32,
) -> String {
    let operation = || -> crate::Result<_> {
        if input.len() > 2 * 1024 * 1024 || config_json.len() > 8 * 1024 * 1024 {
            return Err(crate::Error::new(
                "limit",
                "browser input or configuration exceeds its byte limit",
            ));
        }
        if !(100..=120_000).contains(&deadline_ms)
            || !(16 * 1024 * 1024..=256 * 1024 * 1024).contains(&memory_limit)
        {
            return Err(crate::Error::new(
                "config",
                "browser deadline must be100..120000ms and accounted engine memory16..256MiB",
            ));
        }
        let mut config: Config = serde_json::from_str(config_json)
            .map_err(|e| crate::Error::new("config", e.to_string()))?;
        let format: InputFormat = serde_json::from_str(
            &serde_json::to_string(format)
                .map_err(|e| crate::Error::new("config", e.to_string()))?,
        )
        .map_err(|e| crate::Error::new("input_format", e.to_string()))?;
        config.limits.max_bytes = config.limits.max_bytes.min(2 * 1024 * 1024);
        config.limits.max_output_bytes = config.limits.max_output_bytes.min(8 * 1024 * 1024);
        config.limits.max_analysis_steps = config.limits.max_analysis_steps.min(10_000_000);
        config.limits.max_depth = config.limits.max_depth.min(128);
        config.validation.max_workers = 1;
        config.validation.max_cache_bytes = 0;
        let context = ExecutionContext::new(
            CancellationToken::new(),
            Some(crate::platform::Instant::now() + Duration::from_millis(u64::from(deadline_ms))),
        )
        .with_work_limit(config.limits.max_analysis_steps)
        .with_memory(MemoryBudget::new(memory_limit as usize))?;
        Processor::new(1)?.process(input, format, &config, context)
    };
    match operation() {
        Ok(result)=>serde_json::json!({"schema":1,"engine_version":env!("CARGO_PKG_VERSION"),"ok":true,"result":result}).to_string(),
        Err(error)=>serde_json::json!({"schema":1,"engine_version":env!("CARGO_PKG_VERSION"),"ok":false,"error":error}).to_string(),
    }
}
