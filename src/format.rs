use crate::ast::{Expr, Stmt};
use crate::type_ast::Annotations;
use crate::types::{GeneratedRegion, RegionKind};
use crate::{Config, Error, Result};

pub(crate) fn local_function_syntax(
    names: &[String],
    values: &[Expr],
    options: &crate::types::FormattingConfig,
    annotations: Option<&Annotations>,
    function_index: usize,
) -> bool {
    if !options.local_functions || names.len() != 1 || values.len() != 1 {
        return false;
    }
    let Expr::Function(function) = &values[0] else {
        return false;
    };
    let mut self_reference = false;
    crate::ast::visit_body(&function.body, &mut |expression| {
        self_reference |=
            matches!(expression, Expr::Name(name) | Expr::Global(name) if name == &names[0]);
    });
    if self_reference {
        return false;
    }
    let Some(annotations) = annotations else {
        return true;
    };
    let Some(local_type) = annotations.locals.get(&names[0]) else {
        return true;
    };
    let crate::type_ast::TypeExpr::Function(expected) = local_type else {
        return false;
    };
    let Some(signature) = annotations.functions.get(&function_index) else {
        return false;
    };
    if expected.generics != signature.generics
        || expected.generic_packs != signature.generic_packs
        || expected.parameters.len() != function.parameters.len()
        || (function.vararg && signature.variadic.is_none())
    {
        return false;
    }
    let mut comparison = TypeComparison {
        annotations,
        remaining: 4096,
    };
    for (index, expected) in expected.parameters.iter().enumerate() {
        if !signature
            .parameters
            .get(index)
            .and_then(Option::as_ref)
            .is_some_and(|actual| comparison.ty(expected, actual, 0))
        {
            return false;
        }
    }
    let variadic = if function.vararg {
        signature.variadic.as_ref()
    } else {
        None
    };
    comparison.tail(expected.variadic.as_ref(), variadic, 0)
        && signature
            .returns
            .as_ref()
            .is_some_and(|returns| comparison.pack(&expected.returns, returns, 0))
}

struct TypeComparison<'a> {
    annotations: &'a Annotations,
    remaining: usize,
}
impl TypeComparison<'_> {
    fn alias<'a>(
        &'a self,
        ty: &crate::type_ast::TypeExpr,
    ) -> Option<&'a crate::type_ast::TypeExpr> {
        use crate::type_ast::TypeExpr;
        let (name, arguments) = match ty {
            TypeExpr::Named(name) => (name, &[][..]),
            TypeExpr::Apply(name, arguments) => (name, arguments.as_slice()),
            _ => return None,
        };
        self.annotations.aliases.iter().find(|alias| alias.name == *name
            && alias.generic_packs.is_empty() && alias.generics.len() == arguments.len()
            && alias.generics.iter().zip(arguments).all(|(name, argument)| matches!(argument, TypeExpr::Generic(actual) | TypeExpr::Named(actual) if actual == name)))
            .map(|alias| &alias.ty)
    }
    fn ty(
        &mut self,
        expected: &crate::type_ast::TypeExpr,
        actual: &crate::type_ast::TypeExpr,
        depth: usize,
    ) -> bool {
        use crate::type_ast::TypeExpr;
        if depth > 64 || self.remaining == 0 {
            return false;
        }
        self.remaining -= 1;
        if expected == actual {
            return true;
        }
        if let Some(alias) = self.alias(expected) {
            let annotations = self.annotations;
            let mut nested = TypeComparison {
                annotations,
                remaining: self.remaining,
            };
            let matches = nested.ty(alias, actual, depth + 1);
            self.remaining = nested.remaining;
            return matches;
        }
        if let Some(alias) = self.alias(actual) {
            let annotations = self.annotations;
            let mut nested = TypeComparison {
                annotations,
                remaining: self.remaining,
            };
            let matches = nested.ty(expected, alias, depth + 1);
            self.remaining = nested.remaining;
            return matches;
        }
        match (expected, actual) {
            (TypeExpr::Optional(a), TypeExpr::Optional(b))
            | (TypeExpr::Array(a), TypeExpr::Array(b)) => self.ty(a, b, depth + 1),
            (TypeExpr::Dictionary(ak, av), TypeExpr::Dictionary(bk, bv)) => {
                self.ty(ak, bk, depth + 1) && self.ty(av, bv, depth + 1)
            }
            (TypeExpr::Record(a), TypeExpr::Record(b)) => {
                a.len() == b.len()
                    && a.iter()
                        .zip(b)
                        .all(|((ak, av), (bk, bv))| ak == bk && self.ty(av, bv, depth + 1))
            }
            (TypeExpr::Union(a), TypeExpr::Union(b))
            | (TypeExpr::Intersection(a), TypeExpr::Intersection(b)) => {
                a.len() == b.len() && a.iter().zip(b).all(|(a, b)| self.ty(a, b, depth + 1))
            }
            (TypeExpr::Apply(an, a), TypeExpr::Apply(bn, b)) => {
                an == bn
                    && a.len() == b.len()
                    && a.iter().zip(b).all(|(a, b)| self.ty(a, b, depth + 1))
            }
            (TypeExpr::Function(a), TypeExpr::Function(b)) => {
                a.generics == b.generics
                    && a.generic_packs == b.generic_packs
                    && a.parameters.len() == b.parameters.len()
                    && a.parameters
                        .iter()
                        .zip(&b.parameters)
                        .all(|(a, b)| self.ty(a, b, depth + 1))
                    && self.tail(a.variadic.as_ref(), b.variadic.as_ref(), depth + 1)
                    && self.pack(&a.returns, &b.returns, depth + 1)
            }
            _ => false,
        }
    }
    fn tail(
        &mut self,
        expected: Option<&crate::type_ast::PackTail>,
        actual: Option<&crate::type_ast::PackTail>,
        depth: usize,
    ) -> bool {
        use crate::type_ast::PackTail;
        match (expected, actual) {
            (None, None) => true,
            (Some(PackTail::Generic(a)), Some(PackTail::Generic(b))) => a == b,
            (Some(PackTail::Variadic(a)), Some(PackTail::Variadic(b))) => self.ty(a, b, depth + 1),
            _ => false,
        }
    }
    fn pack(
        &mut self,
        expected: &crate::type_ast::TypePack,
        actual: &crate::type_ast::TypePack,
        depth: usize,
    ) -> bool {
        expected.head.len() == actual.head.len()
            && expected
                .head
                .iter()
                .zip(&actual.head)
                .all(|(a, b)| self.ty(a, b, depth + 1))
            && self.tail(expected.tail.as_ref(), actual.tail.as_ref(), depth + 1)
    }
}

