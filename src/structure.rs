use crate::ast::{self, Expr, Function, Stmt};
use crate::bindings::RecoveredBindings;
use crate::bytecode::{Constant, Instruction, Module, Opcode, Proto};
use crate::cfg::{self, Cfg};
use crate::dataflow::{RegisterSet, Ssa};
use crate::names::{is_identifier, quote, NameAllocator};
use crate::parallel as rayon;
use crate::{Config, Error, Result};
use std::collections::{BTreeMap, BTreeSet};
use std::sync::Arc;

type Analysis = (Arc<Cfg>, Arc<Ssa>, Arc<RecoveredBindings>);

#[derive(Clone)]
struct Upvalue {
    value: Expr,
    identity: Expr,
    writable: bool,
    native: bool,
}
#[derive(Clone)]
struct Register {
    name: String,
    cell: bool,
    captured: bool,
}
impl Register {
    fn value(&self) -> Expr {
        if self.cell {
            Expr::Field(Box::new(Expr::name(&self.name)), "value".into())
        } else {
            Expr::name(&self.name)
        }
    }
}
#[derive(Clone)]
struct ClosureCache {
    function: Expr,
    captures: Vec<Expr>,
}
#[derive(Clone)]
struct Shared {
    names: NameAllocator,
    caches: BTreeMap<(usize, usize), ClosureCache>,
    raw_equal: Option<String>,
    cache_table: Option<String>,
    next_cache_slot: usize,
    steps: usize,
    expanded_instructions: usize,
    text_bytes: usize,
    proto_text_cost: Vec<usize>,
    analyses: Vec<Analysis>,
    acyclic_root: bool,
    single_use_root_closures: BTreeSet<usize>,
    fallback_prototypes: BTreeSet<usize>,
    recovered_bindings: Vec<RecoveredBindingInfo>,
    hoisted_closures: BTreeMap<(usize, usize), String>,
    hoisted_functions: Vec<(String, Function)>,
    entry_restrictions: BTreeMap<(usize, usize), String>,
    duplicate_sites: Vec<BTreeMap<usize, usize>>,
    uses_duplicate: bool,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct ClosureScopeRestriction {
    pub proto: usize,
    pub pc: usize,
    pub reason: String,
}
#[derive(Debug, Clone, serde::Serialize)]
pub struct ClosureScopeReport {
    pub requested: crate::config::EntryInvocation,
    pub compiler_sharing_contract: bool,
    pub restrictions: Vec<ClosureScopeRestriction>,
    pub assumptions: Vec<String>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct RecoveredBindingInfo {
    pub proto: usize,
    pub id: usize,
    pub register: usize,
    pub first_pc: usize,
    pub last_pc: usize,
    pub name: String,
    pub debug_name: Option<String>,
    pub parameter: bool,
    pub captured: bool,
    pub capture_mode: &'static str,
}
pub struct Reconstruction {
    pub source: String,
    pub baseline_source: Option<String>,
    pub metadata_source: Option<String>,
    pub type_report: crate::types::TypeReport,
    pub constructor_transformations: Vec<String>,
    pub source_map: Vec<crate::types::GeneratedRegion>,
    pub baseline_source_map: Vec<crate::types::GeneratedRegion>,
    pub metadata_source_map: Vec<crate::types::GeneratedRegion>,
    pub baseline_format_micros: u64,
    pub closure_scope: ClosureScopeReport,
    pub body: Vec<Stmt>,
    pub body_origin: usize,
    pub fallback_prototypes: Vec<usize>,
    pub recovered_bindings: Vec<RecoveredBindingInfo>,
}
impl Shared {
    fn charge(&mut self, n: usize, config: &Config) -> Result<()> {
        crate::execution::charge_work(n)?;
        if self.steps & 255 == 0 || n >= 256 {
            crate::execution::checkpoint()?;
        }
        self.steps = self
            .steps
            .checked_add(n)
            .ok_or_else(|| Error::new("limit", "AST expansion counter overflow"))?;
        if self.steps > config.limits.max_analysis_steps {
            return Err(Error::new("limit", "shared AST expansion budget exceeded"));
        }
        if self.expanded_instructions > config.limits.max_output_bytes {
            return Err(Error::new(
                "limit",
                "expanded prototype instruction budget exceeds output budget",
            ));
        }
        Ok(())
    }
}

pub fn decompile_module(module: &Module, config: &Config) -> Result<String> {
    Ok(decompile_module_report(module, config)?.source)
}
pub fn decompile_module_report(module: &Module, config: &Config) -> Result<Reconstruction> {
    crate::execution::checkpoint()?;
    if config.entry_output == crate::config::EntryOutput::Function && nil_capture_wrapper(module) {
        return Err(Error::new("entry", "function dump contains a nil-placeholder capture wrapper; live upvalue values are absent from serialized bytecode").at_proto(module.main));
    }
    crate::execution::reserve_ast_capacity(
        module
            .strings
            .len()
            .saturating_add(module.protos.len())
            .saturating_mul(std::mem::size_of::<usize>()),
    )?;
    let string_cost: Vec<usize> = module
        .strings
        .iter()
        .map(|s| {
            s.iter().fold(2usize, |n, &b| {
                n.saturating_add(match b {
                    b'"' | b'\\' | b'\n' | b'\r' | b'\t' => 2,
                    32..=126 => 1,
                    _ => 4,
                })
            })
        })
        .collect();
    let mut proto_text_cost = Vec::with_capacity(module.protos.len());
    let mut module_text_cost = 0usize;
    for (pid, proto) in module.protos.iter().enumerate() {
        let literal_cost = |constant: &Constant| -> usize {
            match constant {
                Constant::String(id) => string_cost[*id],
                _ => 32,
            }
        };
        let mut cost = proto.code.len().saturating_mul(16);
        for i in &proto.code {
            let index = match i.op {
                Opcode::LoadK | Opcode::DupTable => Some(i.d() as usize),
                Opcode::LoadKx
                | Opcode::GetGlobal
                | Opcode::SetGlobal
                | Opcode::GetTableKs
                | Opcode::SetTableKs
                | Opcode::NameCall => i.aux.map(|v| v as usize),
                Opcode::AddK
                | Opcode::SubK
                | Opcode::MulK
                | Opcode::DivK
                | Opcode::ModK
                | Opcode::PowK
                | Opcode::AndK
                | Opcode::OrK
                | Opcode::IDivK => Some(i.c()),
                Opcode::SubRk | Opcode::DivRk => Some(i.b()),
                Opcode::JumpXEqKN | Opcode::JumpXEqKS => i.aux.map(|v| (v & 0xffffff) as usize),
                _ => None,
            };
            if let Some(index) = index {
                let k = &proto.constants[index];
                cost = cost.saturating_add(literal_cost(k));
                match k {
                    Constant::Table(keys) => {
                        for &key in keys {
                            cost = cost.saturating_add(literal_cost(&proto.constants[key]));
                        }
                    }
                    Constant::TableWithConstants(entries) => {
                        for &(key, value) in entries {
                            cost = cost.saturating_add(literal_cost(&proto.constants[key]));
                            if let Some(value) = value {
                                cost = cost.saturating_add(literal_cost(&proto.constants[value]));
                            }
                        }
                    }
                    _ => {}
                }
            }
            if i.op == Opcode::GetImport {
                let aux = i.aux.unwrap_or(0);
                for n in 0..aux >> 30 {
                    cost = cost.saturating_add(literal_cost(
                        &proto.constants[((aux >> (20 - n * 10)) & 1023) as usize],
                    ));
                }
            }
            if i.op == Opcode::NewTable {
                cost = cost.saturating_add((i.aux.unwrap_or(0) as usize).saturating_mul(5));
            }
            if cost > config.limits.max_output_bytes {
                return Err(Error::new(
                    "limit",
                    "source text estimate exceeds output budget before global/name analysis",
                )
                .at_proto(pid)
                .at_pc(i.pc));
            }
        }
        module_text_cost = module_text_cost.saturating_add(cost);
        if module_text_cost > config.limits.max_output_bytes {
            return Err(
                Error::new("limit", "module source text estimate exceeds output budget")
                    .at_proto(pid),
            );
        }
        proto_text_cost.push(cost);
    }
    crate::execution::reserve_ast_capacity(module_text_cost.saturating_mul(2))?;
    let mut globals = BTreeSet::new();
    let mut environment_references = Vec::new();
    if let Some(path) = &config.vector_constructor {
        globals.insert(path.split('.').next().unwrap().to_owned());
    }
    for (pid, proto) in module.protos.iter().enumerate() {
        for i in &proto.code {
            let global = match i.op {
                Opcode::GetGlobal | Opcode::SetGlobal => {
                    Some(constant_string(module, proto, i.aux.unwrap_or(0) as usize)?)
                }
                Opcode::GetImport => {
                    let aux = i.aux.unwrap_or(0);
                    Some(constant_string(
                        module,
                        proto,
                        ((aux >> 20) & 1023) as usize,
                    )?)
                }
                _ => None,
            };
            if let Some(bytes) = global {
                let name = std::str::from_utf8(bytes).map_err(|_| {
                    Error::new("structure", "global name is not UTF-8")
                        .at_proto(pid)
                        .at_pc(i.pc)
                })?;
                if !is_identifier(name) {
                    return Err(Error::new(
                        "structure",
                        format!("global {name:?} cannot be expressed without environment lookup"),
                    )
                    .at_proto(pid)
                    .at_pc(i.pc));
                }
                if matches!(name, "getfenv" | "setfenv") {
                    if name == "setfenv" || i.op == Opcode::SetGlobal {
                        return Err(Error::new(
                            "structure",
                            "environment mutation is unsupported by closure reconstruction",
                        )
                        .at_proto(pid)
                        .at_pc(i.pc));
                    }
                    environment_references.push((pid, i.pc));
                }
                globals.insert(name.to_owned());
            }
        }
    }
    let mut overrides = BTreeSet::new();
    for (key, name) in &config.name_overrides {
        if globals.contains(name) || !overrides.insert(name.clone()) {
            return Err(Error::new(
                "names",
                format!("override {key} collides with a global or another binding: {name}"),
            ));
        }
        let (p, binding) = key[1..]
            .split_once(':')
            .ok_or_else(|| Error::new("names", "invalid override key"))?;
        let pid = p
            .parse::<usize>()
            .map_err(|_| Error::new("names", "invalid prototype override index"))?;
        let register = binding[1..]
            .parse::<usize>()
            .map_err(|_| Error::new("names", "invalid register override index"))?;
        if module
            .protos
            .get(pid)
            .is_none_or(|p| binding.starts_with('r') && register >= p.max_stack as usize)
        {
            return Err(Error::new(
                "names",
                format!("override {key} does not refer to an existing binding"),
            ));
        }
    }
    globals.extend(overrides);
    let analyses = analyze_prototypes(module, config)?;
    let mut override_targets = BTreeSet::new();
    for key in config.name_overrides.keys() {
        let (proto, target) = key[1..].split_once(':').unwrap();
        let pid: usize = proto.parse().unwrap();
        let index: usize = target[1..].parse().unwrap();
        let id = if target.starts_with('r') {
            analyses[pid].2.first_for_register[index]
        } else {
            index
        };
        if id >= analyses[pid].2.bindings.len() {
            return Err(Error::new(
                "names",
                format!("override {key} refers to an absent binding"),
            )
            .at_proto(pid));
        }
        if !override_targets.insert((pid, id)) {
            return Err(Error::new(
                "names",
                format!(
                    "override {key} duplicates another override for recovered binding p{pid}:b{id}"
                ),
            )
            .at_proto(pid));
        }
    }
    for (pid, pc) in environment_references {
        let proto = &module.protos[pid];
        let index = proto.code.binary_search_by_key(&pc, |i| i.pc).unwrap();
        if !safe_thread_environment_reference(
            proto,
            &analyses[pid].1,
            index,
            config.limits.max_analysis_steps,
        ) {
            return Err(Error::new("structure","getfenv is supported only through proven getfenv(0) calls; stack/environment introspection is unsupported").at_proto(pid).at_pc(pc));
        }
    }
    let (acyclic_root, single_use_root_closures) =
        single_use_root_closures(module, &analyses[module.main].0);
    let duplicate_sites = module
        .protos
        .iter()
        .map(|proto| {
            let mut counts = BTreeMap::new();
            for instruction in &proto.code {
                if instruction.op == Opcode::DupClosure {
                    *counts.entry(instruction.d() as usize).or_insert(0) += 1;
                }
            }
            counts
        })
        .collect();
    let mut shared = Shared {
        names: NameAllocator::new(config.naming, globals),
        caches: BTreeMap::new(),
        raw_equal: None,
        cache_table: None,
        next_cache_slot: 1,
        steps: 0,
        expanded_instructions: 0,
        text_bytes: 0,
        proto_text_cost,
        analyses,
        acyclic_root,
        single_use_root_closures,
        fallback_prototypes: BTreeSet::new(),
        recovered_bindings: Vec::new(),
        hoisted_closures: BTreeMap::new(),
        hoisted_functions: Vec::new(),
        entry_restrictions: BTreeMap::new(),
        duplicate_sites,
        uses_duplicate: false,
    };
    let main = build_function(module, config, &mut shared, module.main, Vec::new(), 0)?;
    if !main.parameters.is_empty() && config.entry_output == crate::config::EntryOutput::Script {
        return Err(
            Error::new("structure", "entry prototype has fixed parameters; select entry_output=function for a serialized function entry").at_proto(module.main),
        );
    }
    let mut body = Vec::new();
    for (name, function) in std::mem::take(&mut shared.hoisted_functions) {
        body.push(Stmt::Local(
            vec![name],
            vec![Expr::Function(Box::new(function))],
        ));
    }
    if let Some(name) = shared.cache_table {
        body.push(Stmt::Local(vec![name], vec![Expr::Table(Vec::new())]));
    }
    if let Some(name) = shared.raw_equal {
        body.push(Stmt::Local(
            vec![name],
            vec![Expr::Function(Box::new(raw_equality_function(
                &mut shared.names,
            )))],
        ));
    }
    if config.entry_output == crate::config::EntryOutput::Function {
        body.push(Stmt::Return(vec![Expr::Function(Box::new(main))]));
    } else {
        body.extend(main.body);
    }
    let recovered_constructors = recover_record_constructors(&mut body)?;
    let format_started = crate::platform::Instant::now();
    let (source, mut source_map) = crate::format::format_typed(
        &body,
        config,
        &crate::ast::Annotations::default(),
        module.main,
        &shared.recovered_bindings,
    )?;
    let baseline_format_micros = format_started.elapsed().as_micros().min(u64::MAX as u128) as u64;
    let constructor_bindings: BTreeSet<_> = shared
        .recovered_bindings
        .iter()
        .filter(|b| recovered_constructors.contains(&b.name))
        .map(|b| format!("p{}:b{}", b.proto, b.id))
        .collect();
    for region in &mut source_map {
        region.transformations.clear();
        if region
            .binding
            .as_ref()
            .is_some_and(|identity| constructor_bindings.contains(identity))
        {
            region
                .transformations
                .push("fresh_table_constructor".into());
        }
    }
    let baseline_source_map = Vec::new();
    Ok(Reconstruction {
        source,
        baseline_source: None,
        metadata_source: None,
        type_report: Default::default(),
        constructor_transformations: constructor_bindings.into_iter().collect(),
        baseline_source_map,
        metadata_source_map: Vec::new(),
        baseline_format_micros,
        closure_scope: ClosureScopeReport {
            requested: config.closures.entry_invocation,
            compiler_sharing_contract: config.closures.compiler_closure_sharing,
            restrictions: shared
                .entry_restrictions
                .into_iter()
                .map(|((proto, pc), reason)| ClosureScopeRestriction { proto, pc, reason })
                .collect(),
            assumptions: if config.closures.entry_invocation
                == crate::config::EntryInvocation::Repeated
                && config.closures.compiler_closure_sharing
                && shared.uses_duplicate
            {
                vec!["output compiler must preserve immutable closure sharing (verified with pinned Luau O1/O2); repeated entry under O0 is not guaranteed".into()]
            } else {
                Vec::new()
            },
        },
        source_map,
        body,
        body_origin: module.main,
        fallback_prototypes: shared.fallback_prototypes.into_iter().collect(),
        recovered_bindings: shared.recovered_bindings,
    })
}

fn nil_capture_wrapper(module: &Module) -> bool {
    let proto = &module.protos[module.main];
    if proto.num_params != 0 || proto.is_vararg || proto.code.len() != 4 {
        return false;
    }
    let [nil, closure, capture, returned] = proto.code.as_slice() else {
        return false;
    };
    nil.op == Opcode::LoadNil
        && closure.op == Opcode::NewClosure
        && capture.op == Opcode::Capture
        && capture.a() == 0
        && capture.b() == nil.a()
        && returned.op == Opcode::Return
        && returned.a() == closure.a()
        && returned.b() == 2
        && proto
            .children
            .get(closure.d() as usize)
            .and_then(|id| module.protos.get(*id))
            .is_some_and(|p| p.num_upvalues == 1)
}

fn recover_record_constructors(body: &mut Vec<Stmt>) -> Result<BTreeSet<String>> {
    let mut recovered = BTreeSet::new();
    fn descend_expr(expr: &mut Expr, recovered: &mut BTreeSet<String>) -> Result<()> {
        match expr {
            Expr::Function(function) => {
                recovered.extend(recover_record_constructors(&mut function.body)?)
            }
            Expr::Unary(_, e) | Expr::Single(e) | Expr::Field(e, _) => descend_expr(e, recovered)?,
            Expr::Binary(_, a, b) | Expr::Index(a, b) => {
                descend_expr(a, recovered)?;
                descend_expr(b, recovered)?;
            }
            Expr::Call(f, args) | Expr::MethodCall(f, _, args) => {
                descend_expr(f, recovered)?;
                for arg in args {
                    descend_expr(arg, recovered)?;
                }
            }
            Expr::Table(fields) => {
                for (key, value) in fields {
                    if let Some(key) = key {
                        descend_expr(key, recovered)?;
                    }
                    descend_expr(value, recovered)?;
                }
            }
            Expr::IfElse(c, a, b) => {
                descend_expr(c, recovered)?;
                descend_expr(a, recovered)?;
                descend_expr(b, recovered)?;
            }
            _ => {}
        }
        Ok(())
    }
    for stmt in body.iter_mut() {
        crate::execution::charge_work(1)?;
        match stmt {
            Stmt::Local(_, values) | Stmt::Return(values) => {
                for value in values {
                    descend_expr(value, &mut recovered)?;
                }
            }
            Stmt::Assign(targets, values) => {
                for value in targets.iter_mut().chain(values) {
                    descend_expr(value, &mut recovered)?;
                }
            }
            Stmt::Call(expr) => descend_expr(expr, &mut recovered)?,
            Stmt::If { condition, yes, no } => {
                descend_expr(condition, &mut recovered)?;
                recovered.extend(recover_record_constructors(yes)?);
                recovered.extend(recover_record_constructors(no)?);
            }
            Stmt::While { condition, body }
            | Stmt::Repeat {
                until: condition,
                body,
            } => {
                descend_expr(condition, &mut recovered)?;
                recovered.extend(recover_record_constructors(body)?);
            }
            Stmt::NumericFor {
                start,
                limit,
                step,
                body,
                ..
            } => {
                for expr in [start, limit, step] {
                    descend_expr(expr, &mut recovered)?;
                }
                recovered.extend(recover_record_constructors(body)?);
            }
            Stmt::GenericFor {
                iterators, body, ..
            } => {
                for expr in iterators {
                    descend_expr(expr, &mut recovered)?;
                }
                recovered.extend(recover_record_constructors(body)?);
            }
            Stmt::Do(body) => recovered.extend(recover_record_constructors(body)?),
            Stmt::Break | Stmt::Continue => {}
        }
    }
    if !body.iter().any(|statement| matches!(statement, Stmt::Local(names, values)
        if names.len() == 1 && matches!(values.as_slice(), [Expr::Table(fields)] if !fields.is_empty()))) {
        return Ok(recovered);
    }
    let mut uses = BTreeMap::<String, usize>::new();
    crate::ast::visit_body(body, &mut |expr| {
        if let Expr::Name(name) = expr {
            if let Some(count) = uses.get_mut(name) {
                *count += 1;
            } else {
                uses.insert(name.clone(), 1);
            }
        }
    });
    let mut at = 0;
    while at < body.len() {
        crate::execution::charge_work(1)?;
        let Some((name, keys)) = record_prefill(&body[at]) else {
            at += 1;
            continue;
        };
        crate::execution::reserve_ast_capacity(
            keys.len()
                .saturating_mul(std::mem::size_of::<usize>() + std::mem::size_of::<Expr>()),
        )?;
        let (candidate_body, mut cursor, scoped) = match body.get(at + 1) {
            Some(Stmt::Do(inner)) => (inner.as_slice(), 0, true),
            _ => (body.as_slice(), at + 1, false),
        };
        let mut replacements = Vec::with_capacity(keys.len());
        for key in &keys {
            let Some((value_at, end)) = record_write(candidate_body, cursor, &name, key, &uses)
            else {
                break;
            };
            replacements.push(value_at);
            cursor = end;
        }
        if replacements.len() == keys.len() && (!scoped || cursor == candidate_body.len()) {
            let source_body = if scoped {
                let Stmt::Do(inner) = &mut body[at + 1] else {
                    unreachable!("validated constructor scope");
                };
                inner
            } else {
                &mut *body
            };
            let replacements: Vec<_> = replacements
                .into_iter()
                .map(|index| match &mut source_body[index] {
                    Stmt::Local(_, values) | Stmt::Assign(_, values) => {
                        std::mem::replace(&mut values[0], Expr::Literal("nil".into()))
                    }
                    _ => unreachable!("validated constructor value statement"),
                })
                .collect();
            if let Stmt::Local(_, values) = &mut body[at] {
                if let Expr::Table(fields) = &mut values[0] {
                    for ((_, value), replacement) in fields.iter_mut().zip(replacements) {
                        *value = replacement;
                    }
                    if let Some((None, value)) = fields.last_mut() {
                        if matches!(value, Expr::Call(..) | Expr::MethodCall(..) | Expr::Vararg) {
                            let original = std::mem::replace(value, Expr::Literal("nil".into()));
                            *value = Expr::Single(Box::new(original));
                        }
                    }
                }
            }
            body.drain(at + 1..if scoped { at + 2 } else { cursor });
            let return_only = uses.get(&name) == Some(&(keys.len() + 1))
                && matches!(body.get(at + 1), Some(Stmt::Return(values)) if values.len() == 1 && matches!(&values[0], Expr::Name(n) if n == &name));
            if return_only {
                let statement = std::mem::replace(&mut body[at], Stmt::Return(Vec::new()));
                if let Stmt::Local(_, values) = statement {
                    body[at] = Stmt::Return(values);
                }
                body.remove(at + 1);
            }
            recovered.insert(name);
        }
        at += 1;
    }
    Ok(recovered)
}

enum ConstructorKey {
    Field(String),
    Index(usize),
}
fn record_write(
    body: &[Stmt],
    start: usize,
    table: &str,
    key: &ConstructorKey,
    uses: &BTreeMap<String, usize>,
) -> Option<(usize, usize)> {
    let mut cursor = start;
    while let Some(Stmt::Local(names, values)) = body.get(cursor) {
        if cursor - start == 2
            || names.len() != 1
            || values.len() != 1
            || uses.get(&names[0]) != Some(&1)
        {
            return None;
        }
        cursor += 1;
    }
    let Stmt::Assign(targets, values) = body.get(cursor)? else {
        return None;
    };
    if targets.len() != 1 || values.len() != 1 {
        return None;
    }
    let mut key_temp = None;
    match &targets[0] {
        Expr::Field(object, field)
            if matches!(&**object, Expr::Name(name) if name == table)
                && matches!(key, ConstructorKey::Field(name) if name == field) => {}
        Expr::Index(object, index) if matches!(&**object, Expr::Name(name) if name == table) => {
            let literal = match &**index {
                Expr::Name(name) => {
                    let at = (start..cursor).find(
                        |at| matches!(&body[*at], Stmt::Local(names, _) if names[0] == *name),
                    )?;
                    key_temp = Some(at);
                    let Stmt::Local(_, values) = &body[at] else {
                        return None;
                    };
                    &values[0]
                }
                expr => expr,
            };
            if !matches!(literal, Expr::Literal(text) if match key {
                ConstructorKey::Field(name) => text.strip_prefix('"').and_then(|s| s.strip_suffix('"')) == Some(name),
                ConstructorKey::Index(index) => text.parse::<usize>().ok() == Some(*index),
            }) {
                return None;
            }
        }
        _ => return None,
    }
    let value_at = if let Expr::Name(name) = &values[0] {
        (start..cursor)
            .find(|at| matches!(&body[*at], Stmt::Local(names, _) if names[0] == *name))
            .unwrap_or(cursor)
    } else {
        cursor
    };
    if (start..cursor).any(|at| at != value_at && Some(at) != key_temp) {
        return None;
    }
    let value = match &body[value_at] {
        Stmt::Local(_, values) | Stmt::Assign(_, values) => &values[0],
        _ => return None,
    };
    if expr_mentions(value, table) {
        return None;
    }
    Some((value_at, cursor + 1))
}

fn record_prefill(stmt: &Stmt) -> Option<(String, Vec<ConstructorKey>)> {
    let Stmt::Local(names, values) = stmt else {
        return None;
    };
    if names.len() != 1 || values.len() != 1 {
        return None;
    }
    let Expr::Table(fields) = &values[0] else {
        return None;
    };
    if fields.is_empty() {
        return None;
    }
    if fields
        .iter()
        .all(|(key, value)| key.is_none() && matches!(value, Expr::Literal(text) if text == "nil"))
    {
        return Some((
            names[0].clone(),
            (1..=fields.len()).map(ConstructorKey::Index).collect(),
        ));
    }
    let mut keys = Vec::with_capacity(fields.len());
    let mut seen = BTreeSet::new();
    for (key, value) in fields {
        let Some(Expr::Literal(key)) = key else {
            return None;
        };
        let key = key.strip_prefix('"')?.strip_suffix('"')?;
        if !is_identifier(key) || !seen.insert(key) {
            return None;
        }
        if !matches!(value, Expr::Literal(text) if text == "nil" || text.parse::<f64>().is_ok()) {
            return None;
        }
        keys.push(ConstructorKey::Field(key.to_owned()));
    }
    Some((names[0].clone(), keys))
}

fn expr_mentions(expr: &Expr, name: &str) -> bool {
    let mut found = false;
    crate::ast::visit_expr(expr, &mut |e| {
        found |= matches!(e, Expr::Name(n) if n == name);
    });
    found
}

#[cfg(test)]
mod constructor_tests {
    use super::*;

