use serde::Serialize;

pub const LEGACY_REVISION: &str = "8cc289fae430d9b0c22bde209fe5cf2d01751ff1";
pub const MODERN_REVISION: &str = "12a6ba75883272c79b66b59815efef4c574196f6";
pub const V7_REVISION: &str = "86d2a9dcd7cef396b73b1585371723e169e69a41";
pub const V9_REVISION: &str = "5bc7f4b23756f69f4669b419fa9034f117ccd6fe";

#[derive(Clone, Copy, Debug, Serialize)]
pub struct Profile {
    pub id: &'static str,
    pub bytecode_version: u8,
    pub upstream_revision: &'static str,
    pub type_header: bool,
    pub vector_constants: bool,
    pub table_values: bool,
    pub integer_constants: bool,
    pub userdata_instructions: bool,
    pub class_constants: bool,
    pub feedback: bool,
    pub sized_prototypes: bool,
    pub vector_double_constants: bool,
    pub fast_pcall: bool,
    pub flags_mask: u8,
    pub maximum_type_tag: u8,
    pub builtin_count: u8,
    pub decoding_support: &'static str,
    pub reconstruction_support: &'static str,
    pub semantic_limitations: &'static [&'static str],
}

const COMMON_LIMITATIONS: &[&str] = &[
    "Reconstruction success is determined per program; decoding is not semantic validation.",
    "Executor encryption, compression and opcode encoding require an explicit normalizer.",
    "Integer constants, classes and prototype-identity guards are rejected.",
    "FASTPCALL requires a proven matching pcall/xpcall fallback and complete argument/capture/liveness evidence.",
    "Native userdata atom callbacks cannot be reconstructed from bytecode alone.",
];

const fn profile(version: u8, id: &'static str) -> Profile {
    Profile {
        id,
        bytecode_version: version,
        upstream_revision: if version <= 6 {
            LEGACY_REVISION
        } else if version <= 8 {
            V7_REVISION
        } else if version <= 12 {
            V9_REVISION
        } else {
            MODERN_REVISION
        },
        type_header: version >= 4,
        vector_constants: version >= 5,
        table_values: version >= 7,
        integer_constants: version >= 8,
        userdata_instructions: version >= 9,
        class_constants: version >= 10,
        feedback: version >= 11,
        sized_prototypes: version >= 12,
        vector_double_constants: version >= 13,
        fast_pcall: version >= 14,
        flags_mask: if version >= 13 {
            31
        } else if version >= 7 {
            15
        } else {
            7
        },
        maximum_type_tag: if version >= 10 {
            12
        } else if version >= 8 {
            10
        } else {
            9
        },
        builtin_count: if version <= 6 {
            89
        } else if version <= 12 {
            133
        } else {
            135
        },
        decoding_support: "validated_subset",
        reconstruction_support: "per_program_with_explicit_rejection",
        semantic_limitations: COMMON_LIMITATIONS,
    }
}

pub static PROFILES: &[Profile] = &[
    profile(3, "luau-v3"),
    profile(4, "luau-v4"),
    profile(5, "luau-v5"),
    profile(6, "luau-v6"),
    profile(7, "luau-v7"),
    profile(8, "luau-v8"),
    profile(9, "luau-v9"),
    profile(10, "luau-v10"),
    profile(11, "luau-v11"),
    profile(12, "luau-v12"),
    profile(13, "luau-v13"),
    profile(14, "luau-v14"),
];

pub fn for_version(version: u8) -> Option<&'static Profile> {
    PROFILES
        .iter()
        .find(|profile| profile.bytecode_version == version)
}

pub fn by_id(id: &str) -> Option<&'static Profile> {
    PROFILES.iter().find(|profile| profile.id == id)
}

pub fn capabilities() -> serde_json::Value {
    serde_json::json!({
        "profiles": PROFILES,
        "normalizers": ["upstream", "roblox_opcode227"],
        "complete_for_all_programs": false,
        "behavioral_evidence": "docs/compatibility.md"
    })
}
