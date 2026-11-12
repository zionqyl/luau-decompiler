import { createServer } from "node:http";
import { readFile, stat, mkdir, writeFile, readdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { resolve, extname, sep } from "node:path";
import { createHash } from "node:crypto";
import { installAudit, runUI } from "../web/tests/acceptance.mjs";
import { zipSync } from "../web/node_modules/fflate/esm/index.mjs";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
const root = resolve(new URL("..", import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const localPython = resolve(root, ".tools/python-3.12.10/python.exe");
const python =
  process.env.LUAU_BROWSER_PYTHON || (existsSync(localPython) ? localPython : "python3");
if (existsSync(resolve(root, ".tools/playwright")))
  process.env.PLAYWRIGHT_BROWSERS_PATH = resolve(root, ".tools/playwright");
const { chromium } = await import("../web/node_modules/playwright/index.mjs");
const proof = process.argv.includes("--proof");
const benchmark = process.argv.includes("--benchmark");
const coldOnly = process.argv.includes("--cold-only");
if (coldOnly && !benchmark) throw Error("--cold-only requires --benchmark");
const proofMode = proof || benchmark;
const packagingOnly = process.argv.includes("--packaging-only");
const publishedUrl = process.argv
  .find((value) => value.startsWith("--published-url="))
  ?.slice("--published-url=".length);
const deployedManifest = process.argv
  .find((value) => value.startsWith("--deployed-manifest="))
  ?.slice("--deployed-manifest=".length);
if (publishedUrl && (proofMode || packagingOnly || !deployedManifest))
  throw Error(
    "Published acceptance requires --deployed-manifest from the matching CI artifact and the ordinary UI profile.",
  );
if (
  publishedUrl &&
  (new URL(publishedUrl).protocol !== "https:" || !publishedUrl.endsWith("/luau-decompiler/"))
)
  throw Error(
    "Published acceptance requires an HTTPS repository-subpath URL ending /luau-decompiler/.",
  );
const assetRoot = process.argv
  .find((value) => value.startsWith("--asset-root="))
  ?.slice("--asset-root=".length);
const publicRoot = resolve(root, assetRoot ?? (proofMode ? "web/public" : "web/out"));
let manifest = JSON.parse(await readFile(resolve(publicRoot, "runtime/manifest.json"), "utf8"));
const digest = (value) => createHash("sha256").update(value).digest("hex");
const localManifestPath = resolve(root, "artifacts/browser-build/static-export-manifest.json");
const staticManifestPath = deployedManifest ? resolve(root, deployedManifest) : localManifestPath;
const staticManifestBytes = proofMode ? null : await readFile(staticManifestPath);
const staticManifest = proofMode ? null : JSON.parse(staticManifestBytes);
if (publishedUrl) {
  const expected = JSON.parse(await readFile(localManifestPath, "utf8"));
  if (
    staticManifest.engine_version !== expected.engine_version ||
    !staticManifest.portable_engine_text_sha256 ||
    staticManifest.portable_engine_text_sha256 !== expected.portable_engine_text_sha256
  )
    throw Error(
      "Deployed CI version/portable engine text identity differs from the validated local candidate.",
    );
}
const deploymentChecks = [];
if (publishedUrl) {
  if (
    staticManifest.assets.length > 1024 ||
    staticManifest.total_bytes > 128 * 1024 * 1024 ||
    staticManifest.processing_backend !== false ||
    staticManifest.base_path !== "/luau-decompiler/"
  )
    throw Error("Deployed static manifest exceeds its supported scope.");
  const deadline = Date.now() + 180000;
  let next = 0;
  let runtimeBytes;
  const assets = staticManifest.assets.filter(
    (row) =>
      row.path !== ".nojekyll" &&
      !row.path.startsWith("404") &&
      !row.path.startsWith("_not-found/"),
  );
  async function fetchAssets() {
    for (;;) {
      const index = next++;
      if (index >= assets.length) return;
      const row = assets[index];
      if (
        !row.path ||
        row.path
          .split("/")
          .some(
            (part) => !part || part === ".." || part === "." || /[\\:\u0000-\u001f]/u.test(part),
          ) ||
        !Number.isSafeInteger(row.bytes) ||
        row.bytes < 0 ||
        row.bytes > 32 * 1024 * 1024 ||
        !/^[a-f0-9]{64}$/.test(row.sha256)
      )
        throw Error("Unsafe deployed asset descriptor.");
      const remaining = deadline - Date.now();
      if (remaining <= 0) throw Error("Deployed asset verification exceeded180 seconds.");
      const location =
        row.path === "index.html"
          ? publishedUrl
          : publishedUrl + row.path.split("/").map(encodeURIComponent).join("/");
      const response = await fetch(location, {
        redirect: "error",
        signal: AbortSignal.timeout(Math.min(20000, remaining)),
      });
      if (!response.ok || !response.body)
        throw Error(`Published asset unavailable ${row.path}: HTTP ${response.status}`);
      const reader = response.body.getReader(),
        chunks = [];
      let size = 0;
      for (;;) {
        const value = await reader.read();
        if (value.done) break;
        size += value.value.length;
        if (size > row.bytes) {
          await reader.cancel();
          throw Error("Published asset exceeds its CI identity: " + row.path);
        }
        chunks.push(value.value);
      }
      const bytes = Buffer.concat(chunks, size);
      if (size !== row.bytes || digest(bytes) !== row.sha256)
        throw Error("Published asset differs from the deployed CI build: " + row.path);
      deploymentChecks.push({
        path: row.path,
        bytes: size,
        sha256: row.sha256,
        status: response.status,
      });
      if (row.path === "runtime/manifest.json") runtimeBytes = bytes;
    }
  }
  await Promise.all(Array.from({ length: 4 }, fetchAssets));
  if (!runtimeBytes) throw Error("Deployed CI closure lacks the runtime manifest.");
  manifest = JSON.parse(runtimeBytes.toString("utf8"));
  if (manifest.engine_version !== staticManifest.engine_version)
    throw Error("Published runtime differs from its CI export version.");
}
const testFiles = [
  "scripts/test-browser.mjs",
  ...(await readdir(resolve(root, "web/tests")))
    .filter((name) => /\.(mjs|ts|py)$/.test(name))
    .sort()
    .map((name) => "web/tests/" + name),
];
const testIdentity = [];
for (const path of testFiles)
  testIdentity.push({
    path,
    sha256: digest(await readFile(resolve(root, path))),
  });
async function verifySnapshot() {
  for (const row of testIdentity)
    if (digest(await readFile(resolve(root, row.path))) !== row.sha256)
      throw Error("Browser acceptance changed during validation: " + row.path);
  if (!staticManifest) return;
  if (publishedUrl) {
    if (digest(await readFile(staticManifestPath)) !== digest(staticManifestBytes))
      throw Error("Deployed CI manifest changed during acceptance");
    return;
  }
  for (const row of [
    ...staticManifest.engine_source_identity.files,
    ...staticManifest.browser_source_identity.files,
  ])
    if (digest(await readFile(resolve(root, row.path))) !== row.sha256)
      throw Error("Browser evidence source identity changed: " + row.path);
  for (const row of staticManifest.assets)
    if (digest(await readFile(resolve(publicRoot, row.path))) !== row.sha256)
      throw Error("Static export changed: " + row.path);
}
await verifySnapshot();
if (!proofMode && !publishedUrl)
  await promisify(execFile)(python, [resolve(root, "web/tests/build_stamps.py")], {
    cwd: root,
    timeout: 30000,
  });
const network = [];
const prefix = "/luau-decompiler/";
const proofHtml = `<!doctype html><meta charset="utf-8"><title>Local processing proof</title><p id="status">Loading</p><script type="module">
const manifest=await(await fetch("./runtime/manifest.json",{cache:"no-store"})).json();
const worker=new Worker(new URL("runtime/"+manifest.assets.worker.path,location.href),{type:"module"});
const waiters=new Map();let readyResolve,readyReject;window.ready=new Promise((resolve,reject)=>{readyResolve=resolve;readyReject=reject});
worker.onmessage=event=>{const value=event.data;if(value.kind==="ready"){window.identity=value;readyResolve(value)}else if(value.kind==="error"&&!value.id){readyReject(Error(value.message))}else if(value.id&&value.kind!=="progress"){const callback=waiters.get(value.id);if(callback){waiters.delete(value.id);callback(value)}}};
worker.onerror=event=>readyReject(Error(event.message));
worker.postMessage({kind:"init",manifestUrl:new URL("runtime/manifest.json",location.href).href,version:manifest.engine_version,assetId:manifest.asset_id});
window.processLocal=async(bytes,format,configuration)=>{await window.ready;const id=crypto.randomUUID();const result=new Promise(resolve=>waiters.set(id,resolve));const input=new Uint8Array(bytes);worker.postMessage({kind:"process",id,input:input.buffer,format,configuration:JSON.stringify(configuration),deadlineMs:30000},[input.buffer]);return result};
</script>`;
const server = createServer(async (request, response) => {
  try {
    network.push({
      method: request.method,
      url: request.url,
      content_length: request.headers["content-length"] ?? null,
    });
    if (request.method !== "GET" && request.method !== "HEAD") {
      response.writeHead(405).end();
      return;
    }
    const path = decodeURIComponent(new URL(request.url, "http://localhost").pathname);
    if (!path.startsWith(prefix)) {
      response.writeHead(404).end();
      return;
    }
    let relative = path.slice(prefix.length);
    if (proofMode && relative === "") {
      response.writeHead(200, { "Content-Type": "text/html; charset=utf-8" }).end(proofHtml);
      return;
    }
    if (!relative || relative.endsWith("/")) relative += "index.html";
    const target = resolve(publicRoot, relative);
    if (!target.startsWith(publicRoot + sep)) {
      response.writeHead(403).end();
      return;
    }
    const data = await readFile(target);
    const types = {
      ".html": "text/html",
      ".js": "text/javascript",
      ".mjs": "text/javascript",
      ".wasm": "application/wasm",
      ".json": "application/json",
      ".css": "text/css",
      ".woff2": "font/woff2",
    };
    response
      .writeHead(200, {
        "Content-Type": types[extname(target)] ?? "application/octet-stream",
        "Cache-Control": "no-store",
      })
      .end(data);
  } catch {
    response.writeHead(404).end();
  }
});
if (!publishedUrl) await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
const address = server.address();
const url = publishedUrl ?? `http://127.0.0.1:${address.port}${prefix}`;
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: { width: 1440, height: 900 },
  permissions: ["clipboard-read", "clipboard-write"],
});
const observedRequests = [];
context.on("request", (request) =>
  observedRequests.push({
    url: request.url(),
    method: request.method(),
    resource_type: request.resourceType(),
    post_bytes: request.postDataBuffer()?.length ?? 0,
  }),
);
function verifyNetwork() {
  for (const request of observedRequests)
    if (
      request.method !== "GET" ||
      request.post_bytes !== 0 ||
      (!request.url.startsWith(url) && !request.url.startsWith("blob:" + new URL(url).origin + "/"))
    )
      throw Error("Unexpected all-origin browser request: " + JSON.stringify(request));
}
const page = await context.newPage();
async function readyPage() {
  await page.waitForFunction(() => window.ready && typeof window.ready.then === "function");
  return await page.evaluate(() => window.ready);
}
const errors = [];
page.on("pageerror", (error) => errors.push(error.message));
const started = performance.now();
let report = {
  schema: 1,
  passed: false,
  mode: publishedUrl
    ? "published_ci_static_export"
    : benchmark
      ? "benchmark"
      : proof
        ? "proof"
        : "static_export",
  browser: browser.version(),
  node: process.version,
  test_identity: testIdentity,
  base_path: prefix,
  manifest_asset_id: manifest.asset_id,
  engine_version: manifest.engine_version,
  static_export_manifest_sha256: staticManifestBytes ? digest(staticManifestBytes) : null,
  engine_source_identity:
    staticManifest?.engine_source_identity.sha256 ?? manifest.source_identity?.sha256,
  browser_source_identity: staticManifest?.browser_source_identity.sha256,
  static_export_bytes: staticManifest?.total_bytes,
  portable_engine_text_sha256: staticManifest?.portable_engine_text_sha256,
  published_url: publishedUrl,
  deployment_asset_checks: publishedUrl ? deploymentChecks : undefined,
  deployment_scope: publishedUrl
    ? "Exact deployed CI export bytes verified against its authenticated artifact manifest; CI build bytes may differ from the local Windows export. Portable engine text identity and release version must agree."
    : undefined,
  retained_captured_packet_available: existsSync(
    process.env.LUAU_BROWSER_CAPTURE_BYTECODE ||
      resolve(
        root,
        "artifacts/rc3-mm2/snapshot/original-bytecode/51cc9d8c7b8c31460651d01272948ddba05221366bad0db92c3bf63d0137ac4b.bc",
      ),
  ),
  retained_captured_packet_scope:
    "Optional private fixture: a missing retained capture is not run and does not establish browser-native getter coverage; public known-source cases remain required.",
  measurement_scope:
    "Local readonly static server on a shared Windows host; timings are browser samples, not isolated internet-load or sustained benchmarks",
};
try {
  if (packagingOnly) {
    const originalBytes = await readFile(resolve(root, "artifacts/browser-tests/export.json"));
    const original = JSON.parse(originalBytes);
    const acceptedBytes = await readFile(
      resolve(root, "artifacts/browser-tests/runtime-gate-manifest.json"),
    );
    const accepted = JSON.parse(acceptedBytes);
    const refresh = JSON.parse(
      await readFile(resolve(root, "artifacts/browser-tests/notice-refresh.json"), "utf8"),
    );
    if (
      !original.passed ||
      digest(acceptedBytes) !== original.static_export_manifest_sha256 ||
      digest(originalBytes) !== refresh.original_acceptance_sha256 ||
      digest(staticManifestBytes) !== refresh.current_static_export_manifest_sha256
    )
      throw Error("The original runtime gate and notice refresh do not reconcile");
    for (const row of original.test_identity)
      if (
        !["scripts/test-browser.mjs", "web/tests/build_stamps.py"].includes(row.path) &&
        digest(await readFile(resolve(root, row.path))) !== row.sha256
      )
        throw Error("Runtime acceptance implementation changed: " + row.path);
    const allowed = new Set(refresh.changed_assets.map((row) => row.path));
    if (
      allowed.size !== 2 ||
      Array.from(allowed).some(
        (path) => !path.endsWith("/licenses.txt") && !path.endsWith("/licenses-manifest.json"),
      )
    )
      throw Error("Packaging reuse may change only notice assets");
    const currentAssets = new Map(staticManifest.assets.map((row) => [row.path, row]));
    for (const row of accepted.assets)
      if (
        !allowed.has(row.path) &&
        JSON.stringify(currentAssets.get(row.path)) !== JSON.stringify(row)
      )
        throw Error("Changed runtime asset prevents gate reuse: " + row.path);
    await page.goto(url);
    await page.getByRole("heading", { name: "Luau Decompiler", exact: true }).waitFor();
    await page.getByRole("link", { name: "Licenses and notices", exact: true }).waitFor();
    const notices = await page.evaluate(
      async ({ base, assetId }) => {
        const location = base + "runtime/" + assetId + "/";
        const metadata = await fetch(location + "licenses-manifest.json", {
            cache: "no-store",
          }),
          text = await fetch(location + "licenses.txt", { cache: "no-store" });
        if (!metadata.ok || !text.ok) throw Error("Required runtime notices are unavailable");
        return { metadata: await metadata.json(), text: await text.text() };
      },
      { base: prefix, assetId: manifest.asset_id },
    );
    const roles = notices.metadata.required_notices;
    if (!roles?.rust_standard_library || roles.emscripten?.length !== 6)
      throw Error("The shipped required runtime notice closure is incomplete");
    const noticeBytes = Buffer.from(notices.text);
    for (const row of [roles.rust_standard_library, ...roles.emscripten]) {
      const matching = notices.metadata.files.find((value) => value.label === row.label);
      if (!matching || matching.sha256 !== row.sha256 || matching.bytes !== row.bytes)
        throw Error("Required notice missing from the shipped closure: " + row.label);
      const heading = Buffer.from("\n" + row.label + "\n" + "=".repeat(60) + "\n");
      const offset = noticeBytes.indexOf(heading);
      if (
        offset < 0 ||
        digest(
          noticeBytes.subarray(
            offset + heading.length,
            offset + heading.length + row.rendered_bytes,
          ),
        ) !== row.rendered_sha256
      )
        throw Error("Required notice body is truncated or changed: " + row.label);
    }
    if (!notices.text.includes("Copyright notices for The Rust Standard Library"))
      throw Error("The active Rust standard-library notice is absent");
    report.mode = "notice_package_refresh";
    report.reused_runtime_cases = original.cases.length;
    report.original_acceptance_sha256 = digest(originalBytes);
    report.original_static_export_manifest_sha256 = digest(acceptedBytes);
    report.runtime_gate_reuse_scope =
      "Every nonnotice exported asset byte and original runUI case implementation are unchanged; driver changes concern notice checks and packaging; original report retained without retimestamping";
    report.test_source_deltas = original.test_identity
      .filter(
        (row) => testIdentity.find((current) => current.path === row.path)?.sha256 !== row.sha256,
      )
      .map((row) => ({
        path: row.path,
        previous_sha256: row.sha256,
        current_sha256: testIdentity.find((current) => current.path === row.path)?.sha256,
      }));
    report.required_notices = roles;
    report.cases = [
      {
        id: "notice_only_runtime_asset_identity",
        passed: true,
        unchanged_assets: accepted.assets.length - allowed.size,
      },
      {
        id: "actual_static_page_and_complete_required_notice_bodies",
        passed: true,
        notice_files: notices.metadata.files.length,
        required_runtime_notices: 7,
      },
    ];
    report.network = network;
    await verifySnapshot();
    report.passed = true;
  } else if (!proofMode) {
    await installAudit(context);
    report.cases = await runUI({ page, context, root, url, manifest, publicRoot });
    report.network = network;
    report.shared_array_buffer = await page.evaluate(() => typeof SharedArrayBuffer);
    report.cross_origin_isolated = await page.evaluate(() => crossOriginIsolated);
    if (
      network.some(
        (row) => row.method !== "GET" || !row.url.startsWith(prefix) || row.content_length !== null,
      )
    )
      throw Error("Unexpected processing transport");
    await verifySnapshot();
    report.passed = true;
  } else {
    await page.goto(url);
    await readyPage();
    report.initial_load_millis = performance.now() - started;
    report.identity = await page.evaluate(() => window.identity);
    const bytes = await readFile(resolve(root, "fixtures/runtime/verified.bc"));
    const options = {
      output_policy: "verified_typed",
      bytecode_encoding: "upstream",
      profile: "auto",
      typing: { mode: "annotated", verbosity: "extensive" },
      validation: {
        mode: "strict_required",
        max_workers: 1,
        max_cache_bytes: 0,
        project: { entry: "main" },
      },
    };
    report.configuration = options;
    const cases = [
      ["bytecode", Array.from(bytes), "luau_bytecode"],
      [
        "source",
        Array.from(new TextEncoder().encode("local answer:number=42\nreturn answer")),
        "luau_source",
      ],
      [
        "strict_negative",
        Array.from(new TextEncoder().encode("local answer:number='wrong'\nreturn answer")),
        "luau_source",
      ],
    ];
    report.cases = [];
    for (let repetition = 0; repetition < (coldOnly ? 0 : benchmark ? 8 : 1); repetition++)
      for (const [id, input, format] of cases) {
        const value = await page.evaluate(
          async ({ input, format, options }) => window.processLocal(input, format, options),
          { input, format, options },
        );
        if (value.kind !== "result" || !value.envelope.ok) throw Error(id + JSON.stringify(value));
        const result = value.envelope.result;
        const expected = id !== "strict_negative";
        if (result.validation.required_passed !== expected)
          throw Error(id + " quality " + JSON.stringify(result.validation));
        if (result.validation.strict_analysis !== (expected ? "passed" : "failed"))
          throw Error(id + " strict status");
        const header = `--!strict\n--[=[\n    Luau Decompiler ${manifest.engine_version}\n    Made by @zionqyl\n    https://github.com/zionqyl/luau-decompiler\n]=]\n`;
        if (!result.source.startsWith(header)) throw Error(id + " missing canonical header");
        report.cases.push({
          id,
          repetition,
          input_sha256: createHash("sha256").update(new Uint8Array(input)).digest("hex"),
          source_sha256: createHash("sha256").update(result.source).digest("hex"),
          complete: result.complete,
          required_passed: result.validation.required_passed,
          validation: result.validation,
          elapsed_millis: value.elapsedMillis,
          validation_metrics: value.validationMetrics,
          phase_timings: result.stats,
          memory: value.memory,
        });
      }
    if (coldOnly) {
      report.cold_trials = [];
      for (let repetition = 0; repetition < 5; repetition++) {
        const trialStart = repetition === 0 ? started : performance.now();
        if (repetition) {
          await page.reload();
          await readyPage();
        }
        const initializationMillis =
          repetition === 0 ? report.initial_load_millis : performance.now() - trialStart;
        const identity = await page.evaluate(() => window.identity);
        const value = await page.evaluate(
          async ({ input, options }) => window.processLocal(input, "luau_bytecode", options),
          { input: Array.from(bytes), options },
        );
        const result = value.envelope?.result;
        if (
          value.kind !== "result" ||
          !value.envelope?.ok ||
          !result?.validation.required_passed ||
          result.validation.strict_analysis !== "passed"
        )
          throw Error("Cold verified-bytecode trial failed: " + JSON.stringify(value));
        report.cold_trials.push({
          repetition,
          initialization_millis: initializationMillis,
          identity,
          first_verified_millis: value.elapsedMillis,
          end_to_end_millis: performance.now() - trialStart,
          input_sha256: digest(bytes),
          source_sha256: digest(Buffer.from(result.source)),
          phase_timings: result.stats,
          validation_metrics: value.validationMetrics,
          memory: value.memory,
        });
      }
      report.cold_scope =
        "Five fresh page-owned workers in one browser process, including asset fetch and definition preparation; later trials can reuse browser code caches. Not cold internet access or five fresh operating-system processes.";
    }
    if (errors.length) throw Error(JSON.stringify(errors));
    if (
      network.some(
        (row) => row.method !== "GET" || !row.url.startsWith(prefix) || row.content_length !== null,
      )
    )
      throw Error("Unexpected processing transport");
    report.network = network;
    report.shared_array_buffer = await page.evaluate(() => typeof SharedArrayBuffer);
    report.cross_origin_isolated = await page.evaluate(() => crossOriginIsolated);
    report.passed = true;
  }
  verifyNetwork();
  report.observed_all_origin_requests = observedRequests;
} catch (error) {
  report.error = String(error);
  if (error.browserCases) report.cases = error.browserCases;
  throw error;
} finally {
  report.finished_elapsed_millis = performance.now() - started;
  if (!proofMode)
    report.case_counts = {
      required_passed:
        report.cases?.filter((row) => row.required !== false && row.passed === true).length ?? 0,
      optional_passed:
        report.cases?.filter((row) => row.required === false && row.passed === true).length ?? 0,
      optional_private_capture_not_run: report.cases?.some(
        (row) => row.id === "captured_signed_container_default_drop_retains_unverified_source",
      )
        ? 0
        : 1,
    };
  await mkdir(resolve(root, "artifacts/browser-tests"), { recursive: true });
  await writeFile(
    resolve(
      root,
      `artifacts/browser-tests/${publishedUrl ? "published" : benchmark ? "benchmark-" + (coldOnly ? "cold-" : "") + manifest.engine_version : proof ? "proof" : packagingOnly ? "packaging-refresh" : "export"}.json`,
    ),
    JSON.stringify(report, null, 2),
  );
  await browser.close();
  if (server.listening) await new Promise((resolve) => server.close(resolve));
}
console.log(
  JSON.stringify(
    {
      passed: report.passed,
      browser: report.browser,
      mode: report.mode,
      initial_load_millis: report.initial_load_millis,
      cases: report.cases?.map((row) => ({
        id: row.id,
        required_passed: row.required_passed,
        elapsed_millis: row.elapsed_millis,
        memory: row.memory,
      })),
      requests: network.length,
      shared_array_buffer: report.shared_array_buffer,
    },
    null,
    2,
  ),
);
if (!proofMode && report.passed && !publishedUrl) {
  const entries = Object.create(null);
  for (const row of staticManifest.assets)
    entries[row.path] = [
      new Uint8Array(await readFile(resolve(publicRoot, row.path))),
      { mtime: new Date(1980, 0, 1) },
    ];
  const bytes = zipSync(entries, { level: 6 });
  const directory = resolve(root, "dist");
  await mkdir(directory, { recursive: true });
  const name = `luau-decompiler-${manifest.engine_version}-pages.zip`;
  await writeFile(resolve(directory, name), bytes);
  await writeFile(resolve(directory, name + ".sha256"), digest(bytes) + "  " + name + "\n");
  await promisify(execFile)(
    python,
    [resolve(root, "scripts/build-browser.py"), "--verify-package", resolve(directory, name)],
    { cwd: root, timeout: 30000 },
  );
  const evidencePaths = [
    "artifacts/browser-tests/export.json",
    "artifacts/browser-tests/package.json",
    "artifacts/browser-build/static-export-manifest.json",
    "artifacts/browser-build/engine-manifest.json",
    "artifacts/browser-build/analyzer-manifest.json",
    "artifacts/browser-build/stamp-checks.json",
    "artifacts/browser-tests/benchmark-0.4.0-rc.3.json",
    "artifacts/browser-tests/benchmark-cold-0.4.0-rc.3.json",
    `artifacts/browser-tests/benchmark-${manifest.engine_version}.json`,
    `artifacts/browser-tests/benchmark-cold-${manifest.engine_version}.json`,
    "docs/results/browser-performance-rc4.json",
    "artifacts/rc4-browser-baseline/package-identity.json",
    "artifacts/rc4-browser-baseline/measurement-driver.mjs",
    "artifacts/rc4-browser-baseline/rc4-proof-schema-failure.json",
    "artifacts/rc4-browser-baseline/rc4-ui-clear-harness-failure.json",
    "artifacts/rc4-browser-baseline/rc4-ui-width-locator-failure.json",
    "artifacts/browser-tests/ui/workspace.png",
    "artifacts/browser-tests/ui/mobile-viewport.png",
    ...(packagingOnly
      ? [
          "artifacts/browser-tests/runtime-gate-manifest.json",
          "artifacts/browser-tests/notice-refresh.json",
          "artifacts/browser-tests/packaging-refresh.json",
        ]
      : []),
  ].filter((path) => existsSync(resolve(root, path)));
  const evidenceEntries = Object.create(null);
  const evidenceFiles = [];
  for (const path of evidencePaths) {
    const contents = new Uint8Array(await readFile(resolve(root, path)));
    evidenceEntries[path] = [contents, { mtime: new Date(1980, 0, 1) }];
    evidenceFiles.push({
      path,
      bytes: contents.length,
      sha256: digest(contents),
    });
  }
  const evidenceBytes = zipSync(evidenceEntries, { level: 6 }),
    evidenceName = `luau-decompiler-${manifest.engine_version}-browser-evidence.zip`;
  await writeFile(resolve(directory, evidenceName), evidenceBytes);
  await writeFile(
    resolve(directory, evidenceName + ".sha256"),
    digest(evidenceBytes) + "  " + evidenceName + "\n",
  );
  await writeFile(
    resolve(directory, `luau-decompiler-${manifest.engine_version}-browser-release.json`),
    JSON.stringify(
      {
        schema: 1,
        engine_version: manifest.engine_version,
        asset_id: manifest.asset_id,
        package: { name, bytes: bytes.length, sha256: digest(bytes) },
        evidence: {
          name: evidenceName,
          bytes: evidenceBytes.length,
          sha256: digest(evidenceBytes),
          files: evidenceFiles,
        },
        static_export_manifest_sha256: digest(staticManifestBytes),
        acceptance_report_sha256: digest(
          await readFile(resolve(root, "artifacts/browser-tests/export.json")),
        ),
        runtime_acceptance: packagingOnly
          ? {
              reused: true,
              scope: report.runtime_gate_reuse_scope,
              cases: report.reused_runtime_cases,
              original_static_export_manifest_sha256: report.original_static_export_manifest_sha256,
              packaging_refresh_report_sha256: digest(
                await readFile(resolve(root, "artifacts/browser-tests/packaging-refresh.json")),
              ),
            }
          : { reused: false, cases: report.cases.length },
        engine_source_identity: staticManifest.engine_source_identity,
        portable_engine_text_sha256: staticManifest.portable_engine_text_sha256,
        browser_source_identity: staticManifest.browser_source_identity,
        engine_assets: manifest.assets,
        publication: "not_performed_by_local_acceptance",
        tested_browser: report.browser,
      },
      null,
      2,
    ) + "\n",
  );
  console.log(
    JSON.stringify({
      static_archive: name,
      bytes: bytes.length,
      sha256: digest(bytes),
    }),
  );
}
