import type { DragEvent } from "react";
import type { WorkerMessage } from "./supervisor.ts";
import { BASE } from "./domain.ts";
import version from "../generated/version.json";
export function save(bytes: Uint8Array, name: string, type: string) {
  const url = URL.createObjectURL(new Blob([bytes as BlobPart], { type }));
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = name;
  anchor.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
let archiveActive = false;
export async function utility(
  kind: "unzip" | "zip",
  payload: Record<string, unknown>,
  transfer: Transferable[] = [],
) {
  if (archiveActive)
    throw new Error("An archive operation is already active; wait for it to finish.");
  archiveActive = true;
  let worker: Worker | undefined;
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    worker = new Worker(`${BASE}/runtime/${version.asset_id}/worker.mjs`, {
      type: "module",
      name: "Luau archive utility",
    });
    return await new Promise<WorkerMessage>((resolve, reject) => {
      const id = crypto.randomUUID();
      timer = setTimeout(() => reject(new Error("Archive operation exceeded 10 seconds.")), 10000);
      worker!.onmessage = (event) => {
        if (event.data.id !== id) return;
        if (event.data.kind === "error") reject(new Error(event.data.message));
        else resolve(event.data);
      };
      worker!.onerror = (event) => {
        event.preventDefault();
        reject(new Error("Archive worker failed; retry with a smaller supported ZIP."));
      };
      worker!.postMessage({ kind, id, ...payload }, transfer);
    });
  } finally {
    clearTimeout(timer);
    worker?.terminate();
    archiveActive = false;
  }
}
type EntryLike = {
  name: string;
  isFile: boolean;
  isDirectory: boolean;
  file?(success: (file: File) => void, error: (error: unknown) => void): void;
  createReader?(): {
    readEntries(success: (entries: EntryLike[]) => void, error: (error: unknown) => void): void;
  };
};
export async function droppedFiles(
  event: DragEvent,
): Promise<{ path: string; bytes: Uint8Array }[]> {
  const entries = Array.from(event.dataTransfer.items)
    .map((item) =>
      (item as unknown as { webkitGetAsEntry?: () => EntryLike | null }).webkitGetAsEntry?.(),
    )
    .filter((entry): entry is EntryLike => !!entry);
  if (!entries.length) {
    const files = Array.from(event.dataTransfer.files);
    if (
      files.length > 64 ||
      files.reduce((n, file) => n + file.size, 0) > 32 * 1024 * 1024 ||
      files.some((file) => file.size > 2 * 1024 * 1024)
    )
      throw new Error(
        "Dropped files exceed browser input bounds; use the ZIP button for larger archives.",
      );
    return Promise.all(
      files.map(async (file) => ({
        path: file.name,
        bytes: new Uint8Array(await file.arrayBuffer()),
      })),
    );
  }
  const result: { path: string; bytes: Uint8Array }[] = [];
  let nodes = 0,
    total = 0;
  async function visit(entry: EntryLike, prefix: string, depth: number): Promise<void> {
    if (++nodes > 512 || depth > 32)
      throw new Error("Dropped folder exceeds512 entries or32 levels.");
    const path = prefix + entry.name;
    if (entry.isFile && entry.file) {
      if (result.length >= 64) throw new Error("Browser input limit is 64 files.");
      const file = await new Promise<File>((resolve, reject) => entry.file?.(resolve, reject));
      total += file.size;
      if (total > 32 * 1024 * 1024) throw new Error("Dropped folder exceeds 32 MiB.");
      if (file.size > 2 * 1024 * 1024) throw new Error(`File exceeds 2 MiB: ${path}`);
      result.push({ path, bytes: new Uint8Array(await file.arrayBuffer()) });
    } else if (entry.isDirectory && entry.createReader) {
      const reader = entry.createReader();
      for (;;) {
        const children = await new Promise<EntryLike[]>((resolve, reject) =>
          reader.readEntries(resolve, reject),
        );
        if (!children.length) break;
        for (const child of children) await visit(child, path + "/", depth + 1);
      }
    } else throw new Error(`Unsupported dropped entry: ${path}`);
  }
  for (const entry of entries) await visit(entry, "", 0);
  return result;
}
