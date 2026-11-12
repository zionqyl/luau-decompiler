# Output policies

Dynamic types in explicitly supplied external contracts are counted separately as `external_contract_any`, `external_contract_unknown`, and `unmeasured_external_contracts`. The default verified policy permits none; these bounded counters conservatively include supplied contracts even if unused. Named SDK classes are not expanded into every class member merely to count unrelated API dynamics. Recursive expression-type accounting has its own finite budget; exhaustion always fails verified typing rather than being reported as zero dynamic types.

The default also requires at least one annotation on a runtime local, parameter, or return signature. An unrelated local type alias alone cannot satisfy this requirement. `meaningful_typing.min_runtime_annotations` makes that threshold explicit; setting it to zero is an explicit policy customization for such uses as type-only exported modules, recorded in configuration identity.

`Config.output_policy`, CLI `--policy`, and per-request HTTP reconstruction configuration share these policies:

| Policy | Annotations | Final-source validation | Failure behavior |
| --- | --- | --- | --- |
| `faithful` | Preserves original source types; disables new bytecode/source inference | Configurable | Reports independent gates |
| `annotated` | Emits justified annotations with recorded provenance | Enabled by default; explicitly disable for faster processing | Preserves source and detailed findings |
| `verified_typed` | Requires meaningful emitted typing | Pinned parser, compiler and strict analysis are mandatory | No successful quality status or source-returning helper success on gate failure |

The CLI spelling `verified-typed` maps to JSON `verified_typed`. Validation `off` and typing `off` conflict with verified typed. The retained `--strict-required` switch requires strict analysis but intentionally keeps its older, narrower contract.

Default meaningful typing requires at least one useful annotation, at least 75% of eligible local/parameter bindings annotated, and 100% of emitted annotation slots useful. Explicit `any`, analyzer-inferred `any`, and type assertions have default maximum zero. `meaningful_typing` exposes all thresholds in configuration and reports actual counts and failures. The chosen thresholds are part of output identity and cache keys. A void return pack expresses arity; a variadic `any` pack does not become useful simply because its fixed head is empty. Recursive traversal covers nested function parameters, return packs, variadics, applications, records, collections, unions and intersections.

Metadata, bounded inference, retained source annotations, and external contracts have separate provenance. A supplied `Player` contract is visible in the report; neither a suggestive name nor one successful runtime input establishes a class. Engine availability and project contracts remain assumptions rather than observed facts.

Recovery uses a finite configured attempt list under one validation-phase deadline and shared request work/cancellation budget. Bytecode annotation recovery may choose metadata-only or faithful output, but an unannotated fallback cannot satisfy verified typed. Source recovery may retain the original typed source; its original annotation metrics are recomputed rather than silently set to zero. Unsupported context, missing assets, or exhausted budgets remain visible failures. The decompiler adds no runtime guards, casts, defaults or altered returns to satisfy analysis.

`type_report.unapplied_external_contracts` identifies supplied binding contracts not checked by the selected final source. Removing a conflicting contract during recovery cannot produce strict-required or verified-typed success, even when the retained original source independently passes strict analysis and its remaining annotations meet the coverage threshold. The diagnostic names the binding, and faithful source remains available. A supplied contract conflicting with an existing source annotation is rejected explicitly instead of replacing the original annotation.

Detailed results retain source, available baseline, attempt hashes/outcomes, tools/context identities, diagnostics, meaningful typing, and independent syntax/compilation/strict statuses. Compilation and strict success never establish behavioral equivalence. Library processing returns structured results for inspection without exiting the host process. Callers must inspect `validation.required_passed` before presenting a requested verified result as successful.

All policies and retained candidates include the mandatory current-version attribution block, including validation-off and failed-quality output. A faithful baseline retains runtime source before optional presentation with this same prefix; it is not the unmodified raw input buffer. Reprocessing official output replaces old leading official headers once. Original input SHA-256 and byte offsets remain separate from final-source hashes and generated positions. No supported wrapper can disable or replace attribution.
