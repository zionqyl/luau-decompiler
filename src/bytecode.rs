use crate::config::Limits;
use crate::error::{Error, Result};
use crate::profiles;
use std::collections::BTreeSet;

pub const UPSTREAM_REVISION: &str = "8cc289fae430d9b0c22bde209fe5cf2d01751ff1";
pub const MIN_VERSION: u8 = 3;
pub const MAX_VERSION: u8 = 14;

pub const ROBLOX_SIGNATURE_PROFILE: &str = "roblox_signed_74171870";
const ROBLOX_SIGNATURE_MARKERS: [u32; 2] = [0x7417_1870, 0x016a_c432];

#[derive(Clone, Debug, serde::Serialize)]
pub struct Representation {
    pub profile: String,
    pub encoding: String,
    pub body_bytes: usize,
    pub body_sha256: String,
    pub trailer: Vec<u8>,
    pub authenticity: String,
    pub evidence: Vec<String>,
}

fn signed_trailer(bytes: &[u8]) -> bool {
    if bytes.len() < 24 || !matches!(bytes.first(), Some(9 | 14)) {
        return false;
    }
    let tail = &bytes[bytes.len() - 24..];
    let word = u32::from_le_bytes(tail[..4].try_into().expect("four-byte signature word"));
    ROBLOX_SIGNATURE_MARKERS
        .iter()
        .enumerate()
        .all(|(i, marker)| {
            let start = 16 + i * 4;
            u32::from_le_bytes(tail[start..start + 4].try_into().expect("four-byte marker"))
                == word ^ marker
        })
}

pub fn detected_encoding(bytes: &[u8]) -> &'static str {
    if signed_trailer(bytes) {
        ROBLOX_SIGNATURE_PROFILE
    } else {
        "upstream"
    }
}

pub fn representation(bytes: &[u8], encoding: &str) -> Result<Representation> {
    use sha2::Digest;
    let selected = if encoding == "auto" || encoding == "roblox_opcode227" && signed_trailer(bytes)
    {
        detected_encoding(bytes)
    } else {
        encoding
    };
    let signed = selected == ROBLOX_SIGNATURE_PROFILE;
    if signed && !signed_trailer(bytes) {
        return Err(Error::new("representation", "roblox_signed_74171870 requires version 9 or 14 and both signature-trailer marker equations from the observed Roblox 0.747.0.7471481 build"));
    }
    let body_bytes = bytes.len().saturating_sub(if signed { 24 } else { 0 });
    Ok(Representation {
        profile: if signed { selected } else { "raw_luau" }.into(),
        encoding: if signed { "roblox_opcode227" } else { selected }.into(),
        body_bytes,
        body_sha256: format!("{:x}", sha2::Sha256::digest(&bytes[..body_bytes])),
        trailer: if signed {
            bytes[body_bytes..].to_vec()
        } else {
            Vec::new()
        },
        authenticity: if signed {
            "not_verified; opaque signature retained, cryptographic checker unavailable"
        } else {
            "not_present"
        }
        .into(),
        evidence: if signed {
            vec!["24-byte signature layout; https://dawn.rip/docs#bytecode-signer (different build marker constants)".into(), "Both marker equations independently observed in 23,629 retained Madium 2.0.0 script-getter buffers from Roblox 0.747.0.7471481; no signature forging or verification".into()]
        } else {
            Vec::new()
        },
    })
}

#[derive(Clone, Debug)]
pub struct Module {
    pub version: u8,
    pub type_version: u8,
    pub strings: Vec<Vec<u8>>,
    pub protos: Vec<Proto>,
    pub main: usize,

    pub userdata_types: std::collections::BTreeMap<u8, Option<usize>>,
}

#[derive(Clone, Debug)]
pub struct Proto {
    pub max_stack: u8,
    pub num_params: u8,
    pub num_upvalues: u8,
    pub is_vararg: bool,
    pub flags: u8,

    pub code: Vec<Instruction>,
    pub constants: Vec<Constant>,
    pub children: Vec<usize>,
    pub line_defined: u32,
    pub debug_name: Option<String>,
    pub locals: Vec<Local>,
    pub upvalue_names: Vec<String>,
    pub type_metadata: TypeMetadata,
}

#[derive(Clone, Debug, Default, serde::Serialize)]
pub struct TypeMetadata {
    pub version: u8,
    pub source_offset: usize,
    pub raw_bytes: Vec<u8>,
    pub parameters: Vec<MetadataType>,
    pub upvalues: Vec<MetadataType>,
    pub locals: Vec<TypedLocal>,
}

#[derive(Clone, Debug, serde::Serialize)]
pub struct MetadataType {
    pub tag: u8,
    pub source_offset: usize,
}

#[derive(Clone, Debug)]
pub struct Local {
    pub name: String,
    pub start_pc: usize,
    pub end_pc: usize,
    pub register: u8,
}

#[derive(Clone, Debug, PartialEq)]
pub enum Constant {
    Nil,
    Boolean(bool),
    Number(f64),
    String(usize),
    Import(u32),
    Table(Vec<usize>),

    TableWithConstants(Vec<(usize, Option<usize>)>),
    Closure(usize),
    Vector([f32; 4]),
    VectorDouble([f64; 4]),
}

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
pub enum Opcode {
    Nop,
    Break,
    LoadNil,
    LoadB,
    LoadN,
    LoadK,
    Move,
    GetGlobal,
    SetGlobal,
    GetUpval,
    SetUpval,
    CloseUpvals,
    GetImport,
    GetTable,
    SetTable,
    GetTableKs,
    SetTableKs,
    GetTableN,
    SetTableN,
    NewClosure,
    NameCall,
    Call,
    Return,
    Jump,
    JumpBack,
    JumpIf,
    JumpIfNot,
    JumpIfEq,
    JumpIfLe,
    JumpIfLt,
    JumpIfNotEq,
    JumpIfNotLe,
    JumpIfNotLt,
    Add,
    Sub,
    Mul,
    Div,
    Mod,
    Pow,
    AddK,
    SubK,
    MulK,
    DivK,
    ModK,
    PowK,
    And,
    Or,
    AndK,
    OrK,
    Concat,
    Not,
    Minus,
    Length,
    NewTable,
    DupTable,
    SetList,
    ForNPrep,
    ForNLoop,
    ForGLoop,
    ForGPrepInext,
    FastCall3,
    ForGPrepNext,
    NativeCall,
    GetVarargs,
    DupClosure,
    PrepVarargs,
    LoadKx,
    JumpX,
    FastCall,
    Coverage,
    Capture,
    SubRk,
    DivRk,
    FastCall1,
    FastCall2,
    FastCall2K,
    ForGPrep,
    JumpXEqKNil,
    JumpXEqKB,
    JumpXEqKN,
    JumpXEqKS,
    IDiv,
    IDivK,
    FastPcall = 89,
}

const OPCODES: &[Opcode] = &[
    Opcode::Nop,
    Opcode::Break,
    Opcode::LoadNil,
    Opcode::LoadB,
    Opcode::LoadN,
    Opcode::LoadK,
    Opcode::Move,
    Opcode::GetGlobal,
    Opcode::SetGlobal,
    Opcode::GetUpval,
    Opcode::SetUpval,
    Opcode::CloseUpvals,
    Opcode::GetImport,
    Opcode::GetTable,
    Opcode::SetTable,
    Opcode::GetTableKs,
    Opcode::SetTableKs,
    Opcode::GetTableN,
    Opcode::SetTableN,
    Opcode::NewClosure,
    Opcode::NameCall,
    Opcode::Call,
    Opcode::Return,
    Opcode::Jump,
    Opcode::JumpBack,
    Opcode::JumpIf,
    Opcode::JumpIfNot,
    Opcode::JumpIfEq,
    Opcode::JumpIfLe,
    Opcode::JumpIfLt,
    Opcode::JumpIfNotEq,
    Opcode::JumpIfNotLe,
    Opcode::JumpIfNotLt,
    Opcode::Add,
    Opcode::Sub,
    Opcode::Mul,
    Opcode::Div,
    Opcode::Mod,
    Opcode::Pow,
    Opcode::AddK,
    Opcode::SubK,
    Opcode::MulK,
    Opcode::DivK,
    Opcode::ModK,
    Opcode::PowK,
    Opcode::And,
    Opcode::Or,
    Opcode::AndK,
    Opcode::OrK,
    Opcode::Concat,
    Opcode::Not,
    Opcode::Minus,
    Opcode::Length,
    Opcode::NewTable,
    Opcode::DupTable,
    Opcode::SetList,
    Opcode::ForNPrep,
    Opcode::ForNLoop,
    Opcode::ForGLoop,
    Opcode::ForGPrepInext,
    Opcode::FastCall3,
    Opcode::ForGPrepNext,
    Opcode::NativeCall,
    Opcode::GetVarargs,
    Opcode::DupClosure,
    Opcode::PrepVarargs,
    Opcode::LoadKx,
    Opcode::JumpX,
    Opcode::FastCall,
    Opcode::Coverage,
    Opcode::Capture,
    Opcode::SubRk,
    Opcode::DivRk,
    Opcode::FastCall1,
    Opcode::FastCall2,
    Opcode::FastCall2K,
    Opcode::ForGPrep,
    Opcode::JumpXEqKNil,
    Opcode::JumpXEqKB,
    Opcode::JumpXEqKN,
    Opcode::JumpXEqKS,
    Opcode::IDiv,
    Opcode::IDivK,
];

impl Opcode {
    pub fn from_byte(value: u8) -> Option<Self> {
        if value == 89 {
            Some(Self::FastPcall)
        } else {
            OPCODES.get(value as usize).copied()
        }
    }

    pub fn has_aux(self) -> bool {
        use Opcode::*;
        matches!(
            self,
            GetGlobal
                | SetGlobal
                | GetImport
                | GetTableKs
                | SetTableKs
                | NameCall
                | JumpIfEq
                | JumpIfLe
                | JumpIfLt
                | JumpIfNotEq
                | JumpIfNotLe
                | JumpIfNotLt
                | NewTable
                | SetList
                | ForGLoop
                | LoadKx
                | FastCall2
                | FastCall2K
                | FastCall3
                | JumpXEqKNil
                | JumpXEqKB
                | JumpXEqKN
                | JumpXEqKS
        )
    }

    pub fn is_fastcall(self) -> bool {
        use Opcode::*;
        matches!(
            self,
            FastCall | FastCall1 | FastCall2 | FastCall2K | FastCall3 | FastPcall
        )
    }

