import argparse
import base64
import concurrent.futures
import contextlib
import hashlib
import http.client
import json
import os
import pathlib
import platform
import secrets
import socket
import struct
import subprocess
import tempfile
import time


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bundle", required=True)
    parser.add_argument("--report", required=True)
    parser.add_argument("--compiler")
    parser.add_argument("--oracle")
    parser.add_argument("--require-linux", action="store_true")
    parser.add_argument("--work-dir")
    args = parser.parse_args()
    if args.require_linux and platform.system() != "Linux":
        parser.error("Linux execution is required by this invocation")
    bundle = pathlib.Path(args.bundle).resolve()
    report_path = pathlib.Path(args.report).resolve()
    suffix = ".exe" if platform.system() == "Windows" else ""
    binary = bundle / "bin" / ("luau-decompile" + suffix)
    analyzer = bundle / "bin" / ("luau-quality" + suffix)
    source = b"local function add(value: number): number\n    return value + 2\nend\nlocal answer: number = add(40)\nreturn answer\n"
    negative = b"local value: number = 'wrong'\nreturn value\n"
    rows = []
    report = {"schema": 1, "passed": False, "platform": platform.platform(), "architecture": platform.machine(),
              "harness_sha256": digest(pathlib.Path(__file__).read_bytes()),
              "executable_sha256": digest(binary.read_bytes()), "analyzer_sha256": digest(analyzer.read_bytes()),
              "analyzer_manifest_sha256": digest(analyzer.with_name(analyzer.name + ".manifest.json").read_bytes()),
              "definitions_sha256": digest((bundle / "definitions" / "roblox.d.luau").read_bytes()), "cases": rows,
              "requested_configuration": {"output_policy": "verified_typed", "other_settings": "release defaults"},
              "behavioral_verification": "not_run_without_explicit_compiler_and_oracle", "arbitrary_source_execution": False}
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n")
    inventory = json.loads((bundle / 'runtime-manifest.json').read_text(encoding='utf-8'))
    tools = inventory['provenance']['quality_tools']
    for field in ['protocol', 'analyzer_sha256', 'manifest_sha256', 'harness_sha256', 'upstream_revision',
                  'definitions_sha256', 'definitions_revision', 'definitions_license_sha256']:
        assert isinstance(tools.get(field), str) and tools[field], 'Missing runtime quality-tool provenance: '+field
    analyzer_manifest = json.loads(analyzer.with_name(analyzer.name + '.manifest.json').read_text(encoding='utf-8'))
    assert tools['protocol'] == analyzer_manifest['protocol'] == 'LQUAL/1'
    definitions_lock = json.loads((bundle / 'definitions.lock.json').read_text(encoding='utf-8'))
    assert tools['analyzer_sha256'] == report['analyzer_sha256']
    assert tools['manifest_sha256'] == report['analyzer_manifest_sha256']
    assert tools['harness_sha256'] == analyzer_manifest['source_sha256']
    assert tools['upstream_revision'] == analyzer_manifest['upstream_revision'] == definitions_lock['analyzer_revision']
    assert tools['definitions_sha256'] == report['definitions_sha256'] == definitions_lock['sha256']
    assert tools['definitions_revision'] == definitions_lock['revision']
    assert tools['definitions_license_sha256'] == digest((bundle / definitions_lock['license_path']).read_bytes())
    rows.append({'id': 'runtime_quality_tool_provenance_matches_packaged_assets', 'passed': True})
    work = contextlib.nullcontext(str(pathlib.Path(args.work_dir).resolve())) if args.work_dir else tempfile.TemporaryDirectory(prefix="luau-runtime-smoke-")
    with work as temporary:
        directory = pathlib.Path(temporary)

        def cli(arguments, data=None, expected=0):
            result = subprocess.run([str(binary), *map(str, arguments)], cwd=directory, input=data,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=90)
            if (result.returncode == 0) != (expected == 0):
                raise AssertionError("CLI status mismatch: " + result.stderr.decode("utf-8", "replace")[:4000])
            return result

        version = cli(["--version"]).stdout.decode().strip()
        report["version"] = version
        package_version = version.removeprefix("luau-decompile ")
        attribution = ("--[=[\n    Luau Decompiler " + package_version + "\n    Made by @zionqyl\n"
                       "    https://github.com/zionqyl/luau-decompiler\n]=]\n\n").encode()

        def finalized(data, strict=True):
            assert data.startswith(b"--!strict\n" + attribution) or (not strict and data.startswith(attribution))
            assert data.count(attribution) == 1
            return digest(data)

        source_path = directory / "original.luau"
        source_path.write_bytes(source)
        quality_path = directory / "quality.json"
        positive = cli(["decompile", "-", "--policy", "verified-typed", "--quality-report", quality_path], source)
        quality = json.loads(quality_path.read_text())
        assert quality["validation"]["required_passed"] and quality["validation"]["meaningful_typing"]["passed"]
        assert quality["input_sha256"] == digest(source)
        finalized(positive.stdout)
        output_path = directory / "result.luau"
        cli(["decompile", source_path, "--policy", "verified-typed", "-o", output_path])
        assert output_path.read_bytes() == positive.stdout
        rows.append({"id": "stdin_file_verified_source", "passed": True, "input_sha256": digest(source), "output_sha256": digest(positive.stdout)})
        failed_report = directory / "failed-quality.json"
        failed = cli(["decompile", "-", "--policy", "verified-typed", "--quality-report", failed_report], negative, expected=1)
        failed_quality = json.loads(failed_report.read_text())
        assert failed.stdout and not failed_quality["validation"]["required_passed"]
        finalized(failed.stdout)
        if failed_quality.get("baseline_source"):
            finalized(failed_quality["baseline_source"].encode(), strict=False)
        rows.append({"id": "failed_verified_source_kept_with_nonzero_status", "passed": True})
        batch_directory = directory / "batch"
        second_path = directory / "second.lua"
        second_path.write_bytes(source)
        cli(["batch", "--policy", "verified-typed", "--out-dir", batch_directory, source_path, second_path])
        assert len(list(batch_directory.glob("*.luau"))) == 2
        assert all(finalized(path.read_bytes()) == digest(positive.stdout) for path in batch_directory.glob("*.luau"))
        rows.append({"id": "bounded_mixed_extension_source_batch", "passed": True})
        bytecode = (bundle / "checks" / "verified.bc").read_bytes() if (bundle / "checks" / "verified.bc").is_file() else None
        if bytecode:
            packet_path = directory / "installed-fixture.bc"
            packet_path.write_bytes(bytecode)
            missing_config = directory / "missing-analyzer.json"
            missing_config.write_text(json.dumps({"typing": {"mode": "off"}, "validation": {"analyzer_path": str(directory / ("missing-analyzer" + suffix))}}))
            missing_report = directory / "missing-analyzer-benchmark.json"
            cli(["benchmark", packet_path, "--threads", "1", "--iterations", "1", "--warmup", "0", "--strict-required", "--config", missing_config, "-o", missing_report], expected=1)
            missing = json.loads(missing_report.read_text())
            assert missing["required_quality_failures"] == 1 and len(missing["results"]) == 1
            assert missing["results"][0]["required_quality_failures"] == 1 and missing["results"][0]["complete_reconstructions"] == 1
            rows.append({"id": "missing_analyzer_strict_benchmark_retains_complete_failed_report", "passed": True})
        if args.compiler and args.oracle:
            compiler = pathlib.Path(args.compiler).resolve()
            oracle = pathlib.Path(args.oracle).resolve()
            report["compiler_sha256"] = digest(compiler.read_bytes())
            report["oracle_sha256"] = digest(oracle.read_bytes())

            def compile_file(path):
                result = subprocess.run([str(compiler), "--binary", "-O0", "-g2", "-t1", str(path)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30, check=True)
                assert result.stdout and result.stdout[0] != 0
                return result.stdout

            bytecode = compile_file(source_path)
            rebuilt = cli(["decompile", "-", "--input-format", "luau-bytecode", "--policy", "verified-typed"], bytecode)
            rebuilt_path = directory / "rebuilt.luau"
            rebuilt_path.write_bytes(rebuilt.stdout)
            finalized(rebuilt.stdout)
            generated = compile_file(rebuilt_path)
            expected_observation = b"LOBS\x01\x01" + struct.pack("<I", 0) + b"\x00" + struct.pack("<I", 1) + b"\x02" + struct.pack("<d", 42)
            for name, packet in [("original", bytecode), ("rebuilt", generated)]:
                packet_path = directory / (name + ".bc")
                packet_path.write_bytes(packet)
                observed = subprocess.run([str(oracle), str(packet_path)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10, check=True).stdout
                assert observed == expected_observation
            rows.append({"id": "verified_bytecode_and_exact_typed_behavior", "passed": True, "input_sha256": digest(bytecode), "output_sha256": digest(rebuilt.stdout)})
            report["behavioral_verification"] = "one_known_source_program; one_exact_LOBS_1_pair; no_arbitrary_input_execution"
        token = secrets.token_hex(32)
        environment = dict(os.environ)
        environment["LUAU_DECOMPILER_TOKEN"] = token
        with socket.socket() as probe:
            probe.bind(("127.0.0.1", 0))
            port = probe.getsockname()[1]
        service = subprocess.Popen([str(binary), "serve", "--listen", "127.0.0.1:" + str(port), "--workers", "2", "--cpu-threads", "2", "--queue", "8", "--timeout-ms", "30000"],
                                   cwd=directory, env=environment, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

        def request(method, path, payload=None, authenticated=True):
            connection = http.client.HTTPConnection("127.0.0.1", port, timeout=40)
            headers = {"Content-Type": "application/json"}
            if authenticated:
                headers["Authorization"] = "Bearer " + token
            connection.request(method, path, json.dumps(payload).encode() if payload is not None else None, headers)
            response = connection.getresponse()
            body = json.loads(response.read())
            status, cache = response.status, response.getheader("X-Decompiler-Cache")
            connection.close()
            return status, body, cache

        try:
            deadline = time.monotonic() + 15
            while True:
                try:
                    status, ready, _ = request("GET", "/readyz")
                    assert status == 200 and ready["ready"]
                    break
                except ConnectionError:
                    if time.monotonic() >= deadline:
                        raise
                    time.sleep(0.05)
            assert request("GET", "/healthz", authenticated=False)[0] == 401
            capabilities = request("GET", "/v1/capabilities")
            assert capabilities[0] == 200 and capabilities[1]["features"]["source_input"] and capabilities[1]["protocol_version"] == 2
            assert version.endswith(capabilities[1]["package_version"])
            payload = {"source": source.decode(), "input_format": "luau_source", "reconstruction_config": {"output_policy": "verified_typed"}}
            status, final, _ = request("POST", "/v1/process", payload)
            assert status == 200 and final["validation"]["required_passed"] and final["validation"]["meaningful_typing"]["passed"]
            assert final["source"].encode() == positive.stdout
            assert final["input_sha256"] == digest(source)
            status, failure, _ = request("POST", "/v1/process", {**payload, "source": negative.decode()})
            assert status == 422 and failure["source"] and not failure["validation"]["required_passed"]
            finalized(failure["source"].encode())
            with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
                concurrent_results = list(executor.map(lambda _: request("POST", "/v1/process", payload), range(24)))
            assert all(status == 200 and body["source"] == final["source"] for status, body, _ in concurrent_results)
            assert any(cache == "hit" for _, _, cache in concurrent_results)
            if bytecode:
                status, body, _ = request("POST", "/v1/decompile", {"bytecode_base64": base64.b64encode(bytecode).decode(), "reconstruction_config": {"output_policy": "verified_typed", "naming": "camelCase", "indent": "  ", "formatting": {"line_width": 80}}})
                assert status == 200 and body["validation"]["required_passed"]
                finalized(body["source"].encode())
                assert body["validation"]["analyzer_sha256"] == report["analyzer_sha256"] and body["validation"]["definitions_sha256"] == report["definitions_sha256"]
                rows.append({"id": "http_verified_bytecode", "passed": True})
            rows.append({"id": "authenticated_http_verified_source_negative_and_24_concurrent_requests", "passed": True})
            rows.append({"id": "exact_attribution_cli_batch_http_cache_and_failed_quality", "passed": True})
            assert request("POST", "/v1/shutdown")[0] == 200
            service.wait(timeout=35)
            assert service.returncode == 0
            rows.append({"id": "authenticated_graceful_shutdown", "passed": True})
        finally:
            if service.poll() is None:
                service.kill()
                service.wait(timeout=10)
            service.stderr.close()
    report["passed"] = True
    report_path.write_text(json.dumps(report, indent=2) + "\n")
    print("runtime package acceptance passed: " + str(report_path))


if __name__ == "__main__":
    main()
