use crate::ast::{Expr, Function, Stmt};
use crate::bytecode::{MetadataType, Module};
use crate::structure::RecoveredBindingInfo;
use crate::type_ast::*;
use crate::{Config, Error, Result};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::sync::OnceLock;

#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum TypingMode {
    Off,
    #[default]
    Annotated,
}
#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum AnnotationVerbosity {
    Useful,
    #[default]
    Extensive,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct TypingConfig {
    pub mode: TypingMode,
    pub verbosity: AnnotationVerbosity,
    pub emit_strict: bool,
    pub aliases: bool,
    pub max_iterations: usize,
    pub max_nodes: usize,
    pub binding_types: BTreeMap<String, String>,
    pub globals: BTreeMap<String, String>,
    pub roblox_api: bool,
}
impl Default for TypingConfig {
    fn default() -> Self {
        Self {
            mode: TypingMode::Annotated,
            verbosity: AnnotationVerbosity::Extensive,
            emit_strict: true,
            aliases: true,
            max_iterations: 8,
            max_nodes: 1_000_000,
            binding_types: BTreeMap::new(),
            globals: BTreeMap::new(),
            roblox_api: true,
        }
    }
}
impl TypingConfig {
    pub fn validate(&self) -> Result<()> {
        if !(1..=32).contains(&self.max_iterations) || !(64..=10_000_000).contains(&self.max_nodes)
        {
            return Err(Error::new(
                "config",
                "typing iterations must be1..32 and max_nodes64..10000000",
            ));
        }
        if self.binding_types.len() + self.globals.len() > 4096 {
            return Err(Error::new("config", "too many external type contracts"));
        }
        let mut bytes = 0usize;
        for (k, v) in self.binding_types.iter().chain(&self.globals) {
            bytes = bytes.saturating_add(k.len() + v.len());
            parse_type(v)?;
        }
        if bytes > 1024 * 1024 {
            return Err(Error::new("config", "external type contracts exceed1MiB"));
        }
        Ok(())
    }
}
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct FormattingConfig {
    pub line_width: usize,
    pub multiline_calls: bool,
    pub multiline_tables: bool,
    pub blank_lines: bool,
    pub local_functions: bool,
}
impl Default for FormattingConfig {
    fn default() -> Self {
        Self {
            line_width: 100,
            multiline_calls: true,
            multiline_tables: true,
            blank_lines: true,
            local_functions: true,
        }
    }
}
impl FormattingConfig {
    pub fn validate(&self) -> Result<()> {
        if !(40..=400).contains(&self.line_width) {
            return Err(Error::new("config", "formatting.line_width must be40..400"));
        }
        Ok(())
    }
}
#[derive(Debug, Clone, Copy, Serialize, Deserialize, Default, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum RegionKind {
    #[default]
    Unknown,
    TypeAlias,
    Statement,
    Declaration,
    Function,
    Expression,
}
impl RegionKind {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Unknown => "unknown",
            Self::TypeAlias => "type_alias",
            Self::Statement => "statement",
            Self::Declaration => "declaration",
            Self::Function => "function",
            Self::Expression => "expression",
        }
    }
}
impl PartialEq<&str> for RegionKind {
    fn eq(&self, other: &&str) -> bool {
        self.as_str() == *other
    }
}
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct GeneratedRegion {
    pub node_id: usize,
    pub kind: RegionKind,
    pub proto: Option<usize>,
    pub binding: Option<String>,
    pub first_pc: Option<usize>,
    pub last_pc: Option<usize>,
    pub first_line: usize,
    pub last_line: usize,
    pub first_column: usize,
    pub last_column: usize,
    pub transformations: Vec<String>,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TypeOrigin {
    Metadata,
    Inference,
    ExternalContract,
    SourceAnnotation,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TypeEvidence {
    pub binding: String,
    pub name: String,
    pub proto: usize,
    pub register: usize,
    pub first_pc: usize,
    pub last_pc: usize,
    pub ty: TypeExpr,
    pub origin: TypeOrigin,
    pub detail: String,
    pub metadata_offsets: Vec<usize>,
}
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct TypeReport {
    pub unapplied_external_contracts: Vec<String>,
    pub constructor_transformations: Vec<String>,
    pub total_bindings: usize,
    pub annotated_bindings: usize,
    pub annotated_parameters: usize,
    pub annotated_returns: usize,
    pub useful_annotations: usize,
    pub explicit_any: usize,
    pub inferred_any: usize,
    pub unknown_bindings: usize,
    pub iterations: usize,
    pub work_steps: usize,
    pub evidence: Vec<TypeEvidence>,
    pub limitations: Vec<String>,
    pub api_definition_sha256: Option<String>,
    pub preserved_metadata: Vec<MetadataRecord>,
    pub emittable_bindings: usize,
    pub emittable_variadics: usize,
    pub annotated_variadics: usize,
    pub emitted_annotations: usize,
    pub emitted_runtime_annotations: usize,
    pub emitted_useful_annotations: usize,
    pub emitted_explicit_any: usize,
    pub metadata_any: usize,
    pub metadata_emitted_annotations: usize,
    pub metadata_emitted_runtime_annotations: usize,
    pub metadata_annotated_bindings: usize,
    pub metadata_annotated_parameters: usize,
    pub metadata_annotated_returns: usize,
    pub metadata_annotated_variadics: usize,
    pub metadata_emitted_useful_annotations: usize,
    pub metadata_emitted_explicit_any: usize,
    pub optional_failures: Vec<PresentationFailure>,
    pub function_return_arities: BTreeMap<usize, Vec<usize>>,
    pub original_return_sites: Vec<OriginalReturnSite>,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OriginalReturnSite {
    pub proto: usize,
    pub pc: usize,
    pub fixed_count: Option<usize>,
    pub open_results: bool,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PresentationFailure {
    pub stage: String,
    pub message: String,
    pub proto: Option<usize>,
    pub pc: Option<usize>,
}
impl From<&Error> for PresentationFailure {
    fn from(error: &Error) -> Self {
        Self {
            stage: error.stage.into(),
            message: error.message.clone(),
            proto: error.proto,
            pc: error.pc,
        }
    }
}
pub fn recoverable_presentation_error(error: &Error) -> bool {
    error.stage == "memory"
        || (error.stage == "types" && error.message.contains("budget"))
        || (error.stage == "limit" && error.message.contains("formatted source"))
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MetadataRecord {
    pub proto: usize,
    pub role: String,
    pub index: usize,
    pub tag: u8,
    pub source_offset: usize,
    pub first_pc: Option<usize>,
    pub last_pc: Option<usize>,
    pub userdata_name: Option<String>,
}

#[derive(Default)]
struct Api {
    parents: BTreeMap<String, String>,
    fields: BTreeMap<(String, String), TypeExpr>,
    methods: BTreeMap<(String, String), FunctionType>,
    globals: BTreeMap<String, TypeExpr>,
    classes: BTreeSet<String>,
    services: BTreeSet<String>,
    creatable: BTreeSet<String>,
    hash: String,
}
fn api() -> &'static Api {
    static API: OnceLock<Api> = OnceLock::new();
    API.get_or_init(|| {
        let source = include_str!("../definitions/roblox.d.luau");
        let mut api = Api {
            hash: format!("{:x}", Sha256::digest(source.as_bytes())),
            ..Api::default()
        };
        if let Some(metadata) = source
            .lines()
            .next()
            .and_then(|s| s.strip_prefix("--#METADATA#"))
            .and_then(|s| serde_json::from_str::<serde_json::Value>(s).ok())
        {
            for (key, target) in [
                ("SERVICES", &mut api.services),
                ("CREATABLE_INSTANCES", &mut api.creatable),
            ] {
                if let Some(values) = metadata[key].as_array() {
                    target.extend(values.iter().filter_map(|v| v.as_str().map(str::to_owned)))
                }
            }
        }
        let mut class = None::<String>;
        let mut namespace = None::<String>;
        for line in source.lines().take(100_000) {
            let line = line.trim();
            if let Some(head) = line.strip_prefix("declare extern type ") {
                let mut words = head.split_whitespace();
                if let Some(name) = words.next() {
                    if crate::names::is_identifier(name) {
                        api.classes.insert(name.into());
                        class = Some(name.into());
                        namespace = None;
                        if words.next() == Some("extends") {
                            if let Some(parent) = words.next() {
                                api.parents.insert(name.into(), parent.into());
                            }
                        }
                        if head.ends_with("with end") {
                            class = None
                        }
                    }
                }
                continue;
            }
            if line == "end" {
                class = None;
                continue;
            }
            if let Some(head) = line.strip_prefix("declare ") {
                if let Some((name, ty)) = head.split_once(':') {
                    let name = name.trim();
                    let ty = ty.trim().trim_end_matches(',');
                    if crate::names::is_identifier(name) {
                        if ty == "{" {
                            namespace = Some(name.into());
                            class = None;
                        } else if let Ok(ty) = parse_type(ty) {
                            api.globals.insert(name.into(), ty);
                        }
                    }
                }
                continue;
            }
            if line == "}" {
                namespace = None;
            }
            if let Some(class) = &class {
                if let Some(method) = line.strip_prefix("function ") {
                    if let Some((name, rest)) = method.split_once('(') {
                        if crate::names::is_identifier(name) {
                            if let Some((arguments, returns)) = rest.rsplit_once("):") {
                                let args = arguments
                                    .strip_prefix("self,")
                                    .or_else(|| arguments.strip_prefix("self, "))
                                    .unwrap_or(if arguments == "self" { "" } else { arguments });
                                let contract = format!("({args}) -> {}", returns.trim());
                                if let Ok(TypeExpr::Function(signature)) = parse_type(&contract) {
                                    api.methods.insert((class.clone(), name.into()), *signature);
                                }
                            }
                        }
                    }
                } else if let Some((name, ty)) = line.split_once(':') {
                    let name = name.trim();
                    if crate::names::is_identifier(name) {
                        if let Ok(ty) = parse_type(ty.trim().trim_end_matches(',')) {
                            api.fields.insert((class.clone(), name.into()), ty);
                        }
                    }
                }
            } else if let Some(namespace) = &namespace {
                if let Some((name, ty)) = line.split_once(':') {
                    let name = name.trim();
                    if crate::names::is_identifier(name) {
                        if let Ok(ty) = parse_type(ty.trim().trim_end_matches(',')) {
                            api.globals.insert(format!("{namespace}.{name}"), ty);
                        }
                    }
                }
            }
        }
        api
    })
}
impl Api {
    fn field(&self, class: &str, name: &str) -> Option<TypeExpr> {
        let mut class = class;
        for _ in 0..64 {
            if let Some(t) = self.fields.get(&(class.into(), name.into())) {
                return Some(t.clone());
            }
            class = self.parents.get(class)?.as_str();
        }
        None
    }
    fn method(&self, class: &str, name: &str) -> Option<FunctionType> {
        let mut class = class;
        for _ in 0..64 {
            if let Some(t) = self.methods.get(&(class.into(), name.into())) {
                return Some(t.clone());
            }
            class = self.parents.get(class)?.as_str();
        }
        None
    }
}

fn metadata_type(info: &MetadataType, module: &Module) -> TypeExpr {
    let base = info.tag & 127;
    let ty = match base {
        0 => TypeExpr::Nil,
        1 => TypeExpr::Boolean,
        2 => TypeExpr::Number,
        3 => TypeExpr::String,
        6 => TypeExpr::Thread,
        9 => TypeExpr::Buffer,
        64..=95 => module
            .userdata_types
            .get(&(base - 64 + 1))
            .and_then(|v| *v)
            .and_then(|id| module.strings.get(id))
            .filter(|b| b.len() <= 128)
            .and_then(|b| std::str::from_utf8(b).ok())
            .filter(|n| crate::names::is_identifier(n))
            .map(|s| TypeExpr::Named(s.into()))
            .unwrap_or(TypeExpr::Unknown),
        _ => TypeExpr::Unknown,
    };
    if info.tag & 128 != 0 && ty != TypeExpr::Unknown {
        TypeExpr::Optional(Box::new(ty))
    } else {
        ty
    }
}
fn metadata_records(module: &Module) -> Vec<MetadataRecord> {
    let mut records = Vec::new();
    for (pid, p) in module.protos.iter().enumerate() {
        for (role, items) in [
            ("parameter", &p.type_metadata.parameters),
            ("upvalue", &p.type_metadata.upvalues),
        ] {
            for (index, t) in items.iter().enumerate() {
                let name = match metadata_type(t, module) {
                    TypeExpr::Named(n) => Some(n),
                    _ => None,
                };
                records.push(MetadataRecord {
                    proto: pid,
                    role: role.into(),
                    index,
                    tag: t.tag,
                    source_offset: t.source_offset,
                    first_pc: None,
                    last_pc: None,
                    userdata_name: name,
                });
            }
        }
        for (index, t) in p.type_metadata.locals.iter().enumerate() {
            let name = match metadata_type(&t.type_info, module) {
                TypeExpr::Named(n) => Some(n),
                _ => None,
            };
            records.push(MetadataRecord {
                proto: pid,
                role: "local".into(),
                index,
                tag: t.type_info.tag,
                source_offset: t.type_info.source_offset,
                first_pc: Some(t.start),
                last_pc: Some(t.end),
                userdata_name: name,
            });
        }
    }
    records
}

#[derive(Clone, Debug, PartialEq, Eq)]
struct Value {
    ty: TypeExpr,
    table: Option<usize>,
    returns: Option<TypePack>,
    literal_string: Option<String>,
    reachable_tables: BTreeSet<usize>,
}
impl Value {
    fn ty(ty: TypeExpr) -> Self {
        Self {
            ty,
            table: None,
            returns: None,
            literal_string: None,
            reachable_tables: BTreeSet::new(),
        }
    }
    fn unknown() -> Self {
        Self::ty(TypeExpr::Unknown)
    }
}
#[derive(Clone, Default)]
struct TableState {
    last_type_change: usize,
    fields: BTreeMap<String, TypeExpr>,
    history: BTreeMap<String, TypeExpr>,
    references: BTreeMap<String, usize>,
    index_references: BTreeMap<i64, usize>,
    reachable_tables: BTreeSet<usize>,
    array: Option<TypeExpr>,
    dictionary: Option<(TypeExpr, TypeExpr)>,
    escaped: bool,
    initial_fields: BTreeSet<String>,
}
struct Engine<'a> {
    config: &'a Config,
    seeds: &'a BTreeMap<String, TypeExpr>,
    known: &'a BTreeMap<String, TypeExpr>,
    conservative_captures: bool,
    values: BTreeMap<String, Value>,
    observed: BTreeMap<String, Value>,
    all: BTreeMap<String, TypeExpr>,
    tables: BTreeMap<usize, TableState>,
    table_parents: BTreeMap<usize, BTreeSet<usize>>,
    table_revision: usize,
    next_table: usize,
    next_function: usize,
    functions: BTreeMap<usize, FunctionAnnotation>,
    function_captures: BTreeMap<usize, BTreeSet<usize>>,
    last_call_aliases: BTreeSet<usize>,
    opaque_return_anchor: Option<usize>,
    opaque_anchors: BTreeSet<usize>,
    active_opaque_anchors: BTreeSet<usize>,
    return_arities: BTreeMap<usize, Vec<usize>>,
    return_stack: Vec<Vec<Option<TypePack>>>,
    varargs: Vec<Option<PackTail>>,
    work: usize,
}
impl Engine<'_> {
    fn returned_value(&mut self, value: Value) -> Result<Value> {
        let value = self.materialize_value(value)?;
        if !may_carry_table_alias(&value.ty) && value.table.is_none() {
            return Ok(value);
        }
        let mut roots: Vec<_> = Self::value_tables(&value).collect();
        if roots.is_empty() {
            return Ok(value);
        }
        let anchor = if let Some(anchor) = self
            .opaque_return_anchor
            .filter(|id| self.tables.get(id).is_some_and(|table| !table.escaped))
        {
            anchor
        } else {
            crate::execution::reserve_ast_capacity(512)?;
            let anchor = self.next_table;
            self.next_table += 1;
            self.tables.insert(anchor, TableState::default());
            self.opaque_return_anchor = Some(anchor);
            self.opaque_anchors.insert(anchor);
            self.active_opaque_anchors.insert(anchor);
            anchor
        };
        let mut visited = BTreeSet::new();
        let mut cursor = 0;
        while cursor < roots.len() {
            let id = roots[cursor];
            cursor += 1;
            self.tick()?;
            if id == anchor || !visited.insert(id) {
                continue;
            }
            if let Some(table) = self.tables.get_mut(&id) {
                roots.extend(
                    table
                        .reachable_tables
                        .iter()
                        .filter(|child| **child != anchor)
                        .copied(),
                );
                table.reachable_tables.insert(anchor);
            }
            self.table_parents.entry(anchor).or_default().insert(id);
        }
        if self.tables.get(&anchor).is_some_and(|t| t.escaped) {
            self.escape_tables(roots)?;
        }
        Ok(value)
    }
    fn invalidate_opaque_write(&mut self, id: usize) -> Result<()> {
        if self.opaque_anchors.contains(&id)
            || self.tables.get(&id).is_some_and(|table| {
                table
                    .reachable_tables
                    .iter()
                    .any(|id| self.opaque_anchors.contains(id))
            })
        {
            self.invalidate_opaque_facts()?;
            self.escape_tables([id])?;
        }
        Ok(())
    }
    fn invalidate_captured_write(&mut self, changed: usize) -> Result<()> {
        if self.function_captures.is_empty() {
            return Ok(());
        }
        let mut pending = vec![changed];
        let mut visited = BTreeSet::new();
        while let Some(id) = pending.pop() {
            self.tick()?;
            if !visited.insert(id) {
                continue;
            }
            if self
                .function_captures
                .values()
                .any(|roots| roots.contains(&id))
            {
                return self.escape_tables([changed]);
            }
            if let Some(parents) = self.table_parents.get(&id) {
                pending.extend(parents.iter().copied());
            }
        }
        Ok(())
    }
    fn invalidate_opaque_facts(&mut self) -> Result<()> {
        let anchors = std::mem::take(&mut self.active_opaque_anchors);
        self.opaque_return_anchor = None;
        self.escape_tables(anchors)
    }
    fn merge_opaque_facts(&mut self, other: BTreeSet<usize>) {
        self.active_opaque_anchors.extend(other);
        self.active_opaque_anchors
            .retain(|id| self.tables.get(id).is_some_and(|table| !table.escaped));
        self.opaque_return_anchor = if self.active_opaque_anchors.len() == 1 {
            self.active_opaque_anchors.first().copied()
        } else {
            None
        };
    }
    fn materialize_value(&mut self, value: Value) -> Result<Value> {
        if value.table.is_some() || !value.reachable_tables.is_empty() {
            return Ok(value);
        }
        if !matches!(
            value.ty,
            TypeExpr::Record(_)
                | TypeExpr::Array(_)
                | TypeExpr::Dictionary(..)
                | TypeExpr::Optional(_)
                | TypeExpr::Union(_)
                | TypeExpr::Intersection(_)
        ) {
            return Ok(value);
        }
        let mut materialized = self.materialize_type(value.ty, 0)?;
        materialized.returns = value.returns;
        materialized.literal_string = value.literal_string;
        Ok(materialized)
    }
    fn materialize_type(&mut self, ty: TypeExpr, depth: usize) -> Result<Value> {
        self.tick()?;
        if depth > 32 {
            return Ok(Value::unknown());
        }
        if matches!(
            ty,
            TypeExpr::Record(_) | TypeExpr::Array(_) | TypeExpr::Dictionary(..)
        ) {
            let key_bytes = match &ty {
                TypeExpr::Record(fields) => fields.keys().map(String::len).sum::<usize>(),
                _ => 0,
            };
            crate::execution::reserve_ast_capacity(
                512usize
                    .saturating_add(ty.metrics().nodes.saturating_mul(192))
                    .saturating_add(key_bytes.saturating_mul(4)),
            )?;
        }
        let mut table = TableState::default();
        match &ty {
            TypeExpr::Record(fields) => {
                for (name, field) in fields {
                    let child = self.materialize_type(field.clone(), depth + 1)?;
                    table.reachable_tables.extend(Self::value_tables(&child));
                    if let Some(id) = child.table {
                        table.references.insert(name.clone(), id);
                    }
                }
                table.initial_fields.extend(fields.keys().cloned());
                table.fields = fields.clone();
                table.history = fields.clone();
            }
            TypeExpr::Array(element) => {
                let child = self.materialize_type((**element).clone(), depth + 1)?;
                table.reachable_tables.extend(Self::value_tables(&child));
                table.array = Some((**element).clone());
            }
            TypeExpr::Dictionary(key, element) => {
                let child = self.materialize_type((**element).clone(), depth + 1)?;
                table.reachable_tables.extend(Self::value_tables(&child));
                table.dictionary = Some(((**key).clone(), (**element).clone()));
            }
            TypeExpr::Optional(inner) => {
                let child = self.materialize_type((**inner).clone(), depth + 1)?;
                let mut value = Value::ty(ty);
                value.reachable_tables.extend(Self::value_tables(&child));
                return Ok(value);
            }
            TypeExpr::Union(types) | TypeExpr::Intersection(types) => {
                let mut reachable = BTreeSet::new();
                for child in types {
                    reachable.extend(Self::value_tables(
                        &self.materialize_type(child.clone(), depth + 1)?,
                    ));
                }
                let mut value = Value::ty(ty);
                value.reachable_tables = reachable;
                return Ok(value);
            }
            _ => return Ok(Value::ty(ty)),
        }
        let id = self.next_table;
        self.next_table += 1;
        for child in &table.reachable_tables {
            self.table_parents.entry(*child).or_default().insert(id);
        }
        self.tables.insert(id, table);
        Ok(Value {
            table: Some(id),
            ..Value::unknown()
        })
    }
    fn escape_tables(&mut self, roots: impl IntoIterator<Item = usize>) -> Result<()> {
        let mut pending: Vec<_> = roots.into_iter().collect();
        let mut visited = BTreeSet::new();
        while let Some(id) = pending.pop() {
            self.tick()?;
            if !visited.insert(id) {
                continue;
            }
            if let Some(table) = self.tables.get_mut(&id) {
                table.escaped = true;
                pending.extend(table.reachable_tables.iter().copied());
            }
            if let Some(parents) = self.table_parents.get(&id) {
                pending.extend(parents.iter().copied());
            }
        }
        Ok(())
    }
    fn propagate_escaped_tables(&mut self) -> Result<()> {
        let roots: Vec<_> = self
            .tables
            .iter()
            .filter_map(|(id, t)| t.escaped.then_some(*id))
            .collect();
        self.escape_tables(roots)
    }
    fn value_tables(value: &Value) -> impl Iterator<Item = usize> + '_ {
        value
            .table
            .into_iter()
            .chain(value.reachable_tables.iter().copied())
    }
    fn tick(&mut self) -> Result<()> {
        crate::execution::charge_work(1)?;
        self.work += 1;
        if self.work & 255 == 0 {
            crate::execution::checkpoint()?
        }
        if self.work
            > self
                .config
                .typing
                .max_nodes
                .min(self.config.limits.max_analysis_steps)
        {
            return Err(Error::new(
                "types",
                "type reconstruction work budget exceeded",
            ));
        }
        Ok(())
    }
    fn joined_value(&self, left: &Value, right: &Value) -> Value {
        let table = left.table.filter(|table| Some(*table) == right.table);
        let mut value = Value::ty(TypeExpr::union(self.resolve(left), self.resolve(right)));
        value.table = table;
        value
            .reachable_tables
            .extend(Self::value_tables(left).chain(Self::value_tables(right)));
        if left.literal_string == right.literal_string {
            value.literal_string = left.literal_string.clone();
        }
        value
    }
    fn loop_body(&mut self, body: &[Stmt], condition: Option<&Expr>) -> Result<()> {
        crate::execution::charge_work(
            self.values.len()
                + self
                    .tables
                    .values()
                    .map(|t| t.fields.len() + 1)
                    .sum::<usize>(),
        )?;
        let before = self.values.clone();
        let tables = self.tables.clone();
        let opaque = self.active_opaque_anchors.clone();
        let revision = self.table_revision;
        let return_start = self.return_stack.last().map_or(0, Vec::len);
        self.body(body)?;
        let after = std::mem::take(&mut self.values);
        let scalar_changes = before
            .iter()
            .filter_map(|(name, value)| {
                after
                    .get(name)
                    .filter(|other| {
                        value.ty != other.ty || value.literal_string != other.literal_string
                    })
                    .map(|_| name.clone())
            })
            .collect();
        self.tables = merge_tables(tables, std::mem::take(&mut self.tables));
        self.merge_opaque_facts(opaque);
        self.propagate_escaped_tables()?;
        self.values = before;
        let mut joined = Vec::new();
        for (name, value) in &self.values {
            if let Some(other) = after.get(name) {
                if *value != *other {
                    joined.push((name.clone(), self.joined_value(value, other)));
                }
            }
        }
        self.values.extend(joined);
        self.loop_dependencies(
            body,
            condition,
            &after,
            revision,
            return_start,
            scalar_changes,
        )?;
        Ok(())
    }
    fn loop_dependencies(
        &mut self,
        body: &[Stmt],
        condition: Option<&Expr>,
        after: &BTreeMap<String, Value>,
        revision: usize,
        return_start: usize,
        mut scalar_changes: BTreeSet<String>,
    ) -> Result<()> {
        let (dependencies, mut calls, returns) = loop_dependencies(body)?;
        if let Some(condition) = condition {
            collect_call_dependencies(condition, &mut calls);
        }
        let mut users = BTreeMap::<String, BTreeSet<String>>::new();
        let mut names = returns.clone();
        for (target, sources) in &dependencies {
            names.insert(target.clone());
            for source in sources {
                users
                    .entry(source.clone())
                    .or_default()
                    .insert(target.clone());
                names.insert(source.clone());
            }
        }
        for call in &calls {
            names.extend(call.iter().cloned());
        }
        let mut aliases = BTreeMap::<String, BTreeSet<usize>>::new();
        let mut pending = std::collections::VecDeque::new();
        for name in names {
            self.tick()?;
            let roots = aliases.entry(name.clone()).or_default();
            for value in self.values.get(&name).into_iter().chain(after.get(&name)) {
                roots.extend(Self::value_tables(value));
            }
            if !roots.is_empty() {
                pending.push_back(name);
            }
        }
        while let Some(name) = pending.pop_front() {
            self.tick()?;
            let roots = aliases.get(&name).cloned().unwrap_or_default();
            if let Some(targets) = users.get(&name) {
                for target in targets {
                    crate::execution::charge_work(roots.len())?;
                    let target_roots = aliases.entry(target.clone()).or_default();
                    let before = target_roots.len();
                    target_roots.extend(roots.iter().copied());
                    if target_roots.len() != before {
                        pending.push_back(target.clone());
                    }
                }
            }
        }
        for call in calls {
            let roots: Vec<_> = call
                .iter()
                .filter_map(|name| aliases.get(name))
                .flat_map(|roots| roots.iter().copied())
                .collect();
            self.escape_tables(roots)?;
        }
        let mut changed: BTreeSet<_> = self
            .tables
            .iter()
            .filter_map(|(id, table)| {
                (table.escaped || table.last_type_change > revision).then_some(*id)
            })
            .collect();
        let mut pending: Vec<_> = changed.iter().copied().collect();
        while let Some(id) = pending.pop() {
            self.tick()?;
            if let Some(parents) = self.table_parents.get(&id) {
                for parent in parents {
                    if changed.insert(*parent) {
                        pending.push(*parent);
                    }
                }
            }
        }
        for (name, roots) in &aliases {
            if roots.iter().any(|id| changed.contains(id)) {
                scalar_changes.insert(name.clone());
            }
        }
        let mut pending: std::collections::VecDeque<_> = scalar_changes.iter().cloned().collect();
        while let Some(name) = pending.pop_front() {
            self.tick()?;
            if let Some(targets) = users.get(&name) {
                for target in targets {
                    self.tick()?;
                    if scalar_changes.insert(target.clone()) {
                        pending.push_back(target.clone());
                    }
                }
            }
        }
        for name in &scalar_changes {
            self.tick()?;
            for value in self
                .values
                .get_mut(name)
                .into_iter()
                .chain(self.observed.get_mut(name))
            {
                value.ty = TypeExpr::Unknown;
                if let Some(table) = value.table.take() {
                    value.reachable_tables.insert(table);
                }
                value.returns = None;
                value.literal_string = None;
            }
            self.all.insert(name.clone(), TypeExpr::Unknown);
        }
        for name in dependencies.keys() {
            self.tick()?;
            if let Some(roots) = aliases
                .get(name)
                .filter(|roots| roots.iter().any(|id| changed.contains(id)))
            {
                if let Some(value) = self.values.get_mut(name) {
                    value.ty = TypeExpr::Unknown;
                    value.table = None;
                    value.reachable_tables.extend(roots.iter().copied());
                    self.observed.insert(name.clone(), value.clone());
                    self.all.insert(name.clone(), TypeExpr::Unknown);
                }
            }
        }
        if !returns.is_disjoint(&scalar_changes)
            || returns
                .iter()
                .filter_map(|name| aliases.get(name))
                .flatten()
                .any(|id| changed.contains(id))
        {
            if let Some(values) = self.return_stack.last_mut() {
                for value in &mut values[return_start..] {
                    *value = None;
                }
            }
        }
        Ok(())
    }
    fn resolve(&self, v: &Value) -> TypeExpr {
        self.resolve_inner(v, &mut BTreeSet::new(), &mut 0, false)
    }
    fn declaration_type(&self, v: &Value) -> TypeExpr {
        self.resolve_inner(v, &mut BTreeSet::new(), &mut 0, true)
    }
    fn resolve_inner(
        &self,
        v: &Value,
        seen: &mut BTreeSet<usize>,
        nodes: &mut usize,
        historical: bool,
    ) -> TypeExpr {
        *nodes += 1;
        if *nodes > 4096 || seen.len() > 32 {
            return TypeExpr::Unknown;
        }
        if let Some(id) = v.table {
            if !seen.insert(id) {
                return TypeExpr::Unknown;
            }
            let Some(table) = self.tables.get(&id) else {
                return TypeExpr::Unknown;
            };
            if table.escaped {
                return TypeExpr::Unknown;
            }
            if historical
                && (table.dictionary.is_some() || table.array.is_some())
                && table.reachable_tables.iter().any(|child| {
                    self.tables
                        .get(child)
                        .is_some_and(|table| table.last_type_change != 0)
                })
            {
                return TypeExpr::Unknown;
            }
            let ty = if let Some((k, v)) = &table.dictionary {
                TypeExpr::Dictionary(Box::new(k.clone()), Box::new(v.clone()))
            } else if let Some(t) = &table.array {
                TypeExpr::Array(Box::new(t.clone()))
            } else {
                let mut fields = if historical {
                    table.history.clone()
                } else {
                    table.fields.clone()
                };
                for (name, id) in &table.references {
                    let ty = self.resolve_inner(
                        &Value {
                            ty: TypeExpr::Unknown,
                            table: Some(*id),
                            returns: None,
                            literal_string: None,
                            reachable_tables: BTreeSet::new(),
                        },
                        seen,
                        nodes,
                        historical,
                    );
                    let ty = if historical {
                        fields
                            .get(name)
                            .cloned()
                            .map_or(ty.clone(), |old| TypeExpr::union(old, ty))
                    } else {
                        ty
                    };
                    fields.insert(name.clone(), ty);
                }
                TypeExpr::Record(fields)
            };
            seen.remove(&id);
            return ty;
        }
        if v.reachable_tables
            .iter()
            .any(|id| self.tables.get(id).is_none_or(|t| t.escaped))
        {
            return TypeExpr::Unknown;
        }
        v.ty.clone()
    }
    fn set(&mut self, name: &str, value: Value) {
        let ty = self.resolve(&value);
        self.all
            .entry(name.into())
            .and_modify(|old| *old = TypeExpr::union(old.clone(), ty.clone()))
            .or_insert(ty);
        self.observed.insert(name.into(), value.clone());
        self.values.insert(name.into(), value);
    }
    fn global_path(expr: &Expr) -> Option<String> {
        match expr {
            Expr::Global(n) => Some(n.clone()),
            Expr::Field(o, n) => Some(format!("{}.{}", Self::global_path(o)?, n)),
            _ => None,
        }
    }
    fn expr(&mut self, e: &Expr) -> Result<Value> {
        self.tick()?;
        let value = match e {
            Expr::Literal(text) => {
                let mut value = Value::ty(literal_type(text));
                value.literal_string = string_literal(e);
                value
            }
            Expr::Name(n) => self
                .values
                .get(n)
                .cloned()
                .or_else(|| {
                    self.seeds
                        .get(n)
                        .or_else(|| self.known.get(n))
                        .cloned()
                        .map(Value::ty)
                })
                .unwrap_or_else(Value::unknown),
            Expr::Global(n) => {
                let value = Value::ty(
                    self.config
                        .typing
                        .globals
                        .get(n)
                        .or_else(|| self.config.validation.project.external_globals.get(n))
                        .or_else(|| self.config.validation.project.instance_types.get(n))
                        .and_then(|s| parse_type(s).ok())
                        .or_else(|| {
                            if self.config.typing.roblox_api {
                                api().globals.get(n).cloned()
                            } else {
                                None
                            }
                        })
                        .unwrap_or(TypeExpr::Unknown),
                );
                self.returned_value(value)?
            }
            Expr::Vararg => Value::ty(match self.varargs.last().and_then(Option::as_ref) {
                Some(PackTail::Variadic(t)) => (**t).clone(),
                _ => TypeExpr::Unknown,
            }),
            Expr::Single(inner) => {
                let mut value = self.expr(inner)?;
                value.returns = None;
                value
            }
            Expr::Unary(op, e) => {
                let ty = self.expr(e)?;
                let ty = self.resolve(&ty);
                Value::ty(match (*op, ty) {
                    ("not", _) => TypeExpr::Boolean,
                    ("-", TypeExpr::Number) => TypeExpr::Number,
                    (
                        "#",
                        TypeExpr::String
                        | TypeExpr::Array(_)
                        | TypeExpr::Dictionary(..)
                        | TypeExpr::Record(_),
                    ) => TypeExpr::Number,
                    _ => TypeExpr::Unknown,
                })
            }
            Expr::Binary(op, a, b) => {
                let a = self.expr(a)?;
                let b = self.expr(b)?;
                if matches!(*op, "and" | "or") {
                    return Ok(self.joined_value(&a, &b));
                }
                let (a, b) = (self.resolve(&a), self.resolve(&b));
                Value::ty(match *op {
                    "==" | "~=" | "<" | "<=" | ">" | ">=" => TypeExpr::Boolean,
                    ".." if matches!(a, TypeExpr::String | TypeExpr::Number)
                        && matches!(b, TypeExpr::String | TypeExpr::Number) =>
                    {
                        TypeExpr::String
                    }
                    "+" | "-" | "*" | "/" | "//" | "%" | "^"
                        if a == TypeExpr::Number && b == TypeExpr::Number =>
                    {
                        TypeExpr::Number
                    }
                    _ => TypeExpr::Unknown,
                })
            }
            Expr::Field(o, n) => {
                if let Some(path) = Self::global_path(e) {
                    if let Some(ty) = self
                        .config
                        .typing
                        .globals
                        .get(&path)
                        .or_else(|| self.config.validation.project.external_globals.get(&path))
                        .or_else(|| self.config.validation.project.instance_types.get(&path))
                        .and_then(|s| parse_type(s).ok())
                        .or_else(|| {
                            if self.config.typing.roblox_api {
                                api().globals.get(&path).cloned()
                            } else {
                                None
                            }
                        })
                    {
                        return self.returned_value(Value::ty(ty));
                    }
                }
                let o = self.expr(o)?;
                if let Some(id) = o.table {
                    if let Some(child) = self
                        .tables
                        .get(&id)
                        .and_then(|table| table.references.get(n))
                    {
                        return Ok(Value {
                            ty: TypeExpr::Unknown,
                            table: Some(*child),
                            returns: None,
                            literal_string: None,
                            reachable_tables: BTreeSet::new(),
                        });
                    }
                }
                let ty = self.resolve(&o);
                let mut value = Value::ty(match ty {
                    TypeExpr::Record(fields) => fields.get(n).cloned().unwrap_or(TypeExpr::Unknown),
                    TypeExpr::Named(class) if self.config.typing.roblox_api => {
                        api().field(&class, n).unwrap_or(TypeExpr::Unknown)
                    }
                    _ => TypeExpr::Unknown,
                });
                if let Some(table) = o.table.and_then(|id| self.tables.get(&id)) {
                    value
                        .reachable_tables
                        .extend(table.reachable_tables.iter().copied());
                }
                value.reachable_tables.extend(o.reachable_tables);
                value
            }
            Expr::Index(o, key) => {
                let o = self.expr(o)?;
                let key_value = self.expr(key)?;
                if let Some(id) = o.table {
                    let table = self.tables.get(&id);
                    let child = key_value
                        .literal_string
                        .as_ref()
                        .and_then(|name| table.and_then(|t| t.references.get(name)))
                        .or_else(|| {
                            integer_literal(key).and_then(|index| {
                                table.and_then(|t| t.index_references.get(&index))
                            })
                        });
                    if let Some(child) = child {
                        return Ok(Value {
                            table: Some(*child),
                            ..Value::unknown()
                        });
                    }
                }
                let ty = self.resolve(&o);
                let key_type = self.resolve(&key_value);
                let mut value = Value::ty(match ty {
                    TypeExpr::Record(fields) => key_value
                        .literal_string
                        .or_else(|| string_literal(key))
                        .and_then(|s| fields.get(&s).cloned())
                        .unwrap_or(TypeExpr::Unknown),
                    TypeExpr::Array(t) if key_type == TypeExpr::Number => TypeExpr::Optional(t),
                    TypeExpr::Dictionary(_, t) => TypeExpr::Optional(t),
                    _ => TypeExpr::Unknown,
                });
                if let Some(table) = o.table.and_then(|id| self.tables.get(&id)) {
                    value
                        .reachable_tables
                        .extend(table.reachable_tables.iter().copied());
                }
                value.reachable_tables.extend(o.reachable_tables);
                value
            }
            Expr::Call(f, args) => {
                let returns = self.call(f, None, args)?;
                let mut value = Value {
                    ty: returns
                        .as_ref()
                        .map(scalar_result)
                        .unwrap_or(TypeExpr::Unknown),
                    table: None,
                    returns,
                    literal_string: None,
                    reachable_tables: BTreeSet::new(),
                };
                if may_carry_table_alias(&value.ty) {
                    value.reachable_tables = self.last_call_aliases.clone();
                }
                self.returned_value(value)?
            }
            Expr::MethodCall(o, n, args) => {
                let returns = self.call(o, Some(n), args)?;
                let mut value = Value {
                    ty: returns
                        .as_ref()
                        .map(scalar_result)
                        .unwrap_or(TypeExpr::Unknown),
                    table: None,
                    returns,
                    literal_string: None,
                    reachable_tables: BTreeSet::new(),
                };
                if may_carry_table_alias(&value.ty) {
                    value.reachable_tables = self.last_call_aliases.clone();
                }
                self.returned_value(value)?
            }
            Expr::Table(fields) => {
                let keys = fields
                    .iter()
                    .filter_map(|(key, _)| key.as_ref())
                    .map(|key| match key {
                        Expr::Literal(text) => text.len(),
                        _ => 0,
                    })
                    .sum::<usize>();
                crate::execution::reserve_ast_capacity(
                    512usize
                        .saturating_add(fields.len().saturating_mul(640))
                        .saturating_add(keys.saturating_mul(4)),
                )?;
                let id = self.next_table;
                self.next_table += 1;
                let mut table = TableState::default();
                let mut array_index = 0i64;
                for (key, value) in fields {
                    let v = self.expr(value)?;
                    table.reachable_tables.extend(Self::value_tables(&v));
                    let ty = self.resolve(&v);
                    match key {
                        None => {
                            array_index += 1;
                            if let Some(id) = v.table {
                                table.index_references.insert(array_index, id);
                            }
                            table.array = Some(
                                table
                                    .array
                                    .take()
                                    .map_or(ty.clone(), |old| TypeExpr::union(old, ty)),
                            )
                        }
                        Some(key) => {
                            if let Some(name) = string_literal(key) {
                                table.initial_fields.insert(name.clone());
                                if let Some(id) = v.table {
                                    table.references.insert(name.clone(), id);
                                }
                                table.history.insert(name.clone(), ty.clone());
                                table.fields.insert(name, ty);
                            } else {
                                let k = self.expr(key)?;
                                table.reachable_tables.extend(Self::value_tables(&k));
                                if let Some(index) = integer_literal(key) {
                                    if let Some(id) = v.table {
                                        table.index_references.insert(index, id);
                                    }
                                }
                                let k = self.resolve(&k);
                                let (k, v) = table.dictionary.take().map_or(
                                    (k.clone(), ty.clone()),
                                    |(oldk, oldv)| {
                                        (TypeExpr::union(oldk, k), TypeExpr::union(oldv, ty))
                                    },
                                );
                                table.dictionary = Some((k, v));
                            }
                        }
                    }
                }
                for child in &table.reachable_tables {
                    self.table_parents.entry(*child).or_default().insert(id);
                }
                self.tables.insert(id, table);
                Value {
                    ty: TypeExpr::Unknown,
                    table: Some(id),
                    returns: None,
                    literal_string: None,
                    reachable_tables: BTreeSet::new(),
                }
            }
            Expr::Function(function) => self.function(function)?,
            Expr::IfElse(c, a, b) => {
                self.expr(c)?;
                let a = self.expr(a)?;
                let b = self.expr(b)?;
                self.joined_value(&a, &b)
            }
        };
        self.materialize_value(value)
    }
    fn call(
        &mut self,
        f: &Expr,
        method: Option<&String>,
        args: &[Expr],
    ) -> Result<Option<TypePack>> {
        let receiver = self.expr(f)?;
        let mut arguments = Vec::new();
        let mut tail_values = Vec::new();
        let mut argument_tail = None;
        for (index, arg) in args.iter().enumerate() {
            let mut value = self.expr(arg)?;
            if index + 1 == args.len() {
                if let Some(expanded) = value.returns.take() {
                    for ty in expanded.head {
                        let mut expanded_value = Value::ty(ty);
                        if may_carry_table_alias(&expanded_value.ty) {
                            expanded_value
                                .reachable_tables
                                .extend(Self::value_tables(&value));
                        }
                        arguments.push(self.returned_value(expanded_value)?);
                    }
                    argument_tail = expanded.tail;
                    if let Some(tail) = &argument_tail {
                        let ty = match tail {
                            PackTail::Variadic(ty) => (**ty).clone(),
                            PackTail::Generic(_) => TypeExpr::Unknown,
                        };
                        let mut tail_value = Value::ty(ty);
                        tail_value
                            .reachable_tables
                            .extend(Self::value_tables(&value));
                        tail_values.push(self.returned_value(tail_value)?);
                    }
                    continue;
                }
                if matches!(arg, Expr::Vararg) {
                    argument_tail = self.varargs.last().cloned().flatten();
                    if argument_tail.is_some() {
                        tail_values.push(self.returned_value(value)?);
                        continue;
                    }
                }
            }
            value.returns = None;
            arguments.push(value);
        }
        let ty = self.resolve(&receiver);
        let mut argument_types: Vec<_> =
            arguments.iter().map(|value| self.resolve(value)).collect();
        if method.is_some() || !effect_free_direct_function(f) {
            self.invalidate_opaque_facts()?;
        }
        if self.config.typing.roblox_api {
            if method.is_none() && Self::global_path(f).as_deref() == Some("Instance.new") {
                if let Some(class) = args.first().and_then(string_literal) {
                    if api().creatable.contains(&class) {
                        self.last_call_aliases.clear();
                        return Ok(Some(TypePack {
                            head: vec![TypeExpr::Named(class)],
                            tail: None,
                        }));
                    }
                }
            }
            if method.map(String::as_str) == Some("GetService")
                && matches!(ty,TypeExpr::Named(ref n)if n=="DataModel"||n=="ServiceProvider")
            {
                if let Some(class) = args.first().and_then(string_literal) {
                    if api().services.contains(&class) {
                        self.last_call_aliases.clear();
                        return Ok(Some(TypePack {
                            head: vec![TypeExpr::Named(class)],
                            tail: None,
                        }));
                    }
                }
            }
        }
        let mut explicit_receiver = false;
        let signature = if let Some(method) = method {
            if let TypeExpr::Named(class) = &ty {
                if self.config.typing.roblox_api {
                    api().method(class, method)
                } else {
                    None
                }
            } else if let TypeExpr::Record(fields) = &ty {
                match fields.get(method) {
                    Some(TypeExpr::Function(f)) => {
                        explicit_receiver = true;
                        Some((**f).clone())
                    }
                    _ => None,
                }
            } else {
                None
            }
        } else if let TypeExpr::Function(f) = &ty {
            Some((**f).clone())
        } else {
            None
        };
        if explicit_receiver {
            arguments.insert(0, receiver.clone());
            argument_types.insert(0, ty);
        }
        let mut aliases = BTreeSet::new();
        aliases.extend(receiver.reachable_tables.iter().copied());
        if method.is_some() {
            aliases.extend(receiver.table);
        }
        for value in &arguments {
            aliases.extend(Self::value_tables(value));
        }
        for value in &tail_values {
            aliases.extend(Self::value_tables(value));
        }
        for value in arguments.iter().chain(&tail_values) {
            self.escape_tables(Self::value_tables(value))?;
        }
        let uncertain_capture =
            !effect_free_direct_function(f) && Self::value_tables(&receiver).next().is_some();
        if signature.is_none() || method.is_some() || uncertain_capture {
            self.escape_tables(Self::value_tables(&receiver))?;
        }
        if let Some(f) = signature.filter(|_| method.is_some() || !uncertain_capture) {
            let mut type_bindings = BTreeMap::<String, TypeExpr>::new();
            for (parameter, ty) in f.parameters.iter().zip(&argument_types) {
                let generic = match parameter {
                    TypeExpr::Generic(n) | TypeExpr::Named(n) if f.generics.contains(n) => Some(n),
                    _ => None,
                };
                if let Some(name) = generic {
                    type_bindings
                        .entry(name.clone())
                        .and_modify(|old| *old = TypeExpr::union(old.clone(), ty.clone()))
                        .or_insert_with(|| ty.clone());
                }
            }
            let mut packs = BTreeMap::new();
            if let Some(PackTail::Generic(name)) = &f.variadic {
                let pack = TypePack {
                    head: argument_types
                        .into_iter()
                        .skip(f.parameters.len())
                        .collect(),
                    tail: argument_tail,
                };
                packs.insert(name.clone(), pack);
            }
            self.last_call_aliases = aliases;
            return Ok(instantiate_pack(
                &f.returns,
                &type_bindings,
                &packs,
                &f.generics,
                &f.generic_packs,
            ));
        }
        self.last_call_aliases = aliases;
        Ok(None)
    }
    fn pack(&mut self, values: &[Expr]) -> Result<Option<TypePack>> {
        let mut pack = TypePack::default();
        for (index, e) in values.iter().enumerate() {
            if index + 1 == values.len() {
                match e {
                    Expr::Vararg => {
                        pack.tail = self.varargs.last().cloned().flatten();
                        if pack.tail.is_none() {
                            return Ok(None);
                        }
                        break;
                    }
                    Expr::Call(f, args) => {
                        if let Some(tail) = self.call(f, None, args)? {
                            pack.head.extend(tail.head);
                            pack.tail = tail.tail;
                            break;
                        } else {
                            return Ok(None);
                        }
                    }
                    Expr::MethodCall(o, n, args) => {
                        if let Some(tail) = self.call(o, Some(n), args)? {
                            pack.head.extend(tail.head);
                            pack.tail = tail.tail;
                            break;
                        } else {
                            return Ok(None);
                        }
                    }
                    _ => {}
                }
            }
            let v = self.expr(e)?;
            pack.head.push(self.resolve(&v));
        }
        Ok(Some(pack))
    }
    fn function(&mut self, f: &Function) -> Result<Value> {
        let id = self.next_function;
        self.next_function += 1;
        let saved = self.values.clone();
        let mut captures = BTreeSet::new();
        crate::ast::visit_body(&f.body, &mut |expr| {
            if let Expr::Name(name) = expr {
                if !f.parameters.contains(name) && saved.contains_key(name) {
                    captures.insert(name.clone());
                }
            }
        });
        for name in captures {
            self.tick()?;
            let value = self.values.get_mut(&name).unwrap();
            if value.table.is_none() && value.reachable_tables.is_empty() {
                let ty = if self.conservative_captures {
                    TypeExpr::Unknown
                } else {
                    self.known.get(&name).cloned().unwrap_or(TypeExpr::Unknown)
                };
                if ty != value.ty {
                    value.ty = ty;
                    value.literal_string = None;
                    value.returns = None;
                }
            }
        }
        let table_boundary = self.next_table;
        let before_revision = self.table_revision;
        let mut annotation = FunctionAnnotation::default();
        let generic_pack = f.vararg && only_return_varargs(&f.body);
        if generic_pack {
            annotation.generic_packs.push("T".into());
            annotation.variadic = Some(PackTail::Generic("T".into()))
        }
        let safe_generics = generic_parameters(f);
        for (index, name) in f.parameters.iter().enumerate() {
            let ty = self.seeds.get(name).cloned().unwrap_or_else(|| {
                if safe_generics.contains(name) {
                    TypeExpr::Generic(format!("T{}", index + 1))
                } else {
                    TypeExpr::Unknown
                }
            });
            if let TypeExpr::Generic(generic) = &ty {
                annotation.generics.push(generic.clone())
            }
            annotation.parameters.push(
                if ty.useful() || ty == TypeExpr::Any || self.seeds.contains_key(name) {
                    Some(ty.clone())
                } else {
                    None
                },
            );
            let value = self.returned_value(Value::ty(ty))?;
            self.set(name, value);
        }
        self.return_stack.push(Vec::new());
        self.varargs.push(annotation.variadic.clone());
        self.body(&f.body)?;
        let mut returns = self.return_stack.pop().unwrap();
        self.varargs.pop();
        if !terminal(&f.body) {
            returns.push(Some(TypePack::default()))
        }
        let mut arities: Vec<_> = returns
            .iter()
            .filter_map(|p| {
                p.as_ref()
                    .filter(|p| p.tail.is_none())
                    .map(|p| p.head.len())
            })
            .collect();
        arities.sort_unstable();
        arities.dedup();
        self.return_arities.insert(id, arities);
        let returns = join_packs(returns);
        annotation.returns = returns.filter(|p| {
            p.head.iter().all(|t| t.useful() || *t == TypeExpr::Any)
                && p.tail.as_ref().is_none_or(|tail| match tail {
                    PackTail::Variadic(t) => t.useful(),
                    PackTail::Generic(_) => true,
                })
        });
        let ty = if let Some(returns) = &annotation.returns {
            TypeExpr::Function(Box::new(FunctionType {
                generics: annotation.generics.clone(),
                generic_packs: annotation.generic_packs.clone(),
                parameters: annotation
                    .parameters
                    .iter()
                    .map(|p| p.clone().unwrap_or(TypeExpr::Unknown))
                    .collect(),
                variadic: annotation.variadic.clone(),
                returns: returns.clone(),
            }))
        } else {
            TypeExpr::Unknown
        };
        self.functions.insert(id, annotation);
        let changed_tables: Vec<_> = self
            .tables
            .range(..table_boundary)
            .filter_map(|(id, table)| (table.last_type_change > before_revision).then_some(*id))
            .collect();
        self.escape_tables(changed_tables)?;
        let changed = std::mem::replace(&mut self.values, saved);
        let mut joined = Vec::new();
        for (name, value) in &self.values {
            if let Some(after) = changed.get(name) {
                if value != after {
                    joined.push((name.clone(), self.joined_value(value, after)));
                }
            }
        }
        self.values.extend(joined);
        let mut value = Value::ty(ty);
        crate::ast::visit_body(&f.body, &mut |expr| {
            if let Expr::Name(name) = expr {
                if !f.parameters.contains(name) {
                    if let Some(captured) = self.values.get(name) {
                        value.reachable_tables.extend(Self::value_tables(captured));
                    }
                }
            }
        });
        if !value.reachable_tables.is_empty() {
            self.function_captures
                .insert(id, value.reachable_tables.clone());
        }
        Ok(value)
    }
    fn assignment_values(&mut self, values: &[Expr], count: usize) -> Result<Vec<Value>> {
        let mut result = Vec::new();
        for (index, e) in values.iter().enumerate() {
            if index + 1 == values.len() {
                match e {
                    Expr::Call(f, args) => {
                        if let Some(p) = self.call(f, None, args)? {
                            for ty in p.head {
                                let mut value = Value::ty(ty);
                                if may_carry_table_alias(&value.ty) {
                                    value.reachable_tables = self.last_call_aliases.clone();
                                }
                                result.push(self.returned_value(value)?);
                            }
                            if let Some(tail) = p.tail {
                                let ty = match tail {
                                    PackTail::Variadic(t) => TypeExpr::union(*t, TypeExpr::Nil),
                                    PackTail::Generic(_) => TypeExpr::Unknown,
                                };
                                while result.len() < count {
                                    let mut value = Value::ty(ty.clone());
                                    if may_carry_table_alias(&value.ty) {
                                        value.reachable_tables = self.last_call_aliases.clone();
                                    }
                                    result.push(self.returned_value(value)?);
                                }
                            }
                        } else {
                            result.resize_with(count.max(result.len()), Value::unknown)
                        }
                        continue;
                    }
                    Expr::MethodCall(o, n, args) => {
                        if let Some(p) = self.call(o, Some(n), args)? {
                            for ty in p.head {
                                let mut value = Value::ty(ty);
                                if may_carry_table_alias(&value.ty) {
                                    value.reachable_tables = self.last_call_aliases.clone();
                                }
                                result.push(self.returned_value(value)?);
                            }
                            if let Some(tail) = p.tail {
                                let ty = match tail {
                                    PackTail::Variadic(t) => TypeExpr::union(*t, TypeExpr::Nil),
                                    PackTail::Generic(_) => TypeExpr::Unknown,
                                };
                                while result.len() < count {
                                    let mut value = Value::ty(ty.clone());
                                    if may_carry_table_alias(&value.ty) {
                                        value.reachable_tables = self.last_call_aliases.clone();
                                    }
                                    result.push(self.returned_value(value)?);
                                }
                            }
                        } else {
                            result.resize_with(count.max(result.len()), Value::unknown)
                        }
                        continue;
                    }
                    _ => {}
                }
            }
            result.push(self.expr(e)?);
        }
        result.resize_with(count.max(result.len()), || Value::ty(TypeExpr::Nil));
        for value in &mut result {
            let original = std::mem::replace(value, Value::unknown());
            *value = self.materialize_value(original)?;
        }
        Ok(result)
    }
    fn body(&mut self, body: &[Stmt]) -> Result<()> {
        for stmt in body {
            self.tick()?;
            match stmt {
                Stmt::Local(names, values) => {
                    let evaluated = self.assignment_values(values, names.len())?;
                    for (index, name) in names.iter().enumerate() {
                        let value = evaluated.get(index).cloned().unwrap_or_else(|| {
                            Value::ty(self.seeds.get(name).cloned().unwrap_or(
                                if values.is_empty() {
                                    TypeExpr::Nil
                                } else {
                                    TypeExpr::Unknown
                                },
                            ))
                        });
                        self.set(name, value);
                    }
                }
                Stmt::Assign(targets, values) => {
                    let evaluated = self.assignment_values(values, targets.len())?;
                    for (index, target) in targets.iter().enumerate() {
                        let value = evaluated.get(index).cloned().unwrap_or_else(Value::unknown);
                        match target {
                            Expr::Name(name) => self.set(name, value),
                            Expr::Field(object, name) => {
                                let object = self.expr(object)?;
                                let ty = self.resolve(&value);
                                if let Some(id) = object.table {
                                    self.invalidate_opaque_write(id)?;
                                    let type_changed = self
                                        .tables
                                        .get(&id)
                                        .is_some_and(|table| table.fields.get(name) != Some(&ty));
                                    let children: Vec<_> = Self::value_tables(&value).collect();
                                    for child in &children {
                                        self.table_parents.entry(*child).or_default().insert(id);
                                    }
                                    let mut escaped = false;
                                    if let Some(table) = self.tables.get_mut(&id) {
                                        table.reachable_tables.extend(children.iter().copied());
                                        escaped = table.escaped;
                                        if table.fields.get(name) != Some(&ty) {
                                            self.table_revision += 1;
                                            table.last_type_change = self.table_revision;
                                        }
                                        let historical =
                                            table.history.get(name).cloned().map_or_else(
                                                || TypeExpr::Optional(Box::new(ty.clone())),
                                                |old| TypeExpr::union(old, ty.clone()),
                                            );
                                        table.history.insert(name.clone(), historical);
                                        if let Some(id) = value.table {
                                            table.references.insert(name.clone(), id);
                                        } else {
                                            table.references.remove(name);
                                        }
                                        table.fields.insert(name.clone(), ty);
                                    }
                                    if escaped {
                                        self.escape_tables(children)?;
                                    }
                                    if type_changed {
                                        self.invalidate_captured_write(id)?;
                                    }
                                } else {
                                    self.invalidate_opaque_facts()?;
                                    self.escape_tables(Self::value_tables(&value))?;
                                    self.escape_tables(object.reachable_tables.iter().copied())?;
                                }
                            }
                            Expr::Index(object, key) => {
                                let object = self.expr(object)?;
                                let key_value = self.expr(key)?;
                                let value_type = self.resolve(&value);
                                let key_type = self.resolve(&key_value);
                                if let Some(id) = object.table {
                                    self.invalidate_opaque_write(id)?;
                                    let revision = self.table_revision;
                                    let children: Vec<_> = Self::value_tables(&value)
                                        .chain(Self::value_tables(&key_value))
                                        .collect();
                                    for child in &children {
                                        self.table_parents.entry(*child).or_default().insert(id);
                                    }
                                    let mut escaped = false;
                                    if let Some(table) = self.tables.get_mut(&id) {
                                        table.reachable_tables.extend(children.iter().copied());
                                        escaped = table.escaped;
                                        if let Some(index) = integer_literal(key) {
                                            if let Some(child) = value.table {
                                                table.index_references.insert(index, child);
                                            } else {
                                                table.index_references.remove(&index);
                                            }
                                        } else if key_value.literal_string.is_none() {
                                            table.index_references.clear();
                                        }
                                        if let Some(name) =
                                            key_value.literal_string.or_else(|| string_literal(key))
                                        {
                                            if table.fields.get(&name) != Some(&value_type) {
                                                self.table_revision += 1;
                                                table.last_type_change = self.table_revision;
                                            }
                                            let historical =
                                                table.history.get(&name).cloned().map_or(
                                                    TypeExpr::Optional(Box::new(
                                                        value_type.clone(),
                                                    )),
                                                    |old| TypeExpr::union(old, value_type.clone()),
                                                );
                                            table.history.insert(name.clone(), historical);
                                            let ty = value_type;
                                            if let Some(id) = value.table {
                                                table.references.insert(name.clone(), id);
                                            } else {
                                                table.references.remove(&name);
                                            }
                                            table.fields.insert(name, ty);
                                        } else if table.array.is_some()
                                            && key_type == TypeExpr::Number
                                        {
                                            if table.array.as_ref() != Some(&value_type) {
                                                self.table_revision += 1;
                                                table.last_type_change = self.table_revision;
                                            }
                                            table.array = Some(TypeExpr::union(
                                                table.array.take().unwrap(),
                                                value_type,
                                            ));
                                        } else {
                                            self.table_revision += 1;
                                            table.last_type_change = self.table_revision;
                                            table.dictionary =
                                                Some(table.dictionary.take().map_or(
                                                    (key_type.clone(), value_type.clone()),
                                                    |(k, v)| {
                                                        (
                                                            TypeExpr::union(k, key_type),
                                                            TypeExpr::union(v, value_type),
                                                        )
                                                    },
                                                ));
                                        }
                                    }
                                    if escaped {
                                        self.escape_tables(children)?;
                                    }
                                    if self.table_revision != revision {
                                        self.invalidate_captured_write(id)?;
                                    }
                                } else {
                                    self.invalidate_opaque_facts()?;
                                    self.escape_tables(Self::value_tables(&value))?;
                                    self.escape_tables(object.reachable_tables.iter().copied())?;
                                }
                            }
                            _ => {
                                self.expr(target)?;
                                self.escape_tables(Self::value_tables(&value))?;
                            }
                        }
                    }
                }
                Stmt::Call(e) => {
                    self.expr(e)?;
                }
                Stmt::Return(values) => {
                    let pack = self.pack(values)?;
                    if let Some(returns) = self.return_stack.last_mut() {
                        returns.push(pack)
                    }
                }
                Stmt::If { condition, yes, no } => {
                    self.expr(condition)?;
                    let before = self.values.clone();
                    let before_tables = self.tables.clone();
                    let before_opaque = self.active_opaque_anchors.clone();
                    let before_anchor = self.opaque_return_anchor;
                    refine_condition(condition, true, &mut self.values);
                    self.body(yes)?;
                    let yes_values = self.values.clone();
                    let yes_tables = self.tables.clone();
                    let yes_opaque = self.active_opaque_anchors.clone();
                    self.tables = before_tables;
                    self.active_opaque_anchors = before_opaque;
                    self.opaque_return_anchor = before_anchor;
                    self.values = before.clone();
                    refine_condition(condition, false, &mut self.values);
                    self.body(no)?;
                    let no_values = self.values.clone();
                    self.tables = merge_tables(yes_tables, std::mem::take(&mut self.tables));
                    self.merge_opaque_facts(yes_opaque);
                    self.propagate_escaped_tables()?;
                    self.values = before;
                    let names: BTreeSet<_> =
                        yes_values.keys().chain(no_values.keys()).cloned().collect();
                    for name in names {
                        if let (Some(a), Some(b)) = (yes_values.get(&name), no_values.get(&name)) {
                            let value = self.joined_value(a, b);
                            self.values.insert(name, value);
                        }
                    }
                }
                Stmt::While { condition, body } => {
                    self.expr(condition)?;
                    self.loop_body(body, Some(condition))?;
                }
                Stmt::Repeat { body, until } => {
                    self.loop_body(body, Some(until))?;
                    self.expr(until)?;
                }
                Stmt::NumericFor {
                    variable,
                    start,
                    limit,
                    step,
                    body,
                } => {
                    self.expr(start)?;
                    self.expr(limit)?;
                    self.expr(step)?;
                    self.set(variable, Value::ty(TypeExpr::Number));
                    self.loop_body(body, None)?;
                }
                Stmt::GenericFor {
                    variables,
                    iterators,
                    body,
                } => {
                    for value in self.assignment_values(iterators, 3)? {
                        self.escape_tables(Self::value_tables(&value))?;
                    }
                    for n in variables {
                        self.set(n, Value::unknown());
                    }
                    self.loop_body(body, None)?;
                }
                Stmt::Do(body) => {
                    let before: BTreeSet<_> = self.values.keys().cloned().collect();
                    self.body(body)?;
                    self.values.retain(|name, _| before.contains(name));
                }
                Stmt::Break | Stmt::Continue => {}
            }
        }
        Ok(())
    }
}
fn effect_free_direct_function(mut function: &Expr) -> bool {
    while let Expr::Single(inner) = function {
        function = inner;
    }
    let Expr::Function(function) = function else {
        return false;
    };
    function.body.iter().all(|statement| match statement {
        Stmt::Return(values) => values.iter().all(effect_free_value),
        _ => false,
    })
}
fn effect_free_value(expr: &Expr) -> bool {
    match expr {
        Expr::Name(_) | Expr::Literal(_) | Expr::Vararg | Expr::Function(_) => true,
        Expr::Single(value) | Expr::Unary("not", value) => effect_free_value(value),
        Expr::Binary("and" | "or", left, right) => {
            effect_free_value(left) && effect_free_value(right)
        }
        Expr::IfElse(condition, yes, no) => {
            effect_free_value(condition) && effect_free_value(yes) && effect_free_value(no)
        }
        Expr::Table(fields) => fields.iter().all(|(key, value)| {
            key.as_ref().is_none_or(effect_free_value) && effect_free_value(value)
        }),
        _ => false,
    }
}
fn dependency_names(expr: &Expr) -> BTreeSet<String> {
    let mut names = BTreeSet::new();
    crate::ast::visit_expr(expr, &mut |expr| {
        if let Expr::Name(name) = expr {
            names.insert(name.clone());
        }
    });
    names
}
fn collect_call_dependencies(expr: &Expr, calls: &mut Vec<BTreeSet<String>>) {
    crate::ast::visit_expr(expr, &mut |expr| match expr {
        Expr::Call(function, arguments) | Expr::MethodCall(function, _, arguments) => {
            let mut names = dependency_names(function);
            for argument in arguments {
                names.extend(dependency_names(argument));
            }
            calls.push(names);
        }
        _ => {}
    });
}
fn nested_function_bodies<'a>(expr: &'a Expr, pending: &mut Vec<&'a Stmt>) {
    match expr {
        Expr::Function(function) => pending.extend(&function.body),
        Expr::Unary(_, value) | Expr::Single(value) | Expr::Field(value, _) => {
            nested_function_bodies(value, pending)
        }
        Expr::Binary(_, left, right) | Expr::Index(left, right) => {
            nested_function_bodies(left, pending);
            nested_function_bodies(right, pending);
        }
        Expr::Call(function, arguments) | Expr::MethodCall(function, _, arguments) => {
            nested_function_bodies(function, pending);
            for argument in arguments {
                nested_function_bodies(argument, pending);
            }
        }
        Expr::Table(fields) => {
            for (key, value) in fields {
                if let Some(key) = key {
                    nested_function_bodies(key, pending);
                }
                nested_function_bodies(value, pending);
            }
        }
        Expr::IfElse(condition, yes, no) => {
            nested_function_bodies(condition, pending);
            nested_function_bodies(yes, pending);
            nested_function_bodies(no, pending);
        }
        _ => {}
    }
}
type LoopDependencies = (
    BTreeMap<String, BTreeSet<String>>,
    Vec<BTreeSet<String>>,
    BTreeSet<String>,
);
fn loop_dependencies(body: &[Stmt]) -> Result<LoopDependencies> {
    let mut dependencies = BTreeMap::<String, BTreeSet<String>>::new();
    let mut calls = Vec::new();
    let mut returns = BTreeSet::new();
    let mut pending: Vec<_> = body.iter().collect();
    let mut visited = BTreeSet::new();
    while let Some(statement) = pending.pop() {
        crate::execution::charge_work(1)?;
        if !visited.insert(std::ptr::from_ref(statement) as usize) {
            continue;
        }
        let mut expressions = Vec::new();
        match statement {
            Stmt::Local(names, values) => {
                let sources: BTreeSet<_> = values.iter().flat_map(dependency_names).collect();
                for name in names {
                    dependencies
                        .entry(name.clone())
                        .or_default()
                        .extend(sources.iter().cloned());
                }
                expressions.extend(values);
            }
            Stmt::Assign(targets, values) => {
                let sources: BTreeSet<_> = values.iter().flat_map(dependency_names).collect();
                for name in targets.iter().flat_map(dependency_names) {
                    dependencies
                        .entry(name)
                        .or_default()
                        .extend(sources.iter().cloned());
                }
                expressions.extend(targets);
                expressions.extend(values);
            }
            Stmt::If { condition, yes, no } => {
                expressions.push(condition);
                pending.extend(yes);
                pending.extend(no);
            }
            Stmt::While { condition, body }
            | Stmt::Repeat {
                body,
                until: condition,
            } => {
                expressions.push(condition);
                pending.extend(body);
            }
            Stmt::NumericFor {
                start,
                limit,
                step,
                body,
                ..
            } => {
                expressions.extend([start, limit, step]);
                pending.extend(body);
            }
            Stmt::GenericFor {
                iterators, body, ..
            } => {
                expressions.extend(iterators);
                pending.extend(body);
            }
            Stmt::Do(body) => pending.extend(body),
            Stmt::Call(expr) => expressions.push(expr),
            Stmt::Return(values) => {
                returns.extend(values.iter().flat_map(dependency_names));
                expressions.extend(values);
            }
            Stmt::Break | Stmt::Continue => {}
        }
        for expression in expressions {
            collect_call_dependencies(expression, &mut calls);
            nested_function_bodies(expression, &mut pending);
        }
    }
    Ok((dependencies, calls, returns))
}
fn literal_type(text: &str) -> TypeExpr {
    if text == "nil" {
        TypeExpr::Nil
    } else if text == "true" || text == "false" {
        TypeExpr::Boolean
    } else if text.starts_with('"') || text.starts_with('\'') {
        TypeExpr::String
    } else if text.parse::<f64>().is_ok() || text.starts_with("0x") {
        TypeExpr::Number
    } else {
        TypeExpr::Unknown
    }
}
fn scalar_result(pack: &TypePack) -> TypeExpr {
    pack.head
        .first()
        .cloned()
        .unwrap_or_else(|| match &pack.tail {
            Some(PackTail::Variadic(ty)) => TypeExpr::union((**ty).clone(), TypeExpr::Nil),
            Some(PackTail::Generic(_)) => TypeExpr::Unknown,
            None => TypeExpr::Nil,
        })
}
fn may_carry_table_alias(ty: &TypeExpr) -> bool {
    match ty {
        TypeExpr::Nil
        | TypeExpr::Boolean
        | TypeExpr::Number
        | TypeExpr::String
        | TypeExpr::Thread
        | TypeExpr::Buffer
        | TypeExpr::Never => false,
        TypeExpr::Named(name) => !api().classes.contains(name),
        TypeExpr::Optional(inner) => may_carry_table_alias(inner),
        TypeExpr::Union(types) | TypeExpr::Intersection(types) => {
            types.iter().any(may_carry_table_alias)
        }
        _ => true,
    }
}
fn integer_literal(mut expr: &Expr) -> Option<i64> {
    while let Expr::Single(inner) = expr {
        expr = inner;
    }
    match expr {
        Expr::Literal(text) => text.parse().ok(),
        _ => None,
    }
}
fn merge_tables(
    mut yes: BTreeMap<usize, TableState>,
    no: BTreeMap<usize, TableState>,
) -> BTreeMap<usize, TableState> {
    for (id, b) in no {
        if let Some(a) = yes.get_mut(&id) {
            let keys: BTreeSet<_> = a.fields.keys().chain(b.fields.keys()).cloned().collect();
            for key in keys {
                let ty = match (a.fields.get(&key), b.fields.get(&key)) {
                    (Some(a), Some(b)) => TypeExpr::union(a.clone(), b.clone()),
                    (Some(a), None) | (None, Some(a)) => TypeExpr::Optional(Box::new(a.clone())),
                    _ => continue,
                };
                a.fields.insert(key.clone(), ty);
                if a.references.get(&key) != b.references.get(&key) {
                    a.references.remove(&key);
                }
            }
            for (k, v) in b.history {
                a.history
                    .entry(k)
                    .and_modify(|t| *t = TypeExpr::union(t.clone(), v.clone()))
                    .or_insert(v);
            }
            a.escaped |= b.escaped;
            a.reachable_tables.extend(b.reachable_tables);
            a.index_references
                .retain(|index, id| b.index_references.get(index) == Some(id));
            a.last_type_change = a.last_type_change.max(b.last_type_change);
            if a.array != b.array {
                a.array = match (a.array.take(), b.array) {
                    (Some(a), Some(b)) => Some(TypeExpr::union(a, b)),
                    _ => Some(TypeExpr::Unknown),
                }
            }
            if a.dictionary != b.dictionary {
                a.dictionary = Some((TypeExpr::Unknown, TypeExpr::Unknown));
            }
        } else {
            yes.insert(id, b);
        }
    }
    yes
}
fn string_literal(mut e: &Expr) -> Option<String> {
    while let Expr::Single(inner) = e {
        e = inner;
    }
    let Expr::Literal(text) = e else { return None };
    if text.starts_with('"') && text.ends_with('"') {
        serde_json::from_str(text).ok().or_else(|| {
            let s = &text[1..text.len() - 1];
            if s.bytes().all(|b| b >= 32 && b != b'\\' && b != b'"') {
                Some(s.into())
            } else {
                None
            }
        })
    } else {
        None
    }
}
fn terminal(body: &[Stmt]) -> bool {
    match body.last() {
        Some(Stmt::Return(_)) => true,
        Some(Stmt::If { yes, no, .. }) => terminal(yes) && terminal(no),
        Some(Stmt::Do(body)) => terminal(body),
        _ => false,
    }
}
fn instantiate_pack(
    pack: &TypePack,
    types: &BTreeMap<String, TypeExpr>,
    packs: &BTreeMap<String, TypePack>,
    generics: &[String],
    generic_packs: &[String],
) -> Option<TypePack> {
    let mut out = TypePack {
        head: pack
            .head
            .iter()
            .map(|t| instantiate_type(t, types, generics))
            .collect(),
        tail: None,
    };
    if let Some(tail) = &pack.tail {
        match tail {
            PackTail::Variadic(t) => {
                out.tail = Some(PackTail::Variadic(Box::new(instantiate_type(
                    t, types, generics,
                ))))
            }
            PackTail::Generic(n) => {
                if let Some(p) = packs.get(n) {
                    out.head.extend(p.head.clone());
                    out.tail = p.tail.clone();
                } else if generic_packs.contains(n) {
                    return None;
                } else {
                    out.tail = Some(tail.clone())
                }
            }
        }
    }
    Some(out)
}
fn instantiate_type(
    ty: &TypeExpr,
    types: &BTreeMap<String, TypeExpr>,
    generics: &[String],
) -> TypeExpr {
    match ty {
        TypeExpr::Generic(n) | TypeExpr::Named(n) if generics.contains(n) => {
            types.get(n).cloned().unwrap_or(TypeExpr::Unknown)
        }
        TypeExpr::Optional(t) => TypeExpr::Optional(Box::new(instantiate_type(t, types, generics))),
        TypeExpr::Array(t) => TypeExpr::Array(Box::new(instantiate_type(t, types, generics))),
        TypeExpr::Dictionary(k, v) => TypeExpr::Dictionary(
            Box::new(instantiate_type(k, types, generics)),
            Box::new(instantiate_type(v, types, generics)),
        ),
        TypeExpr::Record(fields) => TypeExpr::Record(
            fields
                .iter()
                .map(|(n, t)| (n.clone(), instantiate_type(t, types, generics)))
                .collect(),
        ),
        TypeExpr::Union(ts) => TypeExpr::Union(
            ts.iter()
                .map(|t| instantiate_type(t, types, generics))
                .collect(),
        ),
        TypeExpr::Intersection(ts) => TypeExpr::Intersection(
            ts.iter()
                .map(|t| instantiate_type(t, types, generics))
                .collect(),
        ),
        TypeExpr::Apply(n, ts) => TypeExpr::Apply(
            n.clone(),
            ts.iter()
                .map(|t| instantiate_type(t, types, generics))
                .collect(),
        ),
        TypeExpr::Function(f) => {
            let generic_names: Vec<_> = generics
                .iter()
                .filter(|n| !f.generics.contains(n))
                .cloned()
                .collect();
            let mut f = (**f).clone();
            f.parameters = f
                .parameters
                .iter()
                .map(|t| instantiate_type(t, types, &generic_names))
                .collect();
            f.returns.head = f
                .returns
                .head
                .iter()
                .map(|t| instantiate_type(t, types, &generic_names))
                .collect();
            TypeExpr::Function(Box::new(f))
        }
        other => other.clone(),
    }
}
fn refine_condition(condition: &Expr, truth: bool, values: &mut BTreeMap<String, Value>) {
    let (name, non_nil) = match condition {
        Expr::Name(name) if truth => (name, true),
        Expr::Unary("not", inner) => {
            refine_condition(inner, !truth, values);
            return;
        }
        Expr::Binary(op, a, b) if matches!(*op, "==" | "~=") => {
            let pair = match (&**a, &**b) {
                (Expr::Name(name), Expr::Literal(v)) | (Expr::Literal(v), Expr::Name(name))
                    if v == "nil" =>
                {
                    Some(name)
                }
                _ => None,
            };
            let Some(name) = pair else { return };
            (name, truth == (*op == "~="))
        }
        _ => return,
    };
    if let Some(value) = values.get_mut(name) {
        if non_nil {
            value.ty = match &value.ty {
                TypeExpr::Optional(inner) => (**inner).clone(),
                TypeExpr::Union(ts) => {
                    let mut ts: Vec<_> = ts
                        .iter()
                        .filter(|t| **t != TypeExpr::Nil)
                        .cloned()
                        .collect();
                    if ts.len() == 1 {
                        ts.remove(0)
                    } else {
                        TypeExpr::Union(ts)
                    }
                }
                other => other.clone(),
            };
        } else {
            value.ty = TypeExpr::Nil;
            value.table = None;
        }
    }
}
fn join_packs(packs: Vec<Option<TypePack>>) -> Option<TypePack> {
    let packs: Vec<TypePack> = packs.into_iter().collect::<Option<Vec<_>>>()?;
    let arities: BTreeSet<_> = packs.iter().map(|p| p.head.len()).collect();
    if arities == BTreeSet::from([0, 1]) && packs.iter().all(|p| p.tail.is_none()) {
        let mut scalar = TypeExpr::Never;
        for pack in &packs {
            if let Some(t) = pack.head.first() {
                scalar = TypeExpr::union(scalar, t.clone())
            }
        }
        if scalar.useful() {
            return Some(TypePack {
                head: Vec::new(),
                tail: Some(PackTail::Variadic(Box::new(scalar))),
            });
        }
    }
    let mut result = None::<TypePack>;
    for pack in packs {
        if let Some(old) = &mut result {
            if old.tail != pack.tail || old.head.len() != pack.head.len() {
                return None;
            }
            for (a, b) in old.head.iter_mut().zip(pack.head) {
                *a = TypeExpr::union(a.clone(), b)
            }
        } else {
            result = Some(pack)
        }
    }
    result
}
fn only_return_varargs(body: &[Stmt]) -> bool {
    body.len() == 1
        && matches!(&body[0],Stmt::Return(values)if values.last().is_some_and(|v|matches!(v,Expr::Vararg))&&values[..values.len()-1].iter().all(|e|matches!(e,Expr::Literal(_))))
}
fn generic_parameters(f: &Function) -> BTreeSet<String> {
    let parameters: BTreeSet<_> = f.parameters.iter().cloned().collect();
    let mut safe = parameters.clone();
    fn inspect(
        expr: &Expr,
        parameters: &BTreeSet<String>,
        safe: &mut BTreeSet<String>,
        allowed: bool,
    ) {
        match expr {
            Expr::Name(n) if parameters.contains(n) && !allowed => {
                safe.remove(n);
            }
            Expr::Table(fields) => {
                for (key, value) in fields {
                    if let Some(key) = key {
                        inspect(key, parameters, safe, false)
                    }
                    inspect(value, parameters, safe, allowed)
                }
            }
            Expr::Single(e) => inspect(e, parameters, safe, allowed),
            Expr::IfElse(c, a, b) => {
                inspect(c, parameters, safe, false);
                inspect(a, parameters, safe, allowed);
                inspect(b, parameters, safe, allowed)
            }
            Expr::Unary(_, e) | Expr::Field(e, _) => inspect(e, parameters, safe, false),
            Expr::Binary(_, a, b) | Expr::Index(a, b) => {
                inspect(a, parameters, safe, false);
                inspect(b, parameters, safe, false)
            }
            Expr::Call(f, args) | Expr::MethodCall(f, _, args) => {
                inspect(f, parameters, safe, false);
                for e in args {
                    inspect(e, parameters, safe, false)
                }
            }
            Expr::Function(f) => crate::ast::visit_body(&f.body, &mut |e| {
                if let Expr::Name(n) = e {
                    safe.remove(n);
                }
            }),
            _ => {}
        }
    }
    fn body(body: &[Stmt], parameters: &BTreeSet<String>, safe: &mut BTreeSet<String>) {
        for stmt in body {
            match stmt {
                Stmt::Return(values) => {
                    for e in values {
                        inspect(e, parameters, safe, true)
                    }
                }
                _ => crate::ast::visit_body(std::slice::from_ref(stmt), &mut |e| {
                    if let Expr::Name(n) = e {
                        if parameters.contains(n) {
                            safe.remove(n);
                        }
                    }
                }),
            }
        }
    }
    body(&f.body, &parameters, &mut safe);
    safe
}