    pub fn is_jump_d(self) -> bool {
        use Opcode::*;
        matches!(
            self,
            Jump | JumpBack
                | JumpIf
                | JumpIfNot
                | JumpIfEq
                | JumpIfLe
                | JumpIfLt
                | JumpIfNotEq
                | JumpIfNotLe
                | JumpIfNotLt
                | ForNPrep
                | ForNLoop
                | ForGPrep
                | ForGLoop
                | ForGPrepInext
                | ForGPrepNext
                | JumpXEqKNil
                | JumpXEqKB
                | JumpXEqKN
                | JumpXEqKS
        )
    }
}

#[derive(Copy, Clone, Debug)]
pub struct Instruction {
    pub pc: usize,
    pub word: u32,
    pub aux: Option<u32>,
    pub op: Opcode,
}

impl Instruction {
    pub fn a(&self) -> usize {
        ((self.word >> 8) & 255) as usize
    }
    pub fn b(&self) -> usize {
        ((self.word >> 16) & 255) as usize
    }
    pub fn c(&self) -> usize {
        (self.word >> 24) as usize
    }
    pub fn d(&self) -> i32 {
        (self.word as i32) >> 16
    }
    pub fn e(&self) -> i32 {
        (self.word as i32) >> 8
    }
    pub fn len(&self) -> usize {
        if self.aux.is_some() {
            2
        } else {
            1
        }
    }
    pub fn is_empty(&self) -> bool {
        false
    }
}

struct Reader<'a> {
    bytes: &'a [u8],
    pos: usize,

    base: usize,
    proto: Option<usize>,

    end: usize,
    operations: usize,
}

impl<'a> Reader<'a> {
    fn new(bytes: &'a [u8]) -> Self {
        Self {
            bytes,
            pos: 0,
            base: 0,
            proto: None,
            end: bytes.len(),
            operations: 0,
        }
    }

    fn error(&self, message: impl Into<String>) -> Error {
        let err = Error::new("decode", message).at_offset(self.base + self.pos);
        if let Some(p) = self.proto {
            err.at_proto(p)
        } else {
            err
        }
    }

    fn remaining(&self) -> usize {
        self.end.saturating_sub(self.pos)
    }

    fn take(&mut self, n: usize) -> Result<&'a [u8]> {
        self.operations = self.operations.wrapping_add(1);
        if self.operations & 1023 == 0 {
            crate::execution::checkpoint()?;
        }
        if n > self.remaining() {
            return Err(self.error(format!(
                "truncated input: need {n} bytes, have {}",
                self.remaining()
            )));
        }
        let result = &self.bytes[self.pos..self.pos + n];
        self.pos += n;
        Ok(result)
    }

    fn byte(&mut self) -> Result<u8> {
        Ok(self.take(1)?[0])
    }
    fn u32(&mut self) -> Result<u32> {
        let b = self.take(4)?;
        Ok(u32::from_le_bytes([b[0], b[1], b[2], b[3]]))
    }
    fn f32(&mut self) -> Result<f32> {
        Ok(f32::from_bits(self.u32()?))
    }
    fn f64(&mut self) -> Result<f64> {
        let b = self.take(8)?;
        Ok(f64::from_le_bytes([
            b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
        ]))
    }

    fn varint(&mut self) -> Result<u32> {
        let start = self.pos;
        let mut result = 0u32;
        for shift in (0..35).step_by(7) {
            let byte = self.byte()?;
            if shift == 28 && byte > 15 {
                return Err(self.error("varint exceeds 32 bits"));
            }
            result |= u32::from(byte & 127) << shift;
            if byte & 128 == 0 {
                if self.pos - start > 1 && byte == 0 {
                    return Err(self.error("noncanonical overlong varint"));
                }
                return Ok(result);
            }
        }
        Err(self.error("unterminated varint"))
    }

    fn varint64(&mut self) -> Result<u64> {
        let start = self.pos;
        let mut result = 0u64;
        for shift in (0..70).step_by(7) {
            let byte = self.byte()?;
            if shift == 63 && byte > 1 {
                return Err(self.error("varint exceeds 64 bits"));
            }
            result |= u64::from(byte & 127) << shift;
            if byte & 128 == 0 {
                if self.pos - start > 1 && byte == 0 {
                    return Err(self.error("noncanonical overlong varint64"));
                }
                return Ok(result);
            }
        }
        Err(self.error("unterminated varint64"))
    }

    fn count(&mut self, limit: usize, kind: &str, min_bytes: usize) -> Result<usize> {
        let count = self.varint()? as usize;
        if count > limit {
            return Err(self.error(format!("{kind} count {count} exceeds limit {limit}")));
        }
        if min_bytes > 0 && count > self.remaining() / min_bytes {
            return Err(self.error(format!("{kind} count {count} exceeds remaining input")));
        }
        Ok(count)
    }

    fn optional_string(&mut self, count: usize) -> Result<Option<usize>> {
        let id = self.varint()? as usize;
        if id > count {
            return Err(self.error(format!("string id {id} outside table of {count} strings")));
        }
        Ok(id.checked_sub(1))
    }

    fn string(&mut self, count: usize) -> Result<usize> {
        self.optional_string(count)?
            .ok_or_else(|| self.error("required string reference is null"))
    }
}

fn add_budget(
    total: &mut usize,
    amount: usize,
    limit: usize,
    reader: &Reader<'_>,
    kind: &str,
) -> Result<()> {
    *total = total
        .checked_add(amount)
        .ok_or_else(|| reader.error(format!("{kind} budget overflow")))?;
    if *total > limit {
        return Err(reader.error(format!("aggregate {kind} {total} exceeds limit {limit}")));
    }
    Ok(())
}

fn debug_string(
    bytes: &[u8],
    total: &mut usize,
    limits: &Limits,
    r: &Reader<'_>,
) -> Result<String> {
    crate::execution::reserve_decoded_capacity(bytes.len().saturating_mul(3))?;
    let text = String::from_utf8_lossy(bytes);
    add_budget(
        total,
        text.len(),
        limits.max_string_bytes,
        r,
        "expanded debug name bytes",
    )?;
    Ok(text.into_owned())
}

#[derive(Clone, Debug, serde::Serialize)]
pub struct TypedLocal {
    pub register: u8,
    pub start: usize,
    pub end: usize,
    pub type_info: MetadataType,
}

fn valid_type(t: u8, maximum_type_tag: u8) -> bool {
    let base = t & 127;
    base <= maximum_type_tag || base == 15 || (64..96).contains(&base)
}

struct TypeInfoContext {
    version: u8,
    num_params: u8,
    num_upvalues: u8,
    max_stack: u8,
    maximum_type_tag: u8,
}

fn validate_typeinfo(
    bytes: &[u8],
    base: usize,
    p: usize,
    context: TypeInfoContext,
    limits: &Limits,
) -> Result<TypeMetadata> {
    if bytes.is_empty() {
        return Ok(TypeMetadata {
            version: context.version,
            source_offset: base,
            ..TypeMetadata::default()
        });
    }
    let TypeInfoContext {
        version,
        num_params,
        num_upvalues,
        max_stack,
        maximum_type_tag,
    } = context;
    let mut r = Reader {
        bytes,
        pos: 0,
        base,
        proto: Some(p),
        end: bytes.len(),
        operations: 0,
    };
    let (signature, upvalues, locals) = if version == 1 {
        (bytes.len(), 0, 0)
    } else {
        (
            r.count(bytes.len(), "type signature bytes", 1)?,
            r.count(num_upvalues as usize, "typed upvalues", 1)?,
            r.count(limits.max_instructions, "typed locals", 4)?,
        )
    };
    crate::execution::reserve_decoded_capacity(
        bytes
            .len()
            .saturating_add(
                (num_params as usize + upvalues)
                    .saturating_mul(std::mem::size_of::<MetadataType>()),
            )
            .saturating_add(locals.saturating_mul(std::mem::size_of::<TypedLocal>())),
    )?;
    let mut result = TypeMetadata {
        version,
        source_offset: base,
        raw_bytes: bytes.to_vec(),
        ..TypeMetadata::default()
    };
    if signature > 0 {
        let signature_base = r.base + r.pos;
        let sig = r.take(signature)?;
        if sig.len() != 2 + num_params as usize || sig[0] != 5 || sig[1] != num_params {
            return Err(r.error("invalid function type signature (expected FUNCTION, parameter count, parameter types)"));
        }
        if sig[2..].iter().any(|&t| !valid_type(t, maximum_type_tag)) {
            return Err(r.error("invalid parameter type tag"));
        }
        result.parameters = sig[2..]
            .iter()
            .enumerate()
            .map(|(i, &tag)| MetadataType {
                tag,
                source_offset: signature_base + 2 + i,
            })
            .collect();
    }
    let upvalue_base = r.base + r.pos;
    for (i, &t) in r.take(upvalues)?.iter().enumerate() {
        if !valid_type(t, maximum_type_tag) {
            return Err(r.error("invalid upvalue type tag"));
        }
        result.upvalues.push(MetadataType {
            tag: t,
            source_offset: upvalue_base + i,
        });
    }
    result.locals.reserve(locals);
    for _ in 0..locals {
        let type_offset = r.base + r.pos;
        let type_tag = r.byte()?;
        if !valid_type(type_tag, maximum_type_tag) {
            return Err(r.error("invalid local type tag"));
        }
        let register = r.byte()?;
        if register >= max_stack {
            return Err(r.error("typed local register outside stack"));
        }
        let start = r.varint()? as usize;
        let duration = r.varint()? as usize;
        let end = start
            .checked_add(duration)
            .ok_or_else(|| r.error("typed local range overflow"))?;
        result.locals.push(TypedLocal {
            register,
            start,
            end,
            type_info: MetadataType {
                tag: type_tag,
                source_offset: type_offset,
            },
        });
    }
    if r.remaining() != 0 {
        return Err(r.error("trailing bytes in type information"));
    }
    Ok(result)
}

pub fn decode(bytes: &[u8], limits: &Limits) -> Result<Module> {
    decode_with_options(bytes, limits, "auto", "upstream")
}

pub fn decode_with_profile(bytes: &[u8], limits: &Limits, profile: &str) -> Result<Module> {
    decode_with_options(bytes, limits, profile, "upstream")
}

