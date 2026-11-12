use luau_decompiler::executors::{self, CatalogSnapshot, ProductKind};
use std::io::Read;
use std::path::Path;

fn cell(value: &str) -> String {
    value
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('\\', "\\\\")
        .replace('|', "\\|")
        .replace('`', "&#96;")
        .replace('[', "\\[")
        .replace(']', "\\]")
        .replace(['\r', '\n'], " ")
}
fn matrix(report: &CatalogSnapshot) -> String {
    let mut text=format!("# Executor discovery and platform matrix\n\nObserved {} from the [WEAO catalog]({}) using its required `{}` user agent. [API contract](https://docs.weao.xyz/weao-api-reference/exploits.md). This snapshot contains {} product/platform entries: {} executors and {} external tools. Raw SHA-256: `{}`. [Machine-readable evidence](results/executor-catalog-v3.json).\n\nCatalog versions and Roblox builds below are **advertised**, not independently measured. No catalog row is end-to-end compatibility evidence. Built-in decompiler advertising and UNC/sUNC scores are not used as proof. Architecture, target/getter/request contracts, byte handling, encoding, profile and supported options remain unverified for these advertised builds.\n\n| Product | Platform | Kind | Advertised executor version | Advertised Roblox build | Interface verification | Distinct native programs | Status |\n| --- | --- | --- | --- | --- | --- | ---: | --- |\n",cell(&report.observed_at_utc),executors::CATALOG_URL,executors::USER_AGENT,report.input_entries,report.executor_platform_entries,report.external_tool_entries,report.raw_sha256);
    for entry in &report.entries {
        let kind = match entry.kind {
            ProductKind::Executor => "executor",
            ProductKind::ExternalTool => "external tool",
            ProductKind::Unknown => "unknown",
        };
        text.push_str(&format!(
            "| {} | {} | {} | {} | {} | not run | 0 | catalog only |\n",
            cell(&entry.name),
            entry.platform.label(),
            kind,
            cell(
                entry
                    .advertised_executor_version
                    .as_deref()
                    .unwrap_or("unknown")
            ),
            cell(
                entry
                    .advertised_roblox_build
                    .as_deref()
                    .unwrap_or("unknown")
            )
        ));
    }
    text.push_str("\n## Evidence and unavailable environments\n\nMadium and Madius are separate products. The catalog's external-tool label does not establish whether that product exposes the required script, function, getter or HTTP interfaces; those interfaces must be probed against an explicitly selected build. Never inherit Madium evidence into Madius.\n\nThe historical [v0.2 Madium run](results/madium-live.json) exercised Madium 2.0.0 / Roblox 0.746.0.7461267 on Windows, explicit opcode227 and format14. It covers one native 47-byte compiler model with unknown original source provenance plus four supplied-bytecode source fixtures. Sixty-five repetitions are not sixty-five distinct native programs. This historical build differs from the catalog's advertised Madium version and does not certify v0.3 output. Current v0.3 client evidence belongs in separate integration reports identifying the executable, runtime and fixture identities.\n\n[Volt's documented decompile contract](https://docs.volt.rs/docs/scripts/decompile) and [Lynx's script APIs](https://getlynx.gg/docs/api/scripts) are documentation contracts, not live compatibility claims. Shared target-aware adapter dispatch applies documented wrappers only when selected explicitly and when required capabilities are present. Unsupported options fail explicitly.\n\nNo macOS build host/client was supplied for this run; tested macOS packages and live MacSploit/Opiumware integration are not claimed. Android/iOS same-device Rust services and a paired authenticated encrypted companion transport have not been run. A phone's loopback address cannot reach a PC service. Existing loopback transport must not be relabeled a mobile companion transport.\n\nA controlled place must provide engine-compiled known-source ModuleScripts, LocalScripts and client-run Scripts before broad native extraction can be verified. Where Studio or that place is unavailable, retain the fixture/procedure and mark the native matrix not run. Do not replace native program coverage with supplied bytecode or timing repetitions.\n\n## Refresh and schema handling\n\nRun `scripts/refresh-executors.ps1`. The cache uses a bounded body, freshness TTL, conditional HTTP requests and Retry-After cooldowns. Stale responses are labeled; failed refreshes do not turn old metadata into fresh evidence. The normalizer accepts documented arrays and known wrapper/field variations, reports rejected/duplicate rows in the denominator and publishes only allowlisted metadata. Raw sUNC keys, purchase details and descriptions are excluded.\n");
    if !report.starting_inventory_absent.is_empty() {
        text.push_str("\nStarting-review products absent from this snapshot (absence is not incompatibility): ");
        text.push_str(
            &report
                .starting_inventory_absent
                .iter()
                .map(|s| cell(s))
                .collect::<Vec<_>>()
                .join(", "),
        );
        text.push_str(".\n");
    }
    if !report.rejected_entries.is_empty() {
        text.push_str(&format!(
            "\nNormalization is incomplete: {} rejected rows are retained in the JSON report.\n",
            report.rejected_entries.len()
        ));
    }
    text
}
fn write(path: &str, bytes: &[u8]) -> Result<(), String> {
    if let Some(parent) = Path::new(path).parent() {
        std::fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    std::fs::write(path, bytes).map_err(|e| e.to_string())
}
fn run() -> Result<(), String> {
    let args: Vec<_> = std::env::args().skip(1).collect();
    if !(4..=5).contains(&args.len()) {
        return Err("usage: executor_catalog INPUT.json OUTPUT.json OBSERVED_UTC REFRESH_STATUS [MATRIX.md]".into());
    }
    let mut bytes = Vec::new();
    std::fs::File::open(&args[0])
        .map_err(|e| e.to_string())?
        .take(executors::MAX_CATALOG_BYTES as u64 + 1)
        .read_to_end(&mut bytes)
        .map_err(|e| e.to_string())?;
    let report = executors::parse_catalog(&bytes, &args[2], &args[3]).map_err(|e| e.to_string())?;
    if report.accepted_entries == 0 {
        return Err("catalog has no accepted entries; retain the previous cache".into());
    }
    write(
        &args[1],
        &serde_json::to_vec_pretty(&report).map_err(|e| e.to_string())?,
    )?;
    if let Some(path) = args.get(4) {
        write(path, matrix(&report).as_bytes())?;
    }
    println!(
        "Catalog {} / {} normalized; {} executors, {} external tools; {} rejected",
        report.accepted_entries,
        report.input_entries,
        report.executor_platform_entries,
        report.external_tool_entries,
        report.rejected_entries.len()
    );
    Ok(())
}
fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
