# Read-only client corpus collection

The current candidate recognizes the observed signed representation through both marker equations and a fully validated body boundary; see [representation evidence](bytecode-representations.md). The rc.3 counts below remain historical. Current MM2 publication uses the supplied owner permission and a [reviewed project-path scope](../examples/Murder%20Mystery%202/scope.json), excluding engine locations, engine/dependency candidates, identical engine buffers and unknown attribution. A path identifies the observed project scope, not exact erased-source authorship.

This contributor workflow captures serialized bytecode through an authorized executor, then processes it with this project's Rust engine. It is separate from the browser application: Pages processing must not contact these native capture or processing endpoints.

The collector never calls an executor decompiler, executes captured bytecode, requires an unknown module, modifies game objects, or invokes game remotes. Query selectors enumerate available `LocalScript`, `ModuleScript`, and `Script` instances. Only `Script` instances with an observed client RunContext are passed to the script getter. Snapshot-local object identities, optional debug IDs, original ancestor segments, script classes and outcomes distinguish duplicate names without guessing their location. Roblox's [Instance reference](https://create.roblox.com/docs/reference/engine/classes/Instance) documents selector queries and why a dot-separated full name must not be parsed as a path.

## Capture

The maintained components are `adapter/collect-client.luau` and `scripts/capture-client.py`. The native receiver requires Python 3.12 or later; ordinary local decompilation and browser use do not.

```powershell
python scripts/capture-client.py serve --directory artifacts/private-client --snapshot client-001
```

The receiver prints its numeric loopback endpoint and writes a private control file containing a generated bearer token. It does not log credentials or incoming code. Pass that endpoint, token, snapshot identity, authorized place ID, and a binary-safe base64 function into `Collector.start`. Use the actual executor loader to load the collector; do not assume the repository filesystem is the executor filesystem. The collector first transfers a known binary probe containing zero and non-UTF-8 bytes and compares the exact response before collecting scripts.

Inventory and extraction batches have separate acknowledgements. Retrying a pending batch preserves its original bytes and advances only after acknowledgement. The host journal recovers complete records after an interrupted final append. Getter errors, unsupported contexts, disappearance and budget rejections remain outcomes, rather than replacement scripts. Completed capture clears its instance references. Inspect `controller.summary()` for completion, then remove the owned controller reference and shut down the authenticated receiver.

The defaults allow 50,000 inventory entries, an 8 MiB individual bytecode string, 512 MiB aggregate bytecode and bounded 16 MiB HTTP bodies. Metadata journals also have an aggregate limit. The collector prioritizes observed game-service classes before CoreGui/CorePackages, but inventories both. The receiver retains content-addressed original byte buffers separately from generated source. In-repository capture destinations must remain under ignored `artifacts`.

## Process without executing

Select representation handling explicitly. A packet that parses under an encoding is not independent proof that an undocumented getter uses that encoding.

```powershell
python scripts/capture-client.py process --directory artifacts/private-client --binary target/release/luau-decompile.exe --encoding roblox_opcode227 --representation-basis "Explicit provisional interpretation; not independently verified for this script getter" --policy faithful --no-validation --generation opcode227-candidate
```

One owned localhost Rust service provides reusable bounded CPU workers, per-file deadlines, structured diagnostics and bounded output. It is started and stopped by the processing command. All processing requests use authentication; captured source is never evaluated. Hash-identical input buffers under identical settings reuse one processing outcome while retaining separate instance metadata and hierarchy exports.

Per-generation journals make progress resumable. Re-running the same command checks the engine/configuration identities and skips acknowledged outcomes. `--total-seconds`, `--timeout-seconds`, `--max-inputs` and `--max-output-mib` bound a run. Creating a `pause` file in that generation directory stops before the next input; remove it before resuming. A separate generation name retains an alternative encoding or quality investigation. It never modifies original bytecode.

