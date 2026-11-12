import argparse
import gzip
import hashlib
import importlib.util
import json
import os
import pathlib
import platform
import subprocess
import sys
import time
import uuid


def sha(data):
    return hashlib.sha256(data).hexdigest()


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main():
    root = pathlib.Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", default="target/release/luau-decompile.exe")
    parser.add_argument("--input", default="artifacts/v0.2-baseline/scale-corpus/large_module.bc")
    parser.add_argument("--contracts", default="artifacts/rc-baseline/module-contracts.json")
    parser.add_argument("--report", default="docs/results/validation-memory-rc.json")
    parser.add_argument("--timeout", type=int, default=120)
    args = parser.parse_args()
    if os.name != "nt" or not 30 <= args.timeout <= 120:
        parser.error("this observer requires Windows and a timeout in 30..120 seconds")

    def resolve(value):
        path = pathlib.Path(value)
        return path.resolve() if path.is_absolute() else (root / path).resolve()

    def public_path(path):
        return "$workspace/" + path.resolve().relative_to(root).as_posix()

    binary, packet, contracts, report_path = map(resolve, [args.binary, args.input, args.contracts, args.report])
    observer_path = root / "scripts/measure-service-rc.py"
    spec = importlib.util.spec_from_file_location("validation_memory_observer", observer_path)
    observer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(observer)
    work = root / "artifacts" / ("validation-memory-rc-" + uuid.uuid4().hex)
    work.mkdir(parents=True)
    archive = root / "docs/results/validation-memory-rc-raw"
    archive.mkdir(parents=True, exist_ok=True)
    tracked = sorted(root.glob("src/*.rs")) + [root / name for name in [
        "Cargo.toml", "Cargo.lock", "definitions.lock.json", "upstream.lock.json", "upstream.profiles.lock.json",
        "tests/analyzer_runner.cpp", "definitions/roblox.d.luau", ".tools/luau-quality.exe",
        ".tools/luau-quality.exe.manifest.json", "scripts/measure-service-rc.py", "scripts/measure-validation-memory-rc.py"]]

    def identities():
        return [{"path": public_path(path), "bytes": path.stat().st_size, "sha256": sha(path.read_bytes())}
                for path in tracked]

    before = identities()
    binary_hash = sha(binary.read_bytes())
    packet_bytes = packet.read_bytes()
    report = {"schema": 1, "status": "running", "passed": False, "observations": [],
              "executable": {"path": public_path(binary), "sha256": binary_hash},
              "input": {"path": public_path(packet), "bytes": len(packet_bytes), "sha256": sha(packet_bytes)},
              "source_and_tool_files": before,
              "source_scope": "Rust core/CLI files, build manifests, pinned analyzer harness/definitions and measurement drivers; not a whole-repository release gate",
              "contract_template": {"path": public_path(contracts), "sha256": sha(contracts.read_bytes())},
              "measurement_runtime": {"version": platform.python_version(), "executable_sha256": sha(pathlib.Path(sys.executable).read_bytes())},
              "platform": platform.platform(), "architecture": platform.machine(), "started_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
              "requested_sample_interval_ms": 20, "observations_required": 2, "recovered_code_executed": False,
              "limitations": ["one fresh CLI process per configuration, one distinct supplied bytecode program, no distribution or general performance claim",
                              "sampled concurrent working-set sums can double-count shared pages; private bytes are not RSS",
                              "observer starts after CLI launch and can miss short-lived peaks or processes; no exact OS high-water mark is claimed",
                              "observer retains aggregate sample counts, gaps, phases, processes and peaks, not every raw 20ms reading",
                              "whole-process measurements include initialization, reconstruction, validation, output/report serialization and transmission to files; no per-Rust-stage memory attribution",
                              "the external Python observer and driver are excluded from the CLI descendant tree; shared-host applications are uncontrolled"]}
    write_json(report_path, report)
    template = json.loads(contracts.read_text(encoding="utf-8-sig"))
    binding_types = template.get("typing", {}).get("binding_types", {})
    if len(binding_types) != 512 or set(binding_types.values()) != {"number"}:
        raise ValueError("expected the recorded 512 numeric parameter contracts")
    try:
        for label, policy, bindings, expected_exit, expected_strict in [
                ("unconstrained_strict", "annotated", {}, 1, "failed"),
                ("contracted_verified", "verified_typed", binding_types, 0, "passed")]:
            case = work / label
            case.mkdir()
            config = {"output_policy": policy, "input_format": "luau_bytecode",
                      "typing": {"mode": "annotated", "binding_types": bindings},
                      "validation": {"mode": "strict_required", "timeout_ms": 120000, "max_workers": 1,
                                     "max_cache_bytes": 0, "analyzer_path": ".tools/luau-quality.exe",
                                     "definitions_path": "definitions/roblox.d.luau"}}
            config_path, output_path, quality_path = [case / name for name in ["config.json", "output.luau", "quality.json"]]
            write_json(config_path, config)
            command = [str(binary), "decompile", str(packet), "--config", str(config_path), "--threads", "1",
                       "--input-format", "luau-bytecode", "-o", str(output_path), "--quality-report", str(quality_path)]
            with (case / "stdout.bin").open("wb") as stdout, (case / "stderr.bin").open("wb") as stderr:
                started = time.perf_counter_ns()
                process = subprocess.Popen(command, cwd=root, stdin=subprocess.DEVNULL, stdout=stdout, stderr=stderr)
                sampler = observer.ExternalSampler(process.pid)
                sampler.phase = label
                timed_out = False
                try:
                    process.wait(timeout=args.timeout)
                except subprocess.TimeoutExpired:
                    timed_out = True
                    subprocess.run(["taskkill.exe", "/PID", str(process.pid), "/T", "/F"], capture_output=True, timeout=10, check=False)
                    process.wait(timeout=5)
                finally:
                    elapsed_ms = (time.perf_counter_ns() - started) / 1_000_000
                    time.sleep(0.05)
                    sampler.finish()
                memory = sampler.report()
            memory["isolation"] = "separate observer process; observer/driver memory excluded from CLI descendant tree"
            if timed_out:
                raise TimeoutError(label + " exceeded the bounded CLI deadline")
            raw_quality = quality_path.read_bytes()
            result = json.loads(raw_quality)
            validation = result["validation"]
            output = output_path.read_bytes()
            stderr = (case / "stderr.bin").read_bytes()
            public_raw = archive / (label + ".quality.json.gz")
            compressed = gzip.compress(raw_quality, mtime=0)
            public_raw.write_bytes(compressed)
            output_archive = archive / (label + ".output.luau.gz")
            compressed_output = gzip.compress(output, mtime=0)
            output_archive.write_bytes(compressed_output)
            row = {"id": label, "exit_code": process.returncode, "pid": process.pid,
                   "wall_ms": elapsed_ms, "hard_deadline_seconds": args.timeout,
                   "configuration": config, "configuration_file_sha256": sha(config_path.read_bytes()),
                   "configuration_canonical_sha256": sha(json.dumps(config, sort_keys=True, separators=(",", ":")).encode()),
                   "supplied_numeric_contracts": len(bindings), "output_bytes": len(output), "output_sha256": sha(output),
                   "raw_report_bytes": len(raw_quality), "raw_report_sha256": sha(raw_quality),
                   "raw_report_archive": {"path": public_path(public_raw), "sha256": sha(compressed)},
                   "output_archive": {"path": public_path(output_archive), "sha256": sha(compressed_output)},
                   "stderr_bytes": len(stderr), "stderr_sha256": sha(stderr),
                   "complete": result.get("complete"), "profile": result.get("profile"),
                   "prototypes": result.get("prototypes"), "instructions": result.get("instructions"),
                   "phase_microseconds": {name: result.get(name) for name in ["decode_micros", "reconstruct_micros", "type_infer_micros", "format_micros", "validation_micros", "total_micros"]},
                   "validation": {key: validation.get(key) for key in ["output_policy", "required_passed", "syntax", "compilation", "strict_analysis", "meaningful_typing", "selected_strategy", "cache_hit", "compiler_micros", "analyzer_micros", "analyzer_sha256", "definitions_sha256", "context_sha256"]},
                   "diagnostic_count": len(validation.get("diagnostics", [])), "attempts": validation.get("attempts", []),
                   "memory": memory}
            row["passed"] = (process.returncode == expected_exit and result.get("complete") is True
                             and validation.get("syntax") == "passed" and validation.get("compilation") == "passed"
                             and validation.get("strict_analysis") == expected_strict
                             and validation.get("required_passed") is (expected_exit == 0)
                             and memory["samples"] > 0 and memory["max_processes"] >= 2
                             and validation.get("cache_hit") is False)
            if policy == "verified_typed":
                row["passed"] = row["passed"] and validation.get("meaningful_typing", {}).get("passed") is True
            report["observations"].append(row)
            write_json(report_path, report)
            if not row["passed"]:
                raise AssertionError(label + " did not meet its expected outcome")
        if before != identities() or binary_hash != sha(binary.read_bytes()) or sha(packet_bytes) != sha(packet.read_bytes()):
            raise AssertionError("source, tools, executable or corpus changed during measurement")
        report["status"] = "measured"
        report["passed"] = True
        report["finished_utc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        write_json(report_path, report)
        print(json.dumps({"passed": True, "report": public_path(report_path), "executable_sha256": binary_hash,
                          "observations": [{"id": row["id"], "wall_ms": row["wall_ms"], "memory": row["memory"]} for row in report["observations"]]}))
    except Exception as error:
        report["status"] = "failed"
        report["error"] = str(error).replace(str(root), "$workspace")
        write_json(report_path, report)
        raise


if __name__ == "__main__":
    main()
