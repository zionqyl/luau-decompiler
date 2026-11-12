# v0.3 remaining limits and evidence boundaries

The packaged `release-gate.json` identifies the exact source, tools, fixtures,
reports and Windows executable tested. Its successful tests certify their stated
cases and observation protocols. They do not certify all programs in an accepted
format. Reconstruction, compilation, strict checking, useful type coverage and
controlled behavioral comparisons remain separate results.

| Area | Current boundary |
| --- | --- |
| Native extraction | The prepared controlled place has 14 distinct known-source programs and host-compiler checks. Normal-engine compilation and native client observations have not run. Historical Madium evidence uses the v0.2 executable and one unknown-source native model plus four supplied fixtures. |
| Executor targets | Script/raw-string/function routing and supported option mappings have injected-API tests. Native function dumps are not independently verified. Serialized entries with fixed parameters reject; entry upvalue values are not present in serialized bytecode and are not fabricated. |
| Platforms | Windows is tested. No Mac runner was available; macOS packages/tests are not run. Android/iOS same-device or authenticated encrypted companion transport is not implemented or certified. |
| Instructions | Native userdata atom callbacks, prototype-identity guards, integer constants and experimental class operations still reject. An accepted format version is not instruction-feature coverage. A representative native corpus was unavailable for a frequency ranking. |
| Repeated entry calls | The default scope covers one root invocation and repeated calls of recovered returned closures. The repeated-entry mode verifies a limited subset under explicit compiler-sharing contracts; eight captured-cache cases reject. See the separate 32-case report, which deliberately does not claim all-success. |
| Control flow and tables | Hybrid dispatcher/native-loop and cross-block open-result construction require implemented proofs. Unproved entry/exit, alias, insertion-history or result-pack arrangements retain explicit diagnostics. |
| Types and strict analysis | Erased original aliases, generics, project interfaces and concrete classes cannot be exactly recovered. Unknowns, contracts, nilability, `any`, assertions and dependencies are reported. The full Snapshot table-history example and the measured 512-function module fail strict checking while retaining faithful, compilable source. |
| Automatic recovery | Recovery selects among implemented optional annotation/presentation strategies with finite shared budgets. It does not synthesize runtime guards, defaults, conversions, altered errors or return values. Unsupported baseline reconstruction remains an error. |
| Observable runtime details | Source spelling, original line/stack/debug layout, allocation/GC timing, OOM behavior, compiler closure sharing and all VM-generated error prefixes are not universally preserved. Explicit scope/contracts matter. |
| Resources | Aggregate limits bound admission estimates and owned buffer capacities. Analyzer residency is a measured admission weight. This is not an operating-system RSS quota; external child memory and process peaks are reported separately where measured. |
| Performance | Additional provenance, typing and quality checks have measurable costs. Compare the actual v0.2/v0.3 reports; allocation improvements are not a claim of universal latency improvement. |

Strict checking does not establish behavioral equivalence. Accepted malformed-input
mutants are not behavioral certificates. Repeated timing samples are not distinct
native programs. Missing access, dynamic dependencies and external assumptions
remain visible in the reports rather than becoming successful coverage.

See [validation](validation.md), [instruction semantics](semantics-v3.md),
[typing](types-v3.md), [executor compatibility](executors-v3.md),
[controlled-place procedure](native-place-v3.md), and [performance](performance-v3.md).
