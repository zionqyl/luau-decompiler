# Executor discovery and platform matrix

Observed 2026-11-10T17:07:19.0304988+00:00 from the [WEAO catalog](https://weao.xyz/api/status/exploits) using its required `WEAO-3PService` user agent. [API contract](https://docs.weao.xyz/weao-api-reference/exploits.md). This snapshot contains 31 product/platform entries: 21 executors and 10 external tools. Raw SHA-256: `386603cd1ab130239cc65b379dd7656241da77cd09a252a6566f2aa42a2342b4`. [Machine-readable evidence](evidence.md).

Catalog versions and Roblox builds below are **advertised**, not independently measured. No catalog row is end-to-end compatibility evidence. Built-in decompiler advertising and UNC/sUNC scores are not used as proof. Architecture, target/getter/request contracts, byte handling, encoding, profile and supported options remain unverified for these advertised builds.

The [full machine-readable compatibility matrix](evidence.md) supplies each row's advertised versus observed builds, architecture, target/getter/request/binary-string capabilities, options/returns/errors, representation/encoding/profile, distinct native/supplied programs, observations/timing runs, date, limitations and status. Its 31 catalog rows, three injected-wrapper contract rows and historical v0.2 live row are separate collections. No test results transfer between them. The current v0.3 live collection records one failed transport attempt with zero verified behavioral pairs; its details remain separate from mock and historical results. Regenerate with `scripts/build-executor-compatibility-v3.ps1`; add `-RunMockTests` to record an actual host mock run. The mandatory gate uses `-AdapterMocksVerified` only after checking the successful pinned command, then records its tool/source hashes. Neither path establishes executor validation. The retained catalog keeps its original HTTP observation date.

Rc.2 adds independently observed Madium 2.0.0 / Roblox 0.747.0.7471481 Windows function/raw canonical-helper HTTP evidence: five known-source functions, 21 exact typed comparisons, with documented native script targets still untested. See [exact contracts and archive](adapter-rc.md#rc2-connected-client-result). This does not change the advertised catalog rows or retimestamp their snapshot.

Rc.4 separately records one successful real LocalScript getter → current default-auto adapter → authenticated HTTP → final executable round trip on the same observed Madium/Roblox builds. Exact-source syntax and compilation passed; strict analysis and meaningful typing failed. The original source was unavailable, so this supplies no new behavioral comparison. The [current evidence archive](evidence.md#current-acceptance) contains `reports/docs/results/madium-live-rc4.json`, identifying the executable, adapter, input, output, settings and cleanup; [integration details](adapter-rc.md#rc4-real-script-target) distinguish this result from historical known-source function tests. The catalog below retains its original observation and status.

| Product | Platform | Kind | Advertised executor version | Advertised Roblox build | Interface verification | Distinct native programs | Status |
| --- | --- | --- | --- | --- | --- | ---: | --- |
| Athena | Windows | executor | 1.0.1 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Axis | Windows | external tool | 0.5.3-28a4d7830c6ed9a9 | version-4ea8e85481e34f46 | not run | 0 | catalog only |
| DX9WARE V2 | Windows | external tool | 1.1.227 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Isaeva | Windows | executor | 2.6.8 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Lucid | Windows | executor | 1.0.3 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Lumen | Windows | external tool | 1.0.9 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Lynx | Windows | executor | 0.746 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Madium | Windows | executor | 2.8.7 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Madius | Windows | external tool | 1.11.9-beta | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Matcha | Windows | external tool | v2 | version-4ea8e85481e34f46 | not run | 0 | catalog only |
| Matrix Hub | Windows | external tool | v3 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Melatonin | Windows | external tool | 1.4.4l | version-5aed1822f52c4b03 | not run | 0 | catalog only |
| Photon | Windows | external tool | 7.1 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Potassium | Windows | executor | 2.6.1 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Real | Windows | executor | 3.1.0 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Seliware | Windows | executor | 2.4.9 | version-4b6315bf1f0a4dbb | not run | 0 | catalog only |
| Serotonin | Windows | external tool | v2 | version-4ea8e85481e34f46 | not run | 0 | catalog only |
| Severe | Windows | external tool | v2 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| SirHurt | Windows | executor | V5.480 | version-4ea8e85481e34f46 | not run | 0 | catalog only |
| Solara | Windows | executor | 0.1.9 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Synapse Z | Windows | executor | 1.0.4.0 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Velocity | Windows | executor | 1.6.0 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Volcano | Windows | executor | v3.2.10.4 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Volt | Windows | executor | 1.3.21.3 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Wave | Windows | executor | NEW-1.6.1 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| Xeno | Windows | executor | 1.3.65 | version-f0ea5da9412f4e35 | not run | 0 | catalog only |
| MacSploit | macOS | executor | 746.2 | version-2fc79d515be6449d | not run | 0 | catalog only |
| Opiumware | macOS | executor | v2.6.0 | version-b09c93298b5d4cd1 | not run | 0 | catalog only |
| Delta | Android | executor | 2.729.840 | 2.729.840 | not run | 0 | catalog only |
| Vega X | Android | executor | 2.734.917 | 2.734.917 | not run | 0 | catalog only |
| Delta | iOS | executor | 2.729.838 | 2.729.838 | not run | 0 | catalog only |

## Evidence and unavailable environments

Madium and Madius are separate products. The catalog's external-tool label does not establish whether that product exposes the required script, function, getter or HTTP interfaces; those interfaces must be probed against an explicitly selected build. Never inherit Madium evidence into Madius.

The historical [v0.2 Madium run](evidence.md) exercised Madium 2.0.0 / Roblox 0.746.0.7461267 on Windows, explicit opcode227 and format14. It covers one native 47-byte compiler model with unknown original source provenance plus four supplied-bytecode source fixtures. Sixty-five repetitions are not sixty-five distinct native programs. This historical build differs from the catalog's advertised Madium version and does not certify v0.3 output. Current v0.3 client evidence belongs in separate integration reports identifying the executable, runtime and fixture identities.

The [actual v0.3 attempt](evidence.md) on Madium 2.0.0 / Roblox 0.746.0.7461267, client PID 14180, failed at transport: **zero verified native/supplied behavioral pairs and zero successful adapter timing samples**. The exact 47-byte SocketTypes getter packet has independent host/compiler-model proof, four native argument/target rejections passed, oracle collision/incompleteness checks passed, and timeout cleanup restored the function/registry. Those are partial checks. Out-of-order live restoration, settings behavior and malformed-bytecode HTTP diagnostics were not reached.

Authenticated host capabilities returned 200. Native Madium HTTP calls did not complete 8/10-second probes or a final roughly one-minute observation; `HttpService:RequestAsync` was blocked in that MCP context. A host-launched service outside the execution sandbox had the same failure. The cause is **unknown**; neither Rust failure nor sandbox causality is established. Both owned services were stopped and temporary authentication/test keys removed. The executor API exposed no cancellation handle, so native HTTP tasks may outlive wrapper deadlines. Historical success does not certify this attempt.

The failed attempt tested executable 41e2a2ab, before the final benchmark-gate and
quality-buffer admission audit fixes. Its exact hash remains in the report and
matrix. The final audited executable's native path was not rerun; no result is
transferred between those binaries.

[Volt's documented decompile contract](https://docs.volt.rs/docs/scripts/decompile) and [Lynx's script APIs](https://getlynx.gg/docs/api/scripts) are documentation contracts, not live compatibility claims. Shared target-aware adapter dispatch applies documented wrappers only when selected explicitly and when required capabilities are present. Unsupported options fail explicitly.

No macOS build host/client was supplied for this run; tested macOS packages and live MacSploit/Opiumware integration are not claimed. Android/iOS same-device Rust services and a paired authenticated encrypted companion transport have not been run. A phone's loopback address cannot reach a PC service. Existing loopback transport must not be relabeled a mobile companion transport.

A controlled place must provide engine-compiled known-source ModuleScripts, LocalScripts and client-run Scripts before broad native extraction can be verified. Where Studio or that place is unavailable, retain the fixture/procedure and mark the native matrix not run. Do not replace native program coverage with supplied bytecode or timing repetitions.

## Refresh and schema handling

Run `scripts/refresh-executors.ps1`. The cache uses a bounded body, freshness TTL, conditional HTTP requests and Retry-After cooldowns. Stale responses are labeled; failed refreshes do not turn old metadata into fresh evidence. The normalizer accepts documented arrays and known wrapper/field variations, reports rejected/duplicate rows in the denominator and publishes only allowlisted metadata. Raw sUNC keys, purchase details and descriptions are excluded.