pub fn decode_with_options(
    bytes: &[u8],
    limits: &Limits,
    profile_id: &str,
    encoding: &str,
) -> Result<Module> {
    crate::execution::checkpoint()?;
    let selected_encoding =
        if encoding == "auto" || encoding == "roblox_opcode227" && signed_trailer(bytes) {
            detected_encoding(bytes)
        } else {
            encoding
        };
    let signed = selected_encoding == ROBLOX_SIGNATURE_PROFILE;
    if signed && !signed_trailer(bytes) {
        return Err(Error::new("representation", "invalid or unsupported Roblox signature container; expected version 9 or 14 and both observed-build marker equations; no trailer bytes were removed"));
    }
    let opcode_multiplier = match selected_encoding {
        "upstream" => 1u8,
        "roblox_opcode227" | ROBLOX_SIGNATURE_PROFILE => 203u8,
        other => {
            return Err(Error::new(
                "decode",
                format!("unsupported bytecode encoding {other:?}"),
            ))
        }
    };
    if bytes.len() > limits.max_bytes {
        return Err(Error::new(
            "decode",
            format!(
                "input size {} exceeds limit {}",
                bytes.len(),
                limits.max_bytes
            ),
        )
        .at_offset(0));
    }
    let mut r = Reader::new(bytes);
    let version = r.byte()?;
    if version == 0 {
        let text = String::from_utf8_lossy(&bytes[1..bytes.len().min(1025)]);
        return Err(r.error(format!("compiler error packet: {text}")));
    }
    let profile = profiles::for_version(version).ok_or_else(|| r.error(format!("unsupported bytecode version {version}; select an implemented pinned profile (3..=14); experimental class version 100 is unsupported")))?;
    if profile_id != "auto" {
        let requested = profiles::by_id(profile_id)
            .ok_or_else(|| r.error(format!("unknown semantic profile {profile_id:?}")))?;
        if requested.bytecode_version != version {
            return Err(r.error(format!(
                "profile {profile_id} requires bytecode version {}, got {version}",
                requested.bytecode_version
            )));
        }
    }
    let type_version = if profile.type_header {
        let t = r.byte()?;
        if !(1..=3).contains(&t) {
            return Err(r.error(format!(
                "unsupported type encoding version {t}; supported versions are 1..=3"
            )));
        }
        t
    } else {
        0
    };
    let string_count = r.count(limits.max_strings, "strings", 1)?;
    crate::execution::charge_work(string_count)?;
    crate::execution::reserve_decoded_capacity(
        string_count.saturating_mul(std::mem::size_of::<Vec<u8>>()),
    )?;
    let mut strings = Vec::with_capacity(string_count);
    let mut string_bytes = 0;
    for _ in 0..string_count {
        let length = r.count(limits.max_string_bytes, "string bytes", 1)?;
        add_budget(
            &mut string_bytes,
            length,
            limits.max_string_bytes,
            &r,
            "string bytes",
        )?;
        crate::execution::reserve_decoded_capacity(length)?;
        crate::execution::charge_work(length / 16 + 1)?;
        strings.push(r.take(length)?.to_vec());
    }
    let mut userdata_types = std::collections::BTreeMap::new();
    if type_version == 3 {
        let mut used = [false; 32];
        loop {
            let index = r.byte()?;
            if index == 0 {
                break;
            }
            if index > 32 || used[index as usize - 1] {
                return Err(r.error(format!(
                    "invalid or duplicate userdata type mapping index {index}"
                )));
            }
            used[index as usize - 1] = true;

            crate::execution::reserve_decoded_capacity(128)?;
            userdata_types.insert(index, r.optional_string(strings.len())?);
        }
    }
    let proto_count = r.count(limits.max_protos, "prototypes", 10)?;
    crate::execution::reserve_decoded_capacity(
        proto_count.saturating_mul(std::mem::size_of::<Proto>() + std::mem::size_of::<usize>()),
    )?;
    if proto_count == 0 {
        return Err(r.error("prototype table is empty"));
    }
    let mut protos = Vec::with_capacity(proto_count);
    let mut depths = Vec::with_capacity(proto_count);
    let mut total_instructions = 0;
    let mut total_constants = 0;
    let mut total_feedback = 0;

    let mut metadata_string_bytes = 0;
    for p in 0..proto_count {
        crate::execution::checkpoint()?;
        r.proto = Some(p);
        let proto_end = if profile.sized_prototypes {
            let size = r.count(limits.max_bytes, "prototype size", 1)?;
            let end = r
                .pos
                .checked_add(size)
                .ok_or_else(|| r.error("prototype size overflow"))?;
            r.end = end;
            Some(end)
        } else {
            None
        };
        let max_stack = r.byte()?;
        let num_params = r.byte()?;
        let num_upvalues = r.byte()?;
        let vararg = r.byte()?;
        if num_params > max_stack || num_upvalues > 200 || vararg > 1 {
            return Err(r.error(
                "invalid function header (stack, parameter/upvalue count, or vararg flag)",
            ));
        }
        let flags = if profile.type_header { r.byte()? } else { 0 };
        if flags & !profile.flags_mask != 0 {
            return Err(r.error(format!("unsupported prototype flags 0x{flags:02x}")));
        }
        let typed = if profile.type_header {
            let size = r.count(limits.max_bytes, "type information bytes", 1)?;
            let base = r.pos;
            let data = r.take(size)?;
            validate_typeinfo(
                data,
                base,
                p,
                TypeInfoContext {
                    version: type_version,
                    num_params,
                    num_upvalues,
                    max_stack,
                    maximum_type_tag: profile.maximum_type_tag,
                },
                limits,
            )?
        } else {
            TypeMetadata::default()
        };
        let words = r.count(limits.max_instructions.min(1 << 23), "instruction words", 4)?;
        crate::execution::charge_work(words)?;
        add_budget(
            &mut total_instructions,
            words,
            limits.max_instructions,
            &r,
            "instruction words",
        )?;
        if words == 0 {
            return Err(r.error("function instruction stream is empty"));
        }

        crate::execution::reserve_decoded_capacity(words.saturating_mul(
            2 * std::mem::size_of::<Instruction>() + 4 * std::mem::size_of::<usize>(),
        ))?;
        let mut code = Vec::with_capacity(words.min(1024));
        let mut feedback_calls = Vec::new();
        let code_offset = r.pos;
        let mut pc = 0;
        while pc < words {
            let encoded_word = r.u32()?;
            let raw_opcode = (encoded_word as u8).wrapping_mul(opcode_multiplier);
            let word = (encoded_word & !255) | u32::from(raw_opcode);
            let is_feedback_call = raw_opcode == 87 && profile.feedback;
            let op = if is_feedback_call {
                Opcode::Call
            } else {
                Opcode::from_byte(raw_opcode).ok_or_else(|| {
                    let detail = match raw_opcode {
                        83..=85 => "GETUDATAKS/SETUDATAKS/NAMECALLUDATA require native userdata atom callback evidence",
                        86 => "NEWCLASSMEMBER class reconstruction is unsupported",
                        87 => "CALLFB is not available before bytecode version 11",
                        88 => "CMPPROTO requires unrecoverable runtime prototype identity",
                        90..=94 => "experimental class opcode is unsupported",
                        _ => "unknown opcode",
                    };
                    r.error(format!("{detail} ({raw_opcode}) in profile {}", profile.id)).at_pc(pc)
                })?
            };
            if matches!(op, Opcode::Break | Opcode::NativeCall) {
                return Err(r.error(format!("{op:?} requires runtime-only state absent from serialized compiler bytecode")).at_pc(pc));
            }
            if (version < 4 && matches!(op, Opcode::IDiv | Opcode::IDivK))
                || (version < 5 && matches!(op, Opcode::SubRk | Opcode::DivRk))
                || (version < 6 && op == Opcode::FastCall3)
                || (version < 14 && op == Opcode::FastPcall)
            {
                return Err(r
                    .error(format!(
                        "{op:?} is not available in bytecode version {version}"
                    ))
                    .at_pc(pc));
            }
            let aux = if op.has_aux() || is_feedback_call {
                if pc + 1 >= words {
                    return Err(r.error(format!("missing AUX word for {op:?}")).at_pc(pc));
                }
                Some(r.u32()?)
            } else {
                None
            };
            if is_feedback_call {
                feedback_calls.push((pc, aux.unwrap()));
            }
            let inst = Instruction { pc, word, aux, op };
            pc += inst.len();
            code.push(inst);
        }
        let constant_count = r.count(limits.max_constants.min(1 << 23), "constants", 1)?;
        crate::execution::charge_work(constant_count)?;
        add_budget(
            &mut total_constants,
            constant_count,
            limits.max_constants,
            &r,
            "constants",
        )?;
        crate::execution::reserve_decoded_capacity(
            constant_count.saturating_mul(std::mem::size_of::<Constant>()),
        )?;
        let mut constants = Vec::with_capacity(constant_count);
        for k in 0..constant_count {
            let constant = match r.byte()? {
                0 => Constant::Nil,
                1 => {
                    let value = r.byte()?;
                    if value > 1 {
                        return Err(r.error("boolean constant must be 0 or 1"));
                    }
                    Constant::Boolean(value == 1)
                }
                2 => Constant::Number(r.f64()?),
                3 => Constant::String(r.string(strings.len())?),
                4 => {
                    let import = r.u32()?;
                    validate_import(import, &constants)
                        .map_err(|m| r.error(format!("constant {k}: {m}")))?;
                    Constant::Import(import)
                }
                5 => {
                    let count = r.count(limits.max_constants, "table template keys", 1)?;
                    crate::execution::reserve_decoded_capacity(count.saturating_mul(64))?;
                    let mut keys = Vec::with_capacity(count);
                    let mut seen = BTreeSet::new();
                    for _ in 0..count {
                        let key = r.varint()? as usize;
                        let c = constants.get(key).ok_or_else(|| {
                            r.error(format!(
                                "table template key {key} must reference an earlier constant"
                            ))
                        })?;
                        if matches!(
                            c,
                            Constant::Nil
                                | Constant::Import(_)
                                | Constant::Table(_)
                                | Constant::TableWithConstants(_)
                                | Constant::Closure(_)
                        ) || matches!(c, Constant::Number(n) if n.is_nan())
                        {
                            return Err(
                                r.error(format!("invalid table template key constant {key}"))
                            );
                        }
                        if !seen.insert(key) {
                            return Err(r.error(format!("duplicate table template key {key}")));
                        }
                        keys.push(key);
                    }
                    Constant::Table(keys)
                }
                6 => {
                    let id = r.varint()? as usize;
                    if id >= p {
                        return Err(r.error(format!(
                            "closure constant prototype {id} must precede current prototype {p}"
                        )));
                    }
                    Constant::Closure(id)
                }
                7 if profile.vector_constants => Constant::Vector([r.f32()?, r.f32()?, r.f32()?, r.f32()?]),
                8 if profile.table_values => {
                    let count = r.count(limits.max_constants, "table template entries", 5)?;
                    crate::execution::reserve_decoded_capacity(count.saturating_mul(80))?;
                    let mut entries = Vec::with_capacity(count);
                    let mut seen = BTreeSet::new();
                    for _ in 0..count {
                        let key = r.varint()? as usize;
                        let constant = constants.get(key).ok_or_else(|| r.error(format!("table template key {key} must reference an earlier constant")))?;
                        if matches!(constant, Constant::Nil | Constant::Import(_) | Constant::Table(_) | Constant::TableWithConstants(_) | Constant::Closure(_)) || matches!(constant, Constant::Number(n) if n.is_nan()) {
                            return Err(r.error(format!("invalid table template key constant {key}")));
                        }
                        if !seen.insert(key) { return Err(r.error(format!("duplicate table template key {key}"))); }
                        let value = r.u32()? as i32;
                        if value < -1 || value >= k as i32 { return Err(r.error(format!("table template value {value} must be -1 or reference an earlier constant"))); }
                        if value >= 0 && matches!(constants[value as usize], Constant::Import(_) | Constant::Table(_) | Constant::TableWithConstants(_) | Constant::Closure(_)) { return Err(r.error("table template value requires a scalar constant")); }
                        entries.push((key, (value >= 0).then_some(value as usize)));
                    }
                    Constant::TableWithConstants(entries)
                }
                9 if profile.integer_constants => return Err(r.error("INTEGER (64-bit) constant reconstruction is unsupported; integer values must not be rounded to floating point")),
                10 if profile.class_constants => return Err(r.error("CLASS_SHAPE constant reconstruction is unsupported")),
                11 if profile.vector_double_constants => Constant::VectorDouble([r.f64()?, r.f64()?, r.f64()?, r.f64()?]),
                tag => {
                    return Err(r.error(format!(
                        "unknown or unsupported constant tag {tag} in version {version}"
                    )))
                }
            };
            constants.push(constant);
        }
        let child_count = r.count(32768.min(limits.max_protos), "child prototypes", 1)?;
        crate::execution::reserve_decoded_capacity(
            child_count.saturating_mul(std::mem::size_of::<usize>()),
        )?;
        let mut children = Vec::with_capacity(child_count);
        let mut depth = 1usize;
        for _ in 0..child_count {
            let id = r.varint()? as usize;
            if id >= p {
                return Err(r.error(format!(
                    "child prototype {id} must precede current prototype {p}"
                )));
            }
            depth = depth.max(depths[id] + 1);
            children.push(id);
        }
        for c in &constants {
            if let Constant::Closure(id) = c {
                depth = depth.max(depths[*id] + 1);
            }
        }
        if depth > limits.max_depth {
            return Err(r.error(format!(
                "closure dependency depth {depth} exceeds limit {}",
                limits.max_depth
            )));
        }
        depths.push(depth);
        let line_defined = r.varint()?;
        let debug_name = if let Some(s) = r.optional_string(strings.len())? {
            Some(debug_string(
                &strings[s],
                &mut metadata_string_bytes,
                limits,
                &r,
            )?)
        } else {
            None
        };
        let has_lines = r.byte()?;
        if has_lines > 1 {
            return Err(r.error("line information flag must be 0 or 1"));
        }
        if has_lines != 0 {
            let gap = r.byte()?;
            if gap > 31 {
                return Err(r.error("line information gap exponent exceeds 31"));
            }
            let intervals = ((words - 1) >> gap) + 1;
            r.take(words)?;
            let line_bytes = intervals
                .checked_mul(4)
                .ok_or_else(|| r.error("line information size overflow"))?;
            r.take(line_bytes)?;
        }
        let has_debug = r.byte()?;
        if has_debug > 1 {
            return Err(r.error("debug information flag must be 0 or 1"));
        }
        let mut locals = Vec::new();
        let mut upvalue_names = Vec::new();
        if has_debug != 0 {
            let local_count = r.count(limits.max_instructions, "debug locals", 4)?;
            crate::execution::reserve_decoded_capacity(
                local_count.saturating_mul(std::mem::size_of::<Local>()),
            )?;
            locals.reserve(local_count);
            for _ in 0..local_count {
                let name = r.string(strings.len())?;
                let start_pc = r.varint()? as usize;
                let end_pc = r.varint()? as usize;
                let register = r.byte()?;
                if register >= max_stack || start_pc > end_pc || end_pc > words {
                    return Err(r.error("invalid debug local register or lifetime range"));
                }
                let name = debug_string(&strings[name], &mut metadata_string_bytes, limits, &r)?;
                locals.push(Local {
                    name,
                    start_pc,
                    end_pc,
                    register,
                });
            }
            let count = r.count(num_upvalues as usize, "debug upvalue names", 1)?;
            if count != num_upvalues as usize {
                return Err(r.error("debug upvalue count differs from function header"));
            }
            crate::execution::reserve_decoded_capacity(
                count.saturating_mul(std::mem::size_of::<String>()),
            )?;
            upvalue_names.reserve(count);
            for _ in 0..count {
                let name = r.string(strings.len())?;
                upvalue_names.push(debug_string(
                    &strings[name],
                    &mut metadata_string_bytes,
                    limits,
                    &r,
                )?);
            }
        }
        if profile.feedback {
            let count = r.count(limits.max_instructions, "feedback slots", 2)?;
            add_budget(
                &mut total_feedback,
                count,
                limits.max_instructions,
                &r,
                "feedback slots",
            )?;
            crate::execution::reserve_decoded_capacity(
                count.saturating_mul(std::mem::size_of::<usize>()),
            )?;
            let mut slots = Vec::with_capacity(count);
            for _ in 0..count {
                let kind = r.byte()?;
                if kind != 0 {
                    return Err(r.error(format!("unsupported feedback slot kind {kind}; class-construction feedback is unsupported")));
                }
                let target = r.varint()? as usize;
                if feedback_calls
                    .binary_search_by_key(&target, |&(pc, _)| pc)
                    .is_err()
                {
                    return Err(r.error(format!(
                        "feedback slot targets pc {target}, which is not CALLFB"
                    )));
                }
                slots.push(target);
            }
            for &(pc, slot) in &feedback_calls {
                if slot != u32::MAX && slots.get(slot as usize).copied() != Some(pc) {
                    return Err(r
                        .error(format!(
                            "CALLFB feedback slot {slot} does not describe its instruction"
                        ))
                        .at_pc(pc));
                }
            }
        }
        if profile.sized_prototypes && flags & 8 != 0 {
            r.varint64()?;
        }
        if let Some(end) = proto_end {
            if r.pos != end {
                return Err(r.error(format!("prototype size leaves {} unexplained bytes; unknown trailing fields are unsupported", end - r.pos)));
            }
            r.end = bytes.len();
        }
        for t in &typed.locals {
            if t.start > t.end || t.end > words || t.register >= max_stack {
                return Err(r.error("typed local range outside instruction stream"));
            }
        }
        let proto = Proto {
            max_stack,
            num_params,
            num_upvalues,
            is_vararg: vararg != 0,
            type_metadata: typed,
            flags,
            code,
            constants,
            children,
            line_defined,
            debug_name,
            locals,
            upvalue_names,
        };
        validate_proto(
            &proto,
            &protos,
            p,
            words,
            code_offset,
            profile.builtin_count,
        )?;
        protos.push(proto);
    }
    r.proto = None;
    let main = r.varint()? as usize;
    if main >= protos.len() {
        return Err(r.error(format!("main prototype {main} outside prototype table")));
    }
    if protos[main].num_upvalues != 0 {
        return Err(r.error("main prototype must not have upvalues"));
    }
    if signed {
        if r.remaining() != 24 {
            return Err(r.error(format!("Roblox signature container has {} bytes after its validated main prototype; exactly 24 are required", r.remaining())));
        }
        r.take(24)?;
    }
    if r.remaining() != 0 {
        return Err(r.error(format!(
            "{} trailing bytes after main prototype",
            r.remaining()
        )));
    }
    Ok(Module {
        version,
        type_version,
        strings,
        protos,
        main,
        userdata_types,
    })
}

