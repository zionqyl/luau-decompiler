import argparse
import base64
import hashlib
import hmac
import http.client
import http.server
import json
import os
import pathlib
import re
import secrets
import socket
import subprocess
import threading
import time
import unicodedata
import contextlib
import collections


def digest(data):
    return hashlib.sha256(data).hexdigest()


def storage_path(path):
    absolute = os.path.abspath(path)
    if os.name != "nt" or absolute.startswith("\\\\?\\"):
        return pathlib.Path(absolute)
    return pathlib.Path("\\\\?\\UNC\\" + absolute[2:] if absolute.startswith("\\\\") else "\\\\?\\" + absolute)


def atomic_bytes(path, data):
    path = storage_path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + "." + secrets.token_hex(8) + ".pending")
    owned = False
    try:
        with temporary.open("xb") as output:
            owned = True
            output.write(data)
            output.flush()
            os.fsync(output.fileno())
        os.replace(temporary, path)
    finally:
        if owned:
            temporary.unlink(missing_ok=True)


def json_bytes(value):
    return (json.dumps(value, ensure_ascii=True, separators=(",", ":")) + "\n").encode()


def private_directory(value):
    directory = pathlib.Path(value).resolve()
    repository = pathlib.Path(__file__).resolve().parent.parent
    if directory.is_relative_to(repository) and not directory.is_relative_to(repository / "artifacts"):
        raise ValueError("in-repository captures must stay under ignored artifacts")
    return directory


def safe_name(value):
    result = []
    for character in unicodedata.normalize("NFC", value):
        if ord(character) < 32 or character in '<>:"/\\|?*%':
            result.append("%" + character.encode("utf-8").hex().upper())
        else:
            result.append(character)
    result = "".join(result).rstrip(" .")
    if not result or result in (".", ".."):
        result = "_empty"
    if result.split(".", 1)[0].upper() in {"CON", "PRN", "AUX", "NUL", *[f"COM{i}" for i in range(1, 10)], *[f"LPT{i}" for i in range(1, 10)]}:
        result = "_" + result
    if len(result.encode("utf-8")) > 120:
        result = result[:32] + "~" + digest(value.encode())[:16]
    return result


def decode_segments(segments):
    if not isinstance(segments, list) or not 1 <= len(segments) <= 128:
        raise ValueError("invalid path depth")
    result = []
    for segment in segments:
        if not isinstance(segment, dict) or not isinstance(segment.get("identity"), int) or segment["identity"] < 1:
            raise ValueError("invalid instance identity")
        raw = base64.b64decode(segment["name_base64"], validate=True)
        if len(raw) > 4096:
            raise ValueError("instance name exceeds bound")
        try:
            name = raw.decode("utf-8")
        except UnicodeDecodeError:
            name = "_bytes_" + raw.hex()
        result.append({"identity": segment["identity"], "name": name, "name_base64": segment["name_base64"], "class": segment.get("class", "")})
    return result


def hierarchy_paths(rows):
    children = {}
    paths = {}
    for row in rows:
        segments = row.get("capture_segments") or row["inventory_segments"]
        parent = 0
        for segment in segments:
            identity = segment["identity"]
            key = (parent, identity, segment["name_base64"])
            existing = children.setdefault(parent, {})
            existing[key] = segment["name"]
            paths[key] = safe_name(segment["name"])
            parent = key
    for parent, siblings in children.items():
        collisions = {}
        for identity, name in siblings.items():
            collisions.setdefault(safe_name(name).casefold(), []).append(identity)
        for identities in collisions.values():
            if len(identities) > 1:
                for identity in identities:
                    paths[identity] += "~" + digest(str(identity).encode())[:12]
    output = {}
    for row in rows:
        segments = row.get("capture_segments") or row["inventory_segments"]
        parent = 0
        components = []
        for segment in segments:
            key = (parent, segment["identity"], segment["name_base64"])
            components.append(paths[key])
            parent = key
        components[-1] += ".luau"
        output[row["id"]] = pathlib.PurePosixPath("examples", "Murder Mystery 2", *components).as_posix()
    return output


def classify_corpus(rows, scope):
    engine_hashes = {row.get("bytecode_sha256") for row in rows if (row.get("capture_segments") or row["inventory_segments"])[0]["name"] in scope["engine_services"]}
    output = {}
    for row in rows:
        parts = [part["name"] for part in row.get("capture_segments") or row["inventory_segments"]]
        if parts[0] in scope["engine_services"]:
            category = "roblox_engine_location"
        elif row.get("bytecode_sha256") and row["bytecode_sha256"] in engine_hashes:
            category = "roblox_engine_identical_buffer"
        elif any(part in scope["engine_component_names"] for part in parts):
            category = "engine_component_unconfirmed"
        elif any(part in scope["dependency_component_names"] for part in parts):
            category = "other_dependency_unconfirmed"
        elif any(len(parts) >= len(prefix) and all(expected == "*" or expected == actual for expected, actual in zip(prefix, parts)) for prefix in scope["project_prefixes"]):
            category = "mm2_project_scope"
        else:
            category = "unknown_attribution"
        output[row["id"]] = category
    return output


