export type WorkerMessage = {
  kind: string;
  id?: string;
  stage?: string;
  message?: string;
  [key: string]: unknown;
};
export type WorkerPort = {
  onmessage: ((event: { data: WorkerMessage }) => void) | null;
  onerror: ((event: { message?: string; preventDefault?(): void }) => void) | null;
  postMessage(value: unknown, transfer?: Transferable[]): void;
  terminate(): void;
};
export class LocalFailure extends Error {
  readonly kind: "cancelled" | "timed_out" | "failed";
  constructor(kind: "cancelled" | "timed_out" | "failed", message: string) {
    super(message);
    this.kind = kind;
  }
}
export class WorkerSupervisor {
  private worker?: WorkerPort;
  private boot?: Promise<WorkerMessage>;
  private epoch = 0;
  private rejectBoot?: (reason: unknown) => void;
  private resolveBoot?: (message: WorkerMessage) => void;
  private bootTimer?: ReturnType<typeof setTimeout>;
  private pending?: {
    id: string;
    resolve(message: WorkerMessage): void;
    reject(error: unknown): void;
    timer: ReturnType<typeof setTimeout>;
  };
  private readonly workerUrl: string;
  private readonly manifestUrl: string;
  private readonly version: string;
  private readonly assetId: string;
  private readonly status: (stage: string) => void;
  private readonly factory: (url: string) => WorkerPort;
  constructor(
    workerUrl: string,
    manifestUrl: string,
    version: string,
    assetId: string,
    status: (stage: string) => void,
    factory: (url: string) => WorkerPort = (url) =>
      new Worker(url, { type: "module", name: "Luau local processing" }) as unknown as WorkerPort,
  ) {
    this.workerUrl = workerUrl;
    this.manifestUrl = manifestUrl;
    this.version = version;
    this.assetId = assetId;
    this.status = status;
    this.factory = factory;
  }
  ready(): Promise<WorkerMessage> {
    if (this.boot) return this.boot;
    this.boot = new Promise((resolve, reject) => {
      this.resolveBoot = resolve;
      this.rejectBoot = reject;
      const epoch = this.epoch;
      try {
        const worker = this.factory(this.workerUrl);
        this.worker = worker;
        this.bootTimer = setTimeout(() => {
          if (epoch === this.epoch && worker === this.worker)
            this.reset(
              new LocalFailure(
                "timed_out",
                "Local engine startup exceeded 30 seconds; check the static assets and retry.",
              ),
            );
        }, 30000);
        worker.onmessage = (event) => {
          if (epoch !== this.epoch || worker !== this.worker) return;
          const message = event.data;
          if (message.kind === "progress") {
            if (message.id && message.id !== this.pending?.id) return;
            this.status(message.stage ?? "Processing locally");
            return;
          }
          if (message.kind === "ready") {
            clearTimeout(this.bootTimer);
            this.resolveBoot?.(message);
            this.resolveBoot = undefined;
            this.rejectBoot = undefined;
            return;
          }
          if (message.kind === "error" && !message.id) {
            this.reset(
              new LocalFailure("failed", message.message ?? "Local engine initialization failed."),
            );
            return;
          }
          if (!this.pending || message.id !== this.pending.id) return;
          if (message.kind === "error") {
            this.reset(new LocalFailure("failed", message.message ?? "Local worker failed."));
            return;
          }
          const pending = this.pending;
          this.pending = undefined;
          clearTimeout(pending.timer);
          pending.resolve(message);
        };
        worker.onerror = (event) => {
          event.preventDefault?.();
          if (epoch !== this.epoch || worker !== this.worker) return;
          this.reset(
            new LocalFailure(
              "failed",
              event.message ?? "The local worker failed; restore matching WASM/assets and retry.",
            ),
          );
        };
        worker.postMessage({
          kind: "init",
          manifestUrl: this.manifestUrl,
          version: this.version,
          assetId: this.assetId,
        });
      } catch (error) {
        queueMicrotask(() => {
          if (epoch === this.epoch) this.reset(error);
        });
      }
    });
    return this.boot;
  }
  async request(
    message: { kind: string; id: string; [key: string]: unknown },
    deadlineMs: number,
    transfer: Transferable[] = [],
  ): Promise<WorkerMessage> {
    await this.ready();
    if (!this.worker) throw new LocalFailure("cancelled", "Worker was reset before admission.");
    if (this.pending)
      throw new LocalFailure("failed", "The single-worker queue already has an active job.");
    const epoch = this.epoch,
      worker = this.worker;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        if (epoch === this.epoch && worker === this.worker && this.pending?.id === message.id)
          this.reset(
            new LocalFailure(
              "timed_out",
              `Per-file deadline exceeded ${deadlineMs} ms; the synchronous WASM worker was terminated and will be recreated.`,
            ),
          );
      }, deadlineMs);
      this.pending = { id: message.id, resolve, reject, timer };
      try {
        worker.postMessage(message, transfer);
      } catch (error) {
        queueMicrotask(() => {
          if (epoch === this.epoch && worker === this.worker && this.pending?.id === message.id)
            this.reset(error);
        });
      }
    });
  }
  cancel(): void {
    this.reset(new LocalFailure("cancelled", "Cancelled; the active worker was terminated."));
  }
  dispose(): void {
    this.reset(new LocalFailure("cancelled", "Workspace closed."));
  }
  private reset(error: unknown): void {
    this.epoch++;
    clearTimeout(this.bootTimer);
    this.worker?.terminate();
    this.worker = undefined;
    this.rejectBoot?.(error);
    this.rejectBoot = undefined;
    this.resolveBoot = undefined;
    this.boot = undefined;
    if (this.pending) {
      const pending = this.pending;
      this.pending = undefined;
      clearTimeout(pending.timer);
      pending.reject(error);
    }
  }
}
