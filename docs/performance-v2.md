# Measured v0.2 performance

Measured on 10 November 2026: Rust 1.99.1, release ThinLTO/codegen-units=1,
Windows NT 10.0.26300, Intel Core i7-11700K @ 3.60 GHz, 16 logical CPUs.
These are owned synthetic workloads on this host. They establish neither
performance on arbitrary Roblox modules nor a comparison against other tools.
Historical v0.1 reports remain in results for provenance; their timing and lossy
behavioral oracle are not the evidence for this release.

## Corpus and measurement

The pinned official 0.746 compiler emits format 14 with recorded explicit flags,
O2 and D2. The corpus has 2,002 inputs and 1,119,163 bytecode bytes:

| Scenario | Source/work | Bytecode |
| --- | --- | ---: |
| Independent scripts | 2,000 distinct arithmetic/branch/closure/loop programs | 619,865 bytes |
| Large function | 4,096 dynamic updates, 4,099 source lines, 16,152 instructions | 117,973 bytes |
| Large module | 512 exported functions, 14,338 source lines, 513 prototypes, 39,171 instructions | 381,325 bytes |

Source/bytecode hashes are checked before measurement. Both large programs pass
eight complete typed original-versus-recompiled observations across four inputs;
the module uses an unchanged trusted probe calling every exported function.
The 2,000-input measurement establishes complete reconstruction and deterministic
hashes, not 2,000 behavioral certificates. The application and generated-program
differential suites are separate evidence in [validation](validation.md).

Every measured decompilation completed with structured quality and no declared
environment assumptions. Rejected or incomplete results make the driver fail.
[Raw measurements](evidence.md), the
[corpus manifest](evidence.md), and the
[measurement-time behavior report](evidence.md)
retain provenance. Generated source and bytecode can be reproduced from
[generate-scale.ps1](../benchmarks/generate-scale.ps1).

Each thread-count row runs in an isolated process after three corpus warmups.
Warm core latency includes full in-memory decompilation, excluding input I/O and
pool creation. Throughput includes output hashing. Calibration increases short
rows to at least one measured second; actual iterations and discarded calibration
runs are recorded. Small rows use 10/13/23/36 iterations respectively, or
20,000/26,000/46,000/72,000 measured decompilations.

The OS PeakWorkingSet64 high-water counter is sampled every 10 ms while the
process is alive. It includes loaded inputs, retained output, worker stacks,
runtime and allocator overhead. A final increase after the last successful
sample can be missed; unavailable/zero memory is a measurement failure. These
measurements are separate from the service's weighted memory admission budget,
which is not an OS RSS quota.

## Warm core

| 2,000-input corpus threads | Median | P95 | Scripts/s | Sampled peak working set |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 71.8 µs | 125.1 µs | 12,024 | 21.75 MiB |
| 2 | 79.4 µs | 139.8 µs | 20,991 | 22.47 MiB |
| 4 | 83.7 µs | 155.9 µs | 38,004 | 23.53 MiB |
| 8 | 99.0 µs | 197.9 µs | 64,537 | 25.35 MiB |

Independent-script throughput increases 5.37× from one to eight threads. Median
latency rises under concurrency. This comparison is within the current build;
it is not a speedup claim over v0.1.

| Large function threads | Median | P95 | Scripts/s | Sampled peak working set |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 48.28 ms | 52.09 ms | 20.3 | 28.50 MiB |
| 2 | 47.27 ms | 51.40 ms | 20.5 | 29.14 MiB |
| 4 | 47.45 ms | 53.23 ms | 20.5 | 29.33 MiB |
| 8 | 47.88 ms | 51.59 ms | 20.5 | 30.23 MiB |

| Large module threads | Median | P95 | Scripts/s | Sampled peak working set |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 107.96 ms | 114.57 ms | 9.1 | 36.93 MiB |
| 2 | 107.24 ms | 112.83 ms | 9.2 | 37.77 MiB |
| 4 | 103.31 ms | 109.98 ms | 9.5 | 37.60 MiB |
| 8 | 102.16 ms | 106.43 ms | 9.6 | 38.40 MiB |

Large-function rows use 50 iterations; large-module rows use 20. One large
function has no independent function analyses to distribute. The module gains
only modestly from parallel analysis because reconstruction and formatting
remain substantial serial work. Increasing thread count is not a general
latency improvement.

