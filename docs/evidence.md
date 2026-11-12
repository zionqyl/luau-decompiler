# Release evidence

Generated reports are working output under ignored `docs/results` and `artifacts`. They are not parallel copies of maintained source. The release driver creates three distributions: a compact runtime, a contributor source snapshot, and a versioned evidence archive containing each current report once.

The release index and SHA-256 sidecars bind all three archives. Runtime manifests bind shipped files and the validated executable/analyzer/definition identities. The evidence archive preserves the original semantic-gate timestamps and records whether matching evidence was reused for packaging; prose-only changes do not retimestamp semantic tests.

## Historical rc.1 evidence

The exact previous 194 report files, including recorded failures and supplemental post-ZIP checks, are preserved in [0.4.0-rc.1-evidence.zip](../evidence/releases/0.4.0-rc.1-evidence.zip). The [manifest](../evidence/releases/0.4.0-rc.1-manifest.json) lists every original byte count and SHA-256. The archive is durable repository data, independent of expiring CI storage. Its 12,965,108 bytes replace 34,556,756 bytes of active generated files. Observation dates and failure classifications inside the archived reports remain unchanged.

Required historical inputs are restored from this hash-verified archive before validation. Current behavioral and strict reports regenerate from their actual inputs. No failed native transport attempt becomes a successful compatibility claim because it is archived or restored. Small immutable source/observation fixtures under `fixtures` retain their existing consumer checks.

## Current acceptance

Run the maintained [validation procedure](validation.md). The release driver's comprehensive runtime acceptance runs once at the extracted archive boundary, including missing-analyzer/strict-benchmark failure behavior. Installer scenarios cover a distinct ownership, update and rollback boundary. An installation diagnosis runs one small known verified-typed operation; it does not run the corpus.

Detailed performance, source profiles, configurations, tool hashes, original observations and known limitations belong in the versioned evidence asset. A passing gate demonstrates only its documented supported scope and finite tested inputs.

The local Windows review archive below uses member prefix `reports/docs/results/`: `madium-live-rc4.json` and its redacted driver, `client-corpus-rc4.json` and final provenance, preserved superseded processor receipts, and native/browser reference measurements. These are local-reference reports. The clean-CI release evidence contains its own regenerated gate/runtime/installer reports; local corpus, performance and live reports must not be assumed to exist in that different archive.

## Historical rc.2 evidence

The exact rc.2 evidence ZIP is preserved at [0.4.0-rc.2-evidence.zip](../evidence/releases/0.4.0-rc.2-evidence.zip), with its [entry manifest](../evidence/releases/0.4.0-rc.2-manifest.json). It contains 84 entries in 3,049,202 bytes; original timestamps, outcomes and identities remain historical. Browser static-export acceptance is independent of native semantic acceptance. Original client byte buffers and unrelated Roblox engine/dependency source remain excluded from public archives. The user subsequently supplied MM2-owner permission for the scoped game example publication; current scope, rights and per-file outcomes are recorded separately from these historical receipts in the client-corpus guide.

## Rc.4 reference and public evidence boundaries

The local Windows reference build is executable `5b1316e7…` at source `05bd2676`. Its compact runtime passed nine extracted-package checks and all 29 installer scenarios; its local source/runtime/evidence ZIPs carry matching indexes and checksums. These results do not certify a different clean-CI executable. Later clean-CI output has its own source, binary and report identities.

