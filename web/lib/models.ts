export const BROWSER_LIMITS = Object.freeze({
  files: 64,
  inputFileBytes: 2 * 1024 * 1024,
  inputTotalBytes: 32 * 1024 * 1024,
  archiveBytes: 16 * 1024 * 1024,
  archiveExpandedBytes: 32 * 1024 * 1024,
  outputFileBytes: 4 * 1024 * 1024,
  outputTotalBytes: 32 * 1024 * 1024,
  outputArchiveBytes: 34 * 1024 * 1024,
  pathBytes: 2048,
  pathSegments: 32,
  segmentBytes: 120,
});

export type ImportedFile = {
  id: string;
  path: string;
  originalPath: string;
  outputPath: string;
  bytes: Uint8Array;
  sha256: string;
};

const encoder = new TextEncoder();

export function pathKey(path: string): string {
  return path.normalize("NFKC").toUpperCase();
}

export function validatePath(path: string): string[] {
  if (
    typeof path !== "string" ||
    !path ||
    path.startsWith("/") ||
    path.includes("\\") ||
    /^[A-Za-z]:/u.test(path) ||
    path.includes("\0")
  ) {
    throw new Error(
      "Paths must be nonempty relative paths without drives, backslashes or NUL bytes.",
    );
  }
  for (let index = 0; index < path.length; index++) {
    const unit = path.charCodeAt(index);
    if (unit >= 0xd800 && unit <= 0xdbff) {
      const next = path.charCodeAt(++index);
      if (!(next >= 0xdc00 && next <= 0xdfff))
        throw new Error("Path contains an unpaired Unicode surrogate.");
    } else if (unit >= 0xdc00 && unit <= 0xdfff)
      throw new Error("Path contains an unpaired Unicode surrogate.");
  }
  const parts = path.split("/");
  if (
    parts.length > BROWSER_LIMITS.pathSegments ||
    encoder.encode(path).length > BROWSER_LIMITS.pathBytes
  )
    throw new Error("Path exceeds the browser length or nesting limit.");
  if (parts.some((part) => !part || part === "." || part === ".."))
    throw new Error("Paths cannot contain empty, dot or parent-traversal segments.");
  return parts;
}

async function hash(bytes: Uint8Array): Promise<string> {
  if (!globalThis.crypto?.subtle)
    throw new Error(
      "Secure browser SHA-256 is unavailable; open the application using HTTPS or a trusted loopback origin.",
    );
  const digest = await crypto.subtle.digest("SHA-256", new Uint8Array(bytes));
  return Array.from(new Uint8Array(digest), (value) => value.toString(16).padStart(2, "0")).join(
    "",
  );
}

function prefixBytes(value: string, limit: number): string {
  let result = "";
  let used = 0;
  for (const character of value) {
    const size = encoder.encode(character).length;
    if (used + size > limit) break;
    result += character;
    used += size;
  }
  return result;
}

function nameParts(value: string): [string, string] {
  const dot = value.lastIndexOf(".");
  return dot > 0 && encoder.encode(value.slice(dot)).length <= 16
    ? [value.slice(0, dot), value.slice(dot)]
    : [value, ""];
}

function suffixName(value: string, suffix: string): string {
  const [stem, extension] = nameParts(value);
  return (
    prefixBytes(stem, BROWSER_LIMITS.segmentBytes - encoder.encode(extension + suffix).length) +
    suffix +
    extension
  );
}

async function safeSegment(raw: string): Promise<string> {
  let value =
    raw
      .normalize("NFC")
      .replace(/[<>:"|?*\u0000-\u001f\u007f]/gu, "_")
      .replace(/[. ]+$/gu, "") || "_";
  if (
    /^(CON|PRN|AUX|NUL|COM[1-9\u00b9\u00b2\u00b3]|LPT[1-9\u00b9\u00b2\u00b3])(?:[ .]|$)/iu.test(
      value,
    )
  )
    value = "_" + value;
  if (encoder.encode(value).length > BROWSER_LIMITS.segmentBytes)
    value = suffixName(value, "~" + (await hash(encoder.encode(raw))).slice(0, 8));
  return value;
}

function uniquePath(parent: string, name: string, identity: string, used: Set<string>): string {
  if (encoder.encode(name).length > BROWSER_LIMITS.segmentBytes)
    name = suffixName(name, "~" + identity.slice(0, 8));
  let candidate = parent + name;
  let counter = 0;
  while (used.has(pathKey(candidate))) {
    candidate =
      parent + suffixName(name, "~" + identity.slice(0, 8) + (counter ? "-" + counter : ""));
    counter++;
  }
  if (encoder.encode(candidate).length > BROWSER_LIMITS.pathBytes)
    throw new Error("Sanitized path exceeds the browser path limit.");
  used.add(pathKey(candidate));
  return candidate;
}

export async function normalizeFiles(
  items: { path: string; bytes: Uint8Array }[],
): Promise<ImportedFile[]> {
  if (items.length > BROWSER_LIMITS.files)
    throw new Error("Import exceeds the browser 64-file limit.");
  let total = 0;
  const sources = items.map((item) => {
    const parts = validatePath(item.path);
    if (!(item.bytes instanceof Uint8Array) || item.bytes.length > BROWSER_LIMITS.inputFileBytes)
      throw new Error("Input exceeds the browser 2 MiB per-file limit.");
    total += item.bytes.length;
    if (total > BROWSER_LIMITS.inputTotalBytes)
      throw new Error("Inputs exceed the browser 32 MiB aggregate limit.");
    return { parts, originalPath: item.path, bytes: item.bytes };
  });
  const snapshots = sources.map((item) => ({ ...item, bytes: new Uint8Array(item.bytes) }));
  const prepared: {
    parts: string[];
    originalPath: string;
    bytes: Uint8Array;
    sha256: string;
    id: string;
  }[] = [];
  for (const [ordinal, item] of snapshots.entries()) {
    const { parts, bytes, originalPath } = item;
    const sha256 = await hash(bytes);
    const id = await hash(encoder.encode(originalPath + "\0" + sha256 + "\0" + ordinal));
    prepared.push({ parts, originalPath, bytes, sha256, id });
  }
  const directories = new Map<string, string>();
  const usedDirectories = new Set<string>();
  for (const item of prepared) {
    let raw = "";
    let parent = "";
    for (const segment of item.parts.slice(0, -1)) {
      raw += (raw ? "/" : "") + segment;
      let assigned = directories.get(raw);
      if (assigned === undefined) {
        assigned = uniquePath(
          parent,
          await safeSegment(segment),
          await hash(encoder.encode(raw)),
          usedDirectories,
        );
        directories.set(raw, assigned);
      }
      parent = assigned + "/";
    }
  }
  const inputNames = new Set(usedDirectories);
  const outputNames = new Set(usedDirectories);
  const results: ImportedFile[] = [];
  for (const item of prepared) {
    const rawParent = item.parts.slice(0, -1).join("/");
    const parent = rawParent ? directories.get(rawParent)! + "/" : "";
    const name = await safeSegment(item.parts[item.parts.length - 1]);
    const path = uniquePath(parent, name, item.id, inputNames);
    const assignedName = path.slice(parent.length);
    const stem = assignedName.replace(/\.(?:luau|lua|luac|bc)$/iu, "");
    const outputPath = uniquePath(parent, (stem || assignedName) + ".luau", item.id, outputNames);
    results.push({
      id: item.id,
      path,
      originalPath: item.originalPath,
      outputPath,
      bytes: item.bytes,
      sha256: item.sha256,
    });
  }
  return results;
}