pub fn reconstruct(
    body: &[Stmt],
    module: &Module,
    bindings: &[RecoveredBindingInfo],
    config: &Config,
) -> Result<(Annotations, TypeReport)> {
    let metadata_count: usize = module
        .protos
        .iter()
        .map(|p| {
            p.type_metadata.parameters.len()
                + p.type_metadata.upvalues.len()
                + p.type_metadata.locals.len()
        })
        .sum();
    if metadata_count > config.typing.max_nodes {
        return Err(Error::new(
            "types",
            "type metadata report node budget exceeded",
        ));
    }
    crate::execution::charge_work(metadata_count)?;
    crate::execution::reserve_ast_capacity(
        metadata_count
            .saturating_mul(std::mem::size_of::<MetadataRecord>() + 160)
            .saturating_add(bindings.len().saturating_mul(512)),
    )?;
    let mut report = TypeReport {
        total_bindings: bindings.len(),
        preserved_metadata: metadata_records(module),
        ..TypeReport::default()
    };
    report.original_return_sites = module
        .protos
        .iter()
        .enumerate()
        .flat_map(|(proto, p)| {
            p.code
                .iter()
                .filter(|i| i.op == crate::bytecode::Opcode::Return)
                .map(move |i| OriginalReturnSite {
                    proto,
                    pc: i.pc,
                    fixed_count: if i.b() == 0 { None } else { Some(i.b() - 1) },
                    open_results: i.b() == 0,
                })
        })
        .collect();
    report.metadata_any = report
        .preserved_metadata
        .iter()
        .filter(|m| m.tag & 127 == 15)
        .count();
    if config.typing.mode == TypingMode::Off {
        return Ok((Annotations::default(), report));
    }
    if config.typing.roblox_api {
        report.api_definition_sha256 = Some(api().hash.clone())
    }
    let mut seeds = BTreeMap::new();
    let mut origins = BTreeMap::new();
    let mut name_identities = BTreeMap::<String, BTreeSet<String>>::new();
    for binding in bindings {
        name_identities
            .entry(binding.name.clone())
            .or_default()
            .insert(format!("p{}:b{}", binding.proto, binding.id));
    }
    let ambiguous: BTreeSet<String> = name_identities
        .into_iter()
        .filter(|(_, ids)| ids.len() > 1)
        .map(|(name, _)| name)
        .collect();
    for binding in bindings {
        let identity = format!("p{}:b{}", binding.proto, binding.id);
        let p = &module.protos[binding.proto];
        let mut metadata = Vec::new();
        if binding.parameter {
            if let Some(t) = p.type_metadata.parameters.get(binding.register) {
                metadata.push(t)
            }
        }
        if ambiguous.contains(&binding.name) {
            continue;
        }
        for local in &p.type_metadata.locals {
            if local.register as usize == binding.register
                && local.start <= binding.first_pc.saturating_add(2)
                && local.end >= binding.last_pc
            {
                metadata.push(&local.type_info)
            }
        }
        let mut ty = metadata
            .first()
            .map(|t| metadata_type(t, module))
            .unwrap_or(TypeExpr::Unknown);
        if metadata.iter().any(|t| metadata_type(t, module) != ty) {
            ty = TypeExpr::Unknown
        }
        let mut origin = TypeOrigin::Metadata;
        let mut detail = "serialized VM type tag; broad/erased tags remain unresolved".to_string();
        if let Some(contract) = config.typing.binding_types.get(&identity) {
            ty = parse_type(contract)?;
            origin = TypeOrigin::ExternalContract;
            detail = "explicit recovered-binding type contract".into();
        }
        let explicit_contract = matches!(origin, TypeOrigin::ExternalContract);
        if binding.capture_mode == "cell" && (ty.useful() || explicit_contract) {
            ty = TypeExpr::Record(BTreeMap::from([("value".into(), ty)]))
        }
        if ty.useful() || ty == TypeExpr::Any || explicit_contract {
            seeds.insert(binding.name.clone(), ty);
            origins.insert(
                binding.name.clone(),
                (
                    origin,
                    detail,
                    metadata.iter().map(|t| t.source_offset).collect::<Vec<_>>(),
                ),
            );
        }
    }
    for key in config.typing.binding_types.keys() {
        if !bindings
            .iter()
            .any(|b| key == &format!("p{}:b{}", b.proto, b.id))
        {
            return Err(Error::new(
                "types",
                format!("external type contract {key} has no recovered binding"),
            ));
        }
    }
    let mut known = BTreeMap::new();
    let mut final_functions = BTreeMap::new();
    let mut final_types = BTreeMap::new();
    for iteration in 0..config.typing.max_iterations {
        crate::execution::checkpoint()?;
        let mut engine = Engine {
            config,
            seeds: &seeds,
            known: &known,
            conservative_captures: iteration + 1 == config.typing.max_iterations,
            values: BTreeMap::new(),
            observed: BTreeMap::new(),
            all: BTreeMap::new(),
            tables: BTreeMap::new(),
            table_parents: BTreeMap::new(),
            table_revision: 0,
            next_table: 0,
            next_function: 0,
            functions: BTreeMap::new(),
            function_captures: BTreeMap::new(),
            last_call_aliases: BTreeSet::new(),
            opaque_return_anchor: None,
            opaque_anchors: BTreeSet::new(),
            active_opaque_anchors: BTreeSet::new(),
            return_arities: BTreeMap::new(),
            return_stack: Vec::new(),
            varargs: vec![None],
            work: 0,
        };
        engine.body(body)?;
        for (id, captures) in &engine.function_captures {
            if captures
                .iter()
                .any(|id| engine.tables.get(id).is_none_or(|table| table.escaped))
            {
                if let Some(annotation) = engine.functions.get_mut(id) {
                    annotation.returns = None;
                }
            }
        }
        let mut types = engine.all.clone();
        for (name, value) in &engine.observed {
            let ty = engine.resolve(value);
            if let Some(id) = value.table {
                let declaration = if engine.tables.contains_key(&id) {
                    engine.declaration_type(value)
                } else {
                    TypeExpr::Unknown
                };
                types.insert(name.clone(), declaration);
            } else if !value.reachable_tables.is_empty() && ty == TypeExpr::Unknown {
                types.insert(name.clone(), TypeExpr::Unknown);
            }
        }
        for (name, ty) in &seeds {
            let inferred = types.get(name).cloned().unwrap_or(TypeExpr::Unknown);
            let contract = origins
                .get(name)
                .is_some_and(|(origin, _, _)| matches!(origin, TypeOrigin::ExternalContract));
            if contract || inferred == TypeExpr::Unknown {
                types.insert(name.clone(), ty.clone());
            } else {
                types.insert(name.clone(), TypeExpr::union(inferred, ty.clone()));
            }
        }
        report.iterations = iteration + 1;
        report.work_steps = report.work_steps.saturating_add(engine.work);
        if report.work_steps
            > config
                .typing
                .max_nodes
                .min(config.limits.max_analysis_steps)
        {
            return Err(Error::new(
                "types",
                "aggregate type fixed-point work budget exceeded",
            ));
        }
        report.function_return_arities = engine.return_arities;
        final_functions = engine.functions;
        let stable = types == known;
        known = types.clone();
        final_types = types;
        if stable {
            break;
        }
    }
    let mut annotations = Annotations {
        functions: final_functions,
        strict: config.typing.emit_strict,
        ..Annotations::default()
    };
    let declarations = declaration_names(body);
    let obvious = obvious_literal_declarations(body);
    report.emittable_bindings = declarations.len()
        + annotations
            .functions
            .values()
            .map(|f| f.parameters.len())
            .sum::<usize>();
    crate::ast::visit_body(body, &mut |expression| {
        if matches!(expression, Expr::Function(function) if function.vararg) {
            report.emittable_variadics += 1;
        }
    });
    report.annotated_variadics = annotations
        .functions
        .values()
        .filter(|function| function.variadic.is_some())
        .count();
    for binding in bindings {
        let identity = format!("p{}:b{}", binding.proto, binding.id);
        let ty = final_types
            .get(&binding.name)
            .cloned()
            .unwrap_or(TypeExpr::Unknown);
        if ty.useful()
            || ty == TypeExpr::Any
            || origins
                .get(&binding.name)
                .is_some_and(|(origin, _, _)| matches!(origin, TypeOrigin::ExternalContract))
        {
            let (origin, detail, offsets) = origins.get(&binding.name).cloned().unwrap_or((
                TypeOrigin::Inference,
                "bounded AST assignment/call/return constraints; no runtime sample specialization"
                    .into(),
                Vec::new(),
            ));
            report.evidence.push(TypeEvidence {
                binding: identity,
                name: binding.name.clone(),
                proto: binding.proto,
                register: binding.register,
                first_pc: binding.first_pc,
                last_pc: binding.last_pc,
                ty: ty.clone(),
                origin,
                detail,
                metadata_offsets: offsets,
            });
            let omit_obvious = config.typing.verbosity == AnnotationVerbosity::Useful
                && obvious.contains(&binding.name)
                && !binding.captured
                && !origins
                    .get(&binding.name)
                    .is_some_and(|(origin, _, _)| matches!(origin, TypeOrigin::ExternalContract));
            if !binding.parameter
                && declarations.contains(&binding.name)
                && !ambiguous.contains(&binding.name)
                && !omit_obvious
            {
                annotations.locals.insert(binding.name.clone(), ty.clone());
                report.annotated_bindings += 1;
            }
            if ty == TypeExpr::Any {
                report.explicit_any += 1
            } else {
                report.useful_annotations += 1;
            }
        } else {
            report.unknown_bindings += 1;
        }
    }
    for annotation in annotations.functions.values() {
        report.annotated_parameters += annotation.parameters.iter().filter(|p| p.is_some()).count();
        report.annotated_returns += usize::from(annotation.returns.is_some());
    }
    if !ambiguous.is_empty() {
        report.limitations.push("Bindings with explicitly reused names across distinct identities are not annotated by an ambiguous text key.".into());
    }
    if report.unknown_bindings > 0 {
        report.limitations.push("Erased or dynamic types remain unannotated; one observed call input never narrows a function interface.".into())
    }
    if report
        .function_return_arities
        .values()
        .any(|arities| arities.len() > 1)
    {
        report.limitations.push("function_return_arities retains distinct runtime AST return counts. Zero-or-one scalar results may use a conservative variadic scalar type pack; other differing fixed packs remain unannotated. These static packs do not claim exact original arity, and no runtime return list is changed.".into());
    }
    if report.iterations == config.typing.max_iterations {
        report.limitations.push("Type dependency iteration limit reached; scalar captures use unknown instead of stale point-in-time facts, and unresolved recursive relationships remain unknown.".into())
    }
    if config.typing.aliases {
        if let Some(Stmt::Return(values)) = body.last() {
            if values.len() == 1 {
                let ty = match &values[0] {
                    Expr::Name(n) => final_types.get(n).cloned(),
                    _ => None,
                };
                if let Some(ty) = ty.filter(TypeExpr::useful) {
                    if matches!(ty, TypeExpr::Record(_)) {
                        let mut name = "Module".to_string();
                        while api().classes.contains(&name)
                            || bindings.iter().any(|b| b.name == name)
                        {
                            name.push_str("Type");
                        }
                        annotations.aliases.push(TypeAlias {
                            name,
                            generics: Vec::new(),
                            generic_packs: Vec::new(),
                            ty,
                            exported: true,
                            origin: Some(module.main),
                        });
                    }
                }
            }
        }
    }
    if config.typing.aliases {
        add_result_aliases(body, &mut annotations, bindings);
    }
    let emitted = emitted_annotation_counts(&annotations, body, config)?;
    report.emitted_annotations = emitted.annotations;
    report.emitted_runtime_annotations = emitted.runtime_annotations;
    report.emitted_useful_annotations = emitted.useful_annotations;
    report.emitted_explicit_any = emitted.explicit_any;
    report.useful_annotations = emitted.useful_annotations;
    report.explicit_any = emitted.explicit_any;
    report.inferred_any = report
        .evidence
        .iter()
        .filter(|e| matches!(e.origin, TypeOrigin::Inference))
        .map(|e| e.ty.metrics().explicit_any)
        .sum();
    Ok((annotations, report))
}