The earlier [controlled-program performance supplement](https://github.com/zionqyl/luau-decompiler/tree/40504619ad34085c9ff6dad127925e3ee3d7f692) remains an immutable, narrower controlled-program supplement outside the ordinary source branch. It contains the two unchanged aggregates and all 35 native raw reports. It intentionally omits all four browser raw reports and contains no client, live-executor, corpus or private-session report. The subsequently authorized review archive below supplies the broader report closure.

The user explicitly authorized the audited [local Windows review archive](https://raw.githubusercontent.com/zionqyl/luau-decompiler/991fbe8f7aac6603ae51c4f3000815e084a891d8/luau-decompiler-0.4.0-rc.4-local-windows-review.zip). Public HTTP 200 and its 2,019,266-byte download were verified on 2026-11-12 at 20:26:30 UTC against SHA-256 `46070201d38b09f675660adbc5a82df2c469c73a9f03201dd012b96c09cff868`. The immutable [member manifest](https://github.com/zionqyl/luau-decompiler/blob/991fbe8f7aac6603ae51c4f3000815e084a891d8/member-manifest.json) binds the included aggregate/provenance reports, all 35 native raw performance reports, all four browser raw benchmark reports and the redacted first-party live driver. Original bytecode, private logs, credentials and unrelated game code are excluded.

These members identify local reference executable `5b1316e7`, not the shipped `1bcace5d` executable. Browser evidence records the actual served runtime; its full authenticated CI export was unavailable, so the actual served assets were independently observed instead. The [browser guide](browser.md) preserves that distinction. Clean Windows/Linux CI subsequently passed and the [rc.4 release](https://github.com/zionqyl/luau-decompiler/releases/tag/v0.4.0-rc.4) is now public.

## Published rc.4 artifacts

Source `6a84b6248681552ff1746347caf24b9e64e47995` passed canonical CI run `43307786774`. Publisher `43312524140` reused those exact artifacts; the unreleased-tag correction was explicitly authorized and its original commit remains in main history. Public `runtime-publication.json` and `publication.json`, each with a checksum sidecar, bind the source, evidence run, native assets and anonymously pulled image digest.

| Public artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| Windows runtime | 5,463,414 | `f9091c72f0da9011ab36d667c57ea876f428390b4de3c28d7b14f36c45917f71` |
| Linux runtime | 4,378,300 | `4e2e9ad72045711fe010be25496b5b6c74e884dc263e4ea5f029b0fe88759bd1` |
| Source snapshot | 19,230,744 | `0fe09ebb94f86a3b9b7882b220832145296ee9b175797171d139f00f5924889c` |
| Clean-CI evidence | 1,210,667 | `ec41cf74cf9d528dae472c2c619d43bfe6a7003314022005b21e09017ed2a9de` |

Anonymous downloads, all 2,875 source-manifest entries, all source/evidence ZIP CRCs and required report hashes were checked. All 297 showcase documents have one canonical header; 292 contain the strict directive and five are faithful outputs without it. A directive never establishes strict success. The shipped CLI produced the exact checked-in README bytecode example (SHA-256 `d4dc78026f81297cffb3a23f2f203c58d5fc99cbf53e70356f8fdb1ca7db06eb`).

The public Windows installation was additionally tested from a separate Unicode/space destination with no persistent PATH change, using the real tag-pinned script and release assets. Diagnosis, verified bytecode, source/stdin, HTTP 200/strict-negative 422, graceful shutdown and owned uninstall passed. This focused download/installation boundary reused the CI semantic/runtime/installer results rather than running those matrices again. Linux artifact/report verification was read-only on Windows; Linux execution and direct-container tests occurred on the recorded clean Ubuntu runner.

## Distribution size and retained consumers

The retained local rc.3 Windows runtime was 5,247,432 bytes; the published clean-CI rc.4 runtime is 5,463,414 bytes, an increase of 215,982 bytes (4.1%). Source ZIPs grew from 18,337,001 to 19,230,744 bytes (4.9%). These artifacts have different build provenance; the figures are observed sizes, not a controlled compiler or compression improvement claim.

Excluding the generated source manifest, the archived source tree grew from 2,564 files/23,451,659 bytes to 2,875 files/29,239,609 bytes. The 297 authorized showcase documents account for 5,022,113 bytes. Runtime packages exclude that corpus and detailed review evidence. Historical rc.1/rc.2 archives remain active offline fixture/provenance inputs and were preserved; no fixture deletion or source-tree shrink is claimed. Build caches, private captures and prepared review archives stay outside the active tracked source.

## Prepared post-publication supplements

Three additional audited archives are ready locally; their public upload awaits explicit approval. They are separate from the original clean-CI release assets and the previously authorized local-reference review archive.

| Supplement | Bytes | SHA-256 |
| --- | ---: | --- |
| Published Windows performance | 1,655,329 | `8663d28346fcc290e56868f4a55e4397c29848310f731264b28a6ad8c1440e8c` |
| Durable browser proof and notice closure | 2,383,417 | `d5edc1bd1f5183eec472ba859118d2bd5ff328cff85ff0a374eb0f478b8ac7cb` |
| Public validation and shipped-binary corpus provenance | 25,831 | `775db5f2714cd49566e376b80ade159a85cf37614bd59be0027d20e463e0aae7` |

They preserve report identities and original timestamps, with explicitly mapped workspace-path normalization in public copies. They exclude original capture bytecode, credentials, private logs and unrelated game-source bodies. Original measurements remain unchanged. The browser proof includes the actual served assets and their target-filtered 74-file notice closure.

The subsequent [read-only published-bootstrap workflow](https://github.com/zionqyl/luau-decompiler/actions/runs/43320705361/job/131540297276) passed six assertions using the actual published TAR/image. Its public notice contains status, stage and case count. The detailed report remains a restricted CI artifact and is outside these already frozen archives. No public report-upload permission or release-write capability was used for that test.
