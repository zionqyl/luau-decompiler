import type { Options } from "../lib/domain.ts";
export default function OptionsPanel({
  options,
  change,
  setOptions,
}: {
  options: Options;
  change<K extends keyof Options>(key: K, value: Options[K]): void;
  setOptions(value: Options | ((previous: Options) => Options)): void;
}) {
  return (
    <aside className="options-panel">
      <h2>Processing options</h2>
      <label>
        Output policy
        <select
          value={options.policy}
          onChange={(event) => {
            const policy = event.target.value;
            setOptions((previous) => ({
              ...previous,
              policy,
              typing: policy === "faithful" ? "off" : "annotated",
              validation: policy === "verified_typed" ? "strict_required" : "check",
            }));
          }}
        >
          <option value="verified_typed">Verified typed</option>
          <option value="annotated">Annotated</option>
          <option value="faithful">Faithful</option>
        </select>
      </label>
      <p className="hint">
        Verified typed requires final syntax, compilation, strict analysis, and meaningful
        annotations. Failed quality retains available output.
      </p>
      <label>
        Input format
        <select value={options.format} onChange={(event) => change("format", event.target.value)}>
          <option value="auto">Detect content</option>
          <option value="luau_source">Luau source subset</option>
          <option value="lua_source">Lua 5.1 compatible subset</option>
          <option value="luau_bytecode">Luau bytecode</option>
        </select>
      </label>
      <label>
        Fallback naming
        <select value={options.naming} onChange={(event) => change("naming", event.target.value)}>
          <option value="snake_case">snake_case</option>
          <option value="camelCase">camelCase</option>
          <option value="PascalCase">PascalCase</option>
        </select>
      </label>
      <label className="check">
        <input
          type="checkbox"
          checked={options.preserveNames}
          onChange={(event) => change("preserveNames", event.target.checked)}
        />
        Preserve supplied/debug local names
      </label>
      <p className="hint">
        Turn this off to apply the style to eligible local bindings. Properties, keys, globals, and
        exported contracts retain their meaning.
      </p>
      <div className="option-row">
        <label>
          Indent
          <select value={options.indent} onChange={(event) => change("indent", event.target.value)}>
            <option value="  ">2 spaces</option>
            <option value="    ">4 spaces</option>
            <option value={"\t"}>Tab</option>
          </select>
        </label>
        <label>
          Line width
          <select
            value={options.width}
            onChange={(event) => change("width", Number(event.target.value))}
          >
            <option>80</option>
            <option>100</option>
            <option>120</option>
          </select>
        </label>
      </div>
      <label className="check">
        <input
          type="checkbox"
          checked={options.multilineTables}
          onChange={(event) => change("multilineTables", event.target.checked)}
        />
        Multiline tables
      </label>
      <label className="check">
        <input
          type="checkbox"
          checked={options.multilineCalls}
          onChange={(event) => change("multilineCalls", event.target.checked)}
        />
        Wrap long calls
      </label>
      <label className="check">
        <input
          type="checkbox"
          checked={options.blankLines}
          onChange={(event) => change("blankLines", event.target.checked)}
        />
        Blank lines between sections
      </label>
      <label>
        Annotations
        <select
          disabled={options.policy === "verified_typed"}
          value={options.typing}
          onChange={(event) => change("typing", event.target.value)}
        >
          <option value="annotated">Infer justified annotations</option>
          <option value="off">Retain existing source types only</option>
        </select>
      </label>
      <label>
        Validation
        <select
          disabled={options.policy === "verified_typed"}
          value={options.validation}
          onChange={(event) => change("validation", event.target.value)}
        >
          <option value="strict_required">Require strict analysis</option>
          <option value="check">Check and report</option>
          <option value="off">Explicitly disabled</option>
        </select>
      </label>
      {options.validation === "off" && (
        <p className="notice compact">
          Validation is disabled. A header or strict directive is not verification.
        </p>
      )}
      <label>
        Annotation detail
        <select
          value={options.verbosity}
          onChange={(event) => change("verbosity", event.target.value)}
        >
          <option value="extensive">Extensive justified types</option>
          <option value="useful">Omit obvious types</option>
        </select>
      </label>
      <p className="hint">
        Reducing annotations can fail the selected meaningful-typing requirement; quality never
        silently downgrades.
      </p>
      <label>
        Per-file deadline (ms)
        <input
          type="number"
          min={100}
          max={120000}
          step={100}
          value={options.deadline}
          onChange={(event) =>
            change("deadline", Math.max(100, Math.min(120000, Number(event.target.value) || 100)))
          }
        />
      </label>
      <label className="check">
        <input
          type="checkbox"
          checked={options.project}
          onChange={(event) => change("project", event.target.checked)}
        />
        Resolve supplied source modules locally
      </label>
      <details className="advanced-options">
        <summary>Advanced representation and control flow</summary>{" "}
        <label>
          Bytecode encoding
          <select
            value={options.encoding}
            onChange={(event) => change("encoding", event.target.value)}
          >
            <option value="auto">Detect evidenced representation</option>
            <option value="roblox_signed_74171870">Roblox 0.747.0.7471481 signed container</option>
            <option value="upstream">Upstream serialized instructions</option>
            <option value="roblox_opcode227">Explicit Roblox opcode227</option>
          </select>
        </label>
        <p className="hint">
          Automatic detection recognizes upstream bytes and evidenced signed containers. Unmarked
          opcode227 requires an explicit override; signature authenticity is not verified.
        </p>
        <label>
          Semantic profile
          <select
            value={options.profile}
            onChange={(event) => change("profile", event.target.value)}
          >
            <option value="auto">Match serialized version</option>
            {Array.from({ length: 12 }, (_, index) => index + 3).map((value) => (
              <option value={`luau-v${value}`} key={value}>
                luau-v{value}
              </option>
            ))}
          </select>
        </label>
        <label>
          Control flow
          <select value={options.flow} onChange={(event) => change("flow", event.target.value)}>
            <option value="auto">Structured with proven fallback</option>
            <option value="structured">Structured only</option>
            <option value="dispatcher">Conservative dispatcher</option>
          </select>
        </label>
        <label>
          Bytecode entry
          <select value={options.entry} onChange={(event) => change("entry", event.target.value)}>
            <option value="script">Script chunk</option>
            <option value="function">Return dumped function</option>
          </select>
        </label>
      </details>{" "}
      <details>
        <summary>Explicit contracts and overrides</summary>
        <p className="hint">
          JSON maps: bindings, globals, instances, requires, names. Binding identities are in the
          report. Raw supplemental.d.luau definition files are not loaded as external definitions;
          use the supported explicit contracts. Assumptions apply to every selected input.
        </p>
        <textarea
          aria-label="Explicit contracts JSON"
          rows={6}
          spellCheck={false}
          value={options.contracts}
          onChange={(event) => change("contracts", event.target.value)}
        />
      </details>
      <details>
        <summary>Limits and privacy</summary>
        <p className="hint">
          One processing worker. 64 files, 2 MiB/file, 32 MiB total input; 4 MiB/output and 16 MiB
          retained output. ZIP 16 MiB compressed/32 MiB expanded. Linear-memory caps: Rust 256 MiB +
          analyzer 512 MiB, with separately bounded JS input/output and 32 MiB of retained
          serialized results. These are not total browser RSS limits.
        </p>
        <p className="hint">
          Only static assets are requested. Source, bytecode, filenames and paths stay local.
          Offline reload is not advertised.
        </p>
      </details>
    </aside>
  );
}
