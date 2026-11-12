# Typed behavioral oracle and release gate

The official VM executes original bytecode and recompiled output in the same configured environment. The oracle emits `LOBS/1` binary observations. Every print/warn call is an ordered event containing a typed tuple; the terminal outcome contains either the exact return tuple or one typed error value. No observation comparison uses stringification, tab splitting, replacement UTF-8 decoding, or newline normalization.

Numbers carry all 64 IEEE bits, including signed zero, NaN payload/sign and infinities. Vector components carry f32 bits. Strings and buffers carry explicit byte lengths and exact bytes. Tuples have explicit value counts and retain trailing nils. Buffer IDs retain aliasing across events/results; references are held during execution to prevent allocator-address reuse. Returned objects never invoke `__tostring`. Print performs upstream's normal conversions exactly once for their actual side effects, while recording raw argument types/bytes separately. `warn` is an explicit harness hook that models a capture channel; upstream 0.654 does not provide Roblox's logger.

Runtime errors are valid terminal observations, distinct from returns, load failures, timeouts, transport failures and harness/probe failures. Error payloads are typed and exact. VM-added source prefixes are not stripped: a changed location string is a mismatch. Tests that intentionally compare user error bytes use `error(value, 0)`. Preserving source locations in every generated-error string remains separate work; the oracle does not hide it.

An opaque table/function/userdata/thread value makes observation incomplete. Identical opaque frames do not count as success. A trusted separately compiled `--probe` can consume a script's returned table/functions and check selected behavior, without wrapping/recompiling the original input. This verifies the specified probes and inputs, not every possible behavior of an arbitrary object. Global state and effects outside the capture hooks require explicit known-source probes.

The runner accepts `--args` with `LARG/1` typed argument packets. `tests/runtime-inputs.json` declares varied inputs for applicable corpus modules, including negative/fractional numbers, signed zeros, infinities, a NaN payload, a subnormal, arbitrary byte strings, vectors, buffers, nils and an intentional error. Number fields are sixteen-digit IEEE bit strings rather than ambiguous JSON decimals. [Full wire specification](../tests/oracle/PROTOCOL.md).

Eight independent protocol tests reject number/string, nil/string, ambiguous tuples, binary-string/newline collisions, distinct numeric bits, reordered effects, typed errors, incomplete observations and malformed framing. A separate actual-VM conformance test independently compiles twelve negative source pairs and verifies byte/IEEE argument roundtrips, opaque incompleteness, a non-string error and trusted probes. The compiler matrix then tests original versus reconstructed execution. Its report distinguishes reconstruction rejection, failed recompilation, failed oracle transport, incomplete observation and genuine mismatch; none is counted as complete success.

`benchmarks/validate.ps1` now executes the original compiled bytecode, separately compiles reconstructed source at the same optimization/debug settings, applies trusted probes, and compares validated typed frames across multiple seeds. Its previous source-interpreter wrapper and text traces are no longer the oracle. Both hash-reservation model audits also compare typed key/value event sequences.

## Mandatory release path

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/release.ps1
```

The release script always runs `scripts/validate.ps1 -Release`: ordinary Rust tests, actual-VM oracle conformance, typed baseline/runtime-input matrix, binding/dispatcher and capture-scope differentials, version-specific profile behavior, captured native opcode checks, application modules, generated valid programs, large-module/large-function behavior, and adapter tests. The runner binary must identify `LOBS/1` and match its source/hash manifest. Every required report must be freshly generated and complete. A zero-case, incomplete, stale or failed gate prevents packaging. The packaging path has no skip-test or incomplete-result override.

The gate records SHA-256 hashes of tested source/configuration/fixtures, oracle and report. The packaging step verifies those hashes again after the final binary build. This is integrity/freshness evidence, not a cryptographic identity signature. A development `cargo build --release` is still possible and is not a validated release artifact. Release archives include the successful gate record.

VM execution has a five-second interrupt deadline and a 64 MiB allocator limit. Observation frames, counts and decoded values are bounded. Harness deadlines, memory exhaustion, malformed frames and unsupported observations cannot become semantic successes. The oracle is intended only for trusted compiler-generated bytecode; malformed bytecode is fuzzed through the validated Rust decoder and is never executed by the trusted VM loader.
