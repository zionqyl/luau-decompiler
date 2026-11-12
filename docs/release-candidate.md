# 0.4.0-rc.4 assessment

Rc.4 substantially broadens evidenced Roblox input handling, fixes captured-scalar typing and reconstruction failures, improves a concrete bytecode-derived presentation, and removes repeated browser analyzer initialization. It remains a release candidate within the [supported scope](support-matrix-rc.md). The final optimized native profile is running; complete native-gate and extracted-runtime/installer acceptance are **pending**. Neither development checks nor the measurements below substitute for those final boundaries.

The measured native candidate is SHA-256 `5b1316e78fa183aafe32c46471ce31cb3601778a5650b26898e7a27743a7953d`. Reports retain source, fixture, configuration and tool identities. Earlier rc.3 and superseded rc.4 outcomes remain historical in [release evidence](evidence.md).

## Representation and real input coverage

The former 24-byte barrier is an observed signature container: sixteen opaque signature bytes followed by two checked XOR marker words. Both build-specific equations and the exact serialized main-prototype boundary are required. Version-9/version-14 bodies use the evidenced opcode227 mapping. Original bytes, hashes and trailer remain preserved; cryptographic authenticity is explicitly **not verified**. Unknown trailers and unsupported semantics still reject. See the [representation contract](bytecode-representations.md).

The immutable capture reconciles 37,285 observation records to 37,052 distinct objects, including 233 repeats. There are 37,020 captured objects and 23,645 unique serialized buffers. It includes extensive Roblox engine content; it is not an MM2-only denominator. Reviewed MM2 project scope contains 340 distinct objects, including 339 captured objects and 209 unique buffers. Observed project paths do not prove erased-source authorship.

| Unique-buffer result | Whole capture, rc.3 / rc.4 | Reviewed MM2 scope, rc.3 / rc.4 |
| --- | ---: | ---: |
| Decoded | 16 / 23,645 | 13 / 209 |
| Reconstructed and compiled | 16 / 21,854 | 13 / 182 |
| Strict analysis passed | 8 / 4,512 | 8 / 52 |
| Both strict and meaningful typing | 2 / 3,259 | 2 / 38 |

Rc.3 results are historical joins against the same reviewed scope, not retimestamped reruns. Rc.4 actually reprocessed every retained unique buffer using the final candidate. All reconstructed sources compiled. The whole-capture remainder is 1,297 structural, 88 semantic, 387 resource-limit and 19 cancellation outcomes. Marked-container detection covers 23,629 buffers; sixteen unmarked buffers still need an explicit getter-encoding contract. A separate census accounts for 4,819,328 instruction occurrences across 78 opcode families. Decoding, opcode presence and compilation do not establish behavioral correctness.

The corpus requested annotated/check output. Its joint strict/typing counts are not relabelled as requested verified-typed policy successes. No captured program was executed. [Detailed scope and outcomes](client-corpus.md) remain separate from controlled known-source behavioral evidence.

## Correctness, typing and presentation

Captured scalar histories now propagate later writes and delayed initialization into closure return inference. Bounded exhaustion widens unresolved capture facts rather than retaining stale numeric or nil annotations. Open-result scratch proofs distinguish future and closed captures from active captures at both producer and consumer. Active captures still reject when faithful reconstruction is unproved.

Direct closure presentation requires a proven acyclic root under the declared single-entry contract and no self-value capture. Repeated, cyclic and nested sites retain conservative construction where freshness requires it. Cross-optimization identity tests protect against turning fresh closures into shared closures. The actual [verified bytecode example](../examples/typed-output/verified_bytecode.luau) now emits an ordinary local function and exact scalar types without manually cleaned output.

Corpus failures exposed a child CFG error incorrectly triggering a parent snapshot panic, and invalid leading statement separators at block entries. Both have controlled minimized regressions. Difficult nonlocal loop exits still produce contextual prototype/PC diagnostics. GETIMPORT validation now compares only the active path fields used by the pinned VM, preserving inactive bits and rejecting active-path/count mismatches. Controlled compiler/VM comparisons cover cached and unsafe-environment behavior; captured scripts are not behavioral fixtures.

Every returned generated document, baseline and quality failure retains exactly one executing-version attribution header. Finalization precedes validation, hashes and generated positions; exports preserve those bytes. Erased source declarations, missing project contracts, broad dynamic interfaces and unsupported instructions remain visible. Strict success does not prove semantic equivalence.

## Browser, installation and live integration

The actual static export passed 29 required Chromium 143.0.7499.4 acceptance groups plus one optional private-capture group on Windows. Shared Rust WASM processing and the real pinned C++ parser/compiler/strict analyzer run locally in workers without a processing backend, account or SharedArrayBuffer. Checks cover strict rejection, native/browser agreement, all-origin request observation, exports, subpath assets, workspace-wide retention, stale worker errors and selection preservation. Only static assets are fetched. Browser source/asset identities and limits are in the [browser guide](browser.md).

Prepared analyzer reuse removes repeated definition checks from warm requests while retaining exact final-source validation and project/contract isolation. The [matched performance report](performance-rc.md) records large warm browser gains on small fixtures, material cold initialization, and mixed native changes. The earlier native large-module regression is not established as resolved.

Fresh Windows installer bootstrap ownership now precedes staging/version writes. Recovery runs under the lock after pending activation recovery, cleans only owned transaction state and preserves modified user files. Management files come from the newly verified payload. Focused interruption/retry checks are distinct from the pending complete final-package acceptance. Installed native processing remains offline and independent of Roblox, an executor or HTTP.

One fresh Madium 2.0.0 / Roblox 0.747.0.7471481 Windows LocalScript completed native getter, default adapter detection, authenticated HTTP, final Rust reconstruction and response restoration with this exact candidate. Its 1,723-byte input is outside the immutable capture and does not enlarge that denominator. Source passed syntax/compilation but failed strict and meaningful typing; no verified badge or game-behavior claim is made. The single observed cold round trip was 0.856 seconds. It is one unknown-source script target, not broad executor compatibility. `madium-live-rc4.json` retains exact executable/adapter/settings identities and cleanup outcomes in release evidence.

## Examples, publication and remaining blockers

The user supplied MM2-owner permission on 2026-11-12. The [reviewed showcase](../examples/Murder%20Mystery%202/manifest.json) contains 297 source documents for 297 distinct objects, totalling 5,022,113 bytes; 482 successful observation records attach to those objects. It retains all 340 scoped objects and their failures, including 43 without generated files. Engine content, uncertain dependencies and original bytecode remain private. The tool's MIT license does not relicense game code.

Public release, container and Pages deployment are not yet evidenced for this candidate. The recorded unauthenticated check found the repository public and the Pages path returning HTTP 404. Matching static assets and workflows are prepared; final native acceptance and authorized publication remain separate steps. No working deployed preview or published one-command download is claimed yet. [Installation](installation.md) documents the local verified-archive workflow and current publication status.

Linux/container execution, macOS, Firefox, Safari, real mobile browsers, clean Windows VM acceptance and broad current executor target coverage remain untested here. Browser offline reload is not advertised. Unknown external contracts, recursive interfaces and unsupported CFG/table histories can still prevent verified typing or reconstruction. See the [remaining limits](remaining-limitations-rc.md).

Promotion should follow successful final native and installed-artifact gates, matching provenance and separately verified publication. The delivered scope must remain bounded by actual outcomes; finite tests do not establish universal compatibility or a bug-free stable release.
