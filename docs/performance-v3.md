# v0.3 performance evidence

The v0.3 driver compares the preserved v0.2 executable with v0.3 faithful and
annotated output on identical bytecode. It verifies every source/bytecode hash
in the preserved corpus: 2,000 independent small inputs, one function with
4,096 updates and one module with 512 functions. Threads 1/2/4/8 are separate
isolated processes; output hashes must remain deterministic across counts.
Both v0.3 core profiles explicitly disable independent strict validation. The
annotated profile still performs inference and emits annotations.

Warm-core latency includes decoding, reconstruction, inference and formatting.
Phase totals and bounded latency histograms are recorded separately; their
summed thread durations are not elapsed wall time. Windows peak working set is
sampled from the isolated child's high-water counter every 10 ms. It includes
the loaded corpus, outputs, workers and allocator overhead; a final unsampled
peak can be missed. Core calls bypass service result caches. Different source
presentation and additional provenance/type analysis mean that these profiles
are not identical work, even when they consume the same bytecode.

Analyzer measurements use separate fresh processes for uncached and cached
results. Only the first observation in a process is labelled cold-worker;
subsequent uncached observations reuse the persistent analyzer worker. Actual
`cache_hit`, compiler/analyzer durations, strict results, missing dependencies
and diagnostics remain in every observation. Strict failure does not become a
successful quality result because its duration was measured. These helpers do
not execute recovered code. Complete adapter latency is separate evidence in
the executor report.

## Final warm-core comparison

The final 36-row comparison used CLI SHA-256
`e4db3e15c3a17668b9b65ca064a4d369376be2583ce3df65ea4b0bbe6329f3c0`
on the same Windows/i7-11700K host. Each row reconstructed every submitted input
completely and retained deterministic output hashes across thread counts.
Calibration targeted at least one measured second per row. Large-case rows
contain relatively few samples; their p95 values are descriptive measurements,
not robust estimates of extreme latency.
Team builds, tests and fuzzing were paused during measurements; the shared
Windows host and a live Roblox client (PID 14180) remained active. The unchanged v0.2 large
function median moved from 90.72 ms in the preceding preserved run to 66.13 ms
in this final run. That environmental variation prevents attributing small
ordering differences to the final code changes. The client is a plausible
confound; its causal contribution was not isolated or measured.
The [shared-host control report](evidence.md)
preserves both sets of unchanged-baseline rows and the preceding summary.

| Threads | v0.2 small scripts/s | v0.3 faithful scripts/s | v0.3 annotated scripts/s |
| --- | ---: | ---: | ---: |
| 1 | 9,619 | 4,899 | 915 |
| 2 | 15,531 | 8,825 | 1,992 |
| 4 | 24,679 | 15,041 | 3,597 |
| 8 | 46,637 | 21,413 | 6,071 |

| One-thread workload | v0.2 p50 / p95 | v0.3 faithful p50 / p95 | v0.3 annotated p50 / p95 |
| --- | ---: | ---: | ---: |
| Small scripts | 0.0913 / 0.1737 ms | 0.1857 / 0.3255 ms | 1.0371 / 1.5721 ms |
| 4,096-update function | 66.13 / 78.48 ms | 81.45 / 87.21 ms | 119.91 / 127.51 ms |
| 512-function module | 151.57 / 163.89 ms | 190.18 / 199.86 ms | 359.60 / 402.60 ms |

One-thread peak working sets were respectively 28.26/31.06/43.08 MiB for the
large function and 36.13/57.86/81.25 MiB for the module. The annotated small-input
profile scaled from 915 to 6,071 scripts/s at eight threads. Both v0.3 profiles
use more memory and time than v0.2 in this final comparison. Earlier shared-host
runs changed the relative ordering of some large-function rows.
Added provenance and type work has a substantial cost, including in faithful
mode. The allocation optimization below improves v0.3 internally; these shared
host results do not establish a general v0.2 performance win.

[The final performance report](evidence.md) retains all rows,
phase totals/distribution bounds, source/output hash evidence, exact settings
and compressed raw reports. Gzip archives contain the original JSON bytes.

## Independent analyzer observations

The analyzer/allocation helpers were rebuilt from the final post-guard source
alongside the CLI. Their separate executable hashes and the associated final
CLI hash are retained in the report. These helpers ran without an aggregate
`MemoryBudget`; resource-admission tests are separate. Their timings include
library reconstruction and independent quality validation.

There are three distinct supplied-bytecode cases and ten observations per case
in each cache mode. The first small request took 994–1,572 ms including cold
worker/definition startup. Later uncached requests reused that worker.