fn validate_import(import: u32, constants: &[Constant]) -> std::result::Result<(), String> {
    let count = import >> 30;
    if count == 0 {
        return Err("import path length must be 1..=3".into());
    }
    for i in 0..count {
        let key = ((import >> (20 - 10 * i)) & 1023) as usize;
        if !matches!(constants.get(key), Some(Constant::String(_))) {
            return Err(format!(
                "import path element {key} does not reference a string constant"
            ));
        }
    }
    Ok(())
}

fn import_paths_equal(left: u32, right: u32) -> bool {
    let count = left >> 30;
    count != 0 && count == right >> 30 && left >> (30 - count * 10) == right >> (30 - count * 10)
}

fn validate_proto(
    proto: &Proto,
    previous: &[Proto],
    p: usize,
    words: usize,
    code_offset: usize,
    builtin_count: u8,
) -> Result<()> {
    use Opcode::*;
    let err = |i: &Instruction, m: String| {
        Error::new("validate", m)
            .at_proto(p)
            .at_pc(i.pc)
            .at_offset(code_offset + i.pc * 4)
    };
    crate::execution::reserve_decoded_capacity(
        words
            .saturating_mul(std::mem::size_of::<usize>() + 1)
            .saturating_add(
                proto
                    .code
                    .len()
                    .saturating_mul(std::mem::size_of::<Option<usize>>()),
            ),
    )?;
    let mut headers = vec![usize::MAX; words];
    let mut capture_owner = vec![None; proto.code.len()];
    for (n, i) in proto.code.iter().enumerate() {
        if n & 1023 == 0 {
            crate::execution::checkpoint()?;
        }
        headers[i.pc] = n;
    }
    for (n, i) in proto.code.iter().enumerate() {
        let child = match i.op {
            NewClosure => {
                let id = usize::try_from(i.d())
                    .ok()
                    .and_then(|d| proto.children.get(d))
                    .copied()
                    .ok_or_else(|| {
                        err(
                            i,
                            format!("child index {} outside child prototype table", i.d()),
                        )
                    })?;
                Some(id)
            }
            DupClosure => {
                let c = usize::try_from(i.d())
                    .ok()
                    .and_then(|d| proto.constants.get(d));
                if let Some(Constant::Closure(id)) = c {
                    Some(*id)
                } else {
                    return Err(err(
                        i,
                        format!("DUPCLOSURE constant {} is not a closure", i.d()),
                    ));
                }
            }
            _ => None,
        };
        if let Some(child) = child {
            for u in 0..previous[child].num_upvalues as usize {
                let pos = n + 1 + u;
                let cap = proto
                    .code
                    .get(pos)
                    .ok_or_else(|| err(i, "closure capture sequence is truncated".into()))?;
                if cap.op != Capture || cap.pc != i.pc + 1 + u || capture_owner[pos].is_some() {
                    return Err(err(
                        cap,
                        "expected contiguous CAPTURE for closure upvalue".into(),
                    ));
                }
                if i.op == DupClosure && cap.a() == 1 {
                    return Err(err(
                        cap,
                        "DUPCLOSURE cannot capture a register by reference".into(),
                    ));
                }
                capture_owner[pos] = Some(n);
            }
        }
    }
    let mut jump_targets = vec![false; words];
    let mut open_refs = BTreeSet::new();
    let check_target = |i: &Instruction, target: i64| -> Result<usize> {
        if target < 0 || target >= words as i64 {
            return Err(err(
                i,
                format!("jump target {target} outside instruction stream (0..{words})"),
            ));
        }
        let target = target as usize;
        if headers[target] == usize::MAX {
            return Err(err(i, format!("jump target {target} lands in an AUX word")));
        }
        if capture_owner[headers[target]].is_some() {
            return Err(err(
                i,
                format!("jump target {target} enters a closure capture sequence"),
            ));
        }
        Ok(target)
    };
    for (n, i) in proto.code.iter().enumerate() {
        let (a, b, c) = (i.a(), i.b(), i.c());
        let aux = i.aux.unwrap_or(0) as usize;
        let reg = |r: usize| -> Result<()> {
            if r >= proto.max_stack as usize {
                Err(err(
                    i,
                    format!("register r{r} outside stack of {} slots", proto.max_stack),
                ))
            } else {
                Ok(())
            }
        };
        let range = |start: usize, count: usize| -> Result<()> {
            if start > proto.max_stack as usize
                || count > (proto.max_stack as usize).saturating_sub(start)
            {
                Err(err(
                    i,
                    format!(
                        "register range r{start}..r{} outside stack of {} slots",
                        start.saturating_add(count),
                        proto.max_stack
                    ),
                ))
            } else {
                Ok(())
            }
        };
        let constant = |k: usize| -> Result<&Constant> {
            proto.constants.get(k).ok_or_else(|| {
                err(
                    i,
                    format!(
                        "constant index {k} outside table of {} entries",
                        proto.constants.len()
                    ),
                )
            })
        };
        let string = |k: usize| -> Result<()> {
            if !matches!(constant(k)?, Constant::String(_)) {
                return Err(err(i, format!("constant {k} must be a string")));
            }
            Ok(())
        };
        let number = |k: usize| -> Result<()> {
            if !matches!(constant(k)?, Constant::Number(_)) {
                return Err(err(i, format!("constant {k} must be a number")));
            }
            Ok(())
        };
        let upvalue = |u: usize| -> Result<()> {
            if u >= proto.num_upvalues as usize {
                Err(err(
                    i,
                    format!(
                        "upvalue u{u} outside table of {} upvalues",
                        proto.num_upvalues
                    ),
                ))
            } else {
                Ok(())
            }
        };
        let kd = || {
            usize::try_from(i.d()).map_err(|_| err(i, format!("negative constant index {}", i.d())))
        };
        match i.op {
            Nop | Jump | JumpBack | JumpX | Coverage => {}
            Break | NativeCall => return Err(err(i, "runtime-only instruction".into())),
            LoadNil | LoadN => reg(a)?,
            LoadB => {
                reg(a)?;
                if b > 1 {
                    return Err(err(i, "LOADB boolean operand must be 0 or 1".into()));
                }
            }
            LoadK => {
                reg(a)?;
                constant(kd()?)?;
            }
            LoadKx => {
                reg(a)?;
                constant(aux)?;
            }
            Move | Not | Minus | Length => {
                reg(a)?;
                reg(b)?;
            }
            GetGlobal | SetGlobal => {
                reg(a)?;
                string(aux)?;
            }
            GetUpval | SetUpval => {
                reg(a)?;
                upvalue(b)?;
            }
            CloseUpvals => {
                reg(a)?;
                open_refs.retain(|&r| r < a);
            }
            GetImport => {
                reg(a)?;
                if !matches!(constant(kd()?)?, Constant::Import(id) if import_paths_equal(*id, aux as u32))
                {
                    return Err(err(
                        i,
                        "GETIMPORT constant and AUX import path differ".into(),
                    ));
                }
                validate_import(aux as u32, &proto.constants).map_err(|m| err(i, m))?;
            }
            GetTable | SetTable | Add | Sub | Mul | Div | IDiv | Mod | Pow | And | Or => {
                reg(a)?;
                reg(b)?;
                reg(c)?;
            }
            GetTableKs | SetTableKs => {
                reg(a)?;
                reg(b)?;
                string(aux)?;
            }
            GetTableN | SetTableN => {
                reg(a)?;
                reg(b)?;
            }
            NewClosure | DupClosure => reg(a)?,
            NameCall => {
                reg(a)?;
                reg(a + 1)?;
                reg(b)?;
                string(aux)?;
                let call = proto
                    .code
                    .get(n + 1)
                    .ok_or_else(|| err(i, "NAMECALL lacks following CALL".into()))?;
                if call.op != Call || call.a() != a || call.b() == 1 {
                    return Err(err(i, "NAMECALL must be immediately followed by CALL at the same base with a self argument".into()));
                }
            }
            Call => {
                reg(a)?;
                range(a + 1, b.saturating_sub(1))?;
                range(a, c.saturating_sub(1))?;
            }
            Return => range(a, b.saturating_sub(1))?,
            JumpIf | JumpIfNot | JumpXEqKNil | JumpXEqKB => reg(a)?,
            JumpIfEq | JumpIfLe | JumpIfLt | JumpIfNotEq | JumpIfNotLe | JumpIfNotLt => {
                reg(a)?;
                reg(aux)?;
            }
            JumpXEqKN => {
                reg(a)?;
                number(aux & 0xff_ffff)?;
            }
            JumpXEqKS => {
                reg(a)?;
                string(aux & 0xff_ffff)?;
            }
            AddK | SubK | MulK | DivK | IDivK | ModK | PowK => {
                reg(a)?;
                reg(b)?;
                number(c)?;
            }
            SubRk | DivRk => {
                reg(a)?;
                number(b)?;
                reg(c)?;
            }
            AndK | OrK => {
                reg(a)?;
                reg(b)?;
                constant(c)?;
            }
            Concat => {
                reg(a)?;
                reg(b)?;
                reg(c)?;
                if b > c {
                    return Err(err(i, "CONCAT source range is reversed".into()));
                }
            }
            NewTable => {
                reg(a)?;
                if b > 31 || aux > i32::MAX as usize {
                    return Err(err(i, "NEWTABLE capacity is out of range".into()));
                }
            }
            DupTable => {
                reg(a)?;
                if !matches!(
                    constant(kd()?)?,
                    Constant::Table(_) | Constant::TableWithConstants(_)
                ) {
                    return Err(err(i, "DUPTABLE requires a table-template constant".into()));
                }
            }
            SetList => {
                reg(a)?;
                range(b, c.saturating_sub(1))?;
                if aux == 0 || aux > i32::MAX as usize {
                    return Err(err(i, "SETLIST array index must be in 1..=2^31-1".into()));
                }
            }
            ForNPrep | ForNLoop => reg(a + 2)?,
            ForGPrep => reg(a + 3)?,
            ForGPrepInext | ForGPrepNext => reg(a + 4)?,
            ForGLoop => {
                let count = aux & 255;
                if count == 0
                    || (aux as u32 & 0x7fff_ff00) != 0
                    || ((aux as u32 & 0x8000_0000) != 0 && count > 2)
                {
                    return Err(err(
                        i,
                        "invalid FORGLOOP AUX variable count or reserved bits".into(),
                    ));
                }

                reg(a + 2 + count.max(2))?;
            }
            GetVarargs => {
                if !proto.is_vararg {
                    return Err(err(i, "GETVARARGS in a nonvariadic function".into()));
                }
                range(a, b.saturating_sub(1))?;
            }
            PrepVarargs => {
                if !proto.is_vararg || a != proto.num_params as usize || i.pc != 0 {
                    return Err(err(
                        i,
                        "PREPVARARGS must begin a variadic function and match its parameter count"
                            .into(),
                    ));
                }
            }
            FastCall | FastCall1 | FastCall2 | FastCall2K | FastCall3 | FastPcall => {
                if (i.op == FastPcall && a > 1)
                    || (i.op != FastPcall && (a == 0 || a >= usize::from(builtin_count)))
                {
                    return Err(err(i, format!("unsupported fastcall builtin id {a}")));
                }
                if !matches!(i.op, FastCall | FastPcall) {
                    reg(b)?;
                }
                match i.op {
                    FastCall2 => reg(aux)?,
                    FastCall2K => {
                        constant(aux)?;
                    }
                    FastCall3 => {
                        reg(aux & 255)?;
                        reg((aux >> 8) & 255)?;
                        if aux >> 16 != 0 {
                            return Err(err(i, "FASTCALL3 AUX has reserved bits set".into()));
                        }
                    }
                    _ => {}
                }
                let call_pc = check_target(i, (i.pc + 1 + c) as i64)?;
                let call = &proto.code[headers[call_pc]];
                if call.op != Call || call.aux.is_some() {
                    return Err(err(
                        i,
                        format!(
                            "{} skip does not target CALL",
                            if i.op == FastPcall {
                                "FASTPCALL"
                            } else {
                                "FASTCALL"
                            }
                        ),
                    ));
                }
                if i.op == FastPcall && call.b() != 0 && b != call.b() - 1 {
                    return Err(err(
                        i,
                        "FASTPCALL explicit argument count differs from fallback CALL".into(),
                    ));
                }
                check_target(i, (call_pc + 1) as i64)?;
            }
            Capture => {
                if capture_owner[n].is_none() {
                    return Err(err(i, "orphan CAPTURE outside closure creation".into()));
                }
                match a {
                    0 => reg(b)?,
                    1 => {
                        reg(b)?;
                        open_refs.insert(b);
                    }
                    2 => upvalue(b)?,
                    _ => return Err(err(i, format!("unknown capture kind {a}"))),
                }
            }
        }
        if matches!(i.op, JumpXEqKNil) && (aux as u32 & 0x7fff_ffff) != 0 {
            return Err(err(i, "JUMPXEQKNIL AUX has reserved bits set".into()));
        }
        if matches!(i.op, JumpXEqKB) && (aux as u32 & 0x7fff_fffe) != 0 {
            return Err(err(i, "JUMPXEQKB AUX has reserved bits set".into()));
        }
        if matches!(i.op, JumpXEqKN | JumpXEqKS) && (aux as u32 & 0x7f00_0000) != 0 {
            return Err(err(i, "JUMPXEQK AUX has reserved bits set".into()));
        }
        if i.op.is_jump_d() {
            let target = check_target(i, i.pc as i64 + 1 + i.d() as i64)?;
            jump_targets[target] = true;
        } else if i.op == JumpX {
            let target = check_target(i, i.pc as i64 + 1 + i.e() as i64)?;
            jump_targets[target] = true;
        } else if i.op == LoadB && c != 0 {
            let target = check_target(i, (i.pc + 1 + c) as i64)?;
            jump_targets[target] = true;
        }

        if !matches!(
            i.op,
            Return | Jump | JumpBack | JumpX | ForGPrep | ForGPrepInext | ForGPrepNext | Capture
        ) && !(i.op == LoadB && c != 0)
        {
            let next = if matches!(i.op, NewClosure | DupClosure) {
                let mut end = n + 1;
                while end < proto.code.len() && capture_owner[end] == Some(n) {
                    end += 1;
                }
                proto.code.get(end).map(|x| x.pc).unwrap_or(words)
            } else {
                i.pc + i.len()
            };
            check_target(i, next as i64)?;
        }
    }
    if proto.is_vararg && proto.code[0].op != PrepVarargs {
        return Err(err(
            &proto.code[0],
            "variadic function must start with PREPVARARGS".into(),
        ));
    }
    if !open_refs.is_empty() {
        return Err(err(
            proto.code.last().unwrap(),
            "reference captures lack a subsequent CLOSEUPVALS".into(),
        ));
    }
    validate_variadic(proto, &jump_targets, p, code_offset)
}

