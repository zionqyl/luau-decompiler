# Release evidence

Generated reports are working output under ignored `docs/results` and `artifacts`. They are not parallel copies of maintained source. The release driver creates three distributions: a compact runtime, a contributor source snapshot, and a versioned evidence archive containing each current report once.

The release index and SHA-256 sidecars bind all three archives. Runtime manifests bind shipped files and the validated executable/analyzer/definition identities. The evidence archive preserves the original semantic-gate timestamps and records whether matching evidence was reused for packaging; prose-only changes do not retimestamp semantic tests.

## Historical rc.1 evidence

The exact previous 194 report files, including recorded failures and supplemental post-ZIP checks, are preserved in [0.4.0-rc.1-evidence.zip](../evidence/releases/0.4.0-rc.1-evidence.zip). The [manifest](../evidence/releases/0.4.0-rc.1-manifest.json) lists every original byte count and SHA-256. The archive is durable repository data, independent of expiring CI storage. Its 12,965,108 bytes replace 34,556,756 bytes of active generated files. Observation dates and failure classifications inside the archived reports remain unchanged.

Required historical inputs are restored from this hash-verified archive before validation. Current behavioral and strict reports regenerate from their actual inputs. No failed native transport attempt becomes a successful compatibility claim because it is archived or restored. Small immutable source/observation fixtures under `fixtures` retain their existing consumer checks.

## Current acceptance

Run the maintained [validation procedure](validation.md). The release driver's comprehensive runtime acceptance runs once at the extracted archive boundary, including missing-analyzer/strict-benchmark failure behavior. Installer scenarios cover a distinct ownership, update and rollback boundary. An installation diagnosis runs one small known verified-typed operation; it does not run the corpus.

Detailed performance, source profiles, configurations, tool hashes, original observations and known limitations belong in the versioned evidence asset. A passing gate demonstrates only its documented supported scope and finite tested inputs.

Current rc.4 evidence uses archive member prefix `reports/docs/results/`. The script-target receipt is `madium-live-rc4.json`; its redacted first-party driver is `rc4-live-script-driver.luau.gz`. Corpus coverage and final processing identities are `client-corpus-rc4.json` and `client-corpus-rc4-final-provenance.json`. The separate `client-corpus-rc4-provenance.json` and `rc4-corpus-processor.py.gz` preserve the superseded fc37 processing-source receipt. Read each report's executable and scope rather than transferring results across binaries. These generated reports are shipped once in the matching versioned evidence archive, not as working-directory links in Git. The [candidate assessment](release-candidate.md) records current packaging and publication status.

## Historical rc.2 evidence

The exact rc.2 evidence ZIP is preserved at [0.4.0-rc.2-evidence.zip](../evidence/releases/0.4.0-rc.2-evidence.zip), with its [entry manifest](../evidence/releases/0.4.0-rc.2-manifest.json). It contains 84 entries in 3,049,202 bytes; original timestamps, outcomes and identities remain historical. Browser static-export acceptance is independent of native semantic acceptance. Original client byte buffers and unrelated Roblox engine/dependency source remain excluded from public archives. The user subsequently supplied MM2-owner permission for the scoped game example publication; current scope, rights and per-file outcomes are recorded separately from these historical receipts in the client-corpus guide.

## Rc.4 reference and public evidence boundaries

The local Windows reference build is executable `5b1316e7?` at source `05bd2676`. Its compact runtime passed nine extracted-package checks and all 29 installer scenarios; its local source/runtime/evidence ZIPs carry matching indexes and checksums. These results do not certify a different clean-CI executable. Later clean-CI output has its own source, binary and report identities.

The [controlled-program performance supplement](https://github.com/zionqyl/luau-decompiler/tree/40504619ad34085c9ff6dad127925e3ee3d7f692) is publicly downloadable from an immutable commit outside the ordinary source branch. It contains the two unchanged aggregates and all 35 native raw reports. All four browser raw reports are explicitly withheld, with their original hashes retained, because some contain capture-availability metadata. No client, live-executor, corpus or private-session report is included.

The broader local corpus/live review archive remains unpublished pending explicit provenance-publication approval. Its report member names above identify the local reference evidence; they must not be assumed present in a clean-CI release archive. The separate published-browser evidence records the actual served runtime and source identities, while the authenticated full CI export archive was unavailable. The [browser guide](browser.md) preserves that distinction. Native release and registry publication remain pending the matching validated tag and actual online acceptance.
