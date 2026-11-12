use serde::Serialize;
use std::fmt;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Clone, Serialize)]
pub struct Error {
    pub stage: &'static str,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub offset: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub proto: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub pc: Option<usize>,
}

impl Error {
    pub fn new(stage: &'static str, message: impl Into<String>) -> Self {
        Self {
            stage,
            message: message.into(),
            offset: None,
            proto: None,
            pc: None,
        }
    }
    pub fn at_offset(mut self, offset: usize) -> Self {
        self.offset = Some(offset);
        self
    }
    pub fn at_proto(mut self, proto: usize) -> Self {
        self.proto = Some(proto);
        self
    }
    pub fn at_pc(mut self, pc: usize) -> Self {
        self.pc = Some(pc);
        self
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.stage)?;
        if let Some(offset) = self.offset {
            write!(f, " at byte {offset}")?;
        }
        if let Some(proto) = self.proto {
            write!(f, " in proto {proto}")?;
        }
        if let Some(pc) = self.pc {
            write!(f, " at pc {pc}")?;
        }
        write!(f, ": {}", self.message)
    }
}
impl std::error::Error for Error {}
impl From<std::io::Error> for Error {
    fn from(value: std::io::Error) -> Self {
        Self::new("io", value.to_string())
    }
}