def object_identity(row):
    parts = row.get("capture_segments") or row["inventory_segments"]
    return parts[-1]["identity"]


def corpus_metrics(rows, results):
    def counts(selected):
        values = {"inventory": len(selected), "captured": sum(row["extraction"] == "captured" for row in selected)}
        for name, predicate in {
            "attempted": lambda item: bool(item),
            "reconstructed": lambda item: bool(item.get("complete") and item.get("source_path")),
            "strict_attempted": lambda item: item.get("validation", {}).get("strict_analysis") in {"passed", "failed"},
            "strict_passed": lambda item: item.get("validation", {}).get("strict_analysis") == "passed",
            "compilation_passed": lambda item: item.get("validation", {}).get("compilation") == "passed",
            "meaningful_typing_passed": lambda item: item.get("validation", {}).get("meaningful_typing", {}).get("passed") is True,
            "strict_and_meaningful": lambda item: item.get("validation", {}).get("strict_analysis") == "passed" and item.get("validation", {}).get("meaningful_typing", {}).get("passed") is True,
            "validated_decoding_passed": lambda item: item.get("decoding") == "passed" or bool(item.get("complete")),
            "verified_typed": lambda item: item.get("validation", {}).get("output_policy") == "verified_typed" and item.get("validation", {}).get("required_passed") is True,
        }.items():
            values[name] = sum(predicate(results.get(row.get("bytecode_sha256"), {})) for row in selected)
        failures = collections.Counter()
        for row in selected:
            item = results.get(row.get("bytecode_sha256"), {})
            if row["extraction"] != "captured":
                failures["extraction:" + row["extraction"]] += 1
            elif not item:
                failures["not_processed"] += 1
            elif not item.get("complete"):
                error = item.get("error") or {}
                failures[error.get("stage", "transport_or_resource")] += 1
        values["failure_stages"] = dict(sorted(failures.items()))
        return values
    unique = {}
    objects = {}
    for row in rows:
        identity = object_identity(row)
        previous = objects.get(identity)
        if previous is None or (row.get("captured_at") or 0, row["id"]) > (previous.get("captured_at") or 0, previous["id"]):
            objects[identity] = row
        if row.get("bytecode_sha256"):
            unique.setdefault(row["bytecode_sha256"], row)
    return {"observations": counts(rows), "instances": counts(list(objects.values())), "unique_serialized_buffers": counts(list(unique.values()))}


