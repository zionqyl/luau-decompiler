# Development

Rust 1.85 or later builds the Rust core. Cargo.lock fixes utility dependencies. Contributor validation additionally needs the pinned upstream Luau compilers, C++ toolchain, independent VM oracles, analyzer harness, Roblox definition snapshot and ripgrep for the source inventory. End-user bundles carry their runtime assets and do not need these development tools. Windows `scripts/setup.ps1` provisions the official ripgrep 14.1.1 archive with pinned archive and executable SHA-256 checks; `scripts/env.ps1` adds that local tool to the process PATH rather than relying on editor-installed tools.

Read root `AGENTS.md` and applicable nested instructions before editing. First-party implementation, adapters, tests and scripts contain no explanatory or documentation comments. Design rationale belongs in external documents. Functional directives, license notices, third-party upstream code and comment-like fixture data are preserved. `scripts/check-code-style.ps1` checks Rust/C++/Luau lexical comments and PowerShell parser comment tokens; its explicit `-Fix` mode preserves strings and fixture inputs.

```powershell
. ./scripts/env.ps1
cargo test --offline --locked --test source_inputs
./scripts/release.ps1
```

The full gate preserves the existing fixture identities, semantic matrices, typed oracle, negative tests, coverage-guided decoder campaign and source/tool provenance. New release cases are additive. Expected rejections are never successful reconstructions. Windows gate execution does not certify Linux or executor behavior.

Version `0.4.0-rc.4` is a release candidate. Pre-1.0 minor releases may add explicit public configuration fields or result variants; documented protocol fields and legacy bytecode APIs are retained when practical. Publication locations are explicit in `release.json`; a configured location is not evidence of a published release.

Unsafe allocation observers forward the exact original layout and pointer to the system allocator. Windows stack sampling writes only into fixed arrays using the supplied frame count. These test/profiling invariants remain external documentation; normal untrusted processing uses safe Rust.

Use focused affected tests during development. The release driver owns formatting, Clippy, ordinary tests and required ignored suites; do not precede it with the full validator for the same snapshot. `-PackageOnly` can reuse a gate only when all relevant identities still match. Final runtime acceptance runs at extraction, while installation ownership/update scenarios protect a separate boundary. See [validation ownership](validation.md).

Native Rust 1.85 is the declared minimum; the browser build uses its separately pinned Rust/WASM and Emscripten toolchains. Native thread pools and subprocess workers remain native-only; the browser baseline runs one sequential Rust engine and one analyzer in a worker without SharedArrayBuffer. [Browser development and acceptance](browser.md) has a separate owner from the native release gate.

The [recorded Linux CI boundary](hosting.md#evidence-boundary-for-this-candidate) passed on clean Ubuntu 24.04, including Rust 1.85, native correctness/package checks and direct container startup/restart/shutdown. The exact source and public native/container validation reports are linked in the hosting guide and release assets. Windows has its own full semantic gate and public installation evidence. Registry publication and anonymous pull also passed; successful distinct-image upgrades, actual Windows Docker bootstrap and HTTPS remain untested; the published Linux bootstrap base flow and rejected-update preservation passed six focused cases.
