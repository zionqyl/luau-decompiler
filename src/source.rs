use crate::input::InputFormat;
use crate::platform::Instant;
use crate::type_ast::{parse_type, FunctionType, TypeExpr, TypePack};
use crate::types::{TypeReport, TypingMode};
use crate::{execution, Config, Error, Result};
use serde::Serialize;
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize)]
pub struct SourceBinding {
    pub id: String,
    pub name: String,
    pub original_name: String,
    pub declaration_start: usize,
    pub declaration_end: usize,
    pub parameter: bool,
    pub function: bool,
    pub assigned: bool,
    pub captured: bool,
    pub type_only: bool,
    pub annotation_source: Option<String>,
    pub ty: Option<TypeExpr>,
    pub origin: Option<crate::types::TypeOrigin>,
}

#[derive(Debug, Clone, Serialize)]
pub struct SourceFunction {
    pub id: usize,
    pub signature_end: usize,
    pub type_only: bool,
    pub original_return_annotation: Option<String>,
    pub returns: Option<TypePack>,
    pub origin: Option<crate::types::TypeOrigin>,
}

#[derive(Debug, Clone, Serialize)]
pub(crate) struct SourceOutput {
    pub source: String,
    pub baseline_source: Option<String>,
    pub baseline_type_report: TypeReport,
    pub type_report: TypeReport,
    pub parse_micros: u64,
    pub infer_micros: u64,
    pub format_micros: u64,
    pub statements: usize,
    pub bindings: Vec<SourceBinding>,
    pub functions: Vec<SourceFunction>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum TokenKind {
    Identifier,
    Number,
    String,
    Symbol,
}

#[derive(Debug, Clone, Copy)]
struct Token {
    kind: TokenKind,
    start: usize,
    end: usize,
}

#[derive(Debug, Clone, Copy)]
struct Comment {
    start: usize,
    end: usize,
}

struct Lexed {
    tokens: Vec<Token>,
    comments: Vec<Comment>,
}

fn source_error(stage: &'static str, offset: usize, message: impl Into<String>) -> Error {
    Error::new(stage, message).at_offset(offset)
}

fn long_delimiter(bytes: &[u8], at: usize) -> Option<usize> {
    if bytes.get(at) != Some(&b'[') {
        return None;
    }
    let mut cursor = at + 1;
    while bytes.get(cursor) == Some(&b'=') {
        cursor += 1;
    }
    (bytes.get(cursor) == Some(&b'[')).then_some(cursor - at - 1)
}

fn long_end(bytes: &[u8], start: usize, equals: usize) -> Result<usize> {
    let mut at = start + equals + 2;
    while at < bytes.len() {
        if at & 1023 == 0 {
            execution::checkpoint()?;
        }
        if bytes[at] == b']'
            && bytes
                .get(at + 1..at + equals + 1)
                .is_some_and(|middle| middle.iter().all(|byte| *byte == b'='))
            && bytes.get(at + equals + 1) == Some(&b']')
        {
            return Ok(at + equals + 2);
        }
        at += 1;
    }
    Err(source_error(
        "source_lex",
        start,
        "unterminated long string/comment",
    ))
}

fn lex(source: &str, format: InputFormat, config: &Config) -> Result<Lexed> {
    let bytes = source.as_bytes();
    let mut at = 0;
    let mut tokens = Vec::new();
    let mut comments = Vec::new();
    while at < bytes.len() {
        execution::charge_work(1)?;
        let start = at;
        let byte = bytes[at];
        if byte.is_ascii_whitespace() {
            at += 1;
            continue;
        }
        if byte == b'-' && bytes.get(at + 1) == Some(&b'-') {
            at += 2;
            if let Some(equals) = long_delimiter(bytes, at) {
                at = long_end(bytes, at, equals)?;
            } else {
                while at < bytes.len() && !matches!(bytes[at], b'\r' | b'\n') {
                    at += 1;
                }
            }
            execution::reserve_ast_capacity(std::mem::size_of::<Comment>() * 2)?;
            comments.push(Comment { start, end: at });
            continue;
        }
        let kind = if byte.is_ascii_alphabetic() || byte == b'_' {
            at += 1;
            while at < bytes.len() && (bytes[at].is_ascii_alphanumeric() || bytes[at] == b'_') {
                at += 1;
            }
            TokenKind::Identifier
        } else if byte == b'\'' || byte == b'"' {
            let quote = byte;
            at += 1;
            let mut closed = false;
            while at < bytes.len() {
                if at & 1023 == 0 {
                    execution::checkpoint()?;
                }
                let current = bytes[at];
                at += 1;
                if current == quote {
                    closed = true;
                    break;
                }
                if matches!(current, b'\n' | b'\r') {
                    return Err(source_error(
                        "source_lex",
                        at - 1,
                        "unescaped newline in quoted string",
                    ));
                }
                if current != b'\\' {
                    continue;
                }
                let escape = *bytes.get(at).ok_or_else(|| {
                    source_error("source_lex", start, "unterminated string escape")
                })?;
                at += 1;
                match escape {
                    b'a' | b'b' | b'f' | b'n' | b'r' | b't' | b'v' | b'\\' | b'\'' | b'"'
                    | b'\n' => {}
                    b'\r' => {
                        if bytes.get(at) == Some(&b'\n') {
                            at += 1;
                        }
                    }
                    b'0'..=b'9' => {
                        let mut value = u16::from(escape - b'0');
                        for _ in 0..2 {
                            if let Some(digit @ b'0'..=b'9') = bytes.get(at) {
                                value = value * 10 + u16::from(*digit - b'0');
                                at += 1;
                            } else {
                                break;
                            }
                        }
                        if value > 255 {
                            return Err(source_error(
                                "source_lex",
                                at,
                                "decimal string escape exceeds one byte",
                            ));
                        }
                    }
                    b'z' if format != InputFormat::LuaSource => {
                        while bytes.get(at).is_some_and(u8::is_ascii_whitespace) {
                            at += 1;
                        }
                    }
                    b'x' if format != InputFormat::LuaSource => {
                        if !bytes
                            .get(at..at + 2)
                            .is_some_and(|pair| pair.iter().all(u8::is_ascii_hexdigit))
                        {
                            return Err(source_error(
                                "source_lex",
                                at,
                                "hex string escape requires two hexadecimal digits",
                            ));
                        }
                        at += 2;
                    }
                    b'u' if format != InputFormat::LuaSource => {
                        if bytes.get(at) != Some(&b'{') {
                            return Err(source_error(
                                "source_lex",
                                at,
                                "Unicode string escape requires braces",
                            ));
                        }
                        at += 1;
                        let digits = at;
                        while bytes.get(at).is_some_and(u8::is_ascii_hexdigit) {
                            at += 1;
                        }
                        let value = u32::from_str_radix(&source[digits..at], 16)
                            .ok()
                            .and_then(char::from_u32);
                        if value.is_none() || bytes.get(at) != Some(&b'}') {
                            return Err(source_error(
                                "source_lex",
                                digits,
                                "invalid Unicode string escape",
                            ));
                        }
                        at += 1;
                    }
                    _ => {
                        return Err(source_error(
                            "source_lex",
                            at - 1,
                            "unsupported string escape in selected dialect",
                        ))
                    }
                }
            }
            if !closed {
                return Err(source_error(
                    "source_lex",
                    start,
                    "unterminated quoted string",
                ));
            }
            TokenKind::String
        } else if let Some(equals) = long_delimiter(bytes, at) {
            at = long_end(bytes, at, equals)?;
            TokenKind::String
        } else if byte.is_ascii_digit()
            || (byte == b'.' && bytes.get(at + 1).is_some_and(u8::is_ascii_digit))
        {
            let hexadecimal = byte == b'0' && matches!(bytes.get(at + 1), Some(b'x' | b'X'));
            let binary = byte == b'0' && matches!(bytes.get(at + 1), Some(b'b' | b'B'));
            if binary && format == InputFormat::LuaSource {
                return Err(source_error(
                    "source_dialect",
                    start,
                    "binary numeric literals are outside the Lua 5.1 source subset",
                ));
            }
            if hexadecimal || binary {
                at += 2;
            }
            let digits = at;
            while at < bytes.len()
                && (if hexadecimal {
                    bytes[at].is_ascii_hexdigit()
                } else if binary {
                    matches!(bytes[at], b'0' | b'1')
                } else {
                    bytes[at].is_ascii_digit()
                } || bytes[at] == b'_')
            {
                at += 1;
            }
            let mut has_digit = source[digits..at].bytes().any(|b| b != b'_');
            if !binary && bytes.get(at) == Some(&b'.') && bytes.get(at + 1) != Some(&b'.') {
                at += 1;
                let fraction = at;
                while at < bytes.len()
                    && (if hexadecimal {
                        bytes[at].is_ascii_hexdigit()
                    } else {
                        bytes[at].is_ascii_digit()
                    } || bytes[at] == b'_')
                {
                    at += 1;
                }
                has_digit |= source[fraction..at].bytes().any(|b| b != b'_');
            }
            let exponent = if hexadecimal { b'p' } else { b'e' };
            if bytes
                .get(at)
                .is_some_and(|b| b.to_ascii_lowercase() == exponent)
            {
                if format == InputFormat::LuaSource && hexadecimal {
                    return Err(source_error(
                        "source_dialect",
                        start,
                        "hexadecimal floats are outside the Lua 5.1 source subset",
                    ));
                }
                at += 1;
                if matches!(bytes.get(at), Some(b'+' | b'-')) {
                    at += 1;
                }
                let exponent_start = at;
                while bytes.get(at).is_some_and(u8::is_ascii_digit) {
                    at += 1;
                }
                if at == exponent_start {
                    return Err(source_error(
                        "source_lex",
                        at,
                        "numeric exponent has no digits",
                    ));
                }
            }
            if !has_digit
                || bytes
                    .get(at)
                    .is_some_and(|b| b.is_ascii_alphanumeric() || *b == b'_')
            {
                return Err(source_error(
                    "source_lex",
                    start,
                    "malformed numeric literal",
                ));
            }
            if format == InputFormat::LuaSource && source[start..at].contains('_') {
                return Err(source_error(
                    "source_dialect",
                    start,
                    "numeric separators are outside the Lua 5.1 source subset",
                ));
            }
            TokenKind::Number
        } else {
            if byte == b'`' {
                return Err(source_error(
                    "source_unsupported",
                    start,
                    "interpolated strings are not implemented by the source parser",
                ));
            }
            let mut width = 1;
            for symbol in [
                "...", "..=", "//=", "==", "~=", "<=", ">=", "..", "::", "->", "+=", "-=", "*=",
                "/=", "%=", "^=", "//",
            ] {
                if source[start..].starts_with(symbol) {
                    width = symbol.len();
                    break;
                }
            }
            if width == 1 && !b"+-*/%^#=<>;:,().{}[]?&|".contains(&byte) {
                return Err(source_error(
                    "source_lex",
                    start,
                    format!("unsupported source token byte 0x{byte:02x}"),
                ));
            }
            at += width;
            TokenKind::Symbol
        };
        if tokens.len()
            >= config
                .typing
                .max_nodes
                .min(config.limits.max_instructions.saturating_mul(8))
        {
            return Err(source_error("limit", start, "source token budget exceeded"));
        }
        execution::reserve_ast_capacity(std::mem::size_of::<Token>() * 2)?;
        tokens.push(Token {
            kind,
            start,
            end: at,
        });
    }
    Ok(Lexed { tokens, comments })
}

#[derive(Clone, Copy, Default)]
struct Expression {
    binding: Option<usize>,
    assignable: bool,
    call: bool,
    prefix: bool,
    literal: Option<LiteralType>,
    require_function: bool,
    module_import: bool,
    fact: Option<usize>,
}

#[derive(Clone, Copy)]
enum LiteralType {
    Number,
    String,
    Boolean,
    Nil,
}
impl LiteralType {
    fn ty(self) -> TypeExpr {
        match self {
            Self::Number => TypeExpr::Number,
            Self::String => TypeExpr::String,
            Self::Boolean => TypeExpr::Boolean,
            Self::Nil => TypeExpr::Nil,
        }
    }
}

struct Binding {
    name_token: usize,
    name: String,
    annotation: Option<usize>,
    inferred: Option<LiteralType>,
    assigned: bool,
    parameter: bool,
    function: bool,
    function_nesting: usize,
    captured: bool,
    type_only: bool,
    fact: Option<usize>,
}

enum SourceFact {
    Literal(LiteralType),
    Binding(usize),
    Unary(&'static str, usize),
    Binary(String, usize, usize),
    Join(Vec<usize>),
    Function(usize),
}

struct ReturnInference {
    insertion: usize,
    root_depth: usize,
    explicit: bool,
    type_only: bool,
    terminal: bool,
    returns: Vec<Option<Vec<usize>>>,
    original_annotation: Option<usize>,
    parameters: Vec<usize>,
    variadic: bool,
    generic: bool,
    generic_names: Vec<String>,
    effectful: bool,
}

struct Annotation {
    start: usize,
    end: usize,
    parsed: Option<TypeExpr>,
    role: &'static str,
    explicit_any: usize,
    type_only: bool,
}

struct TypeSpacing {
    after_colon: Vec<bool>,
    compact_before: Vec<bool>,
}

struct Parser<'a> {
    source: &'a str,
    tokens: &'a [Token],
    format: InputFormat,
    config: &'a Config,
    at: usize,
    depth: usize,
    indentation: usize,
    scopes: Vec<BTreeMap<String, usize>>,
    import_scopes: Vec<BTreeMap<String, usize>>,
    bindings: Vec<Binding>,
    annotations: Vec<Annotation>,
    lines: Vec<Option<usize>>,
    type_spacing: TypeSpacing,
    token_bindings: Vec<Option<usize>>,
    statements: usize,
    loops: usize,
    varargs: bool,
    variadic_functions: usize,
    function_nesting: usize,
    type_any_count: usize,
    type_context: bool,
    type_pack_root: Option<usize>,
    type_pack_item: Option<usize>,
    facts: Vec<SourceFact>,
    functions: Vec<ReturnInference>,
    active_functions: Vec<usize>,
}

impl<'a> Parser<'a> {
    fn remember_fact(&mut self, fact: SourceFact) -> Result<usize> {
        execution::charge_work(1)?;
        execution::reserve_ast_capacity(std::mem::size_of::<SourceFact>())?;
        let id = self.facts.len();
        self.facts.push(fact);
        Ok(id)
    }
    fn expression_fact(&mut self, value: Expression) -> Result<Option<usize>> {
        if let Some(fact) = value.fact {
            return Ok(Some(fact));
        }
        if let Some(literal) = value.literal {
            return self.remember_fact(SourceFact::Literal(literal)).map(Some);
        }
        if let Some(binding) = value.binding {
            return self.remember_fact(SourceFact::Binding(binding)).map(Some);
        }
        Ok(None)
    }
    fn new(source: &'a str, tokens: &'a [Token], format: InputFormat, config: &'a Config) -> Self {
        Self {
            source,
            tokens,
            format,
            config,
            at: 0,
            depth: 0,
            indentation: 0,
            scopes: vec![BTreeMap::new()],
            import_scopes: vec![BTreeMap::new()],
            bindings: Vec::new(),
            annotations: Vec::new(),
            lines: vec![None; tokens.len() + 1],
            type_spacing: TypeSpacing {
                after_colon: vec![false; tokens.len() + 1],
                compact_before: vec![false; tokens.len() + 1],
            },
            token_bindings: vec![None; tokens.len() + 1],
            statements: 0,
            loops: 0,
            varargs: true,
            variadic_functions: 0,
            function_nesting: 0,
            type_any_count: 0,
            type_context: false,
            type_pack_root: None,
            type_pack_item: None,
            facts: Vec::new(),
            functions: Vec::new(),
            active_functions: Vec::new(),
        }
    }
    fn peek(&self) -> &'a str {
        self.tokens
            .get(self.at)
            .map_or("", |token| &self.source[token.start..token.end])
    }
    fn look(&self, ahead: usize) -> &'a str {
        self.tokens
            .get(self.at + ahead)
            .map_or("", |token| &self.source[token.start..token.end])
    }
    fn offset(&self) -> usize {
        self.tokens
            .get(self.at)
            .map_or(self.source.len(), |token| token.start)
    }
    fn error(&self, message: impl Into<String>) -> Error {
        source_error("source_parse", self.offset(), message)
    }
    fn eat(&mut self, value: &str) -> bool {
        if self.peek() == value {
            self.at += 1;
            true
        } else {
            false
        }
    }
    fn expect(&mut self, value: &str) -> Result<()> {
        if self.eat(value) {
            Ok(())
        } else {
            Err(self.error(format!("expected {value:?}, found {:?}", self.peek())))
        }
    }
    fn identifier(&mut self) -> Result<usize> {
        if !crate::names::is_identifier(self.peek()) {
            return Err(self.error(format!("expected identifier, found {:?}", self.peek())));
        }
        let index = self.at;
        self.at += 1;
        Ok(index)
    }
    fn enter(&mut self) -> Result<()> {
        self.depth += 1;
        if self.depth > self.config.limits.max_depth.min(128) {
            return Err(self.error("source syntax nesting limit exceeded"));
        }
        execution::charge_work(1)
    }
    fn leave(&mut self) {
        self.depth -= 1;
    }
    fn line(&mut self) {
        self.lines[self.at] = Some(self.indentation);
    }
    fn scope(&mut self) {
        self.scopes.push(BTreeMap::new());
        self.import_scopes.push(BTreeMap::new());
    }
    fn unscope(&mut self) {
        self.scopes.pop();
        self.import_scopes.pop();
    }
    fn text(&self, token: usize) -> &'a str {
        let token = self.tokens[token];
        &self.source[token.start..token.end]
    }
    fn resolve(&self, name: &str) -> Option<usize> {
        self.scopes
            .iter()
            .rev()
            .find_map(|scope| scope.get(name).copied())
    }
    fn bind(
        &mut self,
        name_token: usize,
        annotation: Option<usize>,
        parameter: bool,
        function: bool,
    ) -> usize {
        let name = self.text(name_token).to_owned();
        let id = self.bindings.len();
        self.token_bindings[name_token] = Some(id);
        self.bindings.push(Binding {
            name_token,
            name: name.clone(),
            annotation,
            inferred: None,
            assigned: false,
            parameter,
            function,
            function_nesting: self.function_nesting,
            captured: false,
            type_only: self.type_context,
            fact: None,
        });
        if let Some(scope) = self.scopes.last_mut() {
            scope.insert(name, id);
        }
        id
    }
    fn mark_assignment(&mut self, expression: Expression) {
        if let Some(binding) = expression.binding {
            self.bindings[binding].assigned = true;
        }
    }
    fn luau_only(&self, feature: &str) -> Result<()> {
        if self.format == InputFormat::LuaSource {
            Err(source_error(
                "source_dialect",
                self.offset(),
                format!("{feature} is outside the Lua 5.1 source subset"),
            ))
        } else {
            Ok(())
        }
    }
    fn block(&mut self, terminators: &[&str]) -> Result<()> {
        self.enter()?;
        while !self.peek().is_empty() && !terminators.contains(&self.peek()) {
            self.line();
            if self.eat(";") {
                continue;
            }
            self.statements += 1;
            let terminal = self.statement()?;
            self.eat(";");
            if terminal && !self.peek().is_empty() && !terminators.contains(&self.peek()) {
                return Err(self
                    .error("a return/break/continue statement must terminate this source block"));
            }
        }
        self.leave();
        Ok(())
    }
    fn nested_block(&mut self, terminators: &[&str]) -> Result<()> {
        self.scope();
        self.indentation += 1;
        self.block(terminators)?;
        self.indentation -= 1;
        self.unscope();
        self.line();
        Ok(())
    }
    fn statement(&mut self) -> Result<bool> {
        match self.peek() {
            "local" => {
                self.at += 1;
                self.local()?;
            }
            "function" => {
                self.at += 1;
                let name = self.identifier()?;
                if let Some(binding) = self
                    .resolve(self.text(name))
                    .filter(|binding| *binding != usize::MAX)
                {
                    self.bindings[binding].assigned = true;
                    if !self.type_context
                        && self.bindings[binding].function_nesting < self.function_nesting
                    {
                        self.bindings[binding].captured = true;
                    }
                    self.token_bindings[name] = Some(binding);
                }
                while self.eat(".") {
                    self.identifier()?;
                }
                let method = if self.eat(":") {
                    self.identifier()?;
                    true
                } else {
                    false
                };
                self.function_body(method)?;
            }
            "if" => {
                self.at += 1;
                self.expression(0)?;
                self.expect("then")?;
                self.nested_block(&["elseif", "else", "end"])?;
                while self.eat("elseif") {
                    self.expression(0)?;
                    self.expect("then")?;
                    self.nested_block(&["elseif", "else", "end"])?;
                }
                if self.eat("else") {
                    self.nested_block(&["end"])?;
                }
                self.expect("end")?;
            }
            "while" => {
                self.at += 1;
                self.expression(0)?;
                self.expect("do")?;
                self.loops += 1;
                self.nested_block(&["end"])?;
                self.loops -= 1;
                self.expect("end")?;
            }
            "repeat" => {
                self.at += 1;
                self.scope();
                self.indentation += 1;
                self.loops += 1;
                self.block(&["until"])?;
                self.indentation -= 1;
                self.line();
                self.expect("until")?;
                self.expression(0)?;
                self.loops -= 1;
                self.unscope();
            }
            "for" => self.for_statement()?,
            "do" => {
                self.at += 1;
                self.nested_block(&["end"])?;
                self.expect("end")?;
            }
            "return" => {
                self.at += 1;
                let values =
                    if !matches!(self.peek(), "" | "end" | "else" | "elseif" | "until" | ";") {
                        self.expression_list()?
                    } else {
                        Vec::new()
                    };
                if let Some(function) = self.active_functions.last().copied() {
                    let facts = if values.last().is_some_and(|value| value.call) {
                        None
                    } else {
                        let mut facts = Some(Vec::with_capacity(values.len()));
                        for value in values {
                            match self.expression_fact(value)? {
                                Some(value) => {
                                    if let Some(facts) = &mut facts {
                                        facts.push(value);
                                    }
                                }
                                None => facts = None,
                            }
                        }
                        facts
                    };
                    self.functions[function].returns.push(facts);
                    if self.functions[function].root_depth == self.depth {
                        self.functions[function].terminal = true;
                    }
                }
                return Ok(true);
            }
            "break" | "continue" => {
                if self.peek() == "continue" {
                    self.luau_only("continue")?;
                }
                if self.loops == 0 {
                    return Err(self.error("loop control outside a loop"));
                }
                self.at += 1;
                return Ok(true);
            }
            "type"
                if crate::names::is_identifier(self.look(1))
                    && matches!(self.look(2), "=" | "<" | "function") =>
            {
                self.type_alias()?
            }
            "export" if self.look(1) == "type" => self.type_alias()?,
            "goto" => {
                return Err(source_error(
                    "source_dialect",
                    self.offset(),
                    "goto/Lua 5.2+ dialect conversion is unsupported",
                ))
            }
            _ => {
                let first = self.expression(0)?;
                let mut targets = vec![first];
                while self.eat(",") {
                    targets.push(self.expression(0)?);
                }
                let operator = self.peek();
                if matches!(
                    operator,
                    "=" | "+=" | "-=" | "*=" | "/=" | "//=" | "%=" | "^=" | "..="
                ) {
                    if operator != "=" {
                        self.luau_only("compound assignment")?;
                        if targets.len() != 1 {
                            return Err(self.error("compound assignment requires one target"));
                        }
                    }
                    for target in targets {
                        if !target.assignable {
                            return Err(
                                self.error("assignment target is not a variable or table access")
                            );
                        }
                        self.mark_assignment(target);
                    }
                    self.at += 1;
                    self.expression_list()?;
                } else if targets.len() != 1 || !first.call {
                    return Err(self.error("expected an assignment or function-call statement"));
                }
            }
        }
        Ok(false)
    }
    fn local(&mut self) -> Result<()> {
        if self.eat("function") {
            let name = self.identifier()?;
            let binding = self.bind(name, None, false, true);
            let function = self.function_body(false)?;
            self.bindings[binding].fact = Some(self.remember_fact(SourceFact::Function(function))?);
            return Ok(());
        }
        let mut pending = Vec::new();
        loop {
            let name = self.identifier()?;
            let annotation = if self.eat(":") {
                self.luau_only("type annotations")?;
                Some(self.annotation("local")?)
            } else {
                None
            };
            pending.push((name, annotation));
            if !self.eat(",") {
                break;
            }
        }
        let values = if self.eat("=") {
            self.expression_list()?
        } else {
            Vec::new()
        };
        for (index, (name, annotation)) in pending.into_iter().enumerate() {
            let id = self.bind(name, annotation, false, false);
            self.bindings[id].inferred =
                values.get(index).and_then(|expression| expression.literal);
            self.bindings[id].fact = match values.get(index).copied() {
                Some(value) => self.expression_fact(value)?,
                None => None,
            };
            if values
                .get(index)
                .is_some_and(|expression| expression.module_import)
            {
                if let Some(scope) = self.import_scopes.last_mut() {
                    scope.insert(self.bindings[id].name.clone(), id);
                }
            }
        }
        Ok(())
    }
    fn for_statement(&mut self) -> Result<()> {
        self.expect("for")?;
        let first = self.identifier()?;
        let first_annotation = if self.eat(":") {
            self.luau_only("for binding annotations")?;
            Some(self.annotation("local")?)
        } else {
            None
        };
        let mut names = vec![(first, first_annotation)];
        while self.eat(",") {
            let name = self.identifier()?;
            let annotation = if self.eat(":") {
                self.luau_only("for binding annotations")?;
                Some(self.annotation("local")?)
            } else {
                None
            };
            names.push((name, annotation));
        }
        let numeric = self.eat("=");
        if numeric {
            if names.len() != 1 {
                return Err(self.error("numeric for requires one binding"));
            }
            self.expression(0)?;
            self.expect(",")?;
            self.expression(0)?;
            if self.eat(",") {
                self.expression(0)?;
            }
        } else {
            self.expect("in")?;
            let lua_iterator = if self.format == InputFormat::LuaSource {
                let name = self.peek();
                if self.resolve(name).is_some() || !matches!(name, "pairs" | "ipairs" | "next") {
                    return Err(source_error("source_dialect", self.offset(), "Lua source generic for requires an unshadowed standard pairs/ipairs call or next iterator; Luau generalized table iteration changes Lua 5.1 behavior"));
                }
                Some(name)
            } else {
                None
            };
            let values = self.expression_list()?;
            if let Some(iterator) = lua_iterator {
                let valid = if iterator == "next" {
                    (2..=3).contains(&values.len()) && values[0].assignable
                } else {
                    values.len() == 1 && values[0].call
                };
                if !valid {
                    return Err(source_error(
                        "source_dialect",
                        self.offset(),
                        "unsupported Lua source generic iterator expression",
                    ));
                }
            }
        }
        self.expect("do")?;
        self.scope();
        for (name, annotation) in names {
            let binding = self.bind(name, annotation, false, false);
            if numeric {
                self.bindings[binding].inferred = Some(LiteralType::Number);
            }
        }
        self.loops += 1;
        self.indentation += 1;
        self.block(&["end"])?;
        self.indentation -= 1;
        self.loops -= 1;
        self.unscope();
        self.line();
        self.expect("end")
    }
    fn generics(&mut self) -> Result<()> {
        if !self.eat("<") {
            return Ok(());
        }
        self.type_spacing.compact_before[self.at - 1] = true;
        self.type_spacing.compact_before[self.at] = true;
        self.luau_only("generics")?;
        loop {
            self.identifier()?;
            if self.eat("...") {
                self.type_spacing.compact_before[self.at - 1] = true;
            }
            if !self.eat(",") {
                break;
            }
        }
        self.type_spacing.compact_before[self.at] = true;
        self.expect(">")
    }
    fn function_body(&mut self, method: bool) -> Result<usize> {
        self.enter()?;
        self.function_nesting += 1;
        let generic = self.peek() == "<";
        let generic_start = self.at;
        self.generics()?;
        let generic_names = self.tokens[generic_start..self.at]
            .iter()
            .filter(|token| token.kind == TokenKind::Identifier)
            .map(|token| self.source[token.start..token.end].to_owned())
            .collect();
        self.expect("(")?;
        self.scope();
        if method {
            self.scopes
                .last_mut()
                .unwrap()
                .insert("self".into(), usize::MAX);
        }
        let old_varargs = self.varargs;
        let old_loops = self.loops;
        self.varargs = false;
        self.loops = 0;
        let mut parameters = Vec::new();
        if self.peek() != ")" {
            loop {
                if self.eat("...") {
                    self.varargs = true;
                    if !self.type_context {
                        self.variadic_functions += 1;
                    }
                    if self.eat(":") {
                        self.luau_only("variadic type annotations")?;
                        self.annotation("variadic")?;
                    }
                    break;
                }
                let name = self.identifier()?;
                let annotation = if self.eat(":") {
                    self.luau_only("parameter annotations")?;
                    Some(self.annotation("parameter")?)
                } else {
                    None
                };
                parameters.push(self.bind(name, annotation, true, false));
                if !self.eat(",") {
                    break;
                }
            }
        }
        let insertion = self.at;
        self.expect(")")?;
        let explicit = self.eat(":");
        let original_annotation = if explicit {
            self.luau_only("return annotations")?;
            Some(self.annotation("return")?)
        } else {
            None
        };
        let function = self.functions.len();
        self.functions.push(ReturnInference {
            insertion,
            root_depth: self.depth + 1,
            explicit: explicit || self.type_context,
            type_only: self.type_context,
            terminal: false,
            returns: Vec::new(),
            original_annotation,
            parameters,
            variadic: self.varargs || method,
            generic,
            generic_names,
            effectful: false,
        });
        self.active_functions.push(function);
        self.indentation += 1;
        self.block(&["end"])?;
        self.indentation -= 1;
        self.line();
        self.expect("end")?;
        self.active_functions.pop();
        self.unscope();
        self.varargs = old_varargs;
        self.loops = old_loops;
        self.function_nesting -= 1;
        self.leave();
        Ok(function)
    }
    fn expression_list(&mut self) -> Result<Vec<Expression>> {
        let mut list = vec![self.expression(0)?];
        while self.eat(",") {
            list.push(self.expression(0)?);
        }
        Ok(list)
    }
    fn expression(&mut self, minimum: u8) -> Result<Expression> {
        self.enter()?;
        let mut value = if matches!(self.peek(), "not" | "-" | "#") {
            let operator = self.peek();
            self.at += 1;
            let operand = self.expression(7)?;
            let fact = if operator == "not" {
                Some(self.remember_fact(SourceFact::Literal(LiteralType::Boolean))?)
            } else if let Some(operand) = self.expression_fact(operand)? {
                Some(self.remember_fact(SourceFact::Unary(
                    if operator == "-" { "-" } else { "#" },
                    operand,
                ))?)
            } else {
                None
            };
            Expression {
                fact,
                literal: if operator == "-" && matches!(operand.literal, Some(LiteralType::Number))
                {
                    operand.literal
                } else {
                    None
                },
                ..Expression::default()
            }
        } else {
            self.primary()?
        };
        loop {
            if self.peek() == "::" {
                self.luau_only("type assertions")?;
                self.at += 1;
                self.annotation("assertion")?;
                value = Expression::default();
                continue;
            }
            let (precedence, right_associative) = match self.peek() {
                "or" => (1, false),
                "and" => (2, false),
                "<" | ">" | "<=" | ">=" | "~=" | "==" => (3, false),
                ".." => (4, true),
                "+" | "-" => (5, false),
                "*" | "/" | "//" | "%" => (6, false),
                "^" => (8, true),
                _ => break,
            };
            if precedence < minimum {
                break;
            }
            if self.peek() == "//" {
                self.luau_only("floor division")?;
            }
            let operator = self.peek().to_owned();
            self.at += 1;
            let right = self.expression(if right_associative {
                precedence
            } else {
                precedence + 1
            })?;
            let fact = if matches!(operator.as_str(), "<" | ">" | "<=" | ">=" | "~=" | "==") {
                Some(self.remember_fact(SourceFact::Literal(LiteralType::Boolean))?)
            } else {
                match (self.expression_fact(value)?, self.expression_fact(right)?) {
                    (Some(left), Some(right)) => {
                        Some(self.remember_fact(SourceFact::Binary(operator, left, right))?)
                    }
                    _ => None,
                }
            };
            value = Expression {
                fact,
                ..Expression::default()
            };
        }
        self.leave();
        Ok(value)
    }
    fn primary(&mut self) -> Result<Expression> {
        let mut value = match self.peek() {
            "nil" => {
                self.at += 1;
                Expression {
                    literal: Some(LiteralType::Nil),
                    ..Expression::default()
                }
            }
            "true" | "false" => {
                self.at += 1;
                Expression {
                    literal: Some(LiteralType::Boolean),
                    ..Expression::default()
                }
            }
            "..." => {
                if !self.varargs {
                    return Err(self.error("varargs used outside a variadic function"));
                }
                self.at += 1;
                Expression::default()
            }
            "function" => {
                self.at += 1;
                let function = self.function_body(false)?;
                Expression {
                    fact: Some(self.remember_fact(SourceFact::Function(function))?),
                    ..Expression::default()
                }
            }
            "if" => {
                self.luau_only("if expressions")?;
                self.at += 1;
                self.expression(0)?;
                self.expect("then")?;
                let first = self.expression(0)?;
                let mut facts = self.expression_fact(first)?.map(|fact| vec![fact]);
                while self.eat("elseif") {
                    self.expression(0)?;
                    self.expect("then")?;
                    let branch = self.expression(0)?;
                    match (facts.as_mut(), self.expression_fact(branch)?) {
                        (Some(facts), Some(fact)) => facts.push(fact),
                        _ => facts = None,
                    }
                }
                self.expect("else")?;
                let branch = self.expression(0)?;
                match (facts.as_mut(), self.expression_fact(branch)?) {
                    (Some(facts), Some(fact)) => facts.push(fact),
                    _ => facts = None,
                }
                let fact = facts
                    .map(|facts| self.remember_fact(SourceFact::Join(facts)))
                    .transpose()?;
                Expression {
                    fact,
                    ..Expression::default()
                }
            }
            "{" => {
                self.table()?;
                Expression::default()
            }
            "(" => {
                self.at += 1;
                let inner = self.expression(0)?;
                self.expect(")")?;
                Expression {
                    literal: inner.literal,
                    binding: inner.binding,
                    fact: inner.fact,
                    prefix: true,
                    ..Expression::default()
                }
            }
            _ => {
                let token = self
                    .tokens
                    .get(self.at)
                    .ok_or_else(|| self.error("expected expression, found end of input"))?;
                match token.kind {
                    TokenKind::String => {
                        self.at += 1;
                        Expression {
                            literal: Some(LiteralType::String),
                            ..Expression::default()
                        }
                    }
                    TokenKind::Number => {
                        self.at += 1;
                        Expression {
                            literal: Some(LiteralType::Number),
                            ..Expression::default()
                        }
                    }
                    TokenKind::Identifier if crate::names::is_identifier(self.peek()) => {
                        let require_function =
                            self.peek() == "require" && self.resolve("require").is_none();
                        let binding = self
                            .resolve(self.peek())
                            .filter(|binding| *binding != usize::MAX);
                        if let Some(binding) = binding {
                            if !self.type_context
                                && self.bindings[binding].function_nesting < self.function_nesting
                            {
                                self.bindings[binding].captured = true;
                            }
                        }
                        self.token_bindings[self.at] = binding;
                        self.at += 1;
                        Expression {
                            binding,
                            assignable: true,
                            prefix: true,
                            require_function,
                            ..Expression::default()
                        }
                    }
                    _ => {
                        return Err(
                            self.error(format!("expected expression, found {:?}", self.peek()))
                        )
                    }
                }
            }
        };
        loop {
            let suffix = matches!(self.peek(), "." | "[" | ":" | "(" | "{")
                || self
                    .tokens
                    .get(self.at)
                    .is_some_and(|token| token.kind == TokenKind::String);
            if suffix && !value.prefix {
                return Err(self.error(
                    "this literal/function expression requires parentheses before a suffix",
                ));
            }
            if self.eat(".") {
                self.identifier()?;
                value = Expression {
                    assignable: true,
                    prefix: true,
                    ..Expression::default()
                };
            } else if self.eat("[") {
                self.expression(0)?;
                self.expect("]")?;
                value = Expression {
                    assignable: true,
                    prefix: true,
                    ..Expression::default()
                };
            } else if self.eat(":") {
                self.identifier()?;
                self.arguments()?;
                value = Expression {
                    call: true,
                    prefix: true,
                    ..Expression::default()
                };
            } else if self.peek() == "("
                || self.peek() == "{"
                || self
                    .tokens
                    .get(self.at)
                    .is_some_and(|token| token.kind == TokenKind::String)
            {
                let arguments = self.arguments()?;
                value = Expression {
                    call: true,
                    prefix: true,
                    module_import: value.require_function && arguments == 1,
                    ..Expression::default()
                };
            } else {
                break;
            }
        }
        Ok(value)
    }
    fn arguments(&mut self) -> Result<usize> {
        if !self.type_context {
            for function in &self.active_functions {
                self.functions[*function].effectful = true;
            }
        }
        if self.eat("(") {
            let opening = self.at - 1;
            let mut arguments = Vec::new();
            if self.peek() != ")" {
                loop {
                    arguments.push(self.at);
                    self.expression(0)?;
                    if !self.eat(",") {
                        break;
                    }
                }
            }
            let closing = self.at;
            self.expect(")")?;
            if self.config.formatting.multiline_calls
                && !arguments.is_empty()
                && self.tokens[closing].end - self.tokens[opening].start
                    > self.config.formatting.line_width
            {
                for line in self
                    .lines
                    .iter_mut()
                    .take(closing)
                    .skip(opening + 1)
                    .flatten()
                {
                    *line += 1;
                }
                for argument in &arguments {
                    self.lines[*argument] = Some(self.indentation + 1);
                }
                self.lines[closing] = Some(self.indentation);
            }
            Ok(arguments.len())
        } else if self.peek() == "{" {
            self.table()?;
            Ok(1)
        } else if self
            .tokens
            .get(self.at)
            .is_some_and(|token| token.kind == TokenKind::String)
        {
            self.at += 1;
            Ok(1)
        } else {
            Err(self.error("expected call arguments"))
        }
    }
    fn table(&mut self) -> Result<()> {
        self.expect("{")?;
        self.enter()?;
        let multiline = self.config.formatting.multiline_tables && self.peek() != "}";
        if multiline {
            self.indentation += 1;
        }
        while self.peek() != "}" {
            if multiline {
                self.line();
            }
            if self.peek().is_empty() {
                return Err(self.error("unterminated table constructor"));
            }
            if self.eat("[") {
                self.expression(0)?;
                self.expect("]")?;
                self.expect("=")?;
                self.expression(0)?;
            } else if crate::names::is_identifier(self.peek()) && self.look(1) == "=" {
                self.at += 2;
                self.expression(0)?;
            } else {
                self.expression(0)?;
            }
            if !self.eat(",") && !self.eat(";") {
                break;
            }
        }
        if multiline {
            self.indentation -= 1;
            self.line();
        }
        self.expect("}")?;
        self.leave();
        Ok(())
    }
    fn type_alias(&mut self) -> Result<()> {
        self.luau_only("type aliases")?;
        self.eat("export");
        self.expect("type")?;
        if self.peek() == "function" {
            return Err(source_error(
                "source_unsupported",
                self.offset(),
                "user-defined type functions are never executed or accepted by source processing",
            ));
        }
        self.identifier()?;
        self.generics()?;
        self.expect("=")?;
        self.annotation("alias")?;
        Ok(())
    }
    fn annotation(&mut self, role: &'static str) -> Result<usize> {
        let start = self.at;
        let any_start = self.type_any_count;
        let nested_start = self.annotations.len();
        self.type_spacing.after_colon[start] = true;
        let old_pack_root = self.type_pack_root;
        self.type_pack_root = matches!(role, "return" | "variadic").then_some(self.depth + 1);
        let old_type_context = self.type_context;
        self.type_context = true;
        let parsed_annotation = self.type_expression(0);
        self.type_context = old_type_context;
        parsed_annotation?;
        self.type_pack_root = old_pack_root;
        let end = self.at;
        let raw = &self.source[self.tokens[start].start..self.tokens[end - 1].end];
        let parsed = if role == "return" {
            parse_type(&if raw.starts_with('(') {
                format!("() -> {raw}")
            } else {
                format!("() -> ({raw})")
            })
            .ok()
        } else if role == "variadic" && raw.ends_with("...") {
            parse_type(&format!("() -> ({raw})")).ok()
        } else {
            parse_type(raw).ok()
        };
        let id = self.annotations.len();
        execution::charge_work(self.annotations.len() - nested_start)?;
        let nested_any = self.annotations[nested_start..]
            .iter()
            .map(|annotation| annotation.explicit_any)
            .sum::<usize>();
        self.annotations.push(Annotation {
            start,
            end,
            parsed,
            role,
            explicit_any: (self.type_any_count - any_start).saturating_sub(nested_any),
            type_only: old_type_context || role == "alias",
        });
        Ok(id)
    }
    fn type_expression(&mut self, minimum: u8) -> Result<()> {
        self.enter()?;
        self.type_atom()?;
        while self.eat("?") {}
        loop {
            let precedence = match self.peek() {
                "|" => 1,
                "&" => 2,
                _ => break,
            };
            if precedence < minimum {
                break;
            }
            self.at += 1;
            self.type_expression(precedence + 1)?;
        }
        self.leave();
        Ok(())
    }
    fn type_atom(&mut self) -> Result<()> {
        if self.peek() == "<" {
            self.generics()?;
            self.type_parentheses()?;
            self.expect("->")?;
            return self.type_return();
        }
        if self.peek() == "(" {
            let (count, tail) = self.type_parentheses()?;
            if self.eat("->") {
                self.type_return()?;
            } else if (count != 1 || tail) && self.type_pack_root != Some(self.depth) {
                return Err(self.error("a tuple type pack is valid only in a return/pack position or before a function-type arrow"));
            }
            return Ok(());
        }
        if self.eat("{") {
            let multiline = self.config.formatting.multiline_tables && self.peek() != "}";
            if multiline {
                self.indentation += 1;
            }
            while !self.eat("}") {
                if multiline {
                    self.line();
                }
                if self.peek().is_empty() {
                    return Err(self.error("unterminated table type"));
                }
                if self.eat("[") {
                    self.type_expression(0)?;
                    self.expect("]")?;
                    self.expect(":")?;
                    self.type_spacing.after_colon[self.at] = true;
                    self.type_expression(0)?;
                } else if (crate::names::is_identifier(self.peek())
                    || matches!(self.peek(), "read" | "write"))
                    && self.look(1) == ":"
                {
                    self.at += 2;
                    self.type_spacing.after_colon[self.at] = true;
                    self.type_expression(0)?;
                } else {
                    self.type_expression(0)?;
                }
                if !self.eat(",") && !self.eat(";") {
                    if multiline {
                        self.indentation -= 1;
                        self.line();
                    }
                    self.expect("}")?;
                    return Ok(());
                }
            }
            if multiline {
                self.indentation -= 1;
                self.lines[self.at - 1] = Some(self.indentation);
            }
            return Ok(());
        }
        if self.eat("...") {
            if self.type_pack_item != Some(self.depth) && self.type_pack_root != Some(self.depth) {
                return Err(self.error("variadic type pack outside a pack position"));
            }
            return self.type_expression(0);
        }
        if self.peek() == "typeof" && self.look(1) == "(" {
            self.at += 2;
            self.expression(0)?;
            return self.expect(")");
        }
        if matches!(self.peek(), "nil" | "true" | "false")
            || self
                .tokens
                .get(self.at)
                .is_some_and(|token| token.kind == TokenKind::String)
        {
            self.at += 1;
            return Ok(());
        }
        let name = self.identifier()?;
        if self.peek() == "." {
            self.token_bindings[name] = self
                .import_scopes
                .iter()
                .rev()
                .find_map(|scope| scope.get(self.text(name)).copied());
        }
        let primitive_any = self.text(name) == "any" && self.peek() != ".";
        if primitive_any {
            self.type_any_count += 1;
        }
        while self.eat(".") {
            self.identifier()?;
        }
        if self.eat("<") {
            self.type_spacing.compact_before[self.at - 1] = true;
            self.type_spacing.compact_before[self.at] = true;
            if self.peek() == ">" {
                return Err(self.error("generic application requires an argument"));
            }
            loop {
                self.type_return()?;
                if !self.eat(",") {
                    break;
                }
            }
            self.type_spacing.compact_before[self.at] = true;
            self.expect(">")?;
        }
        if self.eat("...") {
            self.type_spacing.compact_before[self.at - 1] = true;
            if self.type_pack_item != Some(self.depth) && self.type_pack_root != Some(self.depth) {
                return Err(self.error("generic type pack outside a pack position"));
            }
            if matches!(self.peek(), "|" | "&" | "?") {
                return Err(
                    self.error("generic type pack cannot be a union/intersection/optional type")
                );
            }
        }
        Ok(())
    }
    fn type_return(&mut self) -> Result<()> {
        let old_pack_root = self.type_pack_root;
        self.type_pack_root = Some(self.depth + 1);
        let result = self.type_expression(0);
        self.type_pack_root = old_pack_root;
        result
    }
    fn type_parentheses(&mut self) -> Result<(usize, bool)> {
        self.expect("(")?;
        let mut count = 0;
        let mut tail = false;
        if self.peek() != ")" {
            loop {
                if crate::names::is_identifier(self.peek()) && self.look(1) == ":" {
                    self.at += 2;
                    self.type_spacing.after_colon[self.at] = true;
                }
                tail = self.peek() == "..." || self.look(1) == "...";
                let old_item = self.type_pack_item;
                self.type_pack_item = Some(self.depth + 1);
                self.type_expression(0)?;
                self.type_pack_item = old_item;
                count += 1;
                if !self.eat(",") {
                    break;
                }
                if tail {
                    return Err(self.error("variadic/generic type pack tail must be last"));
                }
            }
        }
        self.expect(")")?;
        Ok((count, tail))
    }
}

