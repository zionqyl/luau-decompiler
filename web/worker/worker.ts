import { unzipBounded, zipOutputs } from "../lib/archive.ts";
import { loadEngine, sha256, type Runtime } from "./engine";
let runtime: Promise<Runtime> | undefined;
let processing = false;
self.onmessage = async (event: MessageEvent) => {
  const request = event.data;
  try {
    if (request.kind === "unzip") {
      const files = await unzipBounded(new Uint8Array(request.input));
      self.postMessage(
        { kind: "archive", id: request.id, files },
        files.map((file) => file.bytes.buffer),
      );
      return;
    }
    if (request.kind === "zip") {
      const output = zipOutputs(request.files);
      self.postMessage({ kind: "archive", id: request.id, output: output.buffer }, [output.buffer]);
      return;
    }
    if (request.kind === "init") {
      runtime ??= loadEngine(
        request.manifestUrl,
        request.version,
        (stage) => self.postMessage({ kind: "progress", stage }),
        request.assetId,
      );
      const loaded = await runtime;
      self.postMessage({
        kind: "ready",
        capabilities: JSON.parse(loaded.engine.capabilities()),
        memory: loaded.memory(),
        initialization: loaded.initialization,
        assetId: loaded.manifest.asset_id,
      });
      return;
    }
    if (request.kind === "detect" && runtime) {
      const loaded = await runtime;
      const input = new Uint8Array(request.input);
      self.postMessage({
        kind: "detected",
        id: request.id,
        detection: JSON.parse(loaded.engine.detect(input, request.format)),
      });
      return;
    }
    if (request.kind !== "process" || !runtime)
      throw new Error("Initialize the local engine before processing.");
    if (processing) throw new Error("The bounded worker accepts one active job.");
    processing = true;
    const loaded = await runtime;
    const bytes = new Uint8Array(request.input);
    if (bytes.length > 2 * 1024 * 1024) throw new Error("Input exceeds the browser2 MiB limit.");
    if (typeof request.configuration !== "string" || request.configuration.length > 5 * 1024 * 1024)
      throw new Error("Project/configuration exceeds the browser limit.");
    self.postMessage({
      kind: "progress",
      id: request.id,
      stage: "Reconstructing and validating locally",
    });
    const inputSha256 = await sha256(bytes);
    loaded.validationFrames.length = 0;
    const start = performance.now();
    const serialized = loaded.engine.process(
      bytes,
      request.format,
      request.configuration,
      request.deadlineMs,
      128 * 1024 * 1024,
    );
    if (serialized.length > 16 * 1024 * 1024)
      throw new Error("Structured result exceeds the browser16 MiB per-file bound.");
    const resultBytes = new TextEncoder().encode(serialized).length;
    if (resultBytes > 16 * 1024 * 1024)
      throw new Error("Structured result exceeds the browser16 MiB per-file bound.");
    const envelope = JSON.parse(serialized);
    if (
      envelope.result &&
      new TextEncoder().encode(envelope.result.source).length > 4 * 1024 * 1024
    )
      throw new Error("Output exceeds the browser4 MiB limit.");
    self.postMessage({
      kind: "result",
      id: request.id,
      envelope,
      inputSha256,
      elapsedMillis: performance.now() - start,
      resultBytes,
      memory: loaded.memory(),
      validationMetrics: {
        frames: loaded.validationFrames,
        totalMillis: loaded.validationFrames.reduce((sum, frame) => sum + frame.elapsedMillis, 0),
      },
      assetId: loaded.manifest.asset_id,
    });
  } catch (error) {
    self.postMessage({
      kind: "error",
      id: request.id,
      message: error instanceof Error ? error.message : String(error),
    });
  } finally {
    if (request.kind === "process") processing = false;
  }
};