fn add_result_aliases(
    body: &[Stmt],
    annotations: &mut Annotations,
    bindings: &[RecoveredBindingInfo],
) {
    let mut function_names = BTreeMap::<usize, String>::new();
    fn gather(body: &[Stmt], names: &mut BTreeMap<usize, String>) {
        for stmt in body {
            match stmt {
                Stmt::Local(local, values) => {
                    for (name, value) in local.iter().zip(values) {
                        if let Expr::Function(f) = value {
                            names.insert(&**f as *const Function as usize, name.clone());
                        }
                    }
                }
                Stmt::Assign(targets, values) => {
                    for (target, value) in targets.iter().zip(values) {
                        if let (Expr::Name(name), Expr::Function(f)) = (target, value) {
                            names.insert(&**f as *const Function as usize, name.clone());
                        }
                    }
                }
                Stmt::If { yes, no, .. } => {
                    gather(yes, names);
                    gather(no, names)
                }
                Stmt::Do(body)
                | Stmt::While { body, .. }
                | Stmt::Repeat { body, .. }
                | Stmt::NumericFor { body, .. }
                | Stmt::GenericFor { body, .. } => gather(body, names),
                _ => {}
            }
        }
    }
    gather(body, &mut function_names);
    crate::ast::visit_body(body, &mut |e| {
        if let Expr::Function(f) = e {
            gather(&f.body, &mut function_names)
        }
    });
    let mut used: BTreeSet<_> = annotations
        .aliases
        .iter()
        .map(|a| a.name.clone())
        .chain(bindings.iter().map(|b| b.name.clone()))
        .collect();
    used.extend(api().classes.iter().cloned());
    let mut index = 0;
    crate::ast::visit_body(body, &mut |e| {
        if let Expr::Function(f) = e {
            let id = index;
            index += 1;
            let Some(annotation) = annotations.functions.get_mut(&id) else {
                return;
            };
            let Some(pack) = &mut annotation.returns else {
                return;
            };
            if pack.head.len() != 1 || pack.tail.is_some() {
                return;
            }
            let TypeExpr::Record(fields) = &pack.head[0] else {
                return;
            };
            if fields.len() < 2 || !pack.head[0].useful() {
                return;
            }
            let Some(function_name) = function_names.get(&(&**f as *const Function as usize))
            else {
                return;
            };
            let mut stem = function_name.as_str();
            if stem.starts_with("get_") {
                stem = &stem[4..]
            } else if stem.starts_with("get")
                && stem.as_bytes().get(3).is_some_and(u8::is_ascii_uppercase)
            {
                stem = &stem[3..]
            }
            let mut name = String::new();
            let mut upper = true;
            for c in stem.chars() {
                if c == '_' {
                    upper = true;
                } else if upper {
                    name.extend(c.to_uppercase());
                    upper = false
                } else {
                    name.push(c)
                }
            }
            if name.is_empty() {
                name = "FunctionResult".into()
            } else if stem == function_name {
                name.push_str("Result")
            }
            let original = name.clone();
            let mut suffix = 2;
            while used.contains(&name) {
                name = format!("{original}{suffix}");
                suffix += 1;
            }
            used.insert(name.clone());
            let ty = std::mem::replace(
                &mut pack.head[0],
                TypeExpr::Apply(
                    name.clone(),
                    annotation
                        .generics
                        .iter()
                        .map(|n| TypeExpr::Generic(n.clone()))
                        .collect(),
                ),
            );
            if annotation.generics.is_empty() {
                pack.head[0] = TypeExpr::Named(name.clone())
            }
            annotations.aliases.push(TypeAlias {
                name,
                generics: annotation.generics.clone(),
                generic_packs: Vec::new(),
                ty,
                exported: true,
                origin: f.origin,
            });
        }
    });
}

