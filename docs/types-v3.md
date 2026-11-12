# Type reconstruction and typed presentation

The Rust decoder now retains type-version headers, exact raw metadata bytes,
parameter/upvalue tags, typed-local register/PC intervals, byte offsets and the
userdata-name remapping table. These are available in `Proto.type_metadata` and
`Module.userdata_types`. A VM tag is not claimed to recover the original source
annotation: aliases, callback signatures, generic names and richer table shapes
are often erased. Broad table/function/userdata/any tags remain unresolved rather
than becoming fabricated `{[any]: any}` or unrestricted callback declarations.

Local metadata is associated with recovered `pN:bM` bindings and compatible PC
intervals. A later variable reusing the same register does not inherit an old
parameter's type. Conflicting/ambiguous scope associations remain unannotated.
Upvalue metadata is retained even when a source-binding association cannot be
proved; the report does not silently throw that evidence away.

## Type AST and inference

`type_ast.rs` contains explicit syntax for primitive/named types, optionals,
unions/intersections, records, arrays, dictionaries, function types, fixed and
variadic packs, aliases, generic types and generic packs. An annotation sidecar
is part of the typed AST. It does not wrap runtime expressions in casts or
parentheses. Explicit external contracts use a bounded type-only parser; they
cannot inject statements into generated Luau.

The bounded inference pass tracks assignments and joins, literal values,
functions and return relationships, captures, table aliases and mutation,
nilability, calls, branch refinements and conservative loop joins. Function
relationships use deterministic bounded fixed points. Unknown calls can
invalidate aliased table shapes. A captured table whose types may change is
conservative rather than frozen to an early snapshot. Local declaration types
include historical assignment constraints; return-value facts can be more
precise than that declaration history.

Direct identity relationships can infer a generic interface and instantiate its
result at different call sites. A numeric test input never specializes the
function itself to `number`. Arithmetic or field usage alone does not prove a
concrete parameter class: metamethods and dynamic boundaries matter. Unknown
interfaces remain visible through omitted annotations and report entries.

For an IR function returning either zero or one known scalar, a variadic scalar
type pack can conservatively describe the static interface. The exact distinct
AST return counts, including generated helper paths, remain in
`function_return_arities`; original serialized Return PCs and fixed/open counts
are independently retained in `original_return_sites`. This is not a claim that
the original function returned an arbitrary number of values. Runtime return
lists are unchanged. An optional scalar annotation is not substituted for a pack:
the actual pinned checker rejected that attempted interpretation. Other
incompatible fixed packs remain unannotated.

The pinned Roblox definition file supplies known classes, inheritance,
properties, methods and global signatures. `Player.Character`, `Model:GetPivot`
and `CFrame.Position`, for example, are contract facts. Literal `GetService`
and `Instance.new` calls use the definition catalog, not guessed variable names.
The index handles a supported subset of the declaration syntax; the independent
official analyzer reads the full definitions. Unindexed signatures remain
unresolved. A variable called `player` does not itself establish `Player`.

Project modules are resolved statically by the independent analyzer. The core
can consume explicit global/instance/binding contracts; it does not execute a
dependency to discover its type or invent project-specific instance classes.

## Configuration

Annotated output is the preferred presentation. `typing.mode = "off"` retains
the unannotated reconstruction. A representative configuration is:

```json
{
  "naming": "camelCase",
  "typing": {
    "mode": "annotated",
    "verbosity": "extensive",
    "emit_strict": true,
    "aliases": true,
    "max_iterations": 8,
    "max_nodes": 1000000,
    "roblox_api": true,
    "binding_types": {},
    "globals": {}
  },
  "formatting": {
    "line_width": 100,
    "multiline_calls": true,
    "multiline_tables": true,
    "blank_lines": true,
    "local_functions": true
  },
  "validation": { "mode": "strict_required" }
}
```

`useful` verbosity omits obvious single-write literal-local annotations;
`extensive` includes all recoverable declarations. Explicit external contracts
remain visible. Naming conventions apply to renameable bindings while keys,
properties and globals retain their spelling. Formatting is AST-based. Width is
a soft layout target: long indivisible literals/type tokens can exceed it.
Calls, constructors, tuple expansion and short-circuit order are not reordered.
The named-local-function presentation is used only when it cannot change a
self/global-name reference's scope.

