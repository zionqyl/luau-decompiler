use crate::ast::{Annotations, Expr, Stmt, TypeExpr};
use crate::structure::RecoveredBindingInfo;
use crate::{Config, Error, NameStyle, Result};
use std::collections::{BTreeMap, BTreeSet};

#[derive(Default)]
pub struct DisplayNames {
    names: BTreeMap<String, String>,
}

#[derive(Default)]
struct Scope<'a> {
    parent: Option<usize>,
    declarations: Vec<&'a str>,
    used: BTreeSet<String>,
    next_suffix: BTreeMap<String, usize>,
}

enum Visit<'a> {
    Declarations(&'a [String], usize, usize),
    Statement(&'a Stmt, usize, usize),
    Expression(&'a Expr, usize, usize),
}

struct Planner<'a> {
    scopes: Vec<Scope<'a>>,
    declarations: BTreeMap<&'a str, Option<usize>>,
    referenced: BTreeSet<&'a str>,
    reserved: BTreeSet<String>,
    pinned: BTreeSet<String>,
    bindings: BTreeMap<&'a str, Option<&'a RecoveredBindingInfo>>,
    work: usize,
    limit: usize,
}

impl DisplayNames {
    pub fn plan(
        body: &[Stmt],
        annotations: Option<&Annotations>,
        bindings: &[RecoveredBindingInfo],
        config: &Config,
    ) -> Result<Self> {
        let mut planner = Planner {
            scopes: vec![Scope::default()],
            declarations: BTreeMap::new(),
            referenced: BTreeSet::new(),
            reserved: BTreeSet::new(),
            pinned: BTreeSet::new(),
            bindings: BTreeMap::new(),
            work: 0,
            limit: config.limits.max_analysis_steps,
        };
        for binding in bindings {
            planner
                .bindings
                .entry(&binding.name)
                .and_modify(|binding| *binding = None)
                .or_insert(Some(binding));
        }
        planner.collect(body)?;
        if let Some(annotations) = annotations {
            for alias in &annotations.aliases {
                planner.reserved.insert(alias.name.clone());
                planner.type_references(&alias.ty)?;
            }
            for ty in annotations.locals.values() {
                planner.type_references(ty)?;
            }
            for function in annotations.functions.values() {
                for ty in function.parameters.iter().flatten() {
                    planner.type_references(ty)?;
                }
                for tail in function.variadic.iter().chain(
                    function
                        .returns
                        .iter()
                        .filter_map(|pack| pack.tail.as_ref()),
                ) {
                    if let crate::ast::PackTail::Variadic(ty) = tail {
                        planner.type_references(ty)?;
                    }
                }
                for ty in function.returns.iter().flat_map(|pack| &pack.head) {
                    planner.type_references(ty)?;
                }
            }
        }
        for source in config
            .typing
            .binding_types
            .values()
            .chain(config.typing.globals.values())
            .chain(config.validation.project.external_globals.values())
            .chain(config.validation.project.instance_types.values())
        {
            planner.type_references(&crate::type_ast::parse_type(source)?)?;
        }
        planner.assign(config)
    }

    pub fn name<'s>(&'s self, internal: &'s str) -> &'s str {
        self.names.get(internal).map_or(internal, String::as_str)
    }
}

impl<'a> Planner<'a> {
    fn step(&mut self) -> Result<()> {
        self.work = self.work.saturating_add(1);
        if self.work > self.limit {
            return Err(Error::new(
                "limit",
                "scope presentation work budget exceeded",
            ));
        }
        crate::execution::charge_work(1)
    }

    fn scope(&mut self, parent: usize) -> Result<usize> {
        self.step()?;
        crate::execution::reserve_ast_capacity(std::mem::size_of::<Scope<'_>>() + 128)?;
        let scope = self.scopes.len();
        self.scopes.push(Scope {
            parent: Some(parent),
            ..Scope::default()
        });
        Ok(scope)
    }

    fn declare(&mut self, name: &'a str, scope: usize) -> Result<()> {
        self.step()?;
        crate::execution::reserve_ast_capacity(512 + name.len().saturating_mul(3))?;
        self.scopes[scope].declarations.push(name);
        self.declarations
            .entry(name)
            .and_modify(|scope| *scope = None)
            .or_insert(Some(scope));
        Ok(())
    }

    fn collect(&mut self, body: &'a [Stmt]) -> Result<()> {
        let mut pending: Vec<_> = body
            .iter()
            .rev()
            .map(|statement| Visit::Statement(statement, 0, 0))
            .collect();
        while let Some(visit) = pending.pop() {
            self.step()?;
            let depth = match &visit {
                Visit::Declarations(_, _, depth)
                | Visit::Statement(_, _, depth)
                | Visit::Expression(_, _, depth) => *depth,
            };
            if depth > 256 {
                return Err(Error::new(
                    "limit",
                    "scope presentation nesting limit exceeded",
                ));
            }
            match visit {
                Visit::Declarations(names, scope, _) => {
                    for name in names {
                        self.declare(name, scope)?;
                    }
                }
                Visit::Statement(statement, scope, depth) => match statement {
                    Stmt::Local(names, values) => {
                        pending.push(Visit::Declarations(names, scope, depth));
                        pending.extend(
                            values
                                .iter()
                                .rev()
                                .map(|value| Visit::Expression(value, scope, depth + 1)),
                        );
                    }
                    Stmt::Assign(targets, values) => {
                        pending.extend(
                            values
                                .iter()
                                .rev()
                                .map(|value| Visit::Expression(value, scope, depth + 1)),
                        );
                        pending.extend(
                            targets
                                .iter()
                                .rev()
                                .map(|target| Visit::Expression(target, scope, depth + 1)),
                        );
                    }
                    Stmt::Call(value) => pending.push(Visit::Expression(value, scope, depth + 1)),
                    Stmt::Return(values) => pending.extend(
                        values
                            .iter()
                            .rev()
                            .map(|value| Visit::Expression(value, scope, depth + 1)),
                    ),
                    Stmt::If { condition, yes, no } => {
                        for branch in [no, yes] {
                            let inner = self.scope(scope)?;
                            pending.extend(
                                branch
                                    .iter()
                                    .rev()
                                    .map(|statement| Visit::Statement(statement, inner, depth + 1)),
                            );
                        }
                        pending.push(Visit::Expression(condition, scope, depth + 1));
                    }
                    Stmt::While { condition, body } => {
                        let inner = self.scope(scope)?;
                        pending.extend(
                            body.iter()
                                .rev()
                                .map(|statement| Visit::Statement(statement, inner, depth + 1)),
                        );
                        pending.push(Visit::Expression(condition, scope, depth + 1));
                    }
                    Stmt::Repeat { body, until } => {
                        let inner = self.scope(scope)?;
                        pending.push(Visit::Expression(until, inner, depth + 1));
                        pending.extend(
                            body.iter()
                                .rev()
                                .map(|statement| Visit::Statement(statement, inner, depth + 1)),
                        );
                    }
                    Stmt::NumericFor {
                        variable,
                        start,
                        limit,
                        step,
                        body,
                    } => {
                        let inner = self.scope(scope)?;
                        self.declare(variable, inner)?;
                        pending.extend(
                            body.iter()
                                .rev()
                                .map(|statement| Visit::Statement(statement, inner, depth + 1)),
                        );
                        pending.extend(
                            [step, limit, start]
                                .into_iter()
                                .map(|value| Visit::Expression(value, scope, depth + 1)),
                        );
                    }
                    Stmt::GenericFor {
                        variables,
                        iterators,
                        body,
                    } => {
                        let inner = self.scope(scope)?;
                        for variable in variables {
                            self.declare(variable, inner)?;
                        }
                        pending.extend(
                            body.iter()
                                .rev()
                                .map(|statement| Visit::Statement(statement, inner, depth + 1)),
                        );
                        pending.extend(
                            iterators
                                .iter()
                                .rev()
                                .map(|value| Visit::Expression(value, scope, depth + 1)),
                        );
                    }
                    Stmt::Do(body) => {
                        let inner = self.scope(scope)?;
                        pending.extend(
                            body.iter()
                                .rev()
                                .map(|statement| Visit::Statement(statement, inner, depth + 1)),
                        );
                    }
                    Stmt::Break | Stmt::Continue => {}
                },
                Visit::Expression(expression, scope, depth) => match expression {
                    Expr::Name(name) => {
                        self.referenced.insert(name);
                        let declaration = self.declarations.get(name.as_str()).copied().flatten();
                        if match declaration {
                            Some(declaration) => !self.visible(scope, declaration)?,
                            None => true,
                        } {
                            self.pinned.insert(name.clone());
                        }
                    }
                    Expr::Global(name) => {
                        self.reserved.insert(name.clone());
                    }
                    Expr::Function(function) => {
                        let inner = self.scope(scope)?;
                        for parameter in &function.parameters {
                            self.declare(parameter, inner)?;
                        }
                        pending.extend(
                            function
                                .body
                                .iter()
                                .rev()
                                .map(|statement| Visit::Statement(statement, inner, depth + 1)),
                        );
                    }
                    Expr::Unary(_, value) | Expr::Single(value) | Expr::Field(value, _) => {
                        pending.push(Visit::Expression(value, scope, depth + 1))
                    }
                    Expr::Binary(_, left, right) | Expr::Index(left, right) => pending.extend(
                        [right.as_ref(), left.as_ref()]
                            .into_iter()
                            .map(|value| Visit::Expression(value, scope, depth + 1)),
                    ),
                    Expr::Call(function, arguments) | Expr::MethodCall(function, _, arguments) => {
                        pending.extend(
                            arguments
                                .iter()
                                .rev()
                                .map(|argument| Visit::Expression(argument, scope, depth + 1)),
                        );
                        pending.push(Visit::Expression(function, scope, depth + 1));
                    }
                    Expr::Table(fields) => {
                        for (key, value) in fields.iter().rev() {
                            pending.push(Visit::Expression(value, scope, depth + 1));
                            if let Some(key) = key {
                                pending.push(Visit::Expression(key, scope, depth + 1));
                            }
                        }
                    }
                    Expr::IfElse(condition, yes, no) => pending.extend(
                        [no.as_ref(), yes.as_ref(), condition.as_ref()]
                            .into_iter()
                            .map(|value| Visit::Expression(value, scope, depth + 1)),
                    ),
                    Expr::Literal(_) | Expr::Vararg => {}
                },
            }
        }
        for name in &self.referenced {
            if !self.declarations.contains_key(name) {
                self.reserved.insert((*name).into());
            }
        }
        Ok(())
    }

    fn type_references(&mut self, ty: &TypeExpr) -> Result<()> {
        let mut pending = vec![(ty, 0)];
        while let Some((ty, depth)) = pending.pop() {
            self.step()?;
            if depth > 64 {
                return Err(Error::new(
                    "limit",
                    "scope type dependency nesting limit exceeded",
                ));
            }
            match ty {
                TypeExpr::Named(name) | TypeExpr::Apply(name, _) => {
                    for token in name.split(|character: char| {
                        !character.is_ascii_alphanumeric() && character != '_'
                    }) {
                        if self.declarations.contains_key(token) {
                            self.pinned.insert(token.into());
                        }
                    }
                    if let TypeExpr::Apply(_, arguments) = ty {
                        pending.extend(arguments.iter().map(|ty| (ty, depth + 1)));
                    }
                }
                TypeExpr::Optional(ty) | TypeExpr::Array(ty) => pending.push((ty, depth + 1)),
                TypeExpr::Union(types) | TypeExpr::Intersection(types) => {
                    pending.extend(types.iter().map(|ty| (ty, depth + 1)))
                }
                TypeExpr::Record(fields) => {
                    pending.extend(fields.values().map(|ty| (ty, depth + 1)))
                }
                TypeExpr::Dictionary(key, value) => {
                    pending.extend([(key.as_ref(), depth + 1), (value.as_ref(), depth + 1)])
                }
                TypeExpr::Function(function) => {
                    pending.extend(
                        function
                            .parameters
                            .iter()
                            .chain(&function.returns.head)
                            .map(|ty| (ty, depth + 1)),
                    );
                    for tail in function.variadic.iter().chain(function.returns.tail.iter()) {
                        if let crate::ast::PackTail::Variadic(ty) = tail {
                            pending.push((ty, depth + 1));
                        }
                    }
                }
                _ => {}
            }
        }
        Ok(())
    }

    fn fixed(&self, name: &str) -> bool {
        self.pinned.contains(name)
            || self.declarations.get(name).is_none_or(Option::is_none)
            || self
                .bindings
                .get(name)
                .and_then(|binding| *binding)
                .is_none_or(|binding| binding.naming_origin == "override")
    }

    fn visible(&mut self, mut scope: usize, declaration: usize) -> Result<bool> {
        loop {
            self.step()?;
            if scope == declaration {
                return Ok(true);
            }
            let Some(parent) = self.scopes[scope].parent else {
                return Ok(false);
            };
            scope = parent;
        }
    }

    fn available(&mut self, mut scope: usize, name: &str) -> Result<bool> {
        if self.reserved.contains(name) {
            return Ok(false);
        }
        loop {
            self.step()?;
            if self.scopes[scope].used.contains(name) {
                return Ok(false);
            }
            let Some(parent) = self.scopes[scope].parent else {
                return Ok(true);
            };
            scope = parent;
        }
    }

    fn assign(mut self, config: &Config) -> Result<DisplayNames> {
        let mut names = BTreeMap::new();
        let fixed: Vec<_> = self
            .declarations
            .keys()
            .filter(|name| self.fixed(name))
            .map(|name| (*name).to_owned())
            .collect();
        self.reserved.extend(fixed);
        for scope in 0..self.scopes.len() {
            for name in self.scopes[scope].declarations.clone() {
                if self.fixed(name) {
                    self.scopes[scope].used.insert(name.into());
                }
            }
            for name in self.scopes[scope].declarations.clone() {
                self.step()?;
                if self.fixed(name) {
                    continue;
                }
                let binding = self.bindings[name].unwrap();
                let style = if config.naming == NameStyle::Roblox
                    && matches!(binding.name_role, "service" | "module")
                {
                    NameStyle::PascalCase
                } else {
                    config.naming
                };
                let base = if config.naming_options.use_debug_names {
                    binding
                        .debug_name
                        .as_deref()
                        .filter(|name| name.len() <= 128 && crate::names::is_identifier(name))
                        .map(|name| crate::names::identifier(name, style))
                } else {
                    None
                }
                .unwrap_or_else(|| crate::names::identifier(&binding.name_hint, style));
                let mut suffix = self.scopes[scope]
                    .next_suffix
                    .get(&base)
                    .copied()
                    .unwrap_or(1);
                let printed = loop {
                    let candidate = if suffix == 1 {
                        base.clone()
                    } else if style == NameStyle::SnakeCase {
                        format!("{base}_{suffix}")
                    } else {
                        format!("{base}{suffix}")
                    };
                    if self.available(scope, &candidate)? {
                        break candidate;
                    }
                    suffix = suffix.checked_add(1).ok_or_else(|| {
                        Error::new("limit", "scope name collision budget exceeded")
                    })?;
                };
                let next = suffix
                    .checked_add(1)
                    .ok_or_else(|| Error::new("limit", "scope name collision budget exceeded"))?;
                self.scopes[scope].next_suffix.insert(base, next);
                self.scopes[scope].used.insert(printed.clone());
                names.insert(name.into(), printed);
            }
        }
        Ok(DisplayNames { names })
    }
}
