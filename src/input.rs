use crate::{Error, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum InputFormat {
    #[default]
    Auto,
    LuauBytecode,
    LuauSource,
    LuaSource,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct DetectedInput {
    pub format: InputFormat,
    pub utf8_bom: bool,
}

pub fn detect(input: &[u8], requested: InputFormat) -> Result<DetectedInput> {
    if input.starts_with(b"\x1bLua") {
        let version = input.get(4).copied().map_or_else(
            || "unknown".into(),
            |version| format!("{}.{}, header 0x{version:02x}", version >> 4, version & 15),
        );
        return Err(Error::new(
            "input_format",
            format!(
                "standard Lua bytecode ({version}) is recognized but has no implemented backend"
            ),
        ));
    }
    if input.starts_with(b"\x1bLJ") {
        return Err(Error::new(
            "input_format",
            "LuaJIT bytecode is recognized but has no implemented backend",
        ));
    }
    if input.starts_with(b"\xff\xfe") || input.starts_with(b"\xfe\xff") {
        return Err(Error::new(
            "input_encoding",
            "UTF-16 source is unsupported; provide UTF-8 source without text-converting bytecode",
        ));
    }
    if input.is_empty() {
        if matches!(requested, InputFormat::LuauSource | InputFormat::LuaSource) {
            return Ok(DetectedInput {
                format: requested,
                utf8_bom: false,
            });
        }
        return Err(Error::new(
            "input_format",
            "empty input is ambiguous; provide nonempty source or a serialized Luau module",
        ));
    }
    let version_header = input.first().is_some_and(|version| {
        (crate::bytecode::MIN_VERSION..=crate::bytecode::MAX_VERSION).contains(version)
    });
    let binary_header = version_header
        && (!input[0].is_ascii_whitespace() || input.get(1).is_some_and(|version| *version <= 3));
    let format = match requested {
        InputFormat::Auto if binary_header => InputFormat::LuauBytecode,
        InputFormat::Auto => InputFormat::LuauSource,
        format => format,
    };
    if format == InputFormat::LuauBytecode {
        if !version_header {
            return Err(Error::new(
                "input_format",
                format!(
                    "expected serialized Luau bytecode version {}..={}; first byte is 0x{:02x}",
                    crate::bytecode::MIN_VERSION,
                    crate::bytecode::MAX_VERSION,
                    input[0]
                ),
            )
            .at_offset(0));
        }
        return Ok(DetectedInput {
            format,
            utf8_bom: false,
        });
    }
    if binary_header || input[0] == 0 || input[0] == 0x1b {
        return Err(Error::new(
            "input_format",
            "binary input cannot be interpreted as source; select a supported bytecode format explicitly",
        ).at_offset(0));
    }
    let utf8_bom = input.starts_with(b"\xef\xbb\xbf");
    let source_bytes = if utf8_bom { &input[3..] } else { input };
    let source = std::str::from_utf8(source_bytes).map_err(|error| {
        Error::new(
            "input_encoding",
            "source must be valid UTF-8; invalid bytes are never replaced",
        )
        .at_offset(error.valid_up_to() + usize::from(utf8_bom) * 3)
    })?;
    if let Some((offset, _)) = source
        .bytes()
        .enumerate()
        .find(|(_, byte)| *byte < 32 && !matches!(byte, b'\t' | b'\n' | b'\r'))
    {
        return Err(Error::new(
            "input_encoding",
            "source contains an unsupported control byte",
        )
        .at_offset(offset + usize::from(utf8_bom) * 3));
    }
    if source.trim().is_empty() && requested == InputFormat::Auto {
        return Err(Error::new(
            "input_format",
            "whitespace-only input is ambiguous",
        ));
    }
    Ok(DetectedInput { format, utf8_bom })
}

pub fn capabilities() -> serde_json::Value {
    serde_json::json!({
        "detection": "content-aware; filename extensions are hints; explicit input_format override supported",
        "formats": [
            {"id":"luau_bytecode", "versions":(crate::bytecode::MIN_VERSION..=crate::bytecode::MAX_VERSION).collect::<Vec<_>>(), "encodings":["auto", "upstream", "roblox_opcode227", crate::bytecode::ROBLOX_SIGNATURE_PROFILE], "auto_encoding":"upstream raw modules or version9/version14 signed containers matching both observed-build marker equations; unmarked opcode227 requires explicit override", "signature_authenticity":"not_verified; opaque trailer preserved in provenance", "scope":"validated version profiles; individual unsupported semantics are rejected"},
            {"id":"luau_source", "encoding":"utf-8", "parser":"bounded Rust syntax parser with lossless token spans", "scope":"documented source subset; names, annotations, and runtime expression tokens retained; no compile/decompile round trip"},
            {"id":"lua_source", "dialect":"Lua 5.1 compatible syntax subset", "encoding":"utf-8", "scope":"documented common-language subset; requires a compatible standard-library/environment contract; Lua-specific bytecode unsupported"}
        ],
        "unsupported_formats":["standard_lua_bytecode", "luajit_bytecode"],
        "source_restrictions":["no interpolated strings", "no user-defined type functions", "no generic default parameters", "no class declarations or type metatable syntax", "Lua 5.1 subset requires compatible environment contracts and restricted standard generic iterators", "no Lua 5.2+ dialect conversion", "no implicit encoding guesses"],
        "network_required":false,
        "runtime_execution":false
    })
}