def export_corpus(args):
    directory = private_directory(args.directory)
    capture_bytes = (directory / "manifest.json").read_bytes()
    capture = json.loads(capture_bytes)
    scope_path = pathlib.Path(args.scope).resolve()
    scope_bytes = scope_path.read_bytes()
    scope = json.loads(scope_bytes)
    if scope.get("schema") != 1 or scope.get("place_id") != capture["client"].get("place_id") or not scope.get("permission"):
        raise ValueError("publication scope lacks matching place identity or supplied permission")
    classifications = classify_corpus(capture["scripts"], scope)
    outcomes = {}
    generations = []
    for name in [args.fallback_generation, args.generation]:
        if not name:
            continue
        if not re.fullmatch(r"[A-Za-z0-9_-]{1,96}", name):
            raise ValueError("invalid generation identity")
        path = directory / "generations" / name / "processing.json"
        raw = path.read_bytes()
        report = json.loads(raw)
        generations.append({"identity": name, "report_sha256": digest(raw), "engine_version": report["engine_version"], "executable_sha256": report["executable_sha256"], "configuration_sha256": report["configuration_sha256"]})
        for sha, result in report["results"].items():
            outcomes[sha] = {**result, "generation": name}
    metrics = {"whole_inventory": corpus_metrics(capture["scripts"], outcomes)}
    for category in sorted(set(classifications.values())):
        metrics[category] = corpus_metrics([row for row in capture["scripts"] if classifications[row["id"]] == category], outcomes)
    published = []
    total_bytes = 0
    written = {}
    variants = {}
    for row in capture["scripts"]:
        item = outcomes.get(row.get("bytecode_sha256"), {})
        if classifications[row["id"]] == "mm2_project_scope" and item.get("complete") and item.get("source_path"):
            variants.setdefault(row["output_path"].casefold(), set()).add((object_identity(row), row["bytecode_sha256"]))
    destination = pathlib.Path(args.publish_directory).resolve() if args.publish_directory else None
    previous = {}
    if destination and (destination / "manifest.json").exists():
        previous = {row["output_path"]: row["source_sha256"] for row in json.loads((destination / "manifest.json").read_bytes()).get("files", []) if row.get("source_sha256") and row.get("output_path")}
    for row in capture["scripts"]:
        if classifications[row["id"]] != "mm2_project_scope":
            continue
        item = outcomes.get(row.get("bytecode_sha256"), {})
        parts = row.get("capture_segments") or row["inventory_segments"]
        record = {"instance_identity": capture["snapshot"] + ":object:" + str(object_identity(row)), "observations": [{"identity": row["instance_identity"], "id": row["id"], "captured_at_unix_ms": row.get("captured_at")}], "class": row["class"], "original_segments": [{"name": part["name"], "name_base64": part["name_base64"], "identity": part["identity"]} for part in parts], "extraction": row["extraction"], "input_sha256": row.get("bytecode_sha256"), "input_bytes": row.get("bytecode_bytes"), "complete": bool(item.get("complete")), "generation": item.get("generation"), "source_sha256": item.get("source_sha256"), "validation": item.get("validation", {"strict_analysis": "not_run", "required_passed": False}), "error": item.get("error"), "behavior": "not_run; captured code never executed"}
        if item.get("complete") and item.get("source_path"):
            source_path = (directory / item["source_path"]).resolve()
            if not source_path.is_relative_to(directory):
                raise ValueError("source result escapes the private capture")
            source = source_path.read_bytes()
            generation = next(g for g in generations if g["identity"] == item["generation"])
            header = ("--[=[\n    Luau Decompiler " + generation["engine_version"] + "\n    Made by @zionqyl\n    https://github.com/zionqyl/luau-decompiler\n]=]\n\n").encode()
            if digest(source) != item["source_sha256"] or not (source.startswith(header) or source.startswith(b"--!strict\n" + header)):
                raise ValueError("source identity or finalized attribution does not match the engine")
            if len(source) > 4 << 20:
                raise ValueError("public output exceeds its per-file bound")
            relative = pathlib.PurePosixPath(row["output_path"])
            if relative.parts[:2] != ("examples", "Murder Mystery 2") or any(part in {"", ".", ".."} for part in relative.parts):
                raise ValueError("public output path is not the observed safe game hierarchy")
            relative = pathlib.PurePosixPath(*relative.parts[2:])
            if len(variants[row["output_path"].casefold()]) > 1:
                suffix = digest((str(object_identity(row)) + ":" + row["bytecode_sha256"]).encode())[:12]
                relative = relative.with_name(relative.stem + "~" + suffix + relative.suffix)
            record["output_path"] = relative.as_posix()
            previous_hash = written.get(relative.as_posix().casefold())
            if previous_hash is not None and previous_hash != item["source_sha256"]:
                raise ValueError("distinct source versions collided in the publication hierarchy")
            if previous_hash is None:
                total_bytes += len(source)
                written[relative.as_posix().casefold()] = item["source_sha256"]
            if total_bytes > 256 << 20:
                raise ValueError("public corpus exceeds its total bound")
            if destination and previous_hash is None:
                target = (destination / relative).resolve()
                if not target.is_relative_to(destination):
                    raise ValueError("public output escapes its destination")
                stored_target = storage_path(target)
                if stored_target.exists() and digest(stored_target.read_bytes()) not in {item["source_sha256"], previous.get(relative.as_posix())}:
                    raise ValueError("refusing to overwrite a modified or unowned public file")
                atomic_bytes(target, source)
        published.append(record)
    records = {}
    for row in published:
        identity = (row["instance_identity"], row["input_sha256"], json.dumps(row["original_segments"], sort_keys=True), row["extraction"])
        if identity in records:
            records[identity]["observations"].extend(row["observations"])
        else:
            records[identity] = row
    public = {"schema": 1, "release": generations[-1]["engine_version"], "snapshot": capture["snapshot"], "scope": "Client-accessible snapshot; reviewed MM2 project paths only. Authorship of erased source is not established by a path. Engine, dependency candidates and unknown attribution are excluded from publication.", "environment": capture["client"], "rights": {"permission": scope["permission"], "tool_license": "MIT; does not license third-party code", "original_notices": "No original source comments/notices available in retained bytecode; none fabricated or removed from recovered source."}, "capture_manifest_sha256": digest(capture_bytes), "classification_sha256": digest(scope_bytes), "classification_basis": scope["classification_basis"], "generations": generations, "coverage": metrics, "published_outputs": len(written), "source_observations": sum(bool(row.get("output_path")) for row in published), "published_source_bytes": total_bytes, "files": list(records.values()), "limitations": ["Observation identities are inventory-record identities; terminal captured segment identities identify actual objects. Repeated observations are preserved without inflating object or file counts.", "Unknown or later-loaded and server-only scripts are outside the observed snapshot.", "Compilation and strict typing are source-quality results, not captured-code behavioral equivalence.", "Signature structure can be recognized; cryptographic authenticity is not verified."]}
    if destination:
        atomic_bytes(destination / "manifest.json", json_bytes(public))
    if args.report:
        atomic_bytes(pathlib.Path(args.report), json_bytes({key: value for key, value in public.items() if key != "files"}))
    print(json.dumps({"published_outputs": public["published_outputs"], "published_source_bytes": total_bytes, "coverage": metrics}, indent=2))


