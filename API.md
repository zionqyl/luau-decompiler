# Library, CLI and bridge API — v0.4.0-rc.4

## Release candidate input and quality additions

The active candidate is `0.4.0-rc.4`. The legacy bytecode functions below remain available. New source and embedding workflows share `processing::process(input: &[u8], format: input::InputFormat, config: &Config) -> Result<Decompiled>`. A reusable `processing::Processor::new(threads)` accepts a caller-owned `execution::ExecutionContext` for cancellation, deadlines and aggregate memory; its bounded batch method preserves result order. See the working [embedding example](examples/embed.rs).

`input::InputFormat` is `Auto`, `LuauBytecode`, `LuauSource`, or `LuaSource`. Content detection and explicit overrides are common to CLI, library and HTTP. Source is parsed directly in Rust and retains original names and valid type syntax. Supported syntax and restrictions are in [source input](docs/source-input.md); standard Lua/LuaJIT bytecode has no backend.

`Config.input_format`, `output_policy`, `meaningful_typing`, and `entry_output` are new. `entry_output: function` returns a function from the generated chunk rather than executing its fixed parameters as a script entry; live upvalue values are not fabricated. Missing serialized capture values remain unsupported. The default remains script output.

`output_policy` is `faithful`, `annotated`, or `verified_typed`. [Policy contracts](docs/output-policies.md) define exact required gates and meaningful annotation thresholds. `validation.required_passed` combines required gates, and `validation.meaningful_typing` retains independent counts/failures. All settings participate in service cache identity. Detailed results retain inspection output on quality failure; they are not successful verified output.

The CLI includes `doctor --json`, a bounded offline check of installed assets and one known verified-typed operation, with a nonzero exit status on failure. It never runs user code or the release corpus. The CLI adds `capabilities`, `--input-format`, and `--policy`. HTTP adds `/v1/process`, `source`/`input_base64`/`input_format` JSON fields, authenticated health/readiness and graceful shutdown. Failed required quality returns HTTP 422 with the full reconstruction result. Legacy `/v1/decompile` and `bytecode_base64` remain supported. Hosting, remote-bind and transport requirements are documented in [self-hosting](docs/hosting.md).

## Library results

```rust
pub fn decompile(input: &[u8], config: &Config) -> Result<Decompiled>;
pub fn decompile_with_threads(input: &[u8], config: &Config, threads: usize)
    -> Result<Decompiled>;
pub fn decompile_batch(inputs: &[Vec<u8>], config: &Config, threads: usize)
    -> Result<Vec<Result<Decompiled>>>;
```

| Result field | Meaning |
| --- | --- |
| `complete` | Every reachable instruction in the accepted lowering was consumed. Unsupported reconstruction returns an error. |
| `input_sha256` | SHA-256 of unchanged original input bytes, independently of finalized-source hashes. |
| `representation` | Bytecode container/encoding, original body length/hash, preserved trailer and authenticity status; absent for source input. Structural recognition never implies a cryptographic signature check. |
| `source`, `baseline_source` | Final selected source and, when retained, the faithful pre-presentation baseline; both include the current canonical attribution. |
| `quality`, `fallback_prototypes` | `structured` or `dispatcher`, with affected zero-based prototype IDs. |
| `profile`, `bindings`, `assumptions` | Profile, recovered binding identities/evidence, and explicit environment contracts. |
| `source_functions` | Original signature offsets, type-only status, retained/inferred return packs and provenance. |
| `source_bindings` | Parsed source identities, retained/original names, declaration byte intervals, scope/capture facts and annotation provenance; no fabricated VM registers or PCs. |
| `closure_scope` | Requested entry policy, compiler-sharing contract, restrictions and assumptions. |
| `type_report` | Inventory versus actual emitted useful/`any` annotations; unknowns, provenance, metadata, return arities and optional failures. |
| `validation` | Separate syntax/compilation/strict statuses, diagnostics/dependencies/assumptions, `any`/assertions, recovery and tool/context hashes. |
| `source_map` | Generated node/function/binding regions, source positions, known bytecode intervals and transformations. Unknown PCs stay absent. |
| `stats` | Bytes/instructions/prototypes; decode/reconstruct/type-infer/format/validation/total microseconds; CPU-pool threads. |