fn declaration_names(body: &[Stmt]) -> BTreeSet<String> {
    let mut names = BTreeSet::new();
    fn gather(body: &[Stmt], names: &mut BTreeSet<String>) {
        for stmt in body {
            match stmt {
                Stmt::Local(local, _) => names.extend(local.iter().cloned()),
                Stmt::If { yes, no, .. } => {
                    gather(yes, names);
                    gather(no, names)
                }
                Stmt::Do(body)
                | Stmt::While { body, .. }
                | Stmt::Repeat { body, .. }
                | Stmt::NumericFor { body, .. }
                | Stmt::GenericFor { body, .. } => gather(body, names),
                _ => {}
            }
        }
    }
    gather(body, &mut names);
    crate::ast::visit_body(body, &mut |e| {
        if let Expr::Function(f) = e {
            gather(&f.body, &mut names)
        }
    });
    names
}
fn obvious_literal_declarations(body: &[Stmt]) -> BTreeSet<String> {
    let mut counts = BTreeMap::<String, usize>::new();
    let mut names = BTreeSet::new();
    fn gather(body: &[Stmt], names: &mut BTreeSet<String>, counts: &mut BTreeMap<String, usize>) {
        for stmt in body {
            match stmt {
                Stmt::Local(local, values) => {
                    for (index, name) in local.iter().enumerate() {
                        *counts.entry(name.clone()).or_default() += 1;
                        if matches!(values.get(index),Some(Expr::Literal(text))if literal_type(text).useful())
                        {
                            names.insert(name.clone());
                        }
                    }
                }
                Stmt::Assign(targets, _) => {
                    for target in targets {
                        if let Expr::Name(name) = target {
                            *counts.entry(name.clone()).or_default() += 1;
                        }
                    }
                }
                Stmt::If { yes, no, .. } => {
                    gather(yes, names, counts);
                    gather(no, names, counts)
                }
                Stmt::Do(body)
                | Stmt::While { body, .. }
                | Stmt::Repeat { body, .. }
                | Stmt::NumericFor { body, .. }
                | Stmt::GenericFor { body, .. } => gather(body, names, counts),
                _ => {}
            }
        }
    }
    gather(body, &mut names, &mut counts);
    crate::ast::visit_body(body, &mut |e| {
        if let Expr::Function(f) = e {
            gather(&f.body, &mut names, &mut counts)
        }
    });
    names.retain(|n| counts.get(n) == Some(&1));
    names
}
pub fn annotation_counts(a: &Annotations) -> (usize, usize, usize) {
    let mut total = 0;
    let mut useful = 0;
    let mut any = 0;
    let mut add = |metrics: TypeMetrics| {
        total += 1;
        useful += usize::from(metrics.useful());
        any += metrics.explicit_any;
    };
    for ty in a.locals.values().chain(a.aliases.iter().map(|a| &a.ty)) {
        add(ty.metrics());
    }
    for annotation in a.functions.values() {
        for ty in annotation.parameters.iter().flatten() {
            add(ty.metrics());
        }
        if let Some(tail) = &annotation.variadic {
            add(tail.metrics());
        }
        if let Some(pack) = &annotation.returns {
            add(pack.metrics());
        }
    }
    (total, useful, any)
}

