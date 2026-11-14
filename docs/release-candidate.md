# 0.4.0-rc.5 assessment

Rc.5 improves reconstructed bindings, captures, expressions, useful type precision, type layout and source organization. It remains a release candidate: the captured Button and InventoryService modules still fail strict and meaningful-typing gates. Finite controlled tests are not universal Roblox coverage.

The frozen Windows engine is SHA-256 `36c81f2589bda731036dd505886d6676e67bca2f759bf0789d5b08e4feb8cfb4`; its analyzer is `65ccbcb05acc33c60b20db5e55d4d0102093e9f076f1af1aef7b96fba68318ff`, with unchanged pinned Roblox definitions `d6d1e40a...`. The required release profile and final packaged acceptance are pending completion. All three selected outputs were freshly regenerated with this executable; earlier comparison receipts remain pre-final. No rc.5 publication or new Linux/container/executor test is claimed here yet. The currently published rc.4 runtime and browser receipts remain historical, identified by their own hashes.

## What changed

Reference captures now join the actual captured lifetime rather than every definition of one VM register. Closing cells, later reuse, independent factory state and function identities remain protected. Effect-aware bounded forwarding removes safe aliases; captured/global/method callee lookups block unsafe motion. Direct closures require a fresh-table or compiler-backed mutable-reference proof. Compiler-sensitive table reservations remain.

Evaluated class literals retain concrete services and constructors through aliases. The shared native/browser analyzer refines only classes listed by the pinned definitions and keeps ordinary argument checking. Captured table declarations retain prior table identities. Unknown event-argument boundaries replace unjustified unused generics, and strict/typing failures remain visible.

Names follow debug/dataflow/assignment/API evidence after binding recovery. The Roblox preset uses PascalCase for proven services/module aliases and camelCase for ordinary locals/functions. Other presets remain supported; external keys and globals are preserved. Sibling scopes reuse names through a stable-symbol presentation map. Expanded prototype occurrences retain distinct source-map symbols and exact printed-name reports. See [API contracts](../API.md#configuration).

A bounded recursive type printer wraps local/function/nested types and reuses available equivalent aliases. Foundational aliases precede runtime values; dependent aliases follow their imports. Runtime initialization order stays intact. The [generated whole-module example](../examples/typed-output/module_organization.luau) preserves imported types, value-dependent `typeof`, helper dependencies and observable initialization order with explicit controlled modules. It passes strict analysis but fails the unchanged meaningful-typing thresholds (50% binding coverage, 90% useful annotations), and is therefore not verified typed.

## Actual captured outputs

The exact published rc.4 executable `1bcace5d...` regenerated all three historical outputs byte-for-byte before comparison. Only three retained buffers were reprocessed for rc.5; captured code was never executed. The local/evidence readability receipt `docs/results/readability-rc5.json` binds original bytes, configurations, source and tool hashes.

| Module | Category | Source bytes rc.4 / rc.5 | Longest line rc.4 / rc.5 | Final strict / meaningful |
| --- | --- | ---: | ---: | --- |
| [Button](../examples/Murder%20Mystery%202/ReplicatedStorage/ClientServices/Button.luau) | Gameplay/UI | 8,577 / 4,067 | 178 / 97 | Failed / failed |
| [InventoryService](../examples/Murder%20Mystery%202/ReplicatedStorage/ClientServices/InventoryService.luau) | Gameplay | 16,212 / 9,750 | 126 / 105 | Failed / failed |
| [Item](../examples/Murder%20Mystery%202/ReplicatedStorage/Database/Sync/Item.luau) | Data only | 1,375,836 / 1,095,062 | 240,558 / 122 | Passed / passed |

Item's longest local-declaration line is now 28 characters; preserved strings and chains can exceed preferred width. Button recovers `frame`, `onClickEnd`, `onClickStart`, `isPressed`, `isEnabled`, both initial-position snapshots and `ButtonModule`, without readiness scaffolding. Callback snapshots, nil/false defaults, the wait and late public callback reads remain. Hash reservations stay explicit.

Button binding coverage is 29% versus 35% previously; inferred `any` drops from 16 to 8 while inferred unknown rises from 69 to 83. InventoryService coverage is 34% versus 39%, with `any` 138 to 52 and unknown 164 to 182. These are not hidden regressions or verified results. Fewer disposable locals and removal of synthetic generics change the denominators and reveal unresolved interfaces. Missing GUI/project/callback contracts and conservative analysis still limit useful final interfaces; supplied contracts do not guarantee success.

The corpus retains 297 documents: three current outputs and 294 explicitly historical outputs. The Pages showcase serves only the current three while integrity-checking historical documents and retaining their receipts in the repository. Composite inventory coverage is not a full rc.5 pass. The [manifest](../examples/Murder%20Mystery%202/manifest.json) includes failures and exact current-subset denominators. Historical rc.4 counts and source remain available at [the prior manifest](https://github.com/zionqyl/luau-decompiler/blob/d4d21d856c0904251864910e0af4e289198d6800/examples/Murder%20Mystery%202/manifest.json).

## Performance and reliability

Matched native measurements in `docs/results/performance-rc5.json` separate core, uncached strict work, result-cache hits and actual verified-typed policies. Performance is mixed, including large-function and throughput regressions. Tiny warm requests do not predict game-module latency. An invalid PID-only aggregate-memory observer was detected; its raw data remains preserved and only creation-time-validated memory cohorts support current aggregate figures. Allocation counts were not measured.

The required pre-final gate exposed a 256-callback regression: distinct captured cells were all declared at function entry. Proven sequential lifetimes now use existing declaration/scope placement; loop-carried and dispatcher cells remain conservatively at entry. The original required case passes its eight typed comparisons without raising the 200-local compiler limit. Independent review also found stale table history after loop widening and later rebinding; a focused failing regression now keeps that declaration conservative.

The prior optional-forwarding budget regression now admits the same retained 117,973-byte large function under default limits. Per-scope collision counters prevent quadratic repeated-hint scans. Persistent browser analyzer contexts, cancellation and existing worker/accounting behavior remain in place.

Installer ownership now records each atomic write durably before creating its temporary file. Recovery handles partial lock intents, bootstrap/stage-owner/activation writes, and preserves modified or unowned files. Nine focused installer scenarios passed using the current installer and an existing rc.4 test bundle; final rc.5 packaged acceptance has its separate owner. Runtime quality-tool provenance now projects explicit non-null dictionary keys and must match packaged assets and the gate.

## Readiness boundary

The local static export passed 30 Chromium 143 acceptance groups with real browser-local Rust/C++ WASM processing, strict-negative rejection, source/bytecode parity, controlled behavioral pairs, cancellation, retention, exact exports and all-origin request observation. SharedArrayBuffer was unavailable. Firefox, Safari, mobile devices and a fresh clean Windows OS are not tested. Actual deployed rc.5 Pages and release-package results are pending their publication boundary.

Do not promote this candidate to universal or issue-free stable support. Preserve the [unsupported scope](remaining-limitations-rc.md), requested quality policy, missing-context diagnostics and independent behavioral evidence. The historical [rc.4 assessment](https://github.com/zionqyl/luau-decompiler/blob/d4d21d856c0904251864910e0af4e289198d6800/docs/release-candidate.md) remains separate.
