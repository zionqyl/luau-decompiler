# Standalone input and embedding

The `0.4.0-rc.4` common input pipeline accepts byte buffers without an executor, account, HTTP service, or network connection. Bytecode reconstruction remains the existing Rust decoder/CFG/data-flow/AST pipeline. Available source takes a separate Rust lexer, bounded syntax parser, binding resolver, annotation pass, and token-preserving printer. Source is never compiled and decompiled to recover information already present.

## Supported inputs

| Input | Selection | Scope |
| --- | --- | --- |
| Serialized Luau bytecode | `luau_bytecode` or content detection | Explicit version 3 through 14 semantic profiles; unsupported instructions remain precise errors. Automatic representation selection recognizes raw upstream modules and the evidenced version-9/version-14 Roblox signed container described below. Unmarked opcode227 needs an explicit getter/encoding contract. No guessed base64 or compression. |
| UTF-8 Luau source | `luau_source` or content detection | Supported statements, ordinary expressions, functions, closures, varargs, tables, annotations, aliases, generic parameters, ordinary type packs, qualified types, optional/union/intersection/record/array/dictionary/function types. The precise restrictions below apply. |
| Compatible Lua source | Explicit `lua_source` | The Lua 5.1 syntax intersection documented below, under a compatible environment contract. This is not a Lua runtime emulator. |
| Standard Lua bytecode | Rejected | `\x1bLua` identifies the format and encoded version; no implemented backend. |
| LuaJIT bytecode | Rejected | `\x1bLJ` identifies the format; no implemented backend. |

Filename extensions do not select a parser. `Config.input_format`, the CLI `--input-format` override and HTTP `input_format` select the same enum: `auto`, `luau_bytecode`, `luau_source`, `lua_source`. Raw binary buffers are never normalized through UTF-8. Source requires valid UTF-8, optionally with a UTF-8 BOM; malformed text receives a byte-offset diagnostic. UTF-16 is explicitly rejected. Empty or whitespace-only automatic input is ambiguous; an explicit source override permits an empty chunk.

Version headers 9, 10 and 13 overlap ordinary source whitespace. Automatic detection distinguishes their required binary type-version header from leading tabs/newlines before source. Explicit bytecode selection always invokes the version-specific decoder rather than attempting source fallback.

`input::capabilities()` returns machine-readable accepted format, encoding and restriction information. A decoder profile is not an assertion that every opcode or executor representation is implemented.

## Bytecode representation

The default `bytecode_encoding: auto` uses structural evidence, not trial compilation. `upstream` accepts an exactly consumed upstream module. `roblox_opcode227` declares the getter's opcode transform and also recognizes the supported marked container. `roblox_signed_74171870` requires version 9 or 14, both observed-build trailer marker equations, and exactly 24 bytes after the validated main prototype. Arbitrary, corrupt, extra or unknown trailers reject. The marker constants identify the layout observed through Madium 2.0.0 on Roblox 0.747.0.7471481; other builds are not inferred from a filename or executor name.

The 24-byte trailer contains a 16-byte opaque signature and two marker words. Recognition does not verify cryptographic authenticity: the signing tables/checker are unavailable. `representation` reports the selected container, opcode encoding, raw body length/hash, exact trailer and this limitation. `input_sha256` always covers the entire original byte string. The raw capture is never rewritten. Unmarked Roblox opcode227 buffers remain ambiguous to ordinary drop-file detection and require an explicit advanced override backed by their getter provenance. See [representation and corpus evidence](client-corpus.md).

## Source contract

The parser accepts local declarations, assignments and compound assignments; call statements; numeric/generic loops; `while`, `repeat`, `do`, `if` and if-expressions; closures and local functions; methods; varargs; return lists and type assertions. It preserves runtime tokens, literal spellings, parenthesis boundaries and expression order. Single-value calls and open return lists are never rewritten. Binding resolution follows local scopes and closure captures. Later assignments, including writes through captured local names, prevent scalar-literal inference.

Existing annotation syntax and useful names are retained. The bounded fact analysis propagates immutable primitive types through unassigned bindings, arithmetic, concatenation, logical expressions, and conditional expressions. It infers closed, equal-arity function return packs, including trailing nils, when every return and fallthrough is justified. Typed scalar callbacks can receive function annotations; generic identity returns are inferred only from an unassigned parameter with the function's own generic name and no effectful calls. Open call/vararg tails, differing arities, mutable structures, body-local type aliases, and unknown interfaces remain conservative. Runtime observations never narrow parameters.

Explicit `typing.binding_types` contracts may annotate parsed locals and parameters; conflicting original annotations and unknown binding identities are rejected. Original annotations use `source_annotation` provenance; inferred facts use `inference`; supplied contracts use `external_contract`. `source_bindings` records declaration byte intervals, original/final names, capture/assignment facts, type-only status, and annotation provenance. `source_functions` separately records original signature offsets and retained/inferred return packs. Type-only declarations remain visible but cannot satisfy runtime-annotation eligibility. Source input never fabricates bytecode registers or PC evidence.

Source names are preserved by default. Explicitly setting `naming_options.use_debug_names` to `false` enables the configured `snake_case`, `camelCase` or `PascalCase` transformation for resolved local bindings. Overrides use `p0:bN`, where `N` is the deterministic parsed declaration index. References and captures change together. Globals, field names, string keys and type aliases remain unchanged. Names are reserved against globals and other bindings; unsafe overrides are rejected. This opt-in transformation excludes debug-name/stack introspection from its equivalence claim, as bytecode renaming already does.

