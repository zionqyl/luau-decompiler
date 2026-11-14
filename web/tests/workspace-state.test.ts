import assert from "node:assert/strict";
import { test } from "node:test";
import type { Decompiled, Outcome } from "../lib/domain.ts";
import { configuration, contractMaps, initialOptions } from "../lib/domain.ts";
import type { ImportedFile } from "../lib/models.ts";
import { admitOutcome, mergedSelection, processingIdentity } from "../lib/workspace-state.ts";

test("Roblox presentation uses the observed filename only as a bounded module name hint", () => {
  const config = configuration(
    initialOptions,
    "ReplicatedStorage/ClientServices/Button.bc",
    {},
    contractMaps("{}"),
  );
  assert.equal(config.naming, "roblox");
  assert.equal(config.naming_options.module_name_hint, "Button");
  assert.equal(
    configuration(initialOptions, "Button\nName.bc", {}, contractMaps("{}")).naming_options
      .module_name_hint,
    "Button_Name",
  );
  assert.deepEqual(Object.keys(config.typing.binding_types), []);
  const unicode = configuration(
    initialOptions,
    "\u{1f600}".repeat(200) + ".bc",
    {},
    contractMaps("{}"),
  );
  assert.ok(
    new TextEncoder().encode(unicode.naming_options.module_name_hint || "").byteLength <= 256,
  );
});

function outcome(source: string, bytes: number): Outcome {
  return { status: "complete", result: { source } as Decompiled, resultBytes: bytes };
}

test("separate selections share source and structured retention admission", () => {
  const limits = { sourceBytes: 10, resultBytes: 20 };
  let retained = admitOutcome({}, "first", outcome("123456", 10), limits);
  assert.throws(
    () => admitOutcome(retained, "second", outcome("12345", 5), limits),
    /Workspace source/,
  );
  assert.throws(
    () => admitOutcome(retained, "second", outcome("12", 11), limits),
    /structured-result/,
  );
  assert.deepEqual(Object.keys(retained), ["first"]);
  assert.throws(
    () =>
      admitOutcome(
        retained,
        "second",
        { ...outcome("1", 5), result: { source: "1", baseline_source: "1234" } as Decompiled },
        limits,
      ),
    /Workspace source/,
  );
  assert.throws(
    () =>
      admitOutcome(
        retained,
        "second",
        { status: "failed", error: "retained diagnostic", resultBytes: 11 },
        limits,
      ),
    /structured-result/,
  );
  assert.throws(
    () => admitOutcome(retained, "second", outcome("1", Number.NaN), limits),
    /byte accounting/,
  );
  retained = admitOutcome(retained, "first", outcome("12", 4), limits);
  retained = admitOutcome(retained, "second", outcome("12345678", 16), limits);
  assert.deepEqual(Object.keys(retained), ["first", "second"]);
  delete retained.first;
  assert.equal(
    admitOutcome(retained, "third", outcome("12", 4), limits).third.result?.source,
    "12",
  );
});

test("an additional import selects new files and preserves exclusions", () => {
  const files = [{ id: "included" }, { id: "excluded" }] as ImportedFile[];
  assert.deepEqual(
    [...mergedSelection(new Set(["included"]), files, [...files, { id: "new" } as ImportedFile])],
    ["included", "new"],
  );
  const initial = processingIdentity(initialOptions, files);
  assert.equal(processingIdentity(initialOptions, [...files]), initial);
  assert.notEqual(processingIdentity({ ...initialOptions, naming: "camelCase" }, files), initial);
});
