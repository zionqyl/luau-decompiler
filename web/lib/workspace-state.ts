import type { ImportedFile } from "./models.ts";
import type { Options, Outcome } from "./domain.ts";

export const RETENTION_LIMITS = Object.freeze({
  sourceBytes: 16 * 1024 * 1024,
  resultBytes: 32 * 1024 * 1024,
});
const encoder = new TextEncoder();

export function processingIdentity(options: Options, files: ImportedFile[]): string {
  return JSON.stringify({
    options,
    project: options.project ? files.map((file) => [file.originalPath, file.sha256]) : [],
  });
}

export function mergedSelection(
  previous: Set<string>,
  before: ImportedFile[],
  after: ImportedFile[],
): Set<string> {
  const existing = new Set(before.map((file) => file.id));
  return new Set(
    after.filter((file) => previous.has(file.id) || !existing.has(file.id)).map((file) => file.id),
  );
}

export function sourceBytes(outcome: Outcome): number {
  const result = outcome.result;
  return result
    ? encoder.encode(result.source).length +
        (typeof result.baseline_source === "string"
          ? encoder.encode(result.baseline_source).length
          : 0)
    : 0;
}

export function admitOutcome(
  outcomes: Record<string, Outcome>,
  id: string,
  outcome: Outcome,
  limits = RETENTION_LIMITS,
): Record<string, Outcome> {
  if (
    outcome.resultBytes !== undefined &&
    (!Number.isSafeInteger(outcome.resultBytes) || outcome.resultBytes < 0)
  )
    throw new Error("Invalid structured-result byte accounting; result discarded.");
  let retainedSource = sourceBytes(outcome);
  let retainedResults = outcome.resultBytes ?? 0;
  for (const [key, existing] of Object.entries(outcomes)) {
    if (key === id) continue;
    retainedSource += sourceBytes(existing);
    retainedResults += existing.resultBytes ?? 0;
  }
  if (retainedSource > limits.sourceBytes)
    throw new Error(
      "Workspace source retention exceeds 16 MiB; download completed results and clear files before processing more.",
    );
  if (retainedResults > limits.resultBytes)
    throw new Error(
      "Workspace structured-result retention exceeds 32 MiB; download completed results and clear files before processing more.",
    );
  return { ...outcomes, [id]: outcome };
}
