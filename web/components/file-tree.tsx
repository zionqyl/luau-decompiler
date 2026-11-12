import type { ImportedFile } from "../lib/models.ts";
import { statusLabels, type Outcome } from "../lib/domain.ts";
export default function FileTree({
  files,
  outcomes,
  selected,
  included,
  onSelect,
  onInclude,
  disabled,
}: {
  files: ImportedFile[];
  outcomes: Record<string, Outcome>;
  selected: string;
  included: Set<string>;
  onSelect(id: string): void;
  onInclude(id: string): void;
  disabled: boolean;
}) {
  type Tree = { folders: Map<string, Tree>; files: ImportedFile[] };
  const root: Tree = { folders: new Map(), files: [] };
  for (const file of files) {
    let node = root;
    for (const segment of file.path.split("/").slice(0, -1)) {
      if (!node.folders.has(segment)) node.folders.set(segment, { folders: new Map(), files: [] });
      node = node.folders.get(segment)!;
    }
    node.files.push(file);
  }
  function render(node: Tree): React.ReactNode {
    return (
      <ul>
        {Array.from(node.folders)
          .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
          .map(([name, child]) => (
            <li key={`folder:${name}`}>
              <details open>
                <summary>{name}</summary>
                {render(child)}
              </details>
            </li>
          ))}
        {node.files.map((file) => (
          <li key={file.id} className="file-row">
            <input
              type="checkbox"
              disabled={disabled}
              aria-label={`Process ${file.originalPath}`}
              checked={included.has(file.id)}
              onChange={() => onInclude(file.id)}
            />
            <button
              className={selected === file.id ? "file active" : "file"}
              title={file.originalPath}
              onClick={() => onSelect(file.id)}
            >
              <span className="file-name">{file.path.split("/").at(-1)}</span>
              <span className={`file-state ${outcomes[file.id]?.status ?? "ready"}`}>
                {statusLabels[outcomes[file.id]?.status ?? "ready"]}
              </span>
            </button>
          </li>
        ))}
      </ul>
    );
  }
  return (
    <nav aria-label="Imported file hierarchy" className="file-tree">
      {render(root)}
    </nav>
  );
}
