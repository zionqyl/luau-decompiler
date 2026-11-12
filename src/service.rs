use luau_decompiler::{
    execution::{self, CancellationToken, ExecutionContext, MemoryBudget, MemoryLease},
    input::InputFormat,
    runtime::DecompilePool,
    Config, Error,
};
use mio::{Events, Interest, Poll, Token, Waker};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::{HashMap, VecDeque};
use std::io::{Read, Write};
use std::net::{SocketAddr, TcpListener, TcpStream};
use std::sync::atomic::{AtomicBool, AtomicU64, AtomicUsize, Ordering};
use std::sync::{mpsc, Arc, Condvar, Mutex};
use std::thread;
use std::time::{Duration, Instant};

const MAX_HEADER: usize = 16 * 1024;
const CACHE_ENTRY_OVERHEAD: usize = 256;
const HEADER_CREDIT: usize = MAX_HEADER * 3;
const REGISTRY_ENTRY_CREDIT: usize = 256;
const MAX_CONFIGURATION_BYTES: usize = 2 * 1024 * 1024;
const LISTENER_EVENT: Token = Token(0);
const SHUTDOWN_EVENT: Token = Token(1);

#[derive(Default)]
struct JobRegistry {
    active: HashMap<String, CancellationToken>,
    cancelled: HashMap<String, Instant>,
    draining_since: Option<Instant>,
}
impl JobRegistry {
    fn prune(&mut self, now: Instant) {
        self.cancelled.retain(|_, expires| *expires > now);
    }
    fn allocate_id(
        &self,
        requested: Option<String>,
        sequence: &AtomicU64,
    ) -> Result<String, Error> {
        if let Some(id) = requested {
            self.check_id(&id)?;
            return Ok(id);
        }
        for _ in 0..=self.active.len().saturating_add(self.cancelled.len()) {
            let id = format!("server-{}", sequence.fetch_add(1, Ordering::Relaxed));
            if !self.active.contains_key(&id) && !self.cancelled.contains_key(&id) {
                return Ok(id);
            }
        }
        Err(Error::new(
            "limit",
            "could not allocate a free bounded request ID",
        ))
    }
    fn check_id(&self, id: &str) -> Result<(), Error> {
        if self.cancelled.contains_key(id) {
            return Err(Error::new(
                "cancelled",
                "request ID was cancelled before submission",
            ));
        }
        if self.active.contains_key(id) {
            return Err(Error::new("conflict", "request ID is already active"));
        }
        Ok(())
    }
}

pub struct Options {
    pub listen: SocketAddr,
    pub allow_remote: bool,
    pub token: String,
    pub workers: usize,
    pub queue: usize,
    pub cache_bytes: usize,
    pub timeout: Duration,
    pub cpu_threads: usize,
    pub memory_bytes: usize,
}

impl Options {
    fn validate(&self) -> Result<(), String> {
        if !self.listen.ip().is_loopback() && !self.allow_remote {
            return Err("non-loopback binding requires --allow-remote and an authenticated HTTPS reverse proxy".into());
        }
        if !(1..=64).contains(&self.workers) || !(1..=1024).contains(&self.queue) {
            return Err("workers must be 1..64 and queue capacity 1..1024".into());
        }
        if !(1..=64).contains(&self.cpu_threads) || self.memory_bytes < 1024 * 1024 {
            return Err(
                "CPU threads must be 1..64 and aggregate accounted memory at least 1 MiB".into(),
            );
        }
        if !(Duration::from_millis(100)..=Duration::from_secs(120)).contains(&self.timeout) {
            return Err("request timeout must be 100..120000 milliseconds".into());
        }
        if self.token.len() < 32
            || self.token.len() > 256
            || !self.token.bytes().all(|b| b.is_ascii_graphic())
        {
            return Err("token must contain 32..256 printable ASCII bytes without spaces".into());
        }
        Ok(())
    }

    fn validate_feasibility(&self, config: &Config) -> Result<(), String> {
        let max_jobs = self.queue.saturating_add(self.cpu_threads);
        let history = max_jobs.saturating_mul(4).max(256);
        let control = self.workers.saturating_mul(HEADER_CREDIT).saturating_add(
            max_jobs
                .saturating_add(history)
                .saturating_mul(REGISTRY_ENTRY_CREDIT),
        );
        let encoded = config.limits.max_bytes.saturating_add(2) / 3 * 4;
        let transport = encoded
            .saturating_add(MAX_CONFIGURATION_BYTES)
            .saturating_mul(6)
            .saturating_add(config.limits.max_bytes);
        let minimum = control
            .saturating_add(transport)
            .saturating_add(256 * 1024)
            .saturating_add(
                if config.validation.mode != luau_decompiler::quality::ValidationMode::Off {
                    luau_decompiler::quality::ANALYZER_RESIDENT_BYTES
                } else {
                    0
                },
            )
            .saturating_add(
                configuration_storage(config)
                    .map_err(|e| e.to_string())?
                    .saturating_mul(5),
            );
        if minimum > self.memory_bytes {
            return Err(format!("aggregate memory budget cannot admit configured max_bytes: need at least {minimum} bytes for bounded JSON/raw transport and initial stages, configured {}", self.memory_bytes));
        }
        Ok(())
    }
}

struct Cache {
    entries: HashMap<[u8; 32], Arc<CacheEntry>>,
    order: VecDeque<[u8; 32]>,
    bytes: usize,
    limit: usize,
    memory: Arc<MemoryBudget>,
}
struct CacheEntry {
    body: Arc<Vec<u8>>,
    _memory: MemoryLease,
}

impl Cache {
    #[cfg(test)]
    fn new(limit: usize) -> Self {
        Self::with_budget(limit, MemoryBudget::new(usize::MAX))
    }
    fn with_budget(limit: usize, memory: Arc<MemoryBudget>) -> Self {
        Self {
            entries: HashMap::new(),
            order: VecDeque::new(),
            bytes: 0,
            limit,
            memory,
        }
    }

    fn get(&self, key: &[u8; 32]) -> Option<Arc<CacheEntry>> {
        self.entries.get(key).cloned()
    }

    #[cfg(test)]
    fn insert(&mut self, key: [u8; 32], value: Arc<Vec<u8>>) {
        let Some(cost) = value.capacity().checked_add(CACHE_ENTRY_OVERHEAD) else {
            return;
        };
        if cost > self.limit || self.entries.contains_key(&key) {
            return;
        }
        while self.bytes + cost > self.limit || self.entries.len() >= 256 {
            let Some(old) = self.order.pop_front() else {
                break;
            };
            if let Some(value) = self.entries.remove(&old) {
                self.bytes -= value.body.capacity() + CACHE_ENTRY_OVERHEAD;
            }
        }
        let Ok(memory) = self.memory.reserve(cost) else {
            return;
        };
        self.bytes += cost;
        self.order.push_back(key);
        self.entries.insert(
            key,
            Arc::new(CacheEntry {
                body: value,
                _memory: memory,
            }),
        );
    }

    fn insert_accounted(&mut self, key: [u8; 32], value: Arc<CacheEntry>) {
        let cost = value.body.capacity().saturating_add(CACHE_ENTRY_OVERHEAD);
        if cost > self.limit || self.entries.contains_key(&key) {
            return;
        }
        while self.bytes.saturating_add(cost) > self.limit || self.entries.len() >= 256 {
            let Some(old) = self.order.pop_front() else {
                break;
            };
            if let Some(entry) = self.entries.remove(&old) {
                self.bytes -= entry.body.capacity() + CACHE_ENTRY_OVERHEAD;
            }
        }
        self.bytes += cost;
        self.order.push_back(key);
        self.entries.insert(key, value);
    }

    fn evict_for_headroom(&mut self, required: usize) {
        while self.memory.limit().saturating_sub(self.memory.used()) < required {
            let Some(old) = self.order.pop_front() else {
                break;
            };
            if let Some(entry) = self.entries.remove(&old) {
                self.bytes -= entry.body.capacity() + CACHE_ENTRY_OVERHEAD;
            }
        }
    }
}

fn reserve_data(state: &State, bytes: usize) -> Result<MemoryLease, Error> {
    if let Ok(lease) = state.memory.reserve(bytes) {
        return Ok(lease);
    }
    state
        .cache
        .lock()
        .map_err(|_| Error::new("memory", "cache lock poisoned"))?
        .evict_for_headroom(bytes);
    state.memory.reserve(bytes)
}

fn configuration_storage(config: &Config) -> Result<usize, Error> {
    let bytes = serde_json::to_vec(config).map_err(|e| Error::new("config", e.to_string()))?;
    Ok(bytes
        .capacity()
        .saturating_mul(4)
        .saturating_add(json_structure_charge(&bytes))
        .saturating_add(4096))
}

fn json_structure_charge(bytes: &[u8]) -> usize {
    let mut quoted = false;
    let mut escaped = false;
    let mut scalar = false;
    let mut nodes = 0usize;
    for &byte in bytes {
        if quoted {
            if escaped {
                escaped = false;
            } else if byte == b'\\' {
                escaped = true;
            } else if byte == b'"' {
                quoted = false;
            }
            continue;
        }
        match byte {
            b'"' => {
                quoted = true;
                scalar = false;
                nodes = nodes.saturating_add(1);
            }
            b'{' | b'[' | b':' => {
                scalar = false;
                nodes = nodes.saturating_add(1);
            }
            b'}' | b']' | b',' | b' ' | b'\n' | b'\r' | b'\t' => scalar = false,
            _ => {
                if !scalar {
                    nodes = nodes.saturating_add(1);
                    scalar = true;
                }
            }
        }
    }
    nodes.saturating_mul(256)
}

fn merge_config(base: &Config, patch: &serde_json::Value) -> Result<Config, Error> {
    if !patch.is_object()
        || serde_json::to_vec(patch)
            .map_err(|e| Error::new("config", e.to_string()))?
            .len()
            > MAX_CONFIGURATION_BYTES
    {
        return Err(Error::new(
            "config",
            "reconstruction_config must be a bounded JSON object",
        ));
    }
    let mut value = serde_json::to_value(base).map_err(|e| Error::new("config", e.to_string()))?;
    fn merge(target: &mut serde_json::Value, patch: &serde_json::Value) {
        if let (Some(target), Some(fields)) = (target.as_object_mut(), patch.as_object()) {
            for (key, field) in fields {
                if let Some(current) = target.get_mut(key) {
                    merge(current, field);
                } else {
                    target.insert(key.clone(), field.clone());
                }
            }
        } else {
            *target = patch.clone();
        }
    }
    merge(&mut value, patch);
    let server = serde_json::to_value(base).map_err(|e| Error::new("config", e.to_string()))?;
    if server["output_policy"] == "verified_typed" && value["output_policy"] != "verified_typed" {
        return Err(Error::new(
            "config",
            "request cannot downgrade server verified_typed output policy",
        ));
    }
    if server["output_policy"] == "verified_typed" {
        if let Some(requirements) = value["meaningful_typing"].as_object() {
            for (key, requested) in requirements {
                if let Some((requested, required)) = requested
                    .as_u64()
                    .zip(server["meaningful_typing"][key].as_u64())
                {
                    if (key.starts_with("min_") && requested < required)
                        || (key.starts_with("max_") && requested > required)
                    {
                        return Err(Error::new(
                            "config",
                            format!("request cannot weaken server meaningful_typing.{key}"),
                        ));
                    }
                }
            }
        }
    }
    if let Some(limits) = value["limits"].as_object() {
        for (key, limit) in limits {
            if limit
                .as_u64()
                .zip(server["limits"][key].as_u64())
                .is_none_or(|(requested, maximum)| requested > maximum)
            {
                return Err(Error::new(
                    "config",
                    format!("request cannot raise server limit {key}"),
                ));
            }
        }
    }
    if let Some(validation) = value["validation"].as_object() {
        if server["validation"]["mode"] == "strict_required"
            && value["validation"]["mode"] != "strict_required"
        {
            return Err(Error::new(
                "config",
                "request cannot downgrade server strict_required quality policy",
            ));
        }
        for key in ["analyzer_path", "definitions_path"] {
            if validation.get(key) != server["validation"].get(key) {
                return Err(Error::new(
                    "config",
                    format!("validation.{key} is server-owned"),
                ));
            }
        }
        for key in [
            "max_workers",
            "timeout_ms",
            "max_attempts",
            "max_cache_bytes",
        ] {
            if validation
                .get(key)
                .and_then(|v| v.as_u64())
                .zip(server["validation"][key].as_u64())
                .is_some_and(|(requested, maximum)| requested > maximum)
            {
                return Err(Error::new(
                    "config",
                    format!("request cannot raise validation.{key}"),
                ));
            }
        }
    }
    let config: Config =
        serde_json::from_value(value).map_err(|e| Error::new("config", e.to_string()))?;
    config.validate()?;
    Ok(config)
}

struct State {
    config: Config,
    config_charge: usize,
    _config_memory: MemoryLease,
    token_hash: [u8; 32],
    timeout: Duration,
    cache: Mutex<Cache>,
    cpu: Arc<DecompilePool>,
    memory: Arc<MemoryBudget>,
    jobs: Mutex<JobRegistry>,
    jobs_changed: Condvar,
    control: Arc<MemoryBudget>,
    _control_memory: MemoryLease,
    max_tombstones: usize,
    active_jobs: AtomicUsize,
    pending_connections: Arc<AtomicUsize>,
    pending_responses: Arc<AtomicUsize>,
    connection_capacity: usize,
    max_jobs: usize,
    sequence: AtomicU64,
    shutdown: AtomicBool,
    listener_wake: Option<Arc<Waker>>,
    #[cfg(test)]
    body_read_ready: Mutex<Option<mpsc::SyncSender<()>>>,
}
impl State {
    fn fixed_memory(&self) -> usize {
        self._control_memory.amount() + self._config_memory.amount()
    }