fn micros(start: Instant) -> u64 {
    start.elapsed().as_micros().min(u128::from(u64::MAX)) as u64
}

fn immutable_source_type(ty: &TypeExpr) -> bool {
    match ty {
        TypeExpr::Number
        | TypeExpr::String
        | TypeExpr::SingletonString(_)
        | TypeExpr::Boolean
        | TypeExpr::Nil
        | TypeExpr::Thread
        | TypeExpr::Buffer
        | TypeExpr::Never => true,
        TypeExpr::Optional(inner) => immutable_source_type(inner),
        TypeExpr::Union(types) | TypeExpr::Intersection(types) => {
            types.iter().all(immutable_source_type)
        }
        TypeExpr::Function(function) => {
            function.parameters.iter().all(immutable_source_type)
                && function.variadic.is_none()
                && function.returns.tail.is_none()
                && function.returns.head.iter().all(immutable_source_type)
        }
        _ => false,
    }
}

fn inferred_fact(
    parser: &Parser<'_>,
    id: usize,
    active: &mut Vec<usize>,
) -> Result<Option<TypeExpr>> {
    execution::charge_work(1)?;
    if active.len() >= parser.config.limits.max_depth || active.contains(&id) {
        return Ok(None);
    }
    active.push(id);
    let result = match &parser.facts[id] {
        SourceFact::Literal(literal) => Some(literal.ty()),
        SourceFact::Binding(id) => {
            let binding = &parser.bindings[*id];
            if let Some(annotation) = binding.annotation {
                parser.annotations[annotation]
                    .parsed
                    .clone()
                    .filter(immutable_source_type)
            } else if !binding.assigned {
                match binding.fact {
                    Some(fact) => inferred_fact(parser, fact, active)?,
                    None => binding.inferred.map(LiteralType::ty),
                }
            } else {
                None
            }
        }
        SourceFact::Unary(operator, operand) => {
            match (*operator, inferred_fact(parser, *operand, active)?) {
                ("-", Some(TypeExpr::Number)) | ("#", Some(TypeExpr::String)) => {
                    Some(TypeExpr::Number)
                }
                _ => None,
            }
        }
        SourceFact::Binary(operator, left, right) => {
            let left = inferred_fact(parser, *left, active)?;
            let right = inferred_fact(parser, *right, active)?;
            match (operator.as_str(), left, right) {
                ("and" | "or", Some(left), Some(right)) => Some(TypeExpr::union(left, right)),
                (
                    "+" | "-" | "*" | "/" | "//" | "%" | "^",
                    Some(TypeExpr::Number),
                    Some(TypeExpr::Number),
                ) => Some(TypeExpr::Number),
                (
                    "..",
                    Some(TypeExpr::Number | TypeExpr::String),
                    Some(TypeExpr::Number | TypeExpr::String),
                ) => Some(TypeExpr::String),
                _ => None,
            }
        }
        SourceFact::Join(facts) => {
            let mut joined = None;
            for fact in facts {
                match inferred_fact(parser, *fact, active)? {
                    Some(ty) => {
                        joined = Some(joined.map_or(ty.clone(), |old| TypeExpr::union(old, ty)))
                    }
                    None => {
                        active.pop();
                        return Ok(None);
                    }
                }
            }
            joined
        }
        SourceFact::Function(id) => {
            let function = &parser.functions[*id];
            if function.generic || function.variadic {
                None
            } else {
                let mut parameters = Vec::with_capacity(function.parameters.len());
                for binding in &function.parameters {
                    let Some(annotation) = parser.bindings[*binding].annotation else {
                        active.pop();
                        return Ok(None);
                    };
                    let Some(ty) = parser.annotations[annotation]
                        .parsed
                        .clone()
                        .filter(immutable_source_type)
                    else {
                        active.pop();
                        return Ok(None);
                    };
                    parameters.push(ty);
                }
                let returns = if let Some(annotation) = function.original_annotation {
                    let annotation = &parser.annotations[annotation];
                    let text = &parser.source[parser.tokens[annotation.start].start
                        ..parser.tokens[annotation.end - 1].end];
                    let pack = if text.starts_with('(') {
                        text.to_owned()
                    } else {
                        format!("({text})")
                    };
                    match parse_type(&format!("() -> {pack}")) {
                        Ok(TypeExpr::Function(function)) => Some(function.returns),
                        _ => None,
                    }
                } else {
                    inferred_returns(parser, function, active)?
                };
                returns
                    .filter(|returns| {
                        returns.tail.is_none() && returns.head.iter().all(immutable_source_type)
                    })
                    .map(|returns| {
                        TypeExpr::Function(Box::new(FunctionType {
                            parameters,
                            returns,
                            ..FunctionType::default()
                        }))
                    })
            }
        }
    };
    active.pop();
    Ok(result)
}

