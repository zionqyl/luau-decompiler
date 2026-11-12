"use client";
import { useState } from "react";
import { BASE, message } from "../lib/domain.ts";
import { save } from "../lib/browser-io.ts";
import version from "../generated/version.json";
import SourceView from "./source-view";

type Entry = {
  path: string;
  bytes: number;
  sha256: string;
  strict_analysis: string;
  required_passed: boolean;
};
type Index = {
  schema: number;
  engine_version: string;
  status: string;
  scope: string;
  entries: Entry[];
};

async function boundedBytes(response: Response, maximum: number): Promise<Uint8Array> {
  if (!response.ok || !response.body)
    throw new Error(`Static example unavailable (HTTP ${response.status}).`);
  const reader = response.body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    for (;;) {
      const value = await reader.read();
      if (value.done) break;
      size += value.value.length;
      if (size > maximum) {
        await reader.cancel();
        throw new Error("Static example exceeds its preview limit.");
      }
      chunks.push(value.value);
    }
  } finally {
    reader.releaseLock();
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  return bytes;
}

export default function Showcase() {
  const [index, setIndex] = useState<Index | null>(null),
    [source, setSource] = useState(""),
    [entry, setEntry] = useState<Entry | null>(null),
    [busy, setBusy] = useState(false),
    [error, setError] = useState("");
  async function load() {
    if (index || busy) return;
    setBusy(true);
    try {
      const response = await fetch(`${BASE}/examples/mm2-showcase.json`, {
        cache: "no-store",
        credentials: "omit",
        redirect: "error",
      });
      const bytes = await boundedBytes(response, 4 * 1024 * 1024);
      const parsed = JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes)) as Index;
      if (
        parsed.schema !== 1 ||
        parsed.engine_version !== version.version ||
        !Array.isArray(parsed.entries) ||
        parsed.entries.length > 1024
      )
        throw new Error("Example index differs from this release.");
      setIndex(parsed);
    } catch (reason) {
      setError(message(reason));
    } finally {
      setBusy(false);
    }
  }
  async function open(path: string) {
    if (busy) return;
    const selected = index?.entries.find((value) => value.path === path);
    if (!selected) return;
    setBusy(true);
    setError("");
    try {
      if (
        !selected.path.startsWith("examples/Murder Mystery 2/") ||
        selected.path
          .split("/")
          .some(
            (part) => !part || part === "." || part === ".." || /[\\\u0000-\u001f]/u.test(part),
          ) ||
        selected.bytes < 1 ||
        selected.bytes > 2 * 1024 * 1024 ||
        !/^[a-f0-9]{64}$/.test(selected.sha256)
      )
        throw new Error("Unsafe or oversized example descriptor.");
      const response = await fetch(
        `${BASE}/` + selected.path.split("/").map(encodeURIComponent).join("/"),
        { cache: "no-store", credentials: "omit", redirect: "error" },
      );
      const bytes = await boundedBytes(response, selected.bytes);
      const hash = Array.from(
        new Uint8Array(await crypto.subtle.digest("SHA-256", bytes as BufferSource)),
        (value) => value.toString(16).padStart(2, "0"),
      ).join("");
      if (bytes.length !== selected.bytes || hash !== selected.sha256)
        throw new Error("Example content differs from its finalized generation.");
      setSource(new TextDecoder("utf-8", { fatal: true }).decode(bytes));
      setEntry(selected);
    } catch (reason) {
      setError(message(reason));
    } finally {
      setBusy(false);
    }
  }
  return (
    <details
      className="showcase-panel"
      onToggle={(event) => {
        if (event.currentTarget.open) void load();
      }}
    >
      <summary>Owner-authorized MM2 examples</summary>
      {busy && <p role="status">Loading static example locally…</p>}
      {error && (
        <p role="alert" className="failure">
          {error}
        </p>
      )}
      {index && (
        <>
          <p className="hint">
            {index.scope} Source is loaded on demand; generation quality is recorded separately from
            a new processing request.
          </p>
          {index.status === "available" && (
            <>
              <label>
                Captured client script
                <select
                  aria-label="MM2 example"
                  value={entry?.path ?? ""}
                  disabled={busy}
                  onChange={(event) => void open(event.target.value)}
                >
                  <option value="">Choose a generated example</option>
                  {index.entries.map((value) => (
                    <option key={value.path} value={value.path}>
                      {value.path.slice("examples/Murder Mystery 2/".length)}
                    </option>
                  ))}
                </select>
              </label>
              <a
                href={`${BASE}/examples/Murder%20Mystery%202/manifest.json`}
                target="_blank"
                rel="noreferrer"
              >
                Full capture coverage and per-file outcomes
              </a>
            </>
          )}
          {source && entry && (
            <>
              <div className="showcase-heading">
                <span>
                  Recorded strict analysis: {entry.strict_analysis}. Requested generation policy:{" "}
                  {entry.required_passed ? "passed" : "failed or not requested"}.
                </span>
                <button
                  onClick={() =>
                    save(
                      new TextEncoder().encode(source),
                      entry.path.split("/").at(-1)!,
                      "text/plain;charset=utf-8",
                    )
                  }
                >
                  Download example
                </button>
              </div>
              <SourceView source={source} formatted testId="showcase-source" />
            </>
          )}
        </>
      )}
    </details>
  );
}