    fn begin_shutdown(&self) -> Result<(), String> {
        let mut jobs = self
            .jobs
            .lock()
            .map_err(|_| "job registry lock poisoned".to_owned())?;
        let newly_draining = jobs.draining_since.is_none();
        jobs.draining_since.get_or_insert_with(Instant::now);
        self.shutdown.store(true, Ordering::Release);
        drop(jobs);
        self.jobs_changed.notify_all();
        if newly_draining {
            if let Some(waker) = &self.listener_wake {
                waker
                    .wake()
                    .map_err(|error| format!("wake listener for shutdown: {error}"))?;
            }
        }
        Ok(())
    }

    fn wait_for_idle_until(&self, deadline: Instant) -> Result<bool, String> {
        let mut jobs = self
            .jobs
            .lock()
            .map_err(|_| "job registry lock poisoned".to_owned())?;
        while !jobs.active.is_empty() {
            let remaining = deadline.saturating_duration_since(Instant::now());
            if remaining.is_zero() {
                return Ok(false);
            }
            let (updated, _) = self
                .jobs_changed
                .wait_timeout(jobs, remaining)
                .map_err(|_| "job registry lock poisoned during drain".to_owned())?;
            jobs = updated;
        }
        Ok(true)
    }
}

struct JobGuard {
    state: Arc<State>,
    id: String,
}
impl Drop for JobGuard {
    fn drop(&mut self) {
        if let Ok(mut jobs) = self.state.jobs.lock() {
            jobs.active.remove(&self.id);
            self.state.active_jobs.fetch_sub(1, Ordering::AcqRel);
        } else {
            self.state.active_jobs.fetch_sub(1, Ordering::AcqRel);
        }
        self.state.jobs_changed.notify_all();
    }
}

struct Work {
    input: Vec<u8>,
    config: Config,
    key: [u8; 32],
    deadline: Instant,
    cancellation: CancellationToken,
    guard: JobGuard,
    input_memory: MemoryLease,
    cached: Option<Arc<CacheEntry>>,
    input_format: InputFormat,
}

struct PreparedResponse {
    status: u16,
    payload: Arc<CacheEntry>,
    cache: &'static str,
    deadline: Instant,
    cancellation: CancellationToken,
    _guard: JobGuard,
}

struct Transmission {
    stream: TcpStream,
    response: Result<PreparedResponse, (u16, String)>,
    pending: PendingHandoff,
}
impl Transmission {
    fn new(
        stream: TcpStream,
        response: Result<PreparedResponse, (u16, String)>,
        state: &State,
    ) -> Self {
        Self {
            stream,
            response,
            pending: PendingHandoff::new(&state.pending_responses),
        }
    }
}

struct Connection {
    stream: TcpStream,
    accepted: Instant,
    pending: PendingHandoff,
}

struct PendingHandoff(Arc<AtomicUsize>);
impl PendingHandoff {
    fn new(counter: &Arc<AtomicUsize>) -> Self {
        counter.fetch_add(1, Ordering::AcqRel);
        Self(counter.clone())
    }
}
impl Drop for PendingHandoff {
    fn drop(&mut self) {
        self.0.fetch_sub(1, Ordering::AcqRel);
    }
}

struct BudgetBuffer {
    bytes: Vec<u8>,
    memory: MemoryLease,
    limit: usize,
    failure: Option<Error>,
}
impl Write for BudgetBuffer {
    fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
        let needed = self
            .bytes
            .len()
            .checked_add(bytes.len())
            .filter(|n| *n <= self.limit);
        let Some(needed) = needed else {
            self.failure = Some(Error::new(
                "limit",
                "serialized response exceeds configured growth limit",
            ));
            return Err(std::io::Error::other("response byte limit"));
        };
        if needed > self.bytes.capacity() {
            let capacity = needed
                .max(self.bytes.capacity().saturating_mul(2))
                .max(4096)
                .min(self.limit);
            if let Err(error) = self
                .memory
                .resize(capacity.saturating_add(CACHE_ENTRY_OVERHEAD))
            {
                self.failure = Some(error);
                return Err(std::io::Error::other("response memory budget"));
            }
            if self
                .bytes
                .try_reserve_exact(capacity - self.bytes.len())
                .is_err()
            {
                self.failure = Some(Error::new("memory", "response allocation failed"));
                return Err(std::io::Error::other("response allocation failed"));
            }
        }
        self.bytes.extend_from_slice(bytes);
        Ok(bytes.len())
    }
    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

fn serialize_accounted(
    state: &State,
    value: &impl serde::Serialize,
    limit: usize,
) -> Result<Arc<CacheEntry>, Error> {
    let mut buffer = BudgetBuffer {
        bytes: Vec::new(),
        memory: reserve_data(state, CACHE_ENTRY_OVERHEAD)?,
        limit,
        failure: None,
    };
    if let Err(error) = serde_json::to_writer(&mut buffer, value) {
        return Err(buffer
            .failure
            .unwrap_or_else(|| Error::new("serialize", error.to_string())));
    }
    Ok(Arc::new(CacheEntry {
        body: Arc::new(buffer.bytes),
        _memory: buffer.memory,
    }))
}

fn reserve_control(
    memory: &Arc<MemoryBudget>,
    workers: usize,
    max_jobs: usize,
) -> Result<(Arc<MemoryBudget>, MemoryLease, usize), Error> {
    let max_tombstones = max_jobs.saturating_mul(4).max(256);
    let headers = workers
        .checked_mul(HEADER_CREDIT)
        .ok_or_else(|| Error::new("memory", "header control reservation overflow"))?;
    let registry = max_jobs
        .checked_add(max_tombstones)
        .and_then(|n| n.checked_mul(REGISTRY_ENTRY_CREDIT))
        .ok_or_else(|| Error::new("memory", "cancellation registry reservation overflow"))?;
    let total = headers
        .checked_add(registry)
        .ok_or_else(|| Error::new("memory", "control reservation overflow"))?;
    Ok((
        MemoryBudget::new(headers),
        memory.reserve(total)?,
        max_tombstones,
    ))
}

fn hash(bytes: &[u8]) -> [u8; 32] {
    Sha256::digest(bytes).into()
}

fn authenticate(header: &str, expected: &[u8; 32]) -> bool {
    let Some(token) = header.strip_prefix("Bearer ") else {
        return false;
    };
    let actual = hash(token.as_bytes());
    actual
        .iter()
        .zip(expected)
        .fold(0u8, |difference, (a, b)| difference | (a ^ b))
        == 0
}

fn write_until_cancellable(
    stream: &mut TcpStream,
    mut bytes: &[u8],
    deadline: Instant,
    cancellation: Option<&CancellationToken>,
) -> std::io::Result<()> {
    while !bytes.is_empty() {
        if cancellation.is_some_and(CancellationToken::is_cancelled) {
            return Err(std::io::Error::new(
                std::io::ErrorKind::Interrupted,
                "response cancelled",
            ));
        }
        let left = deadline.saturating_duration_since(Instant::now());
        if left.is_zero() {
            return Err(std::io::Error::new(
                std::io::ErrorKind::TimedOut,
                "write deadline exceeded",
            ));
        }
        stream.set_write_timeout(Some(if cancellation.is_some() {
            left.min(Duration::from_millis(100))
        } else {
            left
        }))?;
        match stream.write(&bytes[..bytes.len().min(64 * 1024)]) {
            Ok(0) => {
                return Err(std::io::Error::new(
                    std::io::ErrorKind::WriteZero,
                    "connection closed during response",
                ))
            }
            Ok(count) => bytes = &bytes[count..],
            Err(error) if error.kind() == std::io::ErrorKind::Interrupted => {}
            Err(error)
                if cancellation.is_some()
                    && matches!(
                        error.kind(),
                        std::io::ErrorKind::WouldBlock | std::io::ErrorKind::TimedOut
                    ) => {}
            Err(error) => return Err(error),
        }
    }
    Ok(())
}

fn response(
    stream: &mut TcpStream,
    status: u16,
    body: &[u8],
    cache: &str,
    deadline: Instant,
) -> std::io::Result<()> {
    response_controlled(stream, status, body, cache, deadline, None)
}
fn response_controlled(
    stream: &mut TcpStream,
    status: u16,
    body: &[u8],
    cache: &str,
    deadline: Instant,
    cancellation: Option<&CancellationToken>,
) -> std::io::Result<()> {
    let reason = match status {
        200 => "OK",
        400 => "Bad Request",
        401 => "Unauthorized",
        404 => "Not Found",
        405 => "Method Not Allowed",
        408 => "Request Timeout",
        409 => "Conflict",
        411 => "Length Required",
        413 => "Content Too Large",
        415 => "Unsupported Media Type",
        422 => "Unprocessable Content",
        431 => "Request Header Fields Too Large",
        499 => "Request Cancelled",
        503 => "Service Unavailable",
        _ => "Internal Server Error",
    };
    let header = format!("HTTP/1.1 {status} {reason}\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: {}\r\nConnection: close\r\nCache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nX-Decompiler-Cache: {cache}\r\n\r\n", body.len());
    write_until_cancellable(stream, header.as_bytes(), deadline, cancellation)?;
    write_until_cancellable(stream, body, deadline, cancellation)
}

fn fail(stream: &mut TcpStream, status: u16, message: &str) {
    let body =
        serde_json::to_vec(&json!({"error": Error::new("http", message)})).unwrap_or_default();
    let timeout = stream
        .write_timeout()
        .ok()
        .flatten()
        .unwrap_or(Duration::from_secs(1))
        .min(Duration::from_secs(1));
    let _ = response(stream, status, &body, "none", Instant::now() + timeout);
}

fn remaining(deadline: Instant) -> Result<Duration, (u16, String)> {
    let time = deadline.saturating_duration_since(Instant::now());
    if time.is_zero() {
        Err((408, "request deadline exceeded".into()))
    } else {
        Ok(time)
    }
}

fn read_more(
    stream: &mut TcpStream,
    output: &mut Vec<u8>,
    max: usize,
    deadline: Instant,
) -> Result<(), (u16, String)> {
    stream
        .set_read_timeout(Some(remaining(deadline)?))
        .map_err(|_| (400, "socket timeout configuration failed".into()))?;
    let mut scratch = [0u8; 4096];
    let length = max.min(scratch.len());
    match stream.read(&mut scratch[..length]) {
        Ok(0) => Err((
            400,
            "connection ended before the request was complete".into(),
        )),
        Ok(count) => {
            output
                .try_reserve(count)
                .map_err(|_| (503, "request buffering allocation failed".into()))?;
            output.extend_from_slice(&scratch[..count]);
            Ok(())
        }
        Err(error)
            if matches!(
                error.kind(),
                std::io::ErrorKind::WouldBlock | std::io::ErrorKind::TimedOut
            ) =>
        {
            Err((408, "request deadline exceeded".into()))
        }
        Err(_) => Err((400, "failed to read request".into())),
    }
}

fn drain_rejected_body(stream: &mut TcpStream, mut remaining: usize, deadline: Instant) {
    let deadline = deadline.min(Instant::now() + Duration::from_millis(100));
    let mut scratch = [0u8; 8192];
    while remaining != 0 {
        let left = deadline.saturating_duration_since(Instant::now());
        if left.is_zero() || stream.set_read_timeout(Some(left)).is_err() {
            break;
        }
        let length = remaining.min(scratch.len());
        match stream.read(&mut scratch[..length]) {
            Ok(0) | Err(_) => break,
            Ok(count) => remaining -= count,
        }
    }
}

struct Request {
    path: String,
    request_id: Option<String>,
    timeout_ms: Option<u64>,
    authorization: String,
    content_type: String,
    content_length: usize,
    prefix: Vec<u8>,
}

