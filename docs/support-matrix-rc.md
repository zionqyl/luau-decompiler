# Candidate support matrix

This matrix describes `0.4.0-rc.4`. Completed package evidence is recorded in the [release assessment](release-candidate.md). An implemented path is not automatically a tested platform or native integration.

| Input/workflow | Implemented scope | Evidence boundary |
| --- | --- | --- |
| Local files/stdin/stdout and output files | Shared byte/source dispatch; binary file preservation; explicit format override | Windows executable and separate-working-directory package acceptance |
| Bounded batches | Persistent CPU workers; ordered bounded windows; per-input errors and quality failures | Rust/service regressions and packaged batch acceptance |
| Rust embedding | Direct source/byte buffers; reusable processor; cancellation, deadline, caller assets and bounded resources | Rust embedding example and focused API tests |
| Luau bytecode | Explicit version profiles 3 through 14; structural auto-detection of upstream raw and the evidenced v9/v14 signed container; explicit opcode227 getter override | Required compiler/oracle matrices plus exact-body validation of all 23,645 retained unique native buffers; decoding does not establish reconstruction or behavior |
| Luau source | Documented bounded Rust syntax subset; retains names/types; safe local inference and formatting | Positive/negative parser tests, strict signature tests, 12 preserved source families plus 56 generated source programs |
| Lua source | Explicit Lua 5.1 compatible syntax intersection with compatible runtime/environment contracts | Supported common syntax tested through Luau; no universal cross-dialect runtime certification |
| Standard Lua/LuaJIT bytecode | Recognized and rejected; no backend | Format-specific rejection tests |
| Browser static workspace | Shared Rust WASM reconstruction/source pipeline plus pinned C++ WASM parser/compiler/strict analyzer; supplied modules/contracts in memory | Real static-export acceptance is independent; see [browser evidence](browser.md). No processing service or script execution. |
| Windows self-hosting | Authenticated HTTP, bounded pool/writers/cache, cancellation, readiness and graceful drain | Windows listener and runtime acceptance tests |
| Linux server/container | Build script, runtime assets, container, TLS proxy and CI procedure | Runtime/container/HTTPS tests **not run**; no Linux runner available, confirmed by user |
| macOS | No certified candidate package | **Not run**, no Mac runner available |
| Android/iOS | No certified same-device or encrypted companion integration | **Not run**; a phone's loopback cannot reach a PC |

Bytecode instruction coverage remains narrower than format recognition. Native userdata callbacks, unsupported prototype guards, integer constants and experimental class features remain explicit diagnostics. Real function entries support fixed parameters and varargs under `entry_output=function`; missing upvalue values are not reconstructed. A detected nil-placeholder capture wrapper is rejected in this contract, including conservatively rejecting legitimate factories with that exact shape.

| Executor integration evidence | Meaning |
| --- | --- |
| Documented native Volt/Lynx/Madium profiles | Calling conventions/options checked against the recorded documentation; capability-specific wrappers |
| Mock adapter suites | Dispatch, options, binary transport framing, timeout/restoration, bounded normalization and policy behavior under injected APIs |
| Catalog snapshot | Advertised inventory only; historical observation date retained |
| Rc.4 retained Madium client snapshot | Same original capture, reconciled observations and distinct objects; all 23,645 unique buffers decode and 21,854 reconstruct/compile. Strict, meaningful typing, MM2 scope and source publication have separate counts. [Exact evidence](client-corpus.md). No captured script execution. |
| Rc.4 Madium 2.0.0 / Roblox 0.747.0.7471481, Windows | One real Preloader LocalScript through native script getter, current default-auto adapter and final `5b1316e7…` HTTP service. Annotated source passed exact-source syntax/compilation; strict analysis and meaningful typing failed. Restoration and shutdown passed. Original source was unknown, no game code was executed, and no controlled normal-engine known-source, function-dump or broad executor certification is implied. [Exact live scope](adapter-rc.md#rc4-real-script-target) |
| Historical v0.2/v0.3 live reports | Apply only to their recorded builds, binaries, packets and transport outcomes |
| Rc.2 Madium 2.0.0 / Roblox 0.747.0.7471481, Windows | Final-binary canonical function/raw HTTP helpers: five known-source functions, 21 complete typed comparisons; absent capture rejected. Native script calling convention and normal-engine script extraction not tested. [Exact live scope](adapter-rc.md#rc2-connected-client-result) |

See [adapter contracts](adapter-rc.md), the versioned [catalog/matrix](executors-v3.md), and the candidate release assessment for exact observed outcomes. Executor availability is independent of standalone release validation.
