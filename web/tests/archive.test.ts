import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { test } from "node:test";
import { zipSync } from "fflate";
import { BROWSER_LIMITS, normalizeFiles, pathKey } from "../lib/models.ts";
import { unzipBounded, zipOutputs } from "../lib/archive.ts";

const text = new TextEncoder();
const source = text.encode(
  "--!strict\n--[=[\n    Luau Decompiler test\n    Made by @zionqyl\n    https://github.com/zionqyl/luau-decompiler\n]=]\n\nlocal answer: number = 42\nreturn answer\n",
);
function mutated(zip: Uint8Array, change: (view: DataView, central: number) => void): Uint8Array {
  const result = new Uint8Array(zip);
  const view = new DataView(result.buffer);
  const end = result.length - 22;
  change(view, view.getUint32(end + 16, true));
  return result;
}

test("import identities preserve original paths and disambiguate Unicode, case, reserved names and output extensions", async () => {
  const paths = [
    "Root/e\u0301.lua",
    "Root/\u00e9.lua",
    "root/other.bc",
    "Root/Script.bc",
    "Root/Script.luau",
    "CON.lua",
    "a<b>.lua",
    "name. ",
    "parent",
    "parent/child.lua",
    "Root/Script.bc",
  ];
  const bytes = new Uint8Array([0, 255, 1]);
  const input = paths.map((path) => ({ path, bytes }));
  const files = await normalizeFiles(input);
  const again = await normalizeFiles(input);
  assert.deepEqual(files, again);
  assert.deepEqual(
    files.map((file) => file.originalPath),
    paths,
  );
  assert.equal(new Set(files.map((file) => file.id)).size, paths.length);
  assert.equal(new Set(files.map((file) => pathKey(file.path))).size, paths.length);
  assert.equal(new Set(files.map((file) => pathKey(file.outputPath))).size, paths.length);
  assert.equal(files[0].path, "Root/\u00e9.lua");
  assert.match(files[1].path, /^Root\/\u00e9~[0-9a-f]+\.lua$/u);
  assert.match(files[2].path, /^root~[0-9a-f]+\/other\.bc$/u);
  assert.equal(files[5].path, "_CON.lua");
  assert.equal(files[6].path, "a_b_.lua");
  assert.match(files[8].path, /^parent~/u);
  assert.equal(files[9].path, "parent/child.lua");
  bytes[0] = 9;
  assert.deepEqual(files[0].bytes, new Uint8Array([0, 255, 1]));
  assert.equal(files[0].sha256, createHash("sha256").update(files[0].bytes).digest("hex"));
  assert.ok(files.every((file) => file.outputPath.endsWith(".luau")));
});

test("path, input and aggregate limits reject before processing", async () => {
  for (const path of [
    "../file.lua",
    "a/../b.lua",
    "/absolute.lua",
    "C:/file.lua",
    "a\\b.lua",
    "a//b.lua",
    "a/./b.lua",
    "nul\0.lua",
    "bad\ud800.lua",
  ]) {
    await assert.rejects(normalizeFiles([{ path, bytes: new Uint8Array() }]));
  }
  await assert.rejects(
    normalizeFiles(
      Array.from({ length: 65 }, (_, index) => ({ path: `${index}.lua`, bytes: new Uint8Array() })),
    ),
    /64-file/u,
  );
  await assert.rejects(
    normalizeFiles([
      { path: "large.lua", bytes: new Uint8Array(BROWSER_LIMITS.inputFileBytes + 1) },
    ]),
    /2 MiB/u,
  );
  const large = new Uint8Array(BROWSER_LIMITS.inputFileBytes);
  await assert.rejects(
    normalizeFiles(
      Array.from({ length: 17 }, (_, index) => ({ path: `${index}.lua`, bytes: large })),
    ),
    /32 MiB/u,
  );
});

test("bounded long Unicode names retain valid encoding and extensions", async () => {
  const files = await normalizeFiles([{ path: "\u6c49".repeat(200) + ".lua", bytes: source }]);
  assert.ok(text.encode(files[0].path).length <= BROWSER_LIMITS.segmentBytes);
  assert.ok(text.encode(files[0].outputPath).length <= BROWSER_LIMITS.segmentBytes);
  assert.ok(files[0].outputPath.endsWith(".luau"));
  assert.equal(files[0].originalPath, "\u6c49".repeat(200) + ".lua");
});

test("ZIP export retains exact finalized source bytes and deterministic hierarchy", async () => {
  const files = [
    { path: "Players/\u6c49\u5b57/PlayerScripts/main.luau", bytes: source },
    { path: "ReplicatedStorage/module.luau", bytes: source },
  ];
  const zip = zipOutputs(files);
  assert.deepEqual(zipOutputs(files), zip);
  const read = await unzipBounded(zip);
  assert.deepEqual(read, files);
  for (const file of read) assert.deepEqual(file.bytes, source);
  const hostile = [{ path: "__proto__", bytes: source }];
  assert.deepEqual(await unzipBounded(zipOutputs(hostile)), hostile);
});

test("ZIP decoder supports stored and DEFLATE files plus empty compressed directory records", async () => {
  const zip = zipSync({ "folder/": new Uint8Array(), "folder/file.lua": source }, { level: 6 });
  assert.deepEqual(await unzipBounded(zip), [{ path: "folder/file.lua", bytes: source }]);
  const stored = zipSync({ "binary.bc": new Uint8Array([0, 255, 1]) }, { level: 0 });
  assert.deepEqual(await unzipBounded(stored), [
    { path: "binary.bc", bytes: new Uint8Array([0, 255, 1]) },
  ]);
});

