import { message, type Decompiled, type Outcome } from "../lib/domain.ts";
export default function ValidationPanel({
  result,
  outcome,
  contextNotes,
}: {
  result?: Decompiled;
  outcome?: Outcome;
  contextNotes: string[];
}) {
  return (
    <section className="diagnostics-panel" aria-label="Validation diagnostics">
      <div className="panel-heading">
        <h2>Validation</h2>
        {outcome?.elapsedMillis !== undefined && (
          <span className="hint">Local processing {outcome.elapsedMillis.toFixed(1)}ms</span>
        )}
      </div>
      {result ? (
        <>
          <div className="quality-grid">
            {[
              ["Reconstruction", result.complete ? "complete" : "incomplete"],
              ["Syntax", result.validation.syntax],
              ["Compilation", result.validation.compilation],
              ["Strict analysis", result.validation.strict_analysis],
              [
                "Meaningful typing",
                result.validation.meaningful_typing.passed ? "passed" : "failed",
              ],
              ["Required policy", result.validation.required_passed ? "passed" : "failed"],
            ].map(([label, state]) => (
              <div key={label}>
                <span>{label}</span>
                <strong
                  className={
                    state === "failed" || state === "incomplete"
                      ? "failure"
                      : state === "passed" || state === "complete"
                        ? "success"
                        : ""
                  }
                >
                  {state}
                </strong>
              </div>
            ))}
          </div>
          <div className="diagnostic-list">
            {result.validation.diagnostics.slice(0, 100).map((diagnostic, index) => (
              <pre key={index}>{JSON.stringify(diagnostic, null, 2)}</pre>
            ))}
            {result.validation.diagnostics.length > 100 && (
              <p>
                Showing 100 of {result.validation.diagnostics.length} diagnostics; the Report tab
                retains all.
              </p>
            )}
            {result.validation.meaningful_typing.failures.map((failure, index) => (
              <p className="failure" key={index}>
                {failure}
              </p>
            ))}
            {result.validation.missing_dependencies.map((dependency) => (
              <p className="failure" key={dependency}>
                Missing dependency: {dependency}
              </p>
            ))}
          </div>
          <p className="hint">
            Useful binding coverage {result.validation.meaningful_typing.binding_coverage_percent}%.
            Contracts, any, unknowns, assertions, and recovery attempts remain in the report. Strict
            success is not behavioral equivalence.
          </p>
        </>
      ) : outcome?.error ? (
        <pre className="failure">{message(outcome.error)}</pre>
      ) : (
        <p className="hint">
          Actual syntax, compilation, strict-analysis and annotation-quality results appear after
          processing.
        </p>
      )}
      {contextNotes.map((note) => (
        <p className="hint" key={note}>
          {note}
        </p>
      ))}
      {outcome?.memory && (
        <p className="hint">
          Current WASM linear memory: Rust{" "}
          {(outcome.memory.engine_linear_bytes / 1048576).toFixed(1)}MiB; analyzer{" "}
          {(outcome.memory.analyzer_linear_bytes / 1048576).toFixed(1)}MiB. Browser overhead is
          separate.
        </p>
      )}
    </section>
  );
}
