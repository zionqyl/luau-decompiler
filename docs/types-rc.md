# Type reconstruction in 0.4.0-rc.4

The Rust type engine keeps mutable table identities separately from structural types. Literal constructors, table-valued function results, and structural table contracts create bounded abstract identities. Aliases retain identity relationships through record fields, collection entries, adjusted call results, optional values, and captured references.

Logical results and control-flow joins retain unioned alias dependencies even when no single table identity survives. A bounded assignment dependency closure accounts for aliases created on later loop iterations. Expanded arguments retain both direct table identity and reachable dependencies. Structural external globals, parameters and opaque returned tables share conservative external mutation tracking; a no-argument opaque call can invalidate previously returned shared tables. Epochs distinguish fresh post-call observations without making old aliases immutable.

Calls have no general proof of immutability. Passing a tracked table or a callback that exposes tracked tables therefore invalidates the reachable mutable graph. Containing records and aliases also lose dependent facts. The graph retains overwritten and branch-dependent edges conservatively, handles cycles with a visited set, and propagates invalidation after joins. It can omit useful annotations for a function that happens to be read-only; no read-only effect contract is inferred from its name or signature.

A structural table returned by a function receives an abstract identity. A result that could alias a receiver, argument, or captured value retains those dependencies. Functions whose return annotations depend on subsequently invalidated captures lose those optional return annotations. Explicit external contracts remain visible as assumptions rather than being silently rewritten into inferred facts.

Record function fields use the ordinary Luau function convention: a colon call supplies the receiver as the first argument. Roblox method definitions are parsed from the pinned definition snapshot with their receiver already removed. Generic argument binding respects these two representations.

Parenthesized calls clear expandable return packs. A scalarized zero-result call produces nil; an unparenthesized final call can produce zero results or a pack containing trailing nils. The runtime AST is not padded or cast to make inferred packs fit.

`TypeMetrics` is the common recursive traversal for usefulness, explicit `any`, and unknown nodes. It visits parameters, variadic parameters, return heads and tails, callbacks, records, arrays, dictionaries, optional types, unions, intersections, and generic applications. Annotation counts include emitted aliases and variadic annotations. An explicit external `(...any) -> (...any)` contract remains printable and counts two `any` occurrences and zero useful annotations. Source annotations have a separate `source_annotation` provenance category.

The printer preserves authoritative local function contracts. It uses `local function` syntax only when no local annotation is being dropped or when that annotation is proven equivalent to the function signature actually emitted. Comparison is bounded and can expand generated aliases with identity generic arguments. A conflicting or unproved contract remains an explicit typed local assignment, where strict analysis can diagnose it.

`emitted_annotation_counts` follows the runtime AST and the same formatting decision. It counts actual local, parameter, variadic, return, and alias annotation slots; an omitted redundant local function type is not counted again. `emitted_runtime_annotations` excludes alias declarations. Binding coverage can still recognize a function binding whose complete explicit signature represents its type. The contract regression checks both the initial strict rejection and rejection of verified-typed success after bounded recovery.

## Fresh constructor proof

The reconstruction pass folds a limited fresh table history into a constructor. A record must start with distinct identifier string keys and inert scalar prefill values. An array must start with a complete nil reservation. Every field must then be written exactly once in template order; array indexes must be contiguous from one through the original reserved length.

Each write can consume up to two single-use locals that hold its literal key and value. The initializer cannot refer to or capture the fresh table. No intervening call, alias publication, branch, loop, metatable operation, extra local, or reordered write is accepted. An enclosing `do` block is removed only when its entire body consists of the matched locals and writes. This permits generated large modules to move single-use anonymous functions into a fresh array without moving unrelated scope contents.

Keys, key order, and reservation length are retained. A final array call, method call, or vararg is scalarized so it cannot expand into additional elements. When the only other use is the immediately following return, the constructor replaces the temporary and return. `constructor_transformations` records affected recovered binding identities even when that temporary disappears from the emitted tree.

