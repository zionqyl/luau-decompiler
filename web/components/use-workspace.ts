"use client";
import { useEffect, useMemo, useRef, useState, type DragEvent } from "react";
import version from "../generated/version.json";
import { normalizeFiles, type ImportedFile } from "../lib/models.ts";
import { LocalFailure, WorkerSupervisor } from "../lib/supervisor.ts";
import {
  BASE,
  configuration,
  contractMaps,
  initialOptions,
  logicalPath,
  message,
  verified,
  type Decompiled,
  type Options,
  type Outcome,
  type Status,
} from "../lib/domain.ts";
import { droppedFiles, save, utility } from "../lib/browser-io.ts";
import { admitOutcome, mergedSelection, processingIdentity } from "../lib/workspace-state.ts";
function zipSignature(bytes: Uint8Array) {
  return (
    bytes[0] === 80 &&
    bytes[1] === 75 &&
    ((bytes[2] === 3 && bytes[3] === 4) || (bytes[2] === 5 && bytes[3] === 6))
  );
}
export function useWorkspace() {
  const [files, setFiles] = useState<ImportedFile[]>([]),
    [selected, setSelected] = useState(""),
    [included, setIncluded] = useState<Set<string>>(new Set()),
    [outcomes, setOutcomesState] = useState<Record<string, Outcome>>({}),
    [options, setOptions] = useState<Options>(initialOptions),
    [running, setRunning] = useState(false),
    [importing, setImporting] = useState(false),
    [stage, setStage] = useState("Ready for supported files"),
    [error, setError] = useState(""),
    [pasteOpen, setPasteOpen] = useState(false),
    [paste, setPaste] = useState(""),
    [pasteName, setPasteName] = useState("pasted.luau"),
    [tab, setTab] = useState("source"),
    [theme, setTheme] = useState("dark"),
    [width, setWidth] = useState(260),
    [dragging, setDragging] = useState(false),
    [contextNotes, setContextNotes] = useState<string[]>([]),
    [toast, setToast] = useState("");
  const filesRef = useRef<ImportedFile[]>([]),
    inputAdmission = useRef(false),
    outcomesRef = useRef<Record<string, Outcome>>({}),
    runActive = useRef(false);
  const [automatic, setAutomatic] = useState<string[]>([]);
  function setOutcomes(
    update:
      | Record<string, Outcome>
      | ((previous: Record<string, Outcome>) => Record<string, Outcome>),
  ) {
    const next = typeof update === "function" ? update(outcomesRef.current) : update;
    outcomesRef.current = next;
    setOutcomesState(next);
  }
  const fileInput = useRef<HTMLInputElement>(null),
    folderInput = useRef<HTMLInputElement>(null),
    zipInput = useRef<HTMLInputElement>(null),
    cancelled = useRef(false),
    supervisor = useRef<WorkerSupervisor | null>(null),
    runSerial = useRef(0);
  const signature = useMemo(() => processingIdentity(options, files), [options, files]);
  const stale = !!outcomes[selected]?.generation && outcomes[selected].generation !== signature;
  const current = files.find((file) => file.id === selected),
    outcome = outcomes[selected],
    result = outcome?.result;
  const complete = files.filter(
      (file) =>
        outcomes[file.id]?.generation === signature && !!outcomes[file.id]?.result?.complete,
    ).length,
    typed = files.filter(
      (file) => outcomes[file.id]?.generation === signature && verified(outcomes[file.id]?.result),
    ).length;
  function change<K extends keyof Options>(key: K, value: Options[K]) {
    setOptions((previous) => ({ ...previous, [key]: value }));
  }
  useEffect(() => {
    const saved = localStorage.getItem("luau-theme");
    const chosen = saved === "light" ? "light" : "dark";
    setTheme(chosen);
    document.documentElement.dataset.theme = chosen;
    const value = Number(localStorage.getItem("luau-tree-width"));
    if (value >= 180 && value <= 420) setWidth(value);
    return () => supervisor.current?.dispose();
  }, []);
  function toggleTheme() {
    const value = theme === "dark" ? "light" : "dark";
    setTheme(value);
    document.documentElement.dataset.theme = value;
    localStorage.setItem("luau-theme", value);
  }
  function resize(value: number) {
    setWidth(value);
    localStorage.setItem("luau-tree-width", String(value));
  }
  function local() {
    supervisor.current ??= new WorkerSupervisor(
      new URL(`${BASE}/runtime/${version.asset_id}/worker.mjs`, location.href).href,
      new URL(`${BASE}/runtime/manifest.json`, location.href).href,
      version.version,
      version.asset_id,
      setStage,
    );
    return supervisor.current;
  }
  async function commit(items: { path: string; bytes: Uint8Array }[]) {
    const normalized = await normalizeFiles([
      ...filesRef.current.map((file) => ({ path: file.originalPath, bytes: file.bytes })),
      ...items,
    ]);
    const before = filesRef.current;
    filesRef.current = normalized;
    setFiles(normalized);
    setIncluded((previous) => mergedSelection(previous, before, normalized));
    setSelected((previous) => previous || normalized[0]?.id || "");
    setError("");
    return normalized
      .filter((file) => !before.some((old) => old.id === file.id))
      .map((file) => file.id);
  }
  async function expand(items: { path: string; bytes: Uint8Array }[]) {
    const expanded: { path: string; bytes: Uint8Array }[] = [];
    let total = 0;
    for (const item of items) {
      if (zipSignature(item.bytes)) {
        if (item.bytes.length > 16 * 1024 * 1024) throw new Error("ZIP exceeds 16 MiB.");
        const input = item.bytes.slice();
        const value = await utility("unzip", { input: input.buffer }, [input.buffer]);
        for (const nested of value.files as { path: string; bytes: Uint8Array }[]) {
          total += nested.bytes.length;
          if (expanded.length >= 64 || total > 32 * 1024 * 1024)
            throw new Error("Expanded input selection exceeds browser limits.");
          expanded.push(nested);
        }
      } else {
        total += item.bytes.length;
        if (
          expanded.length >= 64 ||
          item.bytes.length > 2 * 1024 * 1024 ||
          total > 32 * 1024 * 1024
        )
          throw new Error("Input selection exceeds 64 files, 2 MiB/file or 32 MiB total.");
        expanded.push(item);
      }
    }
    return await commit(expanded);
  }
  async function importInput<T>(action: () => Promise<T>) {
    if (runActive.current) throw new Error("Cancel the active batch before changing inputs.");
    if (inputAdmission.current)
      throw new Error("An input import is already active; wait for it to finish.");
    inputAdmission.current = true;
    setImporting(true);
    setStage("Importing files locally");
    try {
      const value = await action();
      setStage("Files imported locally");
      return value;
    } catch (reason) {
      setStage("Import rejected; existing files retained");
      throw reason;
    } finally {
      inputAdmission.current = false;
      setImporting(false);
    }
  }
  async function add(items: { path: string; bytes: Uint8Array }[]) {
    await importInput(() => commit(items));
  }
  async function addContainers(items: { path: string; bytes: Uint8Array }[]) {
    await importInput(() => expand(items));
  }
  async function importDrop(event: DragEvent) {
    const added = await importInput(async () => expand(await droppedFiles(event)));
    if (added.length === 1) setAutomatic(added);
  }
  async function selectedFiles(list: FileList | null) {
    if (!list) return;
    try {
      await importInput(async () => {
        const values = Array.from(list);
        if (values.length > 64) throw new Error("Browser input limit is 64 files.");
        const items: { path: string; bytes: Uint8Array }[] = [];
        let total = 0;
        for (const file of values) {
          const prefix = new Uint8Array(await file.slice(0, 4).arrayBuffer());
          const maximum = zipSignature(prefix) ? 16 * 1024 * 1024 : 2 * 1024 * 1024;
          if (file.size > maximum)
            throw new Error(`File exceeds its source/ZIP limit: ${file.name}`);
          total += file.size;
          if (total > 32 * 1024 * 1024) throw new Error("Selected input containers exceed 32 MiB.");
          items.push({
            path: file.webkitRelativePath || file.name,
            bytes: new Uint8Array(await file.arrayBuffer()),
          });
        }
        await expand(items);
      });
    } catch (reason) {
      setError(message(reason));
    }
  }
  async function archive(file: File | undefined) {
    if (!file) return;
    try {
      await importInput(async () => {
        if (file.size > 16 * 1024 * 1024) throw new Error("ZIP exceeds 16 MiB.");
        setStage("Importing bounded ZIP locally");
        const input = await file.arrayBuffer();
        const value = await utility("unzip", { input }, [input]);
        await commit(value.files as { path: string; bytes: Uint8Array }[]);
      });
    } catch (reason) {
      setError(message(reason));
    }
  }
  async function sample(name = "verified.bc") {
    try {
      await importInput(async () => {
        const response = await fetch(`${BASE}/examples/manifest.json`, { cache: "no-store" });
        if (!response.ok) throw new Error("Known-source example manifest unavailable.");
        const list = (await response.json()) as {
          engine_version: string;
          entries: { path: string; sha256: string; bytes: number }[];
        };
        const item = list.entries.find((entry) => entry.path === `examples/${name}`);
        if (
          list.engine_version !== version.version ||
          !item ||
          !/^examples\/[a-z0-9._-]+$/.test(item.path) ||
          item.bytes > 2 * 1024 * 1024
        )
          throw new Error("Public example manifest is invalid or differs from this release.");
        const asset = await fetch(`${BASE}/${item.path}`, { cache: "no-store" });
        if (!asset.ok) throw new Error("Example asset unavailable.");
        const bytes = new Uint8Array(await asset.arrayBuffer());
        const digest = Array.from(
          new Uint8Array(await crypto.subtle.digest("SHA-256", bytes)),
          (byte) => byte.toString(16).padStart(2, "0"),
        ).join("");
        if (bytes.length !== item.bytes || digest !== item.sha256)
          throw new Error("Example asset identity mismatch.");
        await commit([{ path: `Known source/${name}`, bytes }]);
      });
    } catch (reason) {
      setError(message(reason));
    }
  }
  useEffect(() => {
    if (!automatic.length || importing || running) return;
    const ids = automatic;
    setAutomatic([]);
    void run(ids);
  }, [automatic, importing, running]);
  async function run(only?: string[]) {
    if (inputAdmission.current) {
      setError("Wait for the active input import before processing.");
      return;
    }
    const selection = files.filter(
      (file) =>
        (only ? only.includes(file.id) : included.has(file.id)) &&
        !(
          outcomesRef.current[file.id]?.result &&
          outcomesRef.current[file.id].generation === signature
        ),
    );
    if (!selection.length || runActive.current) {
      if (!runActive.current) setStage("Selected results already match the current settings");
      return;
    }
    const sequence = ++runSerial.current;
    const snapshot = { ...options };
    let contracts;
    try {
      contracts = contractMaps(snapshot.contracts);
    } catch (reason) {
      setError(message(reason));
      return;
    }
    cancelled.current = false;
    runActive.current = true;
    setRunning(true);
    setStage("Preparing local jobs");
    setError("");
    setContextNotes([]);
    setOutcomes((previous) => {
      const next = { ...previous };
      for (const file of selection) next[file.id] = { status: "queued", generation: signature };
      return next;
    });
    const worker = local();
    const modules: Record<string, string> = Object.create(null);
    const detections: Record<string, { ok: boolean; format?: string; error?: unknown }> = {};
    const duplicateModules = new Set<string>();
    const notes: string[] = [];
    try {
      await worker.ready();
      if (snapshot.project) {
        let total = 0;
        for (const file of files) {
          if (cancelled.current) break;
          const copy = file.bytes.slice();
          const detected = await worker.request(
            {
              kind: "detect",
              id: crypto.randomUUID(),
              input: copy.buffer,
              format: snapshot.format,
            },
            10000,
            [copy.buffer],
          );
          const detection = detected.detection as { ok: boolean; format?: string; error?: unknown };
          detections[file.id] = detection;
          if (
            detection.ok &&
            (detection.format === "luau_source" || detection.format === "lua_source")
          ) {
            const key = logicalPath(file.originalPath);
            if (Object.hasOwn(modules, key)) {
              delete modules[key];
              duplicateModules.add(key);
              notes.push(`Ambiguous supplied module path omitted from static resolution: ${key}`);
              continue;
            }
            if (duplicateModules.has(key)) continue;
            total += file.bytes.length;
            if (total > 4 * 1024 * 1024)
              throw new Error(
                "Supplied source module context exceeds 4 MiB; disable project context or import a smaller project.",
              );
            modules[key] = new TextDecoder("utf-8", { fatal: true }).decode(file.bytes);
          }
        }
        setContextNotes(notes);
      }
      let workerFailures = 0;
      for (const file of selection) {
        if (cancelled.current || sequence !== runSerial.current) {
          setOutcomes((previous) => ({
            ...previous,
            [file.id]: { status: "cancelled", generation: signature },
          }));
          continue;
        }
        setSelected(file.id);
        setOutcomes((previous) => ({
          ...previous,
          [file.id]: {
            status: "processing",
            generation: signature,
            format: detections[file.id]?.format,
          },
        }));
        const bytes = file.bytes.slice();
        try {
          const configurationJson = JSON.stringify(
            configuration(
              snapshot,
              logicalPath(file.originalPath),
              snapshot.project ? modules : {},
              contracts,
            ),
          );
          const value = await worker.request(
            {
              kind: "process",
              id: crypto.randomUUID(),
              input: bytes.buffer,
              format: snapshot.format,
              configuration: configurationJson,
              deadlineMs: snapshot.deadline,
            },
            snapshot.deadline,
            [bytes.buffer],
          );
          if (sequence !== runSerial.current) continue;
          const envelope = value.envelope as { ok: boolean; result?: Decompiled; error?: unknown };
          if (!envelope.ok || !envelope.result) {
            const failedStage =
              typeof envelope.error === "object" &&
              envelope.error !== null &&
              "stage" in envelope.error
                ? envelope.error.stage
                : undefined;
            setOutcomes((previous) =>
              admitOutcome(previous, file.id, {
                status:
                  failedStage === "deadline"
                    ? "timed_out"
                    : failedStage === "cancelled"
                      ? "cancelled"
                      : "failed",
                error: envelope.error ?? "No reconstruction returned",
                generation: signature,
                resultBytes: Number(value.resultBytes),
              }),
            );
            continue;
          }
          const processed = envelope.result;
          if (processed.input_sha256 !== file.sha256)
            throw new Error("Input identity changed; result discarded.");
          const status: Status = !processed.complete
            ? "failed"
            : processed.validation.required_passed
              ? "complete"
              : "quality_failed";
          setOutcomes((previous) =>
            admitOutcome(previous, file.id, {
              status,
              result: processed,
              elapsedMillis: value.elapsedMillis as number,
              memory: value.memory as Outcome["memory"],
              generation: signature,
              format: detections[file.id]?.format,
              resultBytes: Number(value.resultBytes),
              validationMetrics: value.validationMetrics,
            }),
          );
        } catch (reason) {
          const status = reason instanceof LocalFailure ? reason.kind : "failed";
          setOutcomes((previous) => ({
            ...previous,
            [file.id]: { status, error: message(reason), generation: signature },
          }));
          if (status === "failed" && ++workerFailures >= 3) {
            cancelled.current = true;
            setError(
              "Three worker failures ended this bounded batch; completed results are retained.",
            );
          }
        }
      }
    } catch (reason) {
      setError(message(reason));
      setOutcomes((previous) => {
        const next = { ...previous };
        for (const file of selection)
          if (next[file.id]?.status === "queued" || next[file.id]?.status === "processing")
            next[file.id] = {
              status: cancelled.current ? "cancelled" : "failed",
              error: message(reason),
              generation: signature,
            };
        return next;
      });
    } finally {
      if (sequence === runSerial.current) {
        runActive.current = false;
        setRunning(false);
        setStage(
          cancelled.current
            ? "Batch cancelled; completed results retained"
            : "Batch finished locally",
        );
      }
    }
  }
  function cancel() {
    cancelled.current = true;
    supervisor.current?.cancel();
    setStage("Cancelling local worker");
  }
  async function copy() {
    if (!result) return;
    try {
      await navigator.clipboard.writeText(result.source);
      setToast("Finalized output copied");
      setTimeout(() => setToast(""), 2000);
    } catch {
      setError("Clipboard access denied; download the file or select its text.");
    }
  }
  async function exportZip() {
    try {
      const completed = files.filter((file) => outcomes[file.id]?.result?.source);
      if (!completed.length) return;
      const entries = completed.map((file) => ({
        path: file.outputPath,
        bytes: new TextEncoder().encode(outcomes[file.id].result!.source),
      }));
      const value = await utility(
        "zip",
        { files: entries },
        entries.map((entry) => entry.bytes.buffer),
      );
      save(new Uint8Array(value.output as ArrayBuffer), "luau-output.zip", "application/zip");
    } catch (reason) {
      setError(message(reason));
    }
  }
  function include(id: string) {
    if (!running && !inputAdmission.current)
      setIncluded((previous) => {
        const next = new Set(previous);
        if (next.has(id)) next.delete(id);
        else next.add(id);
        return next;
      });
  }
  function clear() {
    if (runActive.current) {
      setError("Cancel the active batch before clearing files.");
      return;
    }
    setAutomatic([]);
    if (inputAdmission.current) {
      setError("Wait for the active input import before clearing files.");
      return;
    }
    filesRef.current = [];
    setFiles([]);
    setOutcomes({});
    setSelected("");
    setIncluded(new Set());
  }
  const rendered =
    tab === "baseline"
      ? (result?.baseline_source ?? "No separate faithful candidate was needed.")
      : tab === "report"
        ? JSON.stringify(outcome ?? {}, null, 2)
        : tab === "input"
          ? current
            ? (() => {
                try {
                  return new TextDecoder("utf-8", { fatal: true }).decode(current.bytes);
                } catch {
                  return (
                    Array.from(current.bytes.slice(0, 4096), (byte) =>
                      byte.toString(16).padStart(2, "0"),
                    ).join(" ") +
                    (current.bytes.length > 4096
                      ? "\n... hexadecimal preview limited to4096bytes; original bytes retained"
                      : "")
                  );
                }
              })()
            : ""
          : (result?.source ?? "");
  return {
    files,
    selected,
    setSelected,
    included,
    outcomes,
    options,
    change,
    setOptions,
    running,
    importing,
    stage,
    error,
    setError,
    pasteOpen,
    setPasteOpen,
    paste,
    setPaste,
    pasteName,
    setPasteName,
    tab,
    setTab,
    theme,
    toggleTheme,
    width,
    resize,
    dragging,
    setDragging,
    stale,
    current,
    outcome,
    result,
    complete,
    typed,
    fileInput,
    folderInput,
    zipInput,
    add,
    addContainers,
    importDrop,
    selectedFiles,
    archive,
    sample,
    run,
    cancel,
    copy,
    exportZip,
    include,
    clear,
    rendered,
    contextNotes,
    toast,
  };
}
