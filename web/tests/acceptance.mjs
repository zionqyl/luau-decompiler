import assert from "node:assert/strict";
import { readFile, writeFile, mkdir, copyFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { unzipSync, zipSync, strToU8 } from "fflate";
import { configuration, contractMaps, initialOptions } from "../lib/domain.ts";
const execute = promisify(execFile);
const hash = (value) => createHash("sha256").update(value).digest("hex");
export async function installAudit(context) {
  await context.addInitScript(() => {
    window.__localAudit = {
      created: 0,
      terminated: 0,
      messages: [],
      clipboard: [],
      lifecycle: [],
      archiveCreates: 0,
    };
    const Original = window.Worker;
    window.Worker = class extends Original {
      constructor(url, options) {
        super(url, options);
        window.__localAudit.created++;
        if (options?.name === "Luau archive utility") window.__localAudit.archiveCreates++;
        const created = performance.now();
        this.addEventListener("message", (event) => {
          if (event.data.kind === "ready")
            window.__localAudit.lifecycle.push({
              kind: "ready",
              elapsed_millis: performance.now() - created,
              memory: event.data.memory,
              initialization: event.data.initialization,
            });
        });
      }
      postMessage(message, transfer) {
        window.__localAudit.messages.push({ kind: message.kind, id: message.id });
        if (message.kind === "process" && window.__retentionProbe) {
          const probe = window.__retentionProbe;
          queueMicrotask(async () => {
            const hash = await crypto.subtle.digest("SHA-256", message.input);
            const input_sha256 = Array.from(new Uint8Array(hash), (byte) =>
              byte.toString(16).padStart(2, "0"),
            ).join("");
            const source =
              probe.template.source +
              " ".repeat(
                Math.max(
                  0,
                  probe.sourceBytes - new TextEncoder().encode(probe.template.source).length,
                ),
              );
            const result = {
              ...probe.template,
              input_sha256,
              source,
              baseline_source: null,
              validation: {
                ...probe.template.validation,
                output_policy: "faithful",
                required_passed: false,
                syntax: "not_run",
                compilation: "not_run",
                strict_analysis: "not_run",
                meaningful_typing: {
                  passed: false,
                  binding_coverage_percent: 0,
                  runtime_annotations: 0,
                  failures: ["Mocked retention boundary; no reconstruction or validation claim"],
                },
              },
            };
            this.dispatchEvent(
              new MessageEvent("message", {
                data: {
                  kind: "result",
                  id: message.id,
                  envelope: { ok: true, result },
                  resultBytes: probe.resultBytes,
                  elapsedMillis: 0,
                },
              }),
            );
          });
          return;
        }
        return super.postMessage(message, transfer ?? []);
      }
      terminate() {
        window.__localAudit.terminated++;
        return super.terminate();
      }
    };
    const write = navigator.clipboard.writeText.bind(navigator.clipboard);
    navigator.clipboard.writeText = async (value) => {
      window.__localAudit.clipboard.push(value);
      return write(value);
    };
  });
}
export async function runUI({
  page,
  context,
  root,
  url,
  manifest,
  publicRoot = resolve(root, "web/out"),
}) {
  const rows = [];
  try {
    const work = resolve(root, "artifacts/browser-tests/ui");
    await mkdir(work, { recursive: true });
    async function done() {
      await page.waitForFunction(
        () => !document.querySelector('[data-testid="run"]').disabled,
        {},
        { timeout: 120000 },
      );
    }
    async function importFiles(values) {
      await page.getByTestId("file-input").setInputFiles(
        values.map(([name, buffer]) => ({
          name,
          mimeType: "application/octet-stream",
          buffer: Buffer.from(buffer),
        })),
      );
      await page.waitForFunction(() => !document.querySelector('[data-testid="run"]').disabled);
    }
    async function run() {
      await page.getByTestId("run").click();
      await done();
    }
    async function select(name) {
      await page.getByTitle(name, { exact: true }).click();
    }
    async function source() {
      await page.getByRole("tab", { name: "Output", exact: true }).click();
      return await page.getByTestId("source-view").textContent();
    }
    async function report() {
      await page.getByRole("tab", { name: "Report", exact: true }).click();
      const text = await page.getByTestId("source-view").textContent();
      await page.getByRole("tab", { name: "Output", exact: true }).click();
      return JSON.parse(text);
    }
    async function clear() {
      if (await page.locator(".file-row").count())
        await page.getByRole("button", { name: "Clear", exact: true }).click();
      await page.waitForFunction(() => document.querySelectorAll(".file-row").length === 0);
    }
    async function download(button, name) {
      const pending = page.waitForEvent("download");
      await page.getByRole("button", { name: button, exact: true }).click();
      const item = await pending;
      const path = resolve(work, name);
      await item.saveAs(path);
      return await readFile(path);
    }
    const initialPage = performance.now();
    await page.goto(url);
    await page.getByRole("heading", { name: "Luau Decompiler", exact: true }).waitFor();
    await page.evaluate(() => document.fonts.ready);
    assert.match(
      await page.locator("body").evaluate((element) => getComputedStyle(element).fontFamily),
      /Geist/,
    );
    rows.push({
      id: "static_subpath_and_local_geist_fonts",
      passed: true,
      initial_page_millis: performance.now() - initialPage,
    });
    const showcaseIndex = JSON.parse(
      await readFile(resolve(publicRoot, "examples/mm2-showcase.json"), "utf8"),
    );
    const requiredCorpus = JSON.parse(
      await readFile(resolve(root, "examples/Murder Mystery 2/manifest.json"), "utf8"),
    );
    assert.equal(showcaseIndex.status, "available");
    assert.equal(showcaseIndex.entries.length, requiredCorpus.current_generation_outputs);
    assert.equal(
      showcaseIndex.entries.length + showcaseIndex.historical_entries_not_packaged.length,
      requiredCorpus.published_outputs,
    );
    assert.ok(showcaseIndex.entries.length > 0);
    await page.getByText("Owner-authorized MM2 examples", { exact: true }).click();
    if (showcaseIndex.entries.length) {
      const entry =
        showcaseIndex.entries.find((value) => value.bytes <= 128 * 1024) ??
        showcaseIndex.entries[0];
      await page.getByLabel("MM2 example").selectOption(entry.path);
      await page.getByTestId("showcase-source").waitFor();
      const expected = await readFile(resolve(publicRoot, entry.path));
      assert.equal(
        await page.getByTestId("showcase-source").textContent(),
        expected.toString("utf8"),
      );
      assert.deepEqual(await download("Download example", "showcase.luau"), expected);
      assert.equal(await page.locator(".badge.verified").count(), 0);
      rows.push({
        id: "authorized_mm2_showcase_on_demand_exact_finalized_export",
        passed: true,
        eligible_outputs: showcaseIndex.entries.length,
        path: entry.path,
        source_sha256: hash(expected),
        scope: "Recorded corpus quality is distinct from a new processing/verification request",
      });
    } else
      rows.push({
        id: "authorized_mm2_showcase_on_demand_exact_finalized_export",
        passed: true,
        eligible_outputs: 0,
        status: showcaseIndex.status,
        scope: "No fabricated source or verification badge is displayed",
      });
    await page.getByText("Owner-authorized MM2 examples", { exact: true }).click();
    const fixture = await readFile(resolve(root, "fixtures/runtime/verified.bc"));
    const positive = "local answer:number=42\nreturn answer\n";
    const negative = "local answer:number='wrong'\nreturn answer\n";
    const crlf = "local text:string=[=[a\r\nb]=]\r\nreturn text\r\n";
    const dropStart = performance.now();
    await page.evaluate((bytes) => {
      const transfer = new DataTransfer();
      transfer.items.add(
        new File([new Uint8Array(bytes)], "bytecode.bc", { type: "application/octet-stream" }),
      );
      document
        .querySelector(".import-area")
        .dispatchEvent(
          new DragEvent("drop", { dataTransfer: transfer, bubbles: true, cancelable: true }),
        );
    }, Array.from(fixture));
    await page.locator(".file-state.complete").waitFor({ timeout: 30000 });
    await done();
    const firstDropMillis = performance.now() - dropStart;
    assert.equal((await report()).result.validation.required_passed, true);
    const automaticCount = await page.evaluate(
      () => window.__localAudit.messages.filter((message) => message.kind === "process").length,
    );
    await run();
    assert.equal(
      await page.evaluate(
        () => window.__localAudit.messages.filter((message) => message.kind === "process").length,
      ),
      automaticCount,
    );
    rows.push({
      id: "drag_drop_supported_file",
      passed: true,
      format: "real Luau bytecode",
      automatic_processing: true,
      unchanged_reschedule: false,
      first_drop_end_to_end_millis: firstDropMillis,
      scope:
        "Initial file read, cold worker and definitions, reconstruction, real strict validation and UI result; page/fonts were already loaded",
    });
    await importFiles([
      ["positive.luau", positive],
      ["negative.luau", negative],
      ["crlf.luau", crlf],
    ]);
    await run();
    const outputs = {};
    const results = {};
    for (const name of ["bytecode.bc", "positive.luau", "negative.luau", "crlf.luau"]) {
      await select(name);
      outputs[name] = await source();
      results[name] = await report();
      assert.equal(results[name].result.complete, true);
      assert.equal(results[name].result.validation.required_passed, name !== "negative.luau");
      assert.equal(await page.locator(".badge.verified").count(), name === "negative.luau" ? 0 : 1);
      assert.ok(
        outputs[name].startsWith(
          `--!strict\n--[=[\n    Luau Decompiler ${manifest.engine_version}\n`,
        ),
      );
    }
    rows.push({
      id: "bytecode_source_real_strict_negative_and_completed_result_preservation",
      passed: true,
      cases: Object.entries(results).map(([id, value]) => ({
        id,
        required_passed: value.result.validation.required_passed,
        syntax: value.result.validation.syntax,
        compilation: value.result.validation.compilation,
        strict: value.result.validation.strict_analysis,
        elapsed_millis: value.elapsedMillis,
        memory: value.memory,
        input_sha256: value.result.input_sha256,
        source_sha256: hash(outputs[id]),
      })),
    });
    rows.push({
      id: "worker_initialization_measurement",
      passed: true,
      instances: await page.evaluate(() => window.__localAudit.lifecycle),
      scope:
        "Initial static-asset loading plus Rust/C++ WASM initialization on a local readonly server; not internet cold-load latency",
    });
    assert.ok(
      results["positive.luau"].validationMetrics.frames.every((frame) => frame.contextReused),
    );
    rows.push({
      id: "prepared_context_warm_definition_reuse",
      passed: true,
      frames: results["positive.luau"].validationMetrics.frames,
    });
    await select("crlf.luau");
    assert.ok((await source()).includes("a\r\nb"));
    await page.getByRole("button", { name: "Copy", exact: true }).click();
    const copied = await page.evaluate(() => window.__localAudit.clipboard.at(-1));
    assert.equal(copied, outputs["crlf.luau"]);
    const clipboardRead = await page.evaluate(() => navigator.clipboard.readText());
    const downloaded = await download("Download file", "crlf.luau");
    assert.deepEqual(downloaded, Buffer.from(outputs["crlf.luau"]));
    const zip = await download("Download ZIP", "results.zip");
    const zipped = unzipSync(zip);
    assert.deepEqual(zipped["crlf.luau"], new Uint8Array(downloaded));
    assert.deepEqual(
      zipped["positive.luau"],
      new Uint8Array(Buffer.from(outputs["positive.luau"])),
    );
    rows.push({
      id: "preview_clipboard_call_and_individual_zip_exports_identical_final_source",
      passed: true,
      crlf_inside_literal_retained: true,
      clipboard_api_argument_exact: true,
      clipboard_platform_readback_exact: clipboardRead === copied,
      individual_sha256: hash(downloaded),
      zip_sha256: hash(zip),
    });
    const utilityBefore = await page.evaluate(() => window.__localAudit.archiveCreates);
    const concurrentDownload = page.waitForEvent("download");
    await page.getByRole("button", { name: "Download ZIP", exact: true }).evaluate((button) => {
      button.click();
      button.click();
    });
    await page.locator(".notice.error").waitFor();
    assert.match(
      await page.locator(".notice.error").textContent(),
      /archive operation is already active/,
    );
    await concurrentDownload;
    assert.equal(await page.evaluate(() => window.__localAudit.archiveCreates), utilityBefore + 1);
    await page.getByRole("button", { name: "Dismiss error" }).click();
    await download("Download ZIP", "after-overlap.zip");
    rows.push({
      id: "archive_worker_admission_and_recovery",
      passed: true,
      simultaneous_utility_workers: 1,
    });
    const before = await page.evaluate(
      () => window.__localAudit.messages.filter((message) => message.kind === "process").length,
    );
    await page.getByRole("button", { name: "Toggle color theme" }).click();
    await page.getByRole("separator", { name: "Resize file tree" }).focus();
    await page.keyboard.press("ArrowRight");
    await page.waitForTimeout(100);
    assert.equal(
      await page.evaluate(
        () => window.__localAudit.messages.filter((message) => message.kind === "process").length,
      ),
      before,
    );
    rows.push({ id: "theme_and_keyboard_panel_resize_do_not_process", passed: true });
    await clear();
    await page.getByLabel("Resolve supplied source modules locally").uncheck();
    const retention = [];
    try {
      for (const [kind, count, sourceBytes, resultBytes, pattern] of [
        ["source", 5, 4 * 1024 * 1024, 6 * 1024 * 1024, /Workspace source/],
        ["structured", 3, 1024, 12 * 1024 * 1024, /structured-result/],
      ]) {
        await clear();
        await importFiles(
          Array.from({ length: count }, (_, index) => [`budget${index}.luau`, positive]),
        );
        await page
          .getByRole("checkbox", { name: `Process budget${count - 1}.luau`, exact: true })
          .uncheck();
        await page.evaluate(
          (probe) => {
            window.__retentionProbe = probe;
          },
          { template: results["positive.luau"].result, sourceBytes, resultBytes },
        );
        await run();
        assert.equal(await page.locator(".file-state.quality_failed").count(), count - 1);
        for (let index = 0; index < count - 1; index++)
          await page
            .getByRole("checkbox", { name: `Process budget${index}.luau`, exact: true })
            .uncheck();
        await page
          .getByRole("checkbox", { name: `Process budget${count - 1}.luau`, exact: true })
          .check();
        await run();
        await select(`budget${count - 1}.luau`);
        const rejected = await report();
        assert.equal(rejected.status, "failed");
        assert.match(rejected.error, pattern);
        assert.equal(await page.locator(".file-state.quality_failed").count(), count - 1);
        assert.equal(await page.locator(".badge.verified").count(), 0);
        retention.push({
          id: kind,
          first_selection_retained: count - 1,
          second_selection_rejected: true,
          source_bytes_per_result: sourceBytes,
          structured_bytes_per_result: resultBytes,
        });
      }
    } finally {
      await page.evaluate(() => delete window.__retentionProbe);
    }
    await clear();
    await page.getByLabel("Resolve supplied source modules locally").check();
    rows.push({
      id: "workspace_retention_across_separate_selections",
      passed: true,
      scope:
        "Mocked unverified worker envelopes exercise actual application admission; this is not reconstruction, strict or behavioral evidence",
      cases: retention,
    });
    await clear();
    await importFiles([
      ["unsupported.bin", Uint8Array.from([27, 76, 117, 97, 84, 0])],
      ["keep.luau", positive],
    ]);
    await run();
    await select("unsupported.bin");
    const rejected = await report();
    assert.equal(rejected.status, "failed");
    assert.ok(!rejected.result);
    await select("keep.luau");
    assert.equal((await report()).result.validation.required_passed, true);
    rows.push({
      id: "accurate_unsupported_bytecode_and_independent_file_success",
      passed: true,
      error: rejected.error,
    });
    await clear();
    const controlledSigned = Buffer.from(
      "0e0300000112010000000000018200010000000000000000001132537405060708090a0b0c0d0e0f10612a440023f63975",
      "hex",
    );
    await importFiles([["controlled-signed-v14.bc", controlledSigned]]);
    await run();
    const signedResult = await report();
    assert.equal(signedResult.result.complete, true);
    assert.equal(signedResult.result.representation.profile, "roblox_signed_74171870");
    assert.equal(signedResult.result.representation.trailer.length, 24);
    assert.equal(signedResult.result.stats.instructions, 1);
    assert.ok(signedResult.result.representation.authenticity.startsWith("not_verified"));
    assert.equal(signedResult.result.validation.compilation, "passed");
    assert.equal(signedResult.result.validation.strict_analysis, "passed");
    assert.equal(signedResult.result.validation.meaningful_typing.passed, false);
    assert.equal(signedResult.result.validation.required_passed, false);
    assert.equal(await page.locator(".badge.verified").count(), 0);
    rows.push({
      id: "controlled_signed_container_auto_and_meaningful_gate",
      required: true,
      passed: true,
      input_sha256: hash(controlledSigned),
      source_sha256: hash(signedResult.result.source),
      scope:
        "Literal controlled RETURN container from existing Rust profile fixture generator; synthetic signature layout, not an authenticated/native getter packet; strict pass alone cannot qualify without useful typing",
      instructions: 1,
      strict: "passed",
      meaningful: false,
      verified: false,
    });
    const capturedHash = "51cc9d8c7b8c31460651d01272948ddba05221366bad0db92c3bf63d0137ac4b";
    const capturedPath =
      process.env.LUAU_BROWSER_CAPTURE_BYTECODE ||
      resolve(root, "artifacts/rc3-mm2/snapshot/original-bytecode", capturedHash + ".bc");
    if (existsSync(capturedPath)) {
      const packet = await readFile(capturedPath);
      assert.equal(hash(packet), capturedHash);
      const expectedPath = resolve(work, "captured-native.current.luau");
      const capturedConfig = resolve(work, "captured-native.current.config.json");
      const capturedQualityPath = resolve(work, "captured-native.current.json");
      await writeFile(
        capturedConfig,
        JSON.stringify(configuration(initialOptions, "captured-native.bc", {}, contractMaps("{}"))),
      );
      const currentNative =
        process.env.LUAU_BROWSER_NATIVE_CLI ||
        resolve(
          root,
          "target/release/luau-decompile" + (process.platform === "win32" ? ".exe" : ""),
        );
      await assert.rejects(
        execute(
          currentNative,
          [
            "decompile",
            capturedPath,
            "--config",
            capturedConfig,
            "-o",
            expectedPath,
            "--quality-report",
            capturedQualityPath,
            "--force",
          ],
          { cwd: root, timeout: 45000 },
        ),
        (error) => error.code === 1,
      );
      const capturedQuality = JSON.parse(await readFile(capturedQualityPath, "utf8"));
      assert.equal(capturedQuality.complete, true);
      assert.equal(capturedQuality.validation.strict_analysis, "failed");
      assert.equal(capturedQuality.validation.required_passed, false);
      const expected = await readFile(expectedPath, "utf8");
      await clear();
      await page.evaluate((bytes) => {
        const transfer = new DataTransfer();
        transfer.items.add(
          new File([new Uint8Array(bytes)], "captured-native.bc", {
            type: "application/octet-stream",
          }),
        );
        document
          .querySelector(".import-area")
          .dispatchEvent(
            new DragEvent("drop", { dataTransfer: transfer, bubbles: true, cancelable: true }),
          );
      }, Array.from(packet));
      await page.locator(".file-state.quality_failed").waitFor({ timeout: 30000 });
      await done();
      const observed = await report();
      assert.equal(observed.result.complete, true);
      assert.equal(observed.result.input_sha256, capturedHash);
      assert.equal(observed.result.representation.profile, "roblox_signed_74171870");
      assert.equal(observed.result.representation.trailer.length, 24);
      assert.equal(observed.result.validation.compilation, "passed");
      assert.equal(observed.result.validation.strict_analysis, "failed");
      assert.equal(observed.result.validation.required_passed, false);
      assert.equal(await source(), expected);
      assert.equal(await page.locator(".badge.verified").count(), 0);
      rows.push({
        id: "captured_signed_container_default_drop_retains_unverified_source",
        required: false,
        passed: true,
        input_sha256: capturedHash,
        source_sha256: hash(expected),
        native_cli_sha256: hash(await readFile(currentNative)),
        native_configuration_sha256: hash(await readFile(capturedConfig)),
        representation: observed.result.representation.profile,
        compilation: "passed",
        strict: "failed",
        verified: false,
        scope:
          "Optional private fixture, not required for CI: one retained script-getter packet from the MM2 client session; browser and current native use the same verified-typed settings and retain identical unverified source. This does not establish ownership or behavior; captured code is never executed.",
      });
    }
    await clear();
    await importFiles([["existing.luau", positive]]);
    await page.evaluate((source) => {
      const input = document.querySelector('[data-testid="file-input"]');
      const first = new File([source], "first.luau", { type: "text/plain" });
      Object.defineProperty(first, "arrayBuffer", {
        value: () =>
          new Promise((resolve) => {
            window.__releaseInputRead = () => resolve(new TextEncoder().encode(source).buffer);
          }),
      });
      for (const file of [
        first,
        new File([source], "rejected-overlap.luau", { type: "text/plain" }),
      ]) {
        const transfer = new DataTransfer();
        transfer.items.add(file);
        input.files = transfer.files;
        input.dispatchEvent(new Event("change", { bubbles: true }));
      }
    }, positive);
    await page.waitForFunction(() => typeof window.__releaseInputRead === "function");
    await page.locator(".notice.error").waitFor();
    assert.match(
      await page.locator(".notice.error").textContent(),
      /input import is already active/,
    );
    assert.equal(await page.getByTestId("run").isDisabled(), true);
    assert.equal(await page.getByRole("button", { name: "Clear", exact: true }).isDisabled(), true);
    await page.evaluate(() => window.__releaseInputRead());
    await page.waitForFunction(
      () =>
        document.querySelectorAll(".file-row").length === 2 &&
        !document.querySelector('[data-testid="run"]').disabled,
    );
    await page.getByTitle("existing.luau", { exact: true }).waitFor();
    await page.getByTitle("first.luau", { exact: true }).waitFor();
    assert.equal(await page.getByTitle("rejected-overlap.luau", { exact: true }).count(), 0);
    await page.getByRole("checkbox", { name: "Process existing.luau", exact: true }).uncheck();
    await importFiles([["after.luau", positive]]);
    assert.equal(await page.locator(".file-row").count(), 3);
    assert.equal(
      await page.getByRole("checkbox", { name: "Process existing.luau", exact: true }).isChecked(),
      false,
    );
    assert.equal(
      await page.getByRole("checkbox", { name: "Process after.luau", exact: true }).isChecked(),
      true,
    );
    rows.push({
      id: "serialized_input_admission_preserves_existing_and_new_files",
      passed: true,
      simultaneous_imports: 1,
      retained_files: 3,
      rejected_overlap_visible: true,
    });
    await clear();
    const moduleMain = 'local value:number=require("./module")\nreturn value';
    await importFiles([
      ["main.luau", moduleMain],
      ["module.luau", "local answer:number=42 return answer"],
    ]);
    await run();
    await select("main.luau");
    assert.equal((await report()).result.validation.required_passed, true);
    rows.push({ id: "in_memory_module_resolution_without_execution", passed: true });
    await clear();
    await importFiles([["contract.luau", "local value:number=externalNumber return value"]]);
    await page.getByText("Explicit contracts and overrides", { exact: true }).click();
    const alternating = [];
    for (const [name, contracts, expected] of [
      ["number", { globals: { externalNumber: "number" } }, true],
      ["changed_string", { globals: { externalNumber: "string" } }, false],
      ["removed", {}, false],
      ["number_again", { globals: { externalNumber: "number" } }, true],
    ]) {
      await page.getByLabel("Explicit contracts JSON").fill(JSON.stringify(contracts));
      await run();
      const observed = await report();
      assert.equal(observed.result.validation.required_passed, expected);
      assert.equal(observed.result.validation.strict_analysis, expected ? "passed" : "failed");
      assert.equal(observed.validationMetrics.frames[0].contextReused, false);
      alternating.push({
        id: name,
        required_passed: expected,
        frames: observed.validationMetrics.frames,
      });
    }
    await page.getByLabel("Explicit contracts JSON").fill("{}");
    rows.push({
      id: "prepared_analyzer_context_isolated_across_contract_changes",
      passed: true,
      cases: alternating,
    });
    await clear();
    await page.getByRole("button", { name: "Roblox typed demo", exact: true }).click();
    await page.getByTitle("Known source/player_snapshot.luau", { exact: true }).waitFor();
    await run();
    const snapshot = await report();
    assert.equal(snapshot.result.validation.required_passed, true);
    assert.equal(snapshot.result.validation.strict_analysis, "passed");
    assert.match(await source(), /player: Player/);
    assert.match(await source(), /export type PlayerSnapshot/);
    rows.push({
      id: "owned_roblox_example_on_demand_with_real_definitions",
      passed: true,
      source_sha256: hash(await source()),
      external_assumptions: snapshot.result.validation.external_assumptions,
    });
    await clear();
    await importFiles([["renamed.luau", "local snake_value:number=42 return snake_value"]]);
    await page.getByLabel("Preserve source names; use debug hints").uncheck();
    await page.getByLabel("Naming style").selectOption("camelCase");
    await run();
    await select("renamed.luau");
    assert.match(await source(), /snakeValue/);
    assert.equal((await report()).result.validation.required_passed, true);
    rows.push({ id: "real_engine_naming_options", passed: true });
    const requestsBefore = await page.evaluate(
      () => window.__localAudit.messages.filter((message) => message.kind === "process").length,
    );
    await run();
    assert.equal(
      await page.evaluate(
        () => window.__localAudit.messages.filter((message) => message.kind === "process").length,
      ),
      requestsBefore,
    );
    rows.push({ id: "unchanged_results_not_rescheduled", passed: true });
    await clear();
    const expensive = "local total:number=0\n" + "total=total+1\n".repeat(6000) + "return total\n";
    await importFiles([["expensive.luau", expensive]]);
    await page.getByTestId("run").click();
    await page.locator(".file-state.processing").waitFor();
    const responsive = performance.now();
    await page.getByRole("button", { name: "Toggle color theme" }).click();
    await page.getByRole("separator", { name: "Resize file tree" }).focus();
    await page.keyboard.press("ArrowLeft");
    const responseMillis = performance.now() - responsive;
    await done();
    assert.ok(responseMillis < 600);
    await select("expensive.luau");
    assert.equal((await report()).result.validation.required_passed, true);
    rows.push({
      id: "main_thread_responsive_during_real_cpp_analysis",
      passed: true,
      control_millis: responseMillis,
      source_bytes: Buffer.byteLength(expensive),
      repeated_assignments: 6000,
    });
    await page.getByLabel("Line width").selectOption("80");
    await page.getByTestId("run").click();
    await page.locator(".file-state.processing").waitFor();
    await page.getByTestId("cancel").click();
    await done();
    await select("expensive.luau");
    assert.equal((await report()).status, "cancelled");
    const terminated = await page.evaluate(() => window.__localAudit.terminated);
    assert.ok(terminated > 0);
    await page.getByLabel("Per-file deadline (ms)").fill("100");
    await run();
    await select("expensive.luau");
    assert.equal((await report()).status, "timed_out");
    await page.getByLabel("Per-file deadline (ms)").fill("30000");
    await run();
    assert.equal((await report()).result.validation.required_passed, true);
    rows.push({
      id: "cancel_timeout_terminate_and_recreate_worker",
      passed: true,
      terminated: await page.evaluate(() => window.__localAudit.terminated),
    });
    await clear();
    const archive = zipSync({
      "Folder/Example.luau": strToU8(positive),
      "folder/example.luau": strToU8(positive),
      "Folder/Unicode.luau": strToU8("local label:string='unicode' return label"),
    });
    await page.getByTestId("zip-input").setInputFiles({
      name: "project.zip",
      mimeType: "application/zip",
      buffer: Buffer.from(archive),
    });
    await page.waitForFunction(() => document.querySelectorAll(".file-row").length === 3);
    await run();
    const hierarchy = unzipSync(await download("Download ZIP", "hierarchy.zip"));
    assert.equal(Object.keys(hierarchy).length, 3);
    assert.equal(
      new Set(Object.keys(hierarchy).map((path) => path.normalize("NFKC").toUpperCase())).size,
      3,
    );
    assert.ok(Object.keys(hierarchy).every((path) => path.includes("/")));
    rows.push({
      id: "actual_zip_worker_preserves_hierarchy_and_case_collisions",
      passed: true,
      paths: Object.keys(hierarchy),
    });
    await clear();
    const folder = resolve(work, "folder-import");
    await mkdir(resolve(folder, "sub"), { recursive: true });
    await writeFile(resolve(folder, "sub/real.luau"), positive);
    await page.getByTestId("folder-input").setInputFiles(folder);
    await page.waitForFunction(() => document.querySelectorAll(".file-row").length === 1);
    assert.ok((await page.locator(".file").getAttribute("title")).includes("sub/real.luau"));
    rows.push({ id: "real_browser_directory_selection", passed: true });
    await clear();
    await page.getByRole("button", { name: "Paste source", exact: true }).focus();
    await page.keyboard.press("Enter");
    await page.getByTestId("paste-source").fill(positive);
    await page.getByRole("button", { name: "Add source", exact: true }).click();
    await run();
    assert.equal((await report()).result.validation.required_passed, true);
    await context.route("**/*", (route) => route.abort());
    await page.getByLabel("Line width").selectOption("100");
    await run();
    assert.equal((await report()).result.validation.required_passed, true);
    await context.unroute("**/*");
    rows.push({
      id: "paste_and_processing_with_all_network_blocked_after_static_assets_loaded",
      passed: true,
      offline_reload_claim: false,
    });
    await page.setViewportSize({ width: 390, height: 844 });
    await page.waitForTimeout(100);
    assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1));
    await page.screenshot({ path: resolve(work, "mobile-viewport.png"), fullPage: true });
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.screenshot({ path: resolve(work, "workspace.png"), fullPage: true });
    rows.push({
      id: "responsive_mobile_viewport_and_visible_keyboard_focus",
      passed: true,
      scope: "Chromium desktop resized; not an Android/iOS device test",
    });
    await page.reload();
    await page.getByRole("heading", { name: "Luau Decompiler", exact: true }).waitFor();
    assert.equal(await page.locator(".file-row").count(), 0);
    rows.push({
      id: "repository_subpath_reload_and_no_source_persistence",
      passed: true,
      local_storage_keys: await page.evaluate(() => Object.keys(localStorage)),
    });
    for (const mode of ["missing", "corrupt"]) {
      const other = await context.newPage();
      await other.route("**/*luau_engine_bg.wasm", async (route) => {
        if (mode === "missing") await route.fulfill({ status: 404, body: "missing" });
        else {
          const fetched = await route.fetch();
          const bytes = await fetched.body();
          bytes[0] ^= 255;
          await route.fulfill({ response: fetched, body: bytes });
        }
      });
      await other.goto(url);
      await other.getByTestId("file-input").setInputFiles({
        name: "asset-check.luau",
        mimeType: "text/plain",
        buffer: Buffer.from(positive),
      });
      await other.getByTestId("run").click();
      await other.locator(".notice.error").waitFor({ timeout: 30000 });
      const text = await other.locator(".notice.error").textContent();
      assert.match(
        text,
        mode === "missing" ? /Missing engine_wasm/ : /Corrupt or mixed-version engine_wasm/,
      );
      assert.equal(await other.locator(".badge.verified").count(), 0);
      rows.push({ id: mode + "_wasm_actionable_failure", passed: true, message: text });
      await other.close();
    }
    const nativeInput =
      process.env.LUAU_BROWSER_NATIVE_CLI ||
      resolve(root, "target/release/luau-decompile" + (process.platform === "win32" ? ".exe" : ""));
    const native = resolve(work, "native-cli" + (process.platform === "win32" ? ".exe" : ""));
    await copyFile(nativeInput, native);
    const packagedAnalyzer = resolve(
      dirname(nativeInput),
      "luau-quality" + (process.platform === "win32" ? ".exe" : ""),
    );
    const nativeAnalyzer = existsSync(packagedAnalyzer)
      ? packagedAnalyzer
      : resolve(root, ".tools/luau-quality" + (process.platform === "win32" ? ".exe" : ""));
    const parity = [];
    for (const [id, input, format, expected] of [
      ["bytecode", fixture, "luau_bytecode", true],
      ["positive", Buffer.from(positive), "luau_source", true],
      ["negative", Buffer.from(negative), "luau_source", false],
    ]) {
      const inputPath = resolve(work, id + ".input"),
        outputPath = resolve(work, id + ".native.luau"),
        qualityPath = resolve(work, id + ".native.json"),
        configPath = resolve(work, id + ".config.json");
      await writeFile(inputPath, input);
      await writeFile(
        configPath,
        JSON.stringify({
          input_format: format,
          output_policy: "verified_typed",
          validation: {
            analyzer_path: nativeAnalyzer,
            definitions_path: resolve(root, "definitions/roblox.d.luau"),
            project: { entry: id === "bytecode" ? "bytecode" : id },
          },
        }),
      );
      let exit = 0;
      try {
        await execute(
          native,
          [
            "decompile",
            inputPath,
            "--config",
            configPath,
            "-o",
            outputPath,
            "--quality-report",
            qualityPath,
            "--force",
          ],
          { cwd: root, timeout: 60000 },
        );
      } catch (error) {
        exit = error.code;
      }
      assert.equal(exit === 0, expected, `Native parity ${id} returned ${exit}`);
      const actual = await readFile(outputPath, "utf8"),
        quality = JSON.parse(await readFile(qualityPath, "utf8"));
      assert.equal(actual, outputs[id === "bytecode" ? "bytecode.bc" : id + ".luau"]);
      assert.equal(quality.validation.required_passed, expected);
      parity.push({
        id,
        native_cli_sha256: hash(await readFile(native)),
        native_analyzer_sha256: hash(await readFile(nativeAnalyzer)),
        source_sha256: hash(actual),
        required_passed: expected,
      });
    }
    rows.push({
      id: "native_browser_exact_source_and_quality_agreement",
      passed: true,
      cases: parity,
    });
    const compiler =
        process.env.LUAU_BROWSER_COMPILER ||
        resolve(
          root,
          ".tools/luau-modern/luau-compile" + (process.platform === "win32" ? ".exe" : ""),
        ),
      oracle =
        process.env.LUAU_BROWSER_ORACLE ||
        resolve(
          root,
          ".tools/luau-modern/vm-runner" + (process.platform === "win32" ? ".exe" : ""),
        );
    const argumentPath = resolve(work, "empty.args");
    await writeFile(argumentPath, Buffer.from([76, 65, 82, 71, 1, 0, 0, 0, 0]));
    const semantic = [];
    for (const [id, original] of [
      ["bytecode", null],
      ["positive", positive],
      ["negative", negative],
    ]) {
      const generated = outputs[id === "bytecode" ? "bytecode.bc" : id + ".luau"],
        generatedPath = resolve(work, id + ".browser.luau"),
        originalPath = resolve(work, id + ".original.luau"),
        leftPath = resolve(work, id + ".original.bc"),
        rightPath = resolve(work, id + ".browser.bc");
      await writeFile(generatedPath, generated);
      const rebuilt = await execute(compiler, ["--binary", "-O2", "-g0", generatedPath], {
        encoding: "buffer",
        timeout: 30000,
      });
      let originalBytes = fixture;
      if (original !== null) {
        await writeFile(originalPath, original);
        originalBytes = (
          await execute(compiler, ["--binary", "-O0", "-g0", originalPath], {
            encoding: "buffer",
            timeout: 30000,
          })
        ).stdout;
      }
      await writeFile(leftPath, originalBytes);
      await writeFile(rightPath, rebuilt.stdout);
      const left = (
          await execute(oracle, [leftPath, "--args", argumentPath], {
            encoding: "buffer",
            timeout: 30000,
          })
        ).stdout,
        right = (
          await execute(oracle, [rightPath, "--args", argumentPath], {
            encoding: "buffer",
            timeout: 30000,
          })
        ).stdout;
      assert.deepEqual(left, right);
      assert.ok(left.subarray(0, 6).equals(Buffer.from([76, 79, 66, 83, 1, 1])));
      semantic.push({
        id,
        protocol: "LOBS/1",
        complete: true,
        observation_hex: left.toString("hex"),
      });
    }
    rows.push({
      id: "controlled_browser_output_behavioral_pairs",
      passed: true,
      scope:
        "Only three owned known-source fixtures executed by explicit host test tools; normal browser processing executes no scripts",
      compiler_sha256: hash(await readFile(compiler)),
      oracle_sha256: hash(await readFile(oracle)),
      pairs: semantic,
    });
    return rows;
  } catch (error) {
    error.browserCases = rows;
    throw error;
  }
}