To check only previously reconstructed inputs with the real pinned quality pipeline, use `--policy verified_typed --only-source-from GENERATION` without `--no-validation`. Validation attempts share a bounded deadline. Typed candidates and detailed reports are stored separately from the primary faithful hierarchy; strict rejection retains source. The processor checks that every returned source has the executing engine's canonical attribution block and copies finalized bytes without adding a second header.

New processing generations keep their own `generation-manifest.json` and `corpus/examples/Murder Mystery 2/<observed service>/<observed ancestor names>/<script>.luau`. The original capture manifest and prior generated exports remain unchanged. Component sanitization, case/Unicode collision handling and identity suffixes prevent distinct objects from overwriting one another. The manifest retains original segment bytes and identities. It creates service directories only for actual reconstructed outputs and never moves PlayerScripts into guessed StarterPlayer locations.

## Historical rc.3 snapshot and processing

The [aggregate report](client-corpus-report.json) records counts, settings, actual executable/tool identities and validation outcomes without captured code or private instance names.

The available Madium 2.0.0 client ran Roblox 0.747.0.7471481 in place 142823291, place version 1462. The snapshot inventory contained 37,285 script instances: 466 LocalScripts, 36,780 ModuleScripts and 39 Scripts. This includes Roblox-provided CorePackages/CoreGui content, not only MM2-authored code. The population can change between observations.

Fresh target probes confirmed that `getscriptbytecode` rejects a function and `getfunctionbytecode` rejects a script instance. The function getter accepted a separate controlled function, returning a version-13/type-3 dump. These probes establish separate getter contracts; they do not extend script-extraction coverage.

Actual script-instance getters returned 37,253 byte strings, totalling 72,049,630 bytes. Thirty-two non-client Script contexts were recorded as unsupported. There were no observed getter failures or disappearing instances in this capture. Exact deduplication produced 23,645 different serialized buffers (67,460,571 bytes); these are buffer counts, not claims about different original programs. Their headers identify 23,363 version-9/type-3 buffers and 282 version-14/type-3 buffers.

An upstream-encoding investigation recorded 14,829 decode failures and no source, then stopped rather than repeating that failure across every remaining input. A separately labeled opcode227 investigation processed all 23,645 distinct buffers. Sixteen input buffers reconstructed to thirteen distinct finalized source hashes, exported for 53 observed instances: 44 LocalScripts and nine ModuleScripts. All sixteen accepted source candidates compiled with the pinned official compiler. Captured game code was not executed.

The other 23,629 distinct inputs, representing 37,200 instances, were rejected for exactly 24 trailing bytes after the parsed main prototype. Version 9 accounts for 23,363 of these inputs; version 14 accounts for 266. The observed trailers were distinct and nonzero, with no common fixed byte positions or tested SHA-256/SHA-384 body-prefix/suffix match. Their meaning is unresolved. No bytes were stripped or reclassified as supported metadata to obtain source.

All sixteen accepted inputs also received bounded real verified-typed attempts without invented game contracts. Eight passed strict analysis, eight failed it; only two inputs, representing three instances, passed both strict analysis and meaningful typing. Six strict-passing inputs still failed the useful-typing policy. These are source-quality facts under an explicit provisional representation interpretation, not behavioral or representation-equivalence proof. Faithful outputs, typed candidates, diagnostics and original bytes remain separate.

The full serialized-buffer pass used the recorded debug executable. The final optimized rc.3 executable then processed all sixteen previously reconstructed inputs under both faithful and verified-typed policies. All finalized source hashes matched their earlier candidates, and all 53 instance exports matched the engine's bytes under each policy. The strict and useful-typing outcomes remained unchanged. Exact-source compilation evidence was reused; strict verification actually ran again. Both final processing services reached readiness, acknowledged authenticated shutdown and exited successfully.

