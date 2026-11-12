export type Asset = { path: string; bytes: number; sha256: string };
export type Manifest = {
  schema: number;
  engine_version: string;
  asset_id: string;
  analyzer_revision: string;
  analyzer_source_sha256: string;
  definitions_sha256: string;
  assets: Record<string, Asset>;
  limits: Record<string, number>;
};
type QualityModule = {
  _malloc(size: number): number;
  _free(pointer: number): void;
  _luau_quality_set_definitions(pointer: number, length: number): number;
  _luau_quality_validate(pointer: number, length: number): number;
  _luau_quality_result_length(): number;
  UTF8ToString(pointer: number, length: number): string;
  HEAPU8: Uint8Array;
};
type EngineModule = {
  default(input: { module_or_path: Uint8Array }): Promise<unknown>;
  process(
    input: Uint8Array,
    format: string,
    config: string,
    deadline: number,
    memory: number,
  ): string;
  detect(input: Uint8Array, format: string): string;
  capabilities(): string;
  engine_memory(): WebAssembly.Memory;
};
export type ValidationFrame = {
  elapsedMillis: number;
  compilerMicros?: number;
  analyzerMicros?: number;
  contextInitializationMicros?: number;
  contextReused?: boolean;
};
export type Runtime = {
  engine: EngineModule;
  quality: QualityModule;
  manifest: Manifest;
  initialization: Record<string, number>;
  validationFrames: ValidationFrame[];
  memory(): { engine_linear_bytes: number; analyzer_linear_bytes: number };
};