    fn prefill() -> Stmt {
        Stmt::Local(
            vec!["record".into()],
            vec![Expr::Table(vec![
                (
                    Some(Expr::Literal("\"alpha\"".into())),
                    Expr::Literal("0".into()),
                ),
                (
                    Some(Expr::Literal("\"beta\"".into())),
                    Expr::Literal("0".into()),
                ),
            ])],
        )
    }
    fn write(key: &str, value: Expr) -> Stmt {
        Stmt::Assign(
            vec![Expr::Field(Box::new(Expr::name("record")), key.into())],
            vec![value],
        )
    }
    #[test]
    fn fresh_constructor_inlines_ordered_getters_without_a_return_temporary() {
        let mut body = vec![
            prefill(),
            Stmt::Local(
                vec!["alphaValue".into()],
                vec![Expr::Call(Box::new(Expr::Global("alpha".into())), vec![])],
            ),
            write("alpha", Expr::name("alphaValue")),
            write(
                "beta",
                Expr::Call(Box::new(Expr::Global("beta".into())), vec![]),
            ),
            Stmt::Return(vec![Expr::name("record")]),
        ];
        let recovered = recover_record_constructors(&mut body).unwrap();
        assert!(recovered.contains("record"));
        assert_eq!(body.len(), 1);
        let Stmt::Return(values) = &body[0] else {
            panic!("constructor return");
        };
        let Expr::Table(fields) = &values[0] else {
            panic!("constructor table");
        };
        assert!(
            matches!(&fields[0].1, Expr::Call(f, _) if matches!(&**f, Expr::Global(n) if n == "alpha"))
        );
        assert!(
            matches!(&fields[1].1, Expr::Call(f, _) if matches!(&**f, Expr::Global(n) if n == "beta"))
        );
    }
    #[test]
    fn constructor_fold_refuses_escape_reordered_keys_and_captured_self() {
        let mut cases = vec![
            vec![
                prefill(),
                Stmt::Call(Expr::Call(
                    Box::new(Expr::Global("observe".into())),
                    vec![Expr::name("record")],
                )),
                write("alpha", Expr::Literal("1".into())),
                write("beta", Expr::Literal("2".into())),
            ],
            vec![
                prefill(),
                write("beta", Expr::Literal("2".into())),
                write("alpha", Expr::Literal("1".into())),
            ],
            vec![
                prefill(),
                write(
                    "alpha",
                    Expr::Function(Box::new(Function {
                        origin: None,
                        parameters: vec![],
                        vararg: false,
                        body: vec![Stmt::Return(vec![Expr::name("record")])],
                    })),
                ),
                write("beta", Expr::Literal("2".into())),
            ],
        ];
        for body in &mut cases {
            let before = crate::format::format(body, &Config::default()).unwrap();
            assert!(recover_record_constructors(body).unwrap().is_empty());
            assert_eq!(
                crate::format::format(body, &Config::default()).unwrap(),
                before
            );
        }
    }
    #[test]
    fn array_constructor_retains_capacity_and_scalarizes_its_final_call() {
        let mut body = vec![
            Stmt::Local(
                vec!["values".into()],
                vec![Expr::Table(vec![
                    (None, Expr::Literal("nil".into())),
                    (None, Expr::Literal("nil".into())),
                ])],
            ),
            Stmt::Do(vec![
                Stmt::Assign(
                    vec![Expr::Index(
                        Box::new(Expr::name("values")),
                        Box::new(Expr::Literal("1".into())),
                    )],
                    vec![Expr::Literal("7".into())],
                ),
                Stmt::Assign(
                    vec![Expr::Index(
                        Box::new(Expr::name("values")),
                        Box::new(Expr::Literal("2".into())),
                    )],
                    vec![Expr::Call(
                        Box::new(Expr::Global("multiple".into())),
                        vec![],
                    )],
                ),
            ]),
            Stmt::Return(vec![Expr::name("values")]),
        ];
        assert!(recover_record_constructors(&mut body)
            .unwrap()
            .contains("values"));
        let Stmt::Return(values) = &body[0] else {
            panic!("array return");
        };
        let Expr::Table(fields) = &values[0] else {
            panic!("array constructor");
        };
        assert_eq!(fields.len(), 2);
        assert!(fields.iter().all(|(key, _)| key.is_none()));
        assert!(matches!(&fields[1].1, Expr::Single(value) if matches!(&**value, Expr::Call(..))));
    }
}
fn single_use_root_closures(module: &Module, cfg: &Cfg) -> (bool, BTreeSet<usize>) {
    let mut indegrees = vec![0usize; cfg.blocks.len()];
    let mut reachable = 0usize;
    for block in cfg.blocks.iter().filter(|b| b.reachable) {
        reachable += 1;
        for &next in &block.successors {
            indegrees[next] += 1;
        }
    }
    let mut pending: Vec<_> = cfg
        .blocks
        .iter()
        .enumerate()
        .filter_map(|(id, block)| (block.reachable && indegrees[id] == 0).then_some(id))
        .collect();
    let mut visited = 0usize;
    while let Some(id) = pending.pop() {
        visited += 1;
        for &next in &cfg.blocks[id].successors {
            indegrees[next] -= 1;
            if indegrees[next] == 0 {
                pending.push(next);
            }
        }
    }
    if visited != reachable {
        return (false, BTreeSet::new());
    }
    let mut counts = BTreeMap::<usize, usize>::new();
    for i in &module.protos[module.main].code {
        if i.op == Opcode::DupClosure {
            *counts.entry(i.d() as usize).or_default() += 1;
        }
    }
    (
        true,
        counts
            .into_iter()
            .filter_map(|(constant, count)| (count == 1).then_some(constant))
            .collect(),
    )
}

fn analyze_prototypes(module: &Module, config: &Config) -> Result<Vec<Analysis>> {
    let weights: Vec<usize> = module
        .protos
        .iter()
        .map(|proto| {
            let mut branches = 0usize;
            let mut wide_definitions = 0usize;
            for (index, i) in proto.code.iter().enumerate() {
                if cfg::jump_target(i).is_some() {
                    branches = branches.saturating_add(2);
                } else if i.op == Opcode::Return && index + 1 < proto.code.len() {
                    branches = branches.saturating_add(1);
                }
                let count = match i.op {
                    Opcode::Call => i.c().saturating_sub(1),
                    Opcode::GetVarargs => i.b().saturating_sub(1),
                    Opcode::ForGLoop => i.aux.unwrap_or(0) as usize & 255,
                    _ => 0,
                };
                wide_definitions = wide_definitions.saturating_add(count.saturating_sub(1));
            }
            let blocks = branches.saturating_add(1).min(proto.code.len());
            proto
                .code
                .len()
                .saturating_mul(4)
                .saturating_add(
                    blocks
                        .saturating_mul(proto.max_stack as usize)
                        .saturating_mul(8),
                )
                .saturating_add(wide_definitions.saturating_mul(4))
                .saturating_add(blocks.saturating_mul(4))
        })
        .collect();
    let total = weights
        .iter()
        .fold(0usize, |n, &weight| n.saturating_add(weight));
    if total == 0 || total > config.limits.max_analysis_steps {
        return Err(Error::new(
            "limit",
            "aggregate function-analysis storage/work estimate exceeds max_analysis_steps",
        ));
    }
    let spare = config.limits.max_analysis_steps - total;
    crate::execution::charge_work(total)?;
    let context = crate::execution::current_context();
    let analyze = |(pid, proto): (usize, &Proto)| -> Result<Analysis> {
        let work = || {
            crate::execution::checkpoint()?;
            let mut limits = config.limits.clone();
            limits.max_analysis_steps =
                weights[pid] + ((spare as u128 * weights[pid] as u128) / total as u128) as usize;
            let cfg = Cfg::build(proto, &limits).map_err(|e| e.at_proto(pid))?;
            let ssa = Ssa::analyze(proto, &cfg, &limits).map_err(|e| e.at_proto(pid))?;
            let bindings = RecoveredBindings::analyze(proto, &cfg, &ssa, &limits)
                .map_err(|e| e.at_proto(pid))?;
            Ok((Arc::new(cfg), Arc::new(ssa), Arc::new(bindings)))
        };
        if let Some(context) = context.clone() {
            crate::execution::with_context(context, work)
        } else {
            work()
        }
    };
    let results: Vec<Result<Analysis>> =
        if module.protos.len() >= 16 && rayon::current_thread_index().is_some() {
            use rayon::prelude::*;
            module.protos.par_iter().enumerate().map(analyze).collect()
        } else {
            module.protos.iter().enumerate().map(analyze).collect()
        };
    results.into_iter().collect()
}

fn raw_equality_function(names: &mut NameAllocator) -> Function {
    let a = names.allocate("left_capture");
    let b = names.allocate("right_capture");
    let map = names.allocate("identity_lookup");
    let eqnil = Expr::binary(
        "or",
        Expr::binary("==", Expr::name(&a), nil()),
        Expr::binary("==", Expr::name(&b), nil()),
    );
    let nan = Expr::binary(
        "or",
        Expr::binary("~=", Expr::name(&a), Expr::name(&a)),
        Expr::binary("~=", Expr::name(&b), Expr::name(&b)),
    );
    Function {
        origin: None,
        parameters: vec![a.clone(), b.clone()],
        vararg: false,
        body: vec![
            Stmt::If {
                condition: eqnil,
                yes: vec![Stmt::Return(vec![Expr::binary(
                    "==",
                    Expr::name(&a),
                    Expr::name(&b),
                )])],
                no: Vec::new(),
            },
            Stmt::If {
                condition: nan,
                yes: vec![Stmt::Return(vec![Expr::Literal("false".into())])],
                no: Vec::new(),
            },
            Stmt::Local(
                vec![map.clone()],
                vec![Expr::Table(vec![(
                    Some(Expr::name(&a)),
                    Expr::Literal("true".into()),
                )])],
            ),
            Stmt::Return(vec![Expr::binary(
                "==",
                Expr::Index(Box::new(Expr::name(&map)), Box::new(Expr::name(&b))),
                Expr::Literal("true".into()),
            )]),
        ],
    }
}

fn build_function(
    module: &Module,
    config: &Config,
    shared: &mut Shared,
    pid: usize,
    upvalues: Vec<Upvalue>,
    depth: usize,
) -> Result<Function> {
    if depth > config.limits.max_depth {
        return Err(Error::new("limit", "closure nesting limit exceeded").at_proto(pid));
    }
    let proto = &module.protos[pid];
    shared.expanded_instructions = shared
        .expanded_instructions
        .checked_add(proto.code.len())
        .ok_or_else(|| Error::new("limit", "prototype expansion overflow"))?;
    shared.charge(
        proto.code.len().saturating_add(proto.max_stack as usize),
        config,
    )?;
    shared.text_bytes = shared
        .text_bytes
        .saturating_add(shared.proto_text_cost[pid]);
    if shared.text_bytes > config.limits.max_output_bytes {
        return Err(Error::new(
            "limit",
            "expanded source text estimate exceeds output byte budget before AST allocation",
        )
        .at_proto(pid));
    }
    crate::execution::reserve_ast_capacity(shared.proto_text_cost[pid].saturating_mul(2))?;
    if upvalues.len() != proto.num_upvalues as usize {
        return Err(
            Error::new("structure", "upvalue context does not match prototype").at_proto(pid),
        );
    }
    let (cfg, ssa, bindings) = &shared.analyses[pid];
    let cfg = Arc::clone(cfg);
    let ssa = Arc::clone(ssa);
    let bindings = Arc::clone(bindings);
    let mut captured = vec![false; proto.max_stack as usize];
    for i in &proto.code {
        if i.op == Opcode::Capture && i.a() == 1 {
            captured[i.b()] = true;
        }
    }
    let mut proof_steps = 0;
    let mut proof_memo = BTreeMap::new();
    let native: Vec<_> = (0..captured.len())
        .map(|r| {
            captured[r]
                && proto.code.iter().enumerate().all(|(index, i)| {
                    i.op != Opcode::CloseUpvals
                        || i.a() > r
                        || proto
                            .code
                            .get(index + 1)
                            .is_some_and(|next| next.op == Opcode::Return)
                })
                && native_register_capture_routes(
                    module,
                    pid,
                    r,
                    0,
                    &mut proof_steps,
                    config.limits.max_analysis_steps,
                    &mut proof_memo,
                )
        })
        .collect();
    shared.charge(proof_steps, config)?;
    let mut binding_registers = Vec::with_capacity(bindings.bindings.len());
    let mut protected = BTreeSet::new();
    let mut observable = BTreeSet::new();
    for upvalue in &upvalues {
        if upvalue.native {
            if let Expr::Name(name) = &upvalue.value {
                observable.insert(name.clone());
            }
        }
    }
    if config.naming_options.infer_descriptive_names {
        shared.charge(
            proto
                .code
                .iter()
                .filter(|i| i.op == Opcode::Call)
                .count()
                .saturating_mul(16),
            config,
        )?;
    }
    for binding in &bindings.bindings {
        let r = binding.register;
        let cell = captured[r] && !native[r];
        let hint = config
            .naming_options
            .use_debug_names
            .then(|| {
                binding
                    .debug_name
                    .as_ref()
                    .map(|name| name.chars().take(128).collect::<String>())
            })
            .flatten()
            .unwrap_or_else(|| {
                if config.naming_options.infer_descriptive_names {
                    infer_hint_at(
                        module,
                        proto,
                        &ssa,
                        r,
                        binding.first_pc,
                        binding.parameter,
                        config.naming_options.use_debug_names,
                    )
                } else if binding.parameter {
                    format!("argument_{}", r + 1)
                } else {
                    format!("local_{}", binding.id + 1)
                }
            });
        let identity = format!("p{pid}:b{}", binding.id);
        let register_key = format!("p{pid}:r{r}");
        let legacy = (bindings.first_for_register[r] == binding.id)
            .then(|| config.name_overrides.get(&register_key))
            .flatten();
        if legacy.is_some() && config.name_overrides.contains_key(&identity) {
            return Err(Error::new(
                "names",
                format!("overrides {register_key} and {identity} refer to the same binding"),
            )
            .at_proto(pid));
        }
        let override_name = config.name_overrides.get(&identity).or(legacy);
        let name = if let Some(name) = override_name {
            name.clone()
        } else {
            shared.names.allocate(&hint)
        };
        if binding.debug_name.is_some() || cell || override_name.is_some() {
            protected.insert(name.clone());
        }
        if captured[r] {
            observable.insert(name.clone());
        }
        crate::execution::reserve_ast_capacity(
            std::mem::size_of::<RecoveredBindingInfo>()
                .saturating_mul(2)
                .saturating_add(name.len().saturating_mul(3))
                .saturating_add(binding.debug_name.as_ref().map_or(0, String::len)),
        )?;
        shared.recovered_bindings.push(RecoveredBindingInfo {
            proto: pid,
            id: binding.id,
            register: r,
            first_pc: binding.first_pc,
            last_pc: binding.last_pc,
            name: name.clone(),
            debug_name: binding.debug_name.clone(),
            parameter: binding.parameter,
            captured: captured[r],
            capture_mode: if cell {
                "cell"
            } else if captured[r] {
                "native"
            } else {
                "none"
            },
        });
        binding_registers.push(Register {
            name,
            cell,
            captured: captured[r],
        });
    }
    for key in config
        .name_overrides
        .keys()
        .filter(|key| key.starts_with(&format!("p{pid}:b")))
    {
        let id: usize = key.split_once(":b").unwrap().1.parse().unwrap();
        if id >= bindings.bindings.len() {
            return Err(Error::new(
                "names",
                format!("override {key} refers to an absent binding"),
            )
            .at_proto(pid));
        }
    }
    let registers: Vec<_> = bindings
        .first_for_register
        .iter()
        .map(|&id| binding_registers[id].clone())
        .collect();
    let mut binding_cost = 0usize;
    for (index, effect) in ssa.effects.iter().enumerate() {
        for r in effect.reads.union(effect.writes).registers() {
            let reg = &binding_registers[bindings.read(&ssa, index, r)];
            binding_cost =
                binding_cost.saturating_add(reg.name.len() + if reg.cell { 6 } else { 0 });
        }
    }
    shared.text_bytes = shared.text_bytes.saturating_add(binding_cost);
    if shared.text_bytes > config.limits.max_output_bytes {
        return Err(Error::new(
            "limit",
            "expanded binding text estimate exceeds output byte budget",
        )
        .at_proto(pid));
    }
    crate::execution::reserve_ast_capacity(binding_cost.saturating_mul(2))?;
    let mut parameters = Vec::new();
    for reg in registers.iter().take(proto.num_params as usize) {
        parameters.push(if reg.cell {
            shared.names.allocate(&format!("{}_argument", reg.name))
        } else {
            reg.name.clone()
        });
    }
    let mut loops: BTreeMap<usize, Vec<usize>> = BTreeMap::new();
    for &(tail, head) in &cfg.back_edges {
        let index = cfg.blocks[tail].end - 1;
        let op = proto.code[index].op;
        if matches!(op, Opcode::Jump | Opcode::JumpBack | Opcode::JumpX) || cfg::is_conditional(op)
        {
            loops.entry(cfg.blocks[head].start).or_default().push(index);
        }
    }
    for tails in loops.values_mut() {
        tails.sort_unstable();
    }
    let count = proto.code.len();
    let mut builder = Builder {
        module,
        config,
        shared,
        pid,
        proto,
        cfg,
        ssa,
        bindings,
        binding_registers,
        registers,
        upvalues,
        covered: vec![false; count],
        loops,
        depth,
        current_index: 0,
        deferred_tables: BTreeMap::new(),
    };
    let snapshot =
        if builder.cfg.blocks.len() > 1 && config.control_flow == crate::ControlFlowMode::Auto {
            crate::execution::reserve_ast_capacity(builder.shared.text_bytes.saturating_mul(2))?;
            Some(builder.shared.clone())
        } else {
            None
        };
    let attempt = if config.control_flow == crate::ControlFlowMode::Dispatcher {
        builder.dispatcher()
    } else {
        builder.region(0, count, None, None, 0)
    };
    let mut body = match attempt {
        Err(error)
            if config.control_flow == crate::ControlFlowMode::Auto
                && error.proto == Some(pid)
                && is_cfg_shape_error(&error) =>
        {
            let Some(snapshot) = snapshot else {
                return Err(error);
            };
            *builder.shared = snapshot;
            builder.covered.fill(false);
            builder.deferred_tables.clear();
            builder.dispatcher()?
        }
        result => result?,
    };
    if config.control_flow == crate::ControlFlowMode::Dispatcher {
        builder.shared.fallback_prototypes.insert(pid);
    }
    for (index, &covered) in builder.covered.iter().enumerate() {
        if builder.cfg.blocks[builder.cfg.instruction_block[index]].reachable && !covered {
            return Err(builder.error(
                index,
                "reachable instruction was not consumed by reconstruction",
            ));
        }
    }
    if !builder.deferred_tables.is_empty() {
        return Err(Error::new(
            "structure",
            "deferred constructor initializer was not consumed",
        )
        .at_proto(pid));
    }
    crate::format::validate_shape(&body, config)?;
    let optimizer_work = ast::optimize_checked(
        &mut body,
        &protected,
        &observable,
        config
            .limits
            .max_analysis_steps
            .saturating_sub(builder.shared.steps),
    )?;
    builder.shared.charge(optimizer_work, config)?;
    let used = ast::collect_names(&body);
    let mut declarations = Vec::new();
    let mut direct = BTreeSet::new();
    for (r, reg) in builder.registers.iter().enumerate() {
        if !used.contains_key(&reg.name) {
            continue;
        }
        if reg.cell {
            let fields = if r < parameters.len() {
                vec![(
                    Some(Expr::Literal(quote(b"value"))),
                    Expr::name(&parameters[r]),
                )]
            } else {
                Vec::new()
            };
            declarations.push(Stmt::Local(
                vec![reg.name.clone()],
                vec![Expr::Table(fields)],
            ));
        }
    }
    for (id, reg) in builder.binding_registers.iter().enumerate() {
        if !reg.cell && !builder.bindings.bindings[id].parameter && used.contains_key(&reg.name) {
            direct.insert(reg.name.clone());
        }
    }
    if builder.shared.fallback_prototypes.contains(&pid) {
        if !direct.is_empty() {
            declarations.push(Stmt::Local(direct.into_iter().collect(), Vec::new()));
        }
    } else {
        ast::place_declarations(&mut body, direct);
    }
    declarations.extend(body);
    let scope_work = ast::close_temporary_scopes(
        &mut declarations,
        config
            .limits
            .max_analysis_steps
            .saturating_sub(builder.shared.steps),
    )?;
    builder.shared.charge(scope_work, config)?;
    Ok(Function {
        origin: Some(pid),
        parameters,
        vararg: proto.is_vararg,
        body: declarations,
    })
}

fn is_cfg_shape_error(error: &Error) -> bool {
    error.stage == "structure"
        && [
            "structured-region boundary",
            "unsupported structured region",
            "overlapping control-flow regions",
            "reachable instruction was not consumed",
            "LOADB skip crosses",
            "loop extends outside",
            "loop backedge was not paired",
        ]
        .iter()
        .any(|text| error.message.contains(text))
}

fn safe_thread_environment_reference(
    proto: &Proto,
    ssa: &Ssa,
    index: usize,
    budget: usize,
) -> bool {
    fn zero(
        proto: &Proto,
        ssa: &Ssa,
        value: usize,
        depth: usize,
        steps: &mut usize,
        budget: usize,
    ) -> bool {
        if depth > 64 || *steps >= budget {
            return false;
        }
        *steps += 1;
        match &ssa.definitions[value] {
            crate::dataflow::Definition::Instruction { index, .. } => {
                let i = proto.code[*index];
                match i.op {
                    Opcode::LoadN => i.d() == 0,
                    Opcode::LoadK => {
                        matches!(proto.constants[i.d()as usize],Constant::Number(n) if n==0.0)
                    }
                    Opcode::Move => zero(
                        proto,
                        ssa,
                        ssa.read_definition(*index, i.b()).unwrap(),
                        depth + 1,
                        steps,
                        budget,
                    ),
                    _ => false,
                }
            }
            crate::dataflow::Definition::Phi { incoming, .. } => {
                !incoming.is_empty()
                    && incoming
                        .iter()
                        .all(|(_, value)| zero(proto, ssa, *value, depth + 1, steps, budget))
            }
            _ => false,
        }
    }
    let Some(value) = ssa.write_definition(index, proto.code[index].a()) else {
        return false;
    };
    let mut values = BTreeSet::from([value]);
    let mut steps = 0;
    let mut changed = true;
    while changed {
        changed = false;
        for (index, effect) in ssa.effects.iter().enumerate() {
            if steps >= budget {
                return false;
            }
            steps += 1;
            for r in effect.reads.registers() {
                if !values.contains(&ssa.read_definition(index, r).unwrap()) {
                    continue;
                }
                let i = proto.code[index];
                if i.op == Opcode::Move && i.b() == r {
                    changed |= values.insert(ssa.write_definition(index, i.a()).unwrap());
                } else if i.op == Opcode::Call && i.a() == r && i.b() == 2 {
                    if !zero(
                        proto,
                        ssa,
                        ssa.read_definition(index, r + 1).unwrap(),
                        0,
                        &mut steps,
                        budget,
                    ) {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        }
    }
    !ssa.definitions.iter().any(|definition| matches!(definition,crate::dataflow::Definition::Phi {incoming,..} if incoming.iter().any(|(_,value)|values.contains(value))))
}

fn native_register_capture_routes(
    module: &Module,
    pid: usize,
    register: usize,
    depth: usize,
    steps: &mut usize,
    budget: usize,
    memo: &mut BTreeMap<(usize, usize), bool>,
) -> bool {
    let proto = &module.protos[pid];
    proto.code.iter().enumerate().all(|(index, i)| {
        if *steps >= budget {
            return false;
        }
        *steps += 1;
        if !matches!(i.op, Opcode::NewClosure | Opcode::DupClosure) {
            return true;
        }
        let child = if i.op == Opcode::NewClosure {
            proto.children[i.d() as usize]
        } else if let Constant::Closure(child) = proto.constants[i.d() as usize] {
            child
        } else {
            return false;
        };
        (0..module.protos[child].num_upvalues as usize).all(|upvalue| {
            let capture = &proto.code[index + 1 + upvalue];
            capture.a() != 1
                || capture.b() != register
                || native_upvalue_routes(module, child, upvalue, depth + 1, steps, budget, memo)
        })
    })
}

fn native_upvalue_routes(
    module: &Module,
    pid: usize,
    upvalue: usize,
    depth: usize,
    steps: &mut usize,
    budget: usize,
    memo: &mut BTreeMap<(usize, usize), bool>,
) -> bool {
    if depth > 64 {
        return false;
    }
    if let Some(&result) = memo.get(&(pid, upvalue)) {
        return result;
    }
    let proto = &module.protos[pid];
    let result = proto.code.iter().enumerate().all(|(index, i)| {
        if *steps >= budget {
            return false;
        }
        *steps += 1;
        if !matches!(i.op, Opcode::NewClosure | Opcode::DupClosure) {
            return true;
        }
        let child = if i.op == Opcode::NewClosure {
            proto.children[i.d() as usize]
        } else if let Constant::Closure(child) = proto.constants[i.d() as usize] {
            child
        } else {
            return false;
        };
        (0..module.protos[child].num_upvalues as usize).all(|n| {
            let capture = &proto.code[index + 1 + n];
            capture.a() != 2
                || capture.b() != upvalue
                || (i.op != Opcode::DupClosure
                    && native_upvalue_routes(module, child, n, depth + 1, steps, budget, memo))
        })
    });
    memo.insert((pid, upvalue), result);
    result
}

fn infer_hint_at(
    module: &Module,
    proto: &Proto,
    ssa: &Ssa,
    r: usize,
    first_pc: usize,
    parameter: bool,
    use_debug_names: bool,
) -> String {
    if parameter {
        return format!("argument_{}", r + 1);
    }
    let first = proto.code.partition_point(|i| i.pc < first_pc);
    if let Some(i) = proto.code.get(first).filter(|i| i.a() == r) {
        match i.op {
            Opcode::Call => {
                if let Some(hint) = call_result_hint(module, proto, ssa, first) {
                    return hint;
                }
            }
            Opcode::GetGlobal | Opcode::GetTableKs => {
                if let Ok(s) = constant_string(module, proto, i.aux.unwrap_or(0) as usize) {
                    if let Ok(s) = std::str::from_utf8(s) {
                        return format!("{s}_value");
                    }
                }
            }
            Opcode::GetImport => {
                let aux = i.aux.unwrap_or(0);
                let count = aux >> 30;
                let shift = if count == 1 {
                    20
                } else if count == 2 {
                    10
                } else {
                    0
                };
                if let Ok(s) = constant_string(module, proto, ((aux >> shift) & 1023) as usize) {
                    if let Ok(s) = std::str::from_utf8(s) {
                        return format!("{s}_value");
                    }
                }
            }
            Opcode::NewTable | Opcode::DupTable => return format!("table_{}", r + 1),
            Opcode::NewClosure if use_debug_names => {
                if let Some(child) = proto
                    .children
                    .get(i.d() as usize)
                    .and_then(|&id| module.protos.get(id))
                {
                    if let Some(name) = &child.debug_name {
                        return name.clone();
                    }
                }
            }
            Opcode::DupClosure if use_debug_names => {
                if let Some(Constant::Closure(id)) = proto.constants.get(i.d() as usize) {
                    if let Some(name) = &module.protos[*id].debug_name {
                        return name.clone();
                    }
                }
            }
            _ => {}
        }
    }
    format!("value_{}", r + 1)
}
fn naming_origin<'a>(
    proto: &'a Proto,
    ssa: &Ssa,
    index: usize,
    register: usize,
) -> Option<&'a Instruction> {
    let mut definition = ssa.read_definition(index, register)?;
    for _ in 0..16 {
        let crate::dataflow::Definition::Instruction { index, .. } =
            ssa.definitions.get(definition)?
        else {
            return None;
        };
        let instruction = proto.code.get(*index)?;
        if instruction.op == Opcode::Move {
            definition = ssa.read_definition(*index, instruction.b())?;
        } else {
            return Some(instruction);
        }
    }
    None
}

fn call_result_hint(module: &Module, proto: &Proto, ssa: &Ssa, index: usize) -> Option<String> {
    let call = proto.code.get(index)?;
    let origin = naming_origin(proto, ssa, index, call.a())?;
    let method = match origin.op {
        Opcode::GetGlobal | Opcode::GetTableKs | Opcode::NameCall => {
            constant_string(module, proto, origin.aux? as usize).ok()?
        }
        Opcode::GetImport => {
            let aux = origin.aux?;
            let count = aux >> 30;
            let shift = match count {
                1 => 20,
                2 => 10,
                3 => 0,
                _ => return None,
            };
            constant_string(module, proto, ((aux >> shift) & 1023) as usize).ok()?
        }
        _ => return None,
    };
    let method = std::str::from_utf8(method).ok()?;
    if method.len() > 128 {
        return None;
    }
    if origin.op == Opcode::NameCall {
        if matches!(
            method,
            "GetService" | "GetAttribute" | "FindFirstChild" | "WaitForChild"
        ) {
            let argument = naming_origin(proto, ssa, index, call.a() + 2)?;
            let constant = match argument.op {
                Opcode::LoadK => argument.d() as usize,
                Opcode::LoadKx => argument.aux? as usize,
                _ => return Some(format!("{method}_result")),
            };
            if let Ok(bytes) = constant_string(module, proto, constant) {
                if let Ok(key) = std::str::from_utf8(bytes) {
                    if key.len() <= 128 && is_identifier(key) {
                        return Some(match method {
                            "GetService" if key.ends_with("Service") => key.to_owned(),
                            "GetService" => format!("{key}_service"),
                            "GetAttribute" => format!("{key}_value"),
                            _ => format!("{key}_child"),
                        });
                    }
                }
            }
        }
        return Some(match method {
            "Connect" | "Once" => "connection".into(),
            "GetChildren" => "children".into(),
            "GetDescendants" => "descendants".into(),
            "GetPivot" => "pivot".into(),
            "Clone" => "cloned_value".into(),
            _ => format!("{method}_result"),
        });
    }
    Some(format!("{method}_result"))
}
fn nil() -> Expr {
    Expr::Literal("nil".into())
}
fn number(n: f64) -> Expr {
    Expr::Literal(if n == f64::INFINITY {
        "(1 / 0)".into()
    } else if n == f64::NEG_INFINITY {
        "(-1 / 0)".into()
    } else if n == 0.0 && n.is_sign_negative() {
        "-0.0".into()
    } else {
        n.to_string()
    })
}
fn constant_string<'a>(module: &'a Module, proto: &Proto, index: usize) -> Result<&'a [u8]> {
    match proto.constants.get(index) {
        Some(Constant::String(id)) => module
            .strings
            .get(*id)
            .map(Vec::as_slice)
            .ok_or_else(|| Error::new("structure", "string constant references missing string")),
        _ => Err(Error::new(
            "structure",
            format!("constant k{index} is not a string"),
        )),
    }
}

#[derive(Clone, Copy)]
struct Loop {
    header: usize,
    continue_at: usize,
    end: usize,
}
struct Open {
    base: usize,
    value: Expr,
}
struct Builder<'a> {
    module: &'a Module,
    config: &'a Config,
    shared: &'a mut Shared,
    pid: usize,
    proto: &'a Proto,
    cfg: Arc<Cfg>,
    ssa: Arc<Ssa>,
    bindings: Arc<RecoveredBindings>,
    binding_registers: Vec<Register>,
    registers: Vec<Register>,
    upvalues: Vec<Upvalue>,
    covered: Vec<bool>,
    loops: BTreeMap<usize, Vec<usize>>,
    depth: usize,
    current_index: usize,
    deferred_tables: BTreeMap<usize, (usize, usize)>,
}
impl Builder<'_> {
    fn capture_open(&self, index: usize, r: usize) -> bool {
        self.ssa.open_captures_before[index].contains(r)
    }
    fn dispatcher(&mut self) -> Result<Vec<Stmt>> {
        let state = self.shared.names.allocate("control_state");
        let mut cases = Vec::new();
        let mut native_regions = BTreeMap::new();
        let mut contained = BTreeSet::new();
        for id in 0..self.cfg.blocks.len() {
            if !self.cfg.blocks[id].reachable || contained.contains(&id) {
                continue;
            }
            let block = &self.cfg.blocks[id];
            let prep = block.end - 1;
            let instruction = self.proto.code[prep];
            if !matches!(
                instruction.op,
                Opcode::ForNPrep | Opcode::ForGPrep | Opcode::ForGPrepInext | Opcode::ForGPrepNext
            ) {
                continue;
            }
            let target = self.target(prep)?;
            let numeric = instruction.op == Opcode::ForNPrep;
            let (tail, exit) = if numeric {
                (
                    target.checked_sub(1).ok_or_else(|| {
                        self.error(prep, "native dispatcher loop exit precedes its body")
                    })?,
                    target,
                )
            } else {
                (target, target + 1)
            };
            if tail <= prep
                || exit >= self.proto.code.len()
                || self.proto.code[tail].a() != instruction.a()
                || self.proto.code[tail].op
                    != if numeric {
                        Opcode::ForNLoop
                    } else {
                        Opcode::ForGLoop
                    }
                || self.target(tail)? != prep + 1
            {
                return Err(self.error(
                    prep,
                    "dispatcher native for-loop does not match its preparation/backedge",
                ));
            }
            let exit_block = self.cfg.instruction_block[exit];
            if self.cfg.blocks[exit_block].start != exit || exit_block <= id {
                return Err(self.error(
                    prep,
                    "dispatcher native for-loop exit is not a following block boundary",
                ));
            }
            for inner in id..exit_block {
                self.shared.charge(1, self.config)?;
                if !self.cfg.blocks[inner].reachable {
                    continue;
                }
                if inner != id
                    && self.cfg.blocks[inner]
                        .predecessors
                        .iter()
                        .any(|&previous| previous < id || previous >= exit_block)
                {
                    return Err(self.error(
                        prep,
                        "dispatcher native for-loop has an external entry into its body",
                    ));
                }
                if self.cfg.blocks[inner]
                    .successors
                    .iter()
                    .any(|&next| (next < id || next >= exit_block) && next != exit_block)
                {
                    return Err(self.error(
                        prep,
                        "dispatcher native for-loop has an unproved nonlocal exit",
                    ));
                }
            }
            native_regions.insert(id, exit);
            contained.extend(id + 1..exit_block);
        }
        for id in 0..self.cfg.blocks.len() {
            if !self.cfg.blocks[id].reachable || contained.contains(&id) {
                continue;
            }
            let block = &self.cfg.blocks[id];
            let (start, end) = (block.start, block.end);
            if let Some(&exit) = native_regions.get(&id) {
                let mut body = self.region(start, exit, None, None, 0)?;
                body.push(Stmt::Assign(
                    vec![Expr::name(&state)],
                    vec![number(self.cfg.instruction_block[exit] as f64)],
                ));
                cases.push((id, body));
                continue;
            }
            let last = end - 1;
            let i = self.proto.code[last];
            if matches!(
                i.op,
                Opcode::ForNPrep
                    | Opcode::ForNLoop
                    | Opcode::ForGPrep
                    | Opcode::ForGPrepInext
                    | Opcode::ForGPrepNext
                    | Opcode::ForGLoop
            ) {
                return Err(self.error(last,"dispatcher fallback requires native for-loop region recovery; VM control registers cannot be approximated"));
            }
            let branch = cfg::is_conditional(i.op)
                || cfg::is_unconditional(i.op)
                || (i.op == Opcode::LoadB && i.c() != 0);
            let mut body = self.region(start, if branch { last } else { end }, None, None, 0)?;
            self.current_index = last;
            if branch {
                self.cover(last)?;
                if i.op == Opcode::LoadB {
                    body.push(self.assign(i.a(), Expr::Literal((i.b() != 0).to_string())));
                }
                let target = self.cfg.instruction_block[self.target(last)?];
                let next = if cfg::is_conditional(i.op) {
                    Expr::IfElse(
                        Box::new(self.condition(last)?),
                        Box::new(number(target as f64)),
                        Box::new(number(self.cfg.instruction_block[last + 1] as f64)),
                    )
                } else {
                    number(target as f64)
                };
                body.push(Stmt::Assign(vec![Expr::name(&state)], vec![next]));
            } else if i.op != Opcode::Return {
                let successor = self.cfg.blocks[id].successors[0];
                body.push(Stmt::Assign(
                    vec![Expr::name(&state)],
                    vec![number(successor as f64)],
                ));
            }
            cases.push((id, body));
        }
        fn decision(state: &str, cases: &[(usize, Vec<Stmt>)]) -> Vec<Stmt> {
            if cases.len() == 1 {
                return cases[0].1.clone();
            }
            let middle = cases.len() / 2;
            vec![Stmt::If {
                condition: Expr::binary("<", Expr::name(state), number(cases[middle].0 as f64)),
                yes: decision(state, &cases[..middle]),
                no: decision(state, &cases[middle..]),
            }]
        }
        self.shared.fallback_prototypes.insert(self.pid);
        Ok(vec![
            Stmt::Local(vec![state.clone()], vec![number(0.0)]),
            Stmt::While {
                condition: Expr::Literal("true".into()),
                body: decision(&state, &cases),
            },
        ])
    }
    fn error(&self, index: usize, message: impl Into<String>) -> Error {
        Error::new("structure", message)
            .at_proto(self.pid)
            .at_pc(self.proto.code[index].pc)
    }
    fn r(&self, r: usize) -> Expr {
        self.r_at(self.current_index, r)
    }
    fn r_at(&self, index: usize, r: usize) -> Expr {
        self.binding_registers[self.bindings.read(&self.ssa, index, r)].value()
    }
    fn w(&self, r: usize) -> Expr {
        self.w_at(self.current_index, r)
    }
    fn w_at(&self, index: usize, r: usize) -> Expr {
        self.binding_registers[self.bindings.write(&self.ssa, index, r)].value()
    }
    fn assign(&self, r: usize, value: Expr) -> Stmt {
        Stmt::Assign(vec![self.w(r)], vec![value])
    }
    fn target(&self, index: usize) -> Result<usize> {
        let pc = cfg::jump_target(&self.proto.code[index])
            .ok_or_else(|| self.error(index, "instruction has no valid jump target"))?;
        self.proto
            .code
            .binary_search_by_key(&pc, |i| i.pc)
            .map_err(|_| self.error(index, "jump target is not an instruction header"))
    }
    fn cover(&mut self, index: usize) -> Result<()> {
        if self.covered[index] {
            return Err(self.error(
                index,
                "overlapping control-flow regions require unsupported duplication",
            ));
        }
        self.covered[index] = true;
        self.shared.charge(1, self.config)
    }
    fn constant(&self, index: usize, at: usize) -> Result<Expr> {
        match &self.proto.constants[index] {
            Constant::Nil => Ok(nil()),
            Constant::Boolean(b) => Ok(Expr::Literal(b.to_string())),
            Constant::Number(n) if n.is_nan() => Err(self.error(
                at,
                "NaN constant payload/sign has no bit-preserving source literal",
            )),
            Constant::Number(n) => Ok(number(*n)),
            Constant::String(id) => Ok(Expr::Literal(quote(&self.module.strings[*id]))),
            Constant::Vector(value) => self.vector_literal(value.map(f64::from), at),
            Constant::VectorDouble(value) => self.vector_literal(*value, at),
            _ => Err(self.error(
                at,
                format!("constant k{index} is a cached VM object, not a source literal"),
            )),
        }
    }
    fn vector_literal(&self, value: [f64; 4], at: usize) -> Result<Expr> {
        let path = self.config.vector_constructor.as_ref().ok_or_else(|| {
            self.error(
                at,
                "vector constants require an explicitly configured trusted intrinsic constructor",
            )
        })?;
        if value[3] != 0.0 {
            return Err(self.error(
                at,
                "four-component vector constants require a four-component VM constructor profile",
            ));
        }
        if value[..3].iter().any(|n| n.is_nan()) {
            return Err(self.error(at,"NaN vector components cannot preserve their exact payload through source construction"));
        }
        let mut parts = path.split('.');
        let mut constructor = Expr::Global(parts.next().unwrap().into());
        for field in parts {
            constructor = Expr::Field(Box::new(constructor), field.into());
        }
        Ok(Expr::Call(
            Box::new(constructor),
            value[..3].iter().copied().map(number).collect(),
        ))
    }
    fn key(&self, object: Expr, index: usize, at: usize) -> Result<Expr> {
        let bytes = constant_string(self.module, self.proto, index)
            .map_err(|e| e.at_proto(self.pid).at_pc(self.proto.code[at].pc))?;
        if let Ok(name) = std::str::from_utf8(bytes) {
            if is_identifier(name) {
                return Ok(Expr::Field(Box::new(object), name.to_owned()));
            }
        }
        Ok(Expr::Index(
            Box::new(object),
            Box::new(Expr::Literal(quote(bytes))),
        ))
    }
    fn condition(&self, index: usize) -> Result<Expr> {
        use Opcode::*;
        let i = &self.proto.code[index];
        let a = self.r_at(index, i.a());
        let aux = i.aux.unwrap_or(0);
        Ok(match i.op {
            JumpIf => a,
            JumpIfNot => a.negate(),
            JumpIfEq | JumpIfNotEq | JumpIfLe | JumpIfNotLe | JumpIfLt | JumpIfNotLt => {
                let op = match i.op {
                    JumpIfEq | JumpIfNotEq => "==",
                    JumpIfLe | JumpIfNotLe => "<=",
                    _ => "<",
                };
                let e = Expr::binary(op, a, self.r_at(index, aux as usize));
                if matches!(i.op, JumpIfNotEq | JumpIfNotLe | JumpIfNotLt) {
                    e.negate()
                } else {
                    e
                }
            }
            JumpXEqKNil | JumpXEqKB | JumpXEqKN | JumpXEqKS => {
                let k = match i.op {
                    JumpXEqKNil => nil(),
                    JumpXEqKB => Expr::Literal((aux & 1 != 0).to_string()),
                    _ => self.constant((aux & 0xffffff) as usize, index)?,
                };
                let e = Expr::binary("==", a, k);
                if aux >> 31 != 0 {
                    e.negate()
                } else {
                    e
                }
            }
            _ => return Err(self.error(index, "not a conditional branch")),
        })
    }
    fn live_before(&self, index: usize) -> RegisterSet {
        if index >= self.proto.code.len() {
            RegisterSet::default()
        } else {
            self.ssa.effects[index]
                .reads
                .union(self.ssa.live_after[index].difference(self.ssa.effects[index].writes))
        }
    }
    fn check_loop_registers(
        &self,
        start: usize,
        tail: usize,
        exit: usize,
        a: usize,
        count: usize,
        numeric: bool,
    ) -> Result<()> {
        for r in a..a + 3 {
            if self.capture_open(tail, r) {
                return Err(self.error(
                    tail,
                    format!("native loop control register r{r} is reference-captured"),
                ));
            }
        }
        let after = self.live_before(exit);
        for r in a..a + count {
            if after.contains(r) {
                return Err(self.error(tail,format!("loop control/result register r{r} is live after loop; native loop reconstruction would lose VM exit state")));
            }
        }
        for index in start..tail {
            for r in a..a + 3 {
                if self.ssa.effects[index].writes.contains(r)
                    || ((!numeric || r != a + 2) && self.ssa.effects[index].reads.contains(r))
                {
                    return Err(self.error(
                        index,
                        format!("loop body observes or modifies hidden control register r{r}"),
                    ));
                }
            }
        }
        Ok(())
    }
    fn builtin_origin(
        &mut self,
        index: usize,
        register: usize,
        depth: usize,
    ) -> Result<Option<String>> {
        let value = self.ssa.reaching_definition(&self.cfg, index, register);
        self.value_provenance(value, depth, true, &mut BTreeSet::new())
    }
    fn literal_register(
        &mut self,
        index: usize,
        register: usize,
        depth: usize,
    ) -> Result<Option<Expr>> {
        if self.capture_open(index, register) {
            return Ok(None);
        }
        let value = self.ssa.reaching_definition(&self.cfg, index, register);
        Ok(self
            .value_provenance(value, depth, false, &mut BTreeSet::new())?
            .map(Expr::Literal))
    }
    fn value_provenance(
        &mut self,
        value: usize,
        depth: usize,
        builtin: bool,
        active: &mut BTreeSet<usize>,
    ) -> Result<Option<String>> {
        self.shared.charge(1, self.config)?;
        if depth > self.config.limits.max_depth || !active.insert(value) {
            return Ok(None);
        }
        let definition = self.ssa.definitions[value].clone();
        let result = match definition {
            crate::dataflow::Definition::Instruction { index, register } => {
                let i = self.proto.code[index];
                if i.a() != register {
                    None
                } else {
                    match i.op {
                        Opcode::Move => {
                            let source = self.ssa.read_definition(index, i.b()).unwrap();
                            self.value_provenance(source, depth + 1, builtin, active)?
                        }
                        Opcode::GetGlobal if builtin => std::str::from_utf8(constant_string(
                            self.module,
                            self.proto,
                            i.aux.unwrap_or(0) as usize,
                        )?)
                        .ok()
                        .map(str::to_owned),
                        Opcode::GetImport if builtin && i.aux.unwrap_or(0) >> 30 == 1 => {
                            std::str::from_utf8(constant_string(
                                self.module,
                                self.proto,
                                ((i.aux.unwrap_or(0) >> 20) & 1023) as usize,
                            )?)
                            .ok()
                            .map(str::to_owned)
                        }
                        Opcode::Call if builtin && i.c() >= 4 => {
                            let source = self.ssa.read_definition(index, i.a()).unwrap();
                            self.value_provenance(source, depth + 1, true, active)?
                                .map(|name| format!("call:{name}"))
                        }
                        Opcode::LoadN if !builtin => match number(i.d() as f64) {
                            Expr::Literal(value) => Some(value),
                            _ => unreachable!(),
                        },
                        Opcode::LoadB if !builtin => Some((i.b() != 0).to_string()),
                        Opcode::LoadNil if !builtin => Some("nil".into()),
                        Opcode::LoadK | Opcode::LoadKx if !builtin => {
                            let constant = if i.op == Opcode::LoadK {
                                i.d() as usize
                            } else {
                                i.aux.unwrap_or(0) as usize
                            };
                            match self.constant(constant, index)? {
                                Expr::Literal(value) => Some(value),
                                _ => None,
                            }
                        }
                        _ => None,
                    }
                }
            }
            crate::dataflow::Definition::Phi { incoming, .. } => {
                let mut same = None;
                let mut agrees = true;
                for (_, value) in incoming {
                    let candidate = self.value_provenance(value, depth + 1, builtin, active)?;
                    if candidate.is_none()
                        || same
                            .as_ref()
                            .is_some_and(|known| Some(known) != candidate.as_ref())
                    {
                        agrees = false;
                        break;
                    }
                    same = candidate;
                }
                if agrees {
                    same
                } else {
                    None
                }
            }
            _ => None,
        };
        active.remove(&value);
        Ok(result)
    }
    fn dynamic_first_store(&mut self, origin: usize) -> Result<Option<usize>> {
        let receiver = self.proto.code[origin].a();
        if self.capture_open(origin, receiver) {
            return Ok(None);
        }
        let origin_block = self.cfg.instruction_block[origin];
        let mut pending = vec![origin_block];
        let mut seen = vec![false; self.cfg.blocks.len()];
        let mut stores = BTreeSet::new();
        while let Some(block) = pending.pop() {
            if seen[block] {
                continue;
            }
            seen[block] = true;
            let start = if block == origin_block {
                origin + 1
            } else {
                self.cfg.blocks[block].start
            };
            let mut stopped = false;
            for index in start..self.cfg.blocks[block].end {
                self.shared.charge(1, self.config)?;
                if self.ssa.effects[index].writes.contains(receiver) {
                    return Ok(None);
                }
                if self.ssa.effects[index].reads.contains(receiver) {
                    let i = self.proto.code[index];
                    if matches!(
                        i.op,
                        Opcode::SetTable | Opcode::SetTableKs | Opcode::SetTableN
                    ) && i.b() == receiver
                        && i.a() != receiver
                        && (i.op != Opcode::SetTable || i.c() != receiver)
                    {
                        stores.insert(index);
                        stopped = true;
                        break;
                    }
                    return Ok(None);
                }
            }
            if !stopped {
                pending.extend(self.cfg.blocks[block].successors.iter().copied());
            }
        }
        Ok((stores.len() == 1).then(|| *stores.first().unwrap()))
    }
    fn first_table_key(&mut self, origin: usize) -> Result<Expr> {
        let receiver = self.proto.code[origin].a();
        if self.capture_open(origin, receiver) {
            return Err(self.error(
                origin,
                "hash reservation target is reference-captured before its first store",
            ));
        }
        let block = self.cfg.instruction_block[origin];
        for index in origin + 1..self.cfg.blocks[block].end {
            self.shared.charge(1, self.config)?;
            if self.ssa.effects[index].writes.contains(receiver) {
                return Err(self.error(
                    origin,
                    "hash-reserved table is overwritten before its first store",
                ));
            }
            if !self.ssa.effects[index].reads.contains(receiver) {
                continue;
            }
            let i = &self.proto.code[index];
            let key=match i.op{
                Opcode::SetTableKs if i.b()==receiver=>Some(Expr::Literal(quote(constant_string(self.module,self.proto,i.aux.unwrap_or(0)as usize)?))),
                Opcode::SetTableN if i.b()==receiver=>Some(number((i.c()+1)as f64)),
                Opcode::SetTable if i.b()==receiver&&i.c()!=receiver=>self.literal_register(index,i.c(),0)?,
                _=>return Err(self.error(origin,"hash-reserved table escapes or receives list writes before its first constant-key store")),
            };
            if let Some(key) = key {
                if !matches!(&key,Expr::Literal(text)if text=="nil") {
                    return Ok(key);
                }
            }
            return Err(self.error(
                origin,
                "hash reservation requires a proven literal first key in the same basic block",
            ));
        }
        Err(self.error(
            origin,
            "hash-reserved table has no provable first store before a control-flow boundary",
        ))
    }
    fn region(
        &mut self,
        start: usize,
        end: usize,
        context: Option<Loop>,
        allowed_exit: Option<usize>,
        nesting: usize,
    ) -> Result<Vec<Stmt>> {
        if nesting > self.config.limits.max_depth {
            return Err(self.error(
                start.min(self.proto.code.len() - 1),
                "structured region nesting limit exceeded",
            ));
        }
        let mut out = Vec::new();
        let mut index = start;
        let mut open: Option<Open> = None;
        while index < end {
            self.current_index = index;
            if !self.cfg.blocks[self.cfg.instruction_block[index]].reachable {
                index += 1;
                continue;
            }
            let i = self.proto.code[index];
            if open.is_some()
                && i.op == Opcode::CloseUpvals
                && self
                    .proto
                    .code
                    .get(index + 1)
                    .is_some_and(|i| i.op == Opcode::Return && i.b() == 0)
            {
                self.cover(index)?;
                index += 1;
                continue;
            }
            if open.is_some()
                && i.op == Opcode::GetImport
                && self.proto.code.get(index + 1).is_some_and(|call| {
                    call.op == Opcode::Call && call.b() == 0 && call.a() == i.a()
                })
            {
                let pending = open.take().unwrap();
                if i.a() >= pending.base {
                    return Err(self.error(
                        index,
                        "open-call import overwrites its pending result range",
                    ));
                }
                if self.capture_open(index, i.a()) {
                    return Err(self.error(index,"open-call import destination is externally observable through a reference capture"));
                }
                let call = self.proto.code[index + 1];
                self.check_open_scratch(index + 1, pending.base)?;
                let callee = self.shared.names.allocate("open_callee");
                let mut setup = Vec::new();
                self.plain(index, &mut setup)?;
                let Stmt::Assign(_, mut rhs) = setup.remove(0) else {
                    return Err(
                        self.error(index, "import continuation did not produce an assignment")
                    );
                };
                let mut args: Vec<_> = (i.a() + 1..pending.base)
                    .map(|r| self.r_at(index + 1, r))
                    .collect();
                args.push(Expr::Vararg);
                let function = Function {
                    origin: None,
                    parameters: Vec::new(),
                    vararg: true,
                    body: vec![
                        Stmt::Local(vec![callee.clone()], vec![rhs.remove(0)]),
                        Stmt::Return(vec![Expr::Call(Box::new(Expr::name(&callee)), args)]),
                    ],
                };
                let value = Expr::Call(
                    Box::new(Expr::Function(Box::new(function))),
                    vec![pending.value],
                );
                self.cover(index)?;
                self.cover(index + 1)?;
                self.call_result(&call, value, &mut out, &mut open)?;
                index += 2;
                continue;
            }
            if open.is_some()
                && !matches!(
                    i.op,
                    Opcode::Call
                        | Opcode::Return
                        | Opcode::SetList
                        | Opcode::NameCall
                        | Opcode::FastCall
                        | Opcode::FastCall1
                        | Opcode::FastCall2
                        | Opcode::FastCall2K
                        | Opcode::FastCall3
                        | Opcode::FastPcall
                )
            {
                return Err(self.error(
                    index,
                    "open multiple-return result is not immediately consumed",
                ));
            }
            if open.is_none() && context.is_none_or(|l| l.header != index) {
                if let Some(tail) = self
                    .loops
                    .get(&index)
                    .and_then(|v| v.iter().rev().find(|&&tail| tail < end))
                    .copied()
                {
                    let exit = tail + 1;
                    let loop_context = Loop {
                        header: index,
                        continue_at: index,
                        end: exit,
                    };
                    if cfg::is_conditional(self.proto.code[tail].op) {
                        let body = self.region(
                            index,
                            tail,
                            Some(Loop {
                                continue_at: tail,
                                ..loop_context
                            }),
                            None,
                            nesting + 1,
                        )?;
                        self.cover(tail)?;
                        let until = self.condition(tail)?.negate();
                        out.push(Stmt::Repeat { body, until });
                    } else {
                        let body =
                            self.region(index, tail, Some(loop_context), None, nesting + 1)?;
                        self.cover(tail)?;
                        out.push(Stmt::While {
                            condition: Expr::Literal("true".into()),
                            body,
                        });
                    }
                    index = exit;
                    continue;
                }
            }
            if matches!(
                i.op,
                Opcode::ForNPrep | Opcode::ForGPrep | Opcode::ForGPrepInext | Opcode::ForGPrepNext
            ) {
                if open.is_some() {
                    return Err(self.error(index, "open values cross a loop boundary"));
                }
                self.cover(index)?;
                let target = self.target(index)?;
                let numeric = i.op == Opcode::ForNPrep;
                let (tail, exit) = if numeric {
                    (
                        target
                            .checked_sub(1)
                            .ok_or_else(|| self.error(index, "numeric for exit precedes body"))?,
                        target,
                    )
                } else {
                    (target, target + 1)
                };
                if tail <= index || exit > end {
                    return Err(self.error(
                        index,
                        "loop extends outside its enclosing structured region",
                    ));
                }
                let loop_i = self.proto.code[tail];
                if loop_i.a() != i.a()
                    || loop_i.op
                        != if numeric {
                            Opcode::ForNLoop
                        } else {
                            Opcode::ForGLoop
                        }
                    || self.target(tail)? != index + 1
                {
                    return Err(self.error(
                        index,
                        "for-loop preparation/backedge shape does not match compiler pattern",
                    ));
                }
                let variables = if numeric {
                    1
                } else {
                    (loop_i.aux.unwrap_or(0) & 255) as usize
                };
                if matches!(i.op, Opcode::ForGPrepNext | Opcode::ForGPrepInext) {
                    let origin = self.builtin_origin(index, i.a(), 0)?;
                    let expected = if i.op == Opcode::ForGPrepInext {
                        origin.as_deref() == Some("call:ipairs")
                    } else {
                        matches!(origin.as_deref(), Some("next" | "call:pairs"))
                    };
                    if !expected {
                        return Err(self.error(index,"specialized generic-for generator does not have proven next/pairs/ipairs provenance"));
                    }
                }
                self.check_loop_registers(
                    index + 1,
                    tail,
                    exit,
                    i.a(),
                    if numeric { 3 } else { 3 + variables.max(2) },
                    numeric,
                )?;
                if !numeric && variables == 1 {
                    if self.capture_open(index, i.a() + 4) {
                        return Err(self.error(
                            index,
                            "one-variable generic loop padding is reference-captured",
                        ));
                    }
                    for n in index + 1..tail {
                        if self.ssa.effects[n].reads.contains(i.a() + 4) {
                            return Err(self.error(n,"one-variable generic loop observes VM table-fastpath padding result"));
                        }
                    }
                }
                let mut body = self.region(
                    index + 1,
                    tail,
                    Some(Loop {
                        header: index + 1,
                        continue_at: tail,
                        end: exit,
                    }),
                    None,
                    nesting + 1,
                )?;
                self.cover(tail)?;
                self.current_index = index;
                if numeric {
                    let variable = self.shared.names.allocate("index");
                    body.insert(0, self.assign(i.a() + 2, Expr::name(&variable)));
                    out.push(Stmt::NumericFor {
                        variable,
                        start: self.r(i.a() + 2),
                        limit: self.r(i.a()),
                        step: self.r(i.a() + 1),
                        body,
                    });
                } else {
                    let names: Vec<_> = (0..variables)
                        .map(|v| {
                            self.shared.names.allocate(if v == 0 {
                                "key"
                            } else if v == 1 {
                                "value"
                            } else {
                                "item"
                            })
                        })
                        .collect();
                    body.insert(
                        0,
                        Stmt::Assign(
                            (i.a() + 3..i.a() + 3 + variables)
                                .map(|r| self.r(r))
                                .collect(),
                            names.iter().map(|n| Expr::name(n)).collect(),
                        ),
                    );
                    out.push(Stmt::GenericFor {
                        variables: names,
                        iterators: (i.a()..i.a() + 3).map(|r| self.r(r)).collect(),
                        body,
                    });
                }
                index = exit;
                continue;
            }
            if cfg::is_conditional(i.op) {
                if open.is_some() {
                    return Err(self.error(index, "open values cross a branch"));
                }
                self.cover(index)?;
                let target = self.target(index)?;
                let condition = self.condition(index)?;
                if let Some(l) = context {
                    if target == l.end || target == l.continue_at {
                        let action = if target == l.end {
                            Stmt::Break
                        } else {
                            Stmt::Continue
                        };
                        out.push(Stmt::If {
                            condition,
                            yes: vec![action],
                            no: Vec::new(),
                        });
                        index += 1;
                        continue;
                    }
                }
                if target <= index || target > end {
                    return Err(self.error(
                        index,
                        "conditional edge crosses an unsupported structured-region boundary",
                    ));
                }
                let previous = target - 1;
                let previous_i = &self.proto.code[previous];
                if previous > index && cfg::is_conditional(previous_i.op) {
                    let merge = self.target(previous)?;
                    if merge > target && merge <= end {
                        self.cover(previous)?;
                        let decision = self.shared.names.allocate("take_fallback");
                        let mut yes =
                            self.region(index + 1, previous, context, None, nesting + 1)?;
                        yes.push(Stmt::Assign(
                            vec![Expr::name(&decision)],
                            vec![self.condition(previous)?.negate()],
                        ));
                        let fallback =
                            self.region(target, merge, context, allowed_exit, nesting + 1)?;
                        out.push(Stmt::Do(vec![
                            Stmt::Local(vec![decision.clone()], vec![condition]),
                            Stmt::If {
                                condition: Expr::name(&decision).negate(),
                                yes,
                                no: Vec::new(),
                            },
                            Stmt::If {
                                condition: Expr::name(&decision),
                                yes: fallback,
                                no: Vec::new(),
                            },
                        ]));
                        index = merge;
                        continue;
                    }
                }
                let branch_jump = matches!(previous_i.op, Opcode::Jump | Opcode::JumpX)
                    || (previous_i.op == Opcode::LoadB && previous_i.c() != 0);
                let merge = if branch_jump {
                    self.target(previous)
                        .ok()
                        .filter(|&merge| {
                            merge > target && (merge <= end || Some(merge) == allowed_exit)
                        })
                        .map(|merge| merge.min(end))
                } else {
                    None
                };
                if let Some(merge) = merge {
                    let include_terminal = previous_i.op == Opcode::LoadB;
                    if !include_terminal {
                        self.cover(previous)?;
                    }
                    let yes = self.region(
                        index + 1,
                        if include_terminal { target } else { previous },
                        context,
                        Some(merge),
                        nesting + 1,
                    )?;
                    let no = self.region(target, merge, context, allowed_exit, nesting + 1)?;
                    out.push(Stmt::If {
                        condition: condition.negate(),
                        yes,
                        no,
                    });
                    index = merge;
                } else {
                    let yes = self.region(index + 1, target, context, allowed_exit, nesting + 1)?;
                    out.push(Stmt::If {
                        condition: condition.negate(),
                        yes,
                        no: Vec::new(),
                    });
                    index = target;
                }
                continue;
            }
            if matches!(i.op, Opcode::Jump | Opcode::JumpBack | Opcode::JumpX) {
                self.cover(index)?;
                let target = self.target(index)?;
                if let Some(l) = context {
                    if target == l.end {
                        out.push(Stmt::Break);
                        break;
                    }
                    if target == l.continue_at {
                        out.push(Stmt::Continue);
                        break;
                    }
                }
                if target == end || Some(target) == allowed_exit {
                    break;
                }
                if target > index && target < end {
                    index = target;
                    continue;
                }
                return Err(self.error(
                    index,
                    "unconditional edge crosses an unsupported structured region",
                ));
            }
            self.cover(index)?;
            match i.op {
                Opcode::LoadB => {
                    out.push(self.assign(i.a(), Expr::Literal((i.b() != 0).to_string())));
                    if i.c() != 0 {
                        let target = self.target(index)?;
                        if target == end || Some(target) == allowed_exit {
                            break;
                        }
                        if target <= index || target > end {
                            return Err(self.error(index, "LOADB skip crosses structured region"));
                        }
                        index = target;
                        continue;
                    }
                }
                Opcode::NameCall => {
                    let call_index = index + 1;
                    let call = *self
                        .proto
                        .code
                        .get(call_index)
                        .ok_or_else(|| self.error(index, "NAMECALL has no CALL"))?;
                    if call.op != Opcode::Call || call.a() != i.a() {
                        return Err(
                            self.error(index, "NAMECALL is not immediately followed by its CALL")
                        );
                    }
                    if call_index >= end {
                        return Err(
                            self.error(index, "NAMECALL/CALL pair crosses structured region")
                        );
                    }
                    let method =
                        constant_string(self.module, self.proto, i.aux.unwrap_or(0) as usize)?;
                    let method = std::str::from_utf8(method)
                        .ok()
                        .filter(|s| is_identifier(s))
                        .ok_or_else(|| {
                            self.error(index, "method name has no colon-call source spelling")
                        })?
                        .to_owned();
                    if call.b() == 1 {
                        return Err(self.error(index, "method CALL has no receiver argument"));
                    }
                    if self.capture_open(index, i.a()) || self.capture_open(index, i.a() + 1) {
                        return Err(self.error(
                            index,
                            "NAMECALL preparation writes a reference-captured register",
                        ));
                    }
                    let result_end = if call.c() == 0 {
                        self.proto.max_stack as usize
                    } else {
                        call.a() + call.c() - 1
                    };
                    for r in i.a()..i.a() + 2 {
                        if r >= result_end && self.ssa.live_after[call_index].contains(r) {
                            return Err(self.error(
                                index,
                                "NAMECALL preparation register is observed after CALL",
                            ));
                        }
                    }
                    let value = if let Some(pending) = open.take() {
                        if i.b() >= pending.base {
                            return Err(self.error(
                                index,
                                "NAMECALL receiver is part of an unresolved open-result range",
                            ));
                        }
                        self.check_open_scratch(call_index, pending.base)?;
                        let args = self.arguments(
                            call_index,
                            i.a() + 2,
                            call.b(),
                            Some(Open {
                                base: pending.base,
                                value: Expr::Vararg,
                            }),
                        )?;
                        let method = Expr::MethodCall(Box::new(self.r(i.b())), method, args);
                        Expr::Call(
                            Box::new(Expr::Function(Box::new(Function {
                                origin: None,
                                parameters: Vec::new(),
                                vararg: true,
                                body: vec![Stmt::Return(vec![method])],
                            }))),
                            vec![pending.value],
                        )
                    } else {
                        let args = self.arguments(call_index, i.a() + 2, call.b(), None)?;
                        Expr::MethodCall(Box::new(self.r(i.b())), method, args)
                    };
                    self.cover(call_index)?;
                    self.call_result(&call, value, &mut out, &mut open)?;
                    index += 2;
                    continue;
                }
                Opcode::Call => {
                    let pending = open.take();
                    let wrap = pending
                        .as_ref()
                        .is_some_and(|tail| (i.a()..tail.base).any(|r| self.registers[r].captured));
                    let value = if wrap {
                        let pending = pending.unwrap();
                        let args = self.arguments(
                            index,
                            i.a() + 1,
                            i.b(),
                            Some(Open {
                                base: pending.base,
                                value: Expr::Vararg,
                            }),
                        )?;
                        let call = Expr::Call(Box::new(self.r(i.a())), args);
                        Expr::Call(
                            Box::new(Expr::Function(Box::new(Function {
                                origin: None,
                                parameters: Vec::new(),
                                vararg: true,
                                body: vec![Stmt::Return(vec![call])],
                            }))),
                            vec![pending.value],
                        )
                    } else {
                        let args = self.arguments(index, i.a() + 1, i.b(), pending)?;
                        Expr::Call(Box::new(self.r(i.a())), args)
                    };
                    self.call_result(&i, value, &mut out, &mut open)?;
                }
                Opcode::GetVarargs => {
                    if i.b() == 0 {
                        self.check_open_captures(index, i.a())?;
                        open = Some(Open {
                            base: i.a(),
                            value: Expr::Vararg,
                        });
                    } else if i.b() > 1 {
                        out.push(Stmt::Assign(
                            (i.a()..i.a() + i.b() - 1).map(|r| self.w(r)).collect(),
                            vec![Expr::Vararg],
                        ));
                    }
                }
                Opcode::Return => {
                    let values = if i.b() == 0 {
                        let pending = open
                            .take()
                            .ok_or_else(|| self.error(index, "open RETURN has no producer"))?;
                        if (i.a()..pending.base).any(|r| self.registers[r].captured) {
                            let values = self.open_list(
                                index,
                                i.a(),
                                Some(Open {
                                    base: pending.base,
                                    value: Expr::Vararg,
                                }),
                            )?;
                            vec![Expr::Call(
                                Box::new(Expr::Function(Box::new(Function {
                                    origin: None,
                                    parameters: Vec::new(),
                                    vararg: true,
                                    body: vec![Stmt::Return(values)],
                                }))),
                                vec![pending.value],
                            )]
                        } else {
                            self.open_list(index, i.a(), Some(pending))?
                        }
                    } else {
                        if open.is_some() {
                            return Err(
                                self.error(index, "fixed RETURN leaves open results unconsumed")
                            );
                        }
                        (i.a()..i.a() + i.b() - 1).map(|r| self.r(r)).collect()
                    };
                    out.push(Stmt::Return(values));
                    break;
                }
                Opcode::NewClosure | Opcode::DupClosure => {
                    let (statements, count) = self.closure(index)?;
                    for j in index + 1..index + 1 + count {
                        self.cover(j)?;
                    }
                    out.extend(statements);
                    index += count;
                }
                Opcode::SetList => self.set_list(index, open.take(), &mut out)?,
                Opcode::FastCall
                | Opcode::FastCall1
                | Opcode::FastCall2
                | Opcode::FastCall2K
                | Opcode::FastCall3
                | Opcode::FastPcall => {
                    let proof =
                        crate::bytecode::verify_fastcall_fallback(self.module, self.pid, index)?;
                    if self.cfg.instruction_block[index]
                        != self.cfg.instruction_block[proof.call_index]
                    {
                        return Err(self.error(
                            index,
                            "FASTCALL fallback has an external control-flow entry",
                        ));
                    }
                    for &r in &proof.written_registers {
                        if self.capture_open(index, r) {
                            return Err(self.error(
                                index,
                                format!("FASTCALL fallback writes captured register r{r}"),
                            ));
                        }
                    }
                    for r in proof.scratch_registers {
                        if self.ssa.live_after[proof.call_index].contains(r) {
                            return Err(self.error(
                                index,
                                format!("FASTCALL fallback scratch register r{r} remains live"),
                            ));
                        }
                    }
                }
                Opcode::Capture => {
                    return Err(self.error(index, "CAPTURE was reached outside its closure payload"))
                }
                Opcode::ForNLoop | Opcode::ForGLoop => {
                    return Err(
                        self.error(index, "loop backedge was not paired with its preparation")
                    )
                }
                Opcode::Break | Opcode::NativeCall => {
                    return Err(self.error(index, "runtime-patched opcode cannot be reconstructed"))
                }
                _ => self.plain(index, &mut out)?,
            }
            index += 1;
        }
        if open.is_some() {
            return Err(self.error(
                index.saturating_sub(1),
                "open multiple-return result crosses structured region boundary",
            ));
        }
        Ok(out)
    }
    fn open_list(&self, index: usize, start: usize, open: Option<Open>) -> Result<Vec<Expr>> {
        let open = open.ok_or_else(|| {
            self.error(
                index,
                "open value-list consumer has no immediately preceding producer",
            )
        })?;
        if open.base < start {
            return Err(self.error(index, "open result starts before consumer's fixed prefix"));
        }
        self.check_open_scratch(index, open.base)?;
        let mut values: Vec<_> = (start..open.base).map(|r| self.r_at(index, r)).collect();
        values.push(open.value);
        Ok(values)
    }
    fn check_open_scratch(&self, index: usize, base: usize) -> Result<()> {
        for r in base..self.proto.max_stack as usize {
            if self.ssa.live_after[index].contains(r) && !self.ssa.effects[index].writes.contains(r)
            {
                return Err(self.error(
                    index,
                    format!("open-result scratch register r{r} remains live after its consumer"),
                ));
            }
            if self.capture_open(index, r) {
                return Err(self.error(
                    index,
                    format!("open-result range includes reference-captured register r{r}"),
                ));
            }
        }
        Ok(())
    }
    fn check_open_captures(&self, index: usize, base: usize) -> Result<()> {
        for r in base..self.proto.max_stack as usize {
            if self.capture_open(index, r) {
                return Err(self.error(
                    index,
                    format!(
                        "open-result producer overwrites active reference-captured register r{r}"
                    ),
                ));
            }
        }
        Ok(())
    }
    fn arguments(
        &self,
        index: usize,
        start: usize,
        count: usize,
        open: Option<Open>,
    ) -> Result<Vec<Expr>> {
        if count == 0 {
            self.open_list(index, start, open)
        } else {
            if open.is_some() {
                return Err(self.error(index, "fixed CALL leaves open results unconsumed"));
            }
            let end = self.proto.code[index].a() + count;
            Ok((start..end).map(|r| self.r_at(index, r)).collect())
        }
    }
    fn call_result(
        &self,
        i: &Instruction,
        value: Expr,
        out: &mut Vec<Stmt>,
        open: &mut Option<Open>,
    ) -> Result<()> {
        match i.c() {
            0 => {
                let index = self
                    .proto
                    .code
                    .binary_search_by_key(&i.pc, |op| op.pc)
                    .unwrap();
                self.check_open_captures(index, i.a())?;
                *open = Some(Open { base: i.a(), value });
            }
            1 => out.push(Stmt::Call(value)),
            count => out.push(Stmt::Assign(
                (i.a()..i.a() + count - 1)
                    .map(|r| {
                        self.w_at(
                            self.proto
                                .code
                                .binary_search_by_key(&i.pc, |op| op.pc)
                                .unwrap(),
                            r,
                        )
                    })
                    .collect(),
                vec![value],
            )),
        }
        Ok(())
    }
    fn plain(&mut self, index: usize, out: &mut Vec<Stmt>) -> Result<()> {
        self.current_index = index;
        use Opcode::*;
        let i = &self.proto.code[index];
        let (a, b, c) = (i.a(), i.b(), i.c());
        let value = match i.op {
            Nop | Coverage | PrepVarargs => return Ok(()),
            LoadNil => nil(),
            LoadN => number(i.d() as f64),
            LoadK => self.constant(i.d() as usize, index)?,
            LoadKx => self.constant(i.aux.unwrap_or(0) as usize, index)?,
            Move => self.r(b),
            GetGlobal => {
                let name = constant_string(self.module, self.proto, i.aux.unwrap_or(0) as usize)?;
                Expr::Global(String::from_utf8(name.to_vec()).unwrap())
            }
            SetGlobal => {
                let name = constant_string(self.module, self.proto, i.aux.unwrap_or(0) as usize)?;
                out.push(Stmt::Assign(
                    vec![Expr::Global(String::from_utf8(name.to_vec()).unwrap())],
                    vec![self.r(a)],
                ));
                return Ok(());
            }
            GetImport => {
                let aux = i.aux.unwrap_or(0);
                let count = aux >> 30;
                let root = constant_string(self.module, self.proto, ((aux >> 20) & 1023) as usize)?;
                let mut value = Expr::Global(String::from_utf8(root.to_vec()).unwrap());
                if count >= 2 {
                    value = self.key(value, ((aux >> 10) & 1023) as usize, index)?;
                }
                if count == 3 {
                    value = self.key(value, (aux & 1023) as usize, index)?;
                }
                value
            }
            GetUpval => self.upvalues[b].value.clone(),
            SetUpval => {
                let up = &self.upvalues[b];
                if !up.writable {
                    return Err(self.error(index, "SETUPVAL targets an immutable value capture"));
                }
                out.push(Stmt::Assign(vec![up.value.clone()], vec![self.r(a)]));
                return Ok(());
            }
            CloseUpvals => {
                for reg in &self.registers[a..] {
                    if reg.cell {
                        out.push(Stmt::Assign(
                            vec![Expr::name(&reg.name)],
                            vec![Expr::Table(vec![(
                                Some(Expr::Literal(quote(b"value"))),
                                reg.value(),
                            )])],
                        ))
                    }
                }
                return Ok(());
            }
            GetTable => Expr::Index(Box::new(self.r(b)), Box::new(self.r(c))),
            GetTableKs => self.key(self.r(b), i.aux.unwrap_or(0) as usize, index)?,
            GetTableN => Expr::Index(Box::new(self.r(b)), Box::new(number((c + 1) as f64))),
            SetTable | SetTableKs | SetTableN => {
                if let Some((origin, store)) = self.deferred_tables.remove(&b) {
                    if store != index {
                        return Err(self.error(
                            index,
                            "deferred constructor first-store proof no longer matches",
                        ));
                    }
                    let key = match i.op {
                        SetTable => self.r(c),
                        SetTableKs => Expr::Literal(quote(constant_string(
                            self.module,
                            self.proto,
                            i.aux.unwrap_or(0) as usize,
                        )?)),
                        _ => number((c + 1) as f64),
                    };
                    let fields = self.reservation_fields(origin, Some(key))?;
                    out.push(self.assign(b, Expr::Table(fields)));
                }
                let target = match i.op {
                    SetTable => Expr::Index(Box::new(self.r(b)), Box::new(self.r(c))),
                    SetTableKs => self.key(self.r(b), i.aux.unwrap_or(0) as usize, index)?,
                    _ => Expr::Index(Box::new(self.r(b)), Box::new(number((c + 1) as f64))),
                };
                out.push(Stmt::Assign(vec![target], vec![self.r(a)]));
                return Ok(());
            }
            Add | Sub | Mul | Div | Mod | Pow | And | Or | IDiv => {
                Expr::binary(binary_operator(i.op), self.r(b), self.r(c))
            }
            AddK | SubK | MulK | DivK | ModK | PowK | AndK | OrK | IDivK => {
                Expr::binary(binary_operator(i.op), self.r(b), self.constant(c, index)?)
            }
            SubRk | DivRk => {
                Expr::binary(binary_operator(i.op), self.constant(b, index)?, self.r(c))
            }
            Not | Minus | Length => Expr::Unary(
                match i.op {
                    Not => "not",
                    Minus => "-",
                    _ => "#",
                },
                Box::new(self.r(b)),
            ),
            Concat => {
                if (b..=c).any(|r| self.capture_open(index, r)) {
                    return Err(self.error(
                        index,
                        "CONCAT scratch range contains an externally observable reference capture",
                    ));
                }
                for r in b..=c {
                    if r != a && self.ssa.live_after[index].contains(r) {
                        return Err(self.error(
                            index,
                            format!("CONCAT scratch register r{r} is observed after concatenation"),
                        ));
                    }
                }
                let mut value = self.r(c);
                for r in (b..c).rev() {
                    value = Expr::binary("..", self.r(r), value);
                }
                value
            }
            NewTable => {
                let key = if i.b() != 0 {
                    match self.first_table_key(index) {
                        Ok(key) => Some(key),
                        Err(error) if error.stage == "structure" => {
                            if let Some(store) = self.dynamic_first_store(index)? {
                                self.deferred_tables.insert(a, (index, store));
                                return Ok(());
                            }
                            return Err(error);
                        }
                        Err(error) => return Err(error),
                    }
                } else {
                    None
                };
                Expr::Table(self.reservation_fields(index, key)?)
            }
            DupTable => {
                if let Constant::TableWithConstants(entries) = &self.proto.constants[i.d() as usize]
                {
                    self.shared.charge(entries.len(), self.config)?;
                    self.reject_duplicate_template_strings(
                        index,
                        entries.iter().map(|(key, _)| *key),
                    )?;
                    let mut fields = Vec::with_capacity(entries.len());
                    let mut nil_keys = Vec::new();
                    for &(key, value) in entries {
                        if !matches!(self.proto.constants[key], Constant::String(_)) {
                            return Err(self.error(index,"non-string prefilled DUPTABLE key requires an array/hash layout proof"));
                        }
                        let key = self.constant(key, index)?;
                        let value = match value {
                            Some(value) if matches!(self.proto.constants[value], Constant::Nil) => {
                                nil_keys.push(key.clone());
                                number(0.0)
                            }
                            Some(value) => self.constant(value, index)?,
                            None => number(0.0),
                        };
                        fields.push((Some(key), value));
                    }
                    out.push(self.assign(a, Expr::Table(fields)));
                    for key in nil_keys {
                        out.push(Stmt::Assign(
                            vec![Expr::Index(Box::new(self.w(a)), Box::new(key))],
                            vec![nil()],
                        ));
                    }
                    return Ok(());
                }
                let Constant::Table(keys) = &self.proto.constants[i.d() as usize] else {
                    return Err(self.error(index, "DUPTABLE constant is not a table template"));
                };
                self.shared.charge(keys.len(), self.config)?;
                self.reject_duplicate_template_strings(index, keys.iter().copied())?;
                let mut fields = Vec::with_capacity(keys.len());
                for &key in keys {
                    if !matches!(self.proto.constants[key], Constant::String(_)) {
                        return Err(self.error(
                            index,
                            "non-string DUPTABLE template key has unsupported array/hash layout",
                        ));
                    }
                    fields.push((Some(self.constant(key, index)?), number(0.0)));
                }
                Expr::Table(fields)
            }
            _ => {
                return Err(self.error(
                    index,
                    format!("opcode {:?} has no implemented source lowering", i.op),
                ))
            }
        };
        out.push(self.assign(a, value));
        Ok(())
    }
    fn reject_duplicate_template_strings(
        &self,
        index: usize,
        keys: impl ExactSizeIterator<Item = usize>,
    ) -> Result<()> {
        crate::execution::reserve_ast_capacity(keys.len().saturating_mul(64))?;
        let mut seen = BTreeSet::<&[u8]>::new();
        for key in keys {
            if let Some(Constant::String(string)) = self.proto.constants.get(key) {
                let bytes = self.module.strings.get(*string).ok_or_else(|| {
                    self.error(index, "table template string index is out of range")
                })?;
                if !seen.insert(bytes.as_slice()) {
                    return Err(self.error(index,
                        "DUPTABLE duplicate string key values have unsupported physical template layout; distinct constant indices do not make byte-equal keys distinct"));
                }
            }
        }
        Ok(())
    }
    fn reservation_fields(
        &mut self,
        origin: usize,
        key: Option<Expr>,
    ) -> Result<Vec<(Option<Expr>, Expr)>> {
        let i = self.proto.code[origin];
        let count = i.aux.unwrap_or(0) as usize;
        if count.saturating_mul(5) > self.config.limits.max_output_bytes {
            return Err(self.error(
                origin,
                "table array reservation exceeds source output budget",
            ));
        }
        let repeats = if i.b() == 0 {
            0
        } else {
            let capacity = 1usize.checked_shl((i.b() - 1) as u32).ok_or_else(|| {
                self.error(origin, "hash reservation overflows platform capacity")
            })?;
            if capacity == 1 {
                1
            } else {
                capacity / 2 + 1
            }
        };
        let key_cost = match &key {
            Some(Expr::Literal(text)) => text.len(),
            Some(Expr::Name(name)) => name.len(),
            Some(Expr::Field(_, field)) => 128 + field.len() + 1,
            None => 0,
            _ => {
                return Err(self.error(
                    origin,
                    "hash reservation key lacks a stable scalar source expression",
                ))
            }
        };
        let cost = repeats.saturating_mul(key_cost.saturating_add(10));
        self.shared.text_bytes = self.shared.text_bytes.saturating_add(cost);
        if self.shared.text_bytes > self.config.limits.max_output_bytes {
            return Err(self.error(origin, "hash reservation source exceeds output byte budget"));
        }
        self.shared
            .charge(count.saturating_add(repeats), self.config)?;
        let field_count = count.saturating_add(repeats);
        crate::execution::reserve_ast_capacity(
            field_count
                .saturating_mul(std::mem::size_of::<(Option<Expr>, Expr)>().saturating_add(3))
                .saturating_add(repeats.saturating_mul(
                    key_cost.saturating_add(std::mem::size_of::<Expr>().saturating_mul(2)),
                )),
        )?;
        let mut fields = Vec::with_capacity(field_count);
        fields.extend((0..count).map(|_| (None, nil())));
        if let Some(key) = key {
            let protect_index_syntax = matches!(&key, Expr::Literal(text)
                if serde_json::from_str::<String>(text).ok().is_some_and(|name| is_identifier(&name)));
            let key = if protect_index_syntax {
                Expr::Single(Box::new(key))
            } else {
                key
            };
            fields.extend((0..repeats).map(|_| (Some(key.clone()), nil())));
        }
        Ok(fields)
    }
    fn fresh_table(&mut self, index: usize, register: usize) -> Result<(usize, bool)> {
        let value = self.ssa.reaching_definition(&self.cfg, index, register);
        if let crate::dataflow::Definition::Instruction {
            index: origin,
            register: target,
        } = self.ssa.definitions[value]
        {
            if target == register
                && matches!(
                    self.proto.code[origin].op,
                    Opcode::NewTable | Opcode::DupTable
                )
                && self.cfg.instruction_block[origin] != self.cfg.instruction_block[index]
            {
                if self.capture_open(index, register) {
                    return Err(self.error(index, "cross-block constructor is reference-captured"));
                }
                let origin_block = self.cfg.instruction_block[origin];
                let target_block = self.cfg.instruction_block[index];
                let mut ancestor = target_block;
                while ancestor != origin_block {
                    self.shared.charge(1, self.config)?;
                    let Some(parent) = self.cfg.immediate_dominators[ancestor] else {
                        return Err(self.error(index, "constructor does not dominate SETLIST"));
                    };
                    if parent == ancestor {
                        return Err(self.error(index, "constructor does not dominate SETLIST"));
                    }
                    ancestor = parent;
                }
                let mut relevant = vec![false; self.cfg.blocks.len()];
                let mut pending = vec![target_block];
                while let Some(block) = pending.pop() {
                    self.shared.charge(1, self.config)?;
                    if relevant[block] {
                        continue;
                    }
                    relevant[block] = true;
                    if block != origin_block {
                        pending.extend(self.cfg.blocks[block].predecessors.iter().copied());
                    }
                }
                let mut writes = false;
                for (block, &relevant) in relevant.iter().enumerate() {
                    if !relevant {
                        continue;
                    }
                    let start = if block == origin_block {
                        origin + 1
                    } else {
                        self.cfg.blocks[block].start
                    };
                    let end = if block == target_block {
                        index
                    } else {
                        self.cfg.blocks[block].end
                    };
                    for previous in start..end {
                        self.shared.charge(1, self.config)?;
                        let i = self.proto.code[previous];
                        if self.ssa.effects[previous].writes.contains(register) {
                            return Err(self.error(
                                index,
                                "constructor register changes across SETLIST provenance paths",
                            ));
                        }
                        if self.ssa.effects[previous].reads.contains(register) {
                            let setter = (matches!(
                                i.op,
                                Opcode::SetTable | Opcode::SetTableKs | Opcode::SetTableN
                            ) && i.b() == register
                                && i.a() != register
                                && (i.op != Opcode::SetTable || i.c() != register))
                                || (i.op == Opcode::SetList
                                    && i.a() == register
                                    && i.b() > register);
                            if !setter {
                                return Err(
                                    self.error(index, "constructor escapes on a path to SETLIST")
                                );
                            }
                            writes = true;
                        }
                    }
                }
                return Ok((origin, writes));
            }
        }
        let mut has_writes = false;
        for previous in (0..index).rev() {
            self.shared.charge(1, self.config)?;
            let i = &self.proto.code[previous];
            if self.ssa.effects[previous].writes.contains(register) {
                if i.a() == register
                    && matches!(i.op, Opcode::NewTable | Opcode::DupTable)
                    && self.cfg.instruction_block[previous] == self.cfg.instruction_block[index]
                    && !self.capture_open(index, register)
                {
                    return Ok((previous, has_writes));
                }
                return Err(self.error(
                    index,
                    "SETLIST target is not a fresh unescaped constructor in the same basic block",
                ));
            }
            if self.ssa.effects[previous].reads.contains(register) {
                if (matches!(
                    i.op,
                    Opcode::SetTable | Opcode::SetTableKs | Opcode::SetTableN
                ) && i.b() == register
                    && i.a() != register
                    && (i.op != Opcode::SetTable || i.c() != register))
                    || (i.op == Opcode::SetList && i.a() == register && i.b() > register)
                {
                    has_writes = true;
                } else {
                    return Err(self.error(
                        index,
                        "SETLIST target may have escaped or acquired a metatable",
                    ));
                }
            }
        }
        Err(self.error(index, "SETLIST target has no constructor definition"))
    }
    fn set_list(&mut self, index: usize, open: Option<Open>, out: &mut Vec<Stmt>) -> Result<()> {
        let i = self.proto.code[index];
        let (origin, writes) = self.fresh_table(index, i.a())?;
        let first = i.aux.unwrap_or(0) as usize;
        if i.c() == 0 {
            if self.cfg.instruction_block[origin] != self.cfg.instruction_block[index]
                && (writes
                    || self.proto.code[origin].op != Opcode::NewTable
                    || self.proto.code[origin].b() != 0)
            {
                return Err(self.error(index,"cross-block open SETLIST requires an unwritten array-only constructor; conditional insertion histories remain unsupported"));
            }
            if first.saturating_mul(32) > self.config.limits.max_output_bytes {
                return Err(self.error(
                    index,
                    "open SETLIST prefix reconstruction exceeds output budget",
                ));
            }
            self.shared.charge(first, self.config)?;
            let pending = open.ok_or_else(|| self.error(index, "open SETLIST has no producer"))?;
            if i.a() >= pending.base {
                return Err(self.error(
                    index,
                    "SETLIST receiver is part of an unresolved open-result range",
                ));
            }
            let expected_array = first
                .saturating_sub(1)
                .saturating_add(pending.base.saturating_sub(i.b()))
                .saturating_add(usize::from(!matches!(pending.value, Expr::Vararg)));
            let original = self.proto.code[origin];
            if original.op == Opcode::DupTable
                && matches!(
                    self.proto.constants[original.d() as usize],
                    Constant::TableWithConstants(_)
                )
            {
                return Err(self.error(
                    index,
                    "open SETLIST over a prefilled table requires insertion-history reconstruction",
                ));
            }
            let array_reservation = if original.op == Opcode::NewTable {
                original.aux.unwrap_or(0) as usize
            } else {
                0
            };
            if array_reservation != expected_array {
                return Err(self.error(index,format!("open SETLIST constructor array reservation {array_reservation} differs from reconstructible source hint {expected_array}")));
            }
            let wrapped = (i.b()..pending.base).any(|r| self.registers[r].captured);
            let values = self.open_list(
                index,
                i.b(),
                Some(Open {
                    base: pending.base,
                    value: if wrapped {
                        Expr::Vararg
                    } else {
                        pending.value.clone()
                    },
                }),
            )?;
            let mut fields = Vec::new();
            if first != 1 || writes || self.proto.code[origin].op == Opcode::DupTable {
                let mut keys = Vec::new();
                if original.op == Opcode::DupTable {
                    if let Constant::Table(template) = &self.proto.constants[original.d() as usize]
                    {
                        for &key in template {
                            keys.push(self.constant(key, index)?);
                        }
                    }
                }
                for previous in origin + 1..index {
                    self.shared.charge(1, self.config)?;
                    let setter = self.proto.code[previous];
                    match setter.op {
                        Opcode::SetTableKs if setter.b() == i.a() => {
                            keys.push(Expr::Literal(quote(constant_string(
                                self.module,
                                self.proto,
                                setter.aux.unwrap_or(0) as usize,
                            )?)))
                        }
                        Opcode::SetTableN if setter.b() == i.a() => {
                            keys.push(number((setter.c() + 1) as f64))
                        }
                        Opcode::SetTable if setter.b() == i.a() => {
                            let key = self.literal_register(previous, setter.c(), 0)?.ok_or_else(
                                || {
                                    self.error(
                                        previous,
                                        "open mixed constructor requires proven literal hash keys",
                                    )
                                },
                            )?;
                            keys.push(key);
                        }
                        _ => {}
                    }
                }
                let mut seen = BTreeSet::new();
                let hash_fields = keys.len();
                for key in keys {
                    let Expr::Literal(text) = &key else {
                        return Err(self.error(index, "mixed constructor key is not literal"));
                    };
                    let identity = if let Ok(number) = text.parse::<f64>() {
                        if number == 0.0 {
                            "number:zero".to_owned()
                        } else {
                            format!("number:{}", number.to_bits())
                        }
                    } else {
                        text.clone()
                    };
                    if !seen.insert(identity) {
                        return Err(self.error(index,"open mixed constructor has duplicate hash writes whose historical insertion state cannot be recovered without snapshots"));
                    }
                    self.shared.text_bytes = self
                        .shared
                        .text_bytes
                        .saturating_add(text.len().saturating_mul(2));
                    if self.shared.text_bytes > self.config.limits.max_output_bytes {
                        return Err(self.error(
                            index,
                            "mixed constructor key expansion exceeds output byte budget",
                        ));
                    }
                    fields.push((
                        Some(key.clone()),
                        Expr::Index(Box::new(self.r(i.a())), Box::new(key)),
                    ));
                }
                if original.op == Opcode::NewTable {
                    let old_hash = if original.b() == 0 {
                        0
                    } else {
                        1usize << (original.b() - 1)
                    };
                    let source_hash = if hash_fields == 0 {
                        0
                    } else {
                        hash_fields.next_power_of_two()
                    };
                    if old_hash != source_hash {
                        return Err(self.error(index,"mixed constructor hash reservation differs from reconstructible source hint"));
                    }
                }
                self.shared.text_bytes = self.shared.text_bytes.saturating_add(
                    first
                        .saturating_sub(1)
                        .saturating_mul(self.registers[i.a()].name.len() + 24),
                );
                if self.shared.text_bytes > self.config.limits.max_output_bytes {
                    return Err(self.error(
                        index,
                        "mixed constructor array prefix exceeds output byte budget",
                    ));
                }
                for n in 1..first {
                    fields.push((
                        None,
                        Expr::Index(Box::new(self.r(i.a())), Box::new(number(n as f64))),
                    ));
                }
            }
            fields.extend(values.into_iter().map(|v| (None, v)));
            let table = Expr::Table(fields);
            let value = if wrapped {
                Expr::Call(
                    Box::new(Expr::Function(Box::new(Function {
                        origin: None,
                        parameters: Vec::new(),
                        vararg: true,
                        body: vec![Stmt::Return(vec![table])],
                    }))),
                    vec![pending.value],
                )
            } else {
                table
            };
            out.push(self.assign(i.a(), value));
        } else {
            if open.is_some() {
                return Err(self.error(index, "fixed SETLIST leaves open results unconsumed"));
            }
            let targets = (0..i.c() - 1)
                .map(|n| {
                    Expr::Index(
                        Box::new(self.r(i.a())),
                        Box::new(number((first + n) as f64)),
                    )
                })
                .collect();
            let values = (i.b()..i.b() + i.c() - 1).map(|r| self.r(r)).collect();
            if i.c() > 1 {
                out.push(Stmt::Assign(targets, values));
            }
        }
        Ok(())
    }
    fn closure(&mut self, index: usize) -> Result<(Vec<Stmt>, usize)> {
        let i = self.proto.code[index];
        let duplicate = i.op == Opcode::DupClosure;
        let child = if duplicate {
            match self.proto.constants[i.d() as usize] {
                Constant::Closure(id) => id,
                _ => return Err(self.error(index, "DUPCLOSURE does not refer to a child closure")),
            }
        } else {
            self.proto.children[i.d() as usize]
        };
        let child_proto = &self.module.protos[child];
        let count = child_proto.num_upvalues as usize;
        if duplicate {
            self.shared.uses_duplicate = true;
            if self.config.closures.entry_invocation == crate::config::EntryInvocation::Repeated {
                if !self.config.closures.compiler_closure_sharing {
                    return Err(self.error(index,"repeated-entry DUPCLOSURE reconstruction requires an explicit compiler_closure_sharing contract; arbitrary O0 recompilation cannot preserve cached function identity"));
                }
                if count != 0 {
                    return Err(self.error(index,"repeated-entry DUPCLOSURE with captures requires persistent prototype-cache reconstruction that is not established"));
                }
            } else {
                self.shared.entry_restrictions.insert((self.pid,i.pc),"DUPCLOSURE identity is certified only for one entry invocation without an explicit output-compiler sharing contract".into());
            }
            if count == 0 {
                if let Some(name) = self
                    .shared
                    .hoisted_closures
                    .get(&(self.pid, i.d() as usize))
                {
                    return Ok((vec![self.assign(i.a(), Expr::name(name))], 0));
                }
            }
        }
        let mut captures = Vec::new();
        let mut values = Vec::new();
        let mut upvalues = Vec::new();
        for n in 0..count {
            let capture = &self.proto.code[index + 1 + n];
            let source = capture.b();
            if duplicate && capture.a() == 0 && source == i.a() {
                return Err(self.error(
                    index,
                    "DUPCLOSURE self-value capture has no supported source cache representation",
                ));
            }
            let native_value = match capture.a() {
                1 if !self.registers[source].cell => Some(self.r_at(index + 1 + n, source)),
                2 if self.upvalues[source].native => Some(self.upvalues[source].value.clone()),
                _ => None,
            };
            if let Some(value) = native_value {
                if duplicate {
                    return Err(self.error(
                        index,
                        "native reference capture cannot pass through a DUPCLOSURE identity cache",
                    ));
                }
                upvalues.push(Upvalue {
                    identity: value.clone(),
                    value,
                    writable: true,
                    native: true,
                });
                continue;
            }
            let hint = child_proto
                .upvalue_names
                .get(n)
                .map(String::as_str)
                .unwrap_or("captured_value");
            let name = self.shared.names.allocate(hint);
            let (value, reference) = match capture.a() {
                0 => (self.r_at(index + 1 + n, source), false),
                1 => {
                    if duplicate {
                        return Err(
                            self.error(index, "DUPCLOSURE cannot capture a register reference")
                        );
                    }
                    (Expr::name(&self.registers[source].name), true)
                }
                2 => (
                    self.upvalues[source].identity.clone(),
                    self.upvalues[source].writable,
                ),
                _ => return Err(self.error(index, "unknown upvalue capture type")),
            };
            upvalues.push(Upvalue {
                value: if reference {
                    Expr::Field(Box::new(Expr::name(&name)), "value".into())
                } else {
                    Expr::name(&name)
                },
                identity: Expr::name(&name),
                writable: reference,
                native: false,
            });
            captures.push(name);
            values.push(value);
        }
        let mut function = build_function(
            self.module,
            self.config,
            self.shared,
            child,
            upvalues,
            self.depth + 1,
        )?;
        let mut out = Vec::new();
        if !duplicate
            && self.pid == self.module.main
            && self.shared.acyclic_root
            && self.config.closures.entry_invocation == crate::config::EntryInvocation::Single
            && !(0..count).any(|n| {
                let capture = self.proto.code[index + 1 + n];
                capture.a() == 0 && capture.b() == i.a()
            })
        {
            self.shared.entry_restrictions.insert(
                (self.pid, i.pc),
                "direct NEWCLOSURE presentation uses an acyclic root site under the declared single-entry contract; repeated entry retains conservative fresh-closure construction".into(),
            );
            let assignment = self.assign(i.a(), Expr::Function(Box::new(function)));
            let body = if captures.is_empty() {
                vec![assignment]
            } else {
                vec![Stmt::Do(vec![Stmt::Local(captures, values), assignment])]
            };
            return Ok((body, count));
        }
        if duplicate && count == 0 {
            let names = ast::collect_names(&function.body);
            let external_cache = self
                .shared
                .cache_table
                .as_ref()
                .is_some_and(|name| names.contains_key(name))
                || self
                    .shared
                    .raw_equal
                    .as_ref()
                    .is_some_and(|name| names.contains_key(name));
            if !external_cache {
                if self.pid == self.module.main
                    && self.shared.duplicate_sites[self.pid].get(&(i.d() as usize)) == Some(&1)
                {
                    return Ok((
                        vec![self.assign(i.a(), Expr::Function(Box::new(function)))],
                        0,
                    ));
                }
                if self.shared.hoisted_functions.len() >= 64 {
                    if self.config.closures.entry_invocation
                        == crate::config::EntryInvocation::Repeated
                    {
                        return Err(self.error(index,"repeated-entry constant-closure hoisting exceeds the conservative lexical budget"));
                    }
                } else {
                    let hint = if self.config.naming_options.use_debug_names {
                        child_proto
                            .debug_name
                            .as_ref()
                            .map(|name| {
                                format!("shared_{}", name.chars().take(64).collect::<String>())
                            })
                            .unwrap_or_else(|| "shared_function".into())
                    } else {
                        "shared_function".into()
                    };
                    let name = self.shared.names.allocate(&hint);
                    self.shared
                        .hoisted_closures
                        .insert((self.pid, i.d() as usize), name.clone());
                    self.shared.hoisted_functions.push((name.clone(), function));
                    return Ok((vec![self.assign(i.a(), Expr::name(&name))], 0));
                }
            }
            if self.config.closures.entry_invocation == crate::config::EntryInvocation::Repeated {
                return Err(self.error(index,"repeated-entry noncapturing DUPCLOSURE depends on an entry-local cache helper and cannot be certified"));
            }
        }
        if duplicate
            && self.pid == self.module.main
            && self
                .shared
                .single_use_root_closures
                .contains(&(i.d() as usize))
        {
            if count == 0 {
                return Ok((
                    vec![self.assign(i.a(), Expr::Function(Box::new(function)))],
                    0,
                ));
            }
            return Ok((
                vec![Stmt::Do(vec![
                    Stmt::Local(captures, values),
                    self.assign(i.a(), Expr::Function(Box::new(function))),
                ])],
                count,
            ));
        }
        if duplicate {
            let key = (self.pid, i.d() as usize);
            let cache = if let Some(cache) = self.shared.caches.get(&key) {
                cache.clone()
            } else {
                let table = if let Some(name) = &self.shared.cache_table {
                    name.clone()
                } else {
                    let name = self.shared.names.allocate("closure_cache");
                    self.shared.cache_table = Some(name.clone());
                    name
                };
                let mut slot = || {
                    let n = self.shared.next_cache_slot;
                    self.shared.next_cache_slot += 1;
                    Expr::Index(Box::new(Expr::name(&table)), Box::new(number(n as f64)))
                };
                let function = slot();
                let saved = (0..count).map(|_| slot()).collect();
                let cache = ClosureCache {
                    function,
                    captures: saved,
                };
                self.shared.caches.insert(key, cache.clone());
                cache
            };
            if count != 0 {
                out.push(Stmt::Local(captures.clone(), values));
            }
            let mut condition = Expr::binary("~=", cache.function.clone(), nil());
            if count != 0 {
                let equality = if let Some(name) = &self.shared.raw_equal {
                    name.clone()
                } else {
                    let name = self.shared.names.allocate("same_capture");
                    self.shared.raw_equal = Some(name.clone());
                    name
                };
                for (saved, current) in cache.captures.iter().zip(&captures) {
                    condition = Expr::binary(
                        "and",
                        condition,
                        Expr::Call(
                            Box::new(Expr::name(&equality)),
                            vec![saved.clone(), Expr::name(current)],
                        ),
                    );
                }
            }
            let mut create = Vec::new();
            let sentinel = if count != 0 {
                Some(self.shared.names.allocate("closure_ready"))
            } else {
                None
            };
            if let Some(name) = &sentinel {
                function.body.insert(
                    0,
                    Stmt::If {
                        condition: Expr::name(name).negate(),
                        yes: vec![Stmt::Return(Vec::new())],
                        no: Vec::new(),
                    },
                );
                create.push(Stmt::Local(vec![name.clone()], Vec::new()));
            }
            create.push(self.assign(i.a(), Expr::Function(Box::new(function))));
            if let Some(name) = sentinel {
                create.push(Stmt::Assign(
                    vec![Expr::name(&name)],
                    vec![Expr::Literal("true".into())],
                ));
            }
            let mut save = vec![Stmt::Assign(
                vec![cache.function.clone()],
                vec![self.w(i.a())],
            )];
            if count != 0 {
                save.push(Stmt::Assign(
                    cache.captures.clone(),
                    captures.iter().map(|s| Expr::name(s)).collect(),
                ));
            }
            create.push(Stmt::If {
                condition: Expr::binary("==", cache.function.clone(), nil()),
                yes: save,
                no: Vec::new(),
            });
            out.push(Stmt::If {
                condition,
                yes: vec![self.assign(i.a(), cache.function.clone())],
                no: create,
            });
        } else {
            let sentinel = self.shared.names.allocate("closure_ready");
            function.body.insert(
                0,
                Stmt::If {
                    condition: Expr::name(&sentinel).negate(),
                    yes: vec![Stmt::Return(Vec::new())],
                    no: Vec::new(),
                },
            );
            let mut declarations = captures.clone();
            declarations.push(sentinel.clone());
            out.push(Stmt::Local(declarations, Vec::new()));
            out.push(self.assign(i.a(), Expr::Function(Box::new(function))));
            if !captures.is_empty() {
                out.push(Stmt::Assign(
                    captures.iter().map(|s| Expr::name(s)).collect(),
                    values,
                ));
            }
            out.push(Stmt::Assign(
                vec![Expr::name(&sentinel)],
                vec![Expr::Literal("true".into())],
            ));
        }
        Ok((vec![Stmt::Do(out)], count))
    }
}
fn binary_operator(op: Opcode) -> &'static str {
    use Opcode::*;
    match op {
        Add | AddK => "+",
        Sub | SubK | SubRk => "-",
        Mul | MulK => "*",
        Div | DivK | DivRk => "/",
        Mod | ModK => "%",
        Pow | PowK => "^",
        And | AndK => "and",
        Or | OrK => "or",
        IDiv | IDivK => "//",
        _ => unreachable!("arithmetic dispatch"),
    }
}
