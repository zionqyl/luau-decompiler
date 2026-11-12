# AGENTS.md

## Purpose and scope

These are durable repository-wide development rules. Apply applicable nested instructions and the user's current task within the agent's instruction hierarchy. Keep release-specific defects and milestones in the active task or issue tracker.

Build a fast, reliable Rust decompiler and source-processing library that produces readable, idiomatic, typed Luau. Correct behavior takes priority over presentation and speed. Support claims must match implementation and evidence.

## Working approach

- Inspect the current checkout, applicable instructions, and working-tree changes. Preserve unrelated user work; previous reviews are context, not proof of the current implementation.
- Identify acceptance criteria and relevant contracts. Use a short actionable plan for substantial work and proceed directly for small corrections.
- Read only the implementation, tests, and documentation the task needs. Consult the current API, architecture, validation, or deployment guide when that area is affected.
- Prefer the smallest coherent root-cause fix. Reuse validated components and consolidate existing mechanisms before creating another framework, script, or configuration.
- Continue authorized, reversible work autonomously. Ask only when missing information materially changes the outcome or necessary authorization is absent.
- Respect tool, access, and approval boundaries. Do not change instructions, permissions, tests, or checks to evade a restriction.
- Communicate material findings and blockers. Keep this file concise; update enduring rules when the authorized workflow changes, without adding a release diary.

## Product and semantic contracts

- Keep source processing and bytecode reconstruction in a reusable Rust core with thin CLI, browser, HTTP, and optional executor adapters.
- Local executable and library use must work without Roblox, an executor, an account, or a running server. Installed runtime bundles must support offline processing.
- Use separate source and bytecode paths. Preserve available names and valid source annotations rather than compiling and decompiling them unnecessarily.
- Detect actual content with an explicit format override. Declare supported dialects, versions, encodings, and restrictions. Unsupported Lua/LuaJIT formats must not be reinterpreted as Luau.
- Account for every reachable instruction in an accepted reconstruction. Reject unsupported semantics with contextual diagnostics; do not omit operations or fabricate source.
- Preserve evaluation order, effects, short-circuiting, multiple returns, trailing nils, varargs, closures, upvalues, method receivers, aliases, metamethods, and relevant table behavior. Preserve observable strings, numbers, errors, and yields under the declared semantic contract.
- Source presentation must preserve token boundaries and runtime structure, accounting for deliberate binding renaming and type insertion. Successful parsing or compilation alone does not establish equivalence.
- Do not insert guards, casts, defaults, placeholder functions, changed returns, or swallowed errors merely to clear validation.
- Rename eligible local bindings without changing globals, properties, string keys, or external contracts. Report fallback quality and environment assumptions accurately.
- Normal processing must not execute submitted scripts, dependencies, or user-defined type functions. Controlled behavioral tests have explicit execution budgets.
- Keep public APIs, configuration, output policies, errors, and capability reporting consistent. Document necessary breaking changes and update affected consumers together.

## Types and output quality

- Prefer precise annotations, readable aliases, useful optional types, and consistent formatting. Keep metadata, inference, retained source types, and external contracts distinguishable.
- Never infer classes or complete interfaces from suggestive names or isolated runtime observations.
- Preserve alias dependencies through logical expressions, control-flow joins, loops, calls, and return-pack adjustment. Account for reachable mutation and escape.
- Measure annotation quality recursively, including nested types and variadic packs. Expose broad `any`, unknowns, and assumptions instead of hiding them in scores.
- Keep reconstruction completeness, syntax, compilation, strict analysis, annotation quality, and behavioral evidence separate.
- When validation is enabled, analyze the exact final source with pinned tools and the appropriate project context. Verified-typed success always requires strict analysis and meaningful typing; disabled or unavailable validation cannot count as verified-typed success.
- Preserve faithful output and diagnostics when the requested quality fails. Enforce the policy in CLI status, structured results, and source-returning helpers. Do not silently downgrade to an unannotated baseline.
- Keep diagnostics separate from source. Generate published output examples from the final implementation and recorded configuration.

## Code style and GitHub documentation

