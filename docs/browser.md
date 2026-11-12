# Browser-local preview

The application is a Next.js static export. Processing runs in a Web Worker using the maintained Rust core and the pinned Luau parser, compiler, and strict analyzer compiled to separate WebAssembly modules. It needs no account, token, executor, localhost connection, processing API, or runtime server. Static hosting still supplies HTML, JavaScript, fonts, definitions, examples, and WASM.

Open the [published browser application](https://zionqyl.github.io/luau-decompiler/). The rc.4 deployment passed its Linux static-export gate and a separate published-origin check in Windows Chromium. Browser scope and evidence boundaries appear below. Fork deployments use **Settings > Pages > Source: GitHub Actions**; leave the custom domain blank for the ordinary GitHub project-site address.

## Use

Drop one supported file to process it automatically with bounded verified-typed defaults. Import multiple files, a folder where the browser supports directory selection, or a ZIP, then choose **Process selected**. Pasted source is also available. Newly imported files are selected without reselecting existing exclusions. Matching completed results are reused within the workspace until processing settings or the relevant project context change. The default requests verified typed output. Source names and annotations are retained where supported; bytecode uses validated reconstruction. Standard Lua and LuaJIT bytecode have no backend and reject explicitly. [Supported inputs](source-input.md) and [quality policies](types-rc.md) apply to the shared core.

Only a complete result passing the actual final-source parser, compiler, strict analyzer, and meaningful-typing gate receives **Verified typed**. A failed gate retains source and structured diagnostics. A strict directive, annotations, or an unchecked policy cannot create that badge. The report separates completeness, syntax, compilation, strict analysis, type coverage, unknowns, assumptions, dependencies, and recovery attempts.

Imported source modules provide an in-memory project for static relative dependency resolution. Explicit binding, global, instance, require, and naming contracts can be supplied as JSON. The report retains those external assumptions. Pinned Roblox definitions are included. Supplemental raw `.d.luau` definition documents and dynamic dependency resolution are unsupported in this browser interface; unresolved context stays visible. Normal processing executes neither scripts nor dependencies nor user-defined type functions.

Copy, individual downloads, and hierarchy-preserving ZIP downloads use the exact finalized engine output, including its mandatory attribution header. Some operating-system clipboards normalize line endings after `writeText`; direct downloads preserve the UTF-8 bytes. Visual theme, selection, and panel resizing do not restart processing. Processing-setting changes mark existing results as belonging to previous settings; they do not schedule work by themselves. Syntax coloring and bounded line-number rendering change only presentation; exports retain the finalized engine bytes.

## Privacy and limits

Inputs, names, paths, results, and contracts remain in browser memory. There is no telemetry, source upload, or processing endpoint. Only theme and panel width are stored locally. Reloading clears inputs. The application does not install a service worker or promise offline reload; an already-loaded worker can continue without network access, which is separately tested.

| Resource | Bound |
| --- | --- |
| Processing workers | One non-pthread worker; no SharedArrayBuffer requirement |
| Selected files / queued jobs | 64 |
| Input | 2 MiB per file; 32 MiB total |
| ZIP import | 16 MiB compressed; 32 MiB expanded; 64 entries including directories |
| Generated source | 4 MiB per file; 16 MiB retained by the workspace |
| Structured results | 32 MiB retained; 16 MiB per worker result |
| Supplied source module context | 4 MiB |
| Engine / analyzer linear-memory maxima | 256 MiB / 512 MiB |
| Deadline | 100 ms–120 s per file; 30 s initialization; 10 s archive work |
| Reconstruction recursion / work | 128 levels / 10 million analysis steps |

Linear-memory caps exclude JavaScript, browser overhead, and transient static-asset buffers. One worker avoids multiplying full analyzer instances by reported CPU count. Input admission covers file reading, expansion, and commit; overlapping imports reject explicitly while existing selections remain intact. Archive operations use at most one separate utility worker, load no WASM, and reject overlapping archive work. Cancellation and deadlines terminate synchronous WASM and recreate the worker on the next request. Epochs and job IDs discard stale results. Completed files survive another file's rejection or cancellation.

Unsafe archive paths, links, encryption, ZIP64, multivolume archives, unsupported compression, malformed headers, CRC mismatches, and excessive expansion reject explicitly. Unicode and case collisions receive deterministic distinct output paths. Export allows 4 MiB per file, 32 MiB total, and 34 MiB ZIP bytes; a maximum-size export need not fit the stricter reimport limits. For a ZIP larger than 2 MiB, use the ZIP or file-selection control rather than folder drag and drop.

## Development and acceptance

Visitors need only a browser. Contributors need Node 24.20.0, npm, Python 3.12, Rust with the `wasm32-unknown-unknown` target, wasm-bindgen CLI 0.2.130, Emscripten 4.0.23, and the pinned Luau checkout. Tool identities are in `browser-toolchain.lock.json`, `Cargo.lock`, `web/package-lock.json`, and `upstream.profiles.lock.json`.

```sh
npm ci --prefix web --ignore-scripts --no-audit --no-fund
cargo fetch --locked --target wasm32-unknown-unknown
python scripts/build-browser.py --emxx /path/to/emsdk/upstream/emscripten/em++
npm run --prefix web test:unit
node web/node_modules/playwright/cli.js install chromium
node scripts/test-browser.mjs
```

The last command owns browser acceptance against `web/out` on the real `/luau-decompiler/` subpath. It serves only static files and observes requests from all browser origins while verifying bytecode and source processing, genuine strict rejection, native source/quality agreement, controlled typed behavioral comparisons, no processing transport, exports, hierarchy, cancellation, worker recovery, and missing/corrupt assets. Native comparison additionally needs the native CLI and pinned compiler/VM test tools. `LUAU_BROWSER_NATIVE_CLI`, `LUAU_BROWSER_COMPILER`, and `LUAU_BROWSER_ORACLE` select those existing tools; they are test dependencies, not browser runtime dependencies.

`python scripts/build-browser.py --frontend-only` rebuilds presentation without rerunning native semantic gates. `--assets-only` assembles the shared engines and worker; `--analyzer-only` builds the pinned C++ analyzer. `--frontend-only` and `--skip-rust` reject missing stamps, changed shared engine inputs, or altered compiled assets; rebuild the engines instead of relabeling an old binary. The static export contains integrity manifests and runtime notices derived from shipped Rust, C++, definitions, and client dependency closures. Asset hashes, schema, engine version, and deployment identity are checked before WASM initialization to prevent mixed releases.

Runtime attribution is required: missing or empty Rust standard-library copyright or any of the six pinned Emscripten runtime notices fails packaging. The tested Rust documentation layouts are `share/doc/rust/COPYRIGHT-library.html` and `share/doc/rust/html/COPYRIGHT-library.html`. Notice-only fixes can use `python scripts/build-browser.py --refresh-notices` followed by `node scripts/test-browser.mjs --packaging-only`. This preserves the original full browser report and its accepted manifest, verifies every nonnotice asset remains byte-identical, checks the actual static page and complete required notice bodies, and records explicit reuse alongside the new package evidence. Runtime or frontend changes require the full browser gate.

Historical rc.3 local acceptance used Chromium 143.0.7499.4 on Windows and had no Linux runner. A resized desktop viewport does not establish Android/iOS compatibility. Firefox, Safari, and mobile operating systems remain untested. Browser samples and linear-memory measurements are separate from native throughput and process-memory results. The rc.4 native Linux runtime and container CI job has since [passed](https://github.com/zionqyl/luau-decompiler/actions/runs/43271305691/job/131368239885) on Ubuntu 24.04; this does not substitute for the separate browser build, static-export acceptance, or deployed-origin checks.

Architecture references: [Next.js static export](https://nextjs.org/docs/app/guides/static-exports), [GitHub Pages custom workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

## Prepared analyzer and workspace state

Each processing worker owns one persistent C++ analyzer context. Initialization loads and checks the pinned Roblox definitions once. Compatible requests reuse immutable global definitions while clearing the previous document, module graphs, resolver sources, path mappings, missing dependencies, and statistics. Changed contract bytes rebuild the context; faults and supervisor replacement discard it. Alternating projects and contracts are checked independently. No strict-success result is reused across changed input, final source, contracts, or project context.

The first request includes cold asset/module/definition initialization. Warm processing reports reconstruction, inference, formatting, compiler, analyzer, and end-to-end observations separately. Timing frames and explicit cache-disabled settings make environment reuse distinguishable from result caching. Native workers keep their independent bounded parallelism. The non-pthread browser baseline still uses one processing worker.

Workspace admission includes results outside the current selection. Replacing or clearing an outcome releases its accounted source and structured-result allocation; admission checks all retained source, faithful baselines, and structured failures before committing a result. Public showcase previews have a separate 2 MiB source limit and a 4 MiB index limit. Linear memory, logical retained-byte accounting, transient JavaScript allocations, and total browser RSS are different quantities.

The browser object cache binds source, compiler flags, pinned upstream revision, and the complete relevant upstream header/inline dependency closure. A header-only change invalidates objects and asset assembly. Engine source stamps and final static-asset hashes still prevent a stale engine from being relabeled as a new release.

The MM2 panel fetches a lightweight generated index and selected owner-authorized client-script outputs on demand. It preserves generated bytes, original hierarchy, explicit per-file generation quality, and the canonical header. Unrelated Roblox engine code and uncertain dependencies are excluded. The full corpus manifest retains failures and denominators; a showcase without original sources is not behavioral-equivalence evidence. Publication and current counts are in the [client corpus guide](client-corpus.md).

Maintained TypeScript, TSX, worker code, and browser test sources use pinned Prettier through `npm run --prefix web format` and `format:check`. The static build owns the formatting check. Browser tests have their own canonical owner; they do not rerun the native semantic gate for presentation changes.

## Rc.4 local acceptance

The final Windows Chromium 143.0.7499.4 static export passed 29 required acceptance groups and one separately labeled optional retained MM2 packet case. The required signed-container test uses the controlled Rust profile fixture layout and explicitly does not claim an authenticated native signature. The optional real script packet reconstructed the same source as the final native engine, compiled, and failed strict/meaningful typing for missing project context; it was never executed or given a verified badge. CI does not require private captures.

The gate includes workspace-wide source/structured admission across separate selections, preserved exclusions, changed contracts and modules, warm definition reuse, default automatic bytecode drops, unchanged-job avoidance, cancellation/timeout worker replacement, folder/ZIP hierarchy, exact exports, and missing/corrupt WASM diagnostics. Sixteen focused archive/supervisor/workspace/highlighting unit cases and 25 build/dependency/portable-identity/corpus-stamp cases passed. Three native/browser final-source and quality pairs and three owned LOBS/1 behavioral pairs agreed. Captured game code was not executed.

The export contains 348 files totaling 16,303,568 bytes, including 297 owner-authorized physical MM2 outputs loaded on demand. Its Pages ZIP is 3,574,451 bytes; its independent evidence ZIP is 367,275 bytes. The engine source identity begins `8fd45a85`, the asset identity is `51c298465264bf3c3bc570cc`, and the portable engine text identity begins `24928f42`. Raw build hashes remain separate; portable text identity normalizes only engine-source CRLF/LF for cross-platform generation compatibility, never submitted bytecode or source.

The final observed first bytecode drop took 1,852 ms including cold worker/definition preparation, strict validation, and UI result commit after page/fonts had loaded. A control interaction during the 84,034-byte, 6,000-assignment workload took 45 ms. These are local shared-host observations, not universal latency guarantees. Matched worker measurements and their cold/warm distinction are in the [performance guide](performance-rc.md). Network observation recorded 79 static-server GETs and 86 total browser requests including local blob modules, with no submitted content sent to a processing endpoint or another origin. SharedArrayBuffer remained unavailable and cross-origin isolation was false.

The browser evidence preserves earlier failed protocol/fixture-helper attempts alongside the final pass. No failed report was edited into success. The canonical published-origin mode requires the authenticated CI static-export manifest and checks served CI asset bytes, release version, and portable engine identity before the ordinary browser cases. The actual publication check below used an explicitly narrower served-runtime/source-commit boundary because anonymous CI-artifact downloads returned HTTP 401. Neither mode assumes Linux CI artifacts are byte-identical to the local Windows build.

## Rc.4 published acceptance

The [successful Pages workflow](https://github.com/zionqyl/luau-decompiler/actions/runs/43274086817) built and accepted the static export on Ubuntu 24.04, then deployed commit `b59857557e4135990623356feaf5bccb4b90050b`. A separate Windows Chromium 143.0.7499.4 run against the actual HTTPS repository subpath passed all 29 required groups and the optional retained packet case. The same maintained acceptance functions were reused; no additional decompiler or permissive verification path was introduced.

The deployed runtime identity is `3033f0aa2fa76a81fa70a6ef`; its manifest SHA-256 is `9554298d49462ab3c5c9b035539448fce37535ef31ef3b1e6e75ee2465ec000f`. All six served engine/analyzer/definition/worker assets matched that manifest. Declared engine-source file bytes matched the successful public CI commit, and portable engine identity matched the local final candidate (`24928f42...`). Linux raw source and binary hashes differ from the Windows build. The authenticated full CI-export manifest could not be downloaded anonymously; the published receipt proves observed runtime assets, source identity, and actual behavior of the UI, not a byte comparison of the entire CI archive.

All-origin observation recorded 86 requests: 80 same-origin static GETs and six local blob-module loads, with no processing endpoint, content upload, or page errors. SharedArrayBuffer was unavailable and cross-origin isolation was false. The first automatic bytecode drop took 1,826 ms after page/fonts loaded, including cold worker/definition preparation and genuine final-source strict validation. Three native/browser source-quality pairs and three controlled LOBS/1 behavioral pairs agreed. Captured game code was not executed. The separate published-browser evidence archive retains the actual served runtime closure, report, screenshots, and public workflow metadata; its scope does not replace the local Windows package receipt.

The initial Pages build failed before producing its analyzer manifest. An independently reproduced defect exported an empty `EM_CONFIG`, bypassing the modern SDK's embedded configuration. The corrected workflow verifies and exports the real pinned config and checks `em++ --version`; the next complete build and deployment passed. Signed-in logs from the first run were unavailable, so that earlier failure's exact traceback is not claimed as observed.

## Historical rc.3 acceptance

The final Windows Chromium 143.0.7499.4 export passed 23 acceptance groups, 13 archive/supervisor unit cases and four compile-stamp checks. Three representative native/browser source-quality pairs and three controlled typed behavioral pairs agreed. The trace contained 77 static GET requests and no processing requests; SharedArrayBuffer was undefined and cross-origin isolation was false. Missing/corrupt WASM, cancellation, timeout recreation, stale results, overlapping archives and concurrent import preservation were exercised.

The accepted export contains 49 files totaling 10,634,168 bytes; its Pages ZIP is 2,704,256 bytes. The separate 293,973-byte browser evidence ZIP and browser release index preserve manifests, actual outcomes and integrity records. Local samples measured 164 ms for page/fonts, 95 ms for worker initialization, 1,302 ms for bytecode, 1,032 ms for positive source and 2,352 ms for strict-negative recovery. These are small, local static-server samples taken during native-gate contention, not internet load-time or isolated throughput claims. Observed Rust/C++ linear memory was 5,898,240/48,365,568 bytes; it excludes JavaScript and browser process memory. A control interaction completed in 55 ms during analysis.

The historical rc.3 browser evidence and packages are separate from native correctness and performance reports. Earlier rc.3 artifacts were superseded after import/worker race corrections; only that release's final browser-release index identifies its accepted export. The rc.3 evidence did not include a published URL, offline reload, Firefox, Safari, or real mobile-device result.

The final notice refresh adds the required Rust standard-library notice and fails closed on missing/empty standard runtime notices. Sixteen focused build/notice cases passed. All 47 non-notice files match the original accepted export byte-for-byte, so the original 23-group functional report and its original manifest are retained unchanged in the evidence archive. A separate actual Chromium static check verified the updated notice documents. The current browser release index records this narrowly scoped reuse and the new package integrity; no earlier browser test was retimestamped.