export async function sha256(bytes: Uint8Array): Promise<string> {
  const value = await crypto.subtle.digest("SHA-256", bytes as BufferSource);
  return Array.from(new Uint8Array(value), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

export async function loadEngine(
  manifestUrl: string,
  expectedVersion: string,
  progress: (stage: string) => void,
  expectedAssetId: string,
): Promise<Runtime> {
  const start = performance.now();
  const initialization: Record<string, number> = {};
  const endpoint = new URL(manifestUrl);
  const response = await fetch(endpoint, {
    cache: "no-store",
    credentials: "omit",
    redirect: "error",
  });
  if (!response.ok)
    throw new Error(
      `Engine manifest unavailable (HTTP ${response.status}); reload or restore the matching static deployment.`,
    );
  const text = await response.text();
  if (text.length > 65536) throw new Error("Engine manifest exceeds its bound.");
  const manifest = JSON.parse(text) as Manifest;
  if (
    manifest.schema !== 1 ||
    manifest.engine_version !== expectedVersion ||
    manifest.asset_id !== expectedAssetId ||
    !/^[a-f0-9]{24}$/.test(manifest.asset_id)
  )
    throw new Error("Frontend and engine versions differ; reload the complete deployment.");
  const required = [
    "engine_module",
    "engine_wasm",
    "analyzer_module",
    "analyzer_wasm",
    "definitions",
  ];
  async function asset(name: string) {
    const row = manifest.assets[name];
    if (
      !row ||
      !new RegExp(`^${manifest.asset_id}/[a-zA-Z0-9._-]+$`).test(row.path) ||
      !/^[a-f0-9]{64}$/.test(row.sha256) ||
      row.bytes < 1 ||
      row.bytes > 32 * 1024 * 1024
    )
      throw new Error(`Invalid static asset descriptor: ${name}`);
    progress(`Loading ${name.replaceAll("_", " ")}`);
    const url = new URL(row.path, endpoint);
    if (url.origin !== endpoint.origin) throw new Error("Static asset origin mismatch.");
    const fetched = await fetch(url, { cache: "no-store", credentials: "omit", redirect: "error" });
    if (!fetched.ok)
      throw new Error(
        `Missing ${name} (HTTP ${fetched.status}); restore the complete static deployment.`,
      );
    const data = new Uint8Array(await fetched.arrayBuffer());
    if (data.length !== row.bytes || (await sha256(data)) !== row.sha256)
      throw new Error(`Corrupt or mixed-version ${name}; reload or restore matching assets.`);
    return data;
  }
  for (const key of required) if (!manifest.assets[key]) throw new Error(`Missing asset: ${key}`);
  const [engineJavaScript, engineWasm, analyzerJavaScript, analyzerWasm, definitions] =
    await Promise.all(required.map(asset));
  initialization.assetLoadMillis = performance.now() - start;
  if ((await sha256(definitions)) !== manifest.definitions_sha256)
    throw new Error("Roblox definition digest mismatch.");
  async function moduleSource(data: Uint8Array) {
    const url = URL.createObjectURL(new Blob([data as BlobPart], { type: "text/javascript" }));
    try {
      return await import(url);
    } finally {
      URL.revokeObjectURL(url);
    }
  }
  progress("Initializing pinned Luau analyzer");
  const analyzerStart = performance.now();
  const analyzerFactory = (await moduleSource(analyzerJavaScript)).default;
  const quality = (await analyzerFactory({
    wasmBinary: analyzerWasm,
    locateFile: () => new URL(manifest.assets.analyzer_wasm.path, endpoint).href,
    print: () => {},
    printErr: () => {},
  })) as QualityModule;
  initialization.analyzerModuleMillis = performance.now() - analyzerStart;
  const definitionStart = performance.now();
  const definitionPointer = quality._malloc(definitions.length);
  if (!definitionPointer) throw new Error("Analyzer definition allocation limit reached.");
  try {
    quality.HEAPU8.set(definitions, definitionPointer);
    if (quality._luau_quality_set_definitions(definitionPointer, definitions.length) !== 1)
      throw new Error("Analyzer rejected the pinned definitions.");
  } finally {
    quality._free(definitionPointer);
  }
  initialization.definitionsMillis = performance.now() - definitionStart;
  const validationFrames: ValidationFrame[] = [];
  const globals = globalThis as unknown as {
    __luauValidate(frame: Uint8Array): string;
    __luauValidationAssets(): string;
  };
  globals.__luauValidationAssets = () =>
    JSON.stringify({
      schema: 1,
      engine_version: manifest.engine_version,
      analyzer_sha256: manifest.assets.analyzer_wasm.sha256,
      definitions_sha256: manifest.definitions_sha256,
      source_sha256: manifest.analyzer_source_sha256,
      upstream_revision: manifest.analyzer_revision,
    });
  globals.__luauValidate = (frame) => {
    if (frame.length > 16 * 1024 * 1024) throw new Error("Analyzer request exceeds16MiB.");
    const pointer = quality._malloc(frame.length);
    if (!pointer) throw new Error("Analyzer memory limit reached.");
    try {
      quality.HEAPU8.set(frame, pointer);
      const frameStart = performance.now();
      const result = quality._luau_quality_validate(pointer, frame.length);
      const text = quality.UTF8ToString(result, quality._luau_quality_result_length());
      const observation = JSON.parse(text);
      if (validationFrames.length < 16)
        validationFrames.push({
          elapsedMillis: performance.now() - frameStart,
          compilerMicros: observation.compiler_micros,
          analyzerMicros: observation.analyzer_micros,
          contextInitializationMicros: observation.context_initialization_micros,
          contextReused: observation.context_reused,
        });
      delete observation.context_reused;
      delete observation.context_initialization_micros;
      return JSON.stringify(observation);
    } finally {
      quality._free(pointer);
    }
  };
  progress("Initializing shared Rust engine");
  const engineStart = performance.now();
  const engine = (await moduleSource(engineJavaScript)) as EngineModule;
  await engine.default({ module_or_path: engineWasm });
  initialization.rustModuleMillis = performance.now() - engineStart;
  const capabilities = JSON.parse(engine.capabilities());
  if (
    (capabilities.engine_version ?? capabilities.version ?? capabilities.package_version) !==
    expectedVersion
  )
    throw new Error("Rust engine identity differs from the frontend manifest.");
  initialization.totalMillis = performance.now() - start;
  return {
    engine,
    quality,
    manifest,
    initialization,
    validationFrames,
    memory: () => ({
      engine_linear_bytes: engine.engine_memory().buffer.byteLength,
      analyzer_linear_bytes: quality.HEAPU8.buffer.byteLength,
    }),
  };
}