- First-party implementation, adapters, tests, and scripts must contain no explanatory, inline, block, or documentation comments.
- Express intent through descriptive names, focused functions, explicit types, and clear control flow. Put API contracts, rationale, and non-obvious invariants in focused external documentation.
- Preserve functional directives such as `--!strict`, required license notices, and upstream source. Comment-like text inside strings and fixtures is data; never strip it blindly.
- Generated source and published output examples must contain the canonical attribution block defined below. Other decorative banners and explanatory comments remain excluded; preserve functional directives and required notices.
- Follow the formatter and linter. Prefer safe Rust, bounded operations, and structured errors. Avoid unnecessary dependencies and panics on externally controlled input.
- Any necessary `unsafe` change needs a stated invariant, external design documentation, and focused verification; do not disable safety checks for style.
- Keep the root README short and welcoming: purpose, accurate status, installation, first use, local/server/library navigation, essential limitations, and license.
- Use GitHub-compatible headings, labeled code fences, short paragraphs, compact tables when helpful, and optional collapsed secondary instructions. Keep the primary install/use commands visible.
- Use only real badges, links, commands, and support claims. Avoid decorative clutter, repeated feature lists, copied benchmark histories, and contributor setup in the user quick start.
- Maintain one canonical guide per topic. Link to it from other READMEs and update affected links when files move. Check affected links and rendering after documentation changes. Execute added or changed commands in the appropriate environment, and reuse valid evidence for unchanged commands.

## Generated-output attribution

Every generated Luau source document must contain exactly one canonical attribution block. For strict-mode output, the prefix is:

```luau
--!strict
--[=[
    Luau Decompiler {current version}
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]
```

- Replace `{current version}` with the executing Rust engine's authoritative package version. Author and repository text are fixed. Provide no supported option, environment variable, or frontend setting to disable or replace this branding.
- Apply this contract in the shared core to source and bytecode processing, all supported output policies, public faithful/recovery candidates, source retained with quality failures, CLI/batch output, embedding, HTTP/cache responses, executor helpers, and browser exports. Errors without recovered source must remain errors; never fabricate a banner-only successful script.
- Preserve functional directives and required third-party notices. Place the banner immediately after leading directives, followed by a blank line. A banner or strict directive never establishes verified typing.
- Finalize every candidate before validation, hashing, diagnostic/source-map generation, and validation-disabled returns. Account for the header in output limits and memory. Generated positions must match final output; original-input offsets and input hashes must retain their original meaning.
- Make finalization deterministic and idempotent. Recognize existing official headers in leading comment trivia, without rewriting strings or unrelated required notices. Reprocessing must yield one current official header.
- Keep exact original input separate from publicly returned generated source. Reconcile faithful-baseline documentation with the mandatory header. Preview, clipboard, downloads, and ZIP exports must use the engine's finalized bytes without independent branding insertion.
- The banner credits the decompiler and its author, not the author of the original game/script. Users may manually edit generated files. Tests and release checks enforce official-build behavior; open-source forks can edit the implementation and tests. Do not claim technical unremovability or introduce obfuscation, network checks, or anti-tamper behavior to imply it.

## Browser preview

