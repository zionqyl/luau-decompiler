import argparse
import base64
import collections
import concurrent.futures
import contextlib
import ctypes
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
import sys
import tempfile
import threading
import time


def digest(data):
    return hashlib.sha256(data).hexdigest()


def tiny_packet(value):
    packet = bytearray([6, 3, 0, 0, 1, 2, 0, 0, 0, 0, 0, 2])
    packet.extend(struct.pack("<II", 4 | ((value & 65535) << 16), 22 | (2 << 16)))
    packet.extend(bytes(7))
    return bytes(packet)


def varint(value):
    output = bytearray()
    while True:
        part = value & 127
        value >>= 7
        output.append(part | (128 if value else 0))
        if not value:
            return output


def large_string_packet(size):
    packet = bytearray([6, 3, 1])
    packet.extend(varint(size))
    packet.extend(b"x" * size)
    packet.extend([0, 1, 1, 0, 0, 0, 0, 0, 2])
    packet.extend(struct.pack("<II", 5, 22 | (2 << 16)))
    packet.extend([1, 3, 1, 0, 0, 0, 0, 0, 0])
    return bytes(packet)


def typed_source(value, family=0):
    if family % 5 == 0:
        return "local total:number=" + str(value) + "\nreturn total\n"
    if family % 5 == 1:
        return "local function add(value:number):number return value+" + str(value) + " end\nreturn add\n"
    if family % 5 == 2:
        return "type Snapshot={value:number,label:string}\nlocal snapshot:Snapshot={value=" + str(value) + ",label='record'}\nreturn snapshot\n"
    if family % 5 == 3:
        return "local function apply(callback:(number)->number,value:number):number return callback(value) end\nlocal result:number=apply(function(value:number):number return value*2 end," + str(value) + ")\nreturn result\n"
    return "local total:number=" + str(value) + "\nlocal function add(value:number):number total+=value return total end\nreturn add\n"


def payload_body(payload):
    if isinstance(payload, str):
        return json.dumps({"source": payload, "input_format": "luau_source"}).encode()
    return json.dumps({"bytecode_base64": base64.b64encode(payload).decode()}).encode()


def successful_result(status, result, verified):
    validation = result.get("validation", {})
    valid = status == 200 and result.get("complete") and validation.get("required_passed")
    if verified:
        valid = valid and validation.get("output_policy") == "verified_typed" and validation.get("meaningful_typing", {}).get("passed")
        valid = valid and all(validation.get(gate) == "passed" for gate in ("syntax", "compilation", "strict_analysis"))
    return bool(valid)


