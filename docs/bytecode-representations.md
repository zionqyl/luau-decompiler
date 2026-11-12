# Bytecode representations

The serialized Luau version, opcode encoding, and outer representation are separate facts. Reconstruction uses the same validated decoder after selecting a supported representation. Standard Lua/LuaJIT, encrypted or compressed executor packets, arbitrary Base64, and unknown trailers are not speculative alternatives.

| Setting | Accepted representation |
| --- | --- |
| `auto` (default) | Raw upstream Luau, or the marked signed representation below. Unmarked opcode227 is not guessed. |
| `upstream` | Raw upstream opcode bytes; any unconsumed trailer rejects. |
| `roblox_opcode227` | Explicit fixed opcode mapping, with either no trailer or the complete marked representation below. Unknown trailers reject. |
| `roblox_signed_74171870` | Require the complete observed signed representation, version 9 or 14, both marker equations, and an exactly validated body boundary. |

Opcode227 reverses multiplication by 227 modulo 256 using multiplier 203 on instruction opcode bytes only. AUX words, constants, metadata, and original buffers remain unchanged. An explicit getter contract can justify that mapping for an unmarked buffer; successful compilation cannot.

## Observed signature container

For Roblox `0.747.0.7471481`, extracted through Madium `2.0.0`, the observed layout is a complete serialized opcode227 Luau body followed by 24 bytes. Let `S` be the final 24 bytes and `w` the little-endian word at `S[0..4]`:

| Offset | Size | Interpretation and check |
| --- | --- | --- |
| `0` | 16 | Opaque signature bytes; preserved verbatim. |
| `16` | 4 | Little-endian word must equal `w XOR 0x74171870`. |
| `20` | 4 | Little-endian word must equal `w XOR 0x016ac432`. |

Both equations are required before content detection selects this representation. Parsing must then consume exactly the bytes preceding that trailer, ending after a valid main-prototype index. Prototype boundaries, operands, AUX words, references, limits, and instruction semantics retain their existing checks. A wrong marker, extra byte, truncated trailer, unsupported version, malformed body, or unknown reached instruction cannot become successful reconstruction by removing bytes.

The suffix interpretation is supported by two independent kinds of evidence. [Dawn's implementation documentation](https://dawn.rip/docs#bytecode-signer) describes a 16-byte signature and two XOR marker words after Roblox Luau bytecode, while documenting different constants for its October build. Our retained capture independently verified both equations in all 23,629 trailers, across 23,363 version-9 and 266 version-14 buffers. The other sixteen buffers have no such trailer. All 23,645 original SHA-256 hashes were checked. The original upstream [serializer](https://github.com/luau-lang/luau/blob/12a6ba75883272c79b66b59815efef4c574196f6/Bytecode/src/BytecodeBuilder.cpp) ends at the main-prototype index; the suffix is not an omitted upstream field.

This establishes an observed structural signature-container profile, not signature authenticity. No cryptographic verification key, signing model, or complete checker for this build is available. The two marker equations are structural redundancy, not a message authentication code. Changes to opaque signature bytes can remain structurally valid, and the report explicitly states `not_verified`. The decompiler neither forges signatures nor loads captured programs to test them.

## Provenance and boundaries

Structured results include `representation.profile`, the selected opcode encoding, encoded-body length and SHA-256, the exact trailer bytes, evidence, and authenticity status. `input_sha256` still hashes the exact original complete buffer. No mutable normalized copy replaces original input, and body offsets refer to that input. Configuration and original input identities remain part of caches.

Fresh read-only getter probes inspected a game LocalScript, a game ModuleScript, and an engine ModuleScript. Their script dumps used version 14 or 9; separately reserializing the returned main function used version 13. Returned functions were never invoked. A controlled known-source script compiled by the normal Roblox engine and available through the same getter was not present, so this probe does not establish source equivalence. Controlled compiler-backed fixtures and behavioral oracles remain the semantic gate; captured game programs are never executed.

The profile is scoped to the observed marker/build family. Another build or getter may use a different representation. Invalid or ambiguous inputs remain errors, and accepting this container does not imply support for every instruction or useful typing without external context.
