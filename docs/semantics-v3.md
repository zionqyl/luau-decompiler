# v0.3 semantic reconstruction and generated evidence

The core still lowers validated bytecode through CFG, SSA, recovered bindings,
structured AST and a Luau-aware printer. Unsupported instructions and unproved
control/data relationships remain diagnostics. A successful complete lowering is
separate from compilation, strict analysis and measured behavioral evidence.

## Protected calls

Format-14 opcode 89 is decoded as FASTPCALL, with protected ID zero for pcall and
one for xpcall. The implementation follows pinned official Luau 0.746 revision
12a6ba75883272c79b66b59815efef4c574196f6:

- Common/include/Luau/Bytecode.h defines the explicit-argument count and CALL skip.
- Compiler/src/Compiler.cpp emits the protected-call shortcut, builtin lookup
  fallback and following ordinary CALL.
- VM/src/lvmexecute.cpp applies safe-environment/yieldability guards and prepares
  the protected handler frame; VM/src/lbuiltins.cpp validates the target/handler.

Decoding checks the version, protected ID, exact following plain CALL, fixed
argument count or open-tail position, instruction boundaries and continuation.
The lowering proves that fallback setup resolves the matching pcall/xpcall,
preserves every argument and changes only the callee slot. Existing CFG, capture
and liveness checks reject external fallback entries, observable captured writes
or live scratch values. It emits the ordinary protected call with its real
argument/return expansion. It does not implement a replacement pcall in source
or insert guards, conversions or error normalization.

The pinned VM's LuauFastpcall runtime flag defaults to false. Opcode presence
alone would otherwise test only fallback behavior. The typed oracle therefore
supports explicit --fastpcall true/false and --runtime-flags. A read-only
interrupt observer checks original instruction boundaries and all fast-path
guards, reporting eligible Lua and C targets separately. The source VM is not
modified. These counters describe guard eligibility, not hardware retired
instructions. Known yieldable coroutine contexts and the resulting typed call,
error and yield observations establish the exercised paths.

The independently completed protected gate has eight distinct source programs,
32 compiler cases (O1/O2 × D0/D2), and **232 complete typed comparisons** with
the runtime flag explicitly disabled and enabled. Every enabled original case
has eligible FASTPCALL evidence. Recompiled source can use an ordinary pcall
fallback, particularly when an open-call continuation preserves lookup order;
its runtime counters remain separate. The families are:

- Lua target success and exact binary error values.
- Nested pcall/xpcall and mutable capture effects.
- Vararg arguments, multiple returns and trailing nils.
- Yielding Lua targets and direct yielding C targets.
- xpcall target yield/resume, success and errors.
- Repeated calls to one returned stateful closure using an unchanged trusted probe.
- Immediate C targets including rawequal, error and table.unpack.
- An xpcall error handler that itself throws a numeric error.

[Protected-call report](evidence.md) records source/compiler/
oracle hashes, exact opcode PCs, protected IDs, arguments, runtime guards and
observation hashes. User errors intentionally use error(value, 0). Source line
prefixes and stack/debug introspection are not erased from the oracle or claimed
recoverable by these cases.

## Hybrid control flow and open table results

Dispatcher fallback can now contain proven native numeric and generic for-loop
regions. A collapsed region has one external entry at its preparation block and
all non-return exits lead to the compiler's loop exit. The existing native-loop
proofs still govern hidden control registers, specialized iterator provenance,
capture lifetimes, breaks and continues. Regions with unproved external body
entries, nonlocal exits or unsupported internal structure reject. This is not a
general lowering of VM for-control registers into guessed arithmetic.

An open SETLIST may consume values after branches when its receiver has one
dominating SSA constructor, remains unescaped/uncaptured and has no intervening
writes. Only array-only fresh constructors with exactly matching reservation and
result-prefix evidence qualify. Conditional hash/array insertion histories,
prefilled mixed tables and unresolved open packs crossing branches still reject.

Four source families across O0/O1/O2, D0/D2 and four inputs yield **120 complete
typed comparisons**. The hybrid loop family runs in auto and forced-dispatcher
modes. Tests require actual numeric/generic loop instructions and constructor/
open-store PCs in different blocks. Another family verifies that parentheses
and original type assertions scalarize multiple returns while an unparenthesized
tail still expands. No assertions are inserted to clear analyzer diagnostics.
[Structural report](evidence.md).

Parameter-style fallback names now depend on recovered parameter identity.
Later definitions in the same VM register receive independent binding names.
The debug-name and descriptive-inference switches affect presentation while
retaining metadata provenance, binding identities and explicit overrides.
Call-result naming follows at most sixteen SSA move definitions and uses actual
method/global spellings and literal arguments, such as Players passed to
GetService. These are naming facts, not evidence that an unknown receiver has a
Roblox class. Ambiguous joins or longer chains keep stable fallback names.
Debug-name hints are bounded before copying; full retained metadata is accounted
for separately and remains available in the report.

## Compiler-sensitive table reservation syntax

The pinned compilers distinguish general index items from record items when
choosing NEWTABLE versus DUPTABLE. Compilers 0.726/0.730/0.746 deduplicate repeated
record keys in their table-template optimization. Consequently, rewriting a
hash reservation such as repeated `["alpha"] = nil` items into `alpha = nil`
changes initial physical capacity and can change observable `pairs` order.

Reservation keys now retain general-index syntax using the existing scalar
AST node, for example `[("alpha")] = nil`. The value and evaluation order are
unchanged. This protection applies to capacity reservations; proved template
constructors retain their existing readable record presentation. Array/hash
field storage and owned key expressions are admitted before materialization,
and the field vector is allocated to its validated size.

