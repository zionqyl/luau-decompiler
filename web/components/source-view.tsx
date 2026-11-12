import { useMemo } from "react";
import { highlight } from "../lib/highlight.ts";

export default function SourceView({
  source,
  formatted,
  testId = "source-view",
}: {
  source: string;
  formatted: boolean;
  testId?: string;
}) {
  const tokens = useMemo(
    () => (formatted ? highlight(source) : [{ text: source }]),
    [source, formatted],
  );
  const lines = source.split("\n").length;
  const numbered = lines <= 6000;
  return (
    <div className="source-document">
      {numbered && (
        <div className="line-gutter" aria-hidden="true">
          {Array.from({ length: lines }, (_, index) => (
            <span key={index} />
          ))}
        </div>
      )}
      <pre className="source-view" tabIndex={0} data-testid={testId}>
        <code>
          {tokens.map((token, index) => (
            <span className={token.kind ? "syntax-" + token.kind : undefined} key={index}>
              {token.text}
            </span>
          ))}
        </code>
      </pre>
    </div>
  );
}