class Capture:
    def __init__(self, directory, snapshot, maximum_inventory=50000, maximum_blob=8 << 20, maximum_bytes=512 << 20):
        self.directory = private_directory(directory)
        self.directory.mkdir(parents=True, exist_ok=True)
        self.snapshot = snapshot
        self.maximum_inventory = maximum_inventory
        self.maximum_blob = maximum_blob
        self.maximum_bytes = maximum_bytes
        self.rows = {}
        self.client = None
        self.inventory_complete = False
        self.capture_complete = False
        self.journal = self.directory / "capture.journal.jsonl"
        self.recovered_partial_bytes = 0
        self.maximum_journal_bytes = 256 << 20
        self.journal_bytes = self.journal.stat().st_size if self.journal.exists() else 0
        if self.journal_bytes > self.maximum_journal_bytes:
            raise ValueError("aggregate metadata storage exceeded")
        self.blobs = {path.stem: path.stat().st_size for path in (self.directory / "original-bytecode").glob("*.bc")}
        self.used_bytes = sum(self.blobs.values())
        self.checked_blobs = set()
        self.replay()

    def replay(self):
        if not self.journal.exists():
            return
        content = self.journal.read_bytes()
        complete = content.rfind(b"\n") + 1
        self.recovered_partial_bytes = len(content) - complete
        if complete != len(content):
            atomic_bytes(self.journal, content[:complete])
        for line in content[:complete].splitlines():
            self.apply(json.loads(line))

    def append(self, record):
        data = json_bytes(record)
        if self.journal_bytes + len(data) > self.maximum_journal_bytes:
            raise ValueError("aggregate metadata storage exceeded")
        with self.journal.open("ab") as output:
            output.write(data)
            output.flush()
            os.fsync(output.fileno())
        self.journal_bytes += len(data)
        self.apply(record)

    def apply(self, record):
        if record["snapshot"] != self.snapshot:
            raise ValueError("snapshot mismatch")
        if record["kind"] == "inventory":
            self.client = record["client"]
            for row in record["rows"]:
                previous = self.rows.get(row["id"])
                if previous and previous["inventory_segments"] != row["inventory_segments"]:
                    raise ValueError("snapshot identity reused for a different instance")
                self.rows.setdefault(row["id"], row)
            self.inventory_complete = self.inventory_complete or record.get("complete", False)
        elif record["kind"] == "capture":
            for row in record["rows"]:
                self.rows[row["id"]].update(row)
        elif record["kind"] == "complete":
            self.capture_complete = True

    def inventory(self, request):
        if request.get("snapshot") != self.snapshot or not isinstance(request.get("client"), dict):
            raise ValueError("invalid snapshot or client")
        rows = request.get("rows")
        if not isinstance(rows, list) or len(rows) > 1000:
            raise ValueError("inventory batch exceeds bound")
        checked = []
        for row in rows:
            identity = row.get("id")
            if not isinstance(identity, int) or not 1 <= identity <= self.maximum_inventory:
                raise ValueError("invalid inventory identity")
            segments = decode_segments(row["segments"])
            if identity in self.rows and self.rows[identity]["inventory_segments"] != segments:
                raise ValueError("snapshot identity reused for a different instance")
            if identity not in self.rows:
                checked.append({"id": identity, "instance_identity": f"{self.snapshot}:{identity}", "class": row["class"], "inventory_segments": segments, "inventory_path_status": row.get("path_status", "parented"), "run_context": row.get("run_context"), "debug_id": row.get("debug_id"), "extraction": "pending"})
        if len(set(self.rows).union(row["id"] for row in checked)) > self.maximum_inventory:
            raise ValueError("inventory exceeds bound")
        if checked or request.get("complete") and not self.inventory_complete:
            self.append({"kind": "inventory", "snapshot": self.snapshot, "client": request["client"], "rows": checked, "complete": bool(request.get("complete"))})
        return self.status()

    def capture(self, request):
        if request.get("snapshot") != self.snapshot or not self.inventory_complete:
            raise ValueError("snapshot not inventoried")
        rows = request.get("rows")
        if not isinstance(rows, list) or len(rows) > 1000:
            raise ValueError("capture batch exceeds bound")
        checked = []
        for row in rows:
            identity = row.get("id")
            if identity not in self.rows:
                raise ValueError("capture identity not inventoried")
            status = row.get("status")
            if status not in {"captured", "getter_error", "empty_bytecode", "unsupported_target_context", "disappeared", "path_error", "input_limit", "aggregate_limit", "cancelled"}:
                raise ValueError("invalid capture status")
            item = {"id": identity, "extraction": status, "captured_at": row.get("captured_at"), "returned_bytes": row.get("returned_bytes", 0)}
            if row.get("segments"):
                item["capture_segments"] = decode_segments(row["segments"])
            if row.get("error_base64"):
                error = base64.b64decode(row["error_base64"], validate=True)
                if len(error) > 4096:
                    raise ValueError("error exceeds bound")
                item["error_base64"] = row["error_base64"]
            if status == "captured":
                raw = base64.b64decode(row["bytecode_base64"], validate=True)
                if not raw or len(raw) > self.maximum_blob:
                    raise ValueError("bytecode exceeds bound")
                sha = digest(raw)
                blobs = self.directory / "original-bytecode"
                blobs.mkdir(exist_ok=True)
                path = blobs / (sha + ".bc")
                if sha in self.blobs:
                    if sha not in self.checked_blobs and digest(path.read_bytes()) != sha:
                        raise ValueError("stored raw bytecode integrity failed")
                    self.checked_blobs.add(sha)
                else:
                    if self.used_bytes + len(raw) > self.maximum_bytes:
                        raise ValueError("aggregate capture storage exceeded")
                    atomic_bytes(path, raw)
                    self.blobs[sha] = len(raw)
                    self.used_bytes += len(raw)
                    self.checked_blobs.add(sha)
                item.update({"bytecode_sha256": sha, "bytecode_bytes": len(raw), "bytecode_path": path.relative_to(self.directory).as_posix(), "header_hex": raw[:8].hex()})
            previous = self.rows[identity]
            if previous["extraction"] != "pending" and any(previous.get(key) != value for key, value in item.items() if key not in {"captured_at"}):
                raise ValueError("capture retry changed an acknowledged instance")
            if previous["extraction"] == "pending":
                checked.append(item)
        if checked:
            self.append({"kind": "capture", "snapshot": self.snapshot, "rows": checked})
        return self.status()

    def status(self):
        counts = {}
        for row in self.rows.values():
            counts[row["extraction"]] = counts.get(row["extraction"], 0) + 1
        return {"snapshot": self.snapshot, "inventory": len(self.rows), "inventory_complete": self.inventory_complete, "capture_complete": self.capture_complete, "outcomes": counts}

    def save(self):
        rows = [self.rows[key] for key in sorted(self.rows)]
        paths = hierarchy_paths(rows)
        for row in rows:
            row["output_path"] = paths[row["id"]]
        manifest = {"schema": 1, "snapshot": self.snapshot, "scope": "client-accessible snapshot; no captured code executed or required", "rights": {"redistribution": "not_established", "publication": "private_only"}, "client": self.client, "limits": {"inventory": self.maximum_inventory, "per_blob_bytes": self.maximum_blob, "unique_bytecode_bytes": self.maximum_bytes}, "status": self.status(), "recovered_partial_journal_bytes": self.recovered_partial_bytes, "scripts": rows}
        atomic_bytes(self.directory / "manifest.json", json_bytes(manifest))
        return manifest


