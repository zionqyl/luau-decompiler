import argparse
import concurrent.futures
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import shutil
import re
import time
import zipfile
import unicodedata

ROOT = pathlib.Path(__file__).resolve().parent.parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_identity():
    files = list((ROOT / "src").rglob("*.rs"))
    files.extend(ROOT / name for name in ("Cargo.toml", "Cargo.lock", "build.rs", "browser-toolchain.lock.json", "definitions.lock.json", "upstream.profiles.lock.json", "tests/analyzer_runner.cpp", "definitions/roblox.d.luau"))
    rows = [{"path": str(path.relative_to(ROOT)).replace("\\", "/"), "sha256": digest(path)} for path in sorted(set(files), key=lambda path:path.relative_to(ROOT).as_posix()) if path.is_file()]
    return {"sha256": hashlib.sha256(json.dumps(rows, sort_keys=True).encode()).hexdigest(), "files": rows}


def portable_engine_text_identity():
    rows = [{"path": row["path"], "sha256": hashlib.sha256((ROOT / row["path"]).read_bytes().replace(b"\r\n", b"\n")).hexdigest()} for row in source_identity()["files"]]
    return hashlib.sha256(json.dumps({"schema":1,"normalization":"engine text inputs: CRLF to LF; raw artifact identities remain separate","files":rows},sort_keys=True).encode()).hexdigest()


def checked_engine():
    location = ROOT / "artifacts/browser-build"
    path = location / "engine-manifest.json"
    if not path.is_file():
        raise RuntimeError("The engine has no source-identity build stamp; run a full browser build or --assets-only without --skip-rust")
    manifest = json.loads(path.read_text())
    if manifest["source_identity"] != source_identity():
        raise RuntimeError("Engine source changed since the stamped WASM build; rebuild Rust before frontend-only or --skip-rust assembly")
    for row in manifest["assets"]:
        asset = location / "engine" / row["name"]
        if not asset.is_file() or digest(asset) != row["sha256"]:
            raise RuntimeError("Stamped WASM engine asset changed: " + row["name"])
    return manifest


def compiler_command(compiler):
    if compiler.suffix == ".py":
        launcher = "import runpy,sys; sys.path.insert(0,sys.argv[1]); path=sys.argv.pop(2); sys.argv.pop(1); sys.argv[0]=path; runpy.run_path(path,run_name='__main__')"
        return [sys.executable, "-c", launcher, str(compiler.parent), str(compiler)]
    return [str(compiler)]


def analyzer_dependencies(upstream, revision):
    libraries = ("Common", "Ast", "Config", "Analysis", "Compiler", "Bytecode", "VM")
    files = sorted(path for library in libraries for path in (upstream / library).rglob("*") if path.is_file() and path.suffix in (".h", ".hpp", ".inc", ".inl", ".def"))
    rows = [{"path": path.relative_to(upstream).as_posix(), "sha256": digest(path)} for path in files]
    value = {"revision": revision, "headers": rows}
    return {"sha256": hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest(), **value}