pub fn format(body: &[Stmt], config: &Config) -> Result<String> {
    Ok(format_with_annotations(body, config, None, None, &[])?.0)
}
pub fn format_typed(
    body: &[Stmt],
    config: &Config,
    annotations: &Annotations,
    origin: usize,
    bindings: &[crate::structure::RecoveredBindingInfo],
) -> Result<(String, Vec<GeneratedRegion>)> {
    format_with_annotations(body, config, Some(annotations), Some(origin), bindings)
}
fn format_with_annotations<'a>(
    body: &[Stmt],
    config: &'a Config,
    annotations: Option<&'a Annotations>,
    origin: Option<usize>,
    bindings: &'a [crate::structure::RecoveredBindingInfo],
) -> Result<(String, Vec<GeneratedRegion>)> {
    validate_complexity(body, config)?;
    let mut binding_map = std::collections::BTreeMap::<
        usize,
        std::collections::BTreeMap<&str, &crate::structure::RecoveredBindingInfo>,
    >::new();
    let mut unique_bindings =
        std::collections::BTreeMap::<&str, Option<&crate::structure::RecoveredBindingInfo>>::new();
    for binding in bindings {
        binding_map
            .entry(binding.proto)
            .or_default()
            .insert(&binding.name, binding);
        unique_bindings
            .entry(&binding.name)
            .and_modify(|entry| {
                if entry.is_some_and(|old| old.proto != binding.proto || old.id != binding.id) {
                    *entry = None
                }
            })
            .or_insert(Some(binding));
    }
    let mut printer = Printer {
        output: String::new(),
        indent: &config.indent,
        limit: config.limits.max_output_bytes,
        options: &config.formatting,
        annotations,
        next_function: 0,
        current_proto: origin,
        regions: Vec::new(),
        line: 1,
        column: 0,
        bindings: binding_map,
        unique_bindings,
        reservation: crate::execution::output_buffer()?,
    };
    printer.text(&crate::attribution::prefix(
        annotations.is_some_and(|a| a.strict),
    ))?;
    if let Some(annotations) = annotations {
        for alias in &annotations.aliases {
            let first_line = printer.line;
            if alias.exported {
                printer.text("export ")?;
            }
            printer.text("type ")?;
            printer.text(&alias.name)?;
            printer.text(&crate::type_ast::generic_declaration(
                &alias.generics,
                &alias.generic_packs,
            ))?;
            printer.text(" = ")?;
            printer.type_expr(&alias.ty, 0)?;
            printer.text("\n\n")?;
            printer.push_region(GeneratedRegion {
                node_id: printer.regions.len(),
                kind: RegionKind::TypeAlias,
                proto: alias.origin,
                first_line,
                last_line: printer.line.saturating_sub(2),
                first_column: 1,
                last_column: 1,
                transformations: vec!["generated_type_alias".into()],
                ..GeneratedRegion::default()
            })?;
        }
    }
    printer.body(body, 0)?;
    if body.is_empty() {
        printer.text("return\n")?;
    }
    Ok((printer.output, printer.regions))
}

pub fn validate_complexity(body: &[Stmt], config: &Config) -> Result<()> {
    validate_shape(body, config)?;
    validate_function_bindings(body, &[])?;
    Ok(())
}