class ProcessMemory:
    def __init__(self):
        if os.name != "nt":
            self.kernel = None
            return
        from ctypes import wintypes

        class Entry(ctypes.Structure):
            _fields_ = [("size", wintypes.DWORD), ("usage", wintypes.DWORD), ("pid", wintypes.DWORD),
                        ("heap", ctypes.c_size_t), ("module", wintypes.DWORD), ("threads", wintypes.DWORD),
                        ("parent", wintypes.DWORD), ("priority", wintypes.LONG), ("flags", wintypes.DWORD),
                        ("name", wintypes.WCHAR * 260)]

        class Counters(ctypes.Structure):
            _fields_ = [("size", wintypes.DWORD), ("faults", wintypes.DWORD),
                        ("peak_working_set", ctypes.c_size_t), ("working_set", ctypes.c_size_t),
                        ("peak_paged_pool", ctypes.c_size_t), ("paged_pool", ctypes.c_size_t),
                        ("peak_nonpaged_pool", ctypes.c_size_t), ("nonpaged_pool", ctypes.c_size_t),
                        ("pagefile", ctypes.c_size_t), ("peak_pagefile", ctypes.c_size_t),
                        ("private", ctypes.c_size_t)]

        self.entry_type = Entry
        self.counter_type = Counters
        self.kernel = ctypes.WinDLL("kernel32", use_last_error=True)
        self.psapi = ctypes.WinDLL("psapi", use_last_error=True)
        self.kernel.CreateToolhelp32Snapshot.argtypes = [wintypes.DWORD, wintypes.DWORD]
        self.kernel.CreateToolhelp32Snapshot.restype = wintypes.HANDLE
        self.kernel.Process32FirstW.argtypes = [wintypes.HANDLE, ctypes.POINTER(Entry)]
        self.kernel.Process32NextW.argtypes = [wintypes.HANDLE, ctypes.POINTER(Entry)]
        self.kernel.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
        self.kernel.OpenProcess.restype = wintypes.HANDLE
        self.kernel.CloseHandle.argtypes = [wintypes.HANDLE]
        self.psapi.GetProcessMemoryInfo.argtypes = [wintypes.HANDLE, ctypes.POINTER(Counters), wintypes.DWORD]

    def tree(self, root):
        if self.kernel is None:
            entries = []
            for path in pathlib.Path("/proc").iterdir():
                if not path.name.isdigit():
                    continue
                try:
                    fields = (path / "stat").read_text().rsplit(") ", 1)[1].split()
                    entries.append((int(path.name), int(fields[1]), (path / "comm").read_text().strip()))
                except (OSError, IndexError, ValueError):
                    continue
        else:
            snapshot = self.kernel.CreateToolhelp32Snapshot(2, 0)
            if snapshot == ctypes.c_void_p(-1).value:
                raise OSError(ctypes.get_last_error(), "CreateToolhelp32Snapshot")
            try:
                entry = self.entry_type()
                entry.size = ctypes.sizeof(entry)
                entries = []
                valid = self.kernel.Process32FirstW(snapshot, ctypes.byref(entry))
                while valid:
                    entries.append((entry.pid, entry.parent, entry.name))
                    valid = self.kernel.Process32NextW(snapshot, ctypes.byref(entry))
            finally:
                self.kernel.CloseHandle(snapshot)
        selected = {root}
        while True:
            added = {pid for pid, parent, _ in entries if parent in selected}
            if added <= selected:
                break
            selected.update(added)
        return [(pid, name) for pid, _, name in entries if pid in selected]

    def read(self, pid):
        if self.kernel is None:
            values = {}
            for line in pathlib.Path("/proc", str(pid), "status").read_text().splitlines():
                if line.startswith(("VmRSS:", "RssAnon:")):
                    key, value, _ = line.split()
                    values[key] = int(value) * 1024
            return values.get("VmRSS:", 0), values.get("RssAnon:", 0)
        process = self.kernel.OpenProcess(0x0400 | 0x0010, False, pid)
        if not process:
            raise OSError(ctypes.get_last_error(), "OpenProcess")
        try:
            counters = self.counter_type()
            counters.size = ctypes.sizeof(counters)
            if not self.psapi.GetProcessMemoryInfo(process, ctypes.byref(counters), ctypes.sizeof(counters)):
                raise OSError(ctypes.get_last_error(), "GetProcessMemoryInfo")
            return counters.working_set, counters.private
        finally:
            self.kernel.CloseHandle(process)