def build_analyzer(args, lock):
    upstream = ROOT / "vendor/luau-modern"
    revision = subprocess.check_output(["git", "-C", str(upstream), "rev-parse", "HEAD"], text=True).strip()
    if revision != lock["analyzer_revision"]:
        raise RuntimeError("Analyzer upstream revision differs from browser-toolchain.lock.json")
    if subprocess.check_output(["git", "-C", str(upstream), "status", "--porcelain", "--untracked-files=no"], text=True).strip():
        raise RuntimeError("Analyzer upstream checkout has local modifications")
    compiler = pathlib.Path(args.emxx or os.environ.get("EMXX", ""))
    if not args.emxx and not os.environ.get("EMXX"):
        compiler = ROOT / ".tools/emsdk-4.0.23/upstream/install/emscripten/em++.py"
    compiler = compiler.resolve()
    if not compiler.is_file():
        raise RuntimeError("Pinned Emscripten is missing: install SDK4.0.23, then pass --emxx or set EMXX")
    environment = os.environ.copy()
    if compiler.suffix == ".py" and "EM_CONFIG" not in environment:
        install = compiler.parent.parent
        config = install / "emscripten_config.local"
        if config.is_file():
            environment["EM_CONFIG"] = str(config)
    command = compiler_command(compiler)
    version = subprocess.check_output(command + ["--version"], text=True, env=environment)
    if "4.0.23" not in version:
        raise RuntimeError("Expected pinned Emscripten4.0.23; received " + version.splitlines()[0])
    destination = ROOT / "artifacts/browser-build"
    objects = destination / "objects"
    objects.mkdir(parents=True, exist_ok=True)
    temporary = destination / "tmp"
    temporary.mkdir(exist_ok=True)
    for variable in ("TMP", "TEMP", "TMPDIR"):
        environment[variable] = str(temporary)
    libraries = ["Common", "Ast", "Config", "Analysis", "Compiler", "Bytecode", "VM"]
    includes = ["-I" + str(upstream / library / "include") for library in libraries]
    sources = sorted(path for library in libraries for path in (upstream / library / "src").glob("*.cpp"))
    sources.append(ROOT / "tests/analyzer_runner.cpp")
    flags = ["-std=c++17", "-O2", "-DNDEBUG", "-fexceptions", "-Wno-attributes"] + includes
    dependencies = analyzer_dependencies(upstream, revision)
    identity = hashlib.sha256((version + json.dumps(flags)).encode()).hexdigest()
    outputs = []
    tasks = []
    started = time.monotonic()

    def compile_source(source, output, stamp, expected):
        result = subprocess.run(command + flags + ["-c", str(source), "-o", str(output)], env=environment, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        output.with_suffix(".log").write_text(result.stdout, encoding="utf-8")
        if result.returncode:
            raise RuntimeError("Browser analyzer compilation failed: " + str(source) + "\n" + result.stdout)
        if digest(source) != expected["source"]:
            raise RuntimeError("Analyzer source changed during compilation")
        stamp.write_text(json.dumps(expected), encoding="utf-8")

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.threads) as executor:
        for source in sources:
            output = objects / (str(source.relative_to(ROOT)).replace("\\", "_").replace("/", "_") + ".o")
            outputs.append(output)
            stamp = output.with_suffix(".json")
            expected = {"source": digest(source), "compiler": identity, "dependencies": dependencies["sha256"]}
            if output.is_file() and stamp.is_file() and json.loads(stamp.read_text()) == expected:
                continue
            tasks.append(executor.submit(compile_source, source, output, stamp, expected))
        for index, task in enumerate(concurrent.futures.as_completed(tasks), 1):
            task.result()
            if index % 20 == 0:
                print("Analyzer objects", index, "/", len(tasks), flush=True)
    if dependencies != analyzer_dependencies(upstream, revision):
        raise RuntimeError("Analyzer headers changed during compilation")
    response = destination / "analyzer-link.rsp"
    response.write_text("\n".join(json.dumps(str(path)) for path in outputs), encoding="utf-8")
    output = destination / "luau-quality.mjs"
    link = ["-O2", "-fexceptions", "--no-entry", "-sMODULARIZE=1", "-sEXPORT_ES6=1", "-sENVIRONMENT=web,worker,node", "-sFILESYSTEM=0", "-sALLOW_MEMORY_GROWTH=1", "-sINITIAL_MEMORY=33554432", "-sMAXIMUM_MEMORY=536870912", "-sSTACK_SIZE=2097152", "-sABORTING_MALLOC=0", "-sDISABLE_EXCEPTION_CATCHING=0", "-sEXPORTED_FUNCTIONS=['_malloc','_free','_luau_quality_set_definitions','_luau_quality_validate','_luau_quality_result_length']", "-sEXPORTED_RUNTIME_METHODS=['UTF8ToString','HEAPU8']"]
    link_identity = hashlib.sha256((json.dumps(link) + "".join(digest(path) for path in outputs)).encode()).hexdigest()
    stamp = destination / "analyzer-link.json"
    if not output.is_file() or not stamp.is_file() or json.loads(stamp.read_text()).get("link") != link_identity:
        subprocess.run(command + ["@" + str(response)] + link + ["-o", str(output)], env=environment, check=True)
        stamp.write_text(json.dumps({"link": link_identity}), encoding="utf-8")
    result = {"schema": 1, "analyzer_revision": revision, "dependencies": dependencies, "source_sha256": digest(ROOT / "tests/analyzer_runner.cpp"), "emscripten": version.splitlines()[0], "pthread": False, "maximum_linear_memory_bytes": lock["analyzer_memory_limit_bytes"], "elapsed_seconds": time.monotonic() - started, "files": [{"name": path.name, "bytes": path.stat().st_size, "sha256": digest(path)} for path in [output, output.with_suffix(".wasm")]]}
    (destination / "analyzer-manifest.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))


def prepare_assets():
    engine = checked_engine()
    subprocess.run(["node", str(ROOT / "web/bundle-worker.mjs")], cwd=ROOT, check=True)
    version = re.search(r'^version\s*=\s*"([^\"]+)"', (ROOT / "Cargo.toml").read_text(), re.MULTILINE).group(1)
    location = ROOT / "artifacts/browser-build"
    analyzer = json.loads((location / "analyzer-manifest.json").read_text())
    if analyzer["source_sha256"] != digest(ROOT / "tests/analyzer_runner.cpp"):
        raise RuntimeError("C++ analyzer source changed since its WASM build; rebuild the analyzer")
    lock = json.loads((ROOT / "browser-toolchain.lock.json").read_text())
    if analyzer.get("dependencies") != analyzer_dependencies(ROOT / "vendor/luau-modern", lock["analyzer_revision"]):
        raise RuntimeError("C++ analyzer upstream/header dependencies changed; rebuild the analyzer")
    for row in analyzer["files"]:
        if digest(location / row["name"]) != row["sha256"]:
            raise RuntimeError("Stamped analyzer WASM asset changed: " + row["name"])
    definitions = ROOT / "definitions/roblox.d.luau"
    definition_lock = json.loads((ROOT / "definitions.lock.json").read_text())
    if digest(definitions) != definition_lock["sha256"]:
        raise RuntimeError("Pinned Roblox definitions differ from their lock")
    inputs = {"engine_module": location / "engine/luau_engine.js", "engine_wasm": location / "engine/luau_engine_bg.wasm", "analyzer_module": location / "luau-quality.mjs", "analyzer_wasm": location / "luau-quality.wasm", "definitions": definitions, "worker": location / "worker.mjs"}
    if any(not path.is_file() for path in inputs.values()):
        raise RuntimeError("Browser engine/analyzer/worker assets are missing; complete their builds first")
    core = {"schema": 1, "engine_version": version, "source_identity": engine["source_identity"], "analyzer_revision": analyzer["analyzer_revision"], "analyzer_source_sha256": analyzer["source_sha256"], "definitions_sha256": digest(definitions), "assets": {key: {"sha256": digest(path), "bytes": path.stat().st_size} for key, path in inputs.items()}}
    asset_id = hashlib.sha256(json.dumps(core, sort_keys=True).encode()).hexdigest()[:24]
    public = ROOT / "web/public/runtime"
    destination = public / asset_id
    destination.mkdir(parents=True, exist_ok=True)
    for key, path in inputs.items():
        name = "roblox.d.luau" if key == "definitions" else path.name
        shutil.copyfile(path, destination / name)
        core["assets"][key]["path"] = asset_id + "/" + name
    core["asset_id"] = asset_id
    core["limits"] = {"files": 64, "input_bytes_per_file": 2 * 1024 * 1024, "input_bytes_total": 32 * 1024 * 1024, "output_bytes_per_file": 4 * 1024 * 1024, "output_bytes_total": 16 * 1024 * 1024, "archive_bytes": 16 * 1024 * 1024, "archive_expanded_bytes": 32 * 1024 * 1024, "queue": 64, "workers": 1, "engine_linear_max_bytes": 268435456, "analyzer_linear_max_bytes": 536870912, "deadline_max_ms": 120000}
    (public / "manifest.json").write_text(json.dumps(core, indent=2) + "\n", encoding="utf-8")
    generated = ROOT / "web/generated"
    generated.mkdir(exist_ok=True)
    (generated / "version.json").write_text(json.dumps({"schema": 1, "version": version, "asset_id": asset_id}) + "\n", encoding="utf-8")
    print("Browser assets", asset_id)
    return core


def build_rust():
    identity = source_identity()
    environment = os.environ.copy()
    local = ROOT / ".tools/cargo/bin"
    if local.is_dir():
        environment["PATH"] = str(local) + os.pathsep + environment.get("PATH", "")
        environment["RUSTUP_HOME"] = str(ROOT / ".tools/rustup")
        environment["CARGO_HOME"] = str(ROOT / ".tools/cargo")
    environment["RUSTFLAGS"] = "-C link-arg=--max-memory=268435456"
    subprocess.run([str(local / "cargo.exe") if (local / "cargo.exe").is_file() else "cargo", "build", "--offline", "--locked", "--release", "--lib", "--target", "wasm32-unknown-unknown"], cwd=ROOT, env=environment, check=True)
    bindgen = os.environ.get("WASM_BINDGEN") or str(ROOT / ".tools/wasm-bindgen" / ("wasm-bindgen.exe" if os.name == "nt" else "wasm-bindgen"))
    if not pathlib.Path(bindgen).is_file():
        bindgen = shutil.which("wasm-bindgen") or bindgen
    if "0.2.130" not in subprocess.check_output([bindgen, "--version"], text=True):
        raise RuntimeError("Expected wasm-bindgen-cli0.2.130")
    output = ROOT / "artifacts/browser-build/engine"
    output.mkdir(parents=True, exist_ok=True)
    subprocess.run([bindgen, "--target", "web", "--out-name", "luau_engine", "--out-dir", str(output), str(ROOT / "target/wasm32-unknown-unknown/release/luau_decompiler.wasm")], check=True)
    if identity != source_identity():
        raise RuntimeError("Engine source changed while compiling WASM; do not publish the mixed build")
    compiler = str(local / "rustc.exe") if (local / "rustc.exe").is_file() else "rustc"
    manifest = {"schema":1,"source_identity":identity,"rustc":subprocess.check_output([compiler,"-vV"],env=environment,text=True).strip(),"wasm_bindgen":subprocess.check_output([bindgen,"--version"],text=True).strip(),"rustflags":environment["RUSTFLAGS"],"target":"wasm32-unknown-unknown","assets":[{"name":path.name,"bytes":path.stat().st_size,"sha256":digest(path)} for path in (output / "luau_engine.js",output / "luau_engine_bg.wasm")]}
    (output.parent / "engine-manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")


def required_notice(path, component):
    if not path.is_file() or path.stat().st_size == 0:
        raise RuntimeError("Required " + component + " notice is missing or empty: " + str(path))
    return path


def rust_runtime_notice(sysroot):
    candidates = [sysroot / "share/doc/rust/COPYRIGHT-library.html", sysroot / "share/doc/rust/html/COPYRIGHT-library.html"]
    for path in candidates:
        if path.is_file():
            return required_notice(path, "Rust standard library")
    raise RuntimeError("Required Rust standard library notice was not found in the active sysroot: " + str(sysroot))


def emscripten_runtime_notices(sdk):
    return [required_notice(sdk / path, "Emscripten " + path) for path in ("LICENSE", "system/lib/libcxx/LICENSE.TXT", "system/lib/libcxxabi/LICENSE.TXT", "system/lib/libunwind/LICENSE.TXT", "system/lib/compiler-rt/LICENSE.TXT", "system/lib/libc/musl/COPYRIGHT")]


def supplemental_assets(manifest):
    directory = ROOT / "web/public/runtime" / manifest["asset_id"]
    compiler = os.environ.get("EMXX") or shutil.which("em++")
    sdk = pathlib.Path(compiler).resolve().parent if compiler else ROOT / ".tools/emsdk-4.0.23/upstream/install/emscripten"
    notices = [ROOT / "LICENSE", ROOT / "vendor/luau-modern/LICENSE.txt", ROOT / "vendor/luau-modern/lua_LICENSE.txt", ROOT / "definitions/LICENSE-luau-lsp"]
    for package in ("next", "react", "react-dom", "geist", "fflate"):
        folder = ROOT / "web/node_modules" / package
        notices.extend(path for path in folder.iterdir() if path.is_file() and path.name.upper() in ("LICENSE", "LICENSE.TXT", "LICENSE.MD", "COPYRIGHT", "NOTICE"))
    closure = ROOT / "artifacts/browser-build/frontend-runtime-closure.json"
    if closure.is_file():
        for resource in json.loads(closure.read_text())["resources"]:
            path = pathlib.Path(resource)
            package_root = ROOT / "web/node_modules"
            if not path.is_relative_to(package_root):
                continue
            for folder in path.parents:
                if folder == package_root:
                    break
                notices.extend(candidate for candidate in folder.iterdir() if candidate.is_file() and candidate.name.upper() in ("LICENSE", "LICENSE.TXT", "LICENSE.MD", "COPYRIGHT", "NOTICE"))
    sdk_notices = emscripten_runtime_notices(sdk)
    notices.extend(sdk_notices)
    environment = os.environ.copy()
    local = ROOT / ".tools/cargo/bin"
    if local.is_dir():
        environment["PATH"] = str(local) + os.pathsep + environment.get("PATH", "")
        environment["RUSTUP_HOME"] = str(ROOT / ".tools/rustup")
        environment["CARGO_HOME"] = str(ROOT / ".tools/cargo")
    metadata = json.loads(subprocess.check_output([str(local / "cargo.exe") if (local / "cargo.exe").is_file() else "cargo", "metadata", "--offline", "--locked", "--format-version", "1", "--filter-platform", "wasm32-unknown-unknown"], cwd=ROOT, env=environment, text=True))
    nodes = {node["id"]:node for node in metadata["resolve"]["nodes"]}
    packages = {package["id"]:package for package in metadata["packages"]}
    pending, seen = [metadata["resolve"]["root"]], set()
    while pending:
        identity = pending.pop()
        if identity in seen:
            continue
        seen.add(identity)
        pending.extend(nodes[identity]["dependencies"])
        if identity == metadata["resolve"]["root"]:
            continue
        folder = pathlib.Path(packages[identity]["manifest_path"]).parent
        notices.extend(path for path in folder.iterdir() if path.is_file() and ("LICENSE" in path.name.upper() or path.name.upper() in ("COPYRIGHT", "NOTICE")))
    sysroot = pathlib.Path(subprocess.check_output([str(local / "rustc.exe") if (local / "rustc.exe").is_file() else "rustc", "--print", "sysroot"], env=environment, text=True).strip())
    standard = rust_runtime_notice(sysroot)
    notices.append(standard)
    rendered = []
    identities = []
    for index, path in enumerate(dict.fromkeys(notices)):
        label = str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else path.parent.name + "/" + path.name
        identities.append({"label": label.replace("\\", "/"), "sha256": digest(path), "bytes": path.stat().st_size})
        rendered.append("\n" + label.replace("\\", "/") + "\n" + "=" * 60 + "\n" + path.read_text(encoding="utf-8", errors="strict"))
    (directory / "licenses.txt").write_text("Luau Decompiler runtime notices\n" + "".join(rendered), encoding="utf-8", newline="\n")
    def identity(path):
        label = str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else path.parent.name + "/" + path.name
        body = path.read_text(encoding="utf-8").encode("utf-8")
        return {"label":label.replace("\\", "/"),"sha256":digest(path),"bytes":path.stat().st_size,"rendered_sha256":hashlib.sha256(body).hexdigest(),"rendered_bytes":len(body)}
    (directory / "licenses-manifest.json").write_text(json.dumps({"schema":1, "scope":"Actual wasm32 Cargo dependency closure, linked standard runtimes, shipped Luau/definitions, and known frontend/worker runtime packages; unrelated package caches excluded", "required_notices":{"rust_standard_library":identity(standard),"emscripten":list(map(identity,sdk_notices))},"files":identities}, indent=2) + "\n", encoding="utf-8")
    examples = ROOT / "web/public/examples"
    examples.mkdir(parents=True, exist_ok=True)
    bytecode = ROOT / "fixtures/runtime/verified.bc"
    shutil.copyfile(bytecode, examples / "verified.bc")
    entries = [{"path":"examples/verified.bc","bytes":bytecode.stat().st_size,"sha256":digest(bytecode)}]
    generated = ROOT / "examples/typed-output/player_snapshot.luau"
    if not generated.is_file() or ("Luau Decompiler " + manifest["engine_version"]) not in generated.read_text(encoding="utf-8"):
        raise RuntimeError("Generate the matching owned PlayerSnapshot example with the final native executable before packaging browser assets")
    shutil.copyfile(generated, examples / generated.name)
    entries.append({"path":"examples/"+generated.name,"bytes":generated.stat().st_size,"sha256":digest(generated),"origin":"Generated owned known-source example; declared Player parameter and pinned Roblox definitions"})
    (examples / "manifest.json").write_text(json.dumps({"schema":1,"engine_version":manifest["engine_version"],"scope":"Owned known-source fixtures only; no third-party game code", "entries":entries},indent=2)+"\n",encoding="utf-8")
    prepare_showcase(examples, manifest["engine_version"])


def prepare_showcase(destination, version):
    root = ROOT / "examples/Murder Mystery 2"
    manifest_path = root / "manifest.json"
    target = (destination / "Murder Mystery 2").resolve()
    if not target.is_relative_to(destination.resolve()) or not destination.resolve().is_relative_to((ROOT / "web/public/examples").resolve()):
        raise RuntimeError("Generated showcase path escaped its owned asset directory")
    if target.is_dir():
        shutil.rmtree(target)
    index = {"schema":1,"engine_version":version,"game":"Murder Mystery 2","status":"not_available","entries":[],"scope":"No matching current-generation public corpus is present"}
    if manifest_path.is_file():
        if manifest_path.stat().st_size > 8 * 1024 * 1024:
            raise RuntimeError("Public showcase manifest exceeds8 MiB")
        corpus = json.loads(manifest_path.read_text(encoding="utf-8"))
        if corpus["release"] != version or not corpus["rights"].get("permission"):
            raise RuntimeError("Public showcase rights or generation differ from this release")
        total = 0
        paths = set()
        generations = {generation["identity"]:generation for generation in corpus["generations"]}
        identity = portable_engine_text_identity()
        target.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(manifest_path, target / "manifest.json")
        for row in corpus["files"]:
            path = row.get("output_path")
            if not path:
                continue
            generation = generations.get(row.get("generation"))
            if not generation or generation.get("engine_version") != version or generation.get("portable_engine_text_sha256") != identity:
                raise RuntimeError("Public showcase engine text identity differs from this release; regenerate its manifest from matching processing provenance")
            relative = pathlib.PurePosixPath(path)
            if relative.is_absolute() or any(part in (".", "..", "") or "\\" in part or ":" in part for part in path.split("/")):
                raise RuntimeError("Unsafe public showcase path")
            key = unicodedata.normalize("NFKC", path).upper()
            if key in paths:
                raise RuntimeError("Colliding public showcase paths")
            paths.add(key)
            source = (root / pathlib.Path(*relative.parts)).resolve()
            if not source.is_relative_to(root.resolve()) or not source.is_file():
                raise RuntimeError("Public showcase source is missing or outside its corpus")
            size = source.stat().st_size
            total += size
            if len(index["entries"]) >= 1024 or size > 2 * 1024 * 1024 or total > 64 * 1024 * 1024:
                raise RuntimeError("Public showcase exceeds its bounded static preview capacity")
            if digest(source) != row["source_sha256"] or not row["complete"] or ("Luau Decompiler " + version) not in source.read_text(encoding="utf-8"):
                raise RuntimeError("Public showcase source differs from its finalized generation")
            output = target / pathlib.Path(*relative.parts)
            output.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, output)
            validation = row.get("validation") or {}
            index["entries"].append({"path":"examples/Murder Mystery 2/"+path,"bytes":size,"sha256":row["source_sha256"],"class":row["class"],"strict_analysis":validation.get("strict_analysis","not_run"),"required_passed":validation.get("required_passed",False)})
        index.update({"status":"available","scope":"Owner-authorized MM2 client-accessible outputs only; unrelated Roblox engine/dependency content excluded; this is not the complete game","rights":corpus["rights"],"coverage":corpus["coverage"],"snapshot":corpus["snapshot"],"manifest_sha256":digest(manifest_path),"generations":corpus["generations"]})
    (destination / "mm2-showcase.json").write_text(json.dumps(index,indent=2)+"\n",encoding="utf-8")


