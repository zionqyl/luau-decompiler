import assert from "node:assert/strict";
import { setImmediate as nextTurn } from "node:timers/promises";
import { test } from "node:test";
import {
  LocalFailure,
  WorkerSupervisor,
  type WorkerMessage,
  type WorkerPort,
} from "../lib/supervisor.ts";
class FakeWorker implements WorkerPort {
  onmessage: ((event: { data: WorkerMessage }) => void) | null = null;
  onerror: ((event: { message?: string }) => void) | null = null;
  posts: unknown[] = [];
  terminated = false;
  postMessage(value: unknown) {
    this.posts.push(value);
    if ((value as { kind: string }).kind === "init")
      queueMicrotask(() => this.emit({ kind: "ready" }));
  }
  terminate() {
    this.terminated = true;
  }
  emit(data: WorkerMessage) {
    this.onmessage?.({ data });
  }
}
function workspace() {
  const workers: FakeWorker[] = [];
  const stages: string[] = [];
  const supervisor = new WorkerSupervisor(
    "https://example.invalid/worker.mjs",
    "https://example.invalid/manifest.json",
    "test",
    "asset",
    (stage) => stages.push(stage),
    () => {
      const worker = new FakeWorker();
      workers.push(worker);
      return worker;
    },
  );
  return { supervisor, workers, stages };
}
test("late old-worker and mismatched job results cannot replace the current request", async () => {
  const { supervisor, workers, stages } = workspace();
  const first = supervisor.request({ kind: "process", id: "old" }, 1000).catch((error) => error);
  await nextTurn();
  supervisor.cancel();
  assert.equal(((await first) as LocalFailure).kind, "cancelled");
  assert.equal(workers[0].terminated, true);
  let settled = false;
  const next = supervisor.request({ kind: "process", id: "new" }, 1000).then((value) => {
    settled = true;
    return value;
  });
  await nextTurn();
  workers[0].emit({ kind: "result", id: "new", source: "stale" });
  workers[0].onerror?.({ message: "stale old-worker error" });
  assert.equal(workers[1].terminated, false);
  workers[1].emit({ kind: "result", id: "old", source: "wrong job" });
  workers[1].emit({ kind: "progress", id: "old", stage: "stale progress" });
  await nextTurn();
  assert.equal(settled, false);
  assert.deepEqual(stages, []);
  workers[1].emit({ kind: "result", id: "new", source: "current" });
  assert.equal((await next).source, "current");
  supervisor.dispose();
});
test("deadline terminates synchronous work and recreates one bounded worker", async () => {
  const { supervisor, workers } = workspace();
  await assert.rejects(
    supervisor.request({ kind: "process", id: "slow" }, 10),
    (error) => error instanceof LocalFailure && error.kind === "timed_out",
  );
  assert.equal(workers[0].terminated, true);
  const next = supervisor.request({ kind: "process", id: "recovered" }, 1000);
  await nextTurn();
  assert.equal(workers.length, 2);
  workers[1].emit({ kind: "result", id: "recovered" });
  await next;
  supervisor.dispose();
});