`type_report.unapplied_external_contracts` lists supplied binding identities whose contracts are absent from final-source checking. Required strict/verified policies fail while retaining source and independent strict-analysis results. This prevents recovery from silently discarding a conflicting caller contract.

Source results use `stats.source_statements` and `parse_micros`; bytecode instruction/prototype counts and decoding time remain zero on the source path.

Completeness is not behavioral certification. Library `Ok` may contain failed/unavailable quality; strict callers must inspect `validation.required_passed`. The CLI and adapter source helpers enforce required gates while retaining faithful output. `validation.behavioral_test_outcome` does not pretend to execute submitted programs.

## Configuration

JSON uses defaults and rejects unknown fields. [config-v3.json](examples/config-v3.json) and [project-v3.json](examples/project-v3.json) provide examples.

| Setting | Contract |
| --- | --- |
| `profile`, `bytecode_encoding` | `auto`/`luau-vN`; independently `auto` (default), `upstream`, `roblox_opcode227`, or `roblox_signed_74171870`. [Representation recognition and authenticity limits](docs/bytecode-representations.md). |
| `control_flow` | `auto`, `structured`, `dispatcher`; fallback is explicitly reported. |
| `vector_constructor` | Optional trusted immutable identifier path; Roblox spelling is an explicit contract. |
| `naming`, `naming_options`, `name_overrides`, `indent` | `snake_case`/`camelCase`/`PascalCase`; debug/descriptive switches, identity overrides, at most 16 spaces/tabs. |
| `formatting` | Width, multiline calls/tables, blank lines, local functions; scalar/multiple-result contexts remain intact. |
| `typing` | `annotated`/`off`, `extensive`/`useful`, strict directive, aliases, finite iterations/nodes, API signatures and contracts. |
| `validation` | `check` (default), `strict_required`, `off`; server-owned tool/definition paths, bounded workers/cache/time/attempts and project. |
| `closures` | `entry_invocation: single` (default)/`repeated`, plus explicit `compiler_closure_sharing` contract. |
| `limits` | Input/strings/prototypes/instructions/constants/depth/blocks/output/shared work. |

Use `p<proto>:b<binding>` overrides from the same input's `bindings`. IDs are deterministic for that bytecode and naming-independent; different compilation settings can change them. Legacy name `pN:rM` overrides select the first binding of a register, not later reuse. Type overrides require recovered identities. Exact spelling is retained; absent/duplicate/colliding overrides fail. Globals, properties and string keys are never renamed.

`typing.binding_types` and `typing.globals` are explicit external contracts, not recovered annotations. `validation.project` contains `entry`, virtual `modules`, exact `requires`, `external_globals`, and root `instance_types`. Static resolution never executes modules. Dynamic/missing dependencies and unknown DataModel children remain diagnostics. API definitions are a pinned snapshot, not a claim to match every client build.

Type evidence distinguishes metadata/inference/external contracts. Missing information stays unknown; runtime inputs do not specialize interfaces. A conservative variadic scalar pack can describe zero-or-one results; exact AST return counts remain separately reported and runtime lists are unchanged. Strict analysis never proves behavioral equivalence.

## CLI quality behavior

Candidate `--stats` and automatic stderr notifications are bounded summaries without source, source maps, binding inventories, or complete diagnostic lists. Request `--quality-report FILE` for the detailed report and retained baseline. This prevents ordinary warnings from printing megabytes of recovered source or provenance to stderr.

```powershell
luau-decompile decompile input.bc -o output.luau --strict-required --project examples/project-v3.json --quality-report quality.json
luau-decompile batch --out-dir output --manifest inputs.json --threads 4 --window 4 --batch-report batch.json
```

