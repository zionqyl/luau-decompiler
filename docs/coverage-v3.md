# v0.3 coverage-guided malformed-input evidence

The completed Windows GNU preflight used 60 distinct valid bytecode seeds across
versions 6–14 and 500 bounded mutations, with fixed random seed `3021603`.
All 560 cases completed: 60 seeds and 45 mutants reconstructed completely;
455 mutants received explicit rejections. There were no panics, timeouts or
process failures. Accepted mutants are not behavioral equivalence certificates.

Real LLVM counter profiles increased covered owned-source regions from 8,870
after the seeds to 9,225 of 19,545 regions in the linked instrumented Rust core.
Ninety-five mutants increased that union and were retained. This is a small
parser/reconstruction campaign: the largest actual input was 618 bytes. It
does not establish large-input, OOM, sanitizer or platform certification.
Typing and independent strict analysis were disabled and have separate gates.

```powershell
./scripts/build-coverage-runtime.ps1 -Offline
./scripts/fuzz-coverage.ps1 -Iterations 500 -MaxSeconds 240
```

On a fresh host, first install the matching official `llvm-tools-preview`
component and run the runtime helper without `-Offline` to fetch the locked
LLVM sources. This campaign used Rust 1.99.1 with LLVM 23.1.1 on Windows GNU;
the helper rejects other LLVM majors and does not certify their profiling ABI.
The release gate rebuilds/verifies the instrumented harness and
repeats this same fixed-seed campaign. It does not count the two runs as 1,000
distinct mutations. The latest fresh outcome, per-case source/input/tool hashes,
counter totals and runtime provenance are in
[`coverage-guided-v3.json`](evidence.md).

The driver never executes Luau. Source hashes remain unchanged throughout the
campaign. It retains code/counter/mapping contents when adapting the GNU names
sentinel for the official COFF reader, and checks every other section's content
hash. The [detailed procedure and limits](fuzzing-v3.md) explain the native runtime
shim, admission/work/deadline bounds, mutation-parent cap and failure retention.