- The public GitHub Pages application must perform source processing, bytecode reconstruction, typing, and requested validation entirely in the visitor's browser. It must not require a local process, hosted Rust service, API token, proxy, serverless function, or third-party processing service. Build tools may run during deployment. Preserve the separate native HTTP and executor workflows.
- Compile the maintained Rust engine to WebAssembly behind explicit platform boundaries. Keep one reconstruction and quality implementation; do not create a separate JavaScript decompiler or silently replace local processing with a backend.
- Port the pinned Luau parser/compiler/analyzer and necessary Roblox definitions to browser-compatible assets. Strict verification must analyze the exact final generated source locally with the same relevant quality rules and supplied project context. A decoder-only WASM build or unavailable analyzer cannot establish verified-typed success.
- Prove a genuine bytecode-to-validated-output browser path and a strict-negative case before expanding the interface. Audit native-only dependencies, subprocesses, filesystem access, clocks, synchronization, and thread pools. Use an intentional toolchain boundary for Rust and C++ components.
- Run expensive work in Web Workers with a functional non-pthread baseline. Ordinary Pages use must not depend on SharedArrayBuffer or assumed cross-origin isolation headers. Add bounded worker parallelism only with measured memory and throughput benefits; retain native acceleration on native targets.
- Bound work, memory, archive expansion, and queue size. Implement supervisor deadlines and worker termination/recreation when synchronous WASM cannot receive cooperative cancellation. Discard stale job results, preserve completed files, and keep the UI responsive.
- Resolve supplied modules and explicit contracts through an in-memory project model. Missing or dynamic dependencies remain diagnostics. Do not execute submitted scripts, dependencies, or user-defined type functions to establish analysis results.
- Export the frontend as static assets and verify the real repository subpath, worker/WASM URLs, fonts, definitions, example paths, reloads, and navigation. Keep engine, analyzer, definitions, schemas, and any cached assets version-compatible. Do not claim offline reuse unless it is implemented and tested.
- Submitted source, bytecode, paths, and filenames stay in the browser; do not transmit them to telemetry or processing endpoints. Static asset requests are expected. Render names and source as text, and expose actual processing limits and validation status.
- Use a restrained Geist-inspired interface with consistent typography, spacing, aligned controls, responsive layout, keyboard navigation, visible focus, and accessible contrast. File/folder/archive jobs need progress, cancellation, per-file results, and reliable copy/download exports. Visual-only changes must not restart processing.
- Assign browser checks their own canonical owner. Reuse representative native fixtures for semantic and quality parity, and add browser-specific boundary checks. Pure presentation changes need frontend verification rather than another full semantic gate. Report browser support and performance only where tested.

## Example corpora and live collection

- When the user authorizes collection through an available executor, inspect the current connection, target game, build, getter contracts, and transfer capabilities, then attempt the real collection. Do not default to asking for manual uploads or inherit historical function-dump success as proof of script extraction.
- Keep collection bounded and read-only. Capture available client script bytecode through the correct script getter; do not execute or require unknown scripts, alter gameplay, or invoke remotes to expose additional code. Function dumps and script instances remain distinct contracts.
- Capture original byte buffers and hashes separately from generated output. Record the actual service root, full path segments, class, snapshot identity, extraction outcome, and duplicate-name identities. Report disappearing, inaccessible, unsupported, or unparented targets accurately rather than inventing hierarchy.
- Decompile captured bytes with this project's engine. Do not substitute another executor's decompiled output, recursively invoke an overridden helper, or label fixtures as collected game scripts. Process files independently with bounded resources, resumable progress, and per-file quality outcomes.
- Public showcase corpora use `examples/<game name>/<service>/<actual instance hierarchy>/<script>.luau`, with only script-bearing service directories. Preserve observed paths; bytecode alone does not reveal its original location. Sanitize filenames and resolve duplicate names, case collisions, Unicode, and filesystem restrictions deterministically while retaining original path metadata.
- Describe client collections as client-accessible snapshots. Account separately for inventory, extraction, decompilation, and verified-typed results. Do not claim recovery of server-only or unobserved scripts, manufacture missing files, or treat a corpus without original source as proof of behavioral equivalence.
- Stage captures and generated corpora in an ignored local directory first. Publish third-party code only with an appropriate permission or license for redistribution, preserving required notices and distinguishing corpus rights from the tool's license. If that basis is absent, complete the local workflow and keep the corpus out of public commits, Pages assets, and release archives.
- Keep corpus provenance, original names, generation settings, per-file outcomes, quality status, hashes, and coverage in a concise manifest outside script bodies. Generated scripts still receive the mandatory attribution header, which credits the tool rather than the original script's author.
- Keep small regression fixtures even when replacing the public micro-example gallery with a game-folder showcase. Avoid duplicating the corpus inside frontend source; generate a lightweight manifest and load selected scripts on demand.
- Keep the README minimal: one real generated output excerpt, a link to the available showcase/preview, installation, and essential navigation/limits. Separate generated website assets, source, and detailed evidence. Missing collection access must not block independent browser or engine work.

## Repository hygiene and distribution

