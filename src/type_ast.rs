use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(tag = "kind", content = "value", rename_all = "snake_case")]
pub enum TypeExpr {
    Unknown,
    Any,
    Never,
    Nil,
    Boolean,
    Number,
    String,
    SingletonString(String),
    Thread,
    Buffer,
    Named(String),
    Generic(String),
    Optional(Box<TypeExpr>),
    Union(Vec<TypeExpr>),
    Intersection(Vec<TypeExpr>),
    Array(Box<TypeExpr>),
    Dictionary(Box<TypeExpr>, Box<TypeExpr>),
    Record(BTreeMap<String, TypeExpr>),
    Function(Box<FunctionType>),
    Apply(String, Vec<TypeExpr>),
}
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize, Default)]
pub struct TypePack {
    pub head: Vec<TypeExpr>,
    pub tail: Option<PackTail>,
}
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(tag = "kind", content = "value", rename_all = "snake_case")]
pub enum PackTail {
    Variadic(Box<TypeExpr>),
    Generic(String),
}
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize, Default)]
pub struct FunctionType {
    pub generics: Vec<String>,
    pub generic_packs: Vec<String>,
    pub parameters: Vec<TypeExpr>,
    pub variadic: Option<PackTail>,
    pub returns: TypePack,
}
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct FunctionAnnotation {
    pub generics: Vec<String>,
    pub generic_packs: Vec<String>,
    pub parameters: Vec<Option<TypeExpr>>,
    pub variadic: Option<PackTail>,
    pub returns: Option<TypePack>,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TypeAlias {
    pub name: String,
    pub generics: Vec<String>,
    pub generic_packs: Vec<String>,
    pub ty: TypeExpr,
    pub exported: bool,
    pub origin: Option<usize>,
}
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Annotations {
    pub locals: BTreeMap<String, TypeExpr>,
    pub functions: BTreeMap<usize, FunctionAnnotation>,
    pub aliases: Vec<TypeAlias>,
    pub strict: bool,
}

#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, PartialEq, Eq)]
pub struct TypeMetrics {
    pub nodes: usize,
    pub explicit_any: usize,
    pub unknown: usize,
    pub meaningful_atoms: usize,
}
impl TypeMetrics {
    fn include(&mut self, other: Self) {
        self.nodes += other.nodes;
        self.explicit_any += other.explicit_any;
        self.unknown += other.unknown;
        self.meaningful_atoms += other.meaningful_atoms;
    }
    pub fn useful(self) -> bool {
        self.explicit_any == 0 && self.unknown == 0 && self.meaningful_atoms > 0
    }
}
#[derive(Debug, Clone)]
pub struct TypedProgram {
    pub body: Vec<crate::ast::Stmt>,
    pub annotations: Annotations,
}

impl TypeExpr {
    pub fn useful(&self) -> bool {
        self.metrics().useful()
    }
    pub fn metrics(&self) -> TypeMetrics {
        let mut metrics = TypeMetrics {
            nodes: 1,
            ..TypeMetrics::default()
        };
        match self {
            Self::Unknown => metrics.unknown = 1,
            Self::Any => metrics.explicit_any = 1,
            Self::Optional(t) | Self::Array(t) => metrics.include(t.metrics()),
            Self::Union(ts) | Self::Intersection(ts) | Self::Apply(_, ts) => {
                for ty in ts {
                    metrics.include(ty.metrics());
                }
                if matches!(self, Self::Apply(..)) {
                    metrics.meaningful_atoms += 1;
                }
            }
            Self::Record(fields) => {
                for ty in fields.values() {
                    metrics.include(ty.metrics());
                }
            }
            Self::Dictionary(k, v) => {
                metrics.include(k.metrics());
                metrics.include(v.metrics());
            }
            Self::Function(f) => metrics.include(f.metrics()),
            _ => metrics.meaningful_atoms = 1,
        }
        metrics
    }
    pub fn union(a: Self, b: Self) -> Self {
        if a == b {
            return a;
        }
        if a == Self::Never {
            return b;
        }
        if b == Self::Never {
            return a;
        }
        if matches!(a, Self::Unknown) || matches!(b, Self::Unknown) {
            return Self::Unknown;
        }
        if matches!(a, Self::Any) || matches!(b, Self::Any) {
            return Self::Any;
        }
        let mut values = Vec::new();
        for value in [a, b] {
            match value {
                Self::Union(inner) => values.extend(inner),
                Self::Optional(inner) => {
                    values.push(*inner);
                    values.push(Self::Nil)
                }
                other => values.push(other),
            }
        }
        values.sort();
        values.dedup();
        if values.len() == 2 && values.contains(&Self::Nil) {
            values.retain(|t| *t != Self::Nil);
            return Self::Optional(Box::new(values.remove(0)));
        }
        Self::Union(values)
    }
    pub fn luau(&self) -> String {
        self.render(0)
    }
    fn render(&self, parent: u8) -> String {
        let (prec, text) = match self {
            Self::Unknown => (4, "unknown".into()),
            Self::Any => (4, "any".into()),
            Self::Never => (4, "never".into()),
            Self::Nil => (4, "nil".into()),
            Self::Boolean => (4, "boolean".into()),
            Self::Number => (4, "number".into()),
            Self::String => (4, "string".into()),
            Self::SingletonString(value) => (4, crate::names::quote(value.as_bytes())),
            Self::Thread => (4, "thread".into()),
            Self::Buffer => (4, "buffer".into()),
            Self::Named(n) | Self::Generic(n) => (4, n.clone()),
            Self::Optional(t) => (3, format!("{}?", t.render(3))),
            Self::Union(ts) => (
                1,
                ts.iter()
                    .map(|t| t.render(1))
                    .collect::<Vec<_>>()
                    .join(" | "),
            ),
            Self::Intersection(ts) => (
                2,
                ts.iter()
                    .map(|t| t.render(2))
                    .collect::<Vec<_>>()
                    .join(" & "),
            ),
            Self::Array(t) => (4, format!("{{{}}}", t.luau())),
            Self::Dictionary(k, v) => (4, format!("{{[{}]: {}}}", k.luau(), v.luau())),
            Self::Record(fields) => (
                4,
                format!(
                    "{{ {} }}",
                    fields
                        .iter()
                        .map(|(k, v)| format!(
                            "{}: {}",
                            if crate::names::is_identifier(k) {
                                k.clone()
                            } else {
                                format!("[{}]", crate::names::quote(k.as_bytes()))
                            },
                            v.luau()
                        ))
                        .collect::<Vec<_>>()
                        .join(", ")
                ),
            ),
            Self::Apply(n, args) => (
                4,
                format!(
                    "{}<{}>",
                    n,
                    args.iter().map(Self::luau).collect::<Vec<_>>().join(", ")
                ),
            ),
            Self::Function(f) => {
                let mut parameters = f.parameters.iter().map(Self::luau).collect::<Vec<_>>();
                if let Some(tail) = &f.variadic {
                    parameters.push(tail.luau())
                }
                (
                    0,
                    format!(
                        "{}({}) -> {}",
                        generic_declaration(&f.generics, &f.generic_packs),
                        parameters.join(", "),
                        f.returns.luau()
                    ),
                )
            }
        };
        if prec < parent {
            format!("({text})")
        } else {
            text
        }
    }
}
impl PackTail {
    pub fn metrics(&self) -> TypeMetrics {
        match self {
            Self::Variadic(ty) => ty.metrics(),
            Self::Generic(_) => TypeMetrics {
                nodes: 1,
                meaningful_atoms: 1,
                ..TypeMetrics::default()
            },
        }
    }
    pub fn luau(&self) -> String {
        match self {
            Self::Variadic(t) => format!("...{}", t.luau()),
            Self::Generic(n) => format!("{n}..."),
        }
    }
}
impl TypePack {
    pub fn metrics(&self) -> TypeMetrics {
        let mut metrics = TypeMetrics::default();
        for ty in &self.head {
            metrics.include(ty.metrics());
        }
        if let Some(tail) = &self.tail {
            metrics.include(tail.metrics());
        } else if self.head.is_empty() {
            metrics.meaningful_atoms += 1;
        }
        metrics
    }
    pub fn luau(&self) -> String {
        let mut parts = self.head.iter().map(TypeExpr::luau).collect::<Vec<_>>();
        if let Some(tail) = &self.tail {
            parts.push(tail.luau())
        }
        format!("({})", parts.join(", "))
    }
}
impl FunctionType {
    pub fn metrics(&self) -> TypeMetrics {
        let mut metrics = self.returns.metrics();
        for ty in &self.parameters {
            metrics.include(ty.metrics());
        }
        if let Some(tail) = &self.variadic {
            metrics.include(tail.metrics());
        }
        metrics
    }
}
pub fn generic_declaration(types: &[String], packs: &[String]) -> String {
    let mut items = types.to_vec();
    items.extend(packs.iter().map(|p| format!("{p}...")));
    if items.is_empty() {
        String::new()
    } else {
        format!("<{}>", items.join(", "))
    }
}
pub fn parse_type(source: &str) -> crate::Result<TypeExpr> {
    Parser::new(source)?.parse()
}
fn singleton_string(source: &str) -> crate::Result<String> {
    let bytes = source.as_bytes();
    let mut value = Vec::with_capacity(bytes.len().saturating_sub(2));
    let mut at = 1;
    while at + 1 < bytes.len() {
        let byte = bytes[at];
        at += 1;
        if byte != b'\\' {
            if matches!(byte, b'\n' | b'\r') {
                return Err(crate::Error::new(
                    "types",
                    "newline in singleton string type",
                ));
            }
            value.push(byte);
            continue;
        }
        if at + 1 >= bytes.len() {
            return Err(crate::Error::new(
                "types",
                "incomplete singleton string escape",
            ));
        }
        let escaped = bytes[at];
        at += 1;
        match escaped {
            b'\'' | b'"' | b'\\' => value.push(escaped),
            b'a' => value.push(7),
            b'b' => value.push(8),
            b'f' => value.push(12),
            b'n' => value.push(b'\n'),
            b'r' => value.push(b'\r'),
            b't' => value.push(b'\t'),
            b'v' => value.push(11),
            b'0'..=b'9' => {
                let mut number = u16::from(escaped - b'0');
                let mut digits = 1;
                while digits < 3 && at + 1 < bytes.len() && bytes[at].is_ascii_digit() {
                    number = number * 10 + u16::from(bytes[at] - b'0');
                    at += 1;
                    digits += 1;
                }
                value.push(u8::try_from(number).map_err(|_| {
                    crate::Error::new("types", "singleton string decimal escape exceeds 255")
                })?);
            }
            b'x' => {
                let end = at
                    .checked_add(2)
                    .filter(|end| *end < bytes.len())
                    .ok_or_else(|| {
                        crate::Error::new("types", "incomplete singleton string hex escape")
                    })?;
                let digits = source
                    .get(at..end)
                    .filter(|digits| digits.as_bytes().iter().all(u8::is_ascii_hexdigit))
                    .ok_or_else(|| {
                        crate::Error::new("types", "invalid singleton string hex escape")
                    })?;
                value.push(u8::from_str_radix(digits, 16).map_err(|_| {
                    crate::Error::new("types", "invalid singleton string hex escape")
                })?);
                at = end;
            }
            b'z' => {
                while at + 1 < bytes.len() && bytes[at].is_ascii_whitespace() {
                    at += 1;
                }
            }
            _ => {
                return Err(crate::Error::new(
                    "types",
                    "unsupported singleton string escape; use decimal byte escapes",
                ))
            }
        }
    }
    String::from_utf8(value)
        .map_err(|_| crate::Error::new("types", "singleton string type is not valid UTF-8"))
}
struct Parser {
    tokens: Vec<String>,
    at: usize,
    nodes: usize,
}
impl Parser {
    fn new(source: &str) -> crate::Result<Self> {
        if source.len() > 16384 {
            return Err(crate::Error::new(
                "types",
                "type contract exceeds 16384 bytes",
            ));
        }
        let b = source.as_bytes();
        let mut at = 0;
        let mut tokens = Vec::new();
        while at < b.len() {
            if b[at].is_ascii_whitespace() {
                at += 1;
                continue;
            }
            let start = at;
            if matches!(b[at], b'\'' | b'"') {
                let quote = b[at];
                at += 1;
                while at < b.len() && b[at] != quote {
                    if b[at] == b'\\' {
                        at += 1;
                    }
                    at += 1;
                }
                if at >= b.len() {
                    return Err(crate::Error::new(
                        "types",
                        "unterminated singleton string type",
                    ));
                }
                at += 1;
            } else if b[at].is_ascii_alphabetic() || b[at] == b'_' {
                at += 1;
                while at < b.len() && (b[at].is_ascii_alphanumeric() || b[at] == b'_') {
                    at += 1
                }
            } else if source[at..].starts_with("...") {
                at += 3
            } else if source[at..].starts_with("->") {
                at += 2
            } else if b"?&|{}[]():,;<>.".contains(&b[at]) {
                at += 1
            } else {
                return Err(crate::Error::new(
                    "types",
                    format!("unsupported type contract token at byte {at}"),
                ));
            }
            tokens.push(source[start..at].to_string());
            if tokens.len() > 4096 {
                return Err(crate::Error::new("types", "type contract token limit"));
            }
        }
        Ok(Self {
            tokens,
            at: 0,
            nodes: 0,
        })
    }
    fn peek(&self) -> &str {
        self.tokens.get(self.at).map(String::as_str).unwrap_or("")
    }
    fn eat(&mut self, s: &str) -> bool {
        if self.peek() == s {
            self.at += 1;
            true
        } else {
            false
        }
    }
    fn expect(&mut self, s: &str) -> crate::Result<()> {
        if self.eat(s) {
            Ok(())
        } else {
            Err(crate::Error::new(
                "types",
                format!("expected {s:?} in external type contract"),
            ))
        }
    }
    fn parse(mut self) -> crate::Result<TypeExpr> {
        let t = self.ty(0)?;
        if self.at != self.tokens.len() {
            return Err(crate::Error::new("types", "trailing type contract tokens"));
        }
        Ok(t)
    }
    fn ty(&mut self, depth: usize) -> crate::Result<TypeExpr> {
        if depth > 64 || self.nodes > 4096 {
            return Err(crate::Error::new("types", "type contract complexity limit"));
        }
        self.nodes += 1;
        let mut parts = vec![self.intersection(depth + 1)?];
        while self.eat("|") {
            parts.push(self.intersection(depth + 1)?)
        }
        Ok(if parts.len() == 1 {
            parts.remove(0)
        } else {
            TypeExpr::Union(parts)
        })
    }
    fn intersection(&mut self, d: usize) -> crate::Result<TypeExpr> {
        let mut p = vec![self.atom(d + 1)?];
        while self.eat("&") {
            p.push(self.atom(d + 1)?)
        }
        Ok(if p.len() == 1 {
            p.remove(0)
        } else {
            TypeExpr::Intersection(p)
        })
    }
    fn atom(&mut self, d: usize) -> crate::Result<TypeExpr> {
        if d > 64 {
            return Err(crate::Error::new("types", "type nesting limit"));
        }
        let mut result = if self.peek().starts_with(['\'', '"']) {
            let value = singleton_string(&self.tokens[self.at])?;
            self.at += 1;
            TypeExpr::SingletonString(value)
        } else if self.eat("{") {
            if self.eat("}") {
                TypeExpr::Record(BTreeMap::new())
            } else if self.eat("[") {
                let k = self.ty(d + 1)?;
                self.expect("]")?;
                self.expect(":")?;
                let v = self.ty(d + 1)?;
                self.eat(",");
                self.expect("}")?;
                TypeExpr::Dictionary(Box::new(k), Box::new(v))
            } else if self.tokens.get(self.at + 1).is_some_and(|t| t == ":") {
                let mut fields = BTreeMap::new();
                loop {
                    let n = self.identifier()?;
                    self.expect(":")?;
                    let t = self.ty(d + 1)?;
                    if fields.insert(n, t).is_some() {
                        return Err(crate::Error::new("types", "duplicate record field"));
                    }
                    if !self.eat(",") && !self.eat(";") {
                        break;
                    }
                    if self.peek() == "}" {
                        break;
                    }
                }
                self.expect("}")?;
                TypeExpr::Record(fields)
            } else {
                let t = self.ty(d + 1)?;
                self.expect("}")?;
                TypeExpr::Array(Box::new(t))
            }
        } else if self.peek() == "(" || self.peek() == "<" {
            let (generics, packs) = self.generics()?;
            self.expect("(")?;
            let pack = self.pack(d + 1)?;
            self.expect(")")?;
            if self.eat("->") {
                let returns = if self.eat("(") {
                    let p = self.pack(d + 1)?;
                    self.expect(")")?;
                    p
                } else {
                    TypePack {
                        head: vec![self.ty(d + 1)?],
                        tail: None,
                    }
                };
                TypeExpr::Function(Box::new(FunctionType {
                    generics,
                    generic_packs: packs,
                    parameters: pack.head,
                    variadic: pack.tail,
                    returns,
                }))
            } else if pack.head.len() == 1
                && pack.tail.is_none()
                && generics.is_empty()
                && packs.is_empty()
            {
                pack.head.into_iter().next().unwrap()
            } else {
                return Err(crate::Error::new(
                    "types",
                    "parenthesized type requires one type or function arrow",
                ));
            }
        } else {
            let mut n = self.identifier()?;
            while self.eat(".") {
                n.push('.');
                n.push_str(&self.identifier()?)
            }
            if self.eat("<") {
                let mut args = if self.peek() == ">" {
                    Vec::new()
                } else {
                    vec![self.ty(d + 1)?]
                };
                while self.eat(",") {
                    args.push(self.ty(d + 1)?)
                }
                self.expect(">")?;
                TypeExpr::Apply(n, args)
            } else {
                match n.as_str() {
                    "nil" => TypeExpr::Nil,
                    "boolean" => TypeExpr::Boolean,
                    "number" => TypeExpr::Number,
                    "string" => TypeExpr::String,
                    "thread" => TypeExpr::Thread,
                    "buffer" => TypeExpr::Buffer,
                    "unknown" => TypeExpr::Unknown,
                    "any" => TypeExpr::Any,
                    "never" => TypeExpr::Never,
                    _ => TypeExpr::Named(n),
                }
            }
        };
        while self.eat("?") {
            result = TypeExpr::Optional(Box::new(result))
        }
        Ok(result)
    }
    fn identifier(&mut self) -> crate::Result<String> {
        let n = self.peek();
        if !crate::names::is_identifier(n) && n != "nil" {
            return Err(crate::Error::new(
                "types",
                format!("expected type identifier, found {n:?}"),
            ));
        }
        let n = n.to_string();
        self.at += 1;
        Ok(n)
    }
    fn generics(&mut self) -> crate::Result<(Vec<String>, Vec<String>)> {
        let (mut t, mut p) = (Vec::new(), Vec::new());
        if self.eat("<") {
            loop {
                let n = self.identifier()?;
                if self.eat("...") {
                    p.push(n)
                } else {
                    t.push(n)
                }
                if !self.eat(",") {
                    break;
                }
            }
            self.expect(">")?
        }
        Ok((t, p))
    }
    fn pack(&mut self, d: usize) -> crate::Result<TypePack> {
        let mut p = TypePack::default();
        if self.peek() == ")" {
            return Ok(p);
        }
        loop {
            if self.tokens.get(self.at + 1).is_some_and(|t| t == ":") {
                self.identifier()?;
                self.expect(":")?;
            }
            if self.eat("...") {
                p.tail = Some(PackTail::Variadic(Box::new(self.ty(d + 1)?)));
                break;
            }
            if crate::names::is_identifier(self.peek())
                && self.tokens.get(self.at + 1).is_some_and(|t| t == "...")
            {
                let n = self.identifier()?;
                self.expect("...")?;
                p.tail = Some(PackTail::Generic(n));
                break;
            }
            p.head.push(self.ty(d + 1)?);
            if !self.eat(",") {
                break;
            }
        }
        Ok(p)
    }
}
