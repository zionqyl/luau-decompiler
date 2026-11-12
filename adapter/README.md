# Optional executor adapter

The adapter replaces the selected executor's existing `decompile` entry point with the standalone Rust implementation. Local CLI/library/source processing does not require this adapter. See the current [adapter contract](../docs/adapter-rc.md), [HTTP/self-hosting contract](../docs/hosting.md), [API](../API.md) and [format compatibility](../docs/compatibility.md).

Start the packaged service with a random `LUAU_DECOMPILER_TOKEN` of 32–256 printable non-space ASCII characters. The default endpoint is numeric loopback. The portable bundle includes the analyzer/manifest/definitions required for strict validation; end users do not need a compiler toolchain.

```powershell
./bin/luau-decompile.exe serve --listen 127.0.0.1:7879 --workers 4 --cpu-threads 4 --queue 16 --memory-mib 1024 --timeout-ms 30000
```

Obtain `adapter/decompile.luau` from the matching contributor/source ZIP and place it in the executor filesystem; the compact standalone runtime does not include adapter source. Load it through the executor's supported loader, then install explicitly:

```luau
local Adapter = assert(loadstring(readfile("adapter/decompile.luau")))()
local controller = Adapter.install({
    token = "replace_with_the_service_token",
    endpoint = "http://127.0.0.1:7879/v1/decompile",
    executor_profile = "generic",
    bytecode_encoding = "auto",
    reconstruction_config = {
        output_policy = "verified_typed",
    },
    timeout = 30,
    max_in_flight = 2,
})

local result = controller.decompile_detailed(myTestModule)
local source = controller.decompile(myTestModule)
assert(controller.restore())
```

`generic` uses canonical reconstruction settings and capability-based target dispatch. `volt`, `lynx` and `madium` select their separately documented native target/option contracts. A documented profile or working getter is not a live compatibility certification. Default `auto` recognizes supported marked containers; it does not guess unmarked opcode227. Select `roblox_opcode227` only when the getter representation is independently established; Rust changes instruction opcode headers and preserves AUX words. [Representation scope](../docs/bytecode-representations.md) distinguishes structural recognition from unverified signature authenticity. Custom representation normalization requires a named callback.

| Helper | Contract |
| --- | --- |
| `decompile(target, nativeOptions?)` | Installed source-returning override; selected native calling convention |
| `decompile_detailed(target, nativeOptions?)` | Full reconstruction, faithful baseline, diagnostics, typing/validation/provenance |
| `decompile_canonical(target, settings?)` | Explicit canonical extension independent of native option spelling |
| `decompile_canonical_detailed(target, settings?)` | Detailed canonical extension |
| `decompile_with_timeout(target, canonicalSettings, seconds)` | Source helper with deadline separate from native options |
| `decompile_detailed_with_timeout(target, canonicalSettings, seconds)` | Detailed deadline helper |
| `decompile_bytecode(bytes, seconds?)` | Explicit binary-safe bytecode extension |
| `decompile_bytecode_detailed(bytes, seconds?)` | Full result for caller-supplied bytes |
| `handshake()` | Authenticated service capabilities, cached for 60 seconds |
| `restore()` | Deactivate this layer and restore its active predecessor when appropriate |

Script targets use the script getter. Raw bytecode strings bypass getters. Function targets require a supported function getter and select the explicit function-entry output contract. Dumps do not contain the current values of external upvalues; missing captures are reported rather than invented. A fake function getter verifies dispatch only.

The native second argument is an options table where documented, not a timeout. Unknown settings, cycles, excessive option depth/size and unsupported formatter options fail explicitly. Source-returning helpers enforce the requested output policy. A failed verified-typed HTTP 422 response retains source and detailed diagnostics; detailed helpers return it and source helpers raise a structured quality error. `allow_dispatcher=false` separately rejects dispatcher presentation.

All requests use exact-byte canonical base64, bearer authentication, bounded in-flight admission, request IDs and shared service deadlines. `cancel_on_timeout` and `cancel_on_restore` are independent. A native HTTP function can outlive local timeout when its API provides no cancellation handle; its slot remains occupied until its callback returns. Restoration is safe out of order and never resurrects an inactive predecessor.

Remote deployment requires `allow_remote=true` with an HTTPS hostname endpoint and the authenticated [reverse-proxy configuration](../docs/hosting.md). HTTP non-loopback endpoints are rejected. A phone's loopback cannot reach a PC. Implemented HTTPS configuration does not certify an untested executor's TLS/transport behavior.

Run the injected contract suites using the pinned Luau interpreter:

```powershell
./.tools/luau/luau.exe adapter/test.luau
./.tools/luau/luau.exe adapter/test-v3.luau
./.tools/luau/luau.exe adapter/test-rc.luau
```

These are mocks. The [v0.2 report](../docs/evidence.md) is historical evidence for its exact older executable: one unknown-source native packet observed repeatedly, plus four supplied-bytecode programs. The [v0.3 attempt](../docs/evidence.md) failed at transport. Neither establishes current-release live compatibility. Current live claims require a new source/configuration/executable-bound report and several distinct known-source native getter programs. Catalog inventory, API documentation, mock results and historical observations remain separate in the [executor matrix](../docs/executors-v3.md).

The [rc.2 connected-client result](../docs/adapter-rc.md#rc2-connected-client-result) covers five known-source native functions and 21 exact typed comparisons through canonical function/raw HTTP helpers. It does not certify Madium's documented native script convention or normal-engine script extraction.
