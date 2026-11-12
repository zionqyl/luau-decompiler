import { mkdirSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
const configuration = {
  output: "export",
  basePath: "/luau-decompiler",
  trailingSlash: true,
  images: { unoptimized: true },
  poweredByHeader: false,
  webpack(config, { isServer }) {
    if (!isServer)
      config.plugins.push({
        apply(compiler) {
          compiler.hooks.done.tap("RuntimeLicenseClosure", (statistics) => {
            const resources = new Set();
            function visit(module) {
              if (module.resource) resources.add(module.resource.split("?")[0]);
              if (module.modules) for (const nested of module.modules) visit(nested);
            }
            for (const module of statistics.compilation.modules) visit(module);
            const directory = resolve(process.cwd(), "../artifacts/browser-build");
            mkdirSync(directory, { recursive: true });
            writeFileSync(
              resolve(directory, "frontend-runtime-closure.json"),
              JSON.stringify({ schema: 1, resources: Array.from(resources).sort() }, null, 2) +
                "\n",
            );
          });
        },
      });
    return config;
  },
};
export default configuration;