Use recovered binding identities for external type contracts, for example
`"binding_types": {"p0:b0": "Player"}` only when independent source/project
evidence establishes that interface. Do not assign a class merely because the
debug name resembles it. Callback contracts may use
`"(number, string?) -> (boolean, nil)"`; generic packs and intersections are
represented structurally. Contract errors and nonexistent identities receive
diagnostics rather than being ignored.

Aliases are generated names for proved shapes. They do not claim recovery of
erased original alias declarations. Reusable result records can derive a type
name from a reliably recovered function name; type-name collisions are avoided.

## Reports and independent quality gates

The result retains a faithful unannotated baseline before optional typing.
Metadata/external-contract-only presentation is another implemented recovery
candidate. The final formatted candidate is checked with the pinned official
parser, compiler and Roblox-aware analyzer. A bounded retry can select a known
candidate; it does not add guards, defaults, casts, conversions or waits to make
analysis pass. Optional type/output stage failures retain the faithful source.
Cancellation, deadlines and the shared work budget remain fatal limits and are
never reset for another strategy.

`type_report` separates metadata/inference/external-contract evidence and
preserved tags from actual selected-source annotation counts. `emitted_*`
fields reflect the selected candidate. Explicit/inferred `any` and assertions
also have independent analyzer counts. No `any` or cast is synthesized merely
to silence a diagnostic. A legitimate dynamic boundary can prevent strict
success. Useful typing, source compilation, strict success and behavioral
equivalence are separate results.

Source maps retain deterministic node IDs, expression/statement/function kinds,
generated line/column ranges, original prototype identity, known binding IDs and
known PC intervals. A binding lifetime is not fabricated into an exact opcode
location; unknown expression PCs remain absent. Optional transformations are
reported separately from generated source comments. Strict-required failure
retains faithful source for inspection and yields a failed quality gate.

The staged service accounting covers decoded metadata and growing formatted
buffers. Inference/formatting/recovery share cancellation, memory and execution
work scopes. Timing statistics distinguish decode, reconstruction, inference,
formatting and validation; baseline formatting is included in the formatting
phase rather than analyzer time.

## Actual validation and limits

- Eleven ordinary type/format tests cover bounded syntax, collisions, generic
  interfaces, metadata/register reuse, aliases, nil joins, API contracts,
  variadic packs, verbosity, source mapping and optional-budget recovery.
  Protected constructor keys retain parenthesized general-key syntax in both
  baseline and annotated output; type inference preserves their literal field
  facts without rewriting the compiler-sensitive reservation form.
- The compiler-backed matrix has **144 compiled cases and 432 complete typed
  observations**: nine independent source families × formats 6/14 × O0/O2 ×
  D0/D2 × type-info levels 0/1 × three runtime seeds. Type-enabled fixtures must
  contain real metadata. State probes reuse loaded callbacks; assertion versus
  parenthesis regressions compare exact multiple-return counts and trailing nils.
  [Behavior report](evidence.md).
- Seven final-source quality cases contain six useful annotated strict passes
  and one intentional strict failure. The Roblox identity/position cases use an
  explicit known-source `Player` contract and genuine pinned API definitions;
  they are not executed against a fake Player runtime.
  [Quality report](evidence.md).

The full `PlayerSnapshot` constructor example remains an explicit negative when
the faithful lowering must preserve zero-prefilled table history. Its precise
record-return fact can conflict with the broader declaration needed to represent
that implementation history. The pass does not remove nil-sensitive hash-table
history, cast the table, or insert defaults to conceal the problem. The source
still reconstructs completely and compiles, while strict-required analysis
correctly fails. Rich callback/generic relationships erased from metadata,
recursive mutable graphs and arbitrary dynamic environments remain conservative.

Reproduce:

```powershell
. ./scripts/env.ps1
cargo test --offline --test types_v3
cargo test --offline --test types_v3_behavior -- --ignored --nocapture
```