def build_frontend():
    checked_engine()
    node = "npm.cmd" if os.name == "nt" else "npm"
    environment = os.environ.copy()
    environment["NEXT_TELEMETRY_DISABLED"] = "1"
    subprocess.run([node, "run", "format:check"], cwd=ROOT / "web", env=environment, check=True)
    subprocess.run([node, "run", "typecheck"], cwd=ROOT / "web", env=environment, check=True)
    subprocess.run([node, "run", "build"], cwd=ROOT / "web", env=environment, check=True)
    output = ROOT / "web/out"
    (output / ".nojekyll").write_text("")
    runtime = output / "runtime"
    current = json.loads((runtime / "manifest.json").read_text())["asset_id"]
    if json.loads((runtime / "manifest.json").read_text())["source_identity"] != checked_engine()["source_identity"]:
        raise RuntimeError("Public engine manifest differs from its compiled source identity; rebuild browser assets")
    supplemental_assets(json.loads((runtime / "manifest.json").read_text()))
    for name in ("licenses.txt", "licenses-manifest.json"):
        shutil.copyfile(ROOT / "web/public/runtime" / current / name, runtime / current / name)
    for child in runtime.iterdir():
        if child.is_dir() and re.fullmatch(r"[a-f0-9]{24}",child.name) and child.name != current:
            checked=child.resolve()
            if not checked.is_relative_to(output.resolve()):
                raise RuntimeError("Generated export cleanup escaped its output directory")
            shutil.rmtree(checked)
    write_static_manifest(output)


