#![allow(dead_code)]
use serde::{Deserialize, Serialize};

pub const PROTOCOL: &str = "LOBS/1";
pub const MAX_FRAME_BYTES: usize = 16 * 1024 * 1024;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "type", content = "value", rename_all = "snake_case")]
pub enum Value {
    Nil,
    Boolean(bool),
    Number(#[serde(serialize_with = "hex64", deserialize_with = "parse_hex64")] u64),
    String(Vec<u8>),
    Vector(Vec<u32>),
    Buffer { identity: u32, bytes: Vec<u8> },
    Opaque { vm_type: u8, identity: u32 },
}
fn hex64<S: serde::Serializer>(bits: &u64, serializer: S) -> Result<S::Ok, S::Error> {
    serializer.serialize_str(&format!("{bits:016x}"))
}
fn parse_hex64<'de, D: serde::Deserializer<'de>>(deserializer: D) -> Result<u64, D::Error> {
    let text = String::deserialize(deserializer)?;
    if text.len() != 16 {
        return Err(serde::de::Error::custom(
            "IEEE64 bits require sixteen hexadecimal digits",
        ));
    }
    u64::from_str_radix(&text, 16).map_err(serde::de::Error::custom)
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum EffectKind {
    Print,
    Warn,
}
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct Event {
    pub kind: EffectKind,
    pub values: Vec<Value>,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum Outcome {
    Return,
    Error,
    LoadError,
    HarnessError,
    Timeout,
}
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct Observation {
    pub protocol: &'static str,
    pub complete: bool,
    pub events: Vec<Event>,
    pub outcome: Outcome,
    pub terminal: Vec<Value>,
}

impl Observation {
    pub fn verified(&self) -> bool {
        self.protocol == PROTOCOL
            && self.complete
            && matches!(self.outcome, Outcome::Return | Outcome::Error)
            && (self.outcome != Outcome::Error || self.terminal.len() == 1)
            && !self
                .terminal
                .iter()
                .chain(self.events.iter().flat_map(|event| &event.values))
                .any(|value| matches!(value, Value::Opaque { .. }))
    }

    pub fn equivalent(&self, other: &Self) -> bool {
        self.verified() && other.verified() && self == other
    }
    pub fn decode(bytes: &[u8]) -> Result<Self, String> {
        if bytes.len() > MAX_FRAME_BYTES {
            return Err("observation exceeds frame limit".into());
        }
        let mut input = Reader {
            bytes,
            offset: 0,
            opaque: false,
            values: 0,
        };
        if input.take(5)? != b"LOBS\x01" {
            return Err("expected LOBS/1 observation".into());
        }
        let complete = match input.byte()? {
            0 => false,
            1 => true,
            _ => return Err("invalid complete flag".into()),
        };
        let count = input.word()? as usize;
        if count > 100_000 {
            return Err("event count exceeds limit".into());
        }
        let mut events = Vec::with_capacity(count);
        for _ in 0..count {
            let kind = match input.byte()? {
                1 => EffectKind::Print,
                2 => EffectKind::Warn,
                _ => return Err("unknown effect kind".into()),
            };
            events.push(Event {
                kind,
                values: input.tuple()?,
            });
        }
        let outcome = match input.byte()? {
            0 => Outcome::Return,
            1 => Outcome::Error,
            2 => Outcome::LoadError,
            3 => Outcome::HarnessError,
            4 => Outcome::Timeout,
            _ => return Err("unknown terminal outcome".into()),
        };
        let terminal = input.tuple()?;
        if outcome != Outcome::Return && terminal.len() != 1 {
            return Err("error outcomes require exactly one typed error value".into());
        }
        if input.offset != bytes.len() {
            return Err(format!(
                "{} trailing observation bytes",
                bytes.len() - input.offset
            ));
        }
        if complete && input.opaque {
            return Err("opaque values cannot claim complete observation".into());
        }
        Ok(Self {
            protocol: PROTOCOL,
            complete,
            events,
            outcome,
            terminal,
        })
    }
    pub fn encode(&self) -> Result<Vec<u8>, String> {
        let mut bytes = b"LOBS\x01".to_vec();
        bytes.push(u8::from(self.complete));
        put_word(&mut bytes, self.events.len())?;
        for event in &self.events {
            bytes.push(match event.kind {
                EffectKind::Print => 1,
                EffectKind::Warn => 2,
            });
            encode_tuple(&mut bytes, &event.values, false)?;
        }
        bytes.push(match self.outcome {
            Outcome::Return => 0,
            Outcome::Error => 1,
            Outcome::LoadError => 2,
            Outcome::HarnessError => 3,
            Outcome::Timeout => 4,
        });
        encode_tuple(&mut bytes, &self.terminal, false)?;
        if bytes.len() > MAX_FRAME_BYTES {
            return Err("observation exceeds frame limit".into());
        }
        Ok(bytes)
    }
}

pub fn encode_arguments(values: &[Value]) -> Result<Vec<u8>, String> {
    if values.len() > 4096 {
        return Err("argument count exceeds limit".into());
    }
    let mut bytes = b"LARG\x01".to_vec();
    encode_tuple(&mut bytes, values, true)?;
    if bytes.len() > MAX_FRAME_BYTES {
        return Err("argument frame exceeds limit".into());
    }
    Ok(bytes)
}
fn put_word(bytes: &mut Vec<u8>, value: usize) -> Result<(), String> {
    let value: u32 = value.try_into().map_err(|_| "length exceeds u32")?;
    bytes.extend_from_slice(&value.to_le_bytes());
    Ok(())
}
fn encode_tuple(bytes: &mut Vec<u8>, values: &[Value], arguments: bool) -> Result<(), String> {
    put_word(bytes, values.len())?;
    for value in values {
        match value {
            Value::Nil => bytes.push(0),
            Value::Boolean(b) => bytes.extend_from_slice(&[1, u8::from(*b)]),
            Value::Number(bits) => {
                bytes.push(2);
                bytes.extend_from_slice(&bits.to_le_bytes());
            }
            Value::String(text) => {
                bytes.push(3);
                put_word(bytes, text.len())?;
                bytes.extend_from_slice(text);
            }
            Value::Vector(parts) => {
                if !matches!(parts.len(), 3 | 4) {
                    return Err("vectors require three or four f32 components".into());
                }
                bytes.extend_from_slice(&[4, parts.len() as u8]);
                for part in parts {
                    bytes.extend_from_slice(&part.to_le_bytes());
                }
            }
            Value::Buffer {
                identity,
                bytes: data,
            } => {
                bytes.push(5);
                if !arguments {
                    bytes.extend_from_slice(&identity.to_le_bytes());
                }
                put_word(bytes, data.len())?;
                bytes.extend_from_slice(data);
            }
            Value::Opaque { vm_type, identity } => {
                if arguments {
                    return Err("opaque argument references are unsupported".into());
                }
                bytes.extend_from_slice(&[6, *vm_type]);
                bytes.extend_from_slice(&identity.to_le_bytes());
            }
        }
    }
    Ok(())
}

struct Reader<'a> {
    bytes: &'a [u8],
    offset: usize,
    opaque: bool,
    values: usize,
}
impl<'a> Reader<'a> {
    fn take(&mut self, count: usize) -> Result<&'a [u8], String> {
        if count > self.bytes.len() - self.offset {
            return Err(format!("truncated observation at byte {}", self.offset));
        }
        let result = &self.bytes[self.offset..self.offset + count];
        self.offset += count;
        Ok(result)
    }
    fn byte(&mut self) -> Result<u8, String> {
        Ok(self.take(1)?[0])
    }
    fn word(&mut self) -> Result<u32, String> {
        Ok(u32::from_le_bytes(self.take(4)?.try_into().unwrap()))
    }
    fn tuple(&mut self) -> Result<Vec<Value>, String> {
        let count = self.word()? as usize;
        if count > 65536 || count > self.bytes.len() - self.offset {
            return Err("tuple count exceeds remaining frame or limit".into());
        }
        self.values += count;
        if self.values > 1_000_000 {
            return Err("observation value count exceeds limit".into());
        }
        let mut values = Vec::with_capacity(count);
        for _ in 0..count {
            values.push(self.value()?);
        }
        Ok(values)
    }
    fn value(&mut self) -> Result<Value, String> {
        Ok(match self.byte()? {
            0 => Value::Nil,
            1 => match self.byte()? {
                0 => Value::Boolean(false),
                1 => Value::Boolean(true),
                _ => return Err("invalid boolean observation".into()),
            },
            2 => Value::Number(u64::from_le_bytes(self.take(8)?.try_into().unwrap())),
            3 => {
                let length = self.word()? as usize;
                Value::String(self.take(length)?.to_vec())
            }
            4 => {
                let count = self.byte()?;
                if !matches!(count, 3 | 4) {
                    return Err("invalid vector component count".into());
                }
                let mut parts = Vec::with_capacity(count as usize);
                for _ in 0..count {
                    parts.push(self.word()?);
                }
                Value::Vector(parts)
            }
            5 => {
                let identity = self.word()?;
                if identity == 0 {
                    return Err("buffer identity is zero".into());
                }
                let length = self.word()? as usize;
                Value::Buffer {
                    identity,
                    bytes: self.take(length)?.to_vec(),
                }
            }
            6 => {
                self.opaque = true;
                let vm_type = self.byte()?;
                let identity = self.word()?;
                if identity == 0 {
                    return Err("opaque identity is zero".into());
                }
                Value::Opaque { vm_type, identity }
            }
            tag => return Err(format!("unknown value tag {tag}")),
        })
    }
}
