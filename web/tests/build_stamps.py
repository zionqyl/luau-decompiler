import importlib.util
import json
import pathlib
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]


def rejected(operation, expected):
    try:
        operation()
    except RuntimeError as error:
        if expected not in str(error):
            raise AssertionError(str(error)) from error
        return str(error)
    raise AssertionError("Invalid build stamp was accepted")


def main():
    source = ROOT / "scripts/build-browser.py"
    specification = importlib.util.spec_from_file_location("browser_builder", source)
    builder = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(builder)
    checked = builder.checked_engine()
    rows = []
    try:
        with tempfile.TemporaryDirectory(dir=ROOT / "artifacts/browser-build") as directory:
            temporary = pathlib.Path(directory)
            if not temporary.resolve().is_relative_to((ROOT / "artifacts/browser-build").resolve()):
                raise RuntimeError("Temporary project escaped its workspace")
            (temporary / "src").mkdir()
            program = temporary / "src/lib.rs"
            program.write_text("pub fn value()->u32{1}")
            folder = temporary / "artifacts/browser-build/engine"
            folder.mkdir(parents=True)
            assets = []
            for name in ("luau_engine.js", "luau_engine_bg.wasm"):
                item = folder / name
                item.write_bytes(b"known-compiled-asset")
                assets.append({"name": name, "sha256": builder.digest(item)})
            builder.ROOT = temporary
            stamp = folder.parent / "engine-manifest.json"
            stamp.write_text(json.dumps({"source_identity": builder.source_identity(), "assets": assets}))
            builder.checked_engine()
            rows.append({"id": "matching_source_and_assets", "passed": True})
            program.write_text("pub fn value()->u32{2}")
            rows.append({"id": "stale_same_version_source_rejected", "passed": True, "diagnostic": rejected(builder.checked_engine, "Engine source changed")})
            program.write_text("pub fn value()->u32{1}")
            (folder / "luau_engine_bg.wasm").write_bytes(b"altered")
            rows.append({"id": "changed_compiled_asset_rejected", "passed": True, "diagnostic": rejected(builder.checked_engine, "Stamped WASM engine asset changed")})
            stamp.unlink()
            rows.append({"id": "missing_stamp_rejected", "passed": True, "diagnostic": rejected(builder.checked_engine, "no source-identity build stamp")})
            upstream = temporary / "upstream"
            header = upstream / "Analysis/include/Luau/Frontend.h"
            header.parent.mkdir(parents=True)
            header.write_text("first dependency")
            dependencies = builder.analyzer_dependencies(upstream, "first-revision")
            header.write_text("changed header with unchanged cpp")
            if dependencies == builder.analyzer_dependencies(upstream, "first-revision"):
                raise AssertionError("A header-only update reused the analyzer object identity")
            rows.append({"id":"header_only_upstream_change_invalidates_objects","passed":True})
            header.write_text("first dependency")
            if dependencies == builder.analyzer_dependencies(upstream, "second-revision"):
                raise AssertionError("A changed upstream revision reused the analyzer object identity")
            rows.append({"id":"upstream_revision_invalidates_objects","passed":True})
            (header.parent / "implementation.inl").write_text("additional dependency")
            if dependencies == builder.analyzer_dependencies(upstream, "first-revision"):
                raise AssertionError("An added inline dependency reused the analyzer object identity")
            rows.append({"id":"inline_dependency_invalidates_objects","passed":True})
            (temporary / "Cargo.toml").write_bytes(b"version='test'\n")
            (temporary / "browser-toolchain.lock.json").write_bytes(b"{}\n")
            names = [row["path"] for row in builder.source_identity()["files"]]
            if names != sorted(names):
                raise AssertionError("Engine source paths are not ordered ordinally across platforms")
            rows.append({"id":"platform_independent_source_path_order","passed":True})
            program.write_bytes(b"pub fn value()->u32{1}\n")
            raw = builder.source_identity()["sha256"]
            portable = builder.portable_engine_text_identity()
            program.write_bytes(b"pub fn value()->u32{1}\r\n")
            if raw == builder.source_identity()["sha256"] or portable != builder.portable_engine_text_identity():
                raise AssertionError("Portable text normalization weakened raw build identity or failed line-ending equivalence")
            rows.append({"id":"raw_identity_retained_beside_portable_line_endings","passed":True})
            program.write_bytes(b"pub fn value()->u32{2}\r\n")
            if portable == builder.portable_engine_text_identity():
                raise AssertionError("Portable identity accepted a changed implementation")
            rows.append({"id":"portable_text_identity_rejects_changed_code","passed":True})
            corpus = temporary / "examples/Murder Mystery 2"
            corpus.mkdir(parents=True)
            example = corpus / "StarterGui/Example.luau"
            example.parent.mkdir()
            example.write_bytes(b"--[=[\n    Luau Decompiler test\n    Made by @zionqyl\n    https://github.com/zionqyl/luau-decompiler\n]=]\n\nreturn 1\n")
            document = {"release":"test","rights":{"permission":"owned synthetic regression fixture"},"snapshot":"controlled-test","coverage":{},"generations":[{"identity":"test-generation","engine_version":"test","portable_engine_text_sha256":builder.portable_engine_text_identity()}],"files":[{"output_path":"StarterGui/Example.luau","generation":"test-generation","source_sha256":builder.digest(example),"complete":True,"class":"LocalScript","validation":{"strict_analysis":"not_run","required_passed":False}}]}
            destination=temporary / "web/public/examples"
            destination.mkdir(parents=True)
            manifest_path=corpus / "manifest.json"
            manifest_path.write_text(json.dumps(document))
            builder.prepare_showcase(destination,"test")
            if (destination / "Murder Mystery 2/StarterGui/Example.luau").read_bytes()!=example.read_bytes():
                raise AssertionError("Static showcase changed the finalized source bytes")
            rows.append({"id":"matching_corpus_generation_exact_source_copy","passed":True})
            document["generations"][0]["portable_engine_text_sha256"]="stale"
            manifest_path.write_text(json.dumps(document))
            rows.append({"id":"stale_same_version_corpus_generation_rejected","passed":True,"diagnostic":rejected(lambda:builder.prepare_showcase(destination,"test"),"engine text identity differs")})
            document["generations"][0]["portable_engine_text_sha256"]=builder.portable_engine_text_identity()
            example.write_bytes(b"changed source")
            manifest_path.write_text(json.dumps(document))
            rows.append({"id":"altered_finalized_corpus_source_rejected","passed":True,"diagnostic":rejected(lambda:builder.prepare_showcase(destination,"test"),"differs from its finalized generation")})
            sysroot = temporary / "sysroot"
            rows.append({"id":"missing_rust_standard_notice_rejected","passed":True,"diagnostic":rejected(lambda:builder.rust_runtime_notice(sysroot),"Required Rust standard library notice")})
            primary = sysroot / "share/doc/rust/COPYRIGHT-library.html"
            primary.parent.mkdir(parents=True)
            primary.write_text("active standard-library copyright")
            if builder.rust_runtime_notice(sysroot) != primary:
                raise AssertionError("The active Rust standard-library notice was not selected")
            rows.append({"id":"rust_documentation_root_notice_found","passed":True})
            primary.unlink()
            alternate = sysroot / "share/doc/rust/html/COPYRIGHT-library.html"
            alternate.parent.mkdir()
            alternate.write_text("alternate standard-library copyright")
            if builder.rust_runtime_notice(sysroot) != alternate:
                raise AssertionError("The alternate Rust documentation layout was not supported")
            rows.append({"id":"rust_alternate_html_notice_found","passed":True})
            alternate.write_text("")
            rows.append({"id":"empty_rust_standard_notice_rejected","passed":True,"diagnostic":rejected(lambda:builder.rust_runtime_notice(sysroot),"missing or empty")})
            sdk = temporary / "sdk"
            sdk_paths = [sdk / name for name in ("LICENSE","system/lib/libcxx/LICENSE.TXT","system/lib/libcxxabi/LICENSE.TXT","system/lib/libunwind/LICENSE.TXT","system/lib/compiler-rt/LICENSE.TXT","system/lib/libc/musl/COPYRIGHT")]
            for path in sdk_paths:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("required SDK runtime copyright")
            if builder.emscripten_runtime_notices(sdk) != sdk_paths:
                raise AssertionError("The complete SDK runtime attribution closure was not selected")
            rows.append({"id":"complete_emscripten_notice_closure_found","passed":True})
            for index, path in enumerate(sdk_paths):
                path.unlink()
                rows.append({"id":"missing_emscripten_notice_"+str(index)+"_rejected","passed":True,"diagnostic":rejected(lambda:builder.emscripten_runtime_notices(sdk),"missing or empty")})
                path.write_text("required SDK runtime copyright")
            sdk_paths[-1].write_text("")
            rows.append({"id":"empty_emscripten_notice_rejected","passed":True,"diagnostic":rejected(lambda:builder.emscripten_runtime_notices(sdk),"missing or empty")})
    finally:
        builder.ROOT = ROOT
    if builder.checked_engine() != checked:
        raise RuntimeError("Real engine assets changed during the isolated test")
    report = {"schema": 1, "passed": True, "scope": "Isolated temporary project; real sources, engine assets and runtime notices preserved", "build_script_sha256": builder.digest(source), "test_script_sha256": builder.digest(pathlib.Path(__file__)), "engine_source_identity": checked["source_identity"]["sha256"], "cases": rows}
    (ROOT / "artifacts/browser-build/stamp-checks.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