`--quality-report` writes flat metadata for one input; `--stats` writes metadata to stderr. `--strict-required` conflicts with `--no-validation`. Failed required gates write faithful source/report before nonzero exit. `--project` loads explicit context. Batch reports distinguish reconstruction errors and required quality failures; outputs remain inspectable. Existing outputs require `--force`.

`benchmark --strict-required` also exits nonzero when any measured reconstruction fails the required quality gate. It writes the benchmark report first, retaining failure counts and measured results for inspection. A report file or completed timing loop does not imply a successful quality gate.

## Pools, streaming and limits

```rust
use luau_decompiler::{Config, Result};
use luau_decompiler::execution::{CancellationToken, ExecutionContext};
use luau_decompiler::runtime::DecompilePool;

fn run(bytes: &[u8]) -> Result<String> {
    let pool = DecompilePool::new(4)?; // Retain across real requests.
    let context = ExecutionContext::new(CancellationToken::new(), None);
    Ok(pool.decompile(bytes, &Config::default(), context)?.source)
}
```

Direct work is single-threaded outside an explicit pool; sufficiently large independent prototype analysis shares an existing bounded pool. Convenience APIs construct pools per call. Persistent services retain `DecompilePool`. Closure dependencies/naming remain deterministic. Outer batch errors describe configuration/pool failure; inner errors describe scripts.

Cancellation tokens, optional `Instant` deadlines and work budgets propagate through task contexts. Cancellation is cooperative. `DecompilePool::stream` accepts `Result<(id, Vec<u8>)>`, `StreamOptions` and an ordered sink, releasing bounded windows after writing. Collecting helpers/retaining sinks add memory. CLI manifests hold JSON arrays of at most 4,096 paths.

`MemoryBudget` has shared RAII leases for staged input/decode/validated-shape analysis, controlled text/JSON growth, analyzer workers, queued responses and cache capacity. It is not allocator interception or OS RSS enforcement. Writer workers retain output through send/disposal outside the CPU pool. Startup rejects infeasible service policies; control/cancellation credits survive data overload.

## Authenticated HTTP service

Numeric loopback is the default; `--allow-remote` explicitly permits other numeric bind addresses and peers. Remote deployment requires the documented HTTPS reverse proxy. The service handles one request per connection. Every route requires `Authorization: Bearer TOKEN` (32–256 printable ASCII bytes without spaces). Authentication precedes buffering. Headers are capped at 16 KiB; duplicate framing, chunked transfer and pipelining reject.

| Route | Contract |
| --- | --- |
| `GET /v1/capabilities` | Protocol 2, package version, profiles/encodings, settings support, limits/pools/diagnostics/cancellation and memory counters. |
| `POST /v1/decompile` | Raw `application/octet-stream` or canonical base64 JSON; returns `Decompiled` including quality. |
| `POST /v1/process` | The same shared content-aware source/bytecode processing contract. |
| `DELETE /v1/requests/ID` | Cooperative cancellation with `cancelled`, `active`, `remembered`. |
| `GET /healthz`, `GET /readyz` | Authenticated health and configured validation-asset readiness. |
| `POST /v1/shutdown` | Authenticated bounded graceful drain. |

```json
{
  "bytecode_base64": "...",
  "profile": "luau-v14",
  "bytecode_encoding": "roblox_opcode227",
  "reconstruction_config": {
    "naming": "camelCase",
    "indent": "    ",
    "formatting": {"line_width": 100},
    "typing": {"mode": "annotated", "verbosity": "extensive"},
    "validation": {"mode": "strict_required"}
  }
}
```

JSON requires exactly one of `bytecode_base64`, `input_base64`, or UTF-8 `source`. The optional `input_format` selects the common format override. Legacy top-level profile/encoding/control-flow/vector fields remain supported. Partial `reconstruction_config` merges into defaults and is validated. Requests cannot raise limits, change analyzer/definition paths, or downgrade server-required strict analysis or verified-typed policy. Unsupported options fail. Every effective setting, input, tool/definition identity and project-context hash enters cache keys.