def write_static_manifest(output):
    files = sorted(path for path in output.rglob("*") if path.is_file())
    frontend = []
    for folder in ("app", "components", "lib", "worker"):
        frontend.extend((ROOT / "web" / folder).rglob("*"))
    frontend.extend(ROOT / path for path in ("web/package.json", "web/package-lock.json", "web/.prettierrc.json", "web/next.config.mjs", "web/tsconfig.json", "web/bundle-worker.mjs", "scripts/build-browser.py", "browser-toolchain.lock.json"))
    source_rows = [{"path":str(path.relative_to(ROOT)).replace("\\", "/"),"sha256":digest(path)} for path in sorted(set(frontend),key=lambda path:path.relative_to(ROOT).as_posix()) if path.is_file()]
    report = {"schema":1,"engine_version":re.search(r'^version\s*=\s*"([^\"]+)"',(ROOT / "Cargo.toml").read_text(),re.MULTILINE).group(1),"engine_source_identity":source_identity(),"browser_source_identity":{"sha256":hashlib.sha256(json.dumps(source_rows,sort_keys=True).encode()).hexdigest(),"files":source_rows},"static_export":True,"base_path":"/luau-decompiler/","processing_backend":False,"files":len(files),"total_bytes":sum(path.stat().st_size for path in files),"assets":[{"path":str(path.relative_to(output)).replace("\\","/"),"bytes":path.stat().st_size,"sha256":digest(path)} for path in files]}
    report["portable_engine_text_sha256"] = portable_engine_text_identity()
    (ROOT / "artifacts/browser-build/static-export-manifest.json").write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print("Static export",report["files"],"files",report["total_bytes"],"bytes")


