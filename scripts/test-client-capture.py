import base64
import importlib.util
import pathlib
import contextlib
import shutil
import uuid
import unittest
import unittest.mock
import argparse
import json
import os
import io

spec = importlib.util.spec_from_file_location("capture_client", pathlib.Path(__file__).with_name("capture-client.py"))
capture_client = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture_client)


def segment(identity, name, kind="Folder"):
    return {"identity": identity, "name_base64": base64.b64encode(name.encode()).decode(), "class": kind}


@contextlib.contextmanager
def temporary_directory():
    root = pathlib.Path(__file__).resolve().parent.parent
    parent = root / "artifacts" / "client-capture-tests"
    parent.mkdir(parents=True, exist_ok=True)
    directory = (parent / ("case-" + uuid.uuid4().hex)).resolve()
    directory.mkdir()
    if not directory.is_relative_to(parent.resolve()):
        raise ValueError("temporary directory outside test workspace")
    try:
        yield directory
    finally:
        if not directory.resolve().is_relative_to(parent.resolve()):
            raise ValueError("cleanup target outside test workspace")
        shutil.rmtree(capture_client.storage_path(directory))


class ClientCaptureTests(unittest.TestCase):
    @unittest.skipUnless(os.name == "nt", "Windows extended-path filesystem boundary")
    def test_long_observed_hierarchy_writes_without_global_path_policy_changes(self):
        with temporary_directory() as directory:
            path = directory.joinpath(*(["observed_" + "a" * 44] * 6), "Script.luau")
            self.assertGreater(len(str(path)), 350)
            capture_client.atomic_bytes(path, b"retained engine bytes")
            self.assertEqual(capture_client.storage_path(path).read_bytes(), b"retained engine bytes")

    def test_project_scope_excludes_engine_identical_buffers_and_uncertain_dependencies(self):
        scope = {"engine_services": ["CorePackages"], "engine_component_names": ["PlayerModule"], "dependency_component_names": ["Maid"], "project_prefixes": [["ReplicatedStorage", "Modules"]]}
        rows = []
        for identity, names, sha in [(1, ["CorePackages", "Engine"], "same"), (2, ["ReplicatedStorage", "Modules", "Copy"], "same"), (3, ["ReplicatedStorage", "Modules", "Maid"], "dependency"), (4, ["ReplicatedStorage", "Modules", "Game"], "game"), (5, ["Workspace", "Unknown"], "unknown")]:
            rows.append({"id": identity, "bytecode_sha256": sha, "inventory_segments": [{"name": name} for name in names]})
        self.assertEqual(capture_client.classify_corpus(rows, scope), {1: "roblox_engine_location", 2: "roblox_engine_identical_buffer", 3: "other_dependency_unconfirmed", 4: "mm2_project_scope", 5: "unknown_attribution"})

    def process_fixture(self, directory, observation_style=None):
        snapshot = directory / "snapshot"
        capture = capture_client.Capture(snapshot, "controlled-test")
        count = 2 if observation_style else 1
        parts = [[segment(1, "ReplicatedStorage", "ReplicatedStorage"), segment(2, "Modules"), segment(3 + (index if observation_style == "distinct_objects" else 0), "Game", "ModuleScript")] for index in range(count)]
        capture.inventory({"snapshot": "controlled-test", "client": {"place_id": 142823291}, "complete": True, "rows": [{"id": index + 1, "class": "ModuleScript", "segments": path} for index, path in enumerate(parts)]})
        capture.capture({"snapshot": "controlled-test", "rows": [{"id": index + 1, "status": "captured", "segments": path, "bytecode_base64": "BgMB" if observation_style == "versions" and index else "BgMA"} for index, path in enumerate(parts)]})
        capture.save()
        original = (snapshot / "manifest.json").read_bytes()
        binary = directory / "fixture.exe"
        binary.write_bytes(b"nonexecutable-test-identity")
        version = "0.0.0-fixture"
        source = "--[=[\n    Luau Decompiler " + version + "\n    Made by @zionqyl\n    https://github.com/zionqyl/luau-decompiler\n]=]\n\nreturn 42\n"
        @contextlib.contextmanager
        def service(*_):
            yield lambda *_: (200, {"complete": True, "source": source, "quality": "structured"})
        args = argparse.Namespace(directory=str(snapshot), binary=str(binary), encoding="auto", policy="faithful", no_validation=True, generation="controlled", roots=None, only_source_from=None, prioritize_scope=None, representation_basis="synthetic mocked processing boundary; not live extraction", max_inputs=None, timeout_seconds=1, total_seconds=10, max_output_mib=1)
        with contextlib.redirect_stdout(io.StringIO()), unittest.mock.patch.object(capture_client.subprocess, "check_output", return_value=("luau-decompile " + version).encode()), unittest.mock.patch.object(capture_client, "processing_service", service):
            capture_client.process(args)
        return snapshot, original

    def test_public_counts_separate_reobservations_objects_and_source_versions(self):
        for style, objects, files in [("repeat", 1, 1), ("distinct_objects", 2, 2), ("versions", 1, 2)]:
            with self.subTest(style=style), temporary_directory() as directory:
                snapshot, _ = self.process_fixture(directory, style)
                scope = {"schema": 1, "place_id": 142823291, "permission": "synthetic permission", "classification_basis": "synthetic paths", "engine_services": ["CorePackages"], "engine_component_names": [], "dependency_component_names": [], "project_prefixes": [["ReplicatedStorage", "Modules"]]}
                scope_path = directory / "scope.json"
                scope_path.write_bytes(capture_client.json_bytes(scope))
                destination = directory / "public"
                args = argparse.Namespace(directory=str(snapshot), scope=str(scope_path), generation="controlled", fallback_generation=None, publish_directory=str(destination), report=None)
                with contextlib.redirect_stdout(io.StringIO()):
                    capture_client.export_corpus(args)
                public = json.loads((destination / "manifest.json").read_bytes())
                self.assertEqual(public["coverage"]["mm2_project_scope"]["observations"]["inventory"], 2)
                self.assertEqual(public["coverage"]["mm2_project_scope"]["instances"]["inventory"], objects)
                self.assertEqual(public["published_outputs"], files)
                self.assertEqual(len(list(destination.rglob("*.luau"))), files)
                self.assertEqual(len({row["output_path"].casefold() for row in public["files"]}), files)
                self.assertEqual(sum(len(row["observations"]) for row in public["files"]), 2)

    def test_processing_preserves_capture_manifest_and_historical_exports(self):
        with temporary_directory() as directory:
            snapshot, original = self.process_fixture(directory)
            self.assertEqual((snapshot / "manifest.json").read_bytes(), original)
            generation = snapshot / "generations/controlled"
            report = json.loads((generation / "generation-manifest.json").read_bytes())
            self.assertEqual(report["capture_manifest_sha256"], capture_client.digest(original))
            self.assertTrue((generation / "corpus/examples/Murder Mystery 2/ReplicatedStorage/Modules/Game.luau").is_file())
            self.assertFalse((snapshot / "examples").exists())

    def test_public_promotion_preserves_engine_bytes_and_refuses_modified_files(self):
        with temporary_directory() as directory:
            snapshot, original = self.process_fixture(directory)
            scope = {"schema": 1, "place_id": 142823291, "permission": "controlled synthetic fixture permission", "classification_basis": "synthetic test paths", "engine_services": ["CorePackages"], "engine_component_names": [], "dependency_component_names": [], "project_prefixes": [["ReplicatedStorage", "Modules"]]}
            scope_path = directory / "scope.json"
            scope_path.write_bytes(capture_client.json_bytes(scope))
            destination = directory / "public"
            args = argparse.Namespace(directory=str(snapshot), scope=str(scope_path), generation="controlled", fallback_generation=None, publish_directory=str(destination), report=None)
            capture_client.export_corpus(args)
            public = json.loads((destination / "manifest.json").read_bytes())
            self.assertEqual(public["published_outputs"], 1)
            output = destination / public["files"][0]["output_path"]
            self.assertEqual(capture_client.digest(output.read_bytes()), public["files"][0]["source_sha256"])
            pending = output.with_name(output.name + ".pending")
            pending.write_bytes(b"unowned user work")
            capture_client.export_corpus(args)
            self.assertEqual(pending.read_bytes(), b"unowned user work")
            output.write_bytes(b"user modification")
            with self.assertRaises(ValueError):
                capture_client.export_corpus(args)
            self.assertEqual(output.read_bytes(), b"user modification")
            self.assertEqual((snapshot / "manifest.json").read_bytes(), original)

    def test_binary_bytes_deduplicate_without_merging_distinct_instances(self):
        with temporary_directory() as directory:
            capture = capture_client.Capture(directory, "snapshot")
            paths = [[segment(10, "Players"), segment(11, "player"), segment(identity, "Client", "LocalScript")] for identity in [12, 13]]
            capture.inventory({"snapshot": "snapshot", "client": {"place_id": 142823291}, "complete": True, "rows": [{"id": index + 1, "class": "LocalScript", "segments": path} for index, path in enumerate(paths)]})
            raw = bytes([0, 255, 128, 65, 0])
            for index, path in enumerate(paths):
                request = {"snapshot": "snapshot", "rows": [{"id": index + 1, "status": "captured", "segments": path, "bytecode_base64": base64.b64encode(raw).decode()}]}
                capture.capture(request)
                capture.capture(request)
            manifest = capture.save()
            self.assertEqual(len(list(pathlib.Path(directory, "original-bytecode").glob("*.bc"))), 1)
            self.assertEqual(next(pathlib.Path(directory, "original-bytecode").glob("*.bc")).read_bytes(), raw)
            outputs = [row["output_path"] for row in manifest["scripts"]]
            self.assertEqual(len(set(outputs)), 2)
            self.assertTrue(all(path.startswith("examples/Murder Mystery 2/Players/player/") for path in outputs))

    def test_names_and_parent_collisions_cannot_escape_or_overwrite(self):
        rows = []
        for index, name in enumerate(["Name", "name", "../CON", "NUL", "\u0394\u6c49\u5b57", ""]):
            segments = capture_client.decode_segments([segment(1, "ReplicatedStorage"), segment(index + 10, name), segment(index + 30, "Module")])
            rows.append({"id": index, "inventory_segments": segments})
        paths = list(capture_client.hierarchy_paths(rows).values())
        self.assertEqual(len({path.casefold() for path in paths}), len(rows))
        self.assertTrue(all(".." not in pathlib.PurePosixPath(path).parts for path in paths))
        self.assertTrue(any("\u0394\u6c49\u5b57" in path for path in paths))
        self.assertTrue(all("\\" not in path for path in paths))

    def test_retry_conflict_does_not_poison_durable_journal(self):
        with temporary_directory() as directory:
            capture = capture_client.Capture(directory, "snapshot")
            request = {"snapshot": "snapshot", "client": {}, "complete": True, "rows": [{"id": 1, "class": "ModuleScript", "segments": [segment(1, "ReplicatedStorage"), segment(2, "A")]}]}
            capture.inventory(request)
            request["rows"][0]["segments"][-1] = segment(2, "B")
            with self.assertRaises(ValueError):
                capture.inventory(request)
            restored = capture_client.Capture(directory, "snapshot")
            self.assertEqual(restored.rows[1]["inventory_segments"][-1]["name"], "A")

    def test_interrupted_final_append_recovers_acknowledged_state(self):
        with temporary_directory() as directory:
            capture = capture_client.Capture(directory, "snapshot")
            capture.inventory({"snapshot": "snapshot", "client": {}, "complete": True, "rows": []})
            with capture.journal.open("ab") as output:
                output.write(b'{"kind":"capture"')
            restored = capture_client.Capture(directory, "snapshot")
            self.assertTrue(restored.inventory_complete)
            self.assertEqual(restored.recovered_partial_bytes, 17)
            self.assertTrue(restored.journal.read_bytes().endswith(b"\n"))

    def test_blob_and_inventory_limits_reject_without_fabricated_capture(self):
        with temporary_directory() as directory:
            capture = capture_client.Capture(directory, "snapshot", maximum_inventory=1, maximum_blob=2, maximum_bytes=2)
            capture.inventory({"snapshot": "snapshot", "client": {}, "complete": True, "rows": [{"id": 1, "class": "ModuleScript", "segments": [segment(1, "ReplicatedStorage"), segment(2, "A")]}]})
            with self.assertRaises(ValueError):
                capture.capture({"snapshot": "snapshot", "rows": [{"id": 1, "status": "captured", "bytecode_base64": "YWJj"}]})
            self.assertEqual(capture.status()["outcomes"], {"pending": 1})
            with self.assertRaises(ValueError):
                capture.inventory({"snapshot": "snapshot", "client": {}, "rows": [{"id": 2, "class": "ModuleScript", "segments": [segment(3, "B")]}]})

    def test_private_capture_cannot_enter_public_repository_example_tree(self):
        repository = pathlib.Path(__file__).resolve().parent.parent
        with self.assertRaises(ValueError):
            capture_client.private_directory(repository / "examples" / "Murder Mystery 2")
        self.assertEqual(capture_client.private_directory(repository / "artifacts" / "private"), repository / "artifacts" / "private")

    def test_reparented_or_renamed_shared_ancestor_retains_both_observed_paths(self):
        first = capture_client.decode_segments([segment(1, "Players"), segment(2, "First"), segment(3, "Script")])
        second = capture_client.decode_segments([segment(1, "Players"), segment(2, "Second"), segment(4, "Script")])
        paths = capture_client.hierarchy_paths([{"id": 1, "inventory_segments": first}, {"id": 2, "inventory_segments": second}])
        self.assertIn("/First/", paths[1])
        self.assertIn("/Second/", paths[2])


if __name__ == "__main__":
    unittest.main()
