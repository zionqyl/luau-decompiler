# Candidate validation and release evidence

This document describes the `0.4.0-rc.4` workflow. The final optimized gate, packaged executable checks, and matching source/tool/report identities determine release readiness. Individual development runs and the existence of a report file do not establish a passing final candidate. See the [candidate assessment](release-candidate.md) for the current status and [remaining limits](remaining-limitations-rc.md) for the supported boundary.

## Independent results

Reconstruction completeness, syntax, compilation, strict analysis, meaningful typing, explicit/inferred `any`, assertions, unresolved dependencies, external assumptions, and behavioral observations remain separate results. A strict directive is not an analyzer result; compilation or strict success is not behavioral equivalence.

The [output policies](output-policies.md) distinguish faithful reconstruction, annotated presentation, and verified typed output. Verified typed requires the exact final source to pass pinned parser/compiler/strict checks and the configured meaningful-typing thresholds. Disabled or unavailable validation, an unannotated rollback, discarded contracts, broad dynamic types, and exhausted budgets cannot silently become verified success. Faithful output remains available for inspection with structured failure information.

Ordinary processing never executes submitted programs, project dependencies, or user-defined type functions. Execution belongs to bounded, controlled behavioral harnesses.

## Reproduce the Windows candidate gate

Prepare the pinned tools using the [development instructions](development.md), then run:

```powershell
./scripts/release.ps1
```

Ordinary Cargo tests do not replace ignored compiler/oracle/analyzer matrices. `validate.ps1` verifies the first-party comment rule, pinned assets, required source/case identities, ordinary and ignored tests, adapter mocks, malformed-input coverage, and source/tool freshness. `release.ps1` owns that optimized gate once, then packages and comprehensively checks the exact extracted runtime. CI calls this driver instead of repeating formatting, Clippy and package acceptance. Neither command certifies Linux, macOS, mobile, or a live executor.

Ordinary tests run once through `cargo test --all-targets`. Required ignored compiler/oracle/analyzer cases are then selected with `--ignored`, so ordinary cases are not run a second time. The single `runtime-smoke.py` owner includes the former unique missing-analyzer/strict-benchmark negative, per-request formatting, authentication, source/bytecode, batches and controlled behavioral checks. The two staging smoke wrappers were retired only after these assertions migrated.

For a semantic-only contributor run, `./scripts/validate.ps1 -Release` is the alternative entry point. After that exact snapshot passes, `./scripts/release.ps1 -PackageOnly` reuses its unchanged code/test/fixture/command/config/tool/binary identities. Markdown-only differences are recorded separately; original semantic timestamps are retained. A changed relevant input requires affected verification and a new matching gate. Do not run both full entry points for one unchanged snapshot.

Generated reports remain ignored working output. The release creates separate runtime, source and evidence archives; detailed reports appear once in the evidence asset. The [evidence guide](evidence.md) identifies durable historical artifacts.

The preserved requirements are [release-requirements-v3.json](../tests/release-requirements-v3.json); additive candidate identities are in [release-requirements-rc.json](../tests/release-requirements-rc.json). Existing families are not replaced by smaller examples. Expected rejections count as negative regression results, not successful reconstruction or verified typed output.

## Required candidate additions

These are acceptance requirements and report locations. A final run must regenerate them against its frozen source and tools.