def refresh_notices():
    checked_engine()
    output = ROOT / "web/out"
    manifest_path = ROOT / "artifacts/browser-build/static-export-manifest.json"
    gate_path = ROOT / "artifacts/browser-tests/export.json"
    gate = json.loads(gate_path.read_text())
    accepted_path = ROOT / "artifacts/browser-tests/runtime-gate-manifest.json"
    if digest(manifest_path) == gate["static_export_manifest_sha256"]:
        shutil.copyfile(manifest_path, accepted_path)
    if not gate["passed"] or not accepted_path.is_file() or digest(accepted_path) != gate["static_export_manifest_sha256"]:
        raise RuntimeError("Notice refresh requires the original successful browser gate and its exact accepted static manifest")
    accepted = json.loads(accepted_path.read_text())
    if accepted["engine_source_identity"] != checked_engine()["source_identity"]:
        raise RuntimeError("The shared engine changed; run the full browser gate instead of reusing notice-only evidence")
    runtime = json.loads((output / "runtime/manifest.json").read_text())
    changed = {"runtime/" + runtime["asset_id"] + "/licenses.txt", "runtime/" + runtime["asset_id"] + "/licenses-manifest.json"}
    for row in accepted["assets"]:
        if row["path"] not in changed and digest(output / row["path"]) != row["sha256"]:
            raise RuntimeError("Runtime asset changed; full browser acceptance is required: " + row["path"])
    supplemental_assets(runtime)
    for name in ("licenses.txt", "licenses-manifest.json"):
        shutil.copyfile(ROOT / "web/public/runtime" / runtime["asset_id"] / name, output / "runtime" / runtime["asset_id"] / name)
    write_static_manifest(output)
    current = json.loads(manifest_path.read_text())
    before = {row["path"]:row for row in accepted["assets"]}
    after = {row["path"]:row for row in current["assets"]}
    if set(before) != set(after) or any(before[path] != after[path] for path in before if path not in changed):
        raise RuntimeError("Notice refresh changed the runtime closure; full browser acceptance is required")
    old_sources = {row["path"]:row["sha256"] for row in accepted["browser_source_identity"]["files"]}
    deltas = [dict(row, previous_sha256=old_sources.get(row["path"])) for row in current["browser_source_identity"]["files"] if old_sources.get(row["path"]) != row["sha256"]]
    if any(row["path"] != "scripts/build-browser.py" for row in deltas):
        raise RuntimeError("Frontend processing inputs changed; rebuild and run browser acceptance instead of notice-only refresh")
    report = {"schema":1,"passed":True,"scope":"Notice-only package refresh; original runtime acceptance remains unmodified and is reused only for byte-identical nonnotice assets","original_acceptance_sha256":digest(gate_path),"original_static_export_manifest_sha256":digest(accepted_path),"current_static_export_manifest_sha256":digest(manifest_path),"unchanged_runtime_assets":len(before)-len(changed),"reused_runtime_cases":len(gate["cases"]),"source_deltas":deltas,"changed_assets":[{"path":path,"before":before[path],"after":after[path]} for path in sorted(changed)]}
    (ROOT / "artifacts/browser-tests/notice-refresh.json").write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")


