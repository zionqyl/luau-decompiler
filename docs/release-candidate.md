# 0.4.0-rc.5 assessment

[Rc.5 is published](https://github.com/zionqyl/luau-decompiler/releases/tag/v0.4.0-rc.5), including matching Windows/Linux runtimes, validation assets, checksums, source, evidence and a container image. The [browser application](https://zionqyl.github.io/luau-decompiler/) performs reconstruction and strict analysis locally. This remains a release candidate: Button and InventoryService still fail strict and meaningful-typing gates, large-input performance regresses, and one real online installation needed recovery after a bounded bootstrap deadline.

## Release identities and acceptance

| Boundary | Exact identity and result |
| --- | --- |
| Published source/tag | `v0.4.0-rc.5` at `090c1e64635c6af7344973a283b164e9e5f944d8` |
| Published Windows executable | SHA-256 `9cd4c98f8ec0b19ef1084fbd6d3593b44c99725eacd3c1930a813b8b5d796d31`; analyzer `ff04e80cb3e1024b138bf92a06f0214cb4438adf1a1abc13f26b0975fe6e5451` |
| Windows runtime ZIP | 5,577,821 bytes; SHA-256 `41b45bbdd4e13fc6e2f46e0a682a772efe218d592bc227e26c412c1da3bc2371` |
| Linux runtime | 4,490,645 bytes; SHA-256 `c84308311ac75c035d2c47c07f22ffa83da6f863c85ae7c918be0ed4cd2648d7` |
| Container | `ghcr.io/zionqyl/luau-decompiler@sha256:7530fcf27b63e019d9cdd34a41137513b66a096f8a44556157df09de01424c70`; anonymous digest pull passed |
| Portable engine text | `29427015a45d9f790d99bd352233ff71561bd48537be3d9cbfd707c589991ec6` |
| Pages | Source `6c45359b98dc878c2688f468064d6988687117f9`, served asset ID `2f2c5389b95ff190bcc78552`; subsequent source changes affect native installation only |

The corrected canonical [Windows job](https://github.com/zionqyl/luau-decompiler/actions/runs/43545344892/job/132295248819) passed the required release profile, ten extracted-runtime checks and 33 installer scenarios. The [Ubuntu 24.04 job](https://github.com/zionqyl/luau-decompiler/actions/runs/43545344892/job/132295248434) passed Rust 1.85, build/format/lint/ordinary tests, ten runtime checks, container readiness, a genuine verified-typed request, same-container restart and clean shutdown. The [publisher](https://github.com/zionqyl/luau-decompiler/actions/runs/43548156610) reused those exact successful artifacts, rather than running another semantic gate. Public [runtime](https://github.com/zionqyl/luau-decompiler/releases/download/v0.4.0-rc.5/runtime-publication.json) and [image](https://github.com/zionqyl/luau-decompiler/releases/download/v0.4.0-rc.5/publication.json) receipts bind the source, evidence run and assets.

The frozen local engine `36c81f2589bda731036dd505886d6676e67bca2f759bf0789d5b08e4feb8cfb4` passed its complete required profile once: 50 required reports, from 00:51:12 to 01:05:11 UTC on 2026-11-14. Installer-only changes reused that unchanged semantic result. Final local packaging passed ten runtime and 34 installer scenarios, adding an actual published rc.4 updater transition to the standard 33 cases. A separately built current embedding example passed verified-typed processing. Local and CI binary hashes differ; their evidence is not interchangeable.

After publication, the actual downloaded Windows executable independently passed all ten canonical runtime checks from a separate working directory, including verified source/bytecode, strict-negative rejection, CLI/stdin/batch, authenticated HTTP with 24 concurrent requests and exact attribution. It reproduced all three selected captured outputs byte-for-byte; Item was explicitly requested with `--policy verified-typed` in addition to its recorded generation configuration. Captured game code was not executed. The [sanitized public-artifact receipt](public-acceptance-rc5.md) preserves exact identities, results and recorded installation failures.

The [audited comparison archive](https://github.com/zionqyl/luau-decompiler/tree/7bbc410e035c39223a851ab8ba611744c5c9adf5) preserves current local measurement/readability reports, portable configurations and compact engine/browser/gate identities. Its 42,969-byte ZIP is SHA-256 `122a7bd9098dc76d1ba60831115c6017d8c4133adcc2bb51ddc5a99482eb31ad`; anonymous download and checksum passed. It excludes captured bytecode, source copies, logs, credentials and earlier unpublished supplements. Public release evidence and this local comparison archive serve separate purposes.

## Reconstruction, naming and useful types

Reference captures join actual captured lifetimes rather than every definition of a register. Closed cells and later register reuse separate where proven; shared mutable captures, recursion and independent factory state remain protected. Bounded effect-aware forwarding removes safe aliases without moving property or function snapshots across observable operations. Initialized closure scaffolding is removed only with a fresh-table or compiler-backed mutable-reference proof. Compiler-sensitive hash reservations remain.

Evaluated literal facts retain concrete services and constructors through aliases. Native and browser analyzers refine only classes listed by the pinned definitions while preserving ordinary argument checking. Captured table declarations retain earlier table identities and loop-widened history instead of overwriting the lifetime with the last table. Unknown event arguments replace unjustified unused generics. The gate also caught and fixed 256 sequential captured cells exceeding Luau's active-local limit; the original required eight typed comparisons now pass without increasing that limit.

Names follow debug/dataflow/assignment/API evidence after recovery. The Roblox preset uses PascalCase for proven service/module aliases and camelCase for ordinary bindings. Stable internal symbols remain separate from scoped printed names and source-map occurrences. Other case presets, source-name retention and exact overrides remain available; globals, public keys and string contents are unchanged. See [API contracts](../API.md#configuration).

Recursive width-aware printing covers local, parameter, return and nested types, and reuses equivalent in-scope aliases. Foundational types precede runtime bindings; dependent aliases follow their imports. Runtime initialization order stays intact. The actual [whole-module output](../examples/typed-output/module_organization.luau), generated with controlled project modules, demonstrates imported types, value-dependent `typeof`, helper dependencies and final module return. It passes strict analysis but fails unchanged meaningful-typing thresholds: 50% binding coverage and 90% useful annotations. It is not verified typed.

## Actual bytecode-derived outputs

The exact published rc.4 executable `1bcace5d...` first regenerated the three historical outputs byte-for-byte. Rc.5 reprocessed only these three retained buffers, not the whole capture. Original hashes and generation settings remain in the [corpus manifest](../examples/Murder%20Mystery%202/manifest.json). No captured script was executed.

| Module | Category | Source bytes rc.4 / rc.5 | Longest line rc.4 / rc.5 | Final strict / meaningful |
| --- | --- | ---: | ---: | --- |
| [Button](../examples/Murder%20Mystery%202/ReplicatedStorage/ClientServices/Button.luau) | Gameplay/UI | 8,577 / 4,067 | 178 / 97 | Failed / failed |
| [InventoryService](../examples/Murder%20Mystery%202/ReplicatedStorage/ClientServices/InventoryService.luau) | Gameplay | 16,212 / 9,750 | 126 / 105 | Failed / failed |
| [Item](../examples/Murder%20Mystery%202/ReplicatedStorage/Database/Sync/Item.luau) | Data only | 1,375,836 / 1,095,062 | 240,558 / 122 | Passed / passed |

Compare the [actual prior Button](https://github.com/zionqyl/luau-decompiler/blob/d4d21d856c0904251864910e0af4e289198d6800/examples/Murder%20Mystery%202/ReplicatedStorage/ClientServices/Button.luau) with the generated current document. It now has a concrete TweenService, `frame`, `onClickEnd`, `onClickStart`, `isPressed`, `isEnabled`, both initial-position snapshots and `ButtonModule`, without readiness scaffolding. Nil/false defaults, distinct default closures, event function snapshots, the wait, late callback lookup and hash reservations remain. Item's longest local declaration is 28 characters; unchanged strings and indivisible chains can exceed preferred width.

Button binding coverage is 29% versus 35%; inferred `any` drops from 16 to 8 while unknown rises from 69 to 83. InventoryService coverage is 34% versus 39%, `any` falls from 138 to 52 and unknown rises from 164 to 182. Removing disposable locals and synthetic generics changes the denominators and exposes unresolved interfaces. These are reported regressions, not verified results. Missing GUI/project/callback contracts and conservative analysis still limit precise final interfaces.

The public corpus contains 297 documents: three current and 294 explicitly historical. Pages loads only the current three on demand. The current subset is three of three complete/compiled, one of three strict/meaningful, with two gameplay failures; Item is data-only. Historical inventory counts are not a fresh rc.5 coverage pass. Owner permission, actual paths, failed outcomes and historical receipts remain separate in the [corpus guide](client-corpus.md).

## Matched performance

These Windows measurements use the frozen local engine, its matching analyzer and the exact published rc.4 baseline, not the later CI-built executable. Five warm calls follow two excluded warmups; three fresh processes measure cold work including initialization. The report separates reconstruction, typing, formatting and validation; no allocation count was measured.

| Actual verified-typed input | Warm median rc.4 / rc.5 | Cold process median rc.4 / rc.5 |
| --- | ---: | ---: |
| Small | 1.404 / 1.182 ms | 844.3 / 777.1 ms |
| Medium | 9.896 / 10.855 ms | 751.0 / 764.6 ms |
| Large | 316.388 / 345.895 ms | 1,171.3 / 1,175.1 ms |

Four-core reconstruction with one bounded analyzer worker measured 8.47 versus 7.71 scripts/s on the three-input verified batch. More threads did not improve that workload. Corrected process-tree memory cohorts measured rc.5 peaks of 88.4/91.6/118.3 MiB for the three verified sizes. An invalid PID-only aggregate observer was detected, its aggregate values withdrawn, and separate creation-time-validated cohorts retained. Shared-host noise and small samples limit conclusions. The unconstrained 512-function module still fails strict analysis and is never counted as verified throughput. See [measurement recipes and reports](performance.md).

Browser measurements are separate: seven warm samples after the first per tiny input measured 2.1 ms median verified-bytecode processing; five fresh page-owned workers measured 1,182.46 ms median initialization plus first verification. This is not cold internet or arbitrary game-module latency. Engine/analyzer linear memory was approximately 5.69/46.13 MiB, excluding browser RSS and JavaScript heaps. Persistent analyzer contexts and the non-pthread baseline remain intact.

## Installation and platform limitations

Current installer bytes are SHA-256 `ead5cb1d736996260c20e93c6c224374c0087d8f93a184da7d3c6da740e0597b`. The rc.4 streaming-hash repair was already present and was not claimed as a new fix. Runtime quality-tool provenance now explicitly matches the gate and shipped assets.

The first clean rc.5 Windows run exposed an installer directory move while a diagnosed child process could still retain the staging path. Diagnosis now occurs in an owned provisional version before activation. A later atomic-replacement failure led to bounded content-checked recovery only for classified contention states; ambiguous partial or modified states fail closed. Eleven focused atomic/recovery cases passed, including process interruption and ownership preservation. These fixes did not require another run of the unchanged local semantic matrix.

The actual public online install, using a Unicode/space destination and `-NoPath`, initially hit the one-second bootstrap atomic scheduling deadline. Its durable intent survived; the exact command succeeded on retry. A slow healthy filesystem can therefore still cause first-attempt rejection. This remains an open installer latency/reliability limitation, not a clean-install success. Final uninstall recovered a separate sandbox-denied metadata write using the same verified installer bytes, removed owned payloads, and preserved the ownership marker and unowned configuration.

The published Windows ZIP grew by 114,407 bytes versus rc.4 (5,463,414 to 5,577,821). Published source grew by 13,790 bytes (19,230,744 to 19,244,534); selected corpus source shrank by 291,746 bytes. Local compiler/package sizes differ and are not substituted for public measurements. Required historical evidence remains durable; no source-distribution cleanup is claimed merely from lower output line counts.

The local static export and actual Pages origin each passed 30 Chromium 143 acceptance groups, including real strict-negative rejection, native/browser source-quality parity, controlled behavioral comparisons, cancellation, retention, exact exports and all-origin request observation. SharedArrayBuffer was unavailable. Only static GET/blob requests were observed. Served processing assets were hash-checked against their manifest and CI source; this was not a full authenticated CI-export manifest comparison. [Browser evidence](browser.md) distinguishes local and deployed identities.

Firefox, Safari, mobile, macOS and a fresh consumer Windows VM remain untested. Fresh rc.5 container acceptance is distinct from the historical rc.4 bootstrap wrapper tests; distinct-image upgrade/rollback and HTTPS remain unverified. No fresh rc.5 executor round trip is claimed. Preserve the [unsupported scope](remaining-limitations-rc.md), requested quality policy and independent behavioral evidence. These results do not justify universal support or promotion to issue-free stable status.
