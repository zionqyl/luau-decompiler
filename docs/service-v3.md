# v0.3 bridge settings, resources and transmission

The binary-safe authenticated localhost protocol remains version 2. The
capabilities response advertises `per_request_settings`, staged memory
accounting, bounded response workers and the existing cancellation/diagnostic
features. Catalog or executor capability advertising is separate from an actual
end-to-end compatibility test.

## Per-request canonical settings

An `application/json` POST to `/v1/decompile` accepts `bytecode_base64` and a
`reconstruction_config` partial configuration object. Existing `profile`,
`bytecode_encoding`, `control_flow` and `vector_constructor` fields remain
accepted. The canonical object applies after those legacy fields; omitted
settings inherit the server configuration. JSON null can clear an optional
canonical setting.

```json
{
  "bytecode_base64": "...",
  "reconstruction_config": {
    "naming": "camelCase",
    "indent": "    ",
    "formatting": {"line_width": 100, "multiline_calls": true},
    "typing": {"mode": "annotated", "verbosity": "extensive"},
    "validation": {"mode": "strict_required"}
  }
}
```

The service validates the complete merged configuration. Unknown settings are
errors rather than silently ignored options. A request can lower server limits;
it cannot raise them. Analyzer/definition paths remain server-owned, and requests
cannot raise analyzer worker, timeout, attempt or cache caps. A server configured
with strict-required validation cannot be downgraded by a request. Bounded inline
project/module/type contracts are accepted. The canonical patch is capped at
2 MiB, independently of the bytecode limit.

The cache key covers the exact bytecode and full merged configuration, including
all typing, naming, formatting and quality settings. The independent validation
context fingerprint adds the actual analyzer and definition contents and inline
project contracts, including explicit missing-file states. Paths alone cannot
keep an obsolete result valid after a definition changes.

Native executor option conventions and target dispatch are handled by the shared
Luau adapter and documented executor wrappers. The service receives canonical
settings; it does not interpret an executor's second argument as a timeout.

## Staged accounting

Reservations are conservative, bounded admission accounting, not an allocator
instrumentation system or operating-system RSS quota. The stages are:

1. Resident configuration, request-header/control credits and bounded request-ID
   history have permanent accounted storage. Data requests cannot consume the
   control credits needed for cancellation and capabilities.
2. Raw body capacity follows the advertised actual length. JSON additionally
   reserves actual-body-length-based parsing/merge/copy storage and a
   nonallocating token-shape estimate before serde allocates collections. Large
   arrays of tiny JSON values therefore cannot bypass admission with a short
   input. Request buffers reserve exact capacities before reading.
3. The decoder charges validated string/prototype/instruction/constant/metadata
   capacities before allocation, including bounded verifier scratch storage.
4. Validated instruction, branch, register, wide-result and local counts admit
   analysis. Preflighted expanded AST text has a separate charge. The configured
   maximum output size is a growth limit, not an up-front reservation.
5. Every source printer charges capacity before allocation. Baseline, annotated
   and recovery buffers have distinct reservations retained through execution
   and serialization. All attempts share cancellation, deadlines and the
   algorithmic work counter. Work units are explicit estimates, not CPU
   instruction counts.
6. JSON serialization grows an accounted buffer under a separate finite response
   limit. Input, decoded IR, AST and source storage is disposed before the
   response can wait on a reader. The owned response/cache payload shares one
   lease; eviction does not release storage still held by a writer or caller.

Startup rejects a memory/maximum-input combination that cannot admit one bounded
maximum transport and the initial stages. A particular complex validated program
can still exceed analysis, output, deadline or aggregate admission limits and
receives an explicit diagnostic. Idle analyzer workers have their own persistent
resident reservation, separately from reconstruction. Enabled checking includes
one 192 MiB persistent worker weight in startup feasibility, based on the measured
pinned-definition worker (about 180 MB in the large-case profile); source/project
and response storage are charged separately. This admission model is not a hard
RSS quota. Streaming batch inputs
fork resource/work scopes while sharing the aggregate budget and cancellation;
window storage remains reserved until the ordered sink consumes it.

## Socket writes and cancellation

Reconstruction/serialization run on the persistent CPU pool. A bounded response
queue transfers owned sockets and accounted payloads to separate response
threads. Slow clients cannot turn CPU workers into socket writers. The response
queue has at most one slot per admitted job; a full/disconnected writer queue
disposes its owned payload/socket without blocking a CPU worker.

Response writes use bounded chunks and short cancellation polling intervals.
Cancellation before publication returns the structured cancellation outcome.
After any HTTP response bytes have been sent, a transport failure or cancellation
closes that connection; it never appends a second JSON/HTTP message to a partial
body. Request-ID tombstones still cover DELETE-before-POST and slow-upload races.

## Independently executed regressions

The service test target contains cold concurrent requests, bounded submission
overload and recovery, cache-key separation for request formatting settings,
shared cache/response leases through eviction, startup infeasibility, slow
readers, CPU progress while a writer is blocked, cancellation and lease cleanup.
Existing authentication, framing, body deadlines, diagnostics and restoration
related bridge contracts remain covered separately.

The current [resource report](evidence.md) records a real uncached
27-byte input and a valid synthetic packet within 128 bytes of the default
16 MiB raw input limit. The latter contains an unused large string and returns
no values; the test explicitly raises `max_string_bytes` to 16 MiB. It is a
resource/admission fixture, not a broad semantic or compiler-generated coverage
claim. Validation mode is off for these isolated reconstruction measurements;
native analyzer workers and strict behavior are independently tested.

The report includes the reproduced v0.2 reservation formula and actual v0.3
aggregate-accounting high-water values. Read the recorded numbers rather than
interpreting them as peak process memory. Run:

```powershell
. ./scripts/env.ps1
cargo test --offline --bin luau-decompile service::tests -- --nocapture
cargo test --offline --lib execution::tests -- --nocapture
cargo test --offline --lib runtime::tests -- --nocapture
```
