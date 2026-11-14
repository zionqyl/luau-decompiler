# Performance evidence

The current rc.4 versus rc.5 native receipt `docs/results/performance-rc5.json` uses the exact published rc.4 executable and the recorded rc.5 binary, with equal policies, inputs and bounded worker settings. It separates core work, uncached strict validation, result-cache hits, actual verified-typed requests, cold processes and parallel batches. Improvements and regressions are both retained. Original PID-only aggregate-memory observations were invalidated; the separate creation-time-validated cohorts are the supported process-tree memory evidence. Allocation counts were not measured.

The rc.5 browser receipt `docs/results/browser-performance-rc5.json` measures the accepted static export in Windows Chromium. Seven warm observations per tiny owned input follow the first observation; five fresh page-owned workers measure initialization separately. Historical rc.4 browser timings remain dated references, not a fresh matched baseline. WASM linear memory excludes browser RSS and JavaScript heaps.

The [candidate performance report](performance-rc.md) describes the matched rc.1/rc.2 comparison, measured phases, allocation counters and reproducible commands. A measured executable is identified by its hash; results from a pre-optimization candidate do not validate a later binary. Consult the report's completion status before quoting final-candidate numbers.

The [v0.3 report](performance-v3.md), [v0.3 service measurements](evidence.md), and [v0.2 report](performance-v2.md) are historical. Their programs, configurations, tools, cache states and binaries define their scope. Historical parent-only service memory excludes analyzer subprocesses and is not aggregate memory.

Faithful and annotated core measurements with validation disabled are not verified-typed latency. Cold startup, warmed analyzer work, analyzer-result hits, whole-service cache hits, source processing and complete adapter transport are distinct paths. Small sample sizes and shared-host interference remain visible. Earlier failed native transport probes and manual MCP comparisons do not establish current adapter latency. Current successful requests, when present, are identified separately by exact executable, adapter, program and policy.

Detailed receipts are generated under ignored `docs/results` and shipped in the versioned evidence archive, separately from source and runtime packages. These paths are not public source-tree downloads. Candidate publication status is in the [release assessment](release-candidate.md).

Performance measurements do not establish behavioral equivalence, strict success, platform compatibility or release readiness. Those remain independent [validation gates](validation.md).

## Reproducing the rc.5 inputs

Contributor benchmarks use the pinned compiler and oracle toolchain described in [development](development.md); end-user processing needs no compiler. The retained large-function and large-module workloads come from `benchmarks/generate-scale.ps1`. The three additional measured numeric programs use this exact byte recipe, verified against their recorded hashes. `i` ranges from 1 through `N`, and each update line is `value = (value * {3 + i % 17} + {17 + i * 7}) % 1000003`. Join the lines with LF while constructing the string, then encode every newline as CRLF and write UTF-8 without a BOM.

| Program | N | Prefix | Suffix |
| --- | ---: | --- | --- |
| Medium | 256 | `local seed = ... or 1\nlocal value = seed\n` | `\nreturn value\n` |
| Typed medium | 256 | `return function(seed: number): number\nlocal value=seed\n` | `\nreturn value\nend\n` |
| Typed large | 4096 | Same typed prefix | Same typed suffix |

Compile with `--binary -O2 -g2 --fflags=LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false`; add `-t1` for the two typed inputs. Preserve compiler stdout as bytes rather than using a text redirect in Windows PowerShell. The report records source/bytecode/tool hashes, settings, exact CLI benchmark argument lists and sample counts. Use the existing `luau-decompile benchmark` command with the report's configuration and pinned binary/helper pair. A historical executable must use its own matching bundled analyzer. A failed strict result remains a failed result even when annotated/check benchmarking completes.