fn validate_variadic(proto: &Proto, targets: &[bool], p: usize, code_offset: usize) -> Result<()> {
    use Opcode::*;
    let mut sequence: Option<usize> = None;
    for i in &proto.code {
        let err = |m: &str| {
            Error::new("validate", m)
                .at_proto(p)
                .at_pc(i.pc)
                .at_offset(code_offset + 4 * i.pc)
        };
        if sequence.is_some() && targets[i.pc] {
            return Err(err("branch enters an open multiple-return sequence"));
        }
        match i.op {
            Call => {
                if i.b() == 0 {
                    let producer = sequence
                        .take()
                        .ok_or_else(|| err("CALL consumes multiple results without a producer"))?;
                    if i.a() >= producer {
                        return Err(err(
                            "CALL multiple-result argument base exceeds producer base",
                        ));
                    }
                } else if sequence.is_some() {
                    return Err(err(
                        "fixed-argument CALL interrupts an open multiple-return sequence",
                    ));
                }
                if i.c() == 0 {
                    sequence = Some(i.a());
                }
            }
            GetVarargs if i.b() == 0 => {
                if sequence.is_some() {
                    return Err(err(
                        "GETVARARGS overwrites an open multiple-return sequence",
                    ));
                }
                sequence = Some(i.a());
            }
            Return if i.b() == 0 => {
                let producer = sequence
                    .take()
                    .ok_or_else(|| err("RETURN consumes multiple results without a producer"))?;
                if i.a() > producer {
                    return Err(err("RETURN multiple-result base exceeds producer base"));
                }
            }
            SetList if i.c() == 0 => {
                let producer = sequence
                    .take()
                    .ok_or_else(|| err("SETLIST consumes multiple results without a producer"))?;
                if i.b() > producer {
                    return Err(err("SETLIST multiple-result base exceeds producer base"));
                }
            }
            FastCall | FastPcall => {
                let call_pc = i.pc + i.c() + 1;
                let call = proto
                    .code
                    .binary_search_by_key(&call_pc, |x| x.pc)
                    .map(|n| &proto.code[n])
                    .map_err(|_| err("FASTCALL lacks CALL target"))?;
                if (call.b() == 0) != sequence.is_some() {
                    return Err(err(
                        "FASTCALL and fallback CALL disagree with open multiple-return sequence",
                    ));
                }
                if i.op == FastPcall && call.b() == 0 && sequence != Some(call.a() + 1 + i.b()) {
                    return Err(err(
                        "FASTPCALL explicit arguments do not meet its open-result tail",
                    ));
                }
            }
            CloseUpvals | NameCall | GetImport | Move | GetUpval | GetGlobal | GetTableKs
            | Coverage => {}
            _ if sequence.is_some() => {
                return Err(err(
                    "instruction interrupts an open multiple-return sequence",
                ))
            }
            _ => {}
        }
    }
    if sequence.is_some() {
        return Err(Error::new("validate", "unterminated multiple-return sequence").at_proto(p));
    }
    Ok(())
}

