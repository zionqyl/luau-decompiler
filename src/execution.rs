use crate::platform::Instant;
use crate::{Error, Result};
use std::cell::RefCell;
use std::sync::{
    atomic::{AtomicBool, AtomicUsize, Ordering},
    Arc, Mutex,
};

#[derive(Clone, Default)]
pub struct CancellationToken(Arc<AtomicBool>);
impl CancellationToken {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn cancel(&self) {
        self.0.store(true, Ordering::Release);
    }
    pub fn is_cancelled(&self) -> bool {
        self.0.load(Ordering::Acquire)
    }
}

#[derive(Clone)]
pub struct ExecutionContext {
    pub cancellation: CancellationToken,
    pub deadline: Option<Instant>,
    resources: Option<Arc<RequestMemory>>,
    work: Option<Arc<WorkBudget>>,
}
impl ExecutionContext {
    pub fn new(cancellation: CancellationToken, deadline: Option<Instant>) -> Self {
        Self {
            cancellation,
            deadline,
            resources: None,
            work: None,
        }
    }
    pub fn with_work_limit(mut self, limit: usize) -> Self {
        self.work = Some(Arc::new(WorkBudget {
            used: AtomicUsize::new(0),
            limit,
        }));
        self
    }

    pub fn with_memory(mut self, budget: Arc<MemoryBudget>) -> Result<Self> {
        self.resources = Some(Arc::new(RequestMemory {
            decoded: budget.reserve(64 * 1024)?,
            analysis: budget.reserve(0)?,
            buffers: Mutex::new(Vec::new()),
            budget,
        }));
        Ok(self)
    }

    pub fn fork_input_scope(&self) -> Result<Self> {
        let mut context = Self::new(self.cancellation.clone(), self.deadline);
        if let Some(work) = &self.work {
            context = context.with_work_limit(work.limit);
        }
        if let Some(resources) = &self.resources {
            context.with_memory(resources.budget.clone())
        } else {
            Ok(context)
        }
    }
    pub fn check(&self) -> Result<()> {
        if self.cancellation.is_cancelled() {
            return Err(Error::new(
                "cancelled",
                "request was cooperatively cancelled",
            ));
        }
        if self
            .deadline
            .is_some_and(|deadline| Instant::now() >= deadline)
        {
            self.cancellation.cancel();
            return Err(Error::new("deadline", "decompilation deadline exceeded"));
        }
        Ok(())
    }
}

struct WorkBudget {
    used: AtomicUsize,
    limit: usize,
}

pub fn charge_work(units: usize) -> Result<()> {
    checkpoint()?;
    if let Some(work) = current_context().and_then(|context| context.work) {
        let mut used = work.used.load(Ordering::Acquire);
        loop {
            let next=used.checked_add(units).filter(|next|*next<=work.limit)
                .ok_or_else(||Error::new("limit",format!("shared execution work budget exhausted: used {used}, requested {units}, limit {}",work.limit)))?;
            match work
                .used
                .compare_exchange_weak(used, next, Ordering::AcqRel, Ordering::Acquire)
            {
                Ok(_) => break,
                Err(current) => used = current,
            }
        }
    }
    Ok(())
}
pub fn current_work_used() -> usize {
    current_context()
        .and_then(|context| context.work)
        .map_or(0, |work| work.used.load(Ordering::Acquire))
}
pub fn with_default_scope<T>(limit: usize, work: impl FnOnce() -> Result<T>) -> Result<T> {
    let context = current_context();
    if context
        .as_ref()
        .is_some_and(|context| context.work.is_some())
    {
        return work();
    }
    let context = context
        .unwrap_or_else(|| ExecutionContext::new(CancellationToken::new(), None))
        .with_work_limit(limit);
    with_context(context, work)
}

struct RequestMemory {
    budget: Arc<MemoryBudget>,
    decoded: MemoryLease,
    analysis: MemoryLease,

    buffers: Mutex<Vec<MemoryLease>>,
}

#[derive(Clone, Default)]
pub struct OutputReservation(Option<MemoryLease>);
impl OutputReservation {
    pub fn reserve_capacity(&self, capacity: usize) -> Result<()> {
        if let Some(lease) = &self.0 {
            if capacity > lease.amount() {
                lease.grow_to(capacity)?;
            }
        }
        checkpoint()
    }
}

pub fn output_buffer() -> Result<OutputReservation> {
    let Some(resources) = current_context().and_then(|context| context.resources) else {
        return Ok(OutputReservation::default());
    };
    let lease = resources.budget.reserve(0)?;
    let mut buffers = resources
        .buffers
        .lock()
        .map_err(|_| Error::new("memory", "output ledger lock poisoned"))?;

    if buffers.len() >= 64 {
        return Err(Error::new(
            "memory",
            "generated-buffer reservation limit exceeded",
        ));
    }
    buffers.push(lease.clone());
    Ok(OutputReservation(Some(lease)))
}