fn inferred_returns(
    parser: &Parser<'_>,
    function: &ReturnInference,
    active: &mut Vec<usize>,
) -> Result<Option<TypePack>> {
    if function.explicit || (!function.terminal && !function.returns.is_empty()) {
        return Ok(None);
    }
    let mut result: Option<Vec<TypeExpr>> = None;
    for values in &function.returns {
        let Some(values) = values else {
            return Ok(None);
        };
        let mut types = Vec::with_capacity(values.len());
        for value in values {
            let generic = match &parser.facts[*value] {
                SourceFact::Binding(id)
                    if !function.effectful
                        && function.parameters.contains(id)
                        && !parser.bindings[*id].assigned =>
                {
                    parser.bindings[*id]
                        .annotation
                        .and_then(|annotation| parser.annotations[annotation].parsed.clone())
                        .filter(|ty| match ty {
                            TypeExpr::Named(name) | TypeExpr::Generic(name) => {
                                function.generic_names.contains(name)
                            }
                            _ => false,
                        })
                }
                _ => None,
            };
            let Some(ty) = generic.or(inferred_fact(parser, *value, active)?) else {
                return Ok(None);
            };
            if ty.luau().contains('.') {
                return Ok(None);
            }
            types.push(ty);
        }
        if let Some(previous) = &mut result {
            if previous.len() != types.len() {
                return Ok(None);
            }
            for (old, ty) in previous.iter_mut().zip(types) {
                *old = TypeExpr::union(old.clone(), ty);
            }
        } else {
            result = Some(types);
        }
    }
    Ok(Some(TypePack {
        head: result.unwrap_or_default(),
        tail: None,
    }))
}