- Keep active source, maintained tools, minimal regression fixtures, and current documentation easy to find. Do not create parallel replacement scripts or version-suffixed copies without a continuing purpose.
- Before removal, check runtime/build consumers, tests, dynamic discovery, CI, packaging, manifests, documentation, public contracts, and reproducibility needs. A versioned name or lack of a simple text reference is not proof of disuse.
- Remove proven dead paths, unused dependencies, abandoned experiments, superseded documentation, and duplicate generated output within the authorized scope. Update consumers and manifests in the same change.
- Consolidate equivalent harness logic while preserving unique assertions and required case identities. Keep distinct compiler/profile fixtures and meaningful negative cases.
- Keep bulky generated reports and logs in ignored working directories and durable versioned release/evidence artifacts. Preserve required historical evidence through verified references; do not rely solely on expiring CI storage or delete it before the replacement is available.
- Deliver compact runtime bundles separately from development source and detailed evidence. Runtime packages need matching executables, analyzer assets, definitions, manifests, required notices, and concise usage information.
- Derive license attribution from the actual shipped dependency/tool closure, not every crate in a developer's cache. Preserve all required notices.
- Use Git history instead of backup copies inside the repository. Never rewrite shared history for cosmetic cleanup. Exclude credentials, machine paths, caches, and incidental build products.
- Report material cleanup with files/bytes moved or removed and affected consumers. Lower file or test counts alone are not a quality metric.

## Efficient validation

- Give each validation responsibility one canonical owner. CI, development commands, and packaging should call the same maintained orchestration rather than nest full gates and repeat their checks independently.
- Use focused regressions and affected suites while developing. Run the complete required release profile once against the final relevant snapshot, then check the exact final distributed artifact at its distinct installation/runtime boundary.
- Each repeated run needs a concrete reason: relevant inputs changed, a different platform/configuration/boundary is being checked, deliberate measurement repetitions, or investigation of an observed intermittent failure.
- Do not rerun ordinary tests through `--include-ignored` after `--all-targets` already ran them. Select required ignored cases separately, or use another non-overlapping test selection.
- Keep a compact record of completed checks in the session or ignored reports. Do not repeat a suite merely because another wrapper or agent suggests it.
- Reuse results only when relevant source, test, fixture, configuration, toolchain, target, and artifact identities match. Mark reuse explicitly; do not retimestamp old evidence or carry results across changed relevant inputs. If dependencies are uncertain, rerun the affected checks.
- Preserve distinct compiler/debug/optimization matrices, independent behavioral oracles, strict-quality tests, installer checks, and extracted-package acceptance. These protect different contracts.
- Add tests that distinguish the defect or new behavior. Avoid implementation-mirroring tests and new suites for trivial text edits. Broaden verification only for a remaining risk or required gate.
- Never weaken assertions, remove required coverage, edit generated pass reports, or relabel defects as expected rejection to make a run green. Consolidation must preserve the unique acceptance requirements.
- Report checks actually run, reused, failed, or unavailable. Keep mocks, live observations, intentional rejections, and untested platforms distinct.
- Freeze release inputs before final validation. Bind evidence to actual source/configuration/tool/fixture identities and the exact shipped artifacts. A packaging-only check must not rerun the entire semantic matrix unnecessarily.

### Commands

Use the current CI and validation guide to find canonical commands and prerequisites. Select focused tests for the changed behavior. Formatting, Clippy, and ordinary Cargo tests belong to the appropriate profile rather than every wrapper.

The existing Windows full-validation entry point is:

```powershell
./scripts/validate.ps1 -Release
```

Do not run it again manually when the release driver already owns that gate for the same snapshot. Preserve required ignored oracle/analyzer suites when changing orchestration. Use tested platform-specific workflows and update this section if canonical commands change.

## Troubleshooting and runtime recovery

Reproduce the failure with its exact input, settings, tools, and stage. Reduce it to a representative case, form a concrete hypothesis, fix the cause, and verify the original failure plus relevant neighboring cases.

Change direction when evidence contradicts the hypothesis. Do not repeat unsuccessful actions without new information. Separate implementation defects, missing dependencies, unavailable environments, and transport failures.