def serve(args):
    snapshot = args.snapshot or time.strftime("mm2-%Y%m%dT%H%M%SZ", time.gmtime()) + "-" + secrets.token_hex(4)
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,96}", snapshot):
        raise ValueError("invalid snapshot name")
    capture = Capture(args.directory, snapshot, args.max_inventory, args.max_blob_mib << 20, args.max_total_mib << 20)
    token = secrets.token_urlsafe(36)

    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self, *values):
            pass

        def reply(self, status, body):
            raw = json_bytes(body)
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(raw)))
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(raw)

        def authenticated(self):
            return hmac.compare_digest(self.headers.get("Authorization", ""), "Bearer " + token)

        def do_GET(self):
            if not self.authenticated():
                self.reply(401, {"error": "authentication required"})
            elif self.path == "/state":
                self.reply(200, capture.status())
            else:
                self.reply(404, {"error": "unknown route"})

        def do_POST(self):
            if not self.authenticated():
                self.reply(401, {"error": "authentication required"})
                return
            try:
                self.connection.settimeout(15)
                length = int(self.headers.get("Content-Length", "-1"))
                if length < 0 or length > args.max_wire_mib << 20:
                    self.reply(413, {"error": "request body exceeds bound"})
                    return
                body = self.rfile.read(length)
                if len(body) != length:
                    raise ValueError("truncated request body")
                if self.path == "/probe":
                    self.reply(200, {"bytes": len(body), "sha256": digest(body), "base64": base64.b64encode(body).decode()})
                    return
                request = json.loads(body)
                if self.path == "/inventory":
                    result = capture.inventory(request)
                elif self.path == "/capture":
                    result = capture.capture(request)
                elif self.path == "/complete":
                    if request.get("snapshot") != snapshot:
                        raise ValueError("snapshot mismatch")
                    if any(row["extraction"] == "pending" for row in capture.rows.values()):
                        raise ValueError("capture still has pending identities")
                    capture.append({"kind": "complete", "snapshot": snapshot})
                    capture.save()
                    result = capture.status()
                elif self.path == "/shutdown":
                    capture.save()
                    result = capture.status()
                    threading.Thread(target=self.server.shutdown, daemon=True).start()
                else:
                    self.reply(404, {"error": "unknown route"})
                    return
                if self.path == "/inventory" and request.get("complete"):
                    capture.save()
                self.reply(200, result)
            except (ValueError, KeyError, TypeError, OSError) as error:
                self.reply(422, {"error": str(error)[:512]})

    server = http.server.HTTPServer(("127.0.0.1", args.port), Handler)
    control = {"snapshot": snapshot, "endpoint": f"http://127.0.0.1:{server.server_port}", "token": token, "directory": str(capture.directory)}
    control_path = capture.directory / "control.private.json"
    atomic_bytes(control_path, json_bytes(control))
    print(json.dumps({key: value for key, value in control.items() if key != "token"}), flush=True)
    try:
        server.serve_forever(poll_interval=0.1)
    finally:
        capture.save()
        server.server_close()
        control_path.unlink(missing_ok=True)


