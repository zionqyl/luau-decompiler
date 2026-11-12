import { Inflate, Zip, ZipDeflate } from "fflate";
import { BROWSER_LIMITS, pathKey, validatePath } from "./models.ts";

type Entry = {
  path: string;
  rawName: Uint8Array;
  flags: number;
  method: number;
  crc: number;
  size: number;
  compressed: number;
  local: number;
  needed: number;
  directory: boolean;
  start: number;
};
const decoder = new TextDecoder("utf-8", { fatal: true, ignoreBOM: true });
const crcTable = Uint32Array.from({ length: 256 }, (_, index) => {
  let value = index;
  for (let bit = 0; bit < 8; bit++) value = (value >>> 1) ^ (value & 1 ? 0xedb88320 : 0);
  return value >>> 0;
});

function crcUpdate(value: number, bytes: Uint8Array): number {
  for (const byte of bytes) value = crcTable[(value ^ byte) & 255] ^ (value >>> 8);
  return value;
}

function fail(message: string): never {
  throw new Error("ZIP import: " + message);
}

function range(bytes: Uint8Array, offset: number, length: number): Uint8Array {
  if (
    !Number.isSafeInteger(offset) ||
    !Number.isSafeInteger(length) ||
    offset < 0 ||
    length < 0 ||
    offset + length > bytes.length
  )
    fail("truncated record or invalid offset.");
  return bytes.subarray(offset, offset + length);
}

function extraName(extra: Uint8Array, raw: Uint8Array): string | undefined {
  const view = new DataView(extra.buffer, extra.byteOffset, extra.byteLength);
  let name: string | undefined;
  for (let offset = 0; offset < extra.length; ) {
    if (offset + 4 > extra.length) fail("truncated extra field.");
    const id = view.getUint16(offset, true);
    const length = view.getUint16(offset + 2, true);
    const data = range(extra, offset + 4, length);
    if (id === 1)
      fail("ZIP64 is unsupported; split this input into ordinary bounded ZIP archives.");
    if (id === 0x9901) fail("encrypted archives are unsupported.");
    if (id === 0x7075) {
      if (name !== undefined || data.length < 5 || data[0] !== 1)
        fail("invalid Unicode path extra field.");
      const expected = new DataView(data.buffer, data.byteOffset, data.byteLength).getUint32(
        1,
        true,
      );
      if ((crcUpdate(0xffffffff, raw) ^ 0xffffffff) >>> 0 !== expected)
        fail("Unicode path checksum does not match its filename.");
      try {
        name = decoder.decode(data.subarray(5));
      } catch {
        fail("Unicode path is not valid UTF-8.");
      }
    }
    offset += 4 + length;
  }
  return name;
}

function decodeName(raw: Uint8Array, flags: number, unicode: string | undefined): string {
  let path: string;
  if (flags & 0x800) {
    try {
      path = decoder.decode(raw);
    } catch {
      fail("filename is not valid UTF-8.");
    }
    if (unicode !== undefined && unicode !== path!)
      fail("Unicode filename representations disagree.");
  } else if (unicode !== undefined) path = unicode;
  else {
    if (raw.some((byte) => byte > 127))
      fail("non-ASCII legacy filename encoding is unsupported; create a UTF-8 ZIP.");
    path = String.fromCharCode(...raw);
  }
  return path!;
}