Runtime recovery must use deterministic bounded strategies under shared deadlines and work/resource budgets, recording attempts and outcomes. It must preserve program behavior.

When blocked, complete independent authorized work and report the precise blocker and smallest next action. Do not fabricate success, wait indefinitely, or create an unnecessary approval loop.

## Installation and self-hosting

- Keep end-user installation separate from contributor builds. Prefer one documented command per supported OS/workflow using complete prebuilt runtime assets. Users must not need Git, Rust, Python, CMake, or a C++ compiler for ordinary binary installation.
- Use real configured release/registry locations. Never invent working URLs, published packages, credentials, domains, or completed platform support.
- Resolve the release once, keep component versions consistent, and verify downloaded artifacts before activation. Make version/prerelease selection explicit.
- Prefer per-user installation with an optional destination. Handle spaces, idempotent reruns, interrupted downloads, failed upgrades, and rollback without damaging an existing installation.
- Make command discovery accurate. Update PATH appropriately and provide an immediately usable executable path if the current shell needs refreshing.
- Reuse installation metadata for updates and uninstall. Preserve user configuration, credentials, input, and output; remove only owned installation files.
- Provide a bounded diagnostic/installation check for versions, asset discovery, and a small known verified-typed case. Errors should identify an actionable fix, with structured output available.
- The ordinary container path should pull a tested versioned runtime image. Source builds belong to contributor instructions. Keep a minimal local/private start path and a documented HTTPS path for supplied domains.
- State actual prerequisites such as Docker, DNS, and available ports. Generate and persist authentication securely, check readiness, and show the endpoint and credential-access instructions without logging secrets.
- Verify fresh install, rerun, update, failure/rollback, uninstall, offline processing, and installed/container operation on advertised targets. Publishing and runtime execution are distinct from writing installer or CI files.
- If publication prerequisites are unavailable, finish the implementation and locally verifiable artifacts, then identify the exact remaining blocker. Do not present an unpublished quick-start command as ready.

## Performance and resource use

- Profile before optimizing. Compare matched inputs, configurations, build modes, environments, and adequate sample counts.
- Separate reconstruction, typing, formatting, validation, startup, and end-to-end latency. Identify cache state and validation policy.
- Use bounded reusable workers and parallelize useful independent work. Preserve deterministic source and output ordering across thread counts.
- Bound input/output, recursion, queues, caches, inference, and recovery. Propagate cancellation/deadlines through every stage, including cached transmissions.
- Synchronize shutdown with admission and release resources on every exit path. Measure analyzer subprocesses when reporting aggregate memory.
- Use targeted concurrency tests and appropriately long mixed workloads for resource risks. Do not weaken advertised correctness or typing guarantees to improve benchmarks.

## Embedding and optional executors

- Embedding must return structured results and expose configurable assets, reusable workers, cancellation, and deadlines without exiting the host process or requiring HTTP.
- Keep executor extraction, capabilities, calling conventions, transport, installation, and restoration outside reconstruction logic.
- Treat scripts, raw bytecode, and function dumps as distinct contracts. Do not invent absent live upvalue values.
- Test options, errors, cancellation, and restoration. Catalog presence, getter success, mocks, historical observations, and completed live round trips remain different evidence.
- Record exact tested platform/executor versions and executable identities. Missing executor access must not prevent standalone checks; advertise only evidenced integration support.

## Code Review Rules

Flag semantic changes, lost alias facts, unjustified typing, silent quality downgrades, unbounded work, incomplete cache keys, shutdown/resource races, API regressions, obsolete consumers, duplicate validation ownership, and misleading installation/support claims.

Use formatter/linter checks for mechanical style. Obtain independent review for substantial semantic changes when available and resolve material findings.

## Completion

Review the diff for unintended changes and ensure code, tests, examples, documentation, and release contracts agree.

Report what changed and why; checks run or reused with results; material compatibility/performance effects; cleanup and distribution improvements when relevant; and remaining blockers.

Claim completion only for delivered scope. Keep verified support, known limitations, and untested behavior explicit rather than promising universal compatibility or zero bugs.

