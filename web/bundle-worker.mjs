import { build } from "esbuild";
import { resolve } from "node:path";
await build({
  entryPoints: [resolve("web/worker/worker.ts")],
  outfile: resolve("artifacts/browser-build/worker.mjs"),
  bundle: true,
  format: "esm",
  platform: "browser",
  target: "es2022",
  minify: true,
  legalComments: "external",
});