function readEntries(bytes: Uint8Array): Entry[] {
  if (bytes.length > BROWSER_LIMITS.archiveBytes) fail("compressed archive exceeds 16 MiB.");
  if (bytes.length < 22) fail("missing end-of-directory record.");
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let end = -1;
  for (let offset = bytes.length - 22; offset >= Math.max(0, bytes.length - 65557); offset--) {
    if (
      view.getUint32(offset, true) === 0x06054b50 &&
      offset + 22 + view.getUint16(offset + 20, true) === bytes.length
    ) {
      end = offset;
      break;
    }
  }
  if (end < 0) fail("missing or truncated end-of-directory record.");
  const count = view.getUint16(end + 10, true);
  const centralSize = view.getUint32(end + 12, true);
  const centralStart = view.getUint32(end + 16, true);
  if (count === 0xffff || centralStart === 0xffffffff || centralSize === 0xffffffff)
    fail("ZIP64 is unsupported.");
  if (
    view.getUint16(end + 4, true) ||
    view.getUint16(end + 6, true) ||
    view.getUint16(end + 8, true) !== count
  )
    fail("multi-volume archives are unsupported.");
  if (count > BROWSER_LIMITS.files) fail("archive exceeds 64 entries, including directories.");
  if (centralStart + centralSize !== end)
    fail("directory offsets are inconsistent or contain unsupported intervening records.");
  range(bytes, centralStart, centralSize);
  const entries: Entry[] = [];
  let cursor = centralStart;
  let expanded = 0;
  for (let index = 0; index < count; index++) {
    range(bytes, cursor, 46);
    if (view.getUint32(cursor, true) !== 0x02014b50) fail("invalid central-directory signature.");
    const needed = view.getUint16(cursor + 6, true);
    const flags = view.getUint16(cursor + 8, true);
    const method = view.getUint16(cursor + 10, true);
    const crc = view.getUint32(cursor + 16, true);
    const compressed = view.getUint32(cursor + 20, true);
    const size = view.getUint32(cursor + 24, true);
    const nameLength = view.getUint16(cursor + 28, true);
    const extraLength = view.getUint16(cursor + 30, true);
    const commentLength = view.getUint16(cursor + 32, true);
    const local = view.getUint32(cursor + 42, true);
    if (needed > 20 || size === 0xffffffff || compressed === 0xffffffff || local === 0xffffffff)
      fail("ZIP64 or features newer than ZIP 2.0 are unsupported.");
    if (view.getUint16(cursor + 34, true)) fail("multi-volume entries are unsupported.");
    if (flags & 0x41) fail("encrypted archives are unsupported.");
    if (flags & ~0x80e) fail("unsupported general-purpose ZIP flags.");
    if (method !== 0 && method !== 8) fail("only stored and DEFLATE entries are supported.");
    if (nameLength > BROWSER_LIMITS.pathBytes) fail("filename exceeds the browser path limit.");
    const rawName = range(bytes, cursor + 46, nameLength);
    const extra = range(bytes, cursor + 46 + nameLength, extraLength);
    const path = decodeName(rawName, flags, extraName(extra, rawName));
    const directory = path.endsWith("/");
    validatePath(directory ? path.slice(0, -1) : path);
    const attributes = view.getUint32(cursor + 38, true);
    const type = (attributes >>> 16) & 0xf000;
    if ((type && type !== 0x8000 && type !== 0x4000) || attributes & 0x400)
      fail("links, devices and reparse points are unsupported.");
    if ((type === 0x4000 || attributes & 0x10) && !directory)
      fail("directory attributes disagree with the filename.");
    if (directory && (size || crc)) fail("directory entries must declare empty data.");
    if (size > BROWSER_LIMITS.inputFileBytes) fail("entry exceeds 2 MiB.");
    expanded += size;
    if (expanded > BROWSER_LIMITS.archiveExpandedBytes)
      fail("declared expanded data exceeds 32 MiB.");
    entries.push({
      path,
      rawName,
      flags,
      method,
      crc,
      size,
      compressed,
      local,
      needed,
      directory,
      start: 0,
    });
    cursor += 46 + nameLength + extraLength + commentLength;
    if (cursor > end) fail("central-directory entry exceeds its boundary.");
  }
  if (cursor !== end) fail("central-directory entry count disagrees with its size.");
  const physical = [...entries].sort((left, right) => left.local - right.local);
  if (physical.length && physical[0].local !== 0)
    fail("self-extracting or prefixed archives are unsupported.");
  for (const [index, entry] of physical.entries()) {
    const at = entry.local;
    range(bytes, at, 30);
    if (
      view.getUint32(at, true) !== 0x04034b50 ||
      view.getUint16(at + 4, true) !== entry.needed ||
      view.getUint16(at + 6, true) !== entry.flags ||
      view.getUint16(at + 8, true) !== entry.method
    )
      fail("local and central entry headers disagree.");
    const nameLength = view.getUint16(at + 26, true);
    const extraLength = view.getUint16(at + 28, true);
    const raw = range(bytes, at + 30, nameLength);
    if (
      raw.length !== entry.rawName.length ||
      raw.some((byte, offset) => byte !== entry.rawName[offset])
    )
      fail("local and central filenames disagree.");
    const unicode = extraName(range(bytes, at + 30 + nameLength, extraLength), raw);
    if (unicode !== undefined && unicode !== entry.path)
      fail("local and central Unicode paths disagree.");
    entry.start = at + 30 + nameLength + extraLength;
    const bodyEnd = entry.start + entry.compressed;
    const next = physical[index + 1]?.local ?? centralStart;
    range(bytes, entry.start, entry.compressed);
    if (bodyEnd > next || next > centralStart) fail("entry data overlaps another record.");
    if (entry.flags & 8) {
      const length = next - bodyEnd;
      const offset =
        length === 16 && view.getUint32(bodyEnd, true) === 0x08074b50 ? bodyEnd + 4 : bodyEnd;
      if ((length !== 12 && offset === bodyEnd) || (length !== 16 && offset !== bodyEnd))
        fail("invalid data-descriptor boundary.");
      if (
        view.getUint32(offset, true) !== entry.crc ||
        view.getUint32(offset + 4, true) !== entry.compressed ||
        view.getUint32(offset + 8, true) !== entry.size
      )
        fail("data descriptor disagrees with the directory.");
      for (const [field, expected] of [
        [14, entry.crc],
        [18, entry.compressed],
        [22, entry.size],
      ]) {
        const actual = view.getUint32(at + field, true);
        if (actual !== 0 && actual !== expected)
          fail("streaming local sizes or checksum disagree with the directory.");
      }
    } else if (
      bodyEnd !== next ||
      view.getUint32(at + 14, true) !== entry.crc ||
      view.getUint32(at + 18, true) !== entry.compressed ||
      view.getUint32(at + 22, true) !== entry.size
    )
      fail("entry sizes or checksum disagree with the directory.");
  }
  return entries;
}