pub(crate) fn process(source: &str, format: InputFormat, config: &Config) -> Result<SourceOutput> {
    if !matches!(format, InputFormat::LuauSource | InputFormat::LuaSource) {
        return Err(Error::new(
            "input_format",
            "source processor requires luau_source or lua_source",
        ));
    }
    if source.len() > config.limits.max_bytes {
        return Err(Error::new("limit", "source exceeds max_bytes"));
    }
    execution::reserve_ast_capacity(source.len().saturating_mul(4))?;
    let parse_start = Instant::now();
    let lexed = lex(source, format, config)?;
    execution::reserve_ast_capacity(lexed.tokens.len().saturating_add(1).saturating_mul(224))?;
    let mut parser = Parser::new(source, &lexed.tokens, format, config);
    parser.block(&[])?;
    if parser.at != lexed.tokens.len() {
        return Err(parser.error("unexpected trailing source tokens"));
    }
    let parse_micros = micros(parse_start);
    let infer_start = Instant::now();
    let mut insertions = BTreeMap::new();
    let mut replacements = BTreeMap::new();
    if !config.naming_options.use_debug_names || !config.name_overrides.is_empty() {
        let reserved: Vec<_> = lexed
            .tokens
            .iter()
            .enumerate()
            .filter(|(index, token)| {
                token.kind == TokenKind::Identifier && parser.token_bindings[*index].is_none()
            })
            .map(|(_, token)| source[token.start..token.end].to_owned())
            .collect();
        let mut names = crate::names::NameAllocator::new(config.naming, reserved);
        for (id, binding) in parser.bindings.iter().enumerate() {
            if config.naming_options.use_debug_names
                && !config.name_overrides.contains_key(&format!("p0:b{id}"))
            {
                names.reserve(&binding.name);
            }
        }
        let mut binding_names = Vec::with_capacity(parser.bindings.len());
        for (id, binding) in parser.bindings.iter().enumerate() {
            let renamed = if let Some(name) = config.name_overrides.get(&format!("p0:b{id}")) {
                if !names.reserve(name) {
                    return Err(Error::new("config", format!("source binding override p0:b{id} collides with a preserved binding or global")));
                }
                name.clone()
            } else if config.naming_options.use_debug_names {
                binding.name.clone()
            } else {
                names.allocate(&binding.name)
            };
            binding_names.push(renamed);
        }
        for key in config.name_overrides.keys() {
            if !parser
                .bindings
                .iter()
                .enumerate()
                .any(|(id, _)| key == &format!("p0:b{id}"))
            {
                return Err(Error::new("config", format!("source override {key} does not identify a parsed source binding; expected p0:b<declaration index>")));
            }
        }
        for (token, binding) in parser.token_bindings.iter().enumerate() {
            if let Some(binding) = binding {
                if binding_names[*binding] != parser.bindings[*binding].name {
                    replacements.insert(token, binding_names[*binding].clone());
                }
            }
        }
    }
    let mut report = TypeReport {
        emittable_variadics: parser.variadic_functions,
        annotated_variadics: parser
            .annotations
            .iter()
            .filter(|annotation| annotation.role == "variadic" && !annotation.type_only)
            .count(),
        total_bindings: parser.bindings.len(),
        emittable_bindings: parser
            .bindings
            .iter()
            .filter(|binding| !binding.function && !binding.type_only)
            .count(),
        ..TypeReport::default()
    };
    let mut useful_bindings = 0;
    let mut added_bindings = 0;
    let mut added_parameters = 0;
    let mut added_useful = 0;
    let mut added_any = 0;
    let mut type_only_binding_annotations = 0;
    let mut binding_types = BTreeMap::new();
    for (id, binding) in parser.bindings.iter().enumerate() {
        let contract = config
            .typing
            .binding_types
            .get(&format!("p0:b{id}"))
            .map(|ty| parse_type(ty))
            .transpose()?;
        if binding.function {
            if contract.is_some() {
                return Err(Error::new("source_unsupported", "source binding contracts for local function declarations require explicit source signature annotations"));
            }
            continue;
        }
        if let Some(annotation) = binding.annotation {
            let annotation = &parser.annotations[annotation];
            if contract
                .as_ref()
                .is_some_and(|contract| annotation.parsed.as_ref() != Some(contract))
            {
                return Err(Error::new(
                    "config",
                    format!(
                        "source contract p0:b{id} conflicts with an existing source annotation"
                    ),
                ));
            }
            if binding.type_only {
                type_only_binding_annotations += 1;
            } else if binding.parameter {
                report.annotated_parameters += 1;
            } else {
                report.annotated_bindings += 1;
            }
            if annotation.parsed.as_ref().is_some_and(TypeExpr::useful) {
                useful_bindings += 1;
            }
            if let Some(ty) = &annotation.parsed {
                binding_types.insert(id, (ty.clone(), crate::types::TypeOrigin::SourceAnnotation));
            }
        } else if config.typing.mode != TypingMode::Off && !binding.type_only {
            let inferred = match binding.fact {
                Some(fact) if !binding.assigned => inferred_fact(&parser, fact, &mut Vec::new())?
                    .filter(|ty| !ty.luau().contains('.')),
                _ => None,
            };
            let supported = contract
                .map(|ty| (ty, crate::types::TypeOrigin::ExternalContract))
                .or_else(|| {
                    inferred
                        .or_else(|| {
                            (!binding.assigned)
                                .then_some(binding.inferred)
                                .flatten()
                                .map(LiteralType::ty)
                        })
                        .map(|ty| (ty, crate::types::TypeOrigin::Inference))
                });
            if let Some((ty, origin)) = supported {
                insertions.insert(binding.name_token, format!(": {}", ty.luau()));
                if binding.parameter {
                    report.annotated_parameters += 1;
                    added_parameters += 1;
                } else {
                    report.annotated_bindings += 1;
                    added_bindings += 1;
                }
                if ty.useful() {
                    useful_bindings += 1;
                    added_useful += 1;
                }
                let any = ty.metrics().explicit_any;
                report.explicit_any += any;
                report.emitted_explicit_any += any;
                added_any += any;
                binding_types.insert(id, (ty, origin));
            }
        } else if contract.is_some() {
            report
                .unapplied_external_contracts
                .push(format!("p0:b{id}"));
        }
    }
    for key in config.typing.binding_types.keys() {
        if !parser
            .bindings
            .iter()
            .enumerate()
            .any(|(id, _)| key == &format!("p0:b{id}"))
        {
            return Err(Error::new(
                "config",
                format!("source type contract {key} does not identify a parsed source binding"),
            ));
        }
    }
    report.unknown_bindings = report
        .emittable_bindings
        .saturating_sub(report.annotated_bindings + report.annotated_parameters);
    report.useful_annotations = useful_bindings;
    report.emitted_useful_annotations = useful_bindings;
    report.emitted_annotations =
        report.annotated_bindings + report.annotated_parameters + type_only_binding_annotations;
    for annotation in &parser.annotations {
        let any = annotation.explicit_any;
        report.explicit_any += any;
        report.emitted_explicit_any += any;
        if annotation.role == "return" && !annotation.type_only {
            report.annotated_returns += 1;
        }
        if !matches!(annotation.role, "local" | "parameter" | "assertion") {
            report.emitted_annotations += 1;
            if annotation.parsed.as_ref().is_some_and(TypeExpr::useful) {
                report.emitted_useful_annotations += 1;
                report.useful_annotations += 1;
            }
        }
    }
    let mut added_returns = 0;
    let mut functions = Vec::with_capacity(parser.functions.len());
    for (id, function) in parser.functions.iter().enumerate() {
        let returns = if config.typing.mode == TypingMode::Off || function.type_only {
            None
        } else {
            inferred_returns(&parser, function, &mut Vec::new())?
        };
        let original_return_annotation = function.original_annotation.map(|id| {
            let annotation = &parser.annotations[id];
            source[lexed.tokens[annotation.start].start..lexed.tokens[annotation.end - 1].end]
                .to_owned()
        });
        if let Some(returns) = &returns {
            let annotation = if returns.head.len() == 1 {
                returns.head[0].luau()
            } else {
                returns.luau()
            };
            insertions.insert(function.insertion, format!(": {annotation}"));
            report.annotated_returns += 1;
            report.emitted_annotations += 1;
            report.emitted_useful_annotations += 1;
            report.useful_annotations += 1;
            added_returns += 1;
        }
        let origin = if returns.is_some() {
            Some(crate::types::TypeOrigin::Inference)
        } else if original_return_annotation.is_some() {
            Some(crate::types::TypeOrigin::SourceAnnotation)
        } else {
            None
        };
        functions.push(SourceFunction {
            id,
            signature_end: lexed.tokens[function.insertion].end,
            type_only: function.type_only,
            original_return_annotation,
            returns,
            origin,
        });
    }
    report.limitations.push("Source text is parsed and formatted directly; runtime token order, parentheses, and original annotations are retained. Bounded inference uses immutable scalar dependencies, existing type contracts and closed equal-arity returns. Unknown calls, varying return arities, fallthrough return mixtures and mutable tables remain unannotated; explicit binding contracts are reported separately.".into());
    if format == InputFormat::LuaSource {
        report.limitations.push("Lua 5.1 compatible syntax requires a compatible standard-library/environment contract; Lua bytecode, Lua 5.2+ syntax, environment introspection and runtime-library conversion are unsupported.".into());
    }
    let infer_micros = micros(infer_start);
    report.emitted_runtime_annotations = report.annotated_bindings
        + report.annotated_parameters
        + report.annotated_returns
        + report.annotated_variadics;
    let mut baseline_type_report = report.clone();
    baseline_type_report.unapplied_external_contracts.extend(
        binding_types
            .iter()
            .filter(|(_, (_, origin))| matches!(origin, crate::types::TypeOrigin::ExternalContract))
            .map(|(id, _)| format!("p0:b{id}")),
    );
    baseline_type_report.annotated_bindings -= added_bindings;
    baseline_type_report.annotated_parameters -= added_parameters;
    baseline_type_report.annotated_returns -= added_returns;
    baseline_type_report.useful_annotations -= added_useful + added_returns;
    baseline_type_report.emitted_annotations -= added_bindings + added_parameters + added_returns;
    baseline_type_report.emitted_runtime_annotations -=
        added_bindings + added_parameters + added_returns;
    baseline_type_report.emitted_useful_annotations -= added_useful + added_returns;
    baseline_type_report.explicit_any -= added_any;
    baseline_type_report.emitted_explicit_any -= added_any;
    baseline_type_report.unknown_bindings += added_bindings + added_parameters;
    let bindings = parser
        .bindings
        .iter()
        .enumerate()
        .map(|(id, binding)| {
            let recovered = binding_types.remove(&id);
            let (ty, origin) = recovered.map_or_else(
                || {
                    (
                        None,
                        binding
                            .annotation
                            .map(|_| crate::types::TypeOrigin::SourceAnnotation),
                    )
                },
                |(ty, origin)| (Some(ty), Some(origin)),
            );
            SourceBinding {
                id: format!("p0:b{id}"),
                name: replacements
                    .get(&binding.name_token)
                    .unwrap_or(&binding.name)
                    .clone(),
                original_name: binding.name.clone(),
                declaration_start: lexed.tokens[binding.name_token].start,
                declaration_end: lexed.tokens[binding.name_token].end,
                parameter: binding.parameter,
                function: binding.function,
                assigned: binding.assigned,
                captured: binding.captured,
                type_only: binding.type_only,
                annotation_source: binding.annotation.map(|annotation| {
                    let annotation = &parser.annotations[annotation];
                    source
                        [lexed.tokens[annotation.start].start..lexed.tokens[annotation.end - 1].end]
                        .to_owned()
                }),
                ty,
                origin,
            }
        })
        .collect();
    let format_start = Instant::now();
    let output = render(
        source,
        &lexed,
        &parser.lines,
        &parser.type_spacing,
        &insertions,
        &replacements,
        config,
    )?;
    let format_micros = micros(format_start);
    Ok(SourceOutput {
        baseline_source: (source != output).then(|| source.to_owned()),
        baseline_type_report,
        source: output,
        type_report: report,
        parse_micros,
        infer_micros,
        format_micros,
        statements: parser.statements,
        bindings,
        functions,
    })
}

