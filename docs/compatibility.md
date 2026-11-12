# Compatibility and evidence

Profiles describe a pinned serialization layout and a supported semantic subset.
They do not promise reconstruction of every program carrying that version byte.
Set `profile` to an exact ID to require its semantic format, or `auto` to select
the registered format by the version byte. The default `bytecode_encoding=auto`
recognizes the evidenced, structurally marked Roblox container and otherwise
uses upstream bytes. Unmarked opcode227 getter buffers require the explicit
`roblox_opcode227` setting. Unknown trailers remain errors. See the
[representation scope and evidence](bytecode-representations.md).

The upstream references are official source checkouts and checksummed official
compiler releases in [upstream.profiles.lock.json](../upstream.profiles.lock.json).
The old 0.654 pin remains in [upstream.lock.json](../upstream.lock.json).

| Profile | Serialization change | Compiler fixture producer | Evidence |
| --- | --- | --- | --- |
| `luau-v3` | Original supported layout, no type header or function flags | Synthetic legacy packets | Decoder regressions; no historical compiler behavioral claim |
| `luau-v4` | Type header, function flags, floor division | Synthetic legacy packets | Decoder regressions; no historical compiler behavioral claim |
| `luau-v5` | Float vector constants, reverse constant subtraction/division | Synthetic legacy packets | Decoder regressions; no historical compiler behavioral claim |
| `luau-v6` | Three-argument fast calls | Official 0.654 | Mandatory typed behavioral gate |
| `luau-v7` | Ordered prefilled table templates | Official 0.726 with explicit flags | 234 compiler fixtures |
| `luau-v8` | Integer constant tag | Official 0.726 with explicit flags | 234 fixtures; integer constants rejected |
| `luau-v9` | Native userdata atom opcodes | Official 0.730 with explicit flags | 234 fixtures; native atom callbacks rejected |
| `luau-v10` | Class shape constants and class members | Official 0.726 with explicit flags | 234 fixtures; class features rejected |
| `luau-v11` | Feedback slots, `CALLFB`, `CMPPROTO` | Official 0.726 with explicit flags | 234 fixtures; validated `CALLFB` supported, `CMPPROTO` rejected |
| `luau-v12` | Exact prototype byte boundaries, optional 64-bit cost | Official 0.730 with explicit flags | 234 compiler fixtures |
| `luau-v13` | Double precision serialized vector constants | Official 0.746 with explicit flags | 234 compiler fixtures |
| `luau-v14` | Protected-call shortcut | Official 0.746 with explicit flags | 234 fixtures; `FASTPCALL` rejected |

The modern matrix is 26 known-source scripts × three optimization settings ×
three debug settings × eight formats = 1,872 cases. The source catalog and exact
flags are in `tests/profile-fixtures/manifest.json`; compiler, source and fixture
hashes are checked. [profile-behavior.json](evidence.md) is the
actual result, including every unsuccessful reconstruction or incomplete typed
observation. A release requires **all** listed cases to pass. A first run caught
a real closure-capture bug when modern compiler allocation reused register zero;
the regression is retained in the matrix. Successful parsing and recompilation
alone are never recorded as behavioral success.

The independently run modern matrix currently passes **1,872/1,872** complete
typed comparisons: **234/234 for each of formats 7, 8, 9, 10, 11, 12, 13 and 14**.
This covers the listed source catalog under its exercised runtime inputs. It
does not establish correctness for untested source programs or unsupported
features listed below.

Run the reproducible modern gate from the workspace root:

```powershell
./scripts/setup-profiles.ps1 -BuildOracle
./scripts/generate-profiles.ps1
. ./scripts/env.ps1
cargo test --offline --test profiles
cargo test --offline --test profile_behavior modern_profiles_behavior -- --ignored --nocapture
```

Regeneration preserves the checked-in source catalog. Pass `-IncludeNewSources`
to deliberately expand it. Official CLI releases enable several fast flags by
default, so changing the version byte or relying on CLI defaults cannot reproduce
these profiles. The generator supplies and records every version-selecting flag.
The test checks the current typed-harness hash, exact oracle executable hash,
oracle revision, compiler hash, source hash and fixture hash before comparisons.

## Roblox and executor evidence