| Case | Warm uncached p50 | Analyzer-result cache p50 | Strict outcome |
| --- | ---: | ---: | --- |
| Small script | 1.610 ms | 1.025 ms | Passed, 20/20 observations |
| 4,096-update function | 362.5 ms | 122.9 ms | Passed, 20/20 observations |
| 512-function module | 8,279 ms | 647.4 ms | Failed, 20/20 observations |

All 27 warmed cache-enabled observations reported actual cache hits. Cache-hit
time includes fresh reconstruction, inference, formatting and diagnostic
mapping; it is not a service response-cache measurement. The module produced
1,024 type diagnostics involving unresolved arithmetic interface constraints
and function assignments to a nil-inferred array. Syntax and compilation passed;
explicit/inferred `any` and assertions were zero in that report. Its strict
failure remains a documented limitation and is not included in strict success.

The helper-process peak was about 103.5–113.4 MiB. That counter excludes the external
analyzer subprocess. An earlier individual live analyzer observation was about 180 MB;
no aggregate process-tree peak was measured. The final 192 MiB resident budget
weight is a measured admission base, not an operating-system heap quota.

## Allocation profiling before optimization

The intermediate v0.3 before/after allocator counts ran on Windows 10.0.26300, Intel i7-11700K,
Rust 1.99.1, release ThinLTO/codegen-units=1. Inputs were loaded before counters
started. Requested bytes include full reallocation requests; live heap excludes
stack memory, allocator metadata and external processes. These instrumented
runs occurred while other processes could be active; their timings are not
used for latency or throughput claims.
Each mode profiles the large function followed by the module in one process;
the first annotated input includes initial API-definition parsing, and the
module reuses that initialized cache. Before/after input order is identical.

The initial annotated module produced 82,960 final source-map nodes, including
79,106 expressions. Each map node allocated an identical category string; three
candidate maps amplified that cost. The final vector alone occupied 20 MiB.
Bounded stack sampling also identified function lifting, AST traversal and
substitution, type reconstruction and initial API-definition parsing as
allocation sites. Samples use a 64-entry reservoir from every 256 allocation
events and nearest executable text symbols. They are neither a CPU flamegraph
nor byte-weighted attribution, and do not resolve inlined frames.

The measured optimization replaces those repeated category strings with an
inline `RegionKind` enum, retaining the same JSON labels. It changes provenance
storage without changing generated expressions or runtime order.

| Annotated input | Allocations before → after | Requested bytes before → after | Peak live heap before → after |
| --- | ---: | ---: | ---: |
| 4,096-update function | 818,837 → 741,224 | 87,058,115 → 83,772,435 | 26,609,305 → 24,370,153 |
| 512-function module | 1,762,442 → 1,513,566 | 244,466,216 → 232,267,308 | 73,559,348 → 65,551,224 |

The module reduction is 14.1% of allocations and 10.9% of peak live heap in
this controlled comparison. These are v0.3 before/after figures, not a claim
that v0.3 allocates less than v0.2. The faithful profile and all raw count/stack
reports are linked from [the allocation report](evidence.md).
That isolated enum comparison predates the final hash-layout repair. It remains
intermediate optimization evidence with its original profiler hashes.
The final faithful path also omits an unused rollback-map clone; final benchmark
allocation reports include that subsequent change. Typed rollback maps reserve
their measured storage before cloning under aggregate memory accounting.
Retained map strings, generated binding IDs, AST cloning and type/API parsing
remain measurable allocation costs. Broader interning or representation changes
were not justified by an independently validated implementation in this work.

Fresh final-source allocation measurements, with strict validation disabled,
are retained in the final performance report:

| Final profile/input | Allocations | Requested bytes | Peak additional live heap |
| --- | ---: | ---: | ---: |
| Faithful function | 403,784 | 46,557,970 | 16,923,408 |
| Faithful module | 1,197,431 | 143,380,445 | 45,115,197 |
| Annotated function | 741,224 | 83,772,435 | 24,370,153 |
| Annotated module | 1,513,566 | 232,267,308 | 65,551,224 |

## Reproduction

```powershell
. ./scripts/env.ps1
cargo test --release --offline --test scale_behavior -- --ignored --nocapture
./scripts/benchmark-v3.ps1
./scripts/summarize-v3-benchmark.ps1

cargo run --release --offline --example profile_allocations -- `
  --config artifacts/v3-performance/annotated-core.json --stacks `
  artifacts/v0.2-baseline/scale-corpus/large_module.bc
./scripts/symbolize-allocations.ps1 -Report counts.json `
  -Binary target/release/examples/profile_allocations.exe -Destination stacks.json
```

The benchmark driver writes its explicit configurations and complete comparison
to `artifacts/v3-performance/comparison`. Preserve the exact profiler executable
when symbolizing an earlier sample; addresses from a different build do not
identify the same functions. The v0.2 archive/binary hashes, compiler/corpus
hashes, v0.3 executable hash, settings and machine information are retained.