#[derive(Clone, Debug)]
pub struct FastcallProof {
    pub call_index: usize,
    pub scratch_registers: Vec<usize>,
    pub written_registers: Vec<usize>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
enum ProofLiteral {
    Nil,
    Boolean(bool),
    Number(u64),
    String(usize),
    Vector([u32; 4]),
    VectorDouble([u64; 4]),
}
#[derive(Clone, Debug, PartialEq, Eq)]
enum ProofValue {
    Register(usize),
    Literal(ProofLiteral),
    Path(Vec<usize>),
    Varargs,
}

const BUILTIN_PATHS: &[&str] = &[
    "",
    "assert",
    "math.abs",
    "math.acos",
    "math.asin",
    "math.atan2",
    "math.atan",
    "math.ceil",
    "math.cosh",
    "math.cos",
    "math.deg",
    "math.exp",
    "math.floor",
    "math.fmod",
    "math.frexp",
    "math.ldexp",
    "math.log10",
    "math.log",
    "math.max",
    "math.min",
    "math.modf",
    "math.pow",
    "math.rad",
    "math.sinh",
    "math.sin",
    "math.sqrt",
    "math.tanh",
    "math.tan",
    "bit32.arshift",
    "bit32.band",
    "bit32.bnot",
    "bit32.bor",
    "bit32.bxor",
    "bit32.btest",
    "bit32.extract",
    "bit32.lrotate",
    "bit32.lshift",
    "bit32.replace",
    "bit32.rrotate",
    "bit32.rshift",
    "type",
    "string.byte",
    "string.char",
    "string.len",
    "typeof",
    "string.sub",
    "math.clamp",
    "math.sign",
    "math.round",
    "rawset",
    "rawget",
    "rawequal",
    "table.insert",
    "table.unpack",
    "vector.create",
    "bit32.countlz",
    "bit32.countrz",
    "select",
    "rawlen",
    "bit32.extract",
    "getmetatable",
    "setmetatable",
    "tonumber",
    "tostring",
    "bit32.byteswap",
    "buffer.readi8",
    "buffer.readu8",
    "buffer.writeu8",
    "buffer.readi16",
    "buffer.readu16",
    "buffer.writeu16",
    "buffer.readi32",
    "buffer.readu32",
    "buffer.writeu32",
    "buffer.readf32",
    "buffer.writef32",
    "buffer.readf64",
    "buffer.writef64",
    "vector.magnitude",
    "vector.normalize",
    "vector.cross",
    "vector.dot",
    "vector.floor",
    "vector.ceil",
    "vector.abs",
    "vector.sign",
    "vector.clamp",
    "vector.min",
    "vector.max",
    "math.lerp",
    "vector.lerp",
    "math.isnan",
    "math.isinf",
    "math.isfinite",
    "integer.create",
    "integer.tonumber",
    "integer.neg",
    "integer.add",
    "integer.sub",
    "integer.mul",
    "integer.div",
    "integer.min",
    "integer.max",
    "integer.rem",
    "integer.idiv",
    "integer.udiv",
    "integer.urem",
    "integer.mod",
    "integer.clamp",
    "integer.band",
    "integer.bor",
    "integer.bnot",
    "integer.bxor",
    "integer.lt",
    "integer.le",
    "integer.ult",
    "integer.ule",
    "integer.gt",
    "integer.ge",
    "integer.ugt",
    "integer.uge",
    "integer.lshift",
    "integer.rshift",
    "integer.arshift",
    "integer.lrotate",
    "integer.rrotate",
    "integer.extract",
    "integer.btest",
    "integer.countrz",
    "integer.countlz",
    "integer.bswap",
    "buffer.readinteger",
    "buffer.writeinteger",
    "table.create",
    "table.clear",
];

fn proof_path_matches(module: &Module, path: &[usize], expected: &str) -> bool {
    let mut pieces = expected.split('.');
    for &id in path {
        let Some(piece) = pieces.next() else {
            return false;
        };
        if module.strings.get(id).map(Vec::as_slice) != Some(piece.as_bytes()) {
            return false;
        }
    }
    pieces.next().is_none()
}

pub fn verify_fastcall_fallback(
    module: &Module,
    proto_id: usize,
    index: usize,
) -> Result<FastcallProof> {
    use Opcode::*;
    let proto = module
        .protos
        .get(proto_id)
        .ok_or_else(|| Error::new("semantics", "absent FASTCALL prototype"))?;
    let fast = proto
        .code
        .get(index)
        .ok_or_else(|| Error::new("semantics", "absent FASTCALL instruction").at_proto(proto_id))?;
    let err = |m: &str| Error::new("semantics", m).at_proto(proto_id).at_pc(fast.pc);
    if !fast.op.is_fastcall() {
        return Err(err("fallback verification requires a FASTCALL opcode"));
    }
    let call_pc = fast.pc + fast.c() + 1;
    let call_index = proto
        .code
        .binary_search_by_key(&call_pc, |i| i.pc)
        .map_err(|_| err("FASTCALL lacks a valid CALL target"))?;
    let call = &proto.code[call_index];
    if call.op != Call || call.aux.is_some() || call_index <= index {
        return Err(err("FASTCALL target is not a following CALL"));
    }
    if fast.op == FastPcall && call.b() != 0 && fast.b() != call.b() - 1 {
        return Err(err(
            "FASTPCALL explicit argument count differs from fallback CALL",
        ));
    }
    let literal = |k: usize| -> Result<ProofLiteral> {
        match proto.constants.get(k) {
            Some(Constant::Nil) => Ok(ProofLiteral::Nil),
            Some(Constant::Boolean(b)) => Ok(ProofLiteral::Boolean(*b)),
            Some(Constant::Number(n)) => Ok(ProofLiteral::Number(n.to_bits())),
            Some(Constant::String(s)) => Ok(ProofLiteral::String(*s)),
            Some(Constant::Vector(v)) => Ok(ProofLiteral::Vector(v.map(f32::to_bits))),
            Some(Constant::VectorDouble(v)) => Ok(ProofLiteral::VectorDouble(v.map(f64::to_bits))),
            _ => Err(err("FASTCALL fallback requires a scalar literal, not a cached import/table/closure constant")),
        }
    };
    let mut values: Vec<_> = (0..proto.max_stack as usize)
        .map(ProofValue::Register)
        .collect();
    let mut written = BTreeSet::new();
    let mut vararg_base = None;
    for setup in &proto.code[index + 1..call_index] {
        let (a, b) = (setup.a(), setup.b());
        let value = match setup.op {
            Move => values[b].clone(),
            LoadNil => ProofValue::Literal(ProofLiteral::Nil),
            LoadB if setup.c() == 0 => ProofValue::Literal(ProofLiteral::Boolean(b != 0)),
            LoadN => ProofValue::Literal(ProofLiteral::Number((setup.d() as f64).to_bits())),
            LoadK => ProofValue::Literal(literal(setup.d() as usize)?),
            LoadKx => ProofValue::Literal(literal(setup.aux.unwrap() as usize)?),
            GetImport => {
                let id = setup.aux.unwrap();
                let mut path = Vec::with_capacity((id >> 30) as usize);
                for n in 0..id >> 30 {
                    let k = ((id >> (20 - 10 * n)) & 1023) as usize;
                    if let Some(Constant::String(s)) = proto.constants.get(k) {
                        path.push(*s);
                    } else {
                        return Err(err("FASTCALL fallback import path is not a string path"));
                    }
                }
                ProofValue::Path(path)
            }
            GetGlobal => {
                if let Some(Constant::String(s)) = proto.constants.get(setup.aux.unwrap() as usize)
                {
                    ProofValue::Path(vec![*s])
                } else {
                    return Err(err("FASTCALL fallback global key is not a string"));
                }
            }
            GetTableKs => {
                let ProofValue::Path(mut path) = values[b].clone() else {
                    return Err(err(
                        "FASTCALL fallback property receiver has no proven builtin origin",
                    ));
                };
                let Some(Constant::String(s)) = proto.constants.get(setup.aux.unwrap() as usize)
                else {
                    return Err(err("FASTCALL fallback property key is not a string"));
                };
                path.push(*s);
                ProofValue::Path(path)
            }
            GetVarargs if fast.a() == 57 && setup.b() == 0 => {
                if vararg_base.is_some() || !proto.is_vararg || setup.pc + setup.len() != call.pc {
                    return Err(err(
                        "select FASTCALL requires one final variadic argument producer",
                    ));
                }
                vararg_base = Some(a);
                written.extend(a..proto.max_stack as usize);
                ProofValue::Varargs
            }
            _ => {
                return Err(err(
                    "FASTCALL fallback contains an unproved or effectful setup instruction",
                ))
            }
        };

        if a < values.len() {
            values[a] = value;
            written.insert(a);
        }
    }
    let ProofValue::Path(path) = &values[call.a()] else {
        return Err(err(
            "FASTCALL fallback function alias has no proven builtin origin",
        ));
    };
    let expected = if fast.op == FastPcall {
        match fast.a() {
            0 => "pcall",
            1 => "xpcall",
            _ => return Err(err("unknown FASTPCALL protected function ID")),
        }
    } else {
        *BUILTIN_PATHS
            .get(fast.a())
            .ok_or_else(|| err("unknown FASTCALL builtin ID"))?
    };
    let alternate = match fast.a() {
        53 => Some("unpack"),
        67 => Some("buffer.writei8"),
        70 => Some("buffer.writei16"),
        73 => Some("buffer.writei32"),
        _ => None,
    };
    if !proof_path_matches(module, path, expected)
        && !alternate.is_some_and(|name| proof_path_matches(module, path, name))
    {
        return Err(err("FASTCALL builtin ID and fallback function path differ"));
    }
    let actual_arg = |n: usize| {
        values
            .get(call.a() + 1 + n)
            .ok_or_else(|| err("FASTCALL fallback argument exceeds stack"))
    };
    let expected_arg = ProofValue::Register(fast.b());
    if fast.a() == 57 {
        if fast.op != FastCall1
            || call.b() != 0
            || call.c() != 2
            || vararg_base != Some(call.a() + 2)
            || actual_arg(0)? != &expected_arg
        {
            return Err(err(
                "select FASTCALL and fallback disagree on selector/varargs/results",
            ));
        }
    } else if fast.a() == 59 {
        if fast.op != FastCall2K || call.b() != 4 || actual_arg(0)? != &expected_arg {
            return Err(err(
                "bit32.extract packed FASTCALL has incompatible fallback arguments",
            ));
        }
        let packed = match literal(fast.aux.unwrap() as usize)? {
            ProofLiteral::Number(n) => f64::from_bits(n),
            _ => {
                return Err(err(
                    "bit32.extract packed FASTCALL constant must be numeric",
                ))
            }
        };
        let numeric = |n: usize| -> Result<f64> {
            if let ProofValue::Literal(ProofLiteral::Number(bits)) = actual_arg(n)? {
                Ok(f64::from_bits(*bits))
            } else {
                Err(err(
                    "bit32.extract packed fallback field/width must be numeric literals",
                ))
            }
        };
        let (field, width) = (numeric(1)?, numeric(2)?);
        if !field.is_finite()
            || !width.is_finite()
            || field.trunc() < 0.0
            || width.trunc() < 1.0
            || field.trunc() + width.trunc() > 32.0
            || packed != ((field as i32) | (((width as i32) - 1) << 5)) as f64
        {
            return Err(err(
                "bit32.extract packed constant differs from fallback field/width",
            ));
        }
    } else if matches!(fast.op, FastCall | FastPcall) {
        if written.iter().any(|&r| r != call.a()) || vararg_base.is_some() {
            return Err(err(
                "generic FASTCALL fallback modifies argument/scratch registers",
            ));
        }
    } else {
        let expected_count = match fast.op {
            FastCall1 => 1,
            FastCall3 => 3,
            _ => 2,
        };
        if call.b() != expected_count + 1
            || actual_arg(0)? != &expected_arg
            || vararg_base.is_some()
        {
            return Err(err(
                "specialized FASTCALL and fallback disagree on argument count or first argument",
            ));
        }
        if expected_count >= 2 {
            let second = match fast.op {
                FastCall2K => ProofValue::Literal(literal(fast.aux.unwrap() as usize)?),
                FastCall2 => ProofValue::Register(fast.aux.unwrap() as usize),
                FastCall3 => ProofValue::Register((fast.aux.unwrap() & 255) as usize),
                _ => unreachable!(),
            };
            if actual_arg(1)? != &second {
                return Err(err(
                    "FASTCALL fallback second argument differs from fast path",
                ));
            }
        }
        if expected_count == 3
            && actual_arg(2)? != &ProofValue::Register(((fast.aux.unwrap() >> 8) & 255) as usize)
        {
            return Err(err(
                "FASTCALL fallback third argument differs from fast path",
            ));
        }
    }
    let result_end = call.a() + call.c().saturating_sub(1);
    let scratch_registers = written
        .iter()
        .copied()
        .filter(|&r| call.c() == 0 || r < call.a() || r >= result_end)
        .collect();
    Ok(FastcallProof {
        call_index,
        scratch_registers,
        written_registers: written.into_iter().collect(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn varint(out: &mut Vec<u8>, mut n: u32) {
        loop {
            let byte = (n & 127) as u8;
            n >>= 7;
            out.push(byte | if n == 0 { 0 } else { 128 });
            if n == 0 {
                break;
            }
        }
    }

    pub fn simple(code: &[u32]) -> Vec<u8> {
        let mut out = vec![6, 3, 0, 0, 1, 2, 0, 0, 0, 0, 0];
        varint(&mut out, code.len() as u32);
        for word in code {
            out.extend(word.to_le_bytes());
        }
        out.extend([0, 0, 0, 0, 0, 0, 0]);
        out
    }

    fn ad(op: Opcode, a: u8, d: i16) -> u32 {
        op as u32 | ((a as u32) << 8) | ((d as u16 as u32) << 16)
    }

    fn versioned(version: u8, types: u8, params: u8, typeinfo: &[u8], code: &[u32]) -> Vec<u8> {
        let mut out = vec![version];
        if version >= 4 {
            out.push(types);
        }
        out.push(0);
        if types == 3 {
            out.push(0);
        }
        out.extend([1, 1, params, 0, 0]);
        if version >= 4 {
            out.push(0);
            varint(&mut out, typeinfo.len() as u32);
            out.extend(typeinfo);
        }
        varint(&mut out, code.len() as u32);
        for word in code {
            out.extend(word.to_le_bytes());
        }
        out.extend([0, 0, 0, 0, 0, 0, 0]);
        out
    }

    #[test]
    fn synthetic_legacy_version_headers_decode() {
        let code = [ad(Opcode::LoadN, 0, 7), ad(Opcode::Return, 0, 2)];
        for version in 3..=6 {
            let types = if version == 3 { 0 } else { 1 };
            let bytes = versioned(version, types, 0, &[], &code);
            let m = decode(&bytes, &Limits::default()).unwrap();
            assert_eq!(m.version, version);
            assert_eq!(m.type_version, types);
            assert_eq!(m.protos[0].code[0].d(), 7);
        }
    }

    #[test]
    fn synthetic_all_type_encodings_decode_and_validate() {
        let code = [ad(Opcode::Return, 0, 2)];
        for types in 1..=3 {
            let info: &[u8] = if types == 1 {
                &[5, 1, 2]
            } else {
                &[3, 0, 1, 5, 1, 2, 2, 0, 0, 1]
            };
            let bytes = versioned(4, types, 1, info, &code);
            decode(&bytes, &Limits::default()).unwrap();
            let mut invalid = info.to_vec();
            let last = invalid.len() - 1;
            if types == 1 {
                invalid[last] = 127;
            } else {
                invalid[last] = 2;
            }
            assert!(decode(&versioned(4, types, 1, &invalid, &code), &Limits::default()).is_err());
        }
    }

    #[test]
    fn legacy_versions_reject_newer_opcodes() {
        for (version, opcode) in [
            (3, Opcode::IDiv),
            (4, Opcode::SubRk),
            (5, Opcode::FastCall3),
        ] {
            let bytes = versioned(
                version,
                if version == 3 { 0 } else { 1 },
                0,
                &[],
                &[opcode as u32],
            );
            let error = decode(&bytes, &Limits::default()).unwrap_err().to_string();
            assert!(error.contains("not available"), "{error}");
        }
    }

    #[test]
    fn unused_userdata_mapping_may_have_a_null_name() {
        let mut bytes = versioned(6, 3, 0, &[], &[ad(Opcode::Return, 0, 1)]);

        bytes.splice(3..3, [1, 0]);
        decode(&bytes, &Limits::default()).unwrap();
    }

    #[test]
    fn repeated_debug_names_have_an_expansion_budget() {
        let mut out = vec![
            6, 3, 1, 4, b'n', b'a', b'm', b'e', 0, 1, 1, 0, 0, 0, 0, 0, 1,
        ];
        out.extend(ad(Opcode::Return, 0, 1).to_le_bytes());
        out.extend([0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0]);

        let limits = Limits {
            max_string_bytes: 4,
            ..Limits::default()
        };
        let error = decode(&out, &limits).unwrap_err().to_string();
        assert!(error.contains("expanded debug name bytes"), "{error}");
        decode(&out, &Limits::default()).unwrap();
    }

    #[test]
    fn discriminants_match_pin() {
        assert_eq!(OPCODES.len(), 83);
        for (n, &op) in OPCODES.iter().enumerate() {
            assert_eq!(op as usize, n);
        }
        assert_eq!(Opcode::Return as u8, 22);
        assert_eq!(Opcode::IDivK as u8, 82);
        assert_eq!(BUILTIN_PATHS.len(), 135);
        assert_eq!(BUILTIN_PATHS[57], "select");
        assert_eq!(BUILTIN_PATHS[59], "bit32.extract");
    }

    #[test]
    fn decodes_minimal_numeric_return() {
        let bytes = simple(&[ad(Opcode::LoadN, 0, 42), ad(Opcode::Return, 0, 2)]);
        let m = decode(&bytes, &Limits::default()).unwrap();
        assert_eq!(m.main, 0);
        assert_eq!(m.protos[0].code.len(), 2);
        assert_eq!(m.protos[0].code[0].d(), 42);
    }

    #[test]
    fn every_truncation_rejected() {
        let bytes = simple(&[ad(Opcode::LoadN, 0, -42), ad(Opcode::Return, 0, 2)]);
        for end in 0..bytes.len() {
            assert!(
                decode(&bytes[..end], &Limits::default()).is_err(),
                "truncation {end}"
            );
        }
    }

    #[test]
    fn rejects_bad_register_and_jump() {
        for code in [
            vec![ad(Opcode::LoadN, 2, 0), ad(Opcode::Return, 0, 1)],
            vec![ad(Opcode::Jump, 0, -2)],
            vec![ad(Opcode::Jump, 0, 100)],
        ] {
            assert!(decode(&simple(&code), &Limits::default()).is_err());
        }
    }

    #[test]
    fn rejects_jump_into_aux() {
        let bytes = simple(&[
            ad(Opcode::Jump, 0, 1),
            Opcode::NewTable as u32,
            0,
            ad(Opcode::Return, 0, 1),
        ]);
        let error = decode(&bytes, &Limits::default()).unwrap_err().to_string();
        assert!(error.contains("AUX"), "{error}");
    }

    #[test]
    fn rejects_invalid_versions_trailing_data_and_aux() {
        let mut bytes = simple(&[ad(Opcode::Return, 0, 1)]);
        for version in [0, 1, 2, 15, 100, 255] {
            bytes[0] = version;
            assert!(decode(&bytes, &Limits::default()).is_err());
        }
        bytes[0] = 6;
        bytes.push(0);
        assert!(decode(&bytes, &Limits::default()).is_err());
        assert!(decode(&simple(&[Opcode::LoadKx as u32]), &Limits::default()).is_err());
    }

    #[test]
    fn overlong_varint_rejected() {
        let mut reader = Reader::new(&[0x80, 0]);
        assert!(reader
            .varint()
            .unwrap_err()
            .to_string()
            .contains("overlong"));
        let mut reader = Reader::new(&[255, 255, 255, 255, 16]);
        assert!(reader.varint().is_err());
    }

    #[test]
    fn deterministic_malformed_mutations_do_not_panic() {
        let original = simple(&[ad(Opcode::LoadN, 0, 42), ad(Opcode::Return, 0, 2)]);
        for n in 0..original.len() {
            for byte in 0..=255 {
                let mut bytes = original.clone();
                bytes[n] = byte;
                let _ = decode(&bytes, &Limits::default());
            }
        }
    }

    fn proof_module(
        words: &[u32],
        constants: Vec<Constant>,
        strings: &[&str],
        max_stack: u8,
        is_vararg: bool,
    ) -> Module {
        let mut code = Vec::new();
        let mut pc = 0;
        while pc < words.len() {
            let word = words[pc];
            let op = Opcode::from_byte(word as u8).unwrap();
            let aux = if op.has_aux() {
                Some(words[pc + 1])
            } else {
                None
            };
            let i = Instruction { pc, word, op, aux };
            pc += i.len();
            code.push(i);
        }
        Module {
            version: 6,
            userdata_types: Default::default(),
            type_version: 3,
            main: 0,
            strings: strings.iter().map(|s| s.as_bytes().to_vec()).collect(),
            protos: vec![Proto {
                max_stack,
                num_params: 1,
                num_upvalues: 0,
                is_vararg,
                flags: 0,
                code,
                constants,
                children: vec![],
                line_defined: 0,
                debug_name: None,
                locals: vec![],
                upvalue_names: vec![],
                type_metadata: Default::default(),
            }],
        }
    }
    fn abc(op: Opcode, a: usize, b: usize, c: usize) -> u32 {
        op as u32 | ((a as u32) << 8) | ((b as u32) << 16) | ((c as u32) << 24)
    }

    #[test]
    fn getimport_ignores_only_inactive_path_slots_and_preserves_raw_fields() {
        let constants = |path| {
            vec![
                Constant::String(0),
                Constant::String(1),
                Constant::String(2),
                Constant::Import(path),
            ]
        };
        let builtin_count = crate::profiles::for_version(6).unwrap().builtin_count;
        for count in 1..=3u32 {
            let shift = 30 - count * 10;
            let inactive = (1u32 << shift) - 1;
            let active = (count << 30)
                | if count >= 2 { 1 << 10 } else { 0 }
                | if count >= 3 { 2 } else { 0 };
            let constant = active | (0x5aa55 & inactive);
            let auxiliary = active | (0xa55aa & inactive);
            let words = [
                abc(Opcode::GetImport, 0, 3, 0),
                auxiliary,
                abc(Opcode::Return, 0, 2, 0),
            ];
            let module = proof_module(
                &words,
                constants(constant),
                &["Root", "Child", "Leaf"],
                1,
                false,
            );
            let proto = &module.protos[0];
            validate_proto(proto, &[], 0, words.len(), 0, builtin_count).unwrap();
            assert_eq!(proto.code[0].aux, Some(auxiliary));
            assert!(matches!(proto.constants[3], Constant::Import(value) if value == constant));
            for bad in [
                (auxiliary & !(3 << 30)) | (((count % 3) + 1) << 30),
                auxiliary ^ (1 << 20),
                auxiliary & !(3 << 30),
            ] {
                let mut bad_proto = proto.clone();
                bad_proto.code[0].aux = Some(bad);
                assert!(
                    validate_proto(&bad_proto, &[], 0, words.len(), 0, builtin_count)
                        .unwrap_err()
                        .message
                        .contains("GETIMPORT constant and AUX import path differ")
                );
            }
        }
    }

    #[test]
    fn fastcall_proves_arguments_and_rejects_changed_builtin_or_arg() {
        use Opcode::*;
        let import = (2 << 30) | (1 << 10);
        let mut module = proof_module(
            &[
                abc(FastCall1, 2, 0, 3),
                abc(Move, 2, 0, 0),
                ad(GetImport, 1, 2),
                import,
                abc(Call, 1, 2, 2),
                abc(Return, 1, 2, 0),
            ],
            vec![
                Constant::String(0),
                Constant::String(1),
                Constant::Import(import),
            ],
            &["math", "abs"],
            4,
            false,
        );
        let proof = verify_fastcall_fallback(&module, 0, 0).unwrap();
        assert_eq!(proof.call_index, 3);
        assert_eq!(proof.scratch_registers, vec![2]);
        assert_eq!(proof.written_registers, vec![1, 2]);
        module.protos[0].code[1].word = abc(Move, 2, 3, 0);
        assert!(verify_fastcall_fallback(&module, 0, 0)
            .unwrap_err()
            .to_string()
            .contains("argument"));
        module.protos[0].code[1].word = abc(Move, 2, 0, 0);
        module.protos[0].code[0].word = abc(FastCall1, 3, 0, 3);
        assert!(verify_fastcall_fallback(&module, 0, 0)
            .unwrap_err()
            .to_string()
            .contains("function path"));
    }

    #[test]
    fn fastcall_rejects_effectful_fallback() {
        use Opcode::*;
        let import = (2 << 30) | (1 << 10);
        let module = proof_module(
            &[
                abc(FastCall1, 2, 0, 3),
                abc(SetTable, 2, 0, 0),
                ad(GetImport, 1, 2),
                import,
                abc(Call, 1, 2, 2),
                abc(Return, 1, 2, 0),
            ],
            vec![
                Constant::String(0),
                Constant::String(1),
                Constant::Import(import),
            ],
            &["math", "abs"],
            4,
            false,
        );
        assert!(verify_fastcall_fallback(&module, 0, 0)
            .unwrap_err()
            .to_string()
            .contains("effectful"));
    }

    #[test]
    fn select_vararg_fastcall_has_a_distinct_proof() {
        use Opcode::*;
        let import = 1 << 30;
        let module = proof_module(
            &[
                abc(FastCall1, 57, 0, 4),
                ad(GetImport, 1, 1),
                import,
                abc(Move, 2, 0, 0),
                abc(GetVarargs, 3, 0, 0),
                abc(Call, 1, 0, 2),
                abc(Return, 1, 2, 0),
            ],
            vec![Constant::String(0), Constant::Import(import)],
            &["select"],
            4,
            true,
        );
        verify_fastcall_fallback(&module, 0, 0).unwrap();
    }

    #[test]
    fn extract_packed_fastcall_checks_both_fallback_constants() {
        use Opcode::*;
        let import = (2 << 30) | (1 << 10);
        let mut module = proof_module(
            &[
                abc(FastCall2K, 59, 0, 6),
                3,
                abc(Move, 2, 0, 0),
                ad(LoadN, 3, 2),
                ad(LoadN, 4, 4),
                ad(GetImport, 1, 2),
                import,
                abc(Call, 1, 4, 2),
                abc(Return, 1, 2, 0),
            ],
            vec![
                Constant::String(0),
                Constant::String(1),
                Constant::Import(import),
                Constant::Number(98.0),
            ],
            &["bit32", "extract"],
            5,
            false,
        );
        verify_fastcall_fallback(&module, 0, 0).unwrap();
        module.protos[0].constants[3] = Constant::Number(99.0);
        assert!(verify_fastcall_fallback(&module, 0, 0)
            .unwrap_err()
            .to_string()
            .contains("differs"));
    }
}
