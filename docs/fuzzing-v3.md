# Bounded coverage-guided malformed-input testing

The coverage driver exercises only the Rust decoder, analysis, reconstruction
and printer. It never loads a VM, runs recovered source or resolves or executes
dependencies. Typing and independent strict analysis are disabled for this
campaign; their correctness has separate gates. The instrumented harness uses a
Cargo dev build; its elapsed time is not a release-performance benchmark.

On the recorded Windows GNU host:

```powershell
./scripts/build-coverage-runtime.ps1
./scripts/fuzz-coverage.ps1 -Iterations 500 -MaxSeconds 600
```

The installed stable GNU Rust distribution lacks `profiler_builtins`. The helper
builds the profiling runtime from 33 SHA-256-pinned official LLVM 23.1.1 files.
The measured pairing is Rust 1.99.1 (`58cf8f9c3`) with its reported LLVM 23.1.1
and the matching LLVM 23.1.1 readers. The helper rejects compilers using other
LLVM majors before native compilation; no other profiling ABI is certified.
Its small, licensed Windows shim supplies GCC-aligned boundary sentinels. Only
the internal profiler-runtime marker uses `RUSTC_BOOTSTRAP`; the decompiler is
compiled with the installed stable toolchain. The helper records compiler,
linker, shim, archive, wrapper and upstream-source hashes. Offline rebuilding
checks the same locks with `-Offline`.

Sixty immutable valid seeds cover eight source families and actual serialized
versions 6 through 14, including intermediate-version arithmetic and closures.
Mutations include bit/byte changes, insertion, deletion, truncation, duplication,
zeroing and format-header changes. Each input is at most 16 KiB. A single
persistent harness gives each case an 8 MiB admission ledger, a two-second
deadline and bounded analysis work. The parent process enforces its own timeout,
iteration and corpus-parent limits.

Actual LLVM counter profiles are merged after every case. A mutant becomes a
mutation parent only if it increases the union of covered regions in owned
`src/*.rs` files. The mutation-parent corpus is bounded and immutable seeds are retained. The
driver reports seed executions, mutations, accepted complete reconstructions,
precise rejections, failures and newly covered regions separately. Acceptance
does not establish behavioral equivalence. Coverage denominators describe the
linked instrumented core, including unreachable/unused regions the linker
retained, rather than all possible programs or platform behavior.

The GNU linker must retain `.lcovfun` records. The build disables linker section
GC for the instrumented harness. The official linked-COFF reader expects exactly
one leading byte before profile names, while the GNU runtime needs an aligned
sentinel. A never-executed analysis copy normalizes only that names-section
representation. Every other PE section's content is checked byte-for-byte by
SHA-256. Executed instructions, counters and coverage mappings are unchanged.
This follows the [official coverage reader's COFF handling](https://github.com/llvm/llvm-project/blob/llvmorg-23.1.1/llvm/lib/ProfileData/Coverage/CoverageMappingReader.cpp)
and the [LLVM coverage mapping format](https://llvm.org/docs/CoverageMappingFormat.html).

The machine-readable outcome is
[`coverage-guided-v3.json`](evidence.md). A successful campaign
requires all requested mutations, nonzero real owned-source coverage, at least
one coverage-increasing mutant, no panic/timeout/process failure, and unchanged
source hashes. A target or script existing without such a report is not a
completed campaign. Failures remain as candidate files for minimization and
regression capture. No failing input is silently discarded to obtain a pass.

The separate standard `fuzz/` libFuzzer target remains available for hosts with
the required nightly/tooling support. Neither sanitizer certification nor
cross-platform fuzz execution is implied by this Windows counter campaign.