struct SourcePrinter {
    output: String,
    reservation: execution::OutputReservation,
    limit: usize,
}
impl SourcePrinter {
    fn text(&mut self, text: &str) -> Result<()> {
        let needed = self
            .output
            .len()
            .checked_add(text.len())
            .filter(|needed| *needed <= self.limit)
            .ok_or_else(|| Error::new("limit", "formatted source exceeds max_output_bytes"))?;
        if needed > self.output.capacity() {
            let capacity = needed
                .max(self.output.capacity().saturating_mul(2))
                .max(64)
                .min(self.limit);
            self.reservation.reserve_capacity(capacity)?;
            self.output
                .try_reserve_exact(capacity.saturating_sub(self.output.len()))
                .map_err(|_| Error::new("memory", "unable to grow source output"))?;
            self.reservation.reserve_capacity(self.output.capacity())?;
        }
        self.output.push_str(text);
        Ok(())
    }
}

fn functional_directive(comment: &str) -> bool {
    matches!(
        comment.split_whitespace().next(),
        Some("--!strict" | "--!nonstrict" | "--!nocheck" | "--!optimize" | "--!native")
    )
}

fn retained_comment(comment: &str) -> bool {
    functional_directive(comment)
        || comment.contains("SPDX-License-Identifier:")
        || comment
            .as_bytes()
            .windows(9)
            .any(|part| part.eq_ignore_ascii_case(b"copyright"))
}

