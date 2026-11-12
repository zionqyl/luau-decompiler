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

The local Windows reference build is executable `5b1316e7…` at source `05bd2676`. Its compact runtime passed nine extracted-package checks and all 29 installer scenarios; its local source/runtime/evidence ZIPs carry matching indexes and checksums. These results do not certify a different clean-CI executable. Later clean-CI output has its own source, binary and report identities.

The earlier [controlled-program performance supplement](https://github.com/zionqyl/luau-decompiler/tree/40504619ad34085c9ff6dad127925e3ee3d7f692) remains an immutable, narrower controlled-program supplement outside the ordinary source branch. It contains the two unchanged aggregates and all 35 native raw reports. It intentionally omits all four browser raw reports and contains no client, live-executor, corpus or private-session report. The subsequently authorized review archive below supplies the broader report closure.

The user explicitly authorized the audited [local Windows review archive](https://raw.githubusercontent.com/zionqyl/luau-decompiler/991fbe8f7aac6603ae51c4f3000815e084a891d8/luau-decompiler-0.4.0-rc.4-local-windows-review.zip). Public HTTP 200 and its 2,019,266-byte download were verified on 2026-11-12 at 20:26:30 UTC against SHA-256 `46070201d38b09f675660adbc5a82df2c469c73a9f03201dd012b96c09cff868`. The immutable [member manifest](https://github.com/zionqyl/luau-decompiler/blob/991fbe8f7aac6603ae51c4f3000815e084a891d8/member-manifest.json) binds the included aggregate/provenance reports, all 35 native raw performance reports, all four browser raw benchmark reports and the redacted first-party live driver. Original bytecode, private logs, credentials and unrelated game code are excluded.

These report members identify the local `5b1316e7…` reference evidence, not a clean-CI executable or a successful native release publication. The separate published-browser evidence records the actual served runtime and source identities, while the authenticated full CI export archive was unavailable. The [browser guide](browser.md) preserves that distinction. The latest Windows CI at `def1…` failed final runtime installer acceptance. Correction of the unreleased tag is authorized but awaits matching green CI; native release and registry publication still require their actual online acceptance.