## Bounded streaming batch

Two isolated runs per thread count read and write all 2,000 small scripts. All
16,000 output files match warm-core hashes. Each run writes 1,063,956 source
bytes from 619,865 input bytes in input order. The requested window is eight;
input/source admission budgets are 128/512 MiB. Actual peak buffered-input and
retained-source capacities are recorded in each stream summary.

| Threads | Complete-process wall time, two runs | Inputs/s, two runs | Sampled peak working set |
| ---: | ---: | ---: | ---: |
| 1 | 1.135 / 1.076 s | 1,763 / 1,859 | 10.80 / 10.85 MiB |
| 2 | 0.997 / 0.979 s | 2,007 / 2,042 | 11.45 / 11.54 MiB |
| 4 | 0.978 / 1.008 s | 2,045 / 1,985 | 12.11 / 12.03 MiB |
| 8 | 0.981 / 1.022 s | 2,040 / 1,956 | 13.26 / 13.35 MiB |

Wall time includes CLI startup, manifest/input reads, pool creation, reconstruction
and logical file writes. Post-process hash verification is excluded. The OS file
cache was primed by corpus validation and is uncontrolled; durable disk flush is
not measured. Startup and file I/O limit this workload's scaling. Two repeats do
not establish a stable storage-performance distribution. Streaming is available
through the CLI/library; the service has no HTTP batch endpoint.

## Complete adapter path

[Madium live evidence](evidence.md) records a real Madium 2.0.0 /
Roblox 0.746.0.7461267 run against the four-thread v0.2 service with caching
disabled. The native getter's 47-byte independent empty-table compiler model
passes 65 typed observations. Four separately supplied known-source fixtures
pass another 20 observations, including real Roblox method calls.

The cold native adapter request measured **33.82 ms**, including handshake. The
64 warm native requests measured **16.53 ms median, 17.82 ms P95, 20.22 ms max**.
Timing includes the getter, base64, authenticated localhost HTTP, reconstruction,
JSON and yielding adapter completion; recompilation and behavioral probes are
excluded. Executor scheduling contributes to latency. These small-payload
client-path timings are distinct from warm core measurements and do not predict
latency for large native modules. Original function restoration and registry
cleanup passed. The native source provenance and operator-linked binary-hash
limits are explicit in [compatibility](compatibility.md).

## Allocation profile and remaining work

The System-allocator example measures allocations/reallocations, requested
bytes, and maximum additional live heap after inputs/config are loaded. Its
instrumentation changes timing, so those timings are excluded above. Heap totals
exclude stacks, allocator metadata and external allocations. The retained sample
contains both large cases and 14 evenly spaced small inputs:
[allocation report](evidence.md).

| Input | Allocations | Reallocations | Requested bytes | Peak additional live heap |
| --- | ---: | ---: | ---: | ---: |
| Large function | 398,942 | 24,088 | 36,020,823 | 16.14 MiB |
| Large module | 1,179,832 | 75,296 | 102,702,524 | 22.83 MiB |

Packed SSA access ranges, fixed register bitsets, reused function analysis,
definition-local naming evidence, bounded optimizer work and temporary lifetime
scopes constrain known expensive paths. The measured allocation counts still
show considerable optimization opportunity in large-module reconstruction.
There is no controlled v0.1/v0.2 allocation comparison or CPU flamegraph in this
report; these data do not justify an across-the-board performance claim.

## Reproduction

```powershell
. ./scripts/env.ps1
./scripts/setup-profiles.ps1 -BuildOracle
./benchmarks/generate-scale.ps1
cargo test --release --offline --test scale_behavior -- --ignored --nocapture
./scripts/benchmark-scale.ps1
```

The scale driver verifies the exact corpus and behavioral report, measures each
scenario/thread count separately, and checks all streaming hashes. Use
scripts/benchmark.ps1 -Manifest FILE.json for other bounded corpora; allocation
sampling is explicit and capped to avoid Windows command-line limits. Live
reproduction uses scripts/prepare-live-test.ps1 and scripts/verify-live-test.ps1
with the explicitly selected test client. Record the actual machine, binary,
compiler, config and corpus hashes for every new measurement.