The live Madium 2.0.0 / Roblox 0.746.0.7461267 transport probe has format 14,
type encoding 3 and opcodes encoded by multiplication by 227 modulo 256.
`roblox_opcode227` applies the inverse multiplier 203 to each instruction header's
low byte while discovering instruction boundaries; it preserves every AUX word.
It does not decrypt, decompress or guess other executor containers.

The 47-byte native-getter probe decodes to a variadic main function returning an
empty table. Its original source provenance is unknown. Independently compiling
`return {}` using the pinned official 0.746 compiler matches its instructions,
operands, constants, signature, stack size, flags, line-defined value and local
metadata under all nine optimization/debug combinations. The **entire** 47-byte
packet after explicit header normalization equals the independent compiler's
packet at O0/O1/O2 with D1/D2 (six combinations); D0 emits a 38-byte packet without
line metadata. [native-probe-model.json](evidence.md) records
the comparisons. This is an independent compiler-model check, **not** a claim that the original source was obtained or
that arbitrary executor extraction has been verified. The test is
`native_probe_matches_independent_compiler_model` in `tests/profiles.rs`.
The complete bridge was subsequently verified with Madium 2.0.0 on Roblox
0.746.0.7461267: native getter → authenticated HTTP → persistent four-thread Rust
pool → reconstructed source → real client execution. The schema-2
[live report](evidence.md) contains 65 separately checked native
model observations and 20 known-source observations: four supplied format-14
programs at five inputs. They exercise binary strings, ordered print/warn calls,
captured state, trailing nils and multiple returns, errors, dynamic tables, loop
exits, Roblox attributes/methods and Vector3 component operations. These supplied
programs use the adapter's bytecode entry point; their native Roblox extraction
is not claimed. The native getter case uses the independently matched empty
table model described above.

The live observer runs seven negative collision tests and rejects three
unsupported observations. The host Rust decoder checks every complete typed
frame. The run verifies the capabilities handshake, complete/quality metadata,
out-of-order restoration and exact restoration of the original executor
function. Input/compiler/adapter/harness hashes and a unique prepared plan link
the evidence; the supplied service binary hash is operator-linked and its
package version independently matches the handshake. This is not process-image
attestation.

| Executor/runtime path | Verified behavior | Status |
| --- | --- | --- |
| Madium 2.0.0 / Roblox 0.746.0.7461267, native getter, explicit opcode227 | 47-byte independent compiler model; 65 typed observations | Tested |
| Same client, supplied official format-14 bytecode | Four owned source scripts × five inputs, including real Roblox methods | Tested |
| Madium client-created ModuleScript with assigned Source | Getter returned nil; virtual source execution does not establish native extraction | Extraction unavailable in this probe |
| Other executor/runtime combinations or containers | No independently completed client run | Untested |

Reproduce using [prepare-live-test.ps1](../scripts/prepare-live-test.ps1),
[live-test.luau](../adapter/live-test.luau) and
[verify-live-test.ps1](../scripts/verify-live-test.ps1); see the
[adapter instructions](../adapter/README.md). The source fixtures and the typed
native model bound the integration claim; a passing handshake does not certify
arbitrary program reconstruction.

## Semantic limits

Integer constants are rejected rather than rounded to floating point. Class
constants/opcodes, runtime prototype guards, protected-call shortcuts, runtime
native instructions and native userdata atom callbacks receive explicit
diagnostics. Unknown trailing prototype fields are rejected, even though the
official loader can skip them. Nonempty feedback vectors must describe actual
`CALLFB` instructions with matching slot IDs; unknown feedback kinds are rejected.

Table templates preserve the loader's insertion order, numeric-zero placeholders
and deferred nil resets. Reconstruction supports proven string-key templates;
an unsupported key or open-result layout produces an error. Vector constants
retain all serialized bits in the decoder. Emitting a vector constructor requires
the documented intrinsic environment contract; decoding a vector does not prove
that a source-level constructor can be substituted safely.

The capability handshake separates format features from per-program semantic
success and reports `complete_for_all_programs: false`. See the current validation
and limitations reports for binding, structured control flow and environment
restrictions that apply across all profiles.

The ordinary decoder gate additionally executes 29,952 deterministic byte
mutations across the modern fixture matrix under bounded resources, alongside
format-boundary, tag/version, 64-bit payload and AUX-preservation regressions.
This measured mutation run complements the fuzz target; it is not a claim of an
unbounded libFuzzer campaign.