fn read_headers(stream: &mut TcpStream, deadline: Instant) -> Result<Request, (u16, String)> {
    let mut bytes = Vec::with_capacity(4096);
    let boundary = loop {
        if let Some(position) = bytes.windows(4).position(|window| window == b"\r\n\r\n") {
            break position + 4;
        }
        if bytes.len() >= MAX_HEADER {
            return Err((431, "request headers exceed 16384 bytes".into()));
        }
        let left = MAX_HEADER - bytes.len();
        read_more(stream, &mut bytes, left, deadline)?;
    };
    let text = std::str::from_utf8(&bytes[..boundary])
        .map_err(|_| (400, "HTTP headers must be UTF-8 ASCII".into()))?;
    if !text.is_ascii() {
        return Err((400, "HTTP headers must contain ASCII bytes".into()));
    }
    let mut lines = text.split("\r\n");
    let line = lines.next().unwrap_or("");
    let parts: Vec<_> = line.split(' ').collect();
    if parts.len() != 3 || !matches!(parts[2], "HTTP/1.0" | "HTTP/1.1") {
        return Err((400, "invalid HTTP request line".into()));
    }
    let valid_route = (parts[0] == "POST"
        && matches!(parts[1], "/v1/decompile" | "/v1/process" | "/v1/shutdown"))
        || (parts[0] == "GET" && matches!(parts[1], "/v1/capabilities" | "/healthz" | "/readyz"))
        || (parts[0] == "DELETE" && parts[1].starts_with("/v1/requests/"));
    if !matches!(parts[0], "POST" | "GET" | "DELETE") {
        return Err((405, "unsupported HTTP method".into()));
    }
    if !valid_route {
        return Err((404, "unknown endpoint".into()));
    }
    let mut auth = None;
    let mut length = None;
    let mut content_type = None;
    let mut host = false;
    let mut request_id = None;
    let mut timeout_ms = None;
    for line in lines {
        if line.is_empty() {
            break;
        }
        let (name, value) = line
            .split_once(':')
            .ok_or_else(|| (400, "invalid header field".to_string()))?;
        if name.is_empty()
            || !name
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b"!#$%&'*+-.^_`|~".contains(&b))
        {
            return Err((400, "invalid header field name".into()));
        }
        let value = value.trim();
        if value.bytes().any(|b| b < 32 || b == 127) {
            return Err((400, "invalid header field value".into()));
        }
        match name.to_ascii_lowercase().as_str() {
            "x-request-id" => {
                if value.is_empty()
                    || value.len() > 64
                    || !value
                        .bytes()
                        .all(|b| b.is_ascii_alphanumeric() || b == b'-' || b == b'_')
                    || request_id.replace(value.to_owned()).is_some()
                {
                    return Err((400, "invalid or duplicate x-request-id".into()));
                }
            }
            "x-timeout-ms" => {
                if timeout_ms.is_some()
                    || value
                        .parse::<u64>()
                        .ok()
                        .filter(|n| (1..=120000).contains(n))
                        .is_none()
                {
                    return Err((400, "x-timeout-ms must be one integer in 1..=120000".into()));
                }
                timeout_ms = Some(
                    value
                        .parse::<u64>()
                        .map_err(|_| (400, "invalid timeout".into()))?,
                );
            }
            "authorization" => {
                if auth.replace(value.to_string()).is_some() {
                    return Err((400, "duplicate authorization header".into()));
                }
            }
            "content-length" => {
                if value.is_empty()
                    || !value.bytes().all(|b| b.is_ascii_digit())
                    || length.is_some()
                {
                    return Err((400, "invalid or duplicate content-length".into()));
                }
                length =
                    Some(value.parse::<usize>().map_err(|_| {
                        (413, "content-length overflows platform size".to_string())
                    })?);
            }
            "content-type" => {
                if content_type.replace(value.to_string()).is_some() {
                    return Err((400, "duplicate content-type".into()));
                }
            }
            "host" => {
                if host {
                    return Err((400, "duplicate host header".into()));
                }
                host = true;
            }
            "transfer-encoding" => {
                return Err((
                    400,
                    "transfer-encoding is unsupported; send content-length".into(),
                ))
            }
            "expect" => return Err((400, "expect requests are unsupported".into())),
            _ => {}
        }
    }
    if parts[2] == "HTTP/1.1" && !host {
        return Err((400, "HTTP/1.1 requires a host header".into()));
    }
    Ok(Request {
        path: parts[1].into(),
        request_id,
        timeout_ms,
        authorization: auth.unwrap_or_default(),
        content_type: content_type.unwrap_or_default(),
        content_length: if parts[0] == "POST" {
            length.ok_or_else(|| (411, "content-length is required".to_string()))?
        } else {
            length.unwrap_or(0)
        },
        prefix: bytes[boundary..].to_vec(),
    })
}

fn decode_base64(text: &str, limit: usize) -> Result<Vec<u8>, String> {
    if text.len() % 4 != 0 {
        return Err("base64 length must be divisible by four".into());
    }
    let estimate = (text.len() / 4)
        .checked_mul(3)
        .ok_or("base64 length overflow")?;
    if estimate.saturating_sub(2) > limit {
        return Err("decoded bytecode exceeds input limit".into());
    }
    let mut output = Vec::with_capacity(estimate.min(limit));
    let count = text.len() / 4;
    for (index, group) in text.as_bytes().chunks_exact(4).enumerate() {
        let padding = if group[2] == b'=' {
            2
        } else if group[3] == b'=' {
            1
        } else {
            0
        };
        if padding != 0 && index + 1 != count {
            return Err("base64 padding appears before the end".into());
        }
        if padding == 2 && group[3] != b'=' {
            return Err("invalid base64 padding".into());
        }
        let mut value = [0u8; 4];
        for i in 0..(4 - padding) {
            value[i] = match group[i] {
                b'A'..=b'Z' => group[i] - b'A',
                b'a'..=b'z' => group[i] - b'a' + 26,
                b'0'..=b'9' => group[i] - b'0' + 52,
                b'+' => 62,
                b'/' => 63,
                _ => return Err("invalid base64 alphabet".into()),
            };
        }
        if padding == 2 && value[1] & 15 != 0 || padding == 1 && value[2] & 3 != 0 {
            return Err("noncanonical base64 padding bits".into());
        }
        output.push((value[0] << 2) | (value[1] >> 4));
        if padding < 2 {
            output.push((value[1] << 4) | (value[2] >> 2));
        }
        if padding < 1 {
            output.push((value[2] << 6) | value[3]);
        }
    }
    if output.len() > limit {
        return Err("decoded bytecode exceeds input limit".into());
    }
    Ok(output)
}

fn prepare(
    stream: &mut TcpStream,
    state: &Arc<State>,
    accepted: Instant,
) -> Result<Option<Work>, (u16, String)> {
    let header_memory = state
        .control
        .reserve(HEADER_CREDIT)
        .map_err(|e| (503, e.to_string()))?;
    let mut deadline = accepted + state.timeout;
    let mut request = read_headers(stream, deadline)?;
    if !authenticate(&request.authorization, &state.token_hash) {
        return Err((401, "invalid bearer token".into()));
    }
    if let Some(ms) = request.timeout_ms {
        deadline = deadline.min(accepted + Duration::from_millis(ms));
    }
    if matches!(
        request.path.as_str(),
        "/healthz" | "/readyz" | "/v1/shutdown"
    ) {
        if request.content_length != 0 || !request.prefix.is_empty() {
            return Err((400, "control request must have no body".into()));
        }
        if request.path == "/v1/shutdown" {
            state.begin_shutdown().map_err(|error| (500, error))?;
        }
        let stopping = state.shutdown.load(Ordering::Acquire);
        let effective = state.config.effective();
        let assets = luau_decompiler::quality::validation_assets_ready(&effective);
        let required_validation = effective.output_policy
            == luau_decompiler::config::OutputPolicy::VerifiedTyped
            || effective.validation.mode
                == luau_decompiler::quality::ValidationMode::StrictRequired;
        let ready = !stopping && (!required_validation || assets.is_ok());
        let status = if request.path == "/readyz" && !ready {
            503
        } else {
            200
        };
        let body = serde_json::to_vec(&json!({
            "healthy": true,
            "ready": ready,
            "validation_assets_ready": assets.is_ok(),
            "validation_assets_error": assets.err(),
            "validation_workers": "lazy; asset readiness is not analyzer warm-up or a source analysis result",
            "shutting_down": stopping,
            "active_jobs": state.active_jobs.load(Ordering::Acquire),
            "max_jobs": state.max_jobs,
            "package_version": env!("CARGO_PKG_VERSION")
        })).map_err(|_| (500, "control response serialization failed".into()))?;
        response(stream, status, &body, "none", deadline)
            .map_err(|_| (0, "control response ended".into()))?;
        return Ok(None);
    }
    if request.path == "/v1/capabilities" {
        if request.content_length != 0 || !request.prefix.is_empty() {
            return Err((400, "capabilities request must have no body".into()));
        }
        let body=serde_json::to_vec(&json!({
            "protocol_version":2,"package_version":env!("CARGO_PKG_VERSION"),
            "implementation":luau_decompiler::profiles::capabilities(),
            "inputs":luau_decompiler::input::capabilities(),
            "output_policies":["faithful","annotated","verified_typed"],
            "transport_limits":{"max_header_bytes":MAX_HEADER,"max_configuration_bytes":MAX_CONFIGURATION_BYTES,
                "max_raw_body_bytes":state.config.limits.max_bytes,
                "max_json_body_bytes":state.config.limits.max_bytes.saturating_add(2).saturating_div(3).saturating_mul(4).saturating_add(MAX_CONFIGURATION_BYTES)},
            "encodings":["auto","upstream","roblox_opcode227",luau_decompiler::bytecode::ROBLOX_SIGNATURE_PROFILE],
            "features":{"structured_diagnostics":true,"cooperative_cancellation":true,"persistent_cpu_pool":true,"output_quality":true,"binding_id_overrides":true,"per_request_settings":true,"staged_memory_accounting":true,"bounded_response_workers":true,"cached_response_cancellation":true,"source_input":true,"graceful_shutdown":true},
            "cpu_threads":state.cpu.threads(),"max_jobs":state.max_jobs,"active_jobs":state.active_jobs.load(Ordering::Acquire),
            "pending_handoffs":{"connections":state.pending_connections.load(Ordering::Acquire),"responses":state.pending_responses.load(Ordering::Acquire),"connection_capacity":state.connection_capacity,"response_capacity":state.max_jobs,"scope":"RAII producer-to-worker handoffs; a producer can be included before its bounded try_send completes; not OS socket backlog"},
            "accounted_memory":{"limit":state.memory.limit(),"used":state.memory.used(),"peak":state.memory.peak(),
                "control_reserved":state._control_memory.amount(),"configuration_reserved":state._config_memory.amount(),"fixed_reserved":state.fixed_memory(),"header_credit_in_use":state.control.used(),
                "cancellation_history_limit":state.max_tombstones,
                "model":"bounded transport capacities, staged decoder allocations, validated-shape analysis, controlled generated/JSON growth and shared response/cache leases; not an OS RSS quota"},
            "limits":state.config.limits,"profile":state.config.profile,"bytecode_encoding":state.config.bytecode_encoding,
            "vector_constructor":state.config.vector_constructor
        })).map_err(|_| (500,"capabilities serialization failed".into()))?;
        response(stream, 200, &body, "none", deadline)
            .map_err(|_| (0, "capabilities response ended".into()))?;
        return Ok(None);
    }
    if let Some(id) = request.path.strip_prefix("/v1/requests/") {
        if request.content_length != 0
            || !request.prefix.is_empty()
            || id.is_empty()
            || id.len() > 64
            || !id
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b == b'-' || b == b'_')
        {
            return Err((400, "invalid cancellation request".into()));
        }
        let mut jobs = state
            .jobs
            .lock()
            .map_err(|_| (500, "job registry lock poisoned".into()))?;
        let now = Instant::now();
        jobs.prune(now);
        let active = jobs.active.get(id).is_some_and(|token| {
            token.cancel();
            true
        });
        let expires = now + state.timeout + Duration::from_secs(1);
        let remembered =
            if jobs.cancelled.contains_key(id) || jobs.cancelled.len() < state.max_tombstones {
                jobs.cancelled.insert(id.to_owned(), expires);
                true
            } else {
                false
            };
        if !active && !remembered {
            return Err((
                503,
                "bounded cancellation history is full; retry after expiry".into(),
            ));
        }
        drop(jobs);
        let body = serde_json::to_vec(
            &json!({"request_id":id,"cancelled":true,"active":active,"remembered":remembered}),
        )
        .map_err(|_| (500, "cancellation response failed".into()))?;
        response(stream, 200, &body, "none", deadline)
            .map_err(|_| (0, "cancellation response ended".into()))?;
        return Ok(None);
    }
    if state.shutdown.load(Ordering::Acquire) {
        return Err((503, "service is draining; new work is not admitted".into()));
    }
    if let Some(id) = &request.request_id {
        let mut jobs = state
            .jobs
            .lock()
            .map_err(|_| (500, "job registry lock poisoned".into()))?;
        jobs.prune(Instant::now());
        let checked = jobs.check_id(id);
        drop(jobs);
        if let Err(error) = checked {
            diagnostic_response(
                stream,
                if error.stage == "cancelled" { 499 } else { 409 },
                &error,
                deadline,
            )?;
            drain_rejected_body(
                stream,
                request.content_length.saturating_sub(request.prefix.len()),
                deadline,
            );
            return Ok(None);
        }
    }
    let media = request.content_type.split(';').next().unwrap_or("").trim();
    let json_request = match media {
        "application/octet-stream" | "application/x-luau" | "text/plain" => false,
        "application/json" => true,
        _ => {
            return Err((
                415,
                "content-type must be application/octet-stream, application/json, application/x-luau or text/plain".into(),
            ))
        }
    };
    let input_limit = state.config.limits.max_bytes;
    let body_limit = if json_request {
        input_limit
            .saturating_add(2)
            .saturating_div(3)
            .saturating_mul(4)
            .saturating_add(MAX_CONFIGURATION_BYTES)
    } else {
        input_limit
    };
    if request.content_length > body_limit {
        return Err((413, format!("request body {} exceeds bounded transport limit {body_limit}; decoded input limit is {input_limit}",request.content_length)));
    }
    if request.prefix.len() > request.content_length {
        return Err((400, "unexpected bytes after request body".into()));
    }
    let transport_cost = if json_request {
        request
            .content_length
            .saturating_mul(6)
            .saturating_add(input_limit.min(request.content_length.saturating_mul(3) / 4))
    } else {
        request.content_length
    };
    let body_memory = reserve_data(
        state,
        transport_cost.saturating_add(state.config_charge.saturating_mul(4)),
    )
    .map_err(|e| (503, e.to_string()))?;
    if request.prefix.capacity() < request.content_length {
        request
            .prefix
            .try_reserve_exact(request.content_length - request.prefix.len())
            .map_err(|_| (503, "request buffering allocation failed".into()))?;
    }
    #[cfg(test)]
    if let Some(ready) = state
        .body_read_ready
        .lock()
        .map_err(|_| (500, "body readiness lock poisoned".into()))?
        .take()
    {
        ready
            .send(())
            .map_err(|_| (500, "body readiness observer disconnected".into()))?;
    }
    while request.prefix.len() < request.content_length {
        let left = request.content_length - request.prefix.len();
        read_more(stream, &mut request.prefix, left, deadline)?;
    }
    if json_request {
        body_memory
            .grow(json_structure_charge(&request.prefix))
            .map_err(|e| (503, e.to_string()))?;
    }
    let mut config = state.config.clone();
    let mut input_format = match media {
        "application/x-luau" | "text/plain" => InputFormat::LuauSource,
        _ => state.config.input_format,
    };
    let input = if json_request {
        #[derive(serde::Deserialize)]
        #[serde(deny_unknown_fields)]
        struct Body {
            bytecode_base64: Option<String>,
            input_base64: Option<String>,
            source: Option<String>,
            input_format: Option<InputFormat>,
            profile: Option<String>,
            bytecode_encoding: Option<String>,
            control_flow: Option<luau_decompiler::ControlFlowMode>,
            vector_constructor: Option<String>,
            reconstruction_config: Option<serde_json::Value>,
        }
        let body_bytes = std::mem::take(&mut request.prefix);
        let body: Body = serde_json::from_slice(&body_bytes)
            .map_err(|error| (400, format!("invalid request JSON: {error}")))?;
        let payload_count = usize::from(body.bytecode_base64.is_some())
            + usize::from(body.input_base64.is_some())
            + usize::from(body.source.is_some());
        if payload_count != 1 {
            return Err((
                400,
                "provide exactly one of bytecode_base64, input_base64 or source".into(),
            ));
        }
        if let Some(profile) = body.profile {
            config.profile = profile;
        }
        if let Some(encoding) = body.bytecode_encoding {
            config.bytecode_encoding = encoding;
        }
        if let Some(flow) = body.control_flow {
            config.control_flow = flow;
        }
        if body.vector_constructor.is_some() {
            config.vector_constructor = body.vector_constructor;
        }
        if let Some(patch) = body.reconstruction_config {
            config = match merge_config(&config, &patch) {
                Ok(config) => config,
                Err(error) => {
                    diagnostic_response(stream, 422, &error, deadline)?;
                    return Ok(None);
                }
            };
        }
        input_format = body.input_format.unwrap_or(config.input_format);
        if let Some(encoded) = body.bytecode_base64 {
            if !matches!(input_format, InputFormat::Auto | InputFormat::LuauBytecode) {
                return Err((
                    400,
                    "bytecode_base64 requires auto or luau_bytecode input_format".into(),
                ));
            }
            input_format = InputFormat::LuauBytecode;
            decode_base64(&encoded, input_limit).map_err(|error| (400, error))?
        } else if let Some(encoded) = body.input_base64 {
            decode_base64(&encoded, input_limit).map_err(|error| (400, error))?
        } else {
            let source = body
                .source
                .ok_or_else(|| (400, "missing source payload".to_owned()))?;
            if source.len() > input_limit {
                return Err((413, "source exceeds configured input limit".into()));
            }
            if input_format == InputFormat::LuauBytecode {
                return Err((400, "source cannot be paired with luau_bytecode input_format; use binary-safe input_base64".into()));
            }
            source.into_bytes()
        }
    } else {
        std::mem::take(&mut request.prefix)
    };
    let config = config.effective().into_owned();
    if let Err(error) = config.validate() {
        diagnostic_response(stream, 422, &error, deadline)?;
        return Ok(None);
    }
    let config_bytes = serde_json::to_vec(&config)
        .map_err(|_| (500, "configuration serialization failed".into()))?;
    body_memory
        .resize(
            input
                .capacity()
                .saturating_add(configuration_storage(&config).map_err(|e| (422, e.to_string()))?),
        )
        .map_err(|e| (503, e.to_string()))?;
    let mut hasher = Sha256::new();
    hasher.update(&config_bytes);
    hasher.update(
        serde_json::to_vec(&input_format)
            .map_err(|_| (500, "input format serialization failed".into()))?,
    );
    hasher.update(luau_decompiler::quality::context_fingerprint(&config));
    hasher.update(&input);
    let key: [u8; 32] = hasher.finalize().into();
    let cached = state
        .cache
        .lock()
        .map_err(|_| (500, "cache lock poisoned".into()))?
        .get(&key);
    let cancellation = CancellationToken::new();
    let mut jobs = state
        .jobs
        .lock()
        .map_err(|_| (500, "job registry lock poisoned".into()))?;
    if jobs.draining_since.is_some() {
        return Err((503, "service is draining; new work is not admitted".into()));
    }
    jobs.prune(Instant::now());
    let id = match jobs.allocate_id(request.request_id, &state.sequence) {
        Ok(id) => id,
        Err(error) => {
            drop(jobs);
            let status = if error.stage == "cancelled" {
                499
            } else if error.stage == "conflict" {
                409
            } else {
                503
            };
            diagnostic_response(stream, status, &error, deadline)?;
            return Ok(None);
        }
    };
    if jobs.active.len() >= state.max_jobs {
        return Err((503, "bounded CPU submission queue is full".into()));
    }
    state.active_jobs.fetch_add(1, Ordering::AcqRel);
    jobs.active.insert(id.clone(), cancellation.clone());
    drop(jobs);
    drop(header_memory);
    Ok(Some(Work {
        input,
        config,
        key,
        deadline,
        cancellation,
        guard: JobGuard {
            state: state.clone(),
            id,
        },
        input_memory: body_memory,
        cached,
        input_format,
    }))
}