def verify_package(path):
    archive = pathlib.Path(path).resolve()
    if not archive.is_relative_to((ROOT / "dist").resolve()):
        raise RuntimeError("Browser package verification expects a release archive under dist")
    manifest_path = ROOT / "artifacts/browser-build/static-export-manifest.json"
    manifest = json.loads(manifest_path.read_text())
    expected = {row["path"]: row for row in manifest["assets"]}
    if len(expected) > 1024 or manifest["total_bytes"] > 128 * 1024 * 1024:
        raise RuntimeError("Static export exceeds the package verification bound")
    with zipfile.ZipFile(archive) as bundle:
        names = bundle.namelist()
        if len(names) != len(expected) or set(names) != set(expected):
            raise RuntimeError("Static archive has missing, duplicate, or unexpected entries")
        for name, row in expected.items():
            contents = bundle.read(name)
            if len(contents) != row["bytes"] or hashlib.sha256(contents).hexdigest() != row["sha256"]:
                raise RuntimeError("Static archive differs from the accepted export: " + name)
    report = {"schema": 1, "passed": True, "package": archive.name, "sha256": digest(archive), "files": len(expected), "unpacked_bytes": manifest["total_bytes"], "independent_reader": "Python3.12 zipfile CRC and SHA256 versus accepted static-export manifest", "static_export_manifest_sha256": digest(manifest_path)}
    (ROOT / "artifacts/browser-tests/package.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--emxx")
    parser.add_argument("--threads", type=int, default=2, choices=range(1, 5))
    stages = parser.add_mutually_exclusive_group()
    stages.add_argument("--analyzer-only", action="store_true")
    stages.add_argument("--assets-only", action="store_true")
    stages.add_argument("--frontend-only", action="store_true")
    stages.add_argument("--verify-package")
    stages.add_argument("--refresh-notices", action="store_true")
    parser.add_argument("--skip-rust",action="store_true")
    args = parser.parse_args()
    if args.verify_package:
        verify_package(args.verify_package)
        return
    if args.refresh_notices:
        refresh_notices()
        return
    lock = json.loads((ROOT / "browser-toolchain.lock.json").read_text())
    if args.frontend_only:
        build_frontend()
        return
    if not args.assets_only:
        build_analyzer(args, lock)
    if not args.analyzer_only:
        if not args.skip_rust:
            build_rust()
        manifest = prepare_assets()
        supplemental_assets(manifest)
        if not args.assets_only:
            build_frontend()


if __name__ == "__main__":
    main()
