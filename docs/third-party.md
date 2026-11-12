# Licenses and third-party material

First-party code is MIT licensed under the root LICENSE. Portable bundles retain the exact upstream license notices for Luau, its Lua-derived VM material, the pinned luau-lsp Roblox definition snapshot, utility crates, and the linked Rust runtime.

Luau compiler, VM and analyzer revisions are fixed by `upstream.lock.json`, `upstream.profiles.lock.json`, and `definitions.lock.json`. Upstream source and notices are not subject to the first-party no-comment policy. The Windows profiling runtime shim is derived from the licensed upstream LLVM runtime and retains its required attribution; its lock and license remain under `scripts/coverage-runtime`.

The Rust core implements decompilation and source processing itself. The independent pinned parser/compiler/analyzer and controlled VM oracle are validation tools, not imported decompiler implementations. The LLVM runtime is used only for contributor coverage instrumentation, not ordinary user processing.

Runtime attribution is selected from `cargo metadata --filter-platform` and its reachable dependency graph, including code-generating proc macros. Unrelated crates in a developer cache are excluded. Rust standard-library notices come from that sysroot's `COPYRIGHT-library.html`. The static Windows analyzer also ships pinned GCC 16.2 runtime/GPL exception and MinGW-w64 14/winpthreads notices from the [toolchain manifest](../licenses/toolchain/manifest.json). The bundled notice closure records exact package versions and filenames. SDK attribution remains at its required definition-lock path rather than a second duplicate notice copy.

Native runtime notices use the compact `licenses/` directory. Package manifests retain every file hash and original dependency identity. The shorter path also allows older installed updaters to extract the new payload within Windows path limits without removing notices.

The browser distribution additionally contains wasm-bindgen glue, the Emscripten runtime, Next.js/React, Geist fonts and fflate from pinned tool/package manifests. Browser builds must retain the corresponding package and tool notices; source packages do not license third-party captured game code under MIT. The owner-authorized MM2 showcase has separately recorded permission and scope. Original bytecode, unrelated engine content and uncertain dependencies remain private and excluded from public archives; see the [corpus rights and scope](client-corpus.md).