test("unsafe ZIP paths and unsupported features are rejected without reinterpretation", async () => {
  for (const path of [
    "../a.lua",
    "/a.lua",
    "C:/a.lua",
    "a\\b.lua",
    "a/../b.lua",
    "a//b.lua",
    "nul\0.lua",
  ])
    await assert.rejects(unzipBounded(zipSync({ [path]: source })));
  const valid = zipSync({ "a.lua": source });
  await assert.rejects(
    unzipBounded(
      mutated(valid, (view, central) => {
        view.setUint16(6, 1, true);
        view.setUint16(central + 8, 1, true);
      }),
    ),
    /encrypted/u,
  );
  await assert.rejects(
    unzipBounded(mutated(valid, (view, central) => view.setUint32(central + 24, 0xffffffff, true))),
    /ZIP64/u,
  );
  await assert.rejects(
    unzipBounded(mutated(valid, (view, central) => view.setUint16(central + 10, 99, true))),
    /stored and DEFLATE/u,
  );
  await assert.rejects(
    unzipBounded(mutated(valid, (view, central) => view.setUint32(central + 38, 0xa1ff0000, true))),
    /links/u,
  );
  await assert.rejects(unzipBounded(valid.subarray(0, valid.length - 1)), /truncated/u);
});

test("ZIP count, compressed size and declared expansion bounds are independent", async () => {
  const files: Record<string, Uint8Array> = {};
  for (let index = 0; index < 65; index++) files[`${index}.lua`] = source;
  await assert.rejects(unzipBounded(zipSync(files)), /64 entries/u);
  await assert.rejects(unzipBounded(new Uint8Array(BROWSER_LIMITS.archiveBytes + 1)), /16 MiB/u);
  const valid = zipSync({ "a.lua": source });
  await assert.rejects(
    unzipBounded(
      mutated(valid, (view, central) =>
        view.setUint32(central + 24, BROWSER_LIMITS.inputFileBytes + 1, true),
      ),
    ),
    /2 MiB/u,
  );
});

test("falsified expansion size is bounded by actual streaming output", async () => {
  const bomb = zipSync({ "bomb.lua": new Uint8Array(8 * 1024 * 1024) }, { level: 9 });
  const falsified = mutated(bomb, (view, central) => {
    view.setUint32(22, 1, true);
    view.setUint32(central + 24, 1, true);
  });
  assert.ok(falsified.length < 10000);
  await assert.rejects(unzipBounded(falsified), /actual expanded bytes/u);
});

test("actual CRC, local names and record boundaries are validated", async () => {
  const valid = zipSync({ "a.lua": source }, { level: 0 });
  await assert.rejects(
    unzipBounded(
      mutated(valid, (view) => {
        const at = 30 + view.getUint16(26, true) + view.getUint16(28, true);
        view.setUint8(at, view.getUint8(at) ^ 1);
      }),
    ),
    /CRC-32/u,
  );
  await assert.rejects(
    unzipBounded(mutated(valid, (view) => view.setUint8(30, 98))),
    /filenames disagree/u,
  );
  await assert.rejects(
    unzipBounded(mutated(valid, (view, central) => view.setUint32(central + 42, 1, true))),
    /prefixed/u,
  );
});

test("duplicate ZIP names remain separate inputs and receive distinct export identities", async () => {
  const raw = zipOutputs([
    { path: "one.lua", bytes: source },
    { path: "two.lua", bytes: source },
  ]);
  const duplicate = new Uint8Array(raw);
  for (let index = 0; index <= duplicate.length - 7; index++)
    if (new TextDecoder().decode(duplicate.subarray(index, index + 7)) === "two.lua")
      duplicate.set(text.encode("one.lua"), index);
  const imported = await unzipBounded(duplicate);
  assert.deepEqual(
    imported.map((file) => file.path),
    ["one.lua", "one.lua"],
  );
  const normalized = await normalizeFiles(imported);
  assert.equal(new Set(normalized.map((file) => pathKey(file.outputPath))).size, 2);
  assert.deepEqual(
    (
      await unzipBounded(
        zipOutputs(normalized.map((file) => ({ path: file.outputPath, bytes: source }))),
      )
    ).map((file) => file.bytes),
    [source, source],
  );
});

test("export refuses unsafe paths, collisions and excessive retained output", () => {
  assert.throws(() => zipOutputs([{ path: "../a.luau", bytes: source }]));
  assert.throws(
    () =>
      zipOutputs([
        { path: "a.luau", bytes: source },
        { path: "A.luau", bytes: source },
      ]),
    /collide/u,
  );
  assert.throws(
    () =>
      zipOutputs([
        { path: "a", bytes: source },
        { path: "a/b", bytes: source },
      ]),
    /file\/directory/u,
  );
  assert.throws(() => zipOutputs([{ path: "CON.luau", bytes: source }]), /normalized/u);
  assert.throws(
    () =>
      zipOutputs([
        { path: "large.luau", bytes: new Uint8Array(BROWSER_LIMITS.outputFileBytes + 1) },
      ]),
    /4 MiB/u,
  );
  assert.throws(() => zipOutputs([]), /between 1 and 64/u);
});