pub fn reserve_decoded_capacity(additional_bytes: usize) -> Result<()> {
    if let Some(resources) = current_context().and_then(|context| context.resources) {
        resources.decoded.grow(additional_bytes)?;
    }
    checkpoint()
}

pub fn reserve_ast_capacity(additional_bytes: usize) -> Result<()> {
    if let Some(resources) = current_context().and_then(|context| context.resources) {
        resources.analysis.grow(additional_bytes)?;
    }
    checkpoint()
}

pub fn current_memory_budget() -> Option<Arc<MemoryBudget>> {
    current_context()
        .and_then(|context| context.resources.map(|resources| resources.budget.clone()))
}
pub fn reserve_auxiliary(bytes: usize) -> Result<Option<MemoryLease>> {
    current_memory_budget()
        .map(|budget| budget.reserve(bytes))
        .transpose()
}

pub fn admit_module(module: &crate::bytecode::Module) -> Result<()> {
    let Some(resources) = current_context().and_then(|context| context.resources) else {
        return checkpoint();
    };
    let mut analysis = 64usize * 1024;
    for proto in &module.protos {
        let mut branches = 0usize;
        let mut wide = 0usize;
        for instruction in &proto.code {
            if crate::cfg::jump_target(instruction).is_some() {
                branches = branches.saturating_add(2);
            }
            let width = match instruction.op {
                crate::bytecode::Opcode::Call => instruction.c().saturating_sub(1),
                crate::bytecode::Opcode::GetVarargs => instruction.b().saturating_sub(1),
                crate::bytecode::Opcode::ForGLoop => instruction.aux.unwrap_or(0) as usize & 255,
                _ => 0,
            };
            wide = wide.saturating_add(width);
        }
        let blocks = branches.saturating_add(1).min(proto.code.len());
        analysis = analysis
            .saturating_add(proto.code.len().saturating_mul(1024))
            .saturating_add(
                blocks
                    .saturating_mul(proto.max_stack as usize)
                    .saturating_mul(64),
            )
            .saturating_add(wide.saturating_mul(128))
            .saturating_add(proto.locals.len().saturating_mul(256));
    }
    resources.analysis.grow_to(analysis)?;
    checkpoint()
}
thread_local! { static CURRENT: RefCell<Option<ExecutionContext>> = const {RefCell::new(None)}; }
pub fn current_context() -> Option<ExecutionContext> {
    CURRENT.with(|slot| slot.borrow().clone())
}
pub fn checkpoint() -> Result<()> {
    CURRENT.with(|slot| {
        slot.borrow()
            .as_ref()
            .map_or(Ok(()), ExecutionContext::check)
    })
}
pub fn with_context<T>(context: ExecutionContext, work: impl FnOnce() -> T) -> T {
    struct Restore(Option<ExecutionContext>);
    impl Drop for Restore {
        fn drop(&mut self) {
            CURRENT.with(|slot| {
                slot.replace(self.0.take());
            });
        }
    }
    let _restore = Restore(CURRENT.with(|slot| slot.replace(Some(context))));
    work()
}

#[derive(Debug)]
pub struct MemoryBudget {
    limit: usize,
    used: AtomicUsize,
    peak: AtomicUsize,
}
impl MemoryBudget {
    pub fn new(limit: usize) -> Arc<Self> {
        Arc::new(Self {
            limit,
            used: AtomicUsize::new(0),
            peak: AtomicUsize::new(0),
        })
    }
    pub fn limit(&self) -> usize {
        self.limit
    }
    pub fn used(&self) -> usize {
        self.used.load(Ordering::Acquire)
    }
    pub fn peak(&self) -> usize {
        self.peak.load(Ordering::Acquire)
    }
    fn acquire(&self, amount: usize) -> Result<()> {
        let mut used = self.used();
        loop {
            let next = used.checked_add(amount).filter(|next| *next <= self.limit)
                .ok_or_else(|| Error::new("memory", format!("aggregate accounted memory budget exceeded: used {used}, requested {amount}, limit {}", self.limit)))?;
            match self
                .used
                .compare_exchange_weak(used, next, Ordering::AcqRel, Ordering::Acquire)
            {
                Ok(_) => {
                    self.peak.fetch_max(next, Ordering::Relaxed);
                    return Ok(());
                }
                Err(actual) => used = actual,
            }
        }
    }
    pub fn reserve(self: &Arc<Self>, amount: usize) -> Result<MemoryLease> {
        self.acquire(amount)?;
        Ok(MemoryLease(Arc::new(Lease {
            budget: self.clone(),
            amount: AtomicUsize::new(amount),
        })))
    }
}
struct Lease {
    budget: Arc<MemoryBudget>,
    amount: AtomicUsize,
}
impl Drop for Lease {
    fn drop(&mut self) {
        self.budget
            .used
            .fetch_sub(self.amount.load(Ordering::Relaxed), Ordering::AcqRel);
    }
}
#[derive(Clone)]
pub struct MemoryLease(Arc<Lease>);
impl MemoryLease {
    pub fn amount(&self) -> usize {
        self.0.amount.load(Ordering::Acquire)
    }
    pub fn grow(&self, additional: usize) -> Result<()> {
        self.0.budget.acquire(additional)?;
        self.0.amount.fetch_add(additional, Ordering::Release);
        Ok(())
    }

