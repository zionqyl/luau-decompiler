export const BASE = "/luau-decompiler";
export type Status =
  | "ready"
  | "queued"
  | "processing"
  | "complete"
  | "quality_failed"
  | "failed"
  | "cancelled"
  | "timed_out";
export type Quality = {
  syntax: string;
  compilation: string;
  strict_analysis: string;
  required_passed: boolean;
  output_policy: string;
  diagnostics: unknown[];
  missing_dependencies: string[];
  external_assumptions: string[];
  meaningful_typing: {
    passed: boolean;
    binding_coverage_percent: number;
    runtime_annotations: number;
    failures: string[];
  };
  [key: string]: unknown;
};
export type Decompiled = {
  source: string;
  baseline_source?: string | null;
  complete: boolean;
  quality: string;
  profile: string;
  validation: Quality;
  type_report: Record<string, unknown>;
  input_sha256: string;
  [key: string]: unknown;
};
export type Outcome = {
  status: Status;
  result?: Decompiled;
  error?: unknown;
  elapsedMillis?: number;
  memory?: { engine_linear_bytes: number; analyzer_linear_bytes: number };
  generation?: string;
  format?: string;
  resultBytes?: number;
  validationMetrics?: unknown;
};
export type Options = {
  policy: string;
  format: string;
  encoding: string;
  profile: string;
  flow: string;
  verbosity: string;
  naming: string;
  preserveNames: boolean;
  indent: string;
  width: number;
  multilineTables: boolean;
  multilineCalls: boolean;
  blankLines: boolean;
  typing: string;
  validation: string;
  entry: string;
  deadline: number;
  project: boolean;
  contracts: string;
};
export type ContractMaps = {
  bindings: Record<string, string>;
  globals: Record<string, string>;
  instances: Record<string, string>;
  requires: Record<string, string>;
  names: Record<string, string>;
};
export const initialOptions: Options = {
  policy: "verified_typed",
  format: "auto",
  encoding: "auto",
  profile: "auto",
  flow: "auto",
  verbosity: "extensive",
  naming: "roblox",
  preserveNames: true,
  indent: "    ",
  width: 100,
  multilineTables: true,
  multilineCalls: true,
  blankLines: true,
  typing: "annotated",
  validation: "strict_required",
  entry: "script",
  deadline: 30000,
  project: true,
  contracts: "{}",
};
export const statusLabels: Record<Status, string> = {
  ready: "Ready",
  queued: "Queued",
  processing: "Processing",
  complete: "Complete",
  quality_failed: "Quality failed",
  failed: "Failed",
  cancelled: "Cancelled",
  timed_out: "Timed out",
};
export function message(error: unknown): string {
  return error instanceof Error
    ? error.message
    : typeof error === "string"
      ? error
      : JSON.stringify(error, null, 2);
}
export function contractMaps(text: string): ContractMaps {
  if (text.length > 65536) throw new Error("Contract configuration exceeds 64 KiB.");
  const parsed = JSON.parse(text) as Record<string, unknown>;
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed))
    throw new Error("Contracts must be a JSON object.");
  const result: ContractMaps = {
    bindings: Object.create(null),
    globals: Object.create(null),
    instances: Object.create(null),
    requires: Object.create(null),
    names: Object.create(null),
  };
  for (const [key, value] of Object.entries(parsed)) {
    if (!Object.hasOwn(result, key) || !value || typeof value !== "object" || Array.isArray(value))
      throw new Error(`Unsupported contract map: ${key}`);
    const entries = Object.entries(value);
    if (entries.length > 256) throw new Error(`Too many ${key} contracts.`);
    for (const [name, type] of entries) {
      if (name.length > 256 || typeof type !== "string" || type.length > 4096)
        throw new Error(`Invalid ${key} contract.`);
      result[key as keyof ContractMaps][name] = type;
    }
  }
  return result;
}
export function configuration(
  options: Options,
  entry: string,
  modules: Record<string, string>,
  contracts: ContractMaps,
) {
  const projectModules = { ...modules };
  delete projectModules[entry];
  const moduleNameHint = Array.from(
    entry
      .split("/")
      .at(-1)
      ?.replace(/\.(?:luau|lua|bc|bin)$/i, "")
      .replace(/[\0\r\n]/g, "_") || "",
  )
    .slice(0, 64)
    .join("");
  return {
    bytecode_encoding: options.encoding,
    profile: options.profile,
    control_flow: options.flow,
    output_policy: options.policy,
    entry_output: options.entry,
    naming: options.naming,
    naming_options: {
      use_debug_names: options.preserveNames,
      module_name_hint: moduleNameHint || null,
    },
    name_overrides: contracts.names,
    indent: options.indent,
    formatting: {
      line_width: options.width,
      multiline_tables: options.multilineTables,
      multiline_calls: options.multilineCalls,
      blank_lines: options.blankLines,
    },
    typing: {
      mode: options.typing,
      verbosity: options.verbosity,
      binding_types: contracts.bindings,
    },
    validation: {
      mode: options.validation,
      timeout_ms: Math.max(100, Math.min(options.deadline, 10000)),
      max_workers: 1,
      max_cache_bytes: 0,
      project: {
        entry,
        modules: projectModules,
        requires: contracts.requires,
        external_globals: contracts.globals,
        instance_types: contracts.instances,
      },
    },
    limits: {
      max_bytes: 2 * 1024 * 1024,
      max_output_bytes: 4 * 1024 * 1024,
      max_depth: 128,
      max_analysis_steps: 10000000,
    },
  };
}
export function logicalPath(path: string) {
  return path.replace(/\.(lua|luau|luac|bc)$/i, "");
}
export function verified(result?: Decompiled) {
  return (
    !!result?.complete &&
    result.validation.output_policy === "verified_typed" &&
    result.validation.required_passed &&
    result.validation.syntax === "passed" &&
    result.validation.compilation === "passed" &&
    result.validation.strict_analysis === "passed" &&
    result.validation.meaningful_typing.passed
  );
}