Output removes explanatory source comments through the lexer, preserving comment-like bytes inside literals, recognized functional directives, and copyright/SPDX notices. The faithful baseline preserves original runtime source with the mandatory official attribution prefix. Exact raw input remains caller-owned; `input_sha256` hashes its unchanged bytes, and original binding/signature offsets still refer to that input. The printer re-lexes emitted source to check original token boundaries, allowing deliberate binding replacements and annotation insertion, and reparses it even when external validation is disabled. This prevents long-string indices from becoming call expressions. Indentation, multiline tables, bounded-width multiline calls and original blank-line placement use common configuration. This is not a promise of a complete general-purpose Luau formatter.

Unsupported source features receive explicit diagnostics, including interpolated backtick strings, user-defined type functions, generic defaults, type metatable syntax, and newer declaration/class constructs. Parsing a supported type does not imply the external-contract type AST can measure every original type exactly: unsupported measurement forms are retained but do not count as useful typing. Final pinned analysis determines whether the actual output is valid in its supplied module/API context.

The Lua path rejects Luau annotations/aliases, binary literals, numeric separators, Luau-only escapes, compound assignments, floor division, if-expressions and `continue`. Generic loops require unshadowed standard `pairs`/`ipairs` calls or a standard `next` iterator; arbitrary generalized table iteration would change Lua 5.1 behavior and is rejected. Lua 5.2+ `goto`, labels, bitwise operations and dialect conversion are unsupported. Compatible standard-library globals and runtime environment are an explicit caller contract; version-dependent libraries, debug/environment introspection, unspecified table ordering and undefined length behavior are not translated or certified. Error source locations and stack/debug inspection can change with formatting/naming, as in bytecode reconstruction. Selecting `lua_source` does not establish equivalence for arbitrary Lua programs. A separate Lua 5.1 runtime was not used for the Luau-source behavioral matrix.

## Library

`processing::process(input, input_format, config)` processes a borrowed byte slice and returns `Result<Decompiled>`. `processing::process_source(source, config)` accepts `&str` directly through the same source pipeline. The same result carries source, faithful baseline, diagnostics, policy status, type provenance and stage timings. It does not terminate the embedding process. `decompile` remains a bytecode-only backward-compatible API.

`processing::Processor::new(threads)` owns a reusable bounded worker pool. Its `process` method accepts an `ExecutionContext` with cancellation and an absolute deadline. The context can attach an aggregate admission ledger. `process_batch` preserves input order and rejects batches whose configured worst-case input/output retention exceeds the caller's byte allowance; use the existing bounded streaming interface for larger collections. The ledger is admission accounting, not an OS heap/RSS limit. Callers retaining returned strings own their application-level retention policy.

The [embedding example](../examples/embed.rs) creates one processor, requests verified typed output and checks the structured gate before using source. Run it with `cargo run --locked --example embed` in a contributor checkout. An embedding application links the Rust library and supplies the analyzer, manifest and Roblox definition assets when final validation is required. It does not need a localhost service. No submitted source, dependency or type function executes during ordinary processing.

Prebuilt runtime bundles include validation assets. End users of those bundles do not need Rust or a C++ compiler. Building the library or its application requires the usual Rust build dependencies; building pinned validation helpers is a contributor/package-build step.

## Evidence

`cargo test --locked --test source_inputs` covers input identity/encoding, immutable and captured assignments, binary string spellings, scalarized return syntax, recursive explicit `any`, naming boundaries, bounded mutation, cancellation, deadlines, memory cleanup and aggregate batch bounds.

`cargo test --locked --test source_inputs -- --ignored` invokes pinned final parser/compiler/strict analysis for useful positive source, original PlayerSnapshot types, failed strict annotations and broad dynamic callback rejection. It separately tests policy failure when validation is disabled.

Optional local renaming follows imported module bindings in qualified type references. Import namespaces are resolved separately from ordinary type aliases, generic names and runtime parameter shadowing. The project-resolution regression validates the final renamed source against real statically supplied modules in all three naming styles; type-only references do not fabricate runtime closure captures.

`cargo test --locked --test source_behavior_rc -- --ignored` compares original and processed source with the independent typed VM oracle. Twelve source families combine methods, callbacks, generics, mutable captures, table aliases, protected errors, loops, return adjustment, trailing nils, binary strings and effects across v6/v14, O0/O2, D0/D2, three naming profiles and three runtime inputs. The generated [report](evidence.md) contains exact source/output/configuration/compiler/oracle identities. Those controlled observations are distinct from strict analysis and do not prove all-input equivalence.

The `source` cargo-fuzz target separately bounds bytes, nesting, work, output, memory and deadline with validation disabled; it never executes accepted programs. Adding that target is not evidence that a coverage-guided source campaign ran. The ordinary deterministic mutation regression is reported separately.


`cargo test --locked --test source_rc2 -- --ignored` additionally checks long-string delimiters in callable and non-callable indices under validated and explicitly unvalidated settings (60 behavioral pairs), six useful strict-typed signature examples, and 56 generated source programs with 168 comparisons across two compiler formats and three inputs. Generated programs reuse the maintained compositional generator, including repeated calls of one loaded closure. These finite observations complement structural token checks; neither proves arbitrary-program equivalence.

## Browser-local use

The static application compiles the same Rust library to WebAssembly and runs it in a dedicated worker. A separate non-pthread WebAssembly module contains the pinned Luau parser, compiler and strict analyzer. Shared framing, quality rules and recovery operate on finalized source in memory, with pinned Roblox definitions and explicitly supplied project modules/contracts. No processing server or script execution is involved. See the [browser guide](browser.md) for limits, tested browsers and publication status.