| Area | Required observations | Report or target |
| --- | --- | --- |
| Source processing | Twelve preserved source families; 288 compiled cases and 864 typed comparisons across formats 6/14, O0/O2, D0/D2, naming profiles and varied inputs | [source-input-rc.json](evidence.md), `source_behavior_rc` |
| Input and embedding boundaries | Content detection/overrides, exact binary input, source types/names, files/stdin, bounds, cancellation, deadlines, reusable workers and 512 deterministic source mutations | `source_inputs`, `output_policy`, embedding example |
| PlayerSnapshot | Sixteen parser/compiler/strict/meaningful-typing positives, with explicit Player contracts; sixteen host structural behavioral comparisons | [types-rc-snapshot.json](evidence.md) |
| Inference and constructor semantics | Three families, 48 compiler cases and 144 typed comparisons; transitive aliases, scalarized packs, nils, effects, errors and array construction | [types-rc-behavior.json](evidence.md) |
| Token boundaries | 48 long-string index configurations and 12 grammar cases; exact original/printed VM observations, including validation disabled | `source_rc2`, `artifacts/source-rc2/report.json` |
| Useful source signatures | Six verified-typed and behaviorally compared examples: arithmetic, generic identity, callbacks, optional packs, void and concatenation | `source_rc2`, `artifacts/source-rc2-types/report.json` |
| Generated source | 56 independently composed programs and 168 exact observations across formats 6/14, binary inputs and stateful repeated calls | `source_rc2`, `artifacts/source-rc2-generated/report.json` |
| Alias dependency preservation | Six families, 96 compiler configurations, 288 complete typed comparisons, plus focused configured-global and type-only accounting regressions | `types_rc`, `types_v3`, `source_inputs` |
| Function entry contract | Fixed and variadic compiler-selected entries, two typed comparisons; native nil-placeholder capture wrapper rejection remains separate | [types-rc-function-entry.json](evidence.md), ordinary `types_rc` regression |
| Authoritative local contracts | Conflicting function contract must fail strict checking; bounded recovery must not report verified success after dropping it | [types-rc-contracts.json](evidence.md) |
| Large module quality | A 512-function module must reject unresolved arithmetic context, then pass verified typing with 512 declared numeric parameter contracts and three controlled behavioral comparisons | `scale_quality_rc`, generated `scale-quality-rc.json` |
| Adapter boundaries | Bounded acyclic options, independent timeout/restoration cancellation, policy enforcement, detailed failures and target dispatch | `adapter/test-rc.luau`, required existing adapter suites |
| Packaged interfaces | Files, source stdin, bytecode, bounded batches, CLI/HTTP verified positives, negative quality status, authentication and separate-working-directory execution | `runtime-smoke.py` at the extracted artifact boundary |

The PlayerSnapshot host probe uses controlled structural Player/Model doubles, including binary display names, absent/present characters, vectors, ordered method effects and table iteration. It is not an actual Roblox userdata test. The numeric module contracts are supplied assumptions; arithmetic is not enough evidence to exclude metamethod-based interfaces.

## Preserved semantic gates

The existing release requirements retain general runtime comparisons, explicit version-profile matrices, compiler-sensitive table allocation, application modules, generated/compositional programs, protected calls, hybrid loops/open results, repeated-entry restrictions, captures, typed formatting and strict recovery. Important required counts include 1,872 profile fixtures, 144 hash-layout comparisons, 384 application observations, 3,072 preserved generated-program observations, 720 compositional observations, 232 protected-call observations, and 432 existing typed-output comparisons.

Those are required case counts, not a claim that a later executable inherits an earlier pass. Repeated-entry results deliberately include unsupported captured-cache cases; the 32-case matrix does not claim all-success. PlayerSnapshot is now a required positive; a historical test identifier containing `strict_rejection` is retained with an explicit repaired marker rather than silently removing its identity.

LOBS/1 preserves exact string bytes, floating-point bits, tuple counts/trailing nils, ordered effects and typed error/return outcomes. Protocol and actual-VM negative cases distinguish numbers from strings, nil from strings, ambiguous tuples, binary strings, numeric bits, effects and errors. Opaque observations remain incomplete. See the [oracle contract](oracle.md) and [wire protocol](../tests/oracle/PROTOCOL.md).

## Fuzzing and resource evidence

The required decoder campaign uses sixty fixed valid seeds and five hundred coverage-guided mutations. Its actual coverage values belong to the freshness-bound harness report; old region counts are not candidate measurements. Accepted mutated input is not a behavioral certificate. The separate source cargo-fuzz target is implemented, but a coverage-guided source campaign is not claimed merely because that target exists. Deterministic source mutation tests remain distinguishable from coverage-guided fuzzing.

Service checks cover concurrent cold work, cache hits, slow cached readers, cancellation, overload recovery, analyzer and response failures, resource disposal, readiness and shutdown. Accounted admission/capacity limits are not OS RSS limits. Parent-only working-set measurements must not be presented as process-tree peaks. See [hosting](hosting.md) and [performance](performance.md).

## Native and platform boundaries

