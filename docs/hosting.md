# Self-hosting and runtime bundles

The library, CLI and source-processing paths work offline without Roblox, an executor, an account or a localhost server. HTTP hosting is optional. A portable runtime bundle contains `bin/luau-decompile`, `bin/luau-quality`, the matching analyzer manifest, `definitions/roblox.d.luau` and license notices. Windows uses `.exe` names. Strict validation requires these helper assets; the product is not a single self-contained executable.

Prebuilt runtime users do not need Rust, Git, Python, CMake or a C++ compiler. Linux runtime dependencies are the standard C/C++ runtime from the distribution used to build the package. The supplied container includes them. Contributor builds require Rust, Cargo, G++, Git and Python 3; building the optional independent test tools also requires CMake. No submitted source or project dependency is executed by ordinary processing.

## Prebuilt container bootstrap

The configured candidate image is `ghcr.io/zionqyl/luau-decompiler:0.4.0-rc.4`. A direct source-built container passed clean Ubuntu 24.04 CI, as recorded [below](#evidence-boundary-for-this-candidate). Matching registry publication and anonymous pull are still pending. The following commands become operational only after the tested immutable image is published by the [release workflow](../.github/workflows/publish.yml); they are not current published-installation claims.

Use the `deployment` directory and `release.json` from one matching runtime bundle. Prerequisites are Docker Engine or Docker Desktop with Compose v2 and permission to run Docker. The Windows bootstrap uses Windows PowerShell 5.1 or newer. The Linux bootstrap additionally needs `curl`, `sha256sum`, `od`, `tr`, `sed`, `grep`, `awk`, `cut`, `wc`, `flock`, and `timeout` from the ordinary distribution tools.

Windows, from the extracted runtime root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./deployment/start-server.ps1 -Version 0.4.0-rc.4 -Preview
```

Linux, from the matching runtime root, after the tested image has been published:

```sh
sh deployment/start-server.sh start --version 0.4.0-rc.4 --preview
```

The bootstrap pulls once, resolves a repository digest, starts the service, waits for authenticated readiness, and performs one small verified-typed operation before activating configuration. The local endpoint is `http://127.0.0.1:7879`. It generates a protected persistent `credential.txt`; routine output gives its path without printing the credential. Retrieve it explicitly with `Get-Content` on Windows or `cat` on Linux, and supply `Authorization: Bearer TOKEN` to clients. Treat the credential and `server.env` as secrets.

Windows state defaults to `%LOCALAPPDATA%/LuauDecompiler/server`; Linux state defaults to `${XDG_CONFIG_HOME:-$HOME/.config}/luau-decompiler/server`. Override it with `-Directory` or `--directory`. Keep this directory across restarts and upgrades. `status` checks readiness and a verified-typed operation; `stop` retains configuration and credentials. For Windows use `-Action status`, `-Action stop`, `-Action update -Version VERSION`, or `-Action rollback`. For Linux use `status`, `stop`, `update --version VERSION`, or `rollback` as the first argument. Release candidates require the preview flag. Failed activation restores the previous working configuration; a retained previous digest permits rollback. These control contracts have mocked Windows tests; actual Docker upgrades and rollback remain untested here.

## Local executable service

Set `LUAU_DECOMPILER_TOKEN` to a random 32–256 character printable ASCII token without spaces, then run:

```sh
bin/luau-decompile serve --listen 127.0.0.1:7879 --workers 4 --cpu-threads 4 --queue 16 --memory-mib 1024 --timeout-ms 30000
```

The default numeric loopback listener is appropriate for local clients. Every route, including health, readiness and cancellation, requires `Authorization: Bearer TOKEN`. Ordinary logs contain listener configuration and aggregate operational information, not the token or submitted program. Do not enable proxy access logging of authorization headers or request bodies.

Each connection carries one HTTP/1.0 or HTTP/1.1 request. Clients must send a content length for POST. Chunked requests, keepalive, CORS and proxy header interpretation are deliberately unsupported. A reverse proxy must convert incoming requests to this supported upstream form. Request IDs use up to 64 ASCII letters, digits, `-` or `_`. `X-Timeout-Ms` can lower the service deadline to 1–120000 milliseconds. The configured service timeout is the upper bound.

| Route | Method | Result |
| --- | --- | --- |
| `/v1/process` | POST | Shared source/bytecode processing; full structured result |
| `/v1/decompile` | POST | Compatible alias; legacy `bytecode_base64` remains supported |
| `/v1/capabilities` | GET | Input support, encodings, profiles, policies and resource bounds |
| `/v1/requests/ID` | DELETE | Cancel active work or remember bounded pre-submission cancellation |
| `/healthz` | GET | Authenticated listener and process status |
| `/readyz` | GET | Admission/draining and required validation-asset readiness |
| `/v1/shutdown` | POST | Stop new work, drain existing jobs, then cancel jobs exceeding the drain deadline |

JSON requests contain exactly one payload: `source` for UTF-8 text, `input_base64` for binary-safe generic input, or the compatible `bytecode_base64`. Optional `input_format` values are `auto`, `luau_source`, `lua_source`, and `luau_bytecode`. A bytecode payload cannot be paired with a source format. Source cannot be paired with a bytecode format; use `input_base64` for arbitrary bytes. `reconstruction_config` supplies per-request settings. Requests cannot raise server resource limits, select arbitrary analyzer executable paths, weaken a server verified-typed requirement, or lower its meaningful-typing thresholds.

Raw `application/octet-stream` uses content detection or the configured input format. `application/x-luau` and `text/plain` are explicit Luau source paths. Formats are checked by content, not filename. Base64 uses canonical padding and exact bytes. No bytecode is decoded through UTF-8.

Transport bounds and decoded-input bounds are separate in the capability response. The JSON body budget is the base64 size of the configured maximum input plus 2 MiB for configuration. A heavily Unicode-escaped JSON source can exceed that wire budget before reaching the decoded-input limit; send compact UTF-8 JSON or raw source instead. Such requests fail with 413 identifying both bounds.

```json
{
  "source": "local answer: number = 42\nreturn answer\n",
  "input_format": "luau_source",
  "reconstruction_config": {
    "output_policy": "verified_typed"
  }
}
```

Successful required quality returns 200. A faithfully retained result that fails its required output policy returns 422 with the complete source, baseline and validation report still present. Unsupported/malformed input returns structured diagnostics. Resource or queue overload returns 503; deadlines return 408 and cooperative cancellation returns 499 where a response can still be sent. A disconnected reader can prevent delivery of any final HTTP status. Clients must inspect the result and policy facts rather than treating a source field or a strict directive as verification.

Readiness checks the same pinned helper/manifest/source and definition identities as final validation without spawning an analyzer. Missing required assets make `/readyz` return 503. Best-effort validation may remain admission-ready while its asset failure is visible in `validation_assets_ready` and `validation_assets_error`. Validation-off readiness does not imply that validation assets were needed or checked. Analyzer workers initialize lazily; an asset-ready response is neither an analyzer warm-up result nor successful analysis of any program.

The core CPU pool and response-writing pool are separate and persistent. Cache-hit response transmissions receive the same bounded job admission, request IDs, cancellation tokens and response leases as cold requests. Slow readers retain accounted output until send/disposal and cannot run socket writes on reconstruction workers or front-end workers. Caches include the input bytes, effective settings, input format and analyzer/definition/project identities. The aggregate accounting limit is a bounded admission model, not an OS RSS cap; apply an operating-system/container memory limit as well.

`/v1/shutdown` replies before draining completes. Already admitted jobs share their original deadlines; after the configured drain interval they receive cancellation. Input workers finish bounded reads and dispose rejected work, writers dispose response leases, and the listener exits. A bounded drain that cannot complete reports an error. The binary does not install a process-global signal handler. The container entrypoint translates SIGTERM/SIGINT into the authenticated shutdown request. Other supervisors should call the same endpoint before terminating the process.

## Explicit remote deployment

Remote binding requires `--allow-remote`. This enables non-loopback peers and numeric non-loopback bind addresses without source edits. The Rust HTTP server itself does not terminate TLS. Keep its port on a private network behind an HTTPS reverse proxy; bearer authentication remains enforced by the service. The server does not trust `X-Forwarded-For` or infer authentication from proxy headers.

For public HTTPS, supply a DNS hostname resolving to the Docker host and permit incoming TCP ports 80 and 443. The host needs outbound access to the registry and certificate authority. Start the bootstrap with `-Https -Domain YOUR_HOSTNAME` on Windows, or `--https --domain YOUR_HOSTNAME` on Linux. `YOUR_HOSTNAME` is a value the operator must supply; no domain is bundled. This enables the optional Caddy profile in [Compose](../deployment/compose.yaml). The ordinary loopback endpoint remains private to the host.

The decompiler runs as an unprivileged numeric user with a read-only filesystem, bounded temporary storage, CPU/process limits, and an independent memory limit. Caddy's `32MiB` body limit exceeds the default JSON transport bound; the service still enforces its own advertised input and output limits. Header and service deadlines still apply. Caddy obtains certificates when DNS and network prerequisites permit; see its official [HTTPS documentation](https://caddyserver.com/docs/automatic-https) and [proxy configuration](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy). HTTPS deployment has not been executed on this host.

The optional executor adapter accepts this remote path only with `allow_remote=true` and an `https://HOST[:PORT]/v1/decompile` endpoint. Its HTTP implementation must validate HTTPS certificates. Cleartext non-loopback endpoints, credentials embedded in URLs, query strings and fragments are rejected. A phone's loopback address still refers to that phone, not the server. This remote configuration is implemented but does not establish tested mobile/executor transport compatibility.

## Contributor Linux build and acceptance

The ordinary user path pulls a prebuilt image; source builds belong to contributors and CI. The canonical Linux workflow owns the following checks once per snapshot.

```sh
python3 scripts/build-linux.py --fetch --test-tools --threads 2
cargo fmt --all -- --check
cargo clippy --locked --all-targets -- -D warnings
cargo test --locked --all-targets
python3 scripts/runtime-smoke.py --require-linux --bundle artifacts/linux-runtime --compiler .tools/luau-modern/luau-compile --oracle .tools/luau-modern/vm-runner --report artifacts/linux-runtime-smoke.json
```

`--fetch` downloads only contributor build dependencies. `--offline` instead requires the pinned upstream checkout and cached Cargo dependencies. The script checks the upstream revision, clean tracked sources, definition hash, analyzer source/binary manifest and analyzer protocol. The runtime package contains no build-tool requirement or hidden network dependency. Docker builds fetch pinned sources and Cargo dependencies during the build stage; runtime processing is offline. Image tags and distribution packages are not a bit-reproducible build guarantee.

The Windows release driver owns comprehensive runtime acceptance once at the extracted archive boundary. Linux CI owns its separate platform acceptance. The acceptance harness runs from a separate temporary working directory. It checks source files/stdin, positive verified typing, retained negative quality output/nonzero CLI status, bounded batches, authenticated HTTP, 24 concurrent requests, the identical CLI/HTTP final source, a failed-policy HTTP 422 and graceful shutdown. With explicit independent compiler/oracle tools, it also verifies one known-source bytecode fixture and one exact typed LOBS/1 behavioral pair. Those counts are deliberately separate from broader release matrices. It does not execute arbitrary submitted source.

## Evidence boundary for this candidate

The [Linux candidate job](https://github.com/zionqyl/luau-decompiler/actions/runs/43271305691/job/131368239885) completed successfully on a clean GitHub-hosted Ubuntu 24.04 runner at commit `8749f133897978c3d0495d85aeb88de72fe7ba7e`. It ran the Rust 1.85 all-target check, pinned build, formatting, Clippy and ordinary Cargo tests; extracted-runtime acceptance with independent compiler/typed-oracle tools; container build, authenticated startup/readiness and a verified-typed request; same-container restart, clean shutdown and shell shutdown contracts; and runtime/image archival.

This is actual Linux CI evidence, independent of the local Windows host, which still has no installed Linux/Docker runtime. The public job result and step conclusions were observed; detailed artifacts require authenticated download and their exact case counts, executable/image hashes and full reports have not been retrieved into this checkout. The Rust engine/runtime implementation is unchanged since that tested commit; later workflow and diagnostic-only test changes are not claimed as another Linux execution.

The direct container check does not certify a distinct-image upgrade/rollback, the complete bootstrap lifecycle, published anonymous registry access, reverse-proxy HTTPS, another Linux distribution, macOS or mobile. Registry publication and matching downloadable assets remain separate pending boundaries. A passing Linux job does not imply that the complete Windows release gate passed.
