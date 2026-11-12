pub use crate::type_ast::{
    Annotations, FunctionAnnotation, FunctionType, PackTail, TypeAlias, TypeExpr, TypePack,
    TypedProgram,
};
use std::collections::{BTreeMap, BTreeSet};

#[derive(Debug, Clone)]
pub enum Expr {
    Literal(String),
    Name(String),
    Global(String),
    Vararg,
    Unary(&'static str, Box<Expr>),
    Binary(&'static str, Box<Expr>, Box<Expr>),
    Index(Box<Expr>, Box<Expr>),
    Field(Box<Expr>, String),
    Call(Box<Expr>, Vec<Expr>),
    MethodCall(Box<Expr>, String, Vec<Expr>),
    Table(Vec<(Option<Expr>, Expr)>),
    Function(Box<Function>),
    Single(Box<Expr>),
    IfElse(Box<Expr>, Box<Expr>, Box<Expr>),
}

#[derive(Debug, Clone)]
pub struct Function {
    pub origin: Option<usize>,
    pub parameters: Vec<String>,
    pub vararg: bool,
    pub body: Vec<Stmt>,
}

#[derive(Debug, Clone)]
pub enum Stmt {
    Local(Vec<String>, Vec<Expr>),
    Assign(Vec<Expr>, Vec<Expr>),
    Call(Expr),
    If {
        condition: Expr,
        yes: Vec<Stmt>,
        no: Vec<Stmt>,
    },
    While {
        condition: Expr,
        body: Vec<Stmt>,
    },
    Repeat {
        body: Vec<Stmt>,
        until: Expr,
    },
    NumericFor {
        variable: String,
        start: Expr,
        limit: Expr,
        step: Expr,
        body: Vec<Stmt>,
    },
    GenericFor {
        variables: Vec<String>,
        iterators: Vec<Expr>,
        body: Vec<Stmt>,
    },
    Do(Vec<Stmt>),
    Return(Vec<Expr>),
    Break,
    Continue,
}

impl Expr {
    pub fn name(value: &str) -> Self {
        Self::Name(value.to_owned())
    }
    pub fn binary(op: &'static str, left: Self, right: Self) -> Self {
        Self::Binary(op, Box::new(left), Box::new(right))
    }
    pub fn negate(self) -> Self {
        match self {
            Self::Unary("not", value) => *value,
            Self::Binary("==", left, right) => Self::Binary("~=", left, right),
            Self::Binary("~=", left, right) => Self::Binary("==", left, right),
            other => Self::Unary("not", Box::new(other)),
        }
    }
    fn pure(&self) -> bool {
        match self {
            Self::Literal(_) | Self::Name(_) | Self::Vararg => true,
            Self::Single(value) | Self::Unary("not", value) => value.pure(),
            Self::Binary("and" | "or", left, right) => left.pure() && right.pure(),
            _ => false,
        }
    }
    fn scalar(self) -> Self {
        match self {
            Self::Call(..) | Self::MethodCall(..) | Self::Vararg => Self::Single(Box::new(self)),
            _ => self,
        }
    }
}

pub fn collect_names(body: &[Stmt]) -> BTreeMap<String, usize> {
    let mut names = BTreeMap::new();
    visit_body(body, &mut |e| {
        if let Expr::Name(name) = e {
            *names.entry(name.clone()).or_default() += 1;
        }
    });
    names
}

pub fn place_declarations(body: &mut Vec<Stmt>, names: BTreeSet<String>) {
    if names.is_empty() {
        return;
    }
    let mut occurrences = BTreeMap::<String, (usize, usize)>::new();
    for (index, stmt) in body.iter().enumerate() {
        visit_body(std::slice::from_ref(stmt), &mut |e| {
            if let Expr::Name(name) = e {
                if names.contains(name) {
                    let entry = occurrences.entry(name.clone()).or_insert((index, index));
                    entry.1 = index;
                }
            }
        });
    }
    let mut here = BTreeMap::<usize, Vec<String>>::new();
    let mut nested = BTreeMap::<(usize, usize), BTreeSet<String>>::new();
    for (name, (first, last)) in occurrences {
        let child = if first == last {
            sole_child_reference(&body[first], &name)
        } else {
            None
        };
        if let Some(child) = child {
            nested.entry((first, child)).or_default().insert(name);
        } else {
            here.entry(first).or_default().push(name);
        }
    }
    for ((index, child), names) in nested {
        match &mut body[index] {
            Stmt::If { yes, no, .. } => {
                place_declarations(if child == 0 { yes } else { no }, names)
            }
            Stmt::While { body, .. }
            | Stmt::Repeat { body, .. }
            | Stmt::NumericFor { body, .. }
            | Stmt::GenericFor { body, .. }
            | Stmt::Do(body) => place_declarations(body, names),
            _ => unreachable!("only structured statement bodies are child scopes"),
        }
    }
    let mut output = Vec::with_capacity(body.len() + here.len());
    for (index, mut stmt) in std::mem::take(body).into_iter().enumerate() {
        if let Some(names) = here.remove(&index) {
            let converted = match &stmt {
                Stmt::Assign(targets, values) if targets.len() == names.len() => {
                    let target_names: Option<Vec<_>> = targets
                        .iter()
                        .map(|target| match target {
                            Expr::Name(name) if names.contains(name) => Some(name.clone()),
                            _ => None,
                        })
                        .collect();
                    let mut self_reference = false;
                    for value in values {
                        visit_expr(value, &mut |e| {
                            if let Expr::Name(name) = e {
                                self_reference |= names.contains(name);
                            }
                        });
                    }
                    target_names.filter(|_| !self_reference)
                }
                _ => None,
            };
            if let Some(names) = converted {
                let Stmt::Assign(_, values) = stmt else {
                    unreachable!()
                };
                stmt = Stmt::Local(names, values);
            } else {
                output.push(Stmt::Local(names, Vec::new()));
            }
        }
        output.push(stmt);
    }
    *body = output;
}

fn sole_child_reference(stmt: &Stmt, name: &str) -> Option<usize> {
    let expr_has = |expr: &Expr| {
        let mut found = false;
        visit_expr(expr, &mut |e| {
            found |= matches!(e,Expr::Name(n) if n == name);
        });
        found
    };
    let body_has = |body: &[Stmt]| {
        let mut found = false;
        visit_body(body, &mut |e| {
            found |= matches!(e,Expr::Name(n) if n == name);
        });
        found
    };
    match stmt {
        Stmt::If { condition, yes, no } if !expr_has(condition) => {
            match (body_has(yes), body_has(no)) {
                (true, false) => Some(0),
                (false, true) => Some(1),
                _ => None,
            }
        }
        Stmt::While { condition, body } if !expr_has(condition) && body_has(body) => Some(0),
        Stmt::Repeat { until, body } if !expr_has(until) && body_has(body) => Some(0),
        Stmt::NumericFor {
            start,
            limit,
            step,
            body,
            ..
        } if !expr_has(start) && !expr_has(limit) && !expr_has(step) && body_has(body) => Some(0),
        Stmt::GenericFor {
            iterators, body, ..
        } if !iterators.iter().any(expr_has) && body_has(body) => Some(0),
        Stmt::Do(body) if body_has(body) => Some(0),
        _ => None,
    }
}

pub fn close_temporary_scopes(body: &mut Vec<Stmt>, budget: usize) -> crate::Result<usize> {
    let mut work = 0usize;
    for stmt in body.iter_mut() {
        crate::execution::checkpoint()?;
        match stmt {
            Stmt::If { yes, no, .. } => {
                work =
                    work.saturating_add(close_temporary_scopes(yes, budget.saturating_sub(work))?);
                work =
                    work.saturating_add(close_temporary_scopes(no, budget.saturating_sub(work))?);
            }
            Stmt::Do(inner)
            | Stmt::While { body: inner, .. }
            | Stmt::Repeat { body: inner, .. }
            | Stmt::NumericFor { body: inner, .. }
            | Stmt::GenericFor { body: inner, .. } => {
                work = work
                    .saturating_add(close_temporary_scopes(inner, budget.saturating_sub(work))?);
            }
            _ => {}
        }
    }
    let local_count = body
        .iter()
        .map(|stmt| match stmt {
            Stmt::Local(names, _) => names.len(),
            _ => 0,
        })
        .sum::<usize>();
    if local_count <= 160 {
        return Ok(work);
    }
    let mut last = BTreeMap::<String, usize>::new();
    for (index, stmt) in body.iter().enumerate() {
        visit_body(std::slice::from_ref(stmt), &mut |expr| {
            if let Expr::Name(name) = expr {
                last.insert(name.clone(), index);
            }
        });
    }
    let last_statement = body.len() - 1;
    let mut intervals = Vec::new();
    let mut start = 0;
    while start < body.len() {
        let Stmt::Local(names, _) = &body[start] else {
            start += 1;
            continue;
        };
        let mut end = names
            .iter()
            .filter_map(|name| last.get(name))
            .copied()
            .max()
            .unwrap_or(start)
            .max(start);
        if end == last_statement {
            start += 1;
            continue;
        }
        let mut cursor = start;
        let mut declarations = 0usize;
        while cursor <= end {
            work += 1;
            if work > budget {
                return Err(crate::Error::new(
                    "limit",
                    "local lifetime scope work exceeds analysis budget",
                ));
            }
            if let Stmt::Local(names, _) = &body[cursor] {
                declarations += names.len();
                for name in names {
                    end = end.max(last.get(name).copied().unwrap_or(cursor));
                }
            }
            cursor += 1;
        }
        if end == last_statement {
            start += 1;
            continue;
        }

        while declarations < 64 && end + 1 < last_statement {
            let mut next = end + 1;
            while next < last_statement && !matches!(&body[next], Stmt::Local(..)) {
                next += 1;
            }
            if next >= last_statement {
                break;
            }
            let Stmt::Local(names, _) = &body[next] else {
                unreachable!()
            };
            if names
                .iter()
                .any(|name| last.get(name) == Some(&last_statement))
            {
                break;
            }
            let old_end = end;
            let mut candidate = next;
            let mut scan = end + 1;
            let mut added = 0;
            while scan <= candidate {
                work += 1;
                if work > budget {
                    return Err(crate::Error::new(
                        "limit",
                        "local lifetime scope work exceeds analysis budget",
                    ));
                }
                if let Stmt::Local(names, _) = &body[scan] {
                    added += names.len();
                    for name in names {
                        candidate = candidate.max(last.get(name).copied().unwrap_or(scan));
                    }
                }
                scan += 1;
            }
            if candidate == last_statement || declarations + added > 96 {
                end = old_end;
                break;
            }
            end = candidate;
            declarations += added;
        }
        intervals.push((start, end));
        start = end + 1;
    }
    let mut ranges = intervals.into_iter().peekable();
    let mut statements = std::mem::take(body).into_iter().enumerate().peekable();
    while let Some((index, stmt)) = statements.next() {
        if ranges.peek().is_some_and(|&(start, _)| start == index) {
            let (_, end) = ranges.next().unwrap();
            let mut scope = vec![stmt];
            while statements.peek().is_some_and(|(index, _)| *index <= end) {
                scope.push(statements.next().unwrap().1);
            }
            body.push(Stmt::Do(scope));
        } else {
            body.push(stmt);
        }
    }
    Ok(work)
}

pub fn visit_expr(expr: &Expr, f: &mut impl FnMut(&Expr)) {
    f(expr);
    match expr {
        Expr::Unary(_, value) | Expr::Single(value) | Expr::Field(value, _) => visit_expr(value, f),
        Expr::Binary(_, left, right) | Expr::Index(left, right) => {
            visit_expr(left, f);
            visit_expr(right, f);
        }
        Expr::Call(func, args) | Expr::MethodCall(func, _, args) => {
            visit_expr(func, f);
            for e in args {
                visit_expr(e, f);
            }
        }
        Expr::Table(fields) => {
            for (key, value) in fields {
                if let Some(key) = key {
                    visit_expr(key, f);
                }
                visit_expr(value, f);
            }
        }
        Expr::Function(function) => visit_body(&function.body, f),
        Expr::IfElse(cond, yes, no) => {
            visit_expr(cond, f);
            visit_expr(yes, f);
            visit_expr(no, f);
        }
        _ => {}
    }
}
pub fn visit_body(body: &[Stmt], f: &mut impl FnMut(&Expr)) {
    for stmt in body {
        match stmt {
            Stmt::Local(_, values) | Stmt::Return(values) => {
                for value in values {
                    visit_expr(value, f);
                }
            }
            Stmt::Assign(targets, values) => {
                for e in targets.iter().chain(values) {
                    visit_expr(e, f);
                }
            }
            Stmt::Call(expr) => visit_expr(expr, f),
            Stmt::If { condition, yes, no } => {
                visit_expr(condition, f);
                visit_body(yes, f);
                visit_body(no, f);
            }
            Stmt::While { condition, body } => {
                visit_expr(condition, f);
                visit_body(body, f);
            }
            Stmt::Repeat { body, until } => {
                visit_body(body, f);
                visit_expr(until, f);
            }
            Stmt::NumericFor {
                start,
                limit,
                step,
                body,
                ..
            } => {
                visit_expr(start, f);
                visit_expr(limit, f);
                visit_expr(step, f);
                visit_body(body, f);
            }
            Stmt::GenericFor {
                iterators, body, ..
            } => {
                for e in iterators {
                    visit_expr(e, f);
                }
                visit_body(body, f);
            }
            Stmt::Do(body) => visit_body(body, f),
            _ => {}
        }
    }
}

fn substitute_expr(expr: &mut Expr, name: &str, value: &Expr, blocked: &mut bool) -> bool {
    substitute_at(expr, name, value, blocked, 0)
}
fn substitute_at(
    expr: &mut Expr,
    name: &str,
    value: &Expr,
    blocked: &mut bool,
    depth: usize,
) -> bool {
    if depth > 64 {
        *blocked = true;
        return false;
    }
    if *blocked {
        return false;
    }
    if matches!(expr,Expr::Name(n) if n == name) {
        *expr = value.clone().scalar();
        return true;
    }
    let found = match expr {
        Expr::Unary(_, v) | Expr::Single(v) | Expr::Field(v, _) => {
            substitute_at(v, name, value, blocked, depth + 1)
        }
        Expr::Binary(op, left, right) => {
            let found = substitute_at(left, name, value, blocked, depth + 1);

            if matches!(*op, "and" | "or") {
                *blocked = true;
            }
            found || substitute_at(right, name, value, blocked, depth + 1)
        }
        Expr::Index(object, key) => {
            substitute_at(object, name, value, blocked, depth + 1)
                || substitute_at(key, name, value, blocked, depth + 1)
        }
        Expr::Call(func, args) => {
            let mut found = substitute_at(func, name, value, blocked, depth + 1);
            for arg in args {
                if !found {
                    found = substitute_at(arg, name, value, blocked, depth + 1);
                }
            }
            found
        }
        Expr::MethodCall(object, _, _) => substitute_at(object, name, value, blocked, depth + 1),
        Expr::Table(fields) => {
            let mut found = false;
            for (key, v) in fields {
                if !found {
                    if let Some(key) = key {
                        found = substitute_at(key, name, value, blocked, depth + 1);
                    }
                }
                if !found {
                    found = substitute_at(v, name, value, blocked, depth + 1);
                }
            }
            found
        }
        Expr::IfElse(cond, _, _) => substitute_at(cond, name, value, blocked, depth + 1),
        _ => false,
    };
    if !found && !expr.pure() {
        *blocked = true;
    }
    found
}

fn substitute_next(stmt: &mut Stmt, name: &str, value: &Expr) -> bool {
    let mut blocked = false;
    match stmt {
        Stmt::Assign(targets, values) if targets.iter().all(|e| matches!(e, Expr::Name(_))) => {
            values
                .iter_mut()
                .any(|e| substitute_expr(e, name, value, &mut blocked))
        }
        Stmt::Local(_, values) | Stmt::Return(values) => values
            .iter_mut()
            .any(|e| substitute_expr(e, name, value, &mut blocked)),
        Stmt::Call(expr)
        | Stmt::If {
            condition: expr, ..
        } => substitute_expr(expr, name, value, &mut blocked),
        _ => false,
    }
}

#[derive(Clone)]
struct NameBits(Vec<u64>);
impl NameBits {
    fn new(names: usize) -> Self {
        Self(vec![0; names.div_ceil(64)])
    }
    fn insert(&mut self, id: usize) {
        self.0[id / 64] |= 1 << (id % 64);
    }
    fn remove(&mut self, id: usize) {
        self.0[id / 64] &= !(1 << (id % 64));
    }
    fn contains(&self, id: usize) -> bool {
        self.0[id / 64] & (1 << (id % 64)) != 0
    }
}

fn add_expr_names(expr: &Expr, names: &BTreeMap<String, usize>, bits: &mut NameBits) {
    visit_expr(expr, &mut |e| {
        if let Expr::Name(name) = e {
            bits.insert(names[name]);
        }
    });
}

fn add_body_names(body: &[Stmt], names: &BTreeMap<String, usize>, bits: &mut NameBits) {
    visit_body(body, &mut |e| {
        if let Expr::Name(name) = e {
            bits.insert(names[name]);
        }
    });
}

fn writes_name(stmt: &Stmt, name: &str) -> bool {
    match stmt {
        Stmt::Assign(targets, _) => targets
            .iter()
            .any(|e| matches!(e, Expr::Name(n) if n == name)),
        Stmt::Local(targets, _) => targets.iter().any(|n| n == name),
        _ => false,
    }
}

fn read_count(stmt: &Stmt, name: &str) -> usize {
    let mut count = 0;
    let mut count_expr = |e: &Expr| {
        if matches!(e, Expr::Name(n) if n == name) {
            count += 1;
        }
    };
    match stmt {
        Stmt::Assign(targets, values) => {
            for target in targets {
                if !matches!(target, Expr::Name(_)) {
                    visit_expr(target, &mut count_expr);
                }
            }
            for value in values {
                visit_expr(value, &mut count_expr);
            }
        }

        other => visit_body(std::slice::from_ref(other), &mut count_expr),
    }
    count
}

fn transfer(stmt: &Stmt, names: &BTreeMap<String, usize>, live: &mut NameBits) {
    match stmt {
        Stmt::Assign(targets, values) => {
            for target in targets {
                if let Expr::Name(name) = target {
                    live.remove(names[name]);
                }
            }
            for target in targets {
                if !matches!(target, Expr::Name(_)) {
                    add_expr_names(target, names, live);
                }
            }
            for value in values {
                add_expr_names(value, names, live);
            }
        }
        Stmt::Local(targets, values) => {
            for name in targets {
                if let Some(&id) = names.get(name) {
                    live.remove(id);
                }
            }
            for value in values {
                add_expr_names(value, names, live);
            }
        }

        other => add_body_names(std::slice::from_ref(other), names, live),
    }
}

pub fn optimize(body: &mut Vec<Stmt>, protected: &BTreeSet<String>) {
    optimize_with_observable(body, protected, &BTreeSet::new());
}
pub fn optimize_with_observable(
    body: &mut Vec<Stmt>,
    protected: &BTreeSet<String>,
    observable: &BTreeSet<String>,
) {
    let _ = optimize_checked(body, protected, observable, usize::MAX);
}

pub fn optimize_checked(
    body: &mut Vec<Stmt>,
    protected: &BTreeSet<String>,
    observable: &BTreeSet<String>,
    max_work: usize,
) -> crate::Result<usize> {
    let names: BTreeMap<_, _> = collect_names(body)
        .into_keys()
        .enumerate()
        .map(|(id, name)| (name, id))
        .collect();
    let mut pending = vec![body.as_slice()];
    let mut statements = 0usize;
    while let Some(block) = pending.pop() {
        crate::execution::checkpoint()?;
        statements = statements.saturating_add(block.len());
        for stmt in block {
            match stmt {
                Stmt::If { yes, no, .. } => {
                    pending.push(yes);
                    pending.push(no);
                }
                Stmt::Do(body)
                | Stmt::While { body, .. }
                | Stmt::Repeat { body, .. }
                | Stmt::NumericFor { body, .. }
                | Stmt::GenericFor { body, .. } => pending.push(body),
                _ => {}
            }
        }
    }
    let work = statements.saturating_mul(names.len().div_ceil(64).max(1));
    if work > max_work {
        return Err(crate::Error::new(
            "limit",
            "optimizer live-name work exceeds remaining analysis budget",
        ));
    }
    let live = NameBits::new(names.len());
    optimize_block(body, protected, observable, &names, &live, 0)?;
    Ok(work)
}

fn optimize_block(
    body: &mut Vec<Stmt>,
    protected: &BTreeSet<String>,
    observable: &BTreeSet<String>,
    names: &BTreeMap<String, usize>,
    live_out: &NameBits,
    depth: usize,
) -> crate::Result<()> {
    if depth > 256 {
        return Ok(());
    }

    for stmt in body.iter_mut() {
        if let Stmt::If { condition, yes, no } = stmt {
            if no.is_empty() && yes.len() == 1 {
                if let Stmt::Assign(targets, values) = &yes[0] {
                    if targets.len() == 1 && values.len() == 1 {
                        if let Expr::Name(name) = &targets[0] {
                            let op = match condition {
                                Expr::Name(c) if c == name => Some("and"),
                                Expr::Unary("not", v) if matches!(&**v,Expr::Name(c) if c==name) => {
                                    Some("or")
                                }
                                _ => None,
                            };
                            if let Some(op) = op {
                                *stmt = Stmt::Assign(
                                    targets.clone(),
                                    vec![Expr::binary(op, Expr::name(name), values[0].clone())],
                                );
                            }
                        }
                    }
                }
            }
        }
    }
    let mut live = live_out.clone();
    let mut next_live_out = live.clone();
    let mut next: Option<usize> = None;
    let mut removed = vec![false; body.len()];
    for index in (0..body.len()).rev() {
        if index & 255 == 0 {
            crate::execution::checkpoint()?;
        }
        match &mut body[index] {
            Stmt::If { yes, no, .. } => {
                optimize_block(yes, protected, observable, names, &live, depth + 1)?;
                optimize_block(no, protected, observable, names, &live, depth + 1)?;
            }
            Stmt::Do(inner) => {
                optimize_block(inner, protected, observable, names, &live, depth + 1)?
            }
            Stmt::While { body: inner, .. }
            | Stmt::Repeat { body: inner, .. }
            | Stmt::NumericFor { body: inner, .. }
            | Stmt::GenericFor { body: inner, .. } => {
                let mut carried = live.clone();

                add_body_names(inner, names, &mut carried);
                optimize_block(inner, protected, observable, names, &carried, depth + 1)?;
            }
            _ => {}
        }
        let candidate = match &body[index] {
            Stmt::Assign(targets, values) if targets.len() == 1 && values.len() == 1 => {
                if let Expr::Name(name) = &targets[0] {
                    Some(name.clone())
                } else {
                    None
                }
            }
            _ => None,
        };
        if let (Some(next_index), Some(name)) = (next, candidate) {
            let overwritten = writes_name(&body[next_index], &name);
            if !observable.contains(&name)
                && (!protected.contains(&name) || overwritten)
                && (overwritten || !next_live_out.contains(names[&name]))
                && read_count(&body[next_index], &name) == 1
            {
                let Stmt::Assign(_, values) = &body[index] else {
                    unreachable!()
                };
                let value = values[0].clone();
                removed[index] = substitute_next(&mut body[next_index], &name, &value);
            }
        }
        if !removed[index] {
            next = Some(index);
            next_live_out = live.clone();
        }

        transfer(&body[index], names, &mut live);
    }
    let mut index = 0;
    body.retain(|_| {
        let keep = !removed[index];
        index += 1;
        keep
    });
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    fn assign(name: &str, value: Expr) -> Stmt {
        Stmt::Assign(vec![Expr::name(name)], vec![value])
    }
    #[test]
    fn region_live_out_preserves_branch_results() {
        let mut body = vec![
            Stmt::If {
                condition: Expr::name("condition"),
                yes: vec![
                    assign("result", Expr::Literal("2".into())),
                    assign("copy", Expr::name("result")),
                ],
                no: vec![],
            },
            Stmt::Return(vec![Expr::name("result"), Expr::name("copy")]),
        ];
        optimize(&mut body, &BTreeSet::new());
        let Stmt::If { yes, .. } = &body[0] else {
            panic!("expected branch")
        };
        assert_eq!(yes.len(), 2, "result assignment must survive the branch");
    }
    #[test]
    fn reused_call_registers_are_folded_without_losing_result_names() {
        let mut body = vec![
            assign("result", Expr::Global("calculate".into())),
            assign("argument", Expr::Literal("7".into())),
            Stmt::Assign(
                vec![Expr::name("result"), Expr::name("argument")],
                vec![Expr::Call(
                    Box::new(Expr::name("result")),
                    vec![Expr::name("argument")],
                )],
            ),
            Stmt::Return(vec![Expr::name("result"), Expr::name("argument")]),
        ];
        optimize(
            &mut body,
            &BTreeSet::from(["result".into(), "argument".into()]),
        );
        let source = crate::format::format(&body, &crate::Config::default()).unwrap();
        assert_eq!(
            source,
            format!(
                "{}result, argument = calculate(7)\n\nreturn result, argument\n",
                crate::attribution::prefix(false)
            )
        );
    }
    #[test]
    fn loop_carried_state_is_retained() {
        let mut body = vec![Stmt::While {
            condition: Expr::Literal("true".into()),
            body: vec![
                assign(
                    "state",
                    Expr::Call(Box::new(Expr::name("advance")), vec![Expr::name("state")]),
                ),
                assign("copy", Expr::name("state")),
            ],
        }];
        optimize(&mut body, &BTreeSet::new());
        let Stmt::While { body, .. } = &body[0] else {
            panic!("expected loop")
        };
        assert_eq!(body.len(), 2);
    }
    #[test]
    fn native_capture_writes_remain_observable() {
        let mut body = vec![
            assign(
                "captured",
                Expr::binary("+", Expr::name("captured"), Expr::Literal("1".into())),
            ),
            assign(
                "captured",
                Expr::binary("+", Expr::name("captured"), Expr::Literal("2".into())),
            ),
            Stmt::Return(vec![Expr::name("captured")]),
        ];
        optimize_with_observable(
            &mut body,
            &BTreeSet::new(),
            &BTreeSet::from(["captured".into()]),
        );
        assert_eq!(
            body.len(),
            3,
            "both writes can be observed by another capture or metamethod"
        );
    }
    #[test]
    fn optimizer_work_is_bounded_before_rewriting() {
        let mut body: Vec<_> = (0..100)
            .map(|index| {
                assign(
                    &format!("temporary_{index}"),
                    Expr::Literal(index.to_string()),
                )
            })
            .collect();
        let error = optimize_checked(&mut body, &BTreeSet::new(), &BTreeSet::new(), 1).unwrap_err();
        assert_eq!(error.stage, "limit");
        assert_eq!(
            body.len(),
            100,
            "budget rejection must precede optimizer mutations"
        );
    }
    #[test]
    fn sequential_temporary_lifetimes_do_not_exhaust_lexical_slots() {
        let mut body = vec![Stmt::Local(
            vec!["total".into()],
            vec![Expr::Literal("0".into())],
        )];
        for index in 0..256 {
            let name = format!("temporary_{index}");
            body.push(Stmt::Local(
                vec![name.clone()],
                vec![Expr::Literal(index.to_string())],
            ));
            body.push(assign(
                "total",
                Expr::binary("+", Expr::name("total"), Expr::name(&name)),
            ));
        }
        body.push(Stmt::Return(vec![Expr::name("total")]));
        assert!(crate::format::validate_complexity(&body, &crate::Config::default()).is_err());
        close_temporary_scopes(&mut body, 100_000).unwrap();
        crate::format::validate_complexity(&body, &crate::Config::default()).unwrap();
        assert!(body.iter().any(|stmt| matches!(stmt, Stmt::Do(_))));
    }
}