fn diagnostic_response(
    stream: &mut TcpStream,
    status: u16,
    error: &Error,
    deadline: Instant,
) -> Result<(), (u16, String)> {
    let body = serde_json::to_vec(&json!({"error":error}))
        .map_err(|_| (500, "diagnostic serialization failed".into()))?;
    response(stream, status, &body, "none", deadline)
        .map_err(|_| (0, "diagnostic response ended".into()))?;
    let _ = stream.shutdown(std::net::Shutdown::Write);
    Ok(())
}

fn perform(work: Work) -> Result<PreparedResponse, (u16, String)> {
    let Work {
        input,
        config,
        key,
        deadline,
        cancellation,
        guard,
        input_memory,
        cached,
        input_format,
    } = work;
    if let Some(payload) = cached {
        return Ok(PreparedResponse {
            status: 200,
            payload,
            cache: "hit",
            deadline,
            cancellation,
            _guard: guard,
        });
    }
    let state = guard.state.clone();
    let response_limit = config
        .limits
        .max_output_bytes
        .saturating_mul(8)
        .saturating_add(MAX_CONFIGURATION_BYTES);
    let context = ExecutionContext::new(cancellation.clone(), Some(deadline))
        .with_work_limit(config.limits.max_analysis_steps);
    let result = context
        .clone()
        .with_memory(state.memory.clone())
        .and_then(|context| {
            execution::with_context(context, || {
                let result = luau_decompiler::processing::process(&input, input_format, &config)?;
                let quality_passed = result.validation.required_passed
                    && result.validation.syntax != luau_decompiler::quality::GateStatus::Failed
                    && result.validation.compilation
                        != luau_decompiler::quality::GateStatus::Failed;
                execution::checkpoint()?;
                let payload = serialize_accounted(&state, &result, response_limit)?;
                execution::checkpoint()?;
                Ok((payload, quality_passed))
            })
        });
    drop(input);
    drop(config);
    drop(input_memory);
    let result = result.and_then(|payload| {
        context.check()?;
        Ok(payload)
    });
    let (status, payload, cache, write_deadline) = match result {
        Ok((payload, true)) => {
            state
                .cache
                .lock()
                .map_err(|_| (500, "cache lock poisoned".into()))?
                .insert_accounted(key, payload.clone());
            (200, payload, "miss", deadline)
        }
        Ok((payload, false)) => (422, payload, "none", deadline),
        Err(error) => {
            let status = match error.stage {
                "cancelled" => 499,
                "deadline" => 408,
                "memory" => 503,
                _ => 422,
            };
            let payload = serialize_accounted(&state, &json!({"error":error}), response_limit)
                .map_err(|error| (503, error.to_string()))?;
            (
                status,
                payload,
                "none",
                Instant::now() + Duration::from_secs(1),
            )
        }
    };
    Ok(PreparedResponse {
        status,
        payload,
        cache,
        deadline: write_deadline,
        cancellation,
        _guard: guard,
    })
}

fn transmit(stream: &mut TcpStream, prepared: PreparedResponse) -> Result<(), (u16, String)> {
    if rayon::current_thread_index().is_some() {
        return Err((
            500,
            "socket response was incorrectly scheduled on the CPU pool".into(),
        ));
    }
    if matches!(prepared.status, 200 | 422) {
        let context = ExecutionContext::new(prepared.cancellation.clone(), Some(prepared.deadline));
        if let Err(error) = context.check() {
            return diagnostic_response(
                stream,
                if error.stage == "cancelled" { 499 } else { 408 },
                &error,
                Instant::now() + Duration::from_secs(1),
            );
        }
    }
    let cancellation = if matches!(prepared.status, 200 | 422) {
        Some(&prepared.cancellation)
    } else {
        None
    };
    response_controlled(
        stream,
        prepared.status,
        &prepared.payload.body,
        prepared.cache,
        prepared.deadline,
        cancellation,
    )
    .map_err(|_| (0, "response transport ended before completion".into()))
}

#[cfg(test)]
fn handle(
    stream: &mut TcpStream,
    state: &Arc<State>,
    accepted: Instant,
) -> Result<(), (u16, String)> {
    if let Some(work) = prepare(stream, state, accepted)? {
        let response = if work.cached.is_some() {
            perform(work)?
        } else {
            state.cpu.install(|| perform(work))?
        };
        transmit(stream, response)
    } else {
        Ok(())
    }
}