class Sampler:
    def __init__(self, pid):
        self.pid = pid
        self.reader = ProcessMemory()
        self.stop = threading.Event()
        self.phase = "startup"
        self.samples = 0
        self.max_gap_ms = 0
        self.gaps_above_50ms = 0
        self.peak_rss = 0
        self.peak_private = 0
        self.peak_parent_rss = 0
        self.max_processes = 0
        self.processes = {}
        self.errors = []
        self.started = time.monotonic()
        self.windows = {}
        self.phases = collections.defaultdict(lambda: {"samples": 0, "peak_rss_bytes": 0, "peak_private_bytes": 0})
        self.thread = threading.Thread(target=self.run, daemon=True)

    def run(self):
        previous = time.monotonic()
        while not self.stop.is_set():
            started = time.monotonic()
            self.max_gap_ms = max(self.max_gap_ms, (started - previous) * 1000)
            if started-previous>0.05:
                self.gaps_above_50ms+=1
            previous = started
            try:
                rss, private, observed = 0, 0, 0
                for pid, name in self.reader.tree(self.pid):
                    try:
                        resident, owned = self.reader.read(pid)
                    except OSError as error:
                        if len(self.errors) < 16:
                            self.errors.append({"pid": pid, "error": str(error)})
                        continue
                    self.processes[str(pid)] = name
                    rss += resident
                    private += owned
                    observed += 1
                    if pid == self.pid:
                        self.peak_parent_rss = max(self.peak_parent_rss, resident)
                if observed:
                    self.samples += 1
                    self.max_processes = max(self.max_processes, observed)
                    self.peak_rss = max(self.peak_rss, rss)
                    self.peak_private = max(self.peak_private, private)
                    phase = self.phases[self.phase]
                    phase["samples"] += 1
                    phase["peak_rss_bytes"] = max(phase["peak_rss_bytes"], rss)
                    phase["peak_private_bytes"] = max(phase["peak_private_bytes"], private)
                    window_id = min(127, int((started-self.started)//10))
                    window = self.windows.setdefault(window_id, {"start_offset_seconds":window_id*10,"samples":0,"first_rss_bytes":rss,"first_private_bytes":private,"minimum_rss_bytes":rss,"peak_rss_bytes":rss,"minimum_private_bytes":private,"peak_private_bytes":private})
                    window["samples"] += 1
                    window["last_rss_bytes"] = rss
                    window["last_private_bytes"] = private
                    window["minimum_rss_bytes"] = min(window["minimum_rss_bytes"],rss)
                    window["peak_rss_bytes"] = max(window["peak_rss_bytes"],rss)
                    window["minimum_private_bytes"] = min(window["minimum_private_bytes"],private)
                    window["peak_private_bytes"] = max(window["peak_private_bytes"],private)
            except OSError as error:
                if len(self.errors) < 16:
                    self.errors.append({"error": str(error)})
            self.stop.wait(max(0.001, 0.02 - (time.monotonic() - started)))

    def report(self):
        return {"method": "Toolhelp32 parent-PID snapshots and GetProcessMemoryInfo" if os.name == "nt" else "proc parent-PID and status RSS",
                "requested_interval_ms": 20, "max_observed_gap_ms": self.max_gap_ms, "samples": self.samples,
                "gaps_above_50ms":self.gaps_above_50ms,
                "peak_sampled_process_tree_rss_bytes": self.peak_rss, "peak_sampled_parent_rss_bytes": self.peak_parent_rss,
                "peak_sampled_tree_private_bytes": self.peak_private, "max_processes": self.max_processes,
                "processes": self.processes, "phases": dict(self.phases), "errors": self.errors,
                "ten_second_windows":[self.windows[index] for index in sorted(self.windows)],
                "limitations": "sampled concurrent RSS sums include shared pages and are not unique physical memory or an exact OS high-water mark"}


class ExternalSampler:
    def __init__(self,pid):
        self.process=subprocess.Popen([sys.executable,str(pathlib.Path(__file__).resolve()),"--memory-worker",str(pid)],
                                      stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        self.result=None

    @property
    def phase(self):
        return None

    @phase.setter
    def phase(self,value):
        self.process.stdin.write(json.dumps({"phase":value}).encode()+b"\n")
        self.process.stdin.flush()

    def finish(self):
        if self.result is not None:
            return
        try:
            output,error=self.process.communicate(b"stop\n",timeout=5)
        except subprocess.TimeoutExpired:
            self.process.kill()
            output,error=self.process.communicate(timeout=3)
        if self.process.returncode!=0:
            raise RuntimeError("memory observer failed: "+error.decode("utf-8","replace")[:2048])
        self.result=json.loads(output)
        self.result["isolation"]="separate observer process; its own memory is excluded from the service descendant tree"

    def report(self):
        self.finish()
        return self.result


def memory_worker(pid):
    sampler=Sampler(pid)

    def commands():
        try:
            for line in sys.stdin.buffer:
                if len(line)>4096 or line.strip()==b"stop":
                    break
                value=json.loads(line)
                if isinstance(value.get("phase"),str):
                    sampler.phase=value["phase"]
        finally:
            sampler.stop.set()

    threading.Thread(target=commands,daemon=True).start()
    sampler.run()
    sys.stdout.write(json.dumps(sampler.report()))


def percentiles(values):
    ordered = sorted(values)
    if not ordered:
        return {"count": 0}
    return {"count": len(ordered), "p50_ms": ordered[(len(ordered) - 1) // 2],
            "p95_ms": ordered[min(len(ordered) - 1, (len(ordered) * 95 + 99) // 100 - 1)],
            "p99_ms": ordered[min(len(ordered) - 1, (len(ordered) * 99 + 99) // 100 - 1)],
            "max_ms": ordered[-1]}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bundle", required=True)
    parser.add_argument("--report", required=True)
    parser.add_argument("--seconds", type=float, default=15)
    parser.add_argument("--concurrency", type=int, default=4)
    parser.add_argument("--mode", choices=["faithful", "annotated", "strict", "verified"], default="strict")
    parser.add_argument("--latency-samples", type=int, default=120)
    parser.add_argument("--require-fixes", action="store_true")
    parser.add_argument("--work-dir")
    parser.add_argument("--previous-report")
    args = parser.parse_args()
    if not 15 <= args.seconds <= 600 or not 1 <= args.concurrency <= 8 or not 0 <= args.latency_samples <= 1000:
        parser.error("seconds must be 15..600, concurrency 1..8 and latency samples 0..1000")
    bundle = pathlib.Path(args.bundle).resolve()
    report_path = pathlib.Path(args.report).resolve()
    suffix = ".exe" if os.name == "nt" else ""
    binary = bundle / "bin" / ("luau-decompile" + suffix)
    verified = args.mode == "verified"
    config = {"output_policy":"verified_typed" if verified else "faithful" if args.mode=="faithful" else "annotated",
              "typing": {"mode": "off" if args.mode == "faithful" else "annotated"},
              "validation": {"mode": "strict_required" if args.mode in ("strict","verified") else "off",
                             "timeout_ms": 10000, "max_workers": 2}}
    report = {"schema": 1, "passed": False, "harness_sha256": digest(pathlib.Path(__file__).read_bytes()),
              "executable_sha256": digest(binary.read_bytes()), "platform": platform.platform(),
              "measurement_runtime": {"version": platform.python_version(), "executable_sha256": digest(pathlib.Path(sys.executable).read_bytes())},
              "architecture": platform.machine(), "configuration": config, "mode": args.mode,
              "duration_requested_seconds": args.seconds, "concurrency": args.concurrency,
              "semantics": "resource fixtures only; no Lua execution or behavioral-equivalence claim",
              "verified_typed_required":verified,"maximum_operation_cases":100000,
              "stability_scope":"A finite paced workload in the recorded environment, not proof of general stability or absence of leaks"}
    if args.previous_report:
        previous_path=pathlib.Path(args.previous_report).resolve()
        previous=json.loads(previous_path.read_text())
        if previous.get("executable_sha256")!=report["executable_sha256"] or previous.get("configuration")!=config:
            raise ValueError("Previous comparison report must use the same executable and configuration")
        report["previous_attempt"]={"report_name":previous_path.name,"sha256":digest(previous_path.read_bytes()),"harness_sha256":previous.get("harness_sha256"),"passed":previous.get("passed"),"duration_seconds":previous.get("sustained",{}).get("elapsed_seconds"),"failure_count":len(previous.get("sustained",{}).get("failures",[])),"change":"Harness now records bounded-FIFO hot-key eviction and requires an immediate hit after a successful warming miss; all status, quality, cancellation and resource assertions remain. Service code and executable are unchanged."}
    for name, path in [("analyzer", bundle / "bin" / ("luau-quality" + suffix)),
                       ("definitions", bundle / "definitions" / "roblox.d.luau")]:
        report[name + "_sha256"] = digest(path.read_bytes())
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n")
    token = secrets.token_hex(32)
    environment = dict(os.environ)
    environment["LUAU_DECOMPILER_TOKEN"] = token
    work = contextlib.nullcontext(str(pathlib.Path(args.work_dir).resolve())) if args.work_dir else tempfile.TemporaryDirectory(prefix="luau-service-measure-")
    with work as temporary:
        directory = pathlib.Path(temporary)
        config_path = directory / "config.json"
        config_path.write_text(json.dumps(config))
        with socket.socket() as probe:
            probe.bind(("127.0.0.1", 0))
            port = probe.getsockname()[1]
        service = subprocess.Popen([str(binary), "serve", "--listen", "127.0.0.1:" + str(port),
                                   "--config", str(config_path), "--workers", "2", "--cpu-threads", "2", "--queue", "8",
                                   "--cache-mib", "32", "--memory-mib", "1024", "--timeout-ms", "10000"],
                                  cwd=directory, env=environment, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        sampler = ExternalSampler(service.pid)
        request_lock=threading.Lock()
        request_calls=0

        def request(method, path, packet=None, request_id=None, timeout=3):
            nonlocal request_calls
            with request_lock:
                request_calls+=1
            body = None if packet is None else payload_body(packet)
            connection = http.client.HTTPConnection("127.0.0.1", port, timeout=timeout)
            headers = {"Authorization": "Bearer " + token}
            if body is not None:
                headers["Content-Type"] = "application/json"
            if request_id:
                headers["X-Request-Id"] = request_id
            started = time.perf_counter_ns()
            try:
                connection.request(method, path, body, headers)
                response = connection.getresponse()
                raw = response.read()
                return response.status, json.loads(raw), response.getheader("X-Decompiler-Cache"), (time.perf_counter_ns() - started) / 1e6
            finally:
                connection.close()

        sockets = []
        telemetry_stop = None
        telemetry_worker = None
        try:
            deadline = time.monotonic() + 15
            while True:
                try:
                    status, initial, _, latency = request("GET", "/v1/capabilities")
                    if status != 200:
                        raise RuntimeError("capabilities failed")
                    break
                except (ConnectionError, TimeoutError):
                    if time.monotonic() >= deadline or service.poll() is not None:
                        raise
                    time.sleep(0.05)
            report["package_version"] = initial.get("package_version")
            report["capabilities_latency_ms"] = latency
            warm = typed_source(42) if verified else tiny_packet(42)
            sampler.phase = "cold_start"
            status, first, _, latency = request("POST", "/v1/decompile", warm, timeout=30)
            assert successful_result(status, first, verified)
            report["cold_first_request_ms"] = latency
            report["first_request_type_quality"] = first.get("type_report")
            if verified:
                preflight=[]
                for family in range(5):
                    status,result,_,latency=request("POST","/v1/decompile",typed_source(42,family),timeout=30)
                    if not successful_result(status,result,True):
                        raise AssertionError("verified preflight family failed: "+str(family))
                    preflight.append({"family":family,"latency_ms":latency,"required_passed":True,"source_sha256":digest(result["source"].encode()),"type_quality":result["type_report"]})
                report["verified_source_family_preflight"]=preflight
            sampler.phase="latency_probe"
            latency_rows={}
            for family,method,path,payload in [("cached","POST","/v1/decompile",warm),("health","GET","/healthz",None)]:
                observations=[]
                for observation in range(args.latency_samples):
                    status,result,cache,latency=request(method,path,payload)
                    if family=="cached":
                        if cache!="hit" or not successful_result(status,result,verified):
                            raise AssertionError("latency cohort was not a successful cached result")
                    elif status!=200 or not result.get("healthy"):
                        raise AssertionError("latency health probe failed")
                    observations.append(latency)
                    time.sleep((observation%4)*0.0007)
                latency_rows[family]={"distribution":percentiles(observations),"observations_ms":observations}
            report["listener_latency_probe"]={"samples_per_family":args.latency_samples,"scope":"sequential distinct TCP connections, staggered arrivals, no reconstruction on cache-hit cohort; includes HTTP/authentication/JSON and isolated observer overhead","families":latency_rows}
            counters = collections.Counter()
            cache_observations = collections.Counter()
            timings = collections.defaultdict(list)
            phases = collections.defaultdict(lambda:collections.Counter())
            outcomes = collections.defaultdict(collections.Counter)
            failures = []
            counter_lock = threading.Lock()
            index = 0
            sampler.phase = "sustained_mixed_load"
            calls_before_load=request_calls
            started = time.monotonic()
            end = started + args.seconds
            telemetry_stop=threading.Event()
            telemetry=[]

            def collect_telemetry():
                while not telemetry_stop.is_set():
                    try:
                        status,snapshot,_,latency=request("GET","/v1/capabilities",timeout=3)
                        if status!=200:
                            raise AssertionError("capabilities telemetry status "+str(status))
                        point={"elapsed_seconds":time.monotonic()-started,"latency_ms":latency,"active_jobs":snapshot.get("active_jobs"),"max_jobs":snapshot.get("max_jobs"),"accounted_memory":snapshot.get("accounted_memory"),"pending_handoffs":snapshot.get("pending_handoffs")}
                        with counter_lock:
                            telemetry.append(point)
                    except (OSError,http.client.HTTPException,ValueError,AssertionError) as error:
                        with counter_lock:
                            if len(failures)<16:
                                failures.append({"family":"telemetry","error":str(error)})
                    telemetry_stop.wait(5)

            telemetry_worker=threading.Thread(target=collect_telemetry,daemon=True)
            telemetry_worker.start()

            def worker():
                nonlocal index
                while time.monotonic() < end:
                    with counter_lock:
                        case = index
                        index += 1
                    if case >= 100000:
                        return
                    families=["cached", "cold", "cached", "rejected", "cancelled"]
                    if verified:
                        families.append("quality_rejected")
                    family = families[case % len(families)]
                    began = time.monotonic()
                    try:
                        if family == "cancelled":
                            identifier = "load-" + str(case)
                            cancelled = request("DELETE", "/v1/requests/" + identifier)
                            result = request("POST", "/v1/decompile", warm, identifier)
                            valid = cancelled[0] == 200 and result[0] == 499 and result[1].get("error", {}).get("stage") == "cancelled"
                        elif family == "rejected":
                            result = request("POST", "/v1/decompile", b"\xff")
                            valid = result[0] == 422 and "error" in result[1]
                        elif family == "quality_rejected":
                            result=request("POST","/v1/decompile","local value:string=42 return value")
                            valid=result[0]==422 and bool(result[1].get("source")) and result[1].get("validation",{}).get("required_passed") is False
                        else:
                            packet = warm if family == "cached" else typed_source(100+case,case//len(families)) if verified else tiny_packet(100 + case)
                            result = request("POST", "/v1/decompile", packet)
                            valid = successful_result(result[0],result[1],verified)
                            if family == "cached":
                                with counter_lock:
                                    cache_observations["initial_"+str(result[2])]+=1
                                if valid and result[2]=="miss":
                                    result=request("POST","/v1/decompile",packet)
                                    valid=successful_result(result[0],result[1],verified)
                                    with counter_lock:
                                        cache_observations["miss_followup_requests"]+=1
                                valid = valid and result[2] == "hit"
                        with counter_lock:
                            counters[family] += 1
                            outcomes[family][str(result[0])]+=1
                            timings[family].append(result[3])
                            if family=="cold" and result[0]==200:
                                for stage in ("parse_micros","decode_micros","reconstruct_micros","type_infer_micros","format_micros","validation_micros","total_micros"):
                                    phases[family][stage]+=result[1].get("stats",{}).get(stage,0)
                            if not valid and len(failures) < 16:
                                failures.append({"case": case, "family": family, "status": result[0]})
                    except (OSError, http.client.HTTPException, ValueError) as error:
                        with counter_lock:
                            counters["transport_failure"] += 1
                            if len(failures) < 16:
                                failures.append({"case": case, "family": family, "error": str(error)})
                    time.sleep(max(0, 0.05 - (time.monotonic() - began)))

            with concurrent.futures.ThreadPoolExecutor(max_workers=args.concurrency) as executor:
                list(executor.map(lambda _: worker(), range(args.concurrency)))
            elapsed = time.monotonic() - started
            telemetry_stop.set()
            telemetry_worker.join(timeout=4)
            if telemetry_worker.is_alive():
                raise AssertionError("bounded telemetry worker did not stop")
            report["sustained"] = {"elapsed_seconds": elapsed, "case_counts": dict(counters),
                "operation_cases": sum(counters.values()), "actual_http_calls": request_calls-calls_before_load,
                "cached_initial_outcomes_and_refreshes":dict(cache_observations),
                "cache_workload_contract":"The service cache is bounded FIFO, not permanent key residency. A successful initial miss is recorded and explicitly refreshed; the immediate repeated request must be a hit and satisfy the selected output policy. Cache-hit latency excludes the initial warming miss; actual HTTP attempts include both.",
                "families": {family: percentiles(values) for family, values in timings.items()}, "failures": failures,
                "status_counts":{family:dict(values) for family,values in outcomes.items()},
                "cold_phase_totals_micros":dict(phases["cold"]),"phase_scope":"fresh successful cold requests only; cached stats describe their original computation and are not accumulated",
                "telemetry_interval_seconds":5,"telemetry":telemetry,
                "rate_limit": "each worker waits until at least 50ms per case; maximum 100000 cases"}
            sampler.phase = "slow_cached_readers"
            large = 'local text:string="'+('x'*(2*1024*1024))+'"\nreturn text\n' if verified else large_string_packet(2 * 1024 * 1024)
            status, large_result, cache, latency = request("POST", "/v1/decompile", large, timeout=30)
            large_bytes=large.encode() if isinstance(large,str) else large
            slow = {"input_bytes": len(large_bytes), "input_sha256": digest(large_bytes), "warm_status": status,
                    "warm_latency_ms": latency, "warm_cache": cache, "completed": False}
            if successful_result(status,large_result,verified):
                body = payload_body(large)
                for n in range(2):
                    connection = socket.create_connection(("127.0.0.1", port), timeout=5)
                    connection.settimeout(5)
                    sockets.append(connection)
                    header = ("POST /v1/decompile HTTP/1.1\r\nHost: localhost\r\nAuthorization: Bearer " + token
                              + "\r\nX-Request-Id: slow-cache-" + str(n) + "\r\nContent-Type: application/json\r\nContent-Length: "
                              + str(len(body)) + "\r\n\r\n").encode()
                    connection.sendall(header + body)
                    with request_lock:
                        request_calls+=1
                    prefix = bytearray()
                    while len(prefix) < 12:
                        part = connection.recv(12 - len(prefix))
                        if not part:
                            break
                        prefix.extend(part)
                    if bytes(prefix) != b"HTTP/1.1 200":
                        raise AssertionError("cached slow response did not start with 200")
                time.sleep(0.1)
                try:
                    cancelled = request("DELETE", "/v1/requests/slow-cache-0", timeout=2)
                    slow["control_latency_ms"] = cancelled[3]
                    slow["cancellation_acknowledged_active"] = cancelled[0] == 200 and cancelled[1].get("active") is True
                    slow["completed"] = slow["cancellation_acknowledged_active"]
                except (OSError, http.client.HTTPException) as error:
                    slow["control_error"] = str(error)
            else:
                slow["warm_error"] = large_result.get("error")
            for connection in sockets:
                connection.close()
            sockets.clear()
            sampler.phase = "post_load_recovery"
            recovered = False
            for _ in range(20):
                try:
                    status, final, _, _ = request("GET", "/v1/capabilities")
                    if status == 200 and final["accounted_memory"]["used"] <= final["accounted_memory"]["limit"] and final.get("active_jobs",0)==0:
                        recovered = True
                        break
                except (OSError, http.client.HTTPException):
                    pass
                time.sleep(0.05)
            report["slow_cached_readers"] = slow
            report["post_load_recovered"] = recovered
            report["final_accounted_memory"] = final.get("accounted_memory") if recovered else None
            report["final_active_jobs"] = final.get("active_jobs") if recovered else None
            report["final_pending_handoffs"] = final.get("pending_handoffs") if recovered else None
            report["passed"] = not failures and recovered and elapsed >= args.seconds and (slow["completed"] or not args.require_fixes)
            sampler.finish()
            report["memory"] = sampler.report()
            report["passed"] = report["passed"] and report["memory"]["samples"] > 0
            try:
                shutdown_status,shutdown_body,_,shutdown_latency=request("POST","/v1/shutdown",timeout=3)
                service.wait(timeout=15)
                reader=ProcessMemory()
                cleanup_deadline=time.monotonic()+2
                remaining=reader.tree(service.pid)
                while remaining and time.monotonic()<cleanup_deadline:
                    time.sleep(0.05)
                    remaining=reader.tree(service.pid)
                report["shutdown"]={"status":shutdown_status,"latency_ms":shutdown_latency,"acknowledged":shutdown_body.get("shutting_down") is True,"service_exit_code":service.returncode,"remaining_descendants":[{"pid":pid,"name":name} for pid,name in remaining],"cleanup_method":"bounded post-exit parent-PID snapshot; reparenting can limit descendant visibility on non-Windows platforms"}
                report["passed"]=report["passed"] and shutdown_status==200 and shutdown_body.get("shutting_down") is True and service.returncode==0 and not remaining
            except (OSError,http.client.HTTPException,ValueError,subprocess.TimeoutExpired) as error:
                report["shutdown"]={"passed":False,"error":str(error)}
                report["passed"]=False
            report["total_http_attempts_including_preflight_recovery_and_shutdown"]=request_calls
            report_path.write_text(json.dumps(report, indent=2) + "\n")
            if not report["passed"]:
                raise AssertionError("service acceptance failed; inspect " + str(report_path))
            print("sustained service measurement passed: " + str(report_path))
        finally:
            if telemetry_stop is not None:
                telemetry_stop.set()
            if telemetry_worker is not None:
                telemetry_worker.join(timeout=4)
            for connection in sockets:
                connection.close()
            try:
                sampler.finish()
            finally:
                if service.poll() is None:
                    try:
                        request("POST", "/v1/shutdown", timeout=2)
                        service.wait(timeout=12)
                    except (OSError, http.client.HTTPException, subprocess.TimeoutExpired):
                        service.terminate()
                        try:
                            service.wait(timeout=3)
                        except subprocess.TimeoutExpired:
                            service.kill()
                            service.wait(timeout=3)
                service.stderr.close()


if __name__ == "__main__":
    if len(sys.argv)==3 and sys.argv[1]=="--memory-worker":
        memory_worker(int(sys.argv[2]))
    else:
        main()