The PlayerSnapshot fixture now produces a precise optional Vector3 field without including the loader's temporary numeric prefill values in the final record. The explicit Player binding contract is recorded. The regression matrix covers formats 6 and 14, optimization 0 and 2, debug information 0 and 2, and type metadata 0 and 1. It requires final parser, compiler, strict, and meaningful-typing success.

The host behavioral probe uses explicitly controlled structural Player/Model test doubles, binary names, absent and present characters, vector results, ordered method effects, and unsorted table iteration. This establishes those host observations; it does not certify actual Roblox userdata or normal-engine extraction. Native evidence is reported separately.

## Serialized function entries

`entry_output=function` emits a chunk returning the serialized entry function, preserving its fixed parameters and vararg declaration. The script entry contract rejects fixed parameters with an actionable diagnostic. Compiler-generated packets exercise fixed and variadic entries with trailing nils through the independent typed oracle.

A known executor capture-wrapper shape is conservatively rejected in function-entry mode: a zero-parameter, nonvariadic four-instruction root loads nil, creates a one-upvalue child, captures that nil by value, and returns the child. The serialized packet does not contain the original live capture value. An identical legitimate function factory is outside this conservative function-entry scope. Script mode retains its ordinary serialized-script meaning.

## Reproduction

```powershell
. ./scripts/env.ps1
cargo test --offline --locked --test types_v3
cargo test --offline --locked --lib constructor_tests
cargo test --offline --locked --test types_rc -- --ignored --test-threads=1
cargo test --offline --locked --test types_v3_behavior -- --ignored --test-threads=1
cargo test --offline --locked --test profile_hash_layout_v3 -- --ignored --test-threads=1
```

The candidate reports are `docs/results/types-rc-snapshot.json`, `types-rc-behavior.json`, and `types-rc-function-entry.json`. Their identities and actual outcomes belong to the release gate; existence of these files alone is not evidence of a fresh successful release.

## Source signatures

The separate source frontend now derives immutable primitive local types and closed return packs from bounded facts. It can emit useful scalar callback signatures, equal-arity optional returns, void returns and direct generic identity returns. Mutable record postconditions, open return tails, unknown inputs, aliases declared only inside a function, and interfaces narrowed by observed runtime values are deliberately excluded. See the [source contract](source-input.md) for restrictions and provenance.

Annotation accounting distinguishes runtime bindings from declarations parsed within `typeof`. Nested explicit `any` is counted once per syntactic occurrence and remains visible even when it contributes no runtime annotation. Type-only declarations cannot make an otherwise untyped program satisfy the verified-typed runtime requirement.

The additional alias matrix has six families, 96 compiler cases and 288 exact typed comparisons, covering logical aliases, loop joins, shared opaque returns, adjusted packs, no-argument effects and configured structural globals. Its five selected strict checks use explicit function contracts and remain separate from behavioral equivalence. The structural-global family uses a controlled shared environment and does not claim strict validation from inference contracts alone.

Function signature parsing now associates facts with the actual registered function identity after recursive annotation parsing. Nested `typeof(function...)` bodies cannot overwrite an outer callback or local-function identity. Bounded scalar dependency widening handles reachable changes on later loop iterations; facts from a single body pass do not justify permanent annotations. Conservative loss of precision remains visible to strict/useful-typing checks.

## Captured scalar dependencies

Closure inference reads the bounded whole-binding history of free scalar captures, including writes after closure creation, delayed initialization and callback-to-callback return dependencies. The final permitted iteration widens unresolved capture facts rather than retaining a stale precise return annotation. This can reduce annotations when a recursive or externally mutable relationship cannot be proved. Contracts, metadata and inferred facts retain their separate provenance; runtime samples are not interface constraints.

Noncached closure construction without a self-value capture initializes internal capture aliases before creating the function only when closure-allocation identity is independently established. Repeatedly evaluated sites keep conservative allocation scaffolding. Existing identity-cache and self-value initialization forms remain conservative. Exact returns and ordinary local-function presentation follow from the resulting AST, rather than text substitutions. Controlled compiler/strict/typed-oracle regressions cover scalar writes, delayed nil initialization, callback dependencies, captured writers, recursion and distinct value-captured closure identities.
