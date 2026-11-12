import assert from "node:assert/strict";
import { test } from "node:test";
import { highlight } from "../lib/highlight.ts";

test("display highlighting retains exact source including binary escapes and long delimiters", () => {
  const source =
    '--!strict\r\n--[=[\n    Luau Decompiler test\n]=]\nlocal value: string = "a\\0b"\nreturn t[ [==[foo]==] ], 1 .. "x", `value {value}`\n';
  const tokens = highlight(source);
  assert.equal(tokens.map((token) => token.text).join(""), source);
  assert.ok(
    tokens.some((token) => token.kind === "comment" && token.text.includes("Luau Decompiler")),
  );
  assert.ok(tokens.some((token) => token.kind === "string" && token.text === "[==[foo]==]"));
  assert.equal(highlight("x".repeat(600000)).length, 1);
});
