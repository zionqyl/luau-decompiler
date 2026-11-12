"use client";
import type { CSSProperties } from "react";
import version from "../generated/version.json";
import { BASE, message, verified } from "../lib/domain.ts";
import { save } from "../lib/browser-io.ts";
import { useWorkspace } from "./use-workspace";
import FileTree from "./file-tree";
import OptionsPanel from "./options-panel";
import ValidationPanel from "./validation-panel";
import SourceView from "./source-view";
import Showcase from "./showcase";
export default function Workspace() {
  const state = useWorkspace();
  const { current, outcome, result } = state;
  return (
    <main className="application">
      <header className="topbar">
        <div className="brand">
          <span className="brand-mark" aria-hidden="true">
            [L]
          </span>
          <div>
            <h1>Luau Decompiler</h1>
            <p>Readable output. Real validation. Browser local.</p>
          </div>
        </div>
        <div className="header-actions">
          <span className="version">{version.version}</span>
          <button onClick={state.toggleTheme} aria-label="Toggle color theme">
            {state.theme === "dark" ? "Light theme" : "Dark theme"}
          </button>
          <a href="https://github.com/zionqyl/luau-decompiler" target="_blank" rel="noreferrer">
            Repository
          </a>
        </div>
      </header>
      <section
        className={state.dragging ? "import-area dragging" : "import-area"}
        aria-label="Import supported files"
        onDragOver={(event) => {
          event.preventDefault();
          state.setDragging(true);
        }}
        onDragLeave={() => state.setDragging(false)}
        onDrop={async (event) => {
          event.preventDefault();
          state.setDragging(false);
          if (state.running) {
            state.setError("Cancel the active batch before importing files.");
            return;
          }
          try {
            await state.importDrop(event);
          } catch (reason) {
            state.setError(message(reason));
          }
        }}
      >
        <div>
          <strong>Bring your files</strong>
          <p>Drop supported source, bytecode, or folders. Inputs and paths stay in this browser.</p>
        </div>
        <div className="import-actions">
          <button
            disabled={state.running || state.importing}
            onClick={() => state.fileInput.current?.click()}
          >
            Import files
          </button>
          <button
            disabled={state.running || state.importing}
            onClick={() => state.folderInput.current?.click()}
          >
            Folder
          </button>
          <button
            disabled={state.running || state.importing}
            onClick={() => state.zipInput.current?.click()}
          >
            ZIP
          </button>
          <button
            disabled={state.running || state.importing}
            onClick={() => state.setPasteOpen((value) => !value)}
          >
            Paste source
          </button>
          <button
            disabled={state.running || state.importing}
            className="text-button"
            onClick={() => state.sample()}
          >
            Bytecode demo
          </button>
          <button
            disabled={state.running || state.importing}
            className="text-button"
            onClick={() => state.sample("player_snapshot.luau")}
          >
            Roblox typed demo
          </button>
        </div>
        <input
          ref={state.fileInput}
          data-testid="file-input"
          type="file"
          multiple
          hidden
          onChange={(event) => {
            void state.selectedFiles(event.target.files);
            event.target.value = "";
          }}
        />
        <input
          ref={state.folderInput}
          data-testid="folder-input"
          type="file"
          multiple
          hidden
          {...{ webkitdirectory: "", directory: "" }}
          onChange={(event) => {
            void state.selectedFiles(event.target.files);
            event.target.value = "";
          }}
        />
        <input
          ref={state.zipInput}
          data-testid="zip-input"
          type="file"
          accept=".zip"
          hidden
          onChange={(event) => {
            void state.archive(event.target.files?.[0]);
            event.target.value = "";
          }}
        />
      </section>
      {state.pasteOpen && (
        <section className="paste-panel">
          <label>
            Input filename
            <input
              value={state.pasteName}
              onChange={(event) => state.setPasteName(event.target.value)}
              maxLength={256}
            />
          </label>
          <label>
            Luau source
            <textarea
              data-testid="paste-source"
              value={state.paste}
              onChange={(event) => state.setPaste(event.target.value)}
              spellCheck={false}
              rows={7}
            />
          </label>
          <button
            disabled={state.running || state.importing || !state.paste.length}
            onClick={async () => {
              try {
                await state.add([
                  {
                    path: state.pasteName || "pasted.luau",
                    bytes: new TextEncoder().encode(state.paste),
                  },
                ]);
                state.setPasteOpen(false);
                state.setPaste("");
              } catch (reason) {
                state.setError(message(reason));
              }
            }}
          >
            Add source
          </button>
        </section>
      )}
      {state.error && (
        <div className="notice error" role="alert">
          {state.error}
          <button onClick={() => state.setError("")} aria-label="Dismiss error">
            Dismiss
          </button>
        </div>
      )}
      <div className="workspace-toolbar">
        <div className="processing-state" role="status" aria-live="polite">
          <span className={state.running ? "status-dot processing" : "status-dot"} />
          {state.stage}
        </div>
        <div>
          <span className="counts">
            {state.files.length} files / {state.complete} reconstructed / {state.typed} verified
          </span>
          <button
            disabled={
              !state.files.some((file) => state.included.has(file.id)) ||
              state.running ||
              state.importing
            }
            onClick={() => void state.run()}
            className="primary"
            data-testid="run"
          >
            Process selected
          </button>
          <button disabled={!state.running} onClick={state.cancel} data-testid="cancel">
            Cancel
          </button>
        </div>
      </div>
      <section
        className="workspace-grid"
        style={{ "--tree-width": `${state.width}px` } as CSSProperties}
      >
        <aside className="explorer">
          <div className="panel-heading">
            <h2>Files</h2>
            <button
              disabled={state.running || state.importing || !state.files.length}
              onClick={state.clear}
            >
              Clear
            </button>
          </div>
          {state.files.length ? (
            <FileTree
              files={state.files}
              outcomes={state.outcomes}
              selected={state.selected}
              included={state.included}
              disabled={state.running || state.importing}
              onSelect={state.setSelected}
              onInclude={state.include}
            />
          ) : (
            <div className="empty-tree">
              Your project hierarchy appears here.
              <br />
              64 files maximum.
            </div>
          )}
        </aside>
        <div
          className="resize-handle"
          role="separator"
          tabIndex={0}
          aria-label="Resize file tree"
          aria-orientation="vertical"
          aria-valuemin={180}
          aria-valuemax={420}
          aria-valuenow={state.width}
          onKeyDown={(event) => {
            if (event.key === "ArrowLeft") state.resize(Math.max(180, state.width - 10));
            if (event.key === "ArrowRight") state.resize(Math.min(420, state.width + 10));
          }}
          onPointerDown={(event) => {
            const element = event.currentTarget;
            const start = event.clientX;
            const original = state.width;
            element.setPointerCapture(event.pointerId);
            const move = (pointer: PointerEvent) =>
              state.resize(Math.max(180, Math.min(420, original + pointer.clientX - start)));
            const up = () => {
              element.removeEventListener("pointermove", move);
              element.removeEventListener("pointerup", up);
            };
            element.addEventListener("pointermove", move);
            element.addEventListener("pointerup", up);
          }}
        />
        <section className="editor-panel">
          <div className="editor-heading">
            <div className="tab-list" role="tablist" aria-label="Source views">
              {[
                ["source", "Output"],
                ["baseline", "Faithful candidate"],
                ["input", "Input"],
                ["report", "Report"],
              ].map(([key, label]) => (
                <button
                  role="tab"
                  aria-selected={state.tab === key}
                  onClick={() => state.setTab(key)}
                  key={key}
                >
                  {label}
                </button>
              ))}
            </div>
            <div className="export-actions">
              <button disabled={!result?.source} onClick={state.copy}>
                Copy
              </button>
              <button
                disabled={!result?.source}
                onClick={() =>
                  result &&
                  current &&
                  save(
                    new TextEncoder().encode(result.source),
                    current.outputPath.split("/").at(-1)!,
                    "text/plain;charset=utf-8",
                  )
                }
              >
                Download file
              </button>
              <button
                disabled={!state.files.some((file) => state.outcomes[file.id]?.result?.source)}
                onClick={state.exportZip}
              >
                Download ZIP
              </button>
            </div>
          </div>
          <div className="document-title">
            <span>{current?.outputPath ?? "No file selected"}</span>
            {result && (
              <span className={verified(result) && !state.stale ? "badge verified" : "badge"}>
                {verified(result)
                  ? "Verified typed"
                  : outcome?.status === "quality_failed"
                    ? "Retained output: quality failed"
                    : "Faithful reconstruction"}
                {state.stale ? " / previous settings" : ""}
              </span>
            )}
          </div>
          {state.stale && (
            <div className="notice compact">
              Inputs or processing options changed. Results retain their previous validation;
              process again for the current settings.
            </div>
          )}
          {state.rendered ? (
            <SourceView source={state.rendered} formatted={state.tab !== "report"} />
          ) : (
            <div className="editor-empty">
              <span className="empty-mark" aria-hidden="true">
                [ ]
              </span>
              <h2>Start with a supported file</h2>
              <p>
                Luau source and supported bytecode use the same Rust engine as the native tool.
                Strict verification uses the actual pinned Luau analyzer locally.
              </p>
              <p>Nothing is executed. Nothing is uploaded.</p>
            </div>
          )}
        </section>
        <OptionsPanel options={state.options} change={state.change} setOptions={state.setOptions} />
      </section>
      <ValidationPanel result={result} outcome={outcome} contextNotes={state.contextNotes} />
      <Showcase />
      <footer>
        <span>
          Supported Luau bytecode profiles 3-14 and documented source subsets. Standard Lua/LuaJIT
          bytecode and unproved features reject explicitly.
        </span>
        <a
          href={`${BASE}/runtime/${version.asset_id}/licenses.txt`}
          target="_blank"
          rel="noreferrer"
        >
          Licenses and notices
        </a>
      </footer>
      {state.toast && (
        <div className="toast" role="status">
          {state.toast}
        </div>
      )}
    </main>
  );
}