    pub fn resize(&self, amount: usize) -> Result<()> {
        let mut old = self.amount();
        loop {
            let additional = amount.saturating_sub(old);
            if additional != 0 {
                self.0.budget.acquire(additional)?;
            }
            match self.0.amount.compare_exchange_weak(
                old,
                amount,
                Ordering::AcqRel,
                Ordering::Acquire,
            ) {
                Ok(_) => {
                    if old > amount {
                        self.0.budget.used.fetch_sub(old - amount, Ordering::AcqRel);
                    }
                    return Ok(());
                }
                Err(current) => {
                    if additional != 0 {
                        self.0.budget.used.fetch_sub(additional, Ordering::AcqRel);
                    }
                    old = current;
                }
            }
        }
    }
    pub fn grow_to(&self, amount: usize) -> Result<()> {
        let mut old = self.amount();
        while old < amount {
            let additional = amount - old;
            self.0.budget.acquire(additional)?;
            match self.0.amount.compare_exchange_weak(
                old,
                amount,
                Ordering::AcqRel,
                Ordering::Acquire,
            ) {
                Ok(_) => return Ok(()),
                Err(current) => {
                    self.0.budget.used.fetch_sub(additional, Ordering::AcqRel);
                    old = current;
                }
            }
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn cancellation_deadline_and_nested_context_restore() {
        let token = CancellationToken::new();
        with_context(ExecutionContext::new(token.clone(), None), || {
            assert!(checkpoint().is_ok());
            token.cancel();
            assert_eq!(checkpoint().unwrap_err().stage, "cancelled");
            with_context(
                ExecutionContext::new(CancellationToken::new(), Some(Instant::now())),
                || assert_eq!(checkpoint().unwrap_err().stage, "deadline"),
            );
            assert_eq!(checkpoint().unwrap_err().stage, "cancelled");
        });
        assert!(checkpoint().is_ok());
    }
    #[test]
    fn shared_reservations_release_only_after_last_owner() {
        let budget = MemoryBudget::new(100);
        let lease = budget.reserve(60).unwrap();
        let retained = lease.clone();
        assert!(budget.reserve(50).is_err());
        assert_eq!(budget.used(), 60);
        lease.grow(20).unwrap();
        assert_eq!(budget.peak(), 80);
        drop(lease);
        assert_eq!(budget.used(), 80);
        drop(retained);
        assert_eq!(budget.used(), 0);
    }
    #[test]
    fn shared_work_attempts_cannot_reset_the_counter_and_inputs_fork_it() {
        let context = ExecutionContext::new(CancellationToken::new(), None).with_work_limit(10);
        with_context(context.clone(), || {
            charge_work(6).unwrap();
            with_context(context.clone(), || {
                assert!(charge_work(5)
                    .unwrap_err()
                    .message
                    .contains("shared execution work budget"))
            });
            assert_eq!(current_work_used(), 6);
            charge_work(4).unwrap();
            let child = context.fork_input_scope().unwrap();
            with_context(child, || {
                charge_work(7).unwrap();
                assert_eq!(current_work_used(), 7);
            });
            assert_eq!(current_work_used(), 10);
            assert!(charge_work(1).is_err());
        });
    }
    #[test]
    fn generated_capacity_reservations_outlive_printers_but_end_with_the_scope() {
        let budget = MemoryBudget::new(1024 * 1024);
        let context = ExecutionContext::new(CancellationToken::new(), None)
            .with_memory(budget.clone())
            .unwrap();
        with_context(context, || {
            let first = output_buffer().unwrap();
            let second = output_buffer().unwrap();
            first.reserve_capacity(1000).unwrap();
            second.reserve_capacity(2000).unwrap();
            drop(first);
            drop(second);
            assert_eq!(budget.used(), 64 * 1024 + 3000);
        });
        assert_eq!(budget.used(), 0);
    }
}
