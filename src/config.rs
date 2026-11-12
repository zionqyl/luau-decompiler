use crate::{Error, Result};
use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::BTreeMap;

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum OutputPolicy {
    Faithful,
    #[default]
    Annotated,
    VerifiedTyped,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum EntryOutput {
    #[default]
    Script,
    Function,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct MeaningfulTyping {
    pub min_useful_annotations: usize,
    pub min_runtime_annotations: usize,
    pub min_binding_coverage_percent: usize,
    pub min_useful_annotation_percent: usize,
    pub max_explicit_any: usize,
    pub max_inferred_any: usize,
    pub max_external_any: usize,
    pub max_external_unknown: usize,
    pub max_unmeasured_external_contracts: usize,
    pub max_inferred_unknown: usize,
    pub max_type_assertions: usize,
}

impl Default for MeaningfulTyping {
    fn default() -> Self {
        Self {
            min_useful_annotations: 1,
            min_runtime_annotations: 1,
            min_binding_coverage_percent: 75,
            min_useful_annotation_percent: 100,
            max_explicit_any: 0,
            max_inferred_any: 0,
            max_external_any: 0,
            max_external_unknown: 0,
            max_unmeasured_external_contracts: 0,
            max_inferred_unknown: 0,
            max_type_assertions: 0,
        }
    }
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum NameStyle {
    #[default]
    #[serde(rename = "snake_case")]
    SnakeCase,
    #[serde(rename = "camelCase", alias = "camel_case")]
    CamelCase,
    #[serde(rename = "PascalCase", alias = "pascal_case")]
    PascalCase,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ControlFlowMode {
    #[default]
    Auto,
    Structured,
    Dispatcher,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct NamingOptions {
    pub use_debug_names: bool,
    pub infer_descriptive_names: bool,
}
impl Default for NamingOptions {
    fn default() -> Self {
        Self {
            use_debug_names: true,
            infer_descriptive_names: true,
        }
    }
}

#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum EntryInvocation {
    #[default]
    Single,
    Repeated,
}
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct ClosureConfig {
    pub entry_invocation: EntryInvocation,
    pub compiler_closure_sharing: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Limits {
    pub max_bytes: usize,
    pub max_strings: usize,
    pub max_string_bytes: usize,
    pub max_protos: usize,
    pub max_instructions: usize,
    pub max_constants: usize,
    pub max_depth: usize,
    pub max_blocks: usize,
    pub max_output_bytes: usize,
    pub max_analysis_steps: usize,
}

impl Default for Limits {
    fn default() -> Self {
        Self {
            max_bytes: 16 * 1024 * 1024,
            max_strings: 100_000,
            max_string_bytes: 8 * 1024 * 1024,
            max_protos: 4096,
            max_instructions: 1_000_000,
            max_constants: 500_000,
            max_depth: 128,
            max_blocks: 100_000,
            max_output_bytes: 32 * 1024 * 1024,
            max_analysis_steps: 10_000_000,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Config {
    pub input_format: crate::input::InputFormat,
    pub entry_output: EntryOutput,
    pub output_policy: OutputPolicy,
    pub meaningful_typing: MeaningfulTyping,
    pub typing: crate::types::TypingConfig,
    pub formatting: crate::types::FormattingConfig,
    pub validation: crate::quality::ValidationConfig,

    pub profile: String,

    pub bytecode_encoding: String,
    pub control_flow: ControlFlowMode,

    pub vector_constructor: Option<String>,
    pub naming: NameStyle,
    pub naming_options: NamingOptions,
    pub closures: ClosureConfig,
    pub indent: String,

    pub name_overrides: BTreeMap<String, String>,
    pub limits: Limits,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            input_format: crate::input::InputFormat::Auto,
            entry_output: EntryOutput::default(),
            output_policy: OutputPolicy::default(),
            meaningful_typing: MeaningfulTyping::default(),
            typing: Default::default(),
            formatting: Default::default(),
            validation: Default::default(),
            profile: "auto".into(),
            bytecode_encoding: "auto".into(),
            control_flow: ControlFlowMode::Auto,
            vector_constructor: None,
            naming: NameStyle::default(),
            naming_options: Default::default(),
            closures: Default::default(),
            indent: "    ".into(),
            name_overrides: BTreeMap::new(),
            limits: Limits::default(),
        }
    }
}

impl Config {
    pub fn effective(&self) -> Cow<'_, Self> {
        match self.output_policy {
            OutputPolicy::Faithful if self.typing.mode != crate::types::TypingMode::Off => {
                let mut config = self.clone();
                config.typing.mode = crate::types::TypingMode::Off;
                Cow::Owned(config)
            }
            OutputPolicy::VerifiedTyped
                if self.validation.mode == crate::quality::ValidationMode::Check =>
            {
                let mut config = self.clone();
                config.validation.mode = crate::quality::ValidationMode::StrictRequired;
                Cow::Owned(config)
            }
            _ => Cow::Borrowed(self),
        }
    }

    pub fn validate(&self) -> Result<()> {
        if self.meaningful_typing.min_useful_annotations == 0
            || !(1..=100).contains(&self.meaningful_typing.min_binding_coverage_percent)
            || !(1..=100).contains(&self.meaningful_typing.min_useful_annotation_percent)
        {
            return Err(Error::new("config", "meaningful typing requires a positive annotation minimum and coverage percentages in 1..=100"));
        }
        if self.output_policy == OutputPolicy::VerifiedTyped
            && (self.validation.mode == crate::quality::ValidationMode::Off
                || self.typing.mode == crate::types::TypingMode::Off)
        {
            return Err(Error::new(
                "config",
                "verified_typed requires annotations and final-source validation",
            ));
        }
        self.typing.validate()?;
        self.formatting.validate()?;
        self.validation.validate()?;
        if self.profile != "auto" && crate::profiles::by_id(&self.profile).is_none() {
            return Err(Error::new(
                "config",
                format!("unknown bytecode profile {:?}", self.profile),
            ));
        }
        if !matches!(
            self.bytecode_encoding.as_str(),
            "auto" | "upstream" | "roblox_opcode227" | crate::bytecode::ROBLOX_SIGNATURE_PROFILE
        ) {
            return Err(Error::new(
                "config",
                "bytecode_encoding must be auto, upstream, roblox_opcode227 or roblox_signed_74171870",
            ));
        }
        if let Some(path) = &self.vector_constructor {
            if path.len() > 128
                || path.split('.').count() > 3
                || !path.split('.').all(crate::names::is_identifier)
            {
                return Err(Error::new(
                    "config",
                    "vector_constructor must be a trusted identifier path of at most 128 bytes",
                ));
            }
        }
        if self.indent.len() > 16 || !self.indent.bytes().all(|b| b == b' ' || b == b'\t') {
            return Err(Error::new(
                "config",
                "indent must contain at most 16 spaces or tabs",
            ));
        }
        for (name, value) in [
            ("max_bytes", self.limits.max_bytes),
            ("max_strings", self.limits.max_strings),
            ("max_string_bytes", self.limits.max_string_bytes),
            ("max_protos", self.limits.max_protos),
            ("max_instructions", self.limits.max_instructions),
            ("max_constants", self.limits.max_constants),
            ("max_depth", self.limits.max_depth),
            ("max_blocks", self.limits.max_blocks),
            ("max_output_bytes", self.limits.max_output_bytes),
            ("max_analysis_steps", self.limits.max_analysis_steps),
        ] {
            if value == 0 || value > isize::MAX as usize / 64 {
                return Err(Error::new(
                    "config",
                    format!("{name} must be positive and fit allocation arithmetic"),
                ));
            }
        }
        if self.limits.max_depth > 256 {
            return Err(Error::new(
                "config",
                "max_depth must be at most 256 to bound native stack use",
            ));
        }
        for (key, value) in &self.name_overrides {
            let valid_key = key
                .strip_prefix('p')
                .and_then(|s| s.split_once(':'))
                .and_then(|(p, target)| {
                    let p = p.parse::<usize>().ok()?;
                    if let Some(r) = target.strip_prefix('r') {
                        Some(key == &format!("p{p}:r{}", r.parse::<u8>().ok()?))
                    } else {
                        Some(
                            key == &format!(
                                "p{p}:b{}",
                                target.strip_prefix('b')?.parse::<usize>().ok()?
                            ),
                        )
                    }
                })
                .unwrap_or(false);
            if !valid_key {
                return Err(Error::new(
                    "config",
                    format!("invalid override key {key:?}; expected p<proto>:b<binding> or legacy p<proto>:r<register>"),
                ));
            }
            if value.len() > 128 || !crate::names::is_identifier(value) {
                return Err(Error::new(
                    "config",
                    format!("override {key} is not a Luau identifier: {value:?}"),
                ));
            }
        }
        Ok(())
    }

    pub fn indentation(&self) -> &str {
        &self.indent
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn malformed_config_is_rejected() {
        assert!(serde_json::from_str::<Config>(r#"{"limts":{}}"#).is_err());
        assert!(serde_json::from_str::<Config>(r#"{"naming":"camelCase"}"#)
            .unwrap()
            .validate()
            .is_ok());
        let mut config = Config {
            indent: "\n".into(),
            ..Config::default()
        };
        assert!(config.validate().is_err());
        config.indent.clear();
        config.name_overrides.insert("p0:r0".into(), "end".into());
        assert!(config.validate().is_err());
    }
}