@contextlib.contextmanager
def processing_service(binary, config_path, directory, timeout):
    with socket.socket() as reservation:
        reservation.bind(("127.0.0.1", 0))
        port = reservation.getsockname()[1]
    token = secrets.token_urlsafe(36)
    environment = dict(os.environ)
    environment["LDP_CAPTURE_PROCESS_TOKEN"] = token
    command = [str(binary), "serve", "--listen", f"127.0.0.1:{port}", "--workers", "2", "--cpu-threads", "2", "--queue", "4", "--cache-mib", "0", "--memory-mib", "768", "--timeout-ms", str(timeout * 1000), "--token-env", "LDP_CAPTURE_PROCESS_TOKEN", "--config", str(config_path)]
    log = (directory / "processing-service.log").open("ab")
    process = subprocess.Popen(command, env=environment, stdout=log, stderr=log)
    lifecycle = {"started": True, "pid": process.pid, "ready": False}
    control = directory / "processing-control.private.json"
    atomic_bytes(control, json_bytes({"pid": process.pid, "port": port, "token": token}))

    def exchange(method, path, body=None):
        client = http.client.HTTPConnection("127.0.0.1", port, timeout=timeout + 5)
        try:
            headers = {"Authorization": "Bearer " + token, "Content-Type": "application/json", "X-Timeout-Ms": str(timeout * 1000)}
            client.request(method, path, body, headers)
            response = client.getresponse()
            raw = response.read((32 << 20) + 1)
            if len(raw) > 32 << 20:
                raise ValueError("bounded response size exceeded")
            return response.status, json.loads(raw)
        finally:
            client.close()

    try:
        deadline = time.monotonic() + 15
        while True:
            if process.poll() is not None:
                raise ValueError("processing service exited during startup; inspect private service log")
            try:
                status, _ = exchange("GET", "/readyz")
                if status == 200:
                    break
            except (OSError, http.client.HTTPException):
                pass
            if time.monotonic() >= deadline:
                raise ValueError("processing service readiness deadline exceeded")
            time.sleep(0.05)
        lifecycle["ready"] = True
        yield exchange
    finally:
        if process.poll() is None:
            try:
                lifecycle["shutdown_status"] = exchange("POST", "/v1/shutdown", b"")[0]
            except (OSError, ValueError, http.client.HTTPException):
                pass
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                lifecycle["forced_termination"] = True
                process.kill()
                process.wait(timeout=5)
        lifecycle["exit_code"] = process.poll()
        atomic_bytes(directory / "processing-service-lifecycle.json", json_bytes(lifecycle))
        log.close()
        control.unlink(missing_ok=True)