pub fn run(options: Options, config: Config) -> Result<(), String> {
    options.validate()?;
    let config = config.effective().into_owned();
    config.validate().map_err(|error| error.to_string())?;
    options.validate_feasibility(&config)?;
    let listener = TcpListener::bind(options.listen)
        .map_err(|error| format!("bind {}: {error}", options.listen))?;
    listener
        .set_nonblocking(true)
        .map_err(|error| format!("configure listener: {error}"))?;
    let mut listener = mio::net::TcpListener::from_std(listener);
    let mut readiness =
        Poll::new().map_err(|error| format!("create listener readiness: {error}"))?;
    readiness
        .registry()
        .register(&mut listener, LISTENER_EVENT, Interest::READABLE)
        .map_err(|error| format!("register listener readiness: {error}"))?;
    let listener_wake = Arc::new(
        Waker::new(readiness.registry(), SHUTDOWN_EVENT)
            .map_err(|error| format!("create shutdown wake: {error}"))?,
    );
    let memory = MemoryBudget::new(options.memory_bytes);
    let cpu = Arc::new(DecompilePool::new(options.cpu_threads).map_err(|e| e.to_string())?);
    let max_jobs = options.queue.saturating_add(options.cpu_threads);
    let (control, control_memory, max_tombstones) =
        reserve_control(&memory, options.workers, max_jobs).map_err(|e| e.to_string())?;
    let state = Arc::new(State {
        config_charge: configuration_storage(&config).map_err(|e| e.to_string())?,
        _config_memory: memory
            .reserve(configuration_storage(&config).map_err(|e| e.to_string())?)
            .map_err(|e| e.to_string())?,
        config,
        token_hash: hash(options.token.as_bytes()),
        timeout: options.timeout,
        cache: Mutex::new(Cache::with_budget(options.cache_bytes, memory.clone())),
        cpu,
        memory,
        control,
        _control_memory: control_memory,
        max_tombstones,
        jobs: Mutex::new(JobRegistry::default()),
        jobs_changed: Condvar::new(),
        active_jobs: AtomicUsize::new(0),
        pending_connections: Arc::new(AtomicUsize::new(0)),
        pending_responses: Arc::new(AtomicUsize::new(0)),
        connection_capacity: options.queue,
        max_jobs,
        sequence: AtomicU64::new(1),
        shutdown: AtomicBool::new(false),
        listener_wake: Some(listener_wake),
        #[cfg(test)]
        body_read_ready: Mutex::new(None),
    });
    let (sender, receiver) = mpsc::sync_channel::<Connection>(options.queue);
    let receiver = Arc::new(Mutex::new(receiver));
    let (writers, write_receiver) = mpsc::sync_channel::<Transmission>(max_jobs);
    let write_receiver = Arc::new(Mutex::new(write_receiver));
    let mut response_workers = Vec::with_capacity(options.workers);
    for index in 0..options.workers {
        let receiver = write_receiver.clone();
        response_workers.push(
            thread::Builder::new()
                .name(format!("bridge-response-{index}"))
                .spawn(move || loop {
                    let received = match receiver.lock() {
                        Ok(receiver) => receiver.recv(),
                        Err(_) => return,
                    };
                    let Ok(Transmission {
                        mut stream,
                        response,
                        pending,
                    }) = received
                    else {
                        return;
                    };
                    drop(pending);
                    let result = match response {
                        Ok(response) => transmit(&mut stream, response),
                        Err(error) => Err(error),
                    };
                    if let Err((status, message)) = result {
                        if status != 0 {
                            fail(&mut stream, status, &message);
                        }
                    }
                })
                .map_err(|error| format!("create response worker: {error}"))?,
        );
    }
    let mut front_workers = Vec::with_capacity(options.workers);
    for index in 0..options.workers {
        let receiver = receiver.clone();
        let state = state.clone();
        let writers = writers.clone();
        front_workers.push(
            thread::Builder::new()
                .name(format!("bridge-{index}"))
                .spawn(move || loop {
                    let received = match receiver.lock() {
                        Ok(receiver) => receiver.recv(),
                        Err(_) => return,
                    };
                    let Ok(Connection {
                        mut stream,
                        accepted,
                        pending,
                    }) = received
                    else {
                        return;
                    };
                    drop(pending);
                    let _ = stream.set_write_timeout(Some(state.timeout));
                    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                        prepare(&mut stream, &state, accepted)
                    }));
                    match result {
                        Ok(Ok(None)) => {}
                        Ok(Ok(Some(work))) => {
                            if work.cached.is_some() {
                                let _ = writers.try_send(Transmission::new(
                                    stream,
                                    perform(work),
                                    &state,
                                ));
                                continue;
                            }
                            let cpu = state.cpu.clone();
                            let writers = writers.clone();
                            let state = state.clone();
                            cpu.spawn(move || {
                                let result =
                                    std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                                        perform(work)
                                    }));
                                let response = match result {
                                    Ok(response) => response,
                                    Err(_) => Err((500, "internal decompilation failure".into())),
                                };
                                let _ =
                                    writers.try_send(Transmission::new(stream, response, &state));
                            });
                        }
                        Ok(Err((0, _))) => {}
                        Ok(Err((status, message))) => fail(&mut stream, status, &message),
                        Err(_) => fail(&mut stream, 500, "internal decompilation failure"),
                    }
                })
                .map_err(|error| format!("create bridge worker: {error}"))?,
        );
    }
    eprintln!(
        "bridge listening on http://{}/v1/decompile ({} workers, queue {}, cache {} bytes)",
        listener.local_addr().map_err(|e| e.to_string())?,
        options.workers,
        options.queue,
        options.cache_bytes
    );
    let mut events = Events::with_capacity(2);
    'accepting: loop {
        if state.shutdown.load(Ordering::Acquire) {
            break;
        }
        match readiness.poll(&mut events, None) {
            Ok(()) => {}
            Err(error) if error.kind() == std::io::ErrorKind::Interrupted => continue,
            Err(error) => return Err(format!("wait for listener readiness: {error}")),
        }
        for event in &events {
            if event.token() != LISTENER_EVENT {
                continue;
            }
            loop {
                if state.shutdown.load(Ordering::Acquire) {
                    break 'accepting;
                }
                let (stream, peer) = match listener.accept() {
                    Ok(accepted) => accepted,
                    Err(error) if error.kind() == std::io::ErrorKind::WouldBlock => break,
                    Err(error)
                        if matches!(
                            error.kind(),
                            std::io::ErrorKind::Interrupted
                                | std::io::ErrorKind::ConnectionAborted
                                | std::io::ErrorKind::ConnectionReset
                        ) =>
                    {
                        continue
                    }
                    Err(error) => return Err(format!("accept connection: {error}")),
                };
                let stream: TcpStream = stream.into();
                stream
                    .set_nonblocking(false)
                    .map_err(|error| format!("configure accepted connection: {error}"))?;
                if !peer.ip().is_loopback() && !options.allow_remote {
                    continue;
                }
                let _ = stream.set_nodelay(true);
                match sender.try_send(Connection {
                    stream,
                    accepted: Instant::now(),
                    pending: PendingHandoff::new(&state.pending_connections),
                }) {
                    Ok(()) => {}
                    Err(mpsc::TrySendError::Full(Connection { mut stream, .. })) => {
                        let _ = stream.set_write_timeout(Some(Duration::from_millis(100)));
                        fail(&mut stream, 503, "bridge request queue is full");
                    }
                    Err(mpsc::TrySendError::Disconnected(_)) => {
                        return Err("all bridge workers disconnected".into())
                    }
                }
            }
        }
    }
    drop(listener);
    drop(sender);
    for worker in front_workers {
        worker
            .join()
            .map_err(|_| "bridge worker panicked during shutdown".to_owned())?;
    }
    let drain_started = state
        .jobs
        .lock()
        .map_err(|_| "job registry lock poisoned".to_owned())?
        .draining_since
        .unwrap_or_else(Instant::now);
    if !state.wait_for_idle_until(drain_started + state.timeout)? {
        let jobs = state
            .jobs
            .lock()
            .map_err(|_| "job registry lock poisoned".to_owned())?;
        for token in jobs.active.values() {
            token.cancel();
        }
        drop(jobs);
        if !state.wait_for_idle_until(Instant::now() + Duration::from_secs(2))? {
            return Err(
                "shutdown cancelled outstanding jobs but bounded drain did not complete".into(),
            );
        }
    }
    drop(writers);
    for worker in response_workers {
        worker
            .join()
            .map_err(|_| "response worker panicked during shutdown".to_owned())?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tiny_packet() -> Vec<u8> {
        let mut input = vec![6, 3, 0, 0, 1, 2, 0, 0, 0, 0, 0, 2];
        input.extend([4, 0, 42, 0, 22, 0, 2, 0]);
        input.extend([0; 7]);
        input
    }
    fn varint(mut value: usize, out: &mut Vec<u8>) {
        loop {
            let mut part = (value & 127) as u8;
            value >>= 7;
            if value != 0 {
                part |= 128;
            }
            out.push(part);
            if value == 0 {
                break;
            }
        }
    }
    fn large_unused_string(limit: usize) -> Vec<u8> {
        let length = limit - 64;
        let mut bytes = vec![6, 3, 1];
        varint(length, &mut bytes);
        bytes.resize(bytes.len() + length, b'x');
        bytes.extend([0, 1, 1, 0, 0, 0, 0, 0, 1]);
        bytes.extend_from_slice(
            &(luau_decompiler::bytecode::Opcode::Return as u32 | (1 << 16)).to_le_bytes(),
        );
        bytes.extend([0; 7]);
        bytes
    }
    fn no_cache_state(timeout: Duration) -> Arc<State> {
        let mut state = test_state(timeout);
        Arc::get_mut(&mut state)
            .unwrap()
            .cache
            .get_mut()
            .unwrap()
            .limit = 0;
        state
    }
    fn prepared_work(state: &Arc<State>, bytes: &[u8]) -> (TcpStream, TcpStream, Work) {
        let listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let mut client = TcpStream::connect(listener.local_addr().unwrap()).unwrap();
        let (mut server, _) = listener.accept().unwrap();
        client
            .write_all(&wire(bytes, "application/octet-stream"))
            .unwrap();
        let work = prepare(&mut server, state, Instant::now())
            .unwrap()
            .unwrap();
        (server, client, work)
    }

    #[test]
    fn staged_admission_replaces_max_output_reservations_and_accepts_near_input_limit() {
        let tiny = tiny_packet();
        let state = no_cache_state(Duration::from_secs(5));
        let old_tiny =
            tiny.len() * 48 + Config::default().limits.max_output_bytes * 8 + 1024 * 1024;
        assert!(old_tiny >= 257 * 1024 * 1024);
        assert!(
            exchange_state(wire(&tiny, "application/octet-stream"), state.clone())
                .starts_with("HTTP/1.1 200")
        );
        let tiny_peak = state.memory.peak();
        assert!(
            tiny_peak < 4 * 1024 * 1024,
            "tiny request retained {tiny_peak} bytes"
        );
        assert_eq!(state.memory.used(), state.fixed_memory());
        let mut large_state = no_cache_state(Duration::from_secs(10));
        let limit = large_state.config.limits.max_bytes;
        Arc::get_mut(&mut large_state)
            .unwrap()
            .config
            .limits
            .max_string_bytes = limit;
        let large = large_unused_string(limit);
        assert!(large.len() <= limit && large.len() > limit - 128);
        let old_large =
            large.len() * 53 + Config::default().limits.max_output_bytes * 8 + 1024 * 1024;
        assert!(old_large > large_state.memory.limit());
        let response = exchange_state(
            wire(&large, "application/octet-stream"),
            large_state.clone(),
        );
        assert!(response.starts_with("HTTP/1.1 200"), "{response}");
        assert!(large_state.memory.peak() < 128 * 1024 * 1024);
        assert_eq!(large_state.memory.used(), large_state.fixed_memory());
        let report = json!({"schema":1,"policy":"staged transport/decode/validated-shape analysis/controlled output and shared response-cache capacities; not RSS quota","validation_mode":"off; analyzer workers are validated independently","tiny":{"input_bytes":tiny.len(),"legacy_admission_bytes":old_tiny,"new_aggregate_peak_bytes":tiny_peak,"complete":true},"near_raw_limit":{"input_bytes":large.len(),"raw_limit_bytes":limit,"max_string_bytes":limit,"fixture":"synthetic valid v6 returning no values, unused string payload","legacy_admission_bytes":old_large,"new_aggregate_peak_bytes":large_state.memory.peak(),"complete":true},"memory_limit_bytes":large_state.memory.limit(),"all_leases_released":true});
        std::fs::create_dir_all("docs/results").unwrap();
        std::fs::write(
            "docs/results/service-v3.json",
            serde_json::to_vec_pretty(&report).unwrap(),
        )
        .unwrap();
    }

    #[test]
    fn startup_rejects_infeasible_transport_limits_before_binding() {
        let mut options = Options {
            listen: "127.0.0.1:0".parse().unwrap(),
            allow_remote: false,
            token: "x".repeat(32),
            workers: 2,
            queue: 4,
            cache_bytes: 0,
            timeout: Duration::from_secs(1),
            cpu_threads: 2,
            memory_bytes: 1024 * 1024 * 1024,
        };
        options.validate_feasibility(&Config::default()).unwrap();
        options.memory_bytes = 1024 * 1024;
        assert!(options
            .validate_feasibility(&Config::default())
            .unwrap_err()
            .contains("cannot admit configured max_bytes"));
        let mut small = Config::default();
        small.limits.max_bytes = 64 * 1024;
        options.memory_bytes = luau_decompiler::quality::ANALYZER_RESIDENT_BYTES;
        assert!(
            options.validate_feasibility(&small).is_err(),
            "enabled checking also needs transport and request storage"
        );
        small.validation.mode = luau_decompiler::quality::ValidationMode::Off;
        options.validate_feasibility(&small).unwrap();
        small.output_policy = luau_decompiler::config::OutputPolicy::VerifiedTyped;
        assert!(small.validate().is_err());
        small.validation.mode = luau_decompiler::quality::ValidationMode::Check;
        assert!(run(options, small)
            .unwrap_err()
            .contains("cannot admit configured max_bytes"));
    }

    #[test]
    fn cold_admission_overload_releases_input_and_recovers() {
        let state = no_cache_state(Duration::from_secs(2));
        let tiny = tiny_packet();
        let mut held = Vec::new();
        for _ in 0..state.max_jobs {
            held.push(prepared_work(&state, &tiny));
        }
        assert!(state.memory.peak() < 4 * 1024 * 1024);
        assert!(
            exchange_state(wire(&tiny, "application/octet-stream"), state.clone())
                .starts_with("HTTP/1.1 503")
        );
        drop(held.pop());
        assert!(
            exchange_state(wire(&tiny, "application/octet-stream"), state.clone())
                .starts_with("HTTP/1.1 200")
        );
        drop(held);
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert_eq!(state.memory.used(), state.fixed_memory());
    }

    #[test]
    fn simultaneous_cold_requests_share_the_persistent_pool_without_maximum_output_charges() {
        let mut state = no_cache_state(Duration::from_secs(5));
        let (control, reservation, history) = reserve_control(&state.memory, 8, 16).unwrap();
        let mutable = Arc::get_mut(&mut state).unwrap();
        mutable.max_jobs = 16;
        mutable.control = control;
        mutable._control_memory = reservation;
        mutable.max_tombstones = history;
        let barrier = Arc::new(std::sync::Barrier::new(9));
        let mut workers = Vec::new();
        for _ in 0..8 {
            let state = state.clone();
            let barrier = barrier.clone();
            workers.push(thread::spawn(move || {
                barrier.wait();
                exchange_state(wire(&tiny_packet(), "application/octet-stream"), state)
            }));
        }
        barrier.wait();
        for worker in workers {
            assert!(worker.join().unwrap().starts_with("HTTP/1.1 200"));
        }
        assert!(state.memory.peak() < 8 * 1024 * 1024);
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert_eq!(state.memory.used(), state.fixed_memory());
    }

    #[test]
    fn slow_reader_keeps_payload_accounted_but_cannot_hold_cpu_workers() {
        for status in [200, 422] {
            let state = no_cache_state(Duration::from_secs(5));
            let baseline = state.memory.used();
            let (mut server, mut client, work) = prepared_work(&state, &tiny_packet());
            let mut prepared = state.cpu.install(|| perform(work)).unwrap();
            prepared.status = status;
            let size = 32 * 1024 * 1024;
            let lease = reserve_data(&state, size + CACHE_ENTRY_OVERHEAD).unwrap();
            prepared.payload = Arc::new(CacheEntry {
                body: Arc::new(vec![b'x'; size]),
                _memory: lease,
            });
            let cancellation = prepared.cancellation.clone();
            let (started, waiting) = mpsc::channel();
            let (finished, completion) = mpsc::channel();
            let writer = thread::Builder::new()
                .name("test-response-writer".into())
                .spawn(move || {
                    started.send(()).unwrap();
                    finished.send(transmit(&mut server, prepared)).unwrap();
                })
                .unwrap();
            waiting.recv().unwrap();
            client
                .set_read_timeout(Some(Duration::from_secs(2)))
                .unwrap();
            let mut response_prefix = [0u8; 12];
            client.read_exact(&mut response_prefix).unwrap();
            assert_eq!(&response_prefix, format!("HTTP/1.1 {status}").as_bytes());
            let (sentinel, ready) = mpsc::channel();
            for _ in 0..2 {
                let sentinel = sentinel.clone();
                state.cpu.spawn(move || sentinel.send(()).unwrap());
            }
            for _ in 0..2 {
                ready
                    .recv_timeout(Duration::from_secs(1))
                    .expect("slow reader occupied CPU worker");
            }
            assert!(
                state.memory.used() >= baseline + size,
                "response payload lease released before transmission"
            );
            cancellation.cancel();
            assert!(completion
                .recv_timeout(Duration::from_secs(2))
                .unwrap()
                .is_err());
            writer.join().unwrap();
            drop(client);
            assert_eq!(state.memory.used(), baseline);
            assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        }
    }

    #[test]
    fn canonical_config_overrides_are_validated_and_output_keys_do_not_collide() {
        let base = Config::default();
        let changed=merge_config(&base,&json!({"naming":"camelCase","indent":"\t","formatting":{"line_width":80},"validation":{"mode":"off"}})).unwrap();
        assert_eq!(changed.indent, "\t");
        assert_eq!(changed.formatting.line_width, 80);
        assert_ne!(
            hash(&serde_json::to_vec(&base).unwrap()),
            hash(&serde_json::to_vec(&changed).unwrap())
        );
        assert!(merge_config(
            &base,
            &json!({"limits":{"max_bytes":base.limits.max_bytes+1}})
        )
        .is_err());
        assert!(merge_config(
            &base,
            &json!({"validation":{"analyzer_path":"untrusted.exe"}})
        )
        .unwrap_err()
        .message
        .contains("server-owned"));
        assert!(merge_config(&base, &json!({"formatting":{"invented_option":true}})).is_err());
        let state = test_state(Duration::from_secs(2));
        let response=exchange_state(wire(br#"{"bytecode_base64":"","reconstruction_config":{"formatting":{"invented_option":true}}}"#,"application/json"),state);
        assert!(response.starts_with("HTTP/1.1 422"));
        assert!(response.contains("\"stage\":\"config\""));
        let mut strict = base.clone();
        strict.validation.mode = luau_decompiler::quality::ValidationMode::StrictRequired;
        assert!(merge_config(&strict, &json!({"validation":{"mode":"off"}}))
            .unwrap_err()
            .message
            .contains("cannot downgrade"));
        assert!(merge_config(&strict, &json!({"validation":{"mode":"check"}})).is_err());
    }

    #[test]
    fn response_and_cache_share_one_lease_through_eviction() {
        let state = test_state(Duration::from_secs(2));
        let baseline = state.memory.used();
        let payload =
            serialize_accounted(&state, &json!({"source":"return 42"}), 1024 * 1024).unwrap();
        let charged = state.memory.used();
        assert!(charged > baseline);
        state
            .cache
            .lock()
            .unwrap()
            .insert_accounted([3; 32], payload.clone());
        assert_eq!(
            state.memory.used(),
            charged,
            "cache double-charged the same allocation"
        );
        let held = state.cache.lock().unwrap().get(&[3; 32]).unwrap();
        {
            let mut cache = state.cache.lock().unwrap();
            cache.entries.clear();
            cache.order.clear();
            cache.bytes = 0;
        }
        drop(payload);
        assert_eq!(state.memory.used(), charged);
        drop(held);
        assert_eq!(state.memory.used(), baseline);
    }

    #[test]
    fn request_formatting_settings_are_forwarded_and_cache_keys_include_them() {
        let state = test_state(Duration::from_secs(2));
        let bytes = tiny_packet();
        let alphabet = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        let mut encoded = String::new();
        for chunk in bytes.chunks(3) {
            let n = ((chunk[0] as u32) << 16)
                | ((chunk.get(1).copied().unwrap_or(0) as u32) << 8)
                | chunk.get(2).copied().unwrap_or(0) as u32;
            encoded.push(alphabet[(n >> 18) as usize & 63] as char);
            encoded.push(alphabet[(n >> 12) as usize & 63] as char);
            encoded.push(if chunk.len() > 1 {
                alphabet[(n >> 6) as usize & 63] as char
            } else {
                '='
            });
            encoded.push(if chunk.len() > 2 {
                alphabet[n as usize & 63] as char
            } else {
                '='
            });
        }
        let make = |indent: &str| {
            wire(&serde_json::to_vec(&json!({"bytecode_base64":encoded,"reconstruction_config":{"indent":indent,"formatting":{"line_width":80},"validation":{"mode":"off"}}})).unwrap(),"application/json")
        };
        let first = exchange_state(make("\t"), state.clone());
        assert!(first.starts_with("HTTP/1.1 200"), "{first}");
        assert!(first.contains("X-Decompiler-Cache: miss"));
        let second = exchange_state(make("\t"), state.clone());
        assert!(second.contains("X-Decompiler-Cache: hit"));
        let changed = exchange_state(make("  "), state.clone());
        assert!(changed.starts_with("HTTP/1.1 200"));
        assert!(changed.contains("X-Decompiler-Cache: miss"));
        assert_eq!(state.cache.lock().unwrap().entries.len(), 2);
    }

    #[test]
    fn base64_is_canonical_and_binary_safe() {
        assert_eq!(decode_base64("", 5).unwrap(), b"");
        assert_eq!(decode_base64("AAH/", 3).unwrap(), [0, 1, 255]);
        assert_eq!(decode_base64("Zg==", 1).unwrap(), b"f");
        assert_eq!(decode_base64("Zm8=", 2).unwrap(), b"fo");
        for text in ["Zg=", "Zh==", "Zm9=", "====", "Zg==Zg==", "Zg=+", "Zg\n="] {
            assert!(decode_base64(text, 64).is_err(), "{text}");
        }
        assert!(decode_base64("Zm9v", 2).is_err());
    }

    #[test]
    fn cache_evicts_and_stays_bounded() {
        let mut cache = Cache::new(2 * (3 + CACHE_ENTRY_OVERHEAD));
        cache.insert([1; 32], Arc::new(vec![1; 3]));
        cache.insert([2; 32], Arc::new(vec![2; 3]));
        cache.insert([3; 32], Arc::new(vec![3; 3]));
        assert!(cache.get(&[1; 32]).is_none());
        assert!(cache.get(&[2; 32]).is_some());
        assert!(cache.bytes <= cache.limit);
        cache.insert([3; 32], Arc::new(vec![4; 3]));
        assert_eq!(cache.entries.len(), 2);
        assert_eq!(cache.order.len(), 2);
    }

    #[test]
    fn token_and_bind_validation() {
        assert!(authenticate("Bearer secret", &hash(b"secret")));
        assert!(!authenticate("Bearer Secret", &hash(b"secret")));
        assert!(!authenticate("secret", &hash(b"secret")));
        let mut options = Options {
            listen: "0.0.0.0:7879".parse().unwrap(),
            allow_remote: false,
            token: "x".repeat(32),
            workers: 2,
            queue: 4,
            cache_bytes: 1024,
            timeout: Duration::from_secs(1),
            cpu_threads: 2,
            memory_bytes: 1024 * 1024 * 1024,
        };
        assert!(options.validate().is_err());
        options.allow_remote = true;
        assert!(options.validate().is_ok());
    }

    #[test]
    fn handshake_cpu_pool_and_structured_diagnostics_are_preserved() {
        let state = test_state(Duration::from_secs(2));
        let response=exchange_state(b"GET /v1/capabilities HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\n\r\n".to_vec(),state.clone());
        let body: serde_json::Value =
            serde_json::from_str(response.split_once("\r\n\r\n").unwrap().1).unwrap();
        assert_eq!(body["protocol_version"], 2);
        assert_eq!(body["cpu_threads"], 2);
        assert!(body["encodings"]
            .as_array()
            .unwrap()
            .iter()
            .any(|v| v == "roblox_opcode227"));
        let invalid = exchange_state(
            wire(br#"{"bytecode_base64":"Bg=="}"#, "application/json"),
            state.clone(),
        );
        let error: serde_json::Value =
            serde_json::from_str(invalid.split_once("\r\n\r\n").unwrap().1).unwrap();
        assert_eq!(error["error"]["stage"], "decode");
        assert_eq!(error["error"]["offset"], 1);
        let input = include_bytes!("../tests/fixtures/many_functions.O1.D2.bc");
        let success = exchange_state(wire(input, "application/octet-stream"), state.clone());
        let result: serde_json::Value =
            serde_json::from_str(success.split_once("\r\n\r\n").unwrap().1).unwrap();
        assert_eq!(result["complete"], true);
        assert_eq!(result["stats"]["cpu_pool_threads"], 2);
        assert!(result["bindings"].as_array().is_some());
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert!(state.jobs.lock().unwrap().active.is_empty());
        assert!(
            state.memory.used() < 16 * 1024 * 1024,
            "analysis reservations must release after response"
        );
    }

    #[test]
    fn aggregate_budget_counts_evicted_payloads_until_last_client_releases() {
        let memory = MemoryBudget::new(500);
        let mut cache = Cache::with_budget(400, memory.clone());
        cache.insert([1; 32], Arc::new(vec![1; 100]));
        let held = cache.get(&[1; 32]).unwrap();
        assert_eq!(memory.used(), 100 + CACHE_ENTRY_OVERHEAD);
        cache.insert([2; 32], Arc::new(vec![2; 100]));
        assert!(
            cache.get(&[2; 32]).is_none(),
            "retained old payload must prevent over-admission"
        );
        drop(held);
        assert_eq!(memory.used(), 0);
    }

    #[test]
    fn cancellation_control_remains_responsive_with_busy_cpu_workers() {
        let state = test_state(Duration::from_secs(2));
        let token = CancellationToken::new();
        state
            .jobs
            .lock()
            .unwrap()
            .active
            .insert("busy".into(), token.clone());
        let barrier = Arc::new(std::sync::Barrier::new(3));
        let (done, completion) = mpsc::channel();
        for _ in 0..2 {
            let barrier = barrier.clone();
            let done = done.clone();
            let token = token.clone();
            state.cpu.spawn(move || {
                execution::with_context(
                    ExecutionContext::new(token, Some(Instant::now() + Duration::from_secs(5))),
                    || {
                        barrier.wait();
                        while execution::checkpoint().is_ok() {
                            std::hint::spin_loop();
                        }
                        done.send(()).unwrap();
                    },
                )
            });
        }
        barrier.wait();
        let response=exchange_state(b"DELETE /v1/requests/busy HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\n\r\n".to_vec(),state);
        assert!(response.contains("\"cancelled\":true"));
        assert!(token.is_cancelled());
        for _ in 0..2 {
            completion.recv_timeout(Duration::from_secs(1)).unwrap();
        }
    }

    #[test]
    fn cancellation_before_post_is_remembered_even_for_a_cached_result() {
        let state = test_state(Duration::from_secs(2));
        let fixture = include_bytes!("../tests/fixtures/arithmetic.O1.D2.bc");
        let cancelled = exchange_state(cancel_wire("not-yet-submitted"), state.clone());
        assert!(cancelled.starts_with("HTTP/1.1 200"));
        assert!(cancelled.contains("\"remembered\":true"));
        let response = exchange_state(wire_id(fixture, "not-yet-submitted"), state.clone());
        assert!(response.starts_with("HTTP/1.1 499"), "{response}");
        let error: serde_json::Value =
            serde_json::from_str(response.split_once("\r\n\r\n").unwrap().1).unwrap();
        assert_eq!(error["error"]["stage"], "cancelled");
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert!(
            exchange_state(wire(fixture, "application/octet-stream"), state.clone())
                .starts_with("HTTP/1.1 200")
        );
        assert!(exchange_state(wire_id(fixture, "not-yet-submitted"), state)
            .starts_with("HTTP/1.1 499"));
    }

    #[test]
    fn pre_cancelled_post_replies_then_drains_separately_transmitted_body_without_reset() {
        let state = test_state(Duration::from_secs(2));
        state.jobs.lock().unwrap().cancelled.insert(
            "split-cancel".into(),
            Instant::now() + Duration::from_secs(2),
        );
        let listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let mut client = TcpStream::connect(listener.local_addr().unwrap()).unwrap();
        let (mut server, _) = listener.accept().unwrap();
        let worker_state = state.clone();
        let (done, finished) = mpsc::channel();
        let worker = thread::spawn(move || {
            let result = handle(&mut server, &worker_state, Instant::now());
            done.send(result).unwrap();
        });
        let body = tiny_packet();
        let wire = wire_id(&body, "split-cancel");
        let boundary = wire
            .windows(4)
            .position(|part| part == b"\r\n\r\n")
            .unwrap()
            + 4;
        client
            .set_read_timeout(Some(Duration::from_secs(2)))
            .unwrap();
        client.write_all(&wire[..boundary]).unwrap();
        let mut prefix = [0u8; 12];
        client.read_exact(&mut prefix).unwrap();
        assert_eq!(&prefix, b"HTTP/1.1 499");
        assert!(
            finished.recv_timeout(Duration::from_millis(20)).is_err(),
            "server closed before draining the remaining framed body"
        );
        client.write_all(&wire[boundary..]).unwrap();
        let mut remainder = String::new();
        client
            .read_to_string(&mut remainder)
            .expect("cancellation diagnostics were replaced by a TCP reset");
        assert!(remainder.contains("\"stage\":\"cancelled\""));
        assert!(finished
            .recv_timeout(Duration::from_secs(1))
            .unwrap()
            .is_ok());
        worker.join().unwrap();
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert_eq!(state.memory.used(), state.fixed_memory());
    }

    #[test]
    fn cancellation_during_body_upload_blocks_cpu_and_cached_publication() {
        for warm_cache in [false, true] {
            let state = test_state(Duration::from_secs(2));
            let fixture = include_bytes!("../tests/fixtures/arithmetic.O1.D2.bc");
            if warm_cache {
                assert!(
                    exchange_state(wire(fixture, "application/octet-stream"), state.clone())
                        .starts_with("HTTP/1.1 200")
                );
            }
            let baseline = state.memory.used();
            let listener = TcpListener::bind("127.0.0.1:0").unwrap();
            let address = listener.local_addr().unwrap();
            let worker_state = state.clone();
            let worker = thread::spawn(move || {
                let (mut stream, _) = listener.accept().unwrap();
                handle(&mut stream, &worker_state, Instant::now()).unwrap();
            });
            let request = wire_id(fixture, "upload-race");
            let header_end = request.windows(4).position(|v| v == b"\r\n\r\n").unwrap() + 4;
            let mut stream = TcpStream::connect(address).unwrap();
            stream
                .set_read_timeout(Some(Duration::from_secs(2)))
                .unwrap();
            stream.write_all(&request[..header_end]).unwrap();
            let wait_deadline = Instant::now() + Duration::from_secs(1);
            while state.memory.used() == baseline {
                assert!(Instant::now() < wait_deadline, "body read was not reached");
                thread::yield_now();
            }
            assert!(exchange_state(cancel_wire("upload-race"), state.clone())
                .starts_with("HTTP/1.1 200"));
            stream.write_all(&request[header_end..]).unwrap();
            let mut response = String::new();
            stream.read_to_string(&mut response).unwrap();
            worker.join().unwrap();
            assert!(response.starts_with("HTTP/1.1 499"), "{response}");
            assert!(response.contains("\"stage\":\"cancelled\""));
            assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
            assert_eq!(state.memory.used(), baseline);
        }
    }

    #[test]
    fn control_plane_works_when_all_data_memory_is_reserved() {
        let state = test_state(Duration::from_secs(2));
        let token = CancellationToken::new();
        state
            .jobs
            .lock()
            .unwrap()
            .active
            .insert("busy-memory".into(), token.clone());
        let data = state
            .memory
            .reserve(state.memory.limit() - state.memory.used())
            .unwrap();
        assert_eq!(state.memory.used(), state.memory.limit());
        let response = exchange_state(cancel_wire("busy-memory"), state.clone());
        assert!(response.starts_with("HTTP/1.1 200"), "{response}");
        assert!(token.is_cancelled());
        let capabilities=exchange_state(b"GET /v1/capabilities HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\n\r\n".to_vec(),state.clone());
        assert!(capabilities.starts_with("HTTP/1.1 200"), "{capabilities}");
        assert_eq!(state.control.used(), 0);
        drop(data);
        assert_eq!(state.memory.used(), state.fixed_memory());
    }

    #[test]
    fn generated_ids_skip_active_and_cancelled_names_and_history_expires() {
        let state = test_state(Duration::from_secs(2));
        let mut jobs = state.jobs.lock().unwrap();
        jobs.active
            .insert("server-1".into(), CancellationToken::new());
        jobs.cancelled
            .insert("server-2".into(), Instant::now() + Duration::from_secs(1));
        assert_eq!(jobs.allocate_id(None, &state.sequence).unwrap(), "server-3");
        assert_eq!(
            jobs.allocate_id(Some("server-1".into()), &state.sequence)
                .unwrap_err()
                .stage,
            "conflict"
        );
        assert_eq!(
            jobs.allocate_id(Some("server-2".into()), &state.sequence)
                .unwrap_err()
                .stage,
            "cancelled"
        );
        jobs.prune(Instant::now() + Duration::from_secs(2));
        assert!(jobs.cancelled.is_empty());
        assert!(jobs
            .allocate_id(Some("server-2".into()), &state.sequence)
            .is_ok());
    }

    #[test]
    fn cancellation_history_is_bounded_without_ignoring_an_active_cancel() {
        let state = test_state(Duration::from_secs(2));
        {
            let mut jobs = state.jobs.lock().unwrap();
            for n in 0..state.max_tombstones {
                jobs.cancelled
                    .insert(format!("old-{n}"), Instant::now() + Duration::from_secs(1));
            }
        }
        assert!(
            exchange_state(cancel_wire("new-unknown"), state.clone()).starts_with("HTTP/1.1 503")
        );
        let token = CancellationToken::new();
        state
            .jobs
            .lock()
            .unwrap()
            .active
            .insert("active-at-limit".into(), token.clone());
        let response = exchange_state(cancel_wire("active-at-limit"), state.clone());
        assert!(response.starts_with("HTTP/1.1 200"));
        assert!(response.contains("\"remembered\":false"));
        assert!(token.is_cancelled());
        assert_eq!(
            state.jobs.lock().unwrap().cancelled.len(),
            state.max_tombstones
        );
    }

    fn test_state(timeout: Duration) -> Arc<State> {
        let memory = MemoryBudget::new(1024 * 1024 * 1024);
        let (control, control_memory, max_tombstones) = reserve_control(&memory, 2, 4).unwrap();
        let mut config = Config::default();
        config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
        Arc::new(State {
            config_charge: configuration_storage(&config).unwrap(),
            _config_memory: memory
                .reserve(configuration_storage(&config).unwrap())
                .unwrap(),
            config,
            token_hash: hash(b"test-token"),
            timeout,
            cache: Mutex::new(Cache::with_budget(1024 * 1024, memory.clone())),
            cpu: Arc::new(DecompilePool::new(2).unwrap()),
            memory,
            control,
            _control_memory: control_memory,
            max_tombstones,
            jobs: Mutex::new(JobRegistry::default()),
            jobs_changed: Condvar::new(),
            active_jobs: AtomicUsize::new(0),
            pending_connections: Arc::new(AtomicUsize::new(0)),
            pending_responses: Arc::new(AtomicUsize::new(0)),
            connection_capacity: 4,
            max_jobs: 4,
            sequence: AtomicU64::new(1),
            shutdown: AtomicBool::new(false),
            listener_wake: None,
            body_read_ready: Mutex::new(None),
        })
    }

    fn exchange(request: Vec<u8>, timeout: Duration) -> String {
        exchange_state(request, test_state(timeout))
    }

    fn exchange_state(request: Vec<u8>, state: Arc<State>) -> String {
        let listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let address = listener.local_addr().unwrap();
        let worker = thread::spawn(move || {
            let (mut stream, _) = listener.accept().unwrap();
            stream
                .set_write_timeout(Some(Duration::from_secs(1)))
                .unwrap();
            if let Err((status, message)) = handle(&mut stream, &state, Instant::now()) {
                if status != 0 {
                    fail(&mut stream, status, &message);
                }
            }
        });
        let mut stream = TcpStream::connect(address).unwrap();
        stream
            .set_read_timeout(Some(Duration::from_secs(2)))
            .unwrap();
        stream.write_all(&request).unwrap();
        let mut response = String::new();
        stream.read_to_string(&mut response).unwrap();
        worker.join().unwrap();
        response
    }

    fn wire(body: &[u8], content_type: &str) -> Vec<u8> {
        let mut request = format!("POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nContent-Type: {content_type}\r\nContent-Length: {}\r\n\r\n", body.len()).into_bytes();
        request.extend_from_slice(body);
        request
    }
    fn cancel_wire(id: &str) -> Vec<u8> {
        format!("DELETE /v1/requests/{id} HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\n\r\n").into_bytes()
    }
    fn wire_id(body: &[u8], id: &str) -> Vec<u8> {
        let mut request=format!("POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nX-Request-Id: {id}\r\nContent-Type: application/octet-stream\r\nContent-Length: {}\r\n\r\n",body.len()).into_bytes();
        request.extend_from_slice(body);
        request
    }

    #[test]
    fn wire_protocol_rejects_unauthenticated_and_ambiguous_input() {
        assert!(exchange(
            b"POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nContent-Length: 0\r\n\r\n".to_vec(),
            Duration::from_secs(1)
        )
        .starts_with("HTTP/1.1 401"));
        assert!(exchange(b"POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nContent-Length: 0\r\nContent-Length: 0\r\n\r\n".to_vec(), Duration::from_secs(1)).starts_with("HTTP/1.1 400"));
        assert!(exchange(b"POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nTransfer-Encoding: chunked\r\nContent-Length: 0\r\n\r\n".to_vec(), Duration::from_secs(1)).starts_with("HTTP/1.1 400"));
    }

    #[test]
    fn body_timeout_is_a_real_socket_deadline() {
        let request = b"POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nContent-Type: application/octet-stream\r\nContent-Length: 1\r\n\r\n".to_vec();
        assert!(exchange(request, Duration::from_millis(100)).starts_with("HTTP/1.1 408"));
    }

    #[test]
    fn framing_limits_and_authentication_are_checked_before_body_read() {
        let unauthenticated = b"POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer private-token\r\nContent-Type: application/octet-stream\r\nContent-Length: 10000000\r\n\r\n";
        let result = exchange(unauthenticated.to_vec(), Duration::from_millis(100));
        assert!(result.starts_with("HTTP/1.1 401"));
        assert!(!result.contains("private-token"));
        let oversized = b"POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nContent-Type: application/octet-stream\r\nContent-Length: 999999999\r\n\r\n";
        assert!(
            exchange(oversized.to_vec(), Duration::from_millis(100)).starts_with("HTTP/1.1 413")
        );
        assert!(
            exchange(wire(b"", "image/png"), Duration::from_secs(1)).starts_with("HTTP/1.1 415")
        );
        let mut header = b"POST /v1/decompile HTTP/1.1\r\nX-Pad: ".to_vec();
        header.resize(MAX_HEADER, b'x');
        assert!(exchange(header, Duration::from_secs(1)).starts_with("HTTP/1.1 431"));
        assert!(exchange(b"POST ".to_vec(), Duration::from_millis(100)).starts_with("HTTP/1.1 408"));
    }

    #[test]
    fn raw_success_is_cached_and_json_base64_is_validated() {
        let mut input = vec![6, 3, 0, 0, 1, 2, 0, 0, 0, 0, 0, 2];
        input.extend([4, 0, 42, 0, 22, 0, 2, 0]);
        input.extend([0; 7]);
        let state = test_state(Duration::from_secs(2));
        let first = exchange_state(wire(&input, "application/octet-stream"), state.clone());
        assert!(first.starts_with("HTTP/1.1 200"), "{first}");
        assert!(first.contains("X-Decompiler-Cache: miss"));
        let (_, body) = first.split_once("\r\n\r\n").unwrap();
        let json: serde_json::Value = serde_json::from_str(body).unwrap();
        assert!(json["source"].as_str().unwrap().contains("42"));
        let second = exchange_state(wire(&input, "application/octet-stream"), state);
        assert!(second.contains("X-Decompiler-Cache: hit"));
        let malformed = exchange(
            wire(br#"{"bytecode_base64":"Zh=="}"#, "application/json"),
            Duration::from_secs(1),
        );
        assert!(malformed.starts_with("HTTP/1.1 400"));
        let decoded = exchange(
            wire(br#"{"bytecode_base64":"AA=="}"#, "application/json"),
            Duration::from_secs(1),
        );
        assert!(decoded.starts_with("HTTP/1.1 422"));
    }

    #[test]
    fn cached_slow_reader_is_registered_cancellable_and_does_not_hold_front_end() {
        let mut state = test_state(Duration::from_secs(5));
        Arc::get_mut(&mut state)
            .unwrap()
            .cache
            .get_mut()
            .unwrap()
            .limit = 64 * 1024 * 1024;
        let baseline = state.memory.used();
        let (_, _, cold) = prepared_work(&state, &tiny_packet());
        let key = cold.key;
        drop(cold);
        let size = 32 * 1024 * 1024;
        let entry = Arc::new(CacheEntry {
            body: Arc::new(vec![b'x'; size]),
            _memory: reserve_data(&state, size + CACHE_ENTRY_OVERHEAD).unwrap(),
        });
        state
            .cache
            .lock()
            .unwrap()
            .insert_accounted(key, entry.clone());
        drop(entry);
        let prepared_at = Instant::now();
        let (mut server, mut client, cached) = prepared_work(&state, &tiny_packet());
        assert!(prepared_at.elapsed() < Duration::from_secs(1));
        assert!(cached.cached.is_some());
        let id = cached.guard.id.clone();
        let token = cached.cancellation.clone();
        let prepared = perform(cached).unwrap();
        assert_eq!(prepared.cache, "hit");
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 1);
        let (finished, completion) = mpsc::channel();
        let writer = thread::spawn(move || finished.send(transmit(&mut server, prepared)).unwrap());
        client
            .set_read_timeout(Some(Duration::from_secs(2)))
            .unwrap();
        let mut response_prefix = [0u8; 12];
        client.read_exact(&mut response_prefix).unwrap();
        assert_eq!(&response_prefix, b"HTTP/1.1 200");
        assert!(
            completion.recv_timeout(Duration::from_millis(50)).is_err(),
            "large cached response completed despite an unread body"
        );
        let cancelled = exchange_state(cancel_wire(&id), state.clone());
        assert!(cancelled.contains("\"active\":true"), "{cancelled}");
        assert!(token.is_cancelled());
        completion
            .recv_timeout(Duration::from_secs(2))
            .expect("cached transmission ignored cancellation")
            .unwrap_err();
        writer.join().unwrap();
        drop(client);
        state
            .cache
            .lock()
            .unwrap()
            .evict_for_headroom(state.memory.limit());
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert!(state.jobs.lock().unwrap().active.is_empty());
        assert_eq!(state.memory.used(), baseline);
    }

    #[test]
    fn cached_queue_disposal_releases_request_ids_and_output_ownership() {
        let state = test_state(Duration::from_secs(2));
        assert!(exchange_state(
            wire(&tiny_packet(), "application/octet-stream"),
            state.clone()
        )
        .starts_with("HTTP/1.1 200"));
        let baseline = state.memory.used();
        let (sender, receiver) = mpsc::sync_channel(1);
        let (server, client, work) = prepared_work(&state, &tiny_packet());
        assert!(work.cached.is_some());
        sender
            .try_send(Transmission::new(server, perform(work), &state))
            .unwrap_or_else(|_| panic!("empty writer queue rejected"));
        let (second_server, second_client, second) = prepared_work(&state, &tiny_packet());
        let rejected = sender.try_send(Transmission::new(second_server, perform(second), &state));
        assert!(matches!(rejected, Err(mpsc::TrySendError::Full(_))));
        drop(rejected);
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 1);
        assert_eq!(state.pending_responses.load(Ordering::Acquire), 1);
        drop(receiver);
        drop(sender);
        drop(client);
        drop(second_client);
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert_eq!(state.pending_responses.load(Ordering::Acquire), 0);
        assert_eq!(state.memory.used(), baseline);
    }

    #[test]
    fn sustained_cached_rejected_and_disconnected_requests_release_all_job_resources() {
        let state = test_state(Duration::from_secs(2));
        assert!(exchange_state(
            wire(&tiny_packet(), "application/octet-stream"),
            state.clone()
        )
        .starts_with("HTTP/1.1 200"));
        let baseline = state.memory.used();
        for index in 0..120 {
            let (mut server, client, work) = prepared_work(&state, &tiny_packet());
            assert!(work.cached.is_some());
            let prepared = perform(work).unwrap();
            if index % 3 == 0 {
                prepared.cancellation.cancel();
            }
            drop(client);
            let _ = transmit(&mut server, prepared);
            assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
            assert!(state.jobs.lock().unwrap().active.is_empty());
            assert_eq!(state.memory.used(), baseline);
        }
    }

    #[test]
    fn shutdown_rejects_a_request_paused_before_its_body_is_complete() {
        let state = test_state(Duration::from_secs(2));
        let baseline = state.memory.used();
        let (ready, waiting) = mpsc::sync_channel(1);
        *state.body_read_ready.lock().unwrap() = Some(ready);
        let listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let address = listener.local_addr().unwrap();
        let request_state = state.clone();
        let worker = thread::spawn(move || {
            let (mut stream, _) = listener.accept().unwrap();
            stream
                .set_write_timeout(Some(Duration::from_secs(2)))
                .unwrap();
            if let Err((status, message)) = handle(&mut stream, &request_state, Instant::now()) {
                if status != 0 {
                    fail(&mut stream, status, &message);
                }
            }
        });
        let mut client = TcpStream::connect(address).unwrap();
        client
            .set_read_timeout(Some(Duration::from_secs(3)))
            .unwrap();
        let packet = tiny_packet();
        let header = format!("POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nX-Request-Id: paused-before-shutdown\r\nContent-Type: application/octet-stream\r\nContent-Length: {}\r\n\r\n", packet.len());
        client.write_all(header.as_bytes()).unwrap();
        waiting.recv_timeout(Duration::from_secs(2)).unwrap();
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        let stopped = exchange_state(b"POST /v1/shutdown HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nContent-Length: 0\r\n\r\n".to_vec(), state.clone());
        assert!(stopped.starts_with("HTTP/1.1 200"));
        client.write_all(&packet).unwrap();
        let mut response = String::new();
        client.read_to_string(&mut response).unwrap();
        worker.join().unwrap();
        assert!(response.starts_with("HTTP/1.1 503"), "{response}");
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert!(state.jobs.lock().unwrap().active.is_empty());
        assert_eq!(state.control.used(), 0);
        assert_eq!(state.memory.used(), baseline);
    }

    #[test]
    fn shutdown_tracks_previously_admitted_work_until_cancellation_and_disposal() {
        let state = test_state(Duration::from_secs(2));
        let baseline = state.memory.used();
        let (_server, _client, work) = prepared_work(&state, &tiny_packet());
        let id = work.guard.id.clone();
        let token = work.cancellation.clone();
        state.begin_shutdown().unwrap();
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 1);
        assert!(state.jobs.lock().unwrap().active.contains_key(&id));
        assert!(!state.wait_for_idle_until(Instant::now()).unwrap());
        let cancelled = exchange_state(cancel_wire(&id), state.clone());
        assert!(cancelled.starts_with("HTTP/1.1 200"));
        assert!(cancelled.contains("\"active\":true"));
        assert!(token.is_cancelled());
        let waiting_state = state.clone();
        let waiter = thread::spawn(move || {
            waiting_state
                .wait_for_idle_until(Instant::now() + Duration::from_secs(2))
                .unwrap()
        });
        drop(work);
        assert!(waiter.join().unwrap());
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
        assert!(state.jobs.lock().unwrap().active.is_empty());
        assert_eq!(state.control.used(), 0);
        assert_eq!(state.memory.used(), baseline);
    }

    #[test]
    fn health_readiness_and_shutdown_are_authenticated_and_drain_admission() {
        let state = test_state(Duration::from_secs(2));
        let control = |method: &str, path: &str| {
            format!("{method} {path} HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\nContent-Length: 0\r\n\r\n").into_bytes()
        };
        assert!(exchange_state(
            b"GET /healthz HTTP/1.1\r\nHost: localhost\r\n\r\n".to_vec(),
            state.clone()
        )
        .starts_with("HTTP/1.1 401"));
        let health = exchange_state(control("GET", "/healthz"), state.clone());
        assert!(health.starts_with("HTTP/1.1 200") && health.contains("\"ready\":true"));
        assert!(
            exchange_state(control("POST", "/v1/shutdown"), state.clone())
                .contains("\"shutting_down\":true")
        );
        assert!(
            exchange_state(control("GET", "/readyz"), state.clone()).starts_with("HTTP/1.1 503")
        );
        assert!(exchange_state(
            wire(&tiny_packet(), "application/octet-stream"),
            state.clone()
        )
        .starts_with("HTTP/1.1 503"));
        assert!(exchange_state(cancel_wire("draining"), state.clone()).starts_with("HTTP/1.1 200"));
    }

    #[test]
    fn source_and_bytecode_payloads_share_the_core_without_ambiguous_json() {
        let state = test_state(Duration::from_secs(2));
        let source = b"local value: number = 42\nreturn value\n";
        let first = exchange_state(wire(source, "application/x-luau"), state.clone());
        assert!(first.starts_with("HTTP/1.1 200"), "{first}");
        let body: serde_json::Value =
            serde_json::from_str(first.split_once("\r\n\r\n").unwrap().1).unwrap();
        assert!(
            body["source"].as_str().unwrap().contains("value: number"),
            "{body}"
        );
        assert_eq!(body["profile"], "luau-source");
        let json = serde_json::to_vec(
            &json!({"source":std::str::from_utf8(source).unwrap(),"input_format":"luau_source"}),
        )
        .unwrap();
        let explicit = exchange_state(wire(&json, "application/json"), state.clone());
        assert!(explicit.starts_with("HTTP/1.1 200"), "{explicit}");
        for ambiguous in [
            br#"{"source":"return 1","bytecode_base64":"BgAA"}"#.as_slice(),
            br#"{"source":"return 1","input_format":"luau_bytecode"}"#.as_slice(),
        ] {
            assert!(
                exchange_state(wire(ambiguous, "application/json"), state.clone())
                    .starts_with("HTTP/1.1 400")
            );
        }
    }

    #[test]
    fn failed_required_validation_retains_source_with_unsuccessful_http_status() {
        let mut state = test_state(Duration::from_secs(2));
        let config = &mut Arc::get_mut(&mut state).unwrap().config;
        config.validation.mode = luau_decompiler::quality::ValidationMode::StrictRequired;
        config.validation.analyzer_path = Some("artifacts/absent-service-analyzer".into());
        let readiness = exchange_state(
            b"GET /readyz HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer test-token\r\n\r\n"
                .to_vec(),
            state.clone(),
        );
        assert!(readiness.starts_with("HTTP/1.1 503"), "{readiness}");
        assert!(readiness.contains("\"validation_assets_ready\":false"));
        let result = exchange_state(
            wire(&tiny_packet(), "application/octet-stream"),
            state.clone(),
        );
        assert!(result.starts_with("HTTP/1.1 422"), "{result}");
        let body: serde_json::Value =
            serde_json::from_str(result.split_once("\r\n\r\n").unwrap().1).unwrap();
        assert_eq!(body["complete"], true);
        assert!(!body["source"].as_str().unwrap().is_empty());
        assert_eq!(body["validation"]["required_passed"], false);
        assert!(state.cache.lock().unwrap().entries.is_empty());
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
    }

    #[test]
    fn server_verified_policy_cannot_be_downgraded_by_request_settings() {
        let mut config = Config::default();
        config.output_policy = luau_decompiler::config::OutputPolicy::VerifiedTyped;
        assert!(merge_config(&config, &json!({"output_policy":"annotated"}))
            .unwrap_err()
            .message
            .contains("cannot downgrade"));
        assert!(merge_config(
            &config,
            &json!({"meaningful_typing":{"min_useful_annotations":0}})
        )
        .unwrap_err()
        .message
        .contains("cannot weaken"));
        assert!(merge_config(
            &config,
            &json!({"meaningful_typing":{"max_explicit_any":10}})
        )
        .unwrap_err()
        .message
        .contains("cannot weaken"));
        assert!(merge_config(&config, &json!({"naming":"camelCase"})).is_ok());
    }

    #[test]
    fn verified_request_normalization_precedes_tool_cache_identity_and_admission() {
        let mut state = test_state(Duration::from_secs(2));
        let config = &mut Arc::get_mut(&mut state).unwrap().config;
        config.output_policy = luau_decompiler::config::OutputPolicy::VerifiedTyped;
        config.validation.mode = luau_decompiler::quality::ValidationMode::Check;
        let (_, _, work) = prepared_work(&state, &tiny_packet());
        assert_eq!(
            work.config.validation.mode,
            luau_decompiler::quality::ValidationMode::StrictRequired
        );
        assert_eq!(
            work.config.typing.mode,
            luau_decompiler::types::TypingMode::Annotated
        );
        assert_ne!(
            luau_decompiler::quality::context_fingerprint(&work.config),
            luau_decompiler::quality::context_fingerprint(&state.config)
        );
        drop(work);
        assert_eq!(state.active_jobs.load(Ordering::Acquire), 0);
    }

    #[test]
    fn real_listener_exits_after_authenticated_shutdown() {
        let probe = TcpListener::bind("127.0.0.1:0").unwrap();
        let address = probe.local_addr().unwrap();
        drop(probe);
        let token = "x".repeat(32);
        let options = Options {
            listen: address,
            allow_remote: false,
            token: token.clone(),
            workers: 2,
            queue: 4,
            cache_bytes: 1024 * 1024,
            timeout: Duration::from_secs(2),
            cpu_threads: 2,
            memory_bytes: 1024 * 1024 * 1024,
        };
        let mut config = Config::default();
        config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
        let (done, finished) = mpsc::channel();
        let worker = thread::spawn(move || done.send(run(options, config)).unwrap());
        let connect_deadline = Instant::now() + Duration::from_secs(3);
        let mut socket = loop {
            match TcpStream::connect(address) {
                Ok(stream) => break stream,
                Err(_) if Instant::now() < connect_deadline => {
                    thread::sleep(Duration::from_millis(10))
                }
                Err(error) => panic!("listener startup failed: {error}"),
            }
        };
        socket
            .set_read_timeout(Some(Duration::from_secs(3)))
            .unwrap();
        socket
            .write_all(b"GET /healthz HTTP/1.1\r\nHost: localhost\r\n")
            .unwrap();
        thread::sleep(Duration::from_millis(40));
        socket
            .write_all(format!("Authorization: Bearer {token}\r\n\r\n").as_bytes())
            .unwrap();
        let mut health = String::new();
        socket.read_to_string(&mut health).unwrap();
        assert!(
            health.starts_with("HTTP/1.1 200"),
            "split headers lost blocking read semantics: {health}"
        );
        socket = TcpStream::connect(address).unwrap();
        socket
            .set_read_timeout(Some(Duration::from_secs(3)))
            .unwrap();
        socket.write_all(format!("POST /v1/shutdown HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer {token}\r\nContent-Length: 0\r\n\r\n").as_bytes()).unwrap();
        let mut response = String::new();
        socket.read_to_string(&mut response).unwrap();
        assert!(response.starts_with("HTTP/1.1 200"), "{response}");
        assert!(finished
            .recv_timeout(Duration::from_secs(3))
            .expect("service did not drain and stop")
            .is_ok());
        worker.join().unwrap();
        assert!(TcpStream::connect(address).is_err());
    }
}