`X-Request-Id` accepts 1–64 ASCII letters/digits/`-`/`_`. Active duplicates return 409; remembered cancellations return 499. History is bounded: inability to remember an unknown cancellation returns 503. `X-Timeout-Ms: 1..120000` only shortens server deadlines and is separate from reconstruction/native options.

Errors retain `{"error":{"stage":"structure","message":"...","proto":0,"pc":12}}`. Offsets count serialized bytes; PCs count original words. Missing locations are omitted; HTTP framing/admission uses `http`. Statuses include 401 auth, 422 bytecode/config, 408 deadline, 499 cancellation, 503 bounded overload. `X-Decompiler-Cache` is `hit`/`miss`/`none`; cached stats describe the original computation.

HTTP returns one complete bounded result, without batch/NDJSON. Persistent analyzer workers/results are bounded, cancelable and fully context-keyed. Diagnostic mappings state their precision; a known PC interval is never fabricated as one exact instruction.

## Executor adapter

`Adapter.install(options)` returns a controller. Native `decompile(target, options?)` follows the selected documented profile: scripts use script getters, raw bytes bypass getters, functions require separate function getters and a supporting profile. Madium's documented native contract is script-only/no second native argument; explicit canonical helpers expose additional supported capabilities. Getter errors retain their original payload.

Getter detection/routing does not certify a function packet's representation or semantics. `entry_output=function` explicitly emits a chunk returning the serialized fixed-parameter or variadic entry; script mode rejects fixed-parameter entries. Serialization does not recover external live upvalue values. Historical rc.1 packets have separate manual-transfer evidence. Rc.2 canonical function/raw helpers completed five native function programs and 21 exact comparisons against the final binary; Madium's documented native script contract remains untested. See the [candidate adapter evidence](docs/adapter-rc.md). Such packets are never silently reinterpreted as ordinary script entries.

Source methods include `decompile`, `decompile_bytecode`, `decompile_canonical`, `decompile_with_timeout`; detailed variants retain full responses. `decompile_with_timeout(target, canonical_options, seconds)` and installation deadlines are separate from native options. A numeric native second argument rejects. `decompile_canonical_detailed` retains failed quality; source methods raise a structured quality error containing source/baseline/report.

Supported native options explicitly map debug/descriptive naming, local functions, type hints, blank lines, indentation, width and implemented argument/table layouts. Unsupported native fields fail. Volt/Lynx/Madium wrappers share capability logic; [executor evidence](docs/executors-v3.md) distinguishes docs/mocks from live tests.

The adapter uses binary-safe base64, explicit normalizer/encoding selection, authenticated capabilities and bounded in-flight work. Dispatcher output can be rejected. Restoration deactivates its own layer, skips inactive predecessors and preserves unrelated replacements. Timeout/restoration can request cancellation but cannot forcibly terminate executor HTTP primitives. See [setup](adapter/README.md) and [native procedure](docs/native-place-v3.md).

## Finalization and browser interface

Every public recovered source candidate receives exactly one current engine-version attribution block in shared Rust finalization, immediately after functional directives. It is not configurable. Finalization precedes parser/compiler/strict validation, source hashing, generated-position mapping and validation-disabled returns. Existing leading official blocks are replaced idempotently; string contents and unrelated required notices are preserved. Errors without source remain errors. Original input offsets and `input_sha256` retain their raw-input meaning.

The browser uses the maintained Rust library compiled to WebAssembly and an in-memory pinned Luau analyzer module. Its exported JSON interface is versioned separately from native HTTP: outer transport success does not establish `validation.required_passed`. Cancellation may terminate and recreate the entire worker because synchronous WASM cannot receive messages. Native CLI/library/HTTP interfaces remain independent of the website. See the [browser contract](docs/browser.md).