def process(args):
    directory = private_directory(args.directory)
    capture_manifest = (directory / "manifest.json").read_bytes()
    manifest = json.loads(capture_manifest)
    binary = pathlib.Path(args.binary).resolve()
    version = subprocess.check_output([str(binary), "--version"], timeout=15).decode().strip().split()[-1]
    generation_name = args.generation or args.encoding + "-" + args.policy + ("-unchecked" if args.no_validation else "-checked")
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,96}", generation_name):
        raise ValueError("invalid generation identity")
    generation_directory = directory / "generations" / generation_name
    generation_directory.mkdir(parents=True, exist_ok=True)
    configuration = {"input_format": "luau_bytecode", "bytecode_encoding": args.encoding, "output_policy": args.policy, "limits": {"max_bytes": 8 << 20, "max_output_bytes": 4 << 20, "max_analysis_steps": 4000000}}
    if args.policy == "verified_typed":
        configuration["validation"] = {"mode": "strict_required", "timeout_ms": min(args.timeout_seconds * 1000, 10000), "max_attempts": 2}
    elif args.policy == "annotated":
        configuration["validation"] = {"mode": "check", "timeout_ms": min(args.timeout_seconds * 1000, 10000), "max_attempts": 2}
    if args.no_validation:
        if args.policy == "verified_typed":
            raise ValueError("verified typing cannot disable validation")
        configuration.update({"validation": {"mode": "off"}, "typing": {"mode": "off"}})
    config_path = generation_directory / "generation.config.json"
    atomic_bytes(config_path, json_bytes(configuration))
    settings_hash = digest(config_path.read_bytes())
    report_path = generation_directory / "processing.json"
    report = json.loads(report_path.read_bytes()) if report_path.exists() else {"schema": 1, "snapshot": manifest["snapshot"], "capture_manifest_sha256": digest(capture_manifest), "executable_sha256": digest(binary.read_bytes()), "configuration_sha256": settings_hash, "engine_version": version, "results": {}}
    if report["executable_sha256"] != digest(binary.read_bytes()) or report["configuration_sha256"] != settings_hash:
        raise ValueError("generation identity changed; use a separate processing directory or explicitly reset processing state")
    journal = generation_directory / "processing.journal.jsonl"
    if journal.exists():
        content = journal.read_bytes()
        complete = content.rfind(b"\n") + 1
        if complete != len(content):
            atomic_bytes(journal, content[:complete])
        for line in content[:complete].splitlines():
            item = json.loads(line)
            if item["executable_sha256"] != report["executable_sha256"] or item["configuration_sha256"] != settings_hash:
                raise ValueError("processing journal identities differ")
            report["results"][item["sha256"]] = item["result"]
    started = time.monotonic()
    generated_bytes = sum(row.get("source_bytes", 0) for row in report["results"].values())
    priorities = {"Workspace": 1, "Players": 2, "ReplicatedFirst": 3, "ReplicatedStorage": 4, "StarterGui": 5, "StarterPlayer": 6, "CoreGui": 8, "CorePackages": 9}
    rows = sorted(manifest["scripts"], key=lambda row: (priorities.get(row["inventory_segments"][0]["class"], 7), row["id"]))
    if args.prioritize_scope:
        scope = json.loads(pathlib.Path(args.prioritize_scope).read_bytes())
        classifications = classify_corpus(rows, scope)
        rows.sort(key=lambda row: classifications[row["id"]] != "mm2_project_scope")
    if args.roots:
        selected = set(args.roots.split(","))
        groups = {}
        for row in rows:
            root = row["inventory_segments"][0]["class"]
            if root in selected:
                groups.setdefault(root, []).append(row)
        rows = [group[index] for index in range(max(map(len, groups.values()), default=0)) for group in groups.values() if index < len(group)]
    if args.only_source_from:
        if not re.fullmatch(r"[A-Za-z0-9_-]{1,96}", args.only_source_from):
            raise ValueError("invalid prior generation identity")
        prior_path = directory / "generations" / args.only_source_from / "processing.json"
        prior_results = json.loads(prior_path.read_bytes())["results"]
        accepted = {sha for sha, result in prior_results.items() if result.get("source_path")}
        rows = [row for row in rows if row.get("bytecode_sha256") in accepted]
    selected_identities = {row["id"] for row in rows}
    report.pop("paused", None)
    initial_processed = len(report["results"])
    with processing_service(binary, config_path, generation_directory, args.timeout_seconds) as exchange:
        for row in rows:
            if row["extraction"] != "captured":
                continue
            sha = row["bytecode_sha256"]
            if sha in report["results"]:
                continue
            if (generation_directory / "pause").exists() or args.max_inputs and len(report["results"]) - initial_processed >= args.max_inputs:
                report["paused"] = "explicit pause or per-run input bound"
                break
            if time.monotonic() - started > args.total_seconds or generated_bytes > args.max_output_mib << 20:
                report["paused"] = "aggregate processing deadline or output budget"
                break
            work = generation_directory / "processed-by-hash" / sha
            source = work / "output.luau"
            quality = work / "quality.json"
            raw = (directory / row["bytecode_path"]).read_bytes()
            if digest(raw) != sha:
                raise ValueError("original bytecode hash changed")
            try:
                status, metadata = exchange("POST", "/v1/process", json_bytes({"input_base64": base64.b64encode(raw).decode(), "input_format": "luau_bytecode"}))
                result = {"http_status": status, "complete": bool(metadata.get("complete")), "error": metadata.get("error")}
                stage = (metadata.get("error") or {}).get("stage")
                if result["complete"] or stage in {"structure", "semantics", "cfg", "dataflow", "bindings", "types", "format"}:
                    result["decoding"] = "passed"
                elif stage in {"decode", "representation", "input_format", "input_encoding"}:
                    result["decoding"] = "failed"
                else:
                    result["decoding"] = "not_recorded"
                result["reconstruction_quality"] = metadata.get("quality")
                if metadata.get("stats"):
                    result["decoded_instructions"] = metadata["stats"].get("instructions")
                    result["decoded_prototypes"] = metadata["stats"].get("prototypes")
                if metadata.get("representation"):
                    result["representation"] = metadata["representation"]
                if isinstance(metadata.get("source"), str):
                    output = metadata["source"].encode()
                    expected = ("--[=[\n    Luau Decompiler " + version + "\n    Made by @zionqyl\n    https://github.com/zionqyl/luau-decompiler\n]=]").encode()
                    if expected not in output[:1024]:
                        raise ValueError("engine returned source without its canonical attribution header")
                    atomic_bytes(source, output)
                    result.update({"source_path": source.relative_to(directory).as_posix(), "source_sha256": digest(output), "source_bytes": len(output)})
                    generated_bytes += len(output)
                if "validation" in metadata:
                    validation = metadata["validation"]
                    result["validation"] = {key: validation.get(key) for key in ["output_policy", "required_passed", "syntax", "compilation", "strict_analysis", "meaningful_typing"]}
                    result["diagnostic_count"] = len(validation.get("diagnostics", []))
                    result["quality_path"] = quality.relative_to(directory).as_posix()
                    atomic_bytes(quality, json_bytes({key: metadata.get(key) for key in ["input_sha256", "complete", "profile", "quality", "validation", "assumptions", "type_report", "baseline_source"]}))
            except (OSError, ValueError, http.client.HTTPException) as error:
                result = {"complete": False, "transport_error": str(error)[:512]}
            report["results"][sha] = result
            with journal.open("ab") as output:
                output.write(json_bytes({"sha256": sha, "result": result, "executable_sha256": report["executable_sha256"], "configuration_sha256": settings_hash}))
            if len(report["results"]) % 1000 == 0:
                print(json.dumps({"processed_unique_inputs": len(report["results"]), "elapsed_seconds": time.monotonic() - started}), flush=True)
        report["elapsed_seconds"] = time.monotonic() - started
        report["attempted_this_run"] = len(report["results"]) - initial_processed
        atomic_bytes(report_path, json_bytes(report))
    export_root = generation_directory / "corpus"
    for row in manifest["scripts"]:
        result = report["results"].get(row.get("bytecode_sha256"))
        if result:
            row.setdefault("decompilation_attempts", {})[generation_name] = {"result_id": row["bytecode_sha256"], "complete": bool(result.get("complete")), "source_sha256": result.get("source_sha256"), "quality_status": result.get("validation", {}).get("strict_analysis", "not_run")}
            if result.get("source_path"):
                try:
                    atomic_bytes(export_root / row["output_path"], (directory / result["source_path"]).read_bytes())
                    row["decompilation_attempts"][generation_name]["export_path"] = (export_root / row["output_path"]).relative_to(directory).as_posix()
                except OSError as error:
                    row["decompilation_attempts"][generation_name]["export_error"] = str(error)[:512]
        elif row["extraction"] == "captured":
            row.setdefault("decompilation_attempts", {})[generation_name] = {"status": "pending" if row["id"] in selected_identities else "not_selected"}
    manifest["generation"] = {"configuration": configuration, "configuration_sha256": settings_hash, "executable_sha256": report["executable_sha256"], "engine_version": version, "representation_basis": args.representation_basis, "behavioral_verification": "not_run; captured game code is never executed"}
    manifest["generation_counts"] = {
        "unique_inputs_processed": len(report["results"]),
        "scripts_with_output": sum(bool(report["results"].get(row.get("bytecode_sha256"), {}).get("source_path")) for row in manifest["scripts"]),
        "scripts_complete": sum(bool(report["results"].get(row.get("bytecode_sha256"), {}).get("complete")) for row in manifest["scripts"]),
        "verified_typed": sum(bool(report["results"].get(row.get("bytecode_sha256"), {}).get("validation", {}).get("required_passed") and report["results"].get(row.get("bytecode_sha256"), {}).get("validation", {}).get("output_policy") == "verified_typed") for row in manifest["scripts"]),
    }
    manifest.setdefault("generation_history", {})[generation_name] = {"configuration": configuration, "executable_sha256": report["executable_sha256"], "report_path": report_path.relative_to(directory).as_posix(), "counts": manifest["generation_counts"], "representation_basis": args.representation_basis}
    manifest["capture_manifest_sha256"] = digest(capture_manifest)
    atomic_bytes(generation_directory / "generation-manifest.json", json_bytes(manifest))
    print(json.dumps(manifest["generation_counts"]))