The subsequent final-executable check used SHA-256 `a5b735d38c2f61bc6d6a5d09cfc83a486cb3b7dc26e59dcf1ded215f189a150b`. Its two separate generations again processed only the sixteen previously reconstructed inputs, preserving 53 instance exports per policy and the same finalized source hashes. Strict analysis passed eight inputs; two inputs, representing three instances, met the verified-typed quality policy. Both services shut down successfully. The independent final receipt is retained with release evidence as `client-corpus-rc3-final.json`; the earlier aggregate report retains its original executable identities. No claim is made that the final executable repeated the full 23,645-input pass or established behavioral equivalence for captured code.

The exact loaded collector source hash was recorded. A pre-start whole-file fingerprint of the Python receiver was not recorded: processing-only edits were made while collection ran, and current/post-capture hashes identify the reproduction script rather than attesting the exact running full file. The report preserves this provenance limitation instead of substituting a later hash. Original-buffer hashes were independently rechecked, and capture never depended on the mutable processing implementation.

## Rc.4 reprocessing and inventory reconciliation

The retained capture contains 37,285 observation records, including 233 repeated observations of the same LocalScripts. Terminal path-segment identities and matching debug IDs establish 37,052 distinct objects; their class, path, extraction outcome and bytecode hash were unchanged across these repeats. There are 37,020 captured objects and 32 unsupported Script contexts. The historical receipt remains unchanged; its instance-labelled counts describe observations. Exact serialized-buffer deduplication still yields 23,645 unique buffers.

The [current corpus manifest](../examples/Murder%20Mystery%202/manifest.json) separates observations, distinct objects and unique serialized buffers. Reviewed MM2 project scope contains 340 objects, observed 547 times, with 339 captured objects and 209 unique buffers. The remaining distinct objects are 36,597 under engine services, 58 unconfirmed engine components, six unconfirmed dependency components and 51 of unknown attribution. Engine-identical buffers are excluded from game publication. These are reviewed project-path classifications under the supplied permission; erased source authorship cannot be independently established from a path.

An earlier independent local-reference decoder census accepted all 23,645 buffers with exact body boundaries, accounting for 4,819,328 instruction occurrences across 78 opcode families. Of these buffers, 23,629 have the recognized signature-container markers; sixteen unmarked buffers require the explicit getter encoding. They represent 36,989 marked and 31 unmarked captured objects respectively. Structural acceptance does not verify cryptographic authenticity or reconstruction correctness.

| Unique-buffer result | Whole capture / 23,645 | Reviewed MM2 scope / 209 |
| --- | ---: | ---: |
| Decoding recorded by published-binary processing (lower bound) | 23,239 | 208 |
| Reconstructed and compiled | 21,854 | 182 |
| Strict analysis passed | 4,512 | 52 |
| Meaningful typing passed | 3,342 | 39 |
| Both strict and meaningful typing | 3,259 | 38 |

The final published-binary pass used executable SHA-256 `1bcace5d9ee1ad0b459da926322ddaaf01cf824003cb33ec4390f24be1e9c3b4` and its bundled analyzer `75718ac12edcb6bd5e086f509d0d676eb379688a7bcd1233180ca13b6068dce9`. It retained annotated/check output, real pinned validation, two recovery attempts, eight seconds per request, two CPU workers and a 3,600-second total bound. Capture-manifest, scope, processor, executable, helper and definition identities were checked before/after. Each original input buffer was independently hash-checked once when read, before submission; no second full raw-buffer pass was run. Processing took 1,105.687 seconds; total wall time including private hierarchy export was 1,392.984 seconds. All 21,854 reconstructed buffers compiled. Rejections remained 1,297 structural, 88 semantic, 387 resource-limit and 19 cancellation outcomes. No captured program was executed. This pass requested annotated/check, so joint strict/typing passes are not relabelled as requested verified-typed policy successes.

Processing records establish at least 23,239 decoder passes; the 387 resource-limit and 19 cancellation outcomes do not retain a separate decoding status. One MM2 buffer has that resource-status ambiguity. These are not silently counted as decoding success or failure. The separately identified earlier full decoder census is not relabelled as a shipped-binary run.