The historical rc.1 development session observed four native function dumps and twenty manual comparisons, without successful HTTP transport. Rc.2 separately completed five known-source function programs and 21 exact typed comparisons through canonical function/raw helpers, with one absent-capture rejection. Only one constant program requested verified typing. Normal-engine known-source scripts and the documented native script convention remain untested. See the durable archive and exact contracts in [current adapter evidence](adapter-rc.md#rc2-connected-client-result). Distinct programs, alternate paths, runtime inputs and timing samples remain separate counts.

The prepared [controlled place](native-place-v3.md) has fourteen known-source fixtures and host preparation checks. Normal-engine compilation through that place, native getters and typed native observations remains unrun. A catalog entry, getter capability, handshake, or documentation match does not replace this evidence.

Windows is the available host. No Linux or Mac runner is available; Linux build/container/TLS/package execution and macOS packages/tests are not run. The Linux deployment files and CI procedure are implementation, not a tested Linux artifact. Android/iOS same-device or paired encrypted executor transport remains uncertified. See the [support matrix](support-matrix-rc.md) and [adapter contract](adapter-rc.md).

## Provenance and history

The package gate binds source, fixtures, effective configuration, compilers, oracle, analyzer, definitions, generated examples and reports. Changes during a gate invalidate its snapshot. Package acceptance must run the packaged executable and helpers from a separate working directory. A development `cargo build --release` is not a validated release bundle.

The v0.3.0 Windows artifact had executable SHA-256 `e4db3e15c3a17668b9b65ca064a4d369376be2583ce3df65ea4b0bbe6329f3c0` and ZIP SHA-256 `2878c8040c14d1187f6aed0335bbbad8ee173c4317e709f84e364e017b027a0f`. Its packaged `release-gate.json` and evidence describe that version only. Some actively regenerated report filenames retain a `v3` suffix for compatibility; their filename alone does not establish historical identity. Use the preserved versioned bundle for immutable v0.3 evidence. [Historical v0.3 limitations](remaining-limitations-v3.md), [v0.3 performance](performance-v3.md), and the separately recorded [failed v0.3 live attempt](evidence.md) must not be promoted to candidate successes.

## Rc.3 ownership additions

The native gate retains all required rc.2 case identities and adds source-signature identity, loop-carried scalar inference and attribution/compiler/oracle regressions. It runs the required ignored suites after ordinary tests without rerunning ordinary cases. The exact extracted runtime harness additionally checks finalized output and raw hashes through CLI/stdin/batches/HTTP/cache and retained quality failure. Installer genuine-version transitions and interrupted activation are a distinct artifact boundary, using `release.ps1 -PackageOnly -PreviousArchive dist/luau-decompiler-0.4.0-rc.2-windows-x64.zip` after a matching native gate.

Browser acceptance belongs to `scripts/test-browser.mjs` against the real static export. Browser-only UI/build/test/workflow changes have an independent gate and do not force native semantic reruns; shared Rust/C++ or fixture changes still invalidate native identities. The browser proof precedes interface acceptance, includes a strict-negative result, and uses only static asset HTTP requests. Its report retains actual engine/analyzer/definition/configuration identities. See the [browser guide](browser.md).

Private live collection is not controlled behavior validation. The [client snapshot](client-corpus.md) retains rejected inputs, provisional representation interpretation and exact outcomes. Unlicensed third-party source and bytecode are excluded from public validation assets.

Installer PATH checks use a readable fixed-action PowerShell file and UTF-8 restoration data, with Base64 only as output framing for Unicode values. An earlier encoded-command harness attempt completed 22 scenarios before Defender blocked command discovery and cleanup at process creation; that failed report and event receipts are retained. Fixed-action installation/discovery/uninstall probes passed without changing security settings. The final package driver still requires the complete installer run, including the real previous-version archive and registry ownership assertions.

## Rc.4 boundary ownership

The native release profile additionally preserves the 28 captured-scalar/closure cases (20 required strict positives), the actual retained verified-bytecode packet, eight open-result capture-lifetime comparisons with an active-capture rejection, and twenty cross-optimization fresh-closure comparisons. These identities are additive in `tests/release-requirements-rc.json`; faithful recursive cases are not counted as strict successes. Newly minimized corpus-triggered panics and token-boundary failures have focused regressions before final acceptance. Captured game code never runs in the behavioral oracle.

The canonical example generator can reuse its own evidence only after matching the executable, generator, compiler, analyzer/manifest, definitions, source/input, configuration and finalized output identities. Reuse does not rewrite its receipt. This lets browser asset assembly and the native release owner share the same generated examples without recompiling and reanalyzing them. Changed relevant identities regenerate the examples.

Browser static-export acceptance separately covers workspace-wide retained budgets across selections, preserved exclusions during import, stale worker errors, drop scheduling, real alternating module/contract contexts and a strict negative. The prepared analyzer is reused only for compatible definition/contract identities and clears project state before every request. Browser measurements include cold definition preparation as well as warm validation.

The installer owner includes durable first-install bootstrap recovery, actual mid-download termination, extraction/version-move checkpoints, unrelated staging preservation and genuine rc.3-to-candidate management-script advancement. These remain distinct from activation interruption, ordinary engine tests, runtime package acceptance and browser tests.