function join(chunks: Uint8Array[], length: number): Uint8Array {
  const result = new Uint8Array(length);
  let offset = 0;
  for (const chunk of chunks) {
    result.set(chunk, offset);
    offset += chunk.length;
  }
  return result;
}

export async function unzipBounded(
  bytes: Uint8Array,
): Promise<{ path: string; bytes: Uint8Array }[]> {
  const entries = readEntries(bytes);
  const files: { path: string; bytes: Uint8Array }[] = [];
  let total = 0;
  for (const entry of entries) {
    const chunks: Uint8Array[] = [];
    let size = 0;
    let crc = 0xffffffff;
    const consume = (chunk: Uint8Array) => {
      size += chunk.length;
      total += chunk.length;
      if (size > BROWSER_LIMITS.inputFileBytes || total > BROWSER_LIMITS.archiveExpandedBytes)
        fail("actual expanded bytes exceed the file or aggregate limit.");
      if (size > entry.size) fail("actual expanded bytes exceed the declared size.");
      crc = crcUpdate(crc, chunk);
      chunks.push(new Uint8Array(chunk));
    };
    const data = bytes.subarray(entry.start, entry.start + entry.compressed);
    if (entry.method === 0) consume(data);
    else {
      const inflate = new Inflate(consume);
      if (!data.length) fail("empty DEFLATE payload.");
      for (let offset = 0; offset < data.length; offset += 1024)
        inflate.push(data.subarray(offset, offset + 1024), offset + 1024 >= data.length);
    }
    if (size !== entry.size || (crc ^ 0xffffffff) >>> 0 !== entry.crc)
      fail("actual size or CRC-32 mismatch.");
    if (entry.directory) continue;
    files.push({ path: entry.path, bytes: join(chunks, size) });
  }
  if (!files.length) fail("archive contains no files.");
  return files;
}

export function zipOutputs(files: { path: string; bytes: Uint8Array }[]): Uint8Array {
  if (!files.length || files.length > BROWSER_LIMITS.files)
    throw new Error("ZIP export requires between 1 and 64 completed files.");
  const names = new Set<string>();
  let total = 0;
  for (const file of files) {
    const parts = validatePath(file.path);
    if (
      parts.some(
        (part) =>
          part !== part.normalize("NFC") ||
          /[<>:"|?*\u0000-\u001f\u007f]/u.test(part) ||
          /[. ]$/u.test(part) ||
          /^(CON|PRN|AUX|NUL|COM[1-9\u00b9\u00b2\u00b3]|LPT[1-9\u00b9\u00b2\u00b3])(?:[ .]|$)/iu.test(
            part,
          ),
      )
    )
      throw new Error("ZIP export requires normalized safe paths.");
    if (names.has(pathKey(file.path)))
      throw new Error("ZIP export paths collide; use normalized output identities.");
    names.add(pathKey(file.path));
    if (file.bytes.length > BROWSER_LIMITS.outputFileBytes)
      throw new Error("ZIP export file exceeds 4 MiB.");
    total += file.bytes.length;
    if (total > BROWSER_LIMITS.outputTotalBytes)
      throw new Error("ZIP export exceeds 32 MiB of source.");
  }
  for (const file of files) {
    const parts = file.path.split("/");
    for (let count = 1; count < parts.length; count++)
      if (names.has(pathKey(parts.slice(0, count).join("/"))))
        throw new Error("ZIP export has a file/directory path collision.");
  }
  const chunks: Uint8Array[] = [];
  let length = 0;
  let finished = false;
  const zip = new Zip((error, data, final) => {
    if (error) throw new Error("ZIP export failed: " + error.message);
    length += data.length;
    if (length > BROWSER_LIMITS.outputArchiveBytes)
      throw new Error("ZIP export exceeds the compressed archive limit.");
    chunks.push(new Uint8Array(data));
    finished = final;
  });
  for (const file of files) {
    const entry = new ZipDeflate(file.path, { level: 6 });
    entry.mtime = new Date(1980, 0, 1, 0, 0, 0);
    entry.os = 3;
    entry.attrs = (0o100644 << 16) >>> 0;
    zip.add(entry);
    if (!file.bytes.length) entry.push(new Uint8Array(), true);
    for (let offset = 0; offset < file.bytes.length; offset += 65536)
      entry.push(file.bytes.subarray(offset, offset + 65536), offset + 65536 >= file.bytes.length);
  }
  zip.end();
  if (!finished) throw new Error("ZIP export did not finish.");
  return join(chunks, length);
}
