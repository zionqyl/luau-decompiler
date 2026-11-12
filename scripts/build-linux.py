import argparse
import concurrent.futures
import hashlib
import json
import os
import pathlib
import platform
import shutil
import subprocess


def run(arguments, **kwargs):
    return subprocess.run(arguments, check=True, **kwargs)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fetch", action="store_true")
    parser.add_argument("--offline", action="store_true")
    parser.add_argument("--test-tools", action="store_true")
    parser.add_argument("--threads", type=int, default=2)
    parser.add_argument("--output", default="artifacts/linux-runtime")
    args = parser.parse_args()
    if platform.system() != "Linux" or platform.machine() not in ("x86_64", "AMD64") or not 1 <= args.threads <= 8:
        parser.error("this build requires Linux and 1..8 threads")
    root = pathlib.Path(__file__).resolve().parent.parent
    os.chdir(root)
    lock = json.loads((root / "upstream.profiles.lock.json").read_text())
    profile = next(item for item in lock["profiles"] if item["tag"] == "0.746")
    upstream = root / "vendor" / profile["directory"]
    if not upstream.exists():
        if not args.fetch or args.offline:
            parser.error("pinned vendor/luau-modern is missing; supply it or use --fetch")
        upstream.parent.mkdir(parents=True, exist_ok=True)
        run(["git", "init", str(upstream)])
        run(["git", "-C", str(upstream), "remote", "add", "origin", lock["repository"]])
        run(["git", "-C", str(upstream), "fetch", "--depth", "1", "origin", profile["revision"]])
        run(["git", "-C", str(upstream), "checkout", "--detach", "FETCH_HEAD"])
    actual = subprocess.check_output(["git", "-C", str(upstream), "rev-parse", "HEAD"], text=True).strip()
    dirty = subprocess.check_output(["git", "-C", str(upstream), "status", "--porcelain", "--untracked-files=no"], text=True)
    if actual != profile["revision"] or dirty:
        parser.error("pinned Luau checkout differs or contains tracked edits")
    definitions_lock = json.loads((root / "definitions.lock.json").read_text())
    definitions = root / definitions_lock["path"]
    if digest(definitions) != definitions_lock["sha256"]:
        parser.error("Roblox definitions differ from the lock")
    output = (root / args.output).resolve()
    if output.exists() and any(output.iterdir()):
        raise RuntimeError("choose an empty runtime output directory; existing artifacts are preserved")
    output.mkdir(parents=True, exist_ok=True)
    objects = root / "artifacts" / "linux-analyzer-objects"
    objects.mkdir(parents=True, exist_ok=True)
    compiler = os.environ.get("CXX", "g++")
    compiler_version = subprocess.check_output([compiler, "--version"], text=True).splitlines()[0]
    libraries = ["Common", "Ast", "Config", "Analysis", "Compiler", "Bytecode", "VM"]
    includes = ["-I" + str(upstream / library / "include") for library in libraries]
    sources = sorted(path for library in libraries for path in (upstream / library / "src").glob("*.cpp"))
    harness = root / "tests" / "analyzer_runner.cpp"
    sources.append(harness)
    hashes = {str(path.relative_to(root)): digest(path) for path in sources}

    def compile_source(path):
        target = objects / (str(path.relative_to(root)).replace("/", "_") + ".o")
        run([compiler, "-std=c++17", "-O1", "-DNDEBUG", "-Wno-attributes", *includes, "-c", str(path), "-o", str(target)])
        return target

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.threads) as executor:
        compiled = list(executor.map(compile_source, sources))
    binary_dir = output / "bin"
    binary_dir.mkdir(exist_ok=True)
    analyzer = binary_dir / "luau-quality"
    run([compiler, *map(str, compiled), "-pthread", "-o", str(analyzer)])
    if not subprocess.check_output([str(analyzer), "--version"], text=True).startswith("LQUAL/1 Luau0.746"):
        raise RuntimeError("unexpected analyzer protocol/version")
    if hashes != {str(path.relative_to(root)): digest(path) for path in sources}:
        raise RuntimeError("analyzer sources changed while building")
    manifest = {"protocol": "LQUAL/1", "upstream_revision": actual, "source_sha256": digest(harness),
                "binary_sha256": digest(analyzer), "compiler": compiler_version}
    analyzer.with_name(analyzer.name + ".manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    if args.test_tools:
        build = root / "artifacts" / "linux-luau-build"
        run(["cmake", "-S", str(upstream), "-B", str(build), "-DCMAKE_BUILD_TYPE=Release", "-DLUAU_BUILD_TESTS=OFF", "-DLUAU_BUILD_WEB=OFF"])
        run(["cmake", "--build", str(build), "--target", "Luau.Compile.CLI", "--parallel", str(args.threads)])
        test_tools = root / ".tools" / "luau-modern"
        test_tools.mkdir(parents=True, exist_ok=True)
        shutil.copy2(build / "luau-compile", test_tools)
        vm_sources = [path for path in sources if path.parent in [upstream / "VM" / "src", upstream / "Common" / "src"]]
        vm_objects = [compiled[sources.index(path)] for path in vm_sources]
        runner = test_tools / "vm-runner"
        vm_harness = root / "tests" / "vm_runner.cpp"
        run([compiler, "-std=c++17", "-O1", "-DNDEBUG", "-DLUAU_ORACLE_FASTPCALL_EVIDENCE", *includes,
             "-I" + str(upstream / "VM" / "src"), str(vm_harness), *map(str, vm_objects), "-pthread", "-o", str(runner)])
        if subprocess.check_output([str(runner), "--protocol-version"], text=True).strip() != "LOBS/1 LARG/1":
            raise RuntimeError("unexpected typed VM protocol")
        runner.with_name(runner.name + ".manifest.json").write_text(json.dumps({"protocol": "LOBS/1", "upstream_revision": actual,
            "runner_sha256": digest(runner), "harness_sha256": digest(vm_harness)}, indent=2) + "\n")
    cargo = ["cargo", "build", "--release", "--locked", "--bin", "luau-decompile"]
    if args.offline:
        cargo.append("--offline")
    run(cargo)
    shutil.copy2(root / "target" / "release" / "luau-decompile", binary_dir)
    layout = json.loads((root / "runtime-layout.json").read_text())
    for entry in layout["files"]:
        if entry.get("target") and entry["target"] != "linux-x64":
            continue
        source = root / entry["source"]
        target = output / entry["destination"]
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
    (output / "README.md").write_text("# Luau decompiler runtime\n\nKeep bin, analyzer manifest, definitions and licenses together.\n\n```sh\n./bin/luau-decompile doctor --json\n./bin/luau-decompile decompile checks/verified.luau --policy verified-typed -o output.luau\n```\n\nThis is a runtime bundle; source and detailed evidence are separate. Linux execution must pass extracted runtime acceptance before publication.\n")
    notices = output / "licenses"
    notices.mkdir(exist_ok=True)
    for filename in ["LICENSE.txt", "lua_LICENSE.txt"]:
        shutil.copy2(upstream / filename, notices / ("Luau-" + filename))
    rust_target = next(line.split(": ",1)[1] for line in subprocess.check_output(["rustc","-vV"],text=True).splitlines() if line.startswith("host: "))
    metadata = json.loads(subprocess.check_output(["cargo","metadata","--offline","--locked","--format-version","1","--filter-platform",rust_target]))
    nodes = {node["id"]: node for node in metadata["resolve"]["nodes"]}
    packages = {package["id"]:package for package in metadata["packages"]}
    seen, pending, dependency_notices = set(), [metadata["resolve"]["root"]], []
    while pending:
        identity = pending.pop()
        if identity in seen:
            continue
        seen.add(identity)
        pending.extend(dep["pkg"] for dep in nodes[identity]["deps"])
        if identity == metadata["resolve"]["root"]:
            continue
        package = packages[identity]
        package_root = pathlib.Path(package["manifest_path"]).parent
        licenses = [path for path in package_root.iterdir() if path.is_file() and ("LICENSE" in path.name.upper() or path.name.upper() in ("COPYRIGHT","NOTICE"))]
        if package.get("license_file"):
            licenses.append(pathlib.Path(package["license_file"]))
        if not licenses:
            raise RuntimeError("missing dependency notice: "+package["name"])
        destination = notices / (package["name"]+"-"+package["version"])
        destination.mkdir(exist_ok=True)
        for path in set(licenses):
            shutil.copy2(path,destination/path.name)
        dependency_notices.append({"name":package["name"],"version":package["version"],"license":package["license"],"notice_files":sorted(path.name for path in set(licenses))})
    sysroot = pathlib.Path(subprocess.check_output(["rustc", "--print", "sysroot"], text=True).strip())
    shutil.copy2(sysroot / "share/doc/rust/COPYRIGHT-library.html",notices / "Rust-COPYRIGHT-library.html")
    for filename in ["GCC-GPL3.txt","GCC-RUNTIME-EXCEPTION.txt"]:
        shutil.copy2(root / "licenses/toolchain" / filename,notices / filename)
    (notices / "closure.json").write_text(json.dumps({"schema":1,"target":rust_target,"selection":"target-filtered reachable Cargo dependency closure; unrelated cache crates excluded","dependencies":sorted(dependency_notices,key=lambda item:(item["name"],item["version"])),"compiler":compiler_version},indent=2)+"\n")
    files = [{"path": str(path.relative_to(output)), "bytes": path.stat().st_size, "sha256": digest(path)}
             for path in sorted(output.rglob("*")) if path.is_file() and path.name != "runtime-manifest.json"]
    provenance = {"schema": 1, "product": "luau-decompiler", "version": packages[metadata["resolve"]["root"]]["version"], "target": "linux-x64", "platform": platform.platform(), "architecture": platform.machine(),
                  "compiler": compiler_version, "upstream_revision": actual, "files": files,
                  "validation": "build and analyzer version only; run scripts/runtime-smoke.py for runtime acceptance"}
    (output / "runtime-manifest.json").write_text(json.dumps(provenance, indent=2) + "\n")
    print(output)


if __name__ == "__main__":
    main()
