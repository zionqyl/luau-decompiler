# Application and generated-program evidence

The application corpus contains four original, owned Luau modules: a bounded
FIFO queue, synchronous signal, observable batched store and linked LRU cache.
These model persistent client state, callback registration/disconnection,
reentrant mutation, multiple-return presence flags, dynamic keys, method calls,
linked objects, nil deletion and binary keys/values. The files are in
tests/application-corpus; none were extracted from a private Roblox game.

The application_modules_behavior test currently passes **96 compiled cases and
384 complete typed comparisons**:

- Four modules, pinned official formats 6 and 14.
- Optimization levels 0/1/2 and debug levels 0/2.
- Runtime seeds -3, 0, 1 and 7.
- Two explicitly reported modes: combined application program; standalone
  module bytecode followed by separately compiled, unchanged trusted probe
  bytecode.

The second mode decompiles the actual module export-producing bytecode.
The VM passes its entire return tuple directly into a probe, so recompiling a
wrapper cannot inline away the module API. Probes independently assert queue,
listener, store and eviction invariants; they return only observable typed
values. Opaque export tables/functions are never accepted as complete terminal
observations. Callback effects remain ordered, and nil/binary values remain
typed and length-delimited. The report is
[applications.json](evidence.md), including mode, module/probe,
compiler, oracle, input/output and exact observation hashes.

The generated-program gate currently passes **512 compiled cases and 1,536
complete typed comparisons**. A deterministic xorshift generator creates 128
distinct valid programs using eight bounded grammar families: arithmetic,
nested branches, while/repeat, numeric loops with exits, generic iteration and
dynamic keys, mutable closure factories, variadic multiple returns, and
metamethod arithmetic. It uses formats 6/14, optimization 0/2, alternating debug
0/2, and three inputs combining numeric seeds with nil and different binary
string tokens. All loops have finite bounds. Every comparison requires a
successful, complete original execution; a matching harness error or opaque
value cannot pass. See [generated-programs.json](evidence.md).

The generator found a genuine optimized nested-branch bug: an inner branch
jumped to the enclosing join, and reconstruction emitted its other assignment
unconditionally. A bounded line-deletion reducer made 96 deletion attempts
(97 predicate checks including the initial source), reducing seed 9 from 560 to
384 bytes while requiring valid source, successful original executions and a
remaining differential failure. The retained source is
tests/semantic-corpus/nested_branch_join.luau; the historical pre-fix evidence
is [generated-minimization.json](evidence.md).
The fixed case also remains in the full deterministic generated matrix.

Run the reproducible gates:

~~~powershell
. ./scripts/env.ps1
./scripts/setup-profiles.ps1 -BuildOracle
cargo test --offline --test applications application_modules_behavior -- --ignored --nocapture
cargo test --offline --test generated_programs generated_valid_programs_behavior -- --ignored --nocapture
~~~

For a future reproducible failure, use:

~~~powershell
./scripts/minimize-generated.ps1 -Source artifacts/generated-programs/program-009.luau -Version 6 -Optimization 2
~~~

The reducer refuses to label invalid source or unsuccessful original execution
as a preserved decompiler failure. On a fixed version, the historical source
correctly stops reproducing and the reducer reports that fact. Its output is
artifacts/minimization/minimized.luau and report.json; it is bounded, rather
than a claim of globally minimal output.

These results establish the recorded modules, grammar instances and exercised
inputs under the pinned VMs. They do not certify every possible invocation,
all Roblox engine APIs, every executor format or arbitrary third-party modules.
Mandatory release validation reruns both suites and records source freshness.
