# Release-candidate performance

The final rc.4 comparison uses CLI SHA-256 `5b1316e78fa183aafe32c46471ce31cb3601778a5650b26898e7a27743a7953d` and reruns the preserved rc.3 CLI `a5b735d38c2f61bc6d6a5d09cfc83a486cb3b7dc26e59dcf1ded215f189a150b` on the same Windows host. Authoritative aggregates are `reports/docs/results/performance-rc4-final.json` and `browser-performance-rc4.json` in the [public controlled-program supplement](https://github.com/zionqyl/luau-decompiler/tree/40504619ad34085c9ff6dad127925e3ee3d7f692). Its archive download was verified against SHA-256 `42414238ad0b9b463cd13a8bcf33c3830cb9df0b40b162e322650454d9216d26`. All 35 native raw reports are included. The four browser raw reports remain local because some contain extraneous capture-availability metadata; the unchanged browser aggregate retains their hashes without claiming a complete public raw-data closure. Earlier rc.4 investigation reports retain their identities and do not establish final-candidate performance.

## Matched native results

`scripts/benchmark-rc.ps1` owns warm-core, cold CLI, allocation and strict-helper measurements. The corpus contains 2,000 independent small packets, one 4,096-update function and one 512-function module. One/four-thread cohorts use at least three iterations and one second of calibrated core work. Core timing explicitly disables external validation; it is not verified-typed latency. Reports separate decode, reconstruction, inference, formatting and validation counters, retain actual sample counts and distributions, and check deterministic output.

| Workload | Faithful throughput change, 1 / 4 threads | Annotated throughput change, 1 / 4 threads |
| --- | --- | --- |
| 2,000 small inputs | +7.3% / +11.4% | -2.0% / +3.6% |
| Large function | -1.2% / +4.2% | -1.3% / +0.7% |
| Large module | -0.9% / +0.8% | -1.3% / -0.5% |

Candidate small-input faithful throughput was 5,637/16,238 scripts per second; annotated throughput was 1,036/4,414. Single-thread candidate p50/p95 latency was 0.157/0.260 ms faithful and 0.925/1.400 ms annotated. These small owned fixtures do not represent arbitrary Roblox modules.

Three balanced one-thread large-module faithful ABBA rounds had a median candidate/baseline ratio of 0.9900, ranging from 0.9739 to 1.0342. The earlier rc.3-versus-rc.2 large-module regression is not demonstrated as resolved. Shared-host contention, few large-input samples and changing order limit causal conclusions. No CPU cause or universal speedup is claimed.

Fresh CLI process medians, with validation disabled, include launch, file input, source output and the measurement harness's 10 ms polling overhead:

| Input | Faithful rc.3 / rc.4, ms | Annotated rc.3 / rc.4, ms |
| --- | --- | --- |
| Small packet | 35.0 / 32.9 | 57.8 / 63.8 |
| Large function | 111.5 / 104.2 | 174.2 / 168.6 |
| Large module | 204.1 / 213.9 | 345.0 / 343.0 |

Each cell has three fresh-process samples. Filesystem caches were not flushed. In particular, the faithful large-module cold median regressed despite mixed warm results.

Uncached strict-check helper wall medians were 1.39 to 2.54 ms for a small packet and 318.8 to 328.6 ms for the large function. These measurements include processing and strict checking, not the verified-typed policy's full quality requirement. With analyzer-result caching enabled, candidate medians were 0.91 and 105.9 ms respectively; cache state is explicit in the report. The unconstrained 512-function module failed all five strict observations with 1,024 diagnostics, taking about 8.28 seconds warm without result caching. A cached failure remains a failure. The separate required 512-contract positive and controlled behavior gate must still pass.

Three actual cold verified-typed requests for the already annotated [PlayerSnapshot source fixture](../tests/source-corpus/player_snapshot.luau) took 792.4, 899.2 and 888.8 ms. They include process and pinned-analyzer startup, source parsing, formatting, strict analysis, meaningful typing and file output. This is source processing, not bytecode reconstruction or execution of the Roblox interface.

## Memory and allocations

The instrumented candidate large module used 1,200,106 faithful allocations and 45,041,469 peak additional live heap bytes; annotated processing used 1,510,608 allocations and 53,456,964 bytes. Each mode has five more allocations than its matched rc.3 helper, with unchanged measured peak live heap. The observer excludes input loading, stacks, allocator metadata and analyzer processes. Native parent working sets likewise exclude analyzer subprocesses; these figures are not process-tree peaks.

The final comparison did not collect new CPU or allocation-stack samples. Earlier bounded allocation-event samples identify cloning/allocation sites, not CPU percentages. Allocation counts do not establish the cause of timing differences.

## Browser-local latency

One non-pthread worker owns the Rust engine and persistent C++ analyzer. Compatible requests reuse prepared pinned definitions while clearing per-document/module state; changed contracts, faults and worker replacement rebuild the context. Result caching was disabled for these measurements. No additional full analyzer per reported CPU core was introduced.

Matched Chromium 143.0.7499.4 Windows measurements used three owned inputs, extensive annotations, the verified-typed policy and seven warm observations after the first request. Positives had to pass the actual final-source compiler, strict analyzer and meaningful-typing gate; the strict negative had to fail.

| Input | Rc.3 warm worker median, ms | Rc.4 warm worker median, ms |
| --- | ---: | ---: |
| Supported bytecode | 1,004.5 | 1.9 |
| Positive source | 1,012.7 | 0.8 |
| Strict negative | 2,035.6 | 1.2 |

For the bytecode case, candidate phase medians were about 199 microseconds reconstruction, 600 inference, 99 formatting and 900 validation. Its validation frame recorded 100 microseconds compilation, 400 analysis and zero repeated definition initialization. Submillisecond browser clock precision limits these counters. These are small warm fixtures, not a general latency guarantee.

Cold initialization remains included: five fresh page-owned workers in one browser process had verified end-to-end medians of 1,524.6 ms rc.3 and 1,514.8 ms rc.4 (-0.6%). Candidate nearest-rank p95 was 1,628.5 ms. Candidate initialization median was 1,414.9 ms; the first verified request after initialization had an 85.3 ms median. Definition preparation dominated the recorded initialization breakdowns. Later trials can reuse browser code caches; this is neither cold internet access nor five clean operating-system processes. The final harness does not reuse the earlier superseded cold figures.

Observed Rust/C++ linear memories were 5,898,240/48,365,568 bytes for both versions. They exclude JavaScript, transient asset buffers, browser RSS and process-tree memory. The measured candidate asset ID is `51c298465264bf3c3bc570cc`; engine source identity is `8fd45a8587c5f29547f891c1f1993dd4e7518fe27f51efd074afdc46d0baddb4`. Engine/analyzer WASM sizes were 2,588,984/4,020,225 bytes. Actual UI/drop acceptance and all-origin network observations have their own [browser boundary](browser.md).

## Remaining limits

Native analyzer pools still partition conservatively by full project context. Alternating native projects can require additional initialization. Large-function inference, module source maps, cloning/allocation work and cold browser definition preparation remain material costs. Reusing a prepared environment does not authorize reusing strict success across changed inputs or contracts.

Performance measurements execute no recovered or captured programs. Semantic equivalence, instruction coverage, resource admission, live transport and final package acceptance remain independent evidence. No reconstruction or typing requirement was disabled to produce verified-typed timings.