def main():
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    receiver = commands.add_parser("serve")
    receiver.add_argument("--directory", required=True)
    receiver.add_argument("--snapshot")
    receiver.add_argument("--port", type=int, default=0)
    receiver.add_argument("--max-inventory", type=int, default=50000)
    receiver.add_argument("--max-blob-mib", type=int, default=8)
    receiver.add_argument("--max-total-mib", type=int, default=512)
    receiver.add_argument("--max-wire-mib", type=int, default=16)
    processor = commands.add_parser("process")
    processor.add_argument("--directory", required=True)
    processor.add_argument("--binary", required=True)
    processor.add_argument("--encoding", choices=["auto", "upstream", "roblox_opcode227", "roblox_signed_74171870"], required=True)
    processor.add_argument("--representation-basis", required=True)
    processor.add_argument("--policy", choices=["faithful", "annotated", "verified_typed"], default="verified_typed")
    processor.add_argument("--no-validation", action="store_true")
    processor.add_argument("--generation")
    processor.add_argument("--roots")
    processor.add_argument("--max-inputs", type=int)
    processor.add_argument("--only-source-from")
    processor.add_argument("--prioritize-scope")
    processor.add_argument("--timeout-seconds", type=int, default=20)
    processor.add_argument("--total-seconds", type=int, default=1800)
    processor.add_argument("--max-output-mib", type=int, default=512)
    exporter = commands.add_parser("corpus")
    exporter.add_argument("--directory", required=True)
    exporter.add_argument("--generation", required=True)
    exporter.add_argument("--fallback-generation")
    exporter.add_argument("--scope", required=True)
    exporter.add_argument("--publish-directory")
    exporter.add_argument("--report")
    args = parser.parse_args()
    if args.command == "serve":
        if not 1 <= args.max_inventory <= 100000 or not 1 <= args.max_blob_mib <= 8 or not 1 <= args.max_total_mib <= 2048 or not 1 <= args.max_wire_mib <= 64:
            parser.error("capture limits exceed supported bounds")
        if args.max_wire_mib * (1 << 20) < ((args.max_blob_mib * (1 << 20) + 2) // 3) * 4 + (2 << 20):
            parser.error("wire budget cannot admit the configured maximum blob and metadata")
        serve(args)
    elif args.command == "process":
        if not 1 <= args.timeout_seconds <= 120 or not 1 <= args.total_seconds <= 7200 or not 1 <= args.max_output_mib <= 2048 or args.max_inputs is not None and args.max_inputs < 1:
            parser.error("processing limits exceed supported bounds")
        process(args)
    else:
        export_corpus(args)


if __name__ == "__main__":
    main()