fn render(
    source: &str,
    lexed: &Lexed,
    lines: &[Option<usize>],
    type_spacing: &TypeSpacing,
    insertions: &BTreeMap<usize, String>,
    replacements: &BTreeMap<usize, String>,
    config: &Config,
) -> Result<String> {
    execution::reserve_ast_capacity(
        lexed
            .tokens
            .len()
            .saturating_mul(std::mem::size_of::<Token>()),
    )?;
    let mut emitted_tokens = Vec::with_capacity(lexed.tokens.len());
    let reservation = execution::output_buffer()?;
    let mut printer = SourcePrinter {
        output: String::new(),
        reservation,
        limit: config.limits.max_output_bytes,
    };
    let mut comments = lexed.comments.iter().peekable();
    let mut previous = "";
    let mut line_start = true;
    let strict_present = lexed.comments.iter().any(|comment| {
        source[comment.start..comment.end].trim() == "--!strict"
            && lexed
                .tokens
                .first()
                .is_none_or(|token| comment.end <= token.start)
    });
    if config.typing.emit_strict && config.typing.mode != TypingMode::Off && !strict_present {
        printer.text("--!strict\n\n")?;
    }
    for (index, token) in lexed.tokens.iter().enumerate() {
        execution::charge_work(1)?;
        while comments
            .peek()
            .is_some_and(|comment| comment.start < token.start)
        {
            let comment = comments.next().unwrap();
            let text = &source[comment.start..comment.end];
            if !retained_comment(text) {
                continue;
            }
            if (text.trim() == "--!nonstrict" || text.trim() == "--!nocheck")
                && config.typing.emit_strict
                && config.typing.mode != TypingMode::Off
            {
                continue;
            }
            if !line_start {
                printer.text("\n")?;
            }
            printer.text(text)?;
            printer.text("\n")?;
            line_start = true;
        }
        let current = &source[token.start..token.end];
        if let Some(indent) = lines[index] {
            if !line_start {
                printer.text("\n")?;
            }
            if config.formatting.blank_lines
                && index > 0
                && source[lexed.tokens[index - 1].end..token.start]
                    .bytes()
                    .filter(|byte| *byte == b'\n')
                    .take(2)
                    .count()
                    == 2
                && !printer.output.ends_with("\n\n")
            {
                printer.text("\n")?;
            }
            for _ in 0..indent {
                printer.text(config.indentation())?;
            }
            line_start = true;
        }
        if !line_start
            && !type_spacing.compact_before[index]
            && (needs_space(previous, current)
                || (previous == ":" && type_spacing.after_colon[index]))
        {
            printer.text(" ")?;
        }
        let start = printer.output.len();
        printer.text(replacements.get(&index).map_or(current, String::as_str))?;
        emitted_tokens.push(Token {
            kind: token.kind,
            start,
            end: printer.output.len(),
        });
        if let Some(annotation) = insertions.get(&index) {
            printer.text(annotation)?;
        }
        previous = current;
        line_start = false;
    }
    for comment in comments {
        let text = &source[comment.start..comment.end];
        if !retained_comment(text) {
            continue;
        }
        if !line_start {
            printer.text("\n")?;
        }
        printer.text(text)?;
        printer.text("\n")?;
        line_start = true;
    }
    if !printer.output.ends_with('\n') {
        printer.text("\n")?;
    }
    validate_printed_tokens(&printer.output, &emitted_tokens, config)?;
    Ok(printer.output)
}

