These four original, owned Luau modules model application work: a bounded FIFO,
reentrant signal, observable batched store and linked LRU resource cache. They
are full module sources returning exported API tables. Each separate trusted
probe exercises that API and asserts independent invariants before returning
only typed observable values; opaque exported tables/functions are not treated
as complete behavioral evidence. No module was extracted from a private game.

The test runs two explicit modes: a combined application program, and unchanged
standalone module bytecode followed by separately compiled trusted probe bytecode.
The latter prevents application compilation from inlining the module API into
the probe. Both use pinned official v6/v14 compilers and four runtime seeds under
three optimization and two debug settings (384 complete typed comparisons).
The source/probe/compiler/oracle
hashes and actual coverage are recorded in docs/results/applications.json.
