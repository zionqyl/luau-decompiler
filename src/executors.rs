use crate::{Error, Result};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::BTreeSet;

pub const CATALOG_URL: &str = "https://weao.xyz/api/status/exploits";
pub const USER_AGENT: &str = "WEAO-3PService";
pub const MAX_CATALOG_BYTES: usize = 4 * 1024 * 1024;
pub const MAX_CATALOG_ENTRIES: usize = 1024;

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, PartialOrd, Ord)]
#[serde(rename_all = "snake_case")]
pub enum Platform {
    Windows,
    Macos,
    Android,
    Ios,
    Linux,
    Unknown,
}
impl Platform {
    pub fn label(self) -> &'static str {
        match self {
            Self::Windows => "Windows",
            Self::Macos => "macOS",
            Self::Android => "Android",
            Self::Ios => "iOS",
            Self::Linux => "Linux",
            Self::Unknown => "unknown",
        }
    }
}
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum ProductKind {
    Executor,
    ExternalTool,
    Unknown,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CatalogEntry {
    pub id: String,
    pub name: String,
    pub platform: Platform,
    pub raw_platform: String,
    pub kind: ProductKind,
    pub catalog_type: Option<String>,
    pub advertised_executor_version: Option<String>,
    pub advertised_roblox_build: Option<String>,
    pub advertised_builtin_decompiler: Option<bool>,
    pub catalog_updated_at: Option<String>,
    pub website: Option<String>,
    pub architecture: Option<String>,
    pub interface_verification: String,
    pub native_end_to_end_status: String,
    pub distinct_native_programs_verified: usize,
    pub bytecode_encoding: Option<String>,
    pub bytecode_profile: Option<String>,
    pub limitations: Vec<String>,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RejectedEntry {
    pub index: usize,
    pub reason: String,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CatalogSnapshot {
    pub schema: u32,
    pub source_url: String,
    pub required_user_agent: String,
    pub raw_sha256: String,
    pub observed_at_utc: String,
    pub observation_provenance: String,
    pub refresh_status: String,
    pub input_entries: usize,
    pub accepted_entries: usize,
    pub executor_platform_entries: usize,
    pub external_tool_entries: usize,
    pub complete_normalization: bool,
    pub entries: Vec<CatalogEntry>,
    pub rejected_entries: Vec<RejectedEntry>,
    pub starting_inventory_absent: Vec<String>,
    pub evidence_boundary: String,
}

fn text(value: &Value, aliases: &[&str], limit: usize) -> Option<String> {
    aliases.iter().find_map(|key| {
        let value = value.get(*key)?;
        let value = match value {
            Value::String(value) => value.clone(),
            Value::Number(value) => value.to_string(),
            _ => return None,
        };
        let value = value.trim();
        if value.is_empty() || value.len() > limit || value.chars().any(char::is_control) {
            None
        } else {
            Some(value.into())
        }
    })
}
fn boolean(value: &Value, aliases: &[&str]) -> Option<bool> {
    aliases.iter().find_map(|key| match value.get(*key)? {
        Value::Bool(value) => Some(*value),
        Value::String(value) if value.eq_ignore_ascii_case("true") => Some(true),
        Value::String(value) if value.eq_ignore_ascii_case("false") => Some(false),
        _ => None,
    })
}
fn platform(raw: &str) -> Platform {
    match raw.to_ascii_lowercase().as_str() {
        "windows" | "win" | "win32" | "win64" => Platform::Windows,
        "mac" | "macos" | "osx" | "mac os" => Platform::Macos,
        "android" => Platform::Android,
        "ios" | "iphone" | "ipad" | "ipados" => Platform::Ios,
        "linux" => Platform::Linux,
        _ => Platform::Unknown,
    }
}
fn slug(value: &str) -> String {
    let mut result = String::new();
    for character in value.chars() {
        if character.is_ascii_alphanumeric() {
            result.push(character.to_ascii_lowercase());
        } else if !result.ends_with('-') {
            result.push('-');
        }
    }
    result.trim_matches('-').into()
}
fn array(value: &Value, depth: usize) -> Option<&Vec<Value>> {
    if depth > 4 {
        return None;
    }
    if let Some(values) = value.as_array() {
        return Some(values);
    }
    for key in ["exploits", "executors", "data", "results", "items"] {
        if let Some(child) = value.get(key) {
            if let Some(values) = array(child, depth + 1) {
                return Some(values);
            }
        }
    }
    None
}
fn normalize(value: &Value) -> Result<CatalogEntry> {
    if !value.is_object() {
        return Err(Error::new("catalog", "entry must be an object"));
    }
    let name = text(value, &["title", "name", "executor"], 128)
        .ok_or_else(|| Error::new("catalog", "entry has no bounded nonempty product name"))?;
    let raw_platform = text(value, &["platform", "os", "operatingSystem"], 128)
        .unwrap_or_else(|| "unknown".into());
    let platform = platform(&raw_platform);
    let catalog_type = text(value, &["extype", "type", "category"], 128);
    let category = catalog_type.as_deref().unwrap_or("").to_ascii_lowercase();
    let kind = if category.contains("external") {
        ProductKind::ExternalTool
    } else if category.contains("executor") {
        ProductKind::Executor
    } else {
        ProductKind::Unknown
    };
    let website = text(value, &["websitelink", "website", "url"], 2048).filter(|url| {
        (url.starts_with("https://") || url.starts_with("http://"))
            && !url.chars().any(char::is_whitespace)
    });
    let mut limitations=vec!["Catalog presence and advertised built-in decompilation are not extraction, transport, option-contract or end-to-end evidence.".into(),"Target/getter/request APIs, representation, encoding, feature subset and architecture remain unverified for this advertised build.".into()];
    if kind == ProductKind::ExternalTool {
        limitations.push("Catalog labels this an external tool. Whether it exposes the script/function/HTTP interfaces required by an adapter has not been established.".into());
    }
    if name.eq_ignore_ascii_case("Madium") {
        limitations.push("Madium is distinct from Madius. Historical live Madium 2.0.0 evidence does not certify a different advertised build.".into());
    }
    if name.eq_ignore_ascii_case("Madius") {
        limitations.push("Madius is not an alias for Madium; never inherit Madium's runtime evidence or adapter contract.".into());
    }
    if matches!(platform, Platform::Android | Platform::Ios) {
        limitations.push("Phone loopback cannot reach a PC service. Same-device service or an explicitly paired authenticated encrypted companion is required; neither is tested here.".into());
    }
    let id = format!("{}:{}", slug(&name), slug(platform.label()));
    Ok(CatalogEntry {
        id,
        name,
        platform,
        raw_platform,
        kind,
        catalog_type,
        advertised_executor_version: text(value, &["version", "executorVersion", "build"], 256),
        advertised_roblox_build: text(
            value,
            &["rbxversion", "robloxVersion", "roblox_version"],
            256,
        ),
        advertised_builtin_decompiler: boolean(
            value,
            &["decompiler", "hasDecompiler", "builtInDecompiler"],
        ),
        catalog_updated_at: text(value, &["updatedDate", "updated_at", "updatedAt"], 256),
        website,
        architecture: None,
        interface_verification: "not_run".into(),
        native_end_to_end_status: "not_run".into(),
        distinct_native_programs_verified: 0,
        bytecode_encoding: None,
        bytecode_profile: None,
        limitations,
    })
}

pub fn parse_catalog(
    bytes: &[u8],
    observed_at_utc: &str,
    refresh_status: &str,
) -> Result<CatalogSnapshot> {
    use sha2::{Digest, Sha256};
    if bytes.len() > MAX_CATALOG_BYTES {
        return Err(Error::new("catalog", "catalog exceeds 4 MiB"));
    }
    let value: Value = serde_json::from_slice(bytes)
        .map_err(|error| Error::new("catalog", format!("invalid catalog JSON: {error}")))?;
    let values=array(&value,0).ok_or_else(||Error::new("catalog","no supported catalog array: expected array or exploits/executors/data/results/items wrapper"))?;
    if values.is_empty() || values.len() > MAX_CATALOG_ENTRIES {
        return Err(Error::new(
            "catalog",
            "catalog must contain 1..1024 entries",
        ));
    }
    let mut entries = Vec::with_capacity(values.len());
    let mut rejected_entries = Vec::new();
    let mut ids = BTreeSet::new();
    for (index, value) in values.iter().enumerate() {
        match normalize(value) {
            Ok(entry) => {
                if !ids.insert(entry.id.clone()) {
                    rejected_entries.push(RejectedEntry {
                        index,
                        reason: format!("duplicate product/platform identity {}", entry.id),
                    });
                } else {
                    entries.push(entry);
                }
            }
            Err(error) => rejected_entries.push(RejectedEntry {
                index,
                reason: error.message,
            }),
        }
    }
    entries.sort_by(|a, b| {
        a.platform.cmp(&b.platform).then_with(|| {
            a.name
                .to_ascii_lowercase()
                .cmp(&b.name.to_ascii_lowercase())
        })
    });
    let starting = [
        ("Volt", Platform::Windows),
        ("Potassium", Platform::Windows),
        ("Wave", Platform::Windows),
        ("Synapse Z", Platform::Windows),
        ("Lucid", Platform::Windows),
        ("Lynx", Platform::Windows),
        ("Real", Platform::Windows),
        ("Madium", Platform::Windows),
        ("Isaeva", Platform::Windows),
        ("Volcano", Platform::Windows),
        ("Athena", Platform::Windows),
        ("Velocity", Platform::Windows),
        ("SirHurt", Platform::Windows),
        ("Solara", Platform::Windows),
        ("Xeno", Platform::Windows),
        ("MacSploit", Platform::Macos),
        ("Opiumware", Platform::Macos),
        ("Delta", Platform::Android),
        ("Vega X", Platform::Android),
        ("Delta", Platform::Ios),
    ];
    let starting_inventory_absent = starting
        .into_iter()
        .filter(|(name, platform)| {
            !entries
                .iter()
                .any(|entry| entry.name.eq_ignore_ascii_case(name) && entry.platform == *platform)
        })
        .map(|(name, platform)| format!("{name}/{}", platform.label()))
        .collect();
    Ok(CatalogSnapshot{schema:1,source_url:CATALOG_URL.into(),required_user_agent:USER_AGENT.into(),raw_sha256:format!("{:x}",Sha256::digest(bytes)),observed_at_utc:observed_at_utc.into(),observation_provenance:"Observed HTTP catalog snapshot; builds and product claims are advertised metadata, not independently verified runtime facts.".into(),refresh_status:refresh_status.into(),input_entries:values.len(),accepted_entries:entries.len(),executor_platform_entries:entries.iter().filter(|e|e.kind==ProductKind::Executor).count(),external_tool_entries:entries.iter().filter(|e|e.kind==ProductKind::ExternalTool).count(),complete_normalization:rejected_entries.is_empty(),entries,rejected_entries,starting_inventory_absent,evidence_boundary:"No catalog entry is promoted to tested adapter compatibility. Distinct native programs, supplied fixtures and repeated timing runs must be recorded by separate controlled integration evidence.".into()})
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn wrapper_and_field_variations_remain_typed() {
        let bytes=br#"{"data":{"results":[{"name":"Delta","os":"iOS","executorVersion":4,"roblox_version":"r1","type":"iexecutor","hasDecompiler":"false"}]}}"#;
        let parsed = parse_catalog(bytes, "date", "fixture").unwrap();
        assert_eq!(parsed.accepted_entries, 1);
        assert_eq!(parsed.entries[0].platform, Platform::Ios);
        assert_eq!(parsed.entries[0].advertised_builtin_decompiler, Some(false));
        assert_eq!(
            parsed.entries[0].advertised_executor_version.as_deref(),
            Some("4")
        );
    }
    #[test]
    fn madium_and_madius_never_share_identity_or_evidence() {
        let bytes=br#"[{"title":"Madium","platform":"Windows","extype":"wexecutor","decompiler":true,"sunc":{"secret":"not-published"}},{"title":"Madius","platform":"Windows","extype":"wexternal"}]"#;
        let parsed = parse_catalog(bytes, "date", "fixture").unwrap();
        assert_eq!(parsed.executor_platform_entries, 1);
        assert_eq!(parsed.external_tool_entries, 1);
        assert_ne!(parsed.entries[0].id, parsed.entries[1].id);
        assert!(parsed
            .entries
            .iter()
            .all(|e| e.native_end_to_end_status == "not_run"));
        assert!(!serde_json::to_string(&parsed)
            .unwrap()
            .contains("not-published"));
    }
    #[test]
    fn rejected_and_duplicate_entries_stay_in_denominator() {
        let parsed=parse_catalog(br#"[{"title":"One","platform":"Mac"},{"title":"One","platform":"macOS"},{"platform":"Windows"},17]"#,"date","fixture").unwrap();
        assert_eq!(parsed.input_entries, 4);
        assert_eq!(parsed.accepted_entries, 1);
        assert_eq!(parsed.rejected_entries.len(), 3);
        assert!(!parsed.complete_normalization);
        assert!(!parsed.starting_inventory_absent.is_empty());
    }
    #[test]
    fn schema_and_size_fail_explicitly() {
        for bytes in [b"null".as_slice(), b"{}", b"[]", b"{bad"] {
            assert!(parse_catalog(bytes, "date", "fixture").is_err());
        }
        assert!(parse_catalog(&vec![b' '; MAX_CATALOG_BYTES + 1], "date", "fixture").is_err());
    }
}