pub fn validate_shape(body: &[Stmt], config: &Config) -> Result<()> {
    enum Node<'a> {
        Statement(&'a Stmt),
        Expression(&'a Expr),
    }
    let mut stack: Vec<_> = body
        .iter()
        .map(|stmt| (Node::Statement(stmt), 0usize))
        .collect();
    let mut nodes = 0usize;
    while let Some((node, depth)) = stack.pop() {
        nodes += 1;
        if nodes & 255 == 0 {
            crate::execution::checkpoint()?;
        }
        if nodes > config.limits.max_analysis_steps {
            return Err(Error::new("limit", "AST node budget exceeded"));
        }
        if depth > 256 {
            return Err(Error::new("limit", "source syntax nesting exceeds 256"));
        }
        let next = depth + 1;
        match node {
            Node::Statement(stmt) => match stmt {
                Stmt::Local(_, values) | Stmt::Return(values) => {
                    for e in values {
                        stack.push((Node::Expression(e), next));
                    }
                }
                Stmt::Assign(targets, values) => {
                    for e in targets.iter().chain(values) {
                        stack.push((Node::Expression(e), next));
                    }
                }
                Stmt::Call(e) => stack.push((Node::Expression(e), next)),
                Stmt::If { condition, yes, no } => {
                    stack.push((Node::Expression(condition), next));
                    for s in yes.iter().chain(no) {
                        stack.push((Node::Statement(s), next));
                    }
                }
                Stmt::While { condition, body }
                | Stmt::Repeat {
                    until: condition,
                    body,
                } => {
                    stack.push((Node::Expression(condition), next));
                    for s in body {
                        stack.push((Node::Statement(s), next));
                    }
                }
                Stmt::NumericFor {
                    start,
                    limit,
                    step,
                    body,
                    ..
                } => {
                    for e in [start, limit, step] {
                        stack.push((Node::Expression(e), next));
                    }
                    for s in body {
                        stack.push((Node::Statement(s), next));
                    }
                }
                Stmt::GenericFor {
                    iterators, body, ..
                } => {
                    for e in iterators {
                        stack.push((Node::Expression(e), next));
                    }
                    for s in body {
                        stack.push((Node::Statement(s), next));
                    }
                }
                Stmt::Do(body) => {
                    for s in body {
                        stack.push((Node::Statement(s), next));
                    }
                }
                _ => {}
            },
            Node::Expression(expr) => match expr {
                Expr::Unary(_, e) | Expr::Single(e) | Expr::Field(e, _) => {
                    stack.push((Node::Expression(e), next))
                }
                Expr::Binary(_, a, b) | Expr::Index(a, b) => {
                    stack.push((Node::Expression(a), next));
                    stack.push((Node::Expression(b), next));
                }
                Expr::Call(f, args) | Expr::MethodCall(f, _, args) => {
                    stack.push((Node::Expression(f), next));
                    for e in args {
                        stack.push((Node::Expression(e), next));
                    }
                }
                Expr::Table(fields) => {
                    for (key, value) in fields {
                        if let Some(key) = key {
                            stack.push((Node::Expression(key), next));
                        }
                        stack.push((Node::Expression(value), next));
                    }
                }
                Expr::Function(f) => {
                    for s in &f.body {
                        stack.push((Node::Statement(s), next));
                    }
                }
                Expr::IfElse(c, a, b) => {
                    for e in [c, a, b] {
                        stack.push((Node::Expression(e), next));
                    }
                }
                _ => {}
            },
        }
    }
    Ok(())
}

fn validate_function_bindings(
    body: &[Stmt],
    parameters: &[String],
) -> Result<std::collections::BTreeSet<String>> {
    if parameters.len() > 200 {
        return Err(Error::new(
            "limit",
            "function parameter count exceeds the local binding limit",
        ));
    }
    let mut defined: std::collections::BTreeSet<_> = parameters.iter().cloned().collect();
    let mut referenced = std::collections::BTreeSet::new();
    validate_scope_bindings(body, parameters.len(), &mut defined, &mut referenced)?;
    referenced.retain(|name| !defined.contains(name));
    if referenced.len() > 200 {
        return Err(Error::new(
            "limit",
            "generated function would exceed Luau's 200 upvalue limit",
        ));
    }
    Ok(referenced)
}

fn binding_expression(
    expr: &Expr,
    referenced: &mut std::collections::BTreeSet<String>,
) -> Result<()> {
    match expr {
        Expr::Name(name) => {
            referenced.insert(name.clone());
        }
        Expr::Function(function) => {
            referenced.extend(validate_function_bindings(
                &function.body,
                &function.parameters,
            )?);
        }
        Expr::Unary(_, e) | Expr::Single(e) | Expr::Field(e, _) => {
            binding_expression(e, referenced)?
        }
        Expr::Binary(_, a, b) | Expr::Index(a, b) => {
            binding_expression(a, referenced)?;
            binding_expression(b, referenced)?;
        }
        Expr::Call(f, args) | Expr::MethodCall(f, _, args) => {
            binding_expression(f, referenced)?;
            for arg in args {
                binding_expression(arg, referenced)?;
            }
        }
        Expr::Table(fields) => {
            for (key, value) in fields {
                if let Some(key) = key {
                    binding_expression(key, referenced)?;
                }
                binding_expression(value, referenced)?;
            }
        }
        Expr::IfElse(c, a, b) => {
            for e in [c, a, b] {
                binding_expression(e, referenced)?;
            }
        }
        _ => {}
    }
    Ok(())
}

fn validate_scope_bindings(
    body: &[Stmt],
    mut active: usize,
    defined: &mut std::collections::BTreeSet<String>,
    referenced: &mut std::collections::BTreeSet<String>,
) -> Result<()> {
    for stmt in body {
        match stmt {
            Stmt::Local(names, values) => {
                active += names.len();
                if active > 200 {
                    return Err(Error::new(
                        "limit",
                        "generated scope would exceed Luau's 200 local binding limit",
                    ));
                }
                defined.extend(names.iter().cloned());
                for e in values {
                    binding_expression(e, referenced)?;
                }
            }
            Stmt::Assign(targets, values) => {
                for e in targets.iter().chain(values) {
                    binding_expression(e, referenced)?;
                }
            }
            Stmt::Call(e) => binding_expression(e, referenced)?,
            Stmt::Return(values) => {
                for e in values {
                    binding_expression(e, referenced)?;
                }
            }
            Stmt::If { condition, yes, no } => {
                binding_expression(condition, referenced)?;
                validate_scope_bindings(yes, active, defined, referenced)?;
                validate_scope_bindings(no, active, defined, referenced)?;
            }
            Stmt::While { condition, body }
            | Stmt::Repeat {
                until: condition,
                body,
            } => {
                binding_expression(condition, referenced)?;
                validate_scope_bindings(body, active, defined, referenced)?;
            }
            Stmt::NumericFor {
                variable,
                start,
                limit,
                step,
                body,
            } => {
                for e in [start, limit, step] {
                    binding_expression(e, referenced)?;
                }
                defined.insert(variable.clone());
                if active + 1 > 200 {
                    return Err(Error::new(
                        "limit",
                        "numeric loop would exceed Luau's local binding limit",
                    ));
                }
                validate_scope_bindings(body, active + 1, defined, referenced)?;
            }
            Stmt::GenericFor {
                variables,
                iterators,
                body,
            } => {
                for e in iterators {
                    binding_expression(e, referenced)?;
                }
                defined.extend(variables.iter().cloned());
                if active + variables.len() > 200 {
                    return Err(Error::new(
                        "limit",
                        "generic loop would exceed Luau's local binding limit",
                    ));
                }
                validate_scope_bindings(body, active + variables.len(), defined, referenced)?;
            }
            Stmt::Do(body) => validate_scope_bindings(body, active, defined, referenced)?,
            _ => {}
        }
    }
    Ok(())
}

fn prefix_needs_parentheses(expr: &Expr) -> bool {
    !matches!(
        expr,
        Expr::Name(_)
            | Expr::Global(_)
            | Expr::Index(..)
            | Expr::Field(..)
            | Expr::Call(..)
            | Expr::MethodCall(..)
            | Expr::Single(_)
    )
}

fn starts_with_parenthesis(expr: &Expr) -> bool {
    match expr {
        Expr::Single(_) => true,
        Expr::Index(object, _)
        | Expr::Field(object, _)
        | Expr::Call(object, _)
        | Expr::MethodCall(object, _, _) => {
            if let Expr::Single(inner) = object.as_ref() {
                if matches!(inner.as_ref(), Expr::Call(..) | Expr::MethodCall(..)) {
                    return starts_with_parenthesis(inner);
                }
            }
            prefix_needs_parentheses(object) || starts_with_parenthesis(object)
        }
        _ => false,
    }
}
struct Printer<'a> {
    output: String,
    indent: &'a str,
    limit: usize,
    options: &'a crate::types::FormattingConfig,
    annotations: Option<&'a Annotations>,
    next_function: usize,
    current_proto: Option<usize>,
    regions: Vec<GeneratedRegion>,
    line: usize,
    column: usize,
    bindings: std::collections::BTreeMap<
        usize,
        std::collections::BTreeMap<&'a str, &'a crate::structure::RecoveredBindingInfo>,
    >,
    unique_bindings:
        std::collections::BTreeMap<&'a str, Option<&'a crate::structure::RecoveredBindingInfo>>,
    reservation: crate::execution::OutputReservation,
}
impl<'a> Printer<'a> {
    fn text(&mut self, text: &str) -> Result<()> {
        if self.output.len().saturating_add(text.len()) > self.limit {
            return Err(Error::new(
                "limit",
                "formatted source exceeds output byte limit",
            ));
        }
        let needed = self.output.len() + text.len();
        if needed > self.output.capacity() {
            let capacity = needed
                .max(self.output.capacity().saturating_mul(2))
                .max(64)
                .min(self.limit);
            self.reservation.reserve_capacity(capacity)?;
            self.output
                .try_reserve_exact(capacity.saturating_sub(self.output.len()))
                .map_err(|_| Error::new("memory", "unable to grow formatted output"))?;
            self.reservation.reserve_capacity(self.output.capacity())?;
        }
        self.output.push_str(text);
        for part in text.split_inclusive('\n') {
            if part.ends_with('\n') {
                self.line += 1;
                self.column = 0;
            } else {
                self.column += part.chars().count();
            }
        }
        Ok(())
    }
    fn indentation(&mut self, depth: usize) -> Result<()> {
        for _ in 0..depth {
            self.text(self.indent)?;
        }
        Ok(())
    }
    fn list(&mut self, values: &[Expr], depth: usize) -> Result<()> {
        for (n, e) in values.iter().enumerate() {
            if n != 0 {
                self.text(", ")?;
            }
            self.expr(e, 0, depth)?;
        }
        Ok(())
    }
    fn names(&mut self, names: &[String]) -> Result<()> {
        for (n, name) in names.iter().enumerate() {
            if n != 0 {
                self.text(", ")?;
            }
            self.text(name)?;
        }
        Ok(())
    }
    fn type_expr(&mut self, ty: &crate::type_ast::TypeExpr, depth: usize) -> Result<()> {
        if let crate::type_ast::TypeExpr::Record(fields) = ty {
            if fields.len() > 1
                && (self.options.multiline_tables
                    || self.column + ty.luau().len() > self.options.line_width)
            {
                self.text("{\n")?;
                for (name, ty) in fields {
                    self.indentation(depth + 1)?;
                    if crate::names::is_identifier(name) {
                        self.text(name)?;
                    } else {
                        self.text("[")?;
                        self.text(&crate::names::quote(name.as_bytes()))?;
                        self.text("]")?;
                    }
                    self.text(": ")?;
                    self.type_expr(ty, depth + 1)?;
                    self.text(",\n")?;
                }
                self.indentation(depth)?;
                return self.text("}");
            }
        }
        self.text(&ty.luau())
    }
    fn body(&mut self, body: &[Stmt], depth: usize) -> Result<()> {
        for (index, stmt) in body.iter().enumerate() {
            let blank = matches!(stmt, Stmt::Return(_))
                || matches!(stmt,Stmt::Local(_,values)if values.iter().any(|e|matches!(e,Expr::Function(_))))
                || index.checked_sub(1).is_some_and(|previous| {
                    matches!(&body[previous],Stmt::Local(_,values)if values.iter().any(|e|matches!(e,Expr::Function(_))))
                });
            if index != 0 && self.options.blank_lines && blank {
                self.text("\n")?;
            }
            self.stmt(stmt, depth, index != 0)?;
        }
        Ok(())
    }
    fn prefix(&mut self, expr: &Expr, depth: usize) -> Result<()> {
        if let Expr::Single(inner) = expr {
            if matches!(inner.as_ref(), Expr::Call(..) | Expr::MethodCall(..)) {
                return self.expr(inner, 9, depth);
            }
        }
        if prefix_needs_parentheses(expr) {
            self.text("(")?;
            self.expr(expr, 0, depth)?;
            self.text(")")
        } else {
            self.expr(expr, 9, depth)
        }
    }
    fn stmt(&mut self, stmt: &Stmt, depth: usize, has_previous: bool) -> Result<()> {
        crate::execution::charge_work(1)?;
        let first_line = self.line;
        self.indentation(depth)?;
        let needs_separator = match stmt {
            Stmt::Call(expr) => starts_with_parenthesis(expr),
            Stmt::Assign(targets, _) => targets.first().is_some_and(starts_with_parenthesis),
            _ => false,
        };
        if has_previous && needs_separator {
            self.text(";")?;
        }
        match stmt {
            Stmt::Local(names, values) => {
                if local_function_syntax(
                    names,
                    values,
                    self.options,
                    self.annotations,
                    self.next_function,
                ) {
                    if let Expr::Function(function) = &values[0] {
                        self.text("local ")?;
                        self.function(function, depth, Some(&names[0]))?;
                        self.record_statement(stmt, first_line)?;
                        return self.text("\n");
                    }
                }
                self.text("local ")?;
                self.typed_names(names)?;
                if !values.is_empty() {
                    self.text(" = ")?;
                    self.list(values, depth)?;
                }
            }
            Stmt::Assign(targets, values) => {
                self.list(targets, depth)?;
                self.text(" = ")?;
                self.list(values, depth)?;
            }
            Stmt::Call(expr) => self.expr(expr, 0, depth)?,
            Stmt::Return(values) => {
                self.text("return")?;
                if !values.is_empty() {
                    self.text(" ")?;
                    self.list(values, depth)?;
                }
            }
            Stmt::If { condition, yes, no } => {
                self.text("if ")?;
                self.expr(condition, 0, depth)?;
                self.text(" then\n")?;
                self.body(yes, depth + 1)?;
                if !no.is_empty() {
                    self.indentation(depth)?;
                    self.text("else\n")?;
                    self.body(no, depth + 1)?;
                }
                self.indentation(depth)?;
                self.text("end")?;
            }
            Stmt::While { condition, body } => {
                self.text("while ")?;
                self.expr(condition, 0, depth)?;
                self.text(" do\n")?;
                self.body(body, depth + 1)?;
                self.indentation(depth)?;
                self.text("end")?;
            }
            Stmt::Repeat { body, until } => {
                self.text("repeat\n")?;
                self.body(body, depth + 1)?;
                self.indentation(depth)?;
                self.text("until ")?;
                self.expr(until, 0, depth)?;
            }
            Stmt::NumericFor {
                variable,
                start,
                limit,
                step,
                body,
            } => {
                self.text("for ")?;
                self.text(variable)?;
                self.text(" = ")?;
                self.expr(start, 0, depth)?;
                self.text(", ")?;
                self.expr(limit, 0, depth)?;
                if !matches!(step,Expr::Literal(n) if n=="1") {
                    self.text(", ")?;
                    self.expr(step, 0, depth)?;
                }
                self.text(" do\n")?;
                self.body(body, depth + 1)?;
                self.indentation(depth)?;
                self.text("end")?;
            }
            Stmt::GenericFor {
                variables,
                iterators,
                body,
            } => {
                self.text("for ")?;
                self.names(variables)?;
                self.text(" in ")?;
                self.list(iterators, depth)?;
                self.text(" do\n")?;
                self.body(body, depth + 1)?;
                self.indentation(depth)?;
                self.text("end")?;
            }
            Stmt::Do(body) => {
                self.text("do\n")?;
                self.body(body, depth + 1)?;
                self.indentation(depth)?;
                self.text("end")?;
            }
            Stmt::Break => self.text("break")?,
            Stmt::Continue => self.text("continue")?,
        }
        self.record_statement(stmt, first_line)?;
        self.text("\n")
    }
    fn record_statement(&mut self, stmt: &Stmt, first_line: usize) -> Result<()> {
        let names = match stmt {
            Stmt::Local(names, _) => names.as_slice(),
            _ => &[],
        };
        if names.is_empty() {
            self.push_region(GeneratedRegion {
                node_id: self.regions.len(),
                kind: RegionKind::Statement,
                proto: self.current_proto,
                first_line,
                last_line: self.line,
                first_column: 1,
                last_column: self.column + 1,
                ..GeneratedRegion::default()
            })?;
        }
        for name in names {
            let binding = self.binding(name);
            self.push_region(GeneratedRegion {
                node_id: self.regions.len(),
                kind: RegionKind::Declaration,
                first_column: 1,
                last_column: self.column + 1,
                proto: binding.map(|b| b.proto).or(self.current_proto),
                binding: binding.map(|b| format!("p{}:b{}", b.proto, b.id)),
                first_pc: binding.map(|b| b.first_pc),
                last_pc: binding.map(|b| b.last_pc),
                first_line,
                last_line: self.line,
                transformations: if self
                    .annotations
                    .is_some_and(|a| a.locals.contains_key(name))
                {
                    vec!["local_type_annotation".into()]
                } else {
                    Vec::new()
                },
            })?;
        }
        Ok(())
    }
    fn typed_names(&mut self, names: &[String]) -> Result<()> {
        for (index, name) in names.iter().enumerate() {
            if index != 0 {
                self.text(", ")?;
            }
            self.text(name)?;
            if let Some(ty) = self.annotations.and_then(|a| a.locals.get(name)) {
                self.text(": ")?;
                self.text(&ty.luau())?;
            }
        }
        Ok(())
    }
    fn push_region(&mut self, region: GeneratedRegion) -> Result<()> {
        if self.regions.len() == self.regions.capacity() {
            let capacity = (self.regions.capacity().saturating_mul(2)).max(64);
            let additional = capacity.saturating_sub(self.regions.capacity());
            crate::execution::reserve_ast_capacity(
                additional.saturating_mul(std::mem::size_of::<GeneratedRegion>() + 96),
            )?;
            self.regions
                .try_reserve_exact(capacity.saturating_sub(self.regions.len()))
                .map_err(|_| Error::new("memory", "unable to grow generated source provenance"))?;
        }
        self.regions.push(region);
        Ok(())
    }
    fn binding(&self, name: &str) -> Option<&'a crate::structure::RecoveredBindingInfo> {
        if let Some(proto) = self.current_proto {
            if let Some(binding) = self
                .bindings
                .get(&proto)
                .and_then(|bindings| bindings.get(name))
            {
                return Some(*binding);
            }
        }
        self.unique_bindings.get(name).copied().flatten()
    }
    fn function(
        &mut self,
        function: &crate::ast::Function,
        depth: usize,
        name: Option<&str>,
    ) -> Result<()> {
        let id = self.next_function;
        self.next_function += 1;
        let annotation = self
            .annotations
            .and_then(|a| a.functions.get(&id))
            .cloned()
            .unwrap_or_default();
        let first_line = self.line;
        let first_column = self.column + 1;
        let outer = self.current_proto;
        self.current_proto = function.origin.or(outer);
        self.text("function")?;
        if let Some(name) = name {
            self.text(" ")?;
            self.text(name)?;
        }
        self.text(&crate::type_ast::generic_declaration(
            &annotation.generics,
            &annotation.generic_packs,
        ))?;
        self.text("(")?;
        for (index, name) in function.parameters.iter().enumerate() {
            if index != 0 {
                self.text(", ")?;
            }
            self.text(name)?;
            if let Some(Some(ty)) = annotation.parameters.get(index) {
                self.text(": ")?;
                self.text(&ty.luau())?;
            }
        }
        if function.vararg {
            if !function.parameters.is_empty() {
                self.text(", ")?;
            }
            self.text("...")?;
            if let Some(tail) = &annotation.variadic {
                self.text(": ")?;
                match tail {
                    crate::type_ast::PackTail::Variadic(ty) => self.text(&ty.luau())?,
                    crate::type_ast::PackTail::Generic(name) => {
                        self.text(name)?;
                        self.text("...")?;
                    }
                }
            }
        }
        self.text(")")?;
        if let Some(returns) = &annotation.returns {
            self.text(": ")?;
            if returns.head.len() == 1 && returns.tail.is_none() {
                self.text(&returns.head[0].luau())?;
            } else {
                self.text(&returns.luau())?;
            }
        }
        self.text("\n")?;
        self.body(&function.body, depth + 1)?;
        self.indentation(depth)?;
        self.text("end")?;
        self.push_region(GeneratedRegion {
            node_id: self.regions.len(),
            kind: RegionKind::Function,
            proto: self.current_proto,
            first_line,
            last_line: self.line,
            first_column,
            last_column: self.column + 1,
            transformations: if annotation.parameters.iter().any(Option::is_some)
                || annotation.returns.is_some()
                || annotation.variadic.is_some()
            {
                vec!["function_type_annotation".into()]
            } else {
                Vec::new()
            },
            ..GeneratedRegion::default()
        })?;
        self.current_proto = outer;
        Ok(())
    }
    fn expr(&mut self, expr: &Expr, parent: u8, depth: usize) -> Result<()> {
        crate::execution::charge_work(1)?;
        let first_line = self.line;
        let first_column = self.column + 1;
        let proto = if let Expr::Function(f) = expr {
            f.origin.or(self.current_proto)
        } else {
            self.current_proto
        };
        let prec = precedence(expr);
        let paren = prec < parent;
        if paren {
            self.text("(")?;
        }
        match expr {
            Expr::Literal(text) | Expr::Name(text) | Expr::Global(text) => self.text(text)?,
            Expr::Vararg => self.text("...")?,
            Expr::Single(value) => {
                self.text("(")?;
                self.expr(value, 0, depth)?;
                self.text(")")?;
            }
            Expr::Unary(op, value) => {
                self.text(op)?;
                if *op == "not"
                    || (*op == "-" && matches!(&**value, Expr::Unary("-", _) | Expr::Literal(_)))
                {
                    self.text(" ")?;
                }
                self.expr(value, 7, depth)?;
            }
            Expr::Binary(op, left, right) => {
                let right_associative = matches!(*op, "^" | "..");
                self.expr(left, prec + u8::from(right_associative), depth)?;
                self.text(" ")?;
                self.text(op)?;
                self.text(" ")?;
                self.expr(right, prec + u8::from(!right_associative), depth)?;
            }
            Expr::Index(object, key) => {
                self.prefix(object, depth)?;
                self.text("[")?;
                self.expr(key, 0, depth)?;
                self.text("]")?;
            }
            Expr::Field(object, name) => {
                self.prefix(object, depth)?;
                self.text(".")?;
                self.text(name)?;
            }
            Expr::Call(func, args) => {
                self.prefix(func, depth)?;
                self.text("(")?;
                self.call_arguments(args, depth)?;
                self.text(")")?;
            }
            Expr::MethodCall(object, name, args) => {
                self.prefix(object, depth)?;
                self.text(":")?;
                self.text(name)?;
                self.text("(")?;
                self.call_arguments(args, depth)?;
                self.text(")")?;
            }
            Expr::Table(fields) => {
                let multiline = self.options.multiline_tables
                    && (fields.len() > 3
                        || self.column + estimated_table(fields) > self.options.line_width);
                self.text("{")?;
                if multiline && !fields.is_empty() {
                    self.text("\n")?;
                }
                for (n, (key, value)) in fields.iter().enumerate() {
                    if multiline {
                        self.indentation(depth + 1)?;
                    } else if n != 0 {
                        self.text(", ")?;
                    }
                    if let Some(key) = key {
                        if let Expr::Literal(text) = key {
                            if let Ok(name) = serde_json::from_str::<String>(text) {
                                if crate::names::is_identifier(&name) {
                                    self.text(&name)?;
                                    self.text(" = ")?;
                                } else {
                                    self.text("[")?;
                                    self.expr(key, 0, depth)?;
                                    self.text("] = ")?;
                                }
                            } else {
                                self.text("[")?;
                                self.expr(key, 0, depth)?;
                                self.text("] = ")?;
                            }
                        } else {
                            self.text("[")?;
                            self.expr(key, 0, depth)?;
                            self.text("] = ")?;
                        }
                    }
                    self.expr(value, 0, if multiline { depth + 1 } else { depth })?;
                    if multiline {
                        self.text(",\n")?;
                    }
                }
                if multiline && !fields.is_empty() {
                    self.indentation(depth)?;
                }
                self.text("}")?;
            }
            Expr::Function(function) => {
                self.function(function, depth, None)?;
            }
            Expr::IfElse(cond, yes, no) => {
                self.text("if ")?;
                self.expr(cond, 0, depth)?;
                self.text(" then ")?;
                self.expr(yes, 0, depth)?;
                self.text(" else ")?;
                self.expr(no, 0, depth)?;
            }
        }
        if paren {
            self.text(")")?;
        }
        let binding = if let Expr::Name(name) = expr {
            self.binding(name)
        } else {
            None
        };
        self.push_region(GeneratedRegion {
            node_id: self.regions.len(),
            kind: RegionKind::Expression,
            proto,
            binding: binding.map(|b| format!("p{}:b{}", b.proto, b.id)),
            first_pc: binding.map(|b| b.first_pc),
            last_pc: binding.map(|b| b.last_pc),
            first_line,
            last_line: self.line,
            first_column,
            last_column: self.column + 1,
            transformations: if self.line > first_line && !matches!(expr, Expr::Function(_)) {
                vec!["multiline_format".into()]
            } else {
                Vec::new()
            },
        })?;
        Ok(())
    }
    fn call_arguments(&mut self, args: &[Expr], depth: usize) -> Result<()> {
        let multiline = self.options.multiline_calls
            && !args.is_empty()
            && self.column + args.iter().map(estimated_expr).sum::<usize>() + args.len() * 2
                > self.options.line_width;
        if multiline {
            self.text("\n")?;
            for (index, arg) in args.iter().enumerate() {
                self.indentation(depth + 1)?;
                self.expr(arg, 0, depth + 1)?;
                if index + 1 != args.len() {
                    self.text(",")?;
                }
                self.text("\n")?;
            }
            self.indentation(depth)
        } else {
            self.list(args, depth)
        }
    }
}
fn estimated_table(fields: &[(Option<Expr>, Expr)]) -> usize {
    fields
        .iter()
        .map(|(k, v)| k.as_ref().map_or(0, |k| estimated_expr(k) + 5) + estimated_expr(v) + 2)
        .sum::<usize>()
        .saturating_add(2)
}
fn estimated_expr(expr: &Expr) -> usize {
    match expr {
        Expr::Literal(s) | Expr::Name(s) | Expr::Global(s) => s.len(),
        Expr::Vararg => 3,
        Expr::Unary(_, e) | Expr::Single(e) => estimated_expr(e).saturating_add(4),
        Expr::Binary(_, a, b) | Expr::Index(a, b) => estimated_expr(a)
            .saturating_add(estimated_expr(b))
            .saturating_add(4),
        Expr::Field(o, n) => estimated_expr(o).saturating_add(n.len() + 1),
        Expr::Call(f, args) | Expr::MethodCall(f, _, args) => estimated_expr(f)
            .saturating_add(args.iter().map(estimated_expr).sum::<usize>())
            .saturating_add(args.len() * 2 + 2),
        Expr::Table(fields) => estimated_table(fields),
        Expr::Function(_) => 101,
        Expr::IfElse(a, b, c) => estimated_expr(a)
            .saturating_add(estimated_expr(b))
            .saturating_add(estimated_expr(c))
            .saturating_add(16),
    }
}
fn precedence(expr: &Expr) -> u8 {
    match expr {
        Expr::IfElse(..) => 0,
        Expr::Binary(op, ..) => match *op {
            "or" => 1,
            "and" => 2,
            "==" | "~=" | "<" | "<=" | ">" | ">=" => 3,
            ".." => 4,
            "+" | "-" => 5,
            "*" | "/" | "//" | "%" => 6,
            "^" => 8,
            _ => 0,
        },
        Expr::Unary(..) => 7,
        Expr::Literal(n) if n.starts_with('-') => 7,
        Expr::Index(..) | Expr::Field(..) | Expr::Call(..) | Expr::MethodCall(..) => 9,
        Expr::Function(..) | Expr::Table(..) => 0,
        _ => 10,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn preserves_nonassociative_operations() {
        let e = Expr::binary(
            "-",
            Expr::name("a"),
            Expr::binary("-", Expr::name("b"), Expr::name("c")),
        );
        let source = format(&[Stmt::Return(vec![e])], &Config::default()).unwrap();
        assert_eq!(
            source,
            format!("{}return a - (b - c)\n", crate::attribution::prefix(false))
        );
    }
    #[test]
    fn preserves_power_and_negation() {
        let e = Expr::binary("^", Expr::Literal("-2".into()), Expr::Literal("2".into()));
        assert_eq!(
            format(&[Stmt::Return(vec![e])], &Config::default()).unwrap(),
            format!("{}return (-2) ^ 2\n", crate::attribution::prefix(false))
        );
    }
    #[test]
    fn parenthesized_statement_cannot_attach_to_previous_rhs() {
        let function = crate::ast::Function {
            origin: None,
            parameters: vec![],
            vararg: false,
            body: vec![],
        };
        let body = [
            Stmt::Local(vec!["value".into()], vec![Expr::Literal("1".into())]),
            Stmt::Call(Expr::Call(
                Box::new(Expr::Function(Box::new(function))),
                vec![],
            )),
        ];
        let source = format(&body, &Config::default()).unwrap();
        assert!(source.contains("\n;(function("));
    }
    #[test]
    fn block_entry_does_not_emit_a_leading_statement_separator() {
        let call = Stmt::Call(Expr::Call(
            Box::new(Expr::Function(Box::new(crate::ast::Function {
                origin: None,
                parameters: vec![],
                vararg: false,
                body: vec![],
            }))),
            vec![],
        ));
        let body = [
            call.clone(),
            Stmt::If {
                condition: Expr::Literal("true".into()),
                yes: vec![call.clone()],
                no: vec![call.clone()],
            },
            Stmt::Local(
                vec!["invoke".into()],
                vec![Expr::Function(Box::new(crate::ast::Function {
                    origin: None,
                    parameters: vec![],
                    vararg: false,
                    body: vec![call],
                }))],
            ),
        ];
        let source = format(&body, &Config::default()).unwrap();
        assert!(!source.contains(';'), "{source}");
        let adjusted = Expr::MethodCall(
            Box::new(Expr::Single(Box::new(Expr::Call(
                Box::new(Expr::Global("make".into())),
                vec![],
            )))),
            "run".into(),
            vec![],
        );
        assert!(!starts_with_parenthesis(&adjusted));
    }
    #[test]
    fn literal_receiver_uses_prefix_expression_syntax() {
        let call = Expr::MethodCall(
            Box::new(Expr::Literal("\"abc\"".into())),
            "sub".into(),
            vec![Expr::Literal("2".into())],
        );
        assert_eq!(
            format(&[Stmt::Return(vec![call])], &Config::default()).unwrap(),
            format!(
                "{}return (\"abc\"):sub(2)\n",
                crate::attribution::prefix(false)
            )
        );
    }
    #[test]
    fn scalar_receiver_parentheses_do_not_change_open_return_adjustment() {
        let call = Expr::Call(Box::new(Expr::Global("values".into())), Vec::new());
        let body = [Stmt::Return(vec![Expr::Field(
            Box::new(Expr::Single(Box::new(call.clone()))),
            "field".into(),
        )])];
        assert_eq!(
            format(&body, &Config::default()).unwrap(),
            format!(
                "{}return values().field\n",
                crate::attribution::prefix(false)
            )
        );
        assert_eq!(
            format(
                &[Stmt::Return(vec![Expr::Single(Box::new(call))])],
                &Config::default()
            )
            .unwrap(),
            format!("{}return (values())\n", crate::attribution::prefix(false))
        );
    }
}
