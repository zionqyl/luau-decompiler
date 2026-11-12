# Typed official-VM observations

All integer lengths and raw IEEE bit patterns are little endian. Strings and buffers are arbitrary bytes; no UTF-8 decoding or newline normalization is performed. Scalar values are typed, never compared through `tostring`.

`LOBS/1`: bytes `LOBS`, version byte `1`, complete byte `0/1`, u32 event count, ordered events, outcome byte, terminal tuple. An event is kind byte (`1` print call, `2` warn call) followed by a tuple. A tuple is u32 value count followed by values. The terminal tuple preserves exact return count and trailing nils. Outcome is `0` return, `1` execution error, `2` load error, `3` oracle/probe failure, `4` execution deadline. Errors require exactly one typed error value. Exit status zero means a complete protocol frame was written, not that the program succeeded. Nonzero means runner/transport failure.

Value tags: `0` nil; `1` boolean plus byte 0/1; `2` number plus eight IEEE754 bytes; `3` string plus u32 byte count and bytes; `4` vector plus component-count byte 3/4 and that many f32 bit patterns; `5` buffer plus u32 identity, u32 byte count and bytes; `6` opaque reference plus VM-type byte and u32 identity. Reference IDs are assigned by first observation and kept alive to prevent pointer reuse. Opaque state/call behavior is not verified: any opaque observation forces complete=false and cannot count as success. Buffer identity and snapshots preserve aliasing and ordered mutations. NaN payload/sign, signed zero, infinities, binary strings and tuple boundaries remain distinct.

Print records raw typed arguments before exactly the conversions performed by upstream `print`, preserving `__tostring` effects without serializing through their results. Returning an object never invokes `__tostring`. `warn` is a harness-provided equivalent capture hook; upstream 0.654 does not supply Roblox's logger. Raw error values, including any VM-added source prefix, are preserved and compared exactly. Different source-location strings are a mismatch rather than silently normalized. Program effects not passed through the capture hooks need explicit known-source probes; opaque returns are incomplete, not inferred equivalent.

`LARG/1`: bytes `LARG`, version `1`, then one tuple. Argument tags use the scalar/vector encoding above; buffer arguments omit the identity field and allocate fresh buffers. Opaque arguments are unsupported. The runner accepts `vm-runner BYTECODE [--args ARGS.bin] [--probe PROBE.bc]`. A probe is trusted separately compiled bytecode invoked with the original script's full result tuple, allowing application-specific function/table probes without recompiling the original input. Probe load/execution errors are harness failures, not program errors.

Frames are capped at 16 MiB, events at 100,000, tuple values at 65,536, typed arguments at 4,096, decoded values at one million, VM live heap at 64 MiB and execution at five seconds. Unknown tags, noncanonical flags/bools, truncation and trailing bytes are rejected. A timeout, malformed frame, unsupported observation or oracle limit cannot count as complete behavioral success.

The runner accepts `--fastpcall true|false` only when its pinned VM exposes the
`LuauFastpcall` runtime flag. `--runtime-flags` reports its availability and default
value. The option does not alter the wire protocol or default settings of other
tests. Protected-call feature validation executes original and rebuilt bytecode
with the flag explicitly enabled and disabled; merely containing opcode 89 does
not prove that its fast runtime path ran.

`--repeat-entry 1..16` keeps the same loaded root closure and environment alive
and invokes that closure repeatedly. Each call receives fresh decoding of the
same LARG/1 packet. Effects from all calls remain ordered; the terminal tuple is
the last call's full return tuple, followed by the existing optional trusted
probe. An earlier runtime error stops the sequence and remains the terminal
error. The five-second deadline and observation/memory budgets cover the entire
sequence. An explicit stderr invocation count proves that a requested sequence
was actually completed. This differs from a probe repeatedly calling a returned
closure, and neither is counted as multiple distinct source programs.