#[derive(Debug, Clone, Copy, Default)]
pub struct EmittedAnnotationCounts {
    pub annotations: usize,
    pub runtime_annotations: usize,
    pub useful_annotations: usize,
    pub explicit_any: usize,
}
pub fn emitted_annotation_counts(
    annotations: &Annotations,
    body: &[Stmt],
    config: &Config,
) -> Result<EmittedAnnotationCounts> {
    struct Counter<'a> {
        annotations: &'a Annotations,
        config: &'a Config,
        function_index: usize,
        counts: EmittedAnnotationCounts,
    }
    impl Counter<'_> {
        fn add(&mut self, metrics: TypeMetrics, runtime: bool) {
            self.counts.annotations += 1;
            self.counts.runtime_annotations += usize::from(runtime);
            self.counts.useful_annotations += usize::from(metrics.useful());
            self.counts.explicit_any += metrics.explicit_any;
        }
        fn body(&mut self, body: &[Stmt]) -> Result<()> {
            for stmt in body {
                crate::execution::charge_work(1)?;
                match stmt {
                    Stmt::Local(names, values) => {
                        if !crate::format::local_function_syntax(
                            names,
                            values,
                            &self.config.formatting,
                            Some(self.annotations),
                            self.function_index,
                        ) {
                            for name in names {
                                if let Some(ty) = self.annotations.locals.get(name) {
                                    self.add(ty.metrics(), true);
                                }
                            }
                        }
                        for value in values {
                            self.expr(value)?;
                        }
                    }
                    Stmt::Assign(targets, values) => {
                        for expr in targets.iter().chain(values) {
                            self.expr(expr)?;
                        }
                    }
                    Stmt::Call(expr) => self.expr(expr)?,
                    Stmt::Return(values) => {
                        for value in values {
                            self.expr(value)?;
                        }
                    }
                    Stmt::If { condition, yes, no } => {
                        self.expr(condition)?;
                        self.body(yes)?;
                        self.body(no)?;
                    }
                    Stmt::While { condition, body } => {
                        self.expr(condition)?;
                        self.body(body)?;
                    }
                    Stmt::Repeat { body, until } => {
                        self.body(body)?;
                        self.expr(until)?;
                    }
                    Stmt::NumericFor {
                        start,
                        limit,
                        step,
                        body,
                        ..
                    } => {
                        self.expr(start)?;
                        self.expr(limit)?;
                        self.expr(step)?;
                        self.body(body)?;
                    }
                    Stmt::GenericFor {
                        iterators, body, ..
                    } => {
                        for iterator in iterators {
                            self.expr(iterator)?;
                        }
                        self.body(body)?;
                    }
                    Stmt::Do(body) => self.body(body)?,
                    Stmt::Break | Stmt::Continue => {}
                }
            }
            Ok(())
        }
        fn expr(&mut self, expr: &Expr) -> Result<()> {
            crate::execution::charge_work(1)?;
            match expr {
                Expr::Function(function) => {
                    if let Some(signature) = self.annotations.functions.get(&self.function_index) {
                        for ty in signature
                            .parameters
                            .iter()
                            .take(function.parameters.len())
                            .flatten()
                        {
                            self.add(ty.metrics(), true);
                        }
                        if function.vararg {
                            if let Some(tail) = &signature.variadic {
                                self.add(tail.metrics(), true);
                            }
                        }
                        if let Some(pack) = &signature.returns {
                            self.add(pack.metrics(), true);
                        }
                    }
                    self.function_index += 1;
                    self.body(&function.body)?;
                }
                Expr::Unary(_, value) | Expr::Single(value) | Expr::Field(value, _) => {
                    self.expr(value)?
                }
                Expr::Binary(_, a, b) | Expr::Index(a, b) => {
                    self.expr(a)?;
                    self.expr(b)?;
                }
                Expr::Call(f, args) | Expr::MethodCall(f, _, args) => {
                    self.expr(f)?;
                    for arg in args {
                        self.expr(arg)?;
                    }
                }
                Expr::Table(fields) => {
                    for (key, value) in fields {
                        if let Some(key) = key {
                            self.expr(key)?;
                        }
                        self.expr(value)?;
                    }
                }
                Expr::IfElse(c, a, b) => {
                    self.expr(c)?;
                    self.expr(a)?;
                    self.expr(b)?;
                }
                Expr::Literal(_) | Expr::Name(_) | Expr::Global(_) | Expr::Vararg => {}
            }
            Ok(())
        }
    }
    let mut counter = Counter {
        annotations,
        config,
        function_index: 0,
        counts: EmittedAnnotationCounts::default(),
    };
    for alias in &annotations.aliases {
        counter.add(alias.ty.metrics(), false);
    }
    counter.body(body)?;
    Ok(counter.counts)
}

pub fn metadata_annotations(full: &Annotations, report: &TypeReport, body: &[Stmt]) -> Annotations {
    let names: BTreeSet<_> = report
        .evidence
        .iter()
        .filter(|e| {
            matches!(
                e.origin,
                TypeOrigin::Metadata | TypeOrigin::ExternalContract
            )
        })
        .map(|e| e.name.clone())
        .collect();
    let mut out = Annotations {
        strict: full.strict,
        ..Annotations::default()
    };
    out.locals = full
        .locals
        .iter()
        .filter(|(n, _)| names.contains(*n))
        .map(|(n, t)| (n.clone(), t.clone()))
        .collect();
    let mut index = 0usize;
    crate::ast::visit_body(body, &mut |e| {
        if let Expr::Function(f) = e {
            if let Some(annotation) = full.functions.get(&index) {
                let mut annotation = annotation.clone();
                annotation.generics.clear();
                annotation.generic_packs.clear();
                annotation.variadic = None;
                annotation.returns = None;
                for (name, ty) in f.parameters.iter().zip(&mut annotation.parameters) {
                    if !names.contains(name) {
                        *ty = None
                    }
                }
                out.functions.insert(index, annotation);
            }
            index += 1;
        }
    });
    out
}