fn validate_printed_tokens(source: &str, expected: &[Token], config: &Config) -> Result<()> {
    let actual = lex(source, InputFormat::LuauSource, config)?;
    let mut cursor = 0;
    for expected in expected {
        execution::charge_work(1)?;
        while actual
            .tokens
            .get(cursor)
            .is_some_and(|token| token.start < expected.start)
        {
            cursor += 1;
        }
        if !actual.tokens.get(cursor).is_some_and(|token| {
            token.start == expected.start
                && token.end == expected.end
                && token.kind == expected.kind
        }) {
            return Err(source_error(
                "source_format",
                expected.start,
                "formatting changed a source token boundary",
            ));
        }
        cursor += 1;
    }
    execution::reserve_ast_capacity(actual.tokens.len().saturating_add(1).saturating_mul(224))?;
    let mut parser = Parser::new(source, &actual.tokens, InputFormat::LuauSource, config);
    parser.block(&[])?;
    if parser.at != actual.tokens.len() {
        return Err(source_error(
            "source_format",
            parser.offset(),
            "formatted source has trailing tokens",
        ));
    }
    Ok(())
}

fn needs_space(previous: &str, current: &str) -> bool {
    if previous == "[" && long_delimiter(current.as_bytes(), 0).is_some() {
        return true;
    }
    if matches!(current, "," | ";" | ")" | "]" | "." | ":")
        || matches!(previous, "(" | "[" | "." | ":")
    {
        return false;
    }
    if current == "(" {
        return matches!(previous, "if" | "while" | "not" | "return" | "and" | "or");
    }
    if current == "[" {
        return matches!(previous, "=" | "return" | "," | "{");
    }
    if current == "?" || previous == "..." {
        return false;
    }
    true
}