The prior local `5b1316e7` pass took 797.016 seconds. The new processing observation was 38.7% longer, but these sequential shared-host runs include transport/filesystem work and use different executable/analyzer builds; they are not a controlled throughput comparison. All 21,854 generated source hashes, compilation/strict/meaningful outcomes and failure categories match. Two already-failed inputs have inferred-unknown counts differing by two, and six diagnostic cardinalities differ; no gate outcome changed. All 297 public documents and 5,022,113 bytes match exactly, so the original showcase manifest, configuration and files remain unchanged. The new aggregate, provenance and comparison reports are a separate supplemental receipt.

The preceding `fc377756…` pass completed in 775.469 seconds with the same aggregate outcomes. It was superseded after a fresh live script dump exposed inactive GETIMPORT path bits that the decoder incorrectly required to match. Official VM semantics and controlled compiler-backed observations justified the correction. Both full reports retain their own original binary identities; that local-reference candidate repeated processing and exact-source validation with `5b1316e7…`. These processing totals include transport, filesystem work and shared-host contention and are not a matched throughput comparison.

For the same reviewed scope, historical rc.3 reconstructed thirteen buffers; eight passed strict analysis and two passed both strict and meaningful typing. It represented 28 reconstructed objects, eleven strict-passing objects and two jointly passing objects. Rc.4 produces 297 complete source documents for 297 objects, including 56 strict-passing and 38 jointly passing objects. The documents total 5,022,113 bytes. Their 482 successful observation records remain attached to the corresponding files; they are not counted as 482 documents. Forty-three scoped objects have no generated file, including the unsupported extraction context. No placeholder files are published.

The initial rc.4 investigation stopped after discovering a single-block reconstruction panic and an invalid leading statement separator. Both were minimized and fixed before the final pass. The final service shut down with HTTP 200 and exit status zero; private hierarchy export had no errors. Extended Windows file operations preserve long observed paths without changing global path policy. Canonical promotion groups repeated observations, distinguishes same-named objects and source versions, and preserves user-modified files. Twelve focused collector/export tests cover these boundaries. The final source and input identities are retained in release evidence and the corpus manifest.

The [configuration](../examples/Murder%20Mystery%202/generation.config.json) and [classification scope](../examples/Murder%20Mystery%202/scope.json) accompany the source documents. The browser loads eligible examples on demand from this single corpus; it does not contain a second maintained copy of game code. Missing module context, external contracts and failed strict analysis remain per-file outcomes. Captured-source compilation is not a behavioral equivalence test.

## Rights and publication

On 2026-11-12 the requesting user confirmed permission from the Murder Mystery 2 owner to use the game as an example. That permission is supplied, not pending. It covers eligible MM2 project outputs; Roblox engine content and unrelated dependencies remain excluded. The original rc.3 receipt's private-only rights status describes what was available then and is preserved unchanged. Original buffers and the whole-client capture remain private under ignored `artifacts/rc3-mm2`.

The maintained `capture-client.py corpus` command promotes only complete outputs in the explicit project scope and creates one manifest retaining all scoped inventory entries, including extraction and reconstruction failures. It checks engine output hashes and attribution, preserves observed hierarchy and refuses to overwrite modified or unowned public files. No placeholder source is emitted for rejected inputs. `--fallback-generation` can retain a faithful source when another generation did not process that input; the selected source's own generation and validation status remain explicit.

The decompiler's MIT license does not license third-party game code; its attribution credits the tool rather than the original author. Bytecode usually erases original notices, and none are fabricated. This snapshot does not recover server-only scripts, objects created later, or anything outside the observed client-accessible inventory. Captured programs are never executed for behavioral validation.

## Focused checks

```powershell
python scripts/test-client-capture.py
```

The synthetic checks cover exact binary transfer storage, deduplication without merging objects, repeated observations versus source versions, path/case/Unicode collisions, long Windows paths, interrupted metadata writes, retry conflicts, resource bounds, private staging, immutable capture receipts and safe publication. Live collection is separate evidence; these tests do not impersonate a connected executor.