The focused regression reproduced **144 failures before the fix**: one source
family across 72 compiler fixtures, each in faithful and annotated mode. The
same 144 cases pass afterward with equal initial allocation shape and exact
ordered typed observations. The full modern matrix also passes 1,872/1,872 and
the capture matrix passes 144/144 after the guard changes. No observations are
sorted or normalized. [Focused report](evidence.md).

Serialized templates with distinct constant indices but byte-equal string keys
are well formed, yet their physical layout is not established by the supported
source-template reconstruction. Both ordinary and prefilled DUPTABLE templates
reject this case as unsupported with prototype/PC diagnostics. Equality uses
the original bytes: four serialized negative cases and two different binary-key
positives cover shared/distinct pool entries and avoid lossy UTF-8 comparisons.

Compiler failures retain bounded exit/status/stdout/stderr details, source
hashes and raw diagnostic artifacts. Luau's binary error packet can have an
initial zero byte in stdout with empty stderr; that information is preserved.
The harness does not retry a failed compilation to turn it into success.

One earlier isolated compiler failure remains unexplained; artifact races or
compiler nondeterminism are not established causes. The failing source is retained
in `artifacts/hash-layout-v3-before/unexplained-compiler-failure.luau`. Current
failures preserve raw stdout/stderr, exit status and source identity and remain
failures. This unknown event is separate from the reproduced 144-case allocation
regression and is not dismissed as a flake.

## Independent generated axes and stateful compositions

The original 128 generated source identities remain byte-for-byte reproducible.
The legacy behavioral matrix now runs both D0 and D2 for every source, removing
the former debug=index-parity coupling: 1,024 compiler cases and **3,072 typed
comparisons** across formats 6/14, O0/O2 and three runtime inputs.

An additional Cartesian test selects eight named families and seeds 41/73
independently, then runs every combination of format 6/14, O0/O1/O2, D0/D2 and
three runtime inputs. Four more seeded programs compose branches, finite loops,
per-iteration captures, table mutation, aliases, protected errors and multiple
returns. An unchanged separately compiled probe invokes each returned closure
three times, including mutation before a protected error and a subsequent call.
The result is 20 source programs, 240 compiler cases and **720 complete typed
observations**, including 144 stateful sequence observations. A sequence is one
observation containing three calls; those calls are not counted as three separate
source programs or native extractions.

[Generated v3 report](evidence.md) retains the required
source and compiler-case IDs and a case-plan hash. Missing fixtures, duplicates,
failed reconstruction/recompilation, incomplete observations and mismatches do
not disappear from the denominator. Existing bounded minimization remains an
explicit development command; it is not invoked without a failure source by the
release gate.

## Repeated entry invocation and closure identity

The controlled oracle now supports `--repeat-entry 2`, which invokes the same
loaded root closure twice in the same environment. This differs from invoking a
returned closure repeatedly. Four known-source families cover ordered global
mutation, nested noncapturing closure identity, mutable reference captures and
captured `DUPCLOSURE` cache behavior. Across the pinned 0.654/0.746 compilers,
O1/O2 and D0/D2, **24 supported cases match typed observations**. Eight captured
cache cases reject in repeated-entry mode and remain in the report with their
observed baseline mismatch evidence. They are not successful reconstruction.
[Repeated-entry report](evidence.md).

`closures.entry_invocation` defaults to `single`, preserving the established
one-entry contract while reporting affected prototype/PC locations. Set it to
`repeated` to require the stronger boundary. A bounded noncapturing subset uses
hoisted immutable function bindings; it requires the explicit
`closures.compiler_closure_sharing=true` output-compiler contract. That contract
was tested with the pinned O1/O2 compilers; it does not establish O0 behavior or
arbitrary compiler compatibility. Repeated-entry configurations without that
contract reject `DUPCLOSURE`, and captured/persistent cache arrangements still
reject even with it. Programs without those instructions do not require this
compiler assumption. No implicit compiler optimization promise is made.

## Remaining instruction limits

Native userdata atom operations require runtime atom-to-property callback
information absent from ordinary serialized metadata. CMPPROTO depends on VM
prototype identity that cannot be preserved merely by recompiling source.
Integer constants are not rounded into doubles; experimental class operations
and class shapes still reject. Type metadata can preserve a registered userdata
name without proving the runtime semantics of these operations.

No representative controlled native-source corpus was available for measuring
the frequency of those unsupported families. Their priority is therefore not
reported as an empirical ranking. The executor catalog and a small native model
are not substitutes for native opcode-frequency or end-to-end coverage evidence.

## Reproduction

```powershell
. ./scripts/env.ps1
./scripts/build-vm.ps1
./scripts/setup-profiles.ps1 -BuildOracle
cargo test --release --offline --test v3_semantics -- --ignored --nocapture
cargo test --release --offline --test v3_repeated_entry -- --ignored --nocapture
cargo test --release --offline --test profile_hash_layout_v3 -- --ignored --nocapture
cargo test --release --offline --test generated_programs generated_valid_programs_behavior -- --ignored --nocapture
cargo test --release --offline --test generated_programs orthogonal_compositional_and_stateful_programs_behavior -- --ignored --nocapture
```

These are individually completed runs; the release gate regenerates evidence
for its exact final source/oracle snapshot. All work shares bounded resource,
cancellation, deadline and work budgets in production contexts. No recovered
program or dependency is automatically executed outside controlled test harnesses.
