# Rc.4 local Windows review evidence

This supplement preserves measurements made with the exact Windows executable `5b1316e78fa183aafe32c46471ce31cb3601778a5650b26898e7a27743a7953d`. It is separate from clean GitHub Actions runtime, semantic, Linux and container evidence. A clean CI rebuild can have a different executable hash; these observations must not be transferred to that binary.

The maintained source commit is `8749f133897978c3d0495d85aeb88de72fe7ba7e`. Every original source, configuration, tool, fixture, runtime and asset identity recorded inside each report retains its original meaning. `member-manifest.json` lists exact member SHA-256 values, original modification times, reference checks and source identities. The original executed corpus processor is retained without EOL normalization; the earlier fc37 processor and corpus aggregate remain explicitly superseded.

The reports cover the private retained client-snapshot processing, matched native and browser measurements, one unknown-source real LocalScript adapter round trip, a decoder/opcode census, bounded publication review and the minimum-Rust check. The 35 native compressed raw reports and four browser raw benchmark reports are included and checked against their aggregate references. Existing native benchmark workspace-metadata normalization is documented in the unchanged aggregate; this packaging applies no further normalization.

Extract the archive into an empty directory and verify its entries against `member-manifest.json`. Project-relative report paths are rooted under `reports/`. Native performance raw paths are relative to `reports/docs/results/`; browser raw paths are relative to `reports/`. SHA-256 sidecars bind the whole archive. No report is a claim of broad Roblox equivalence, new test execution, universal typing, clean-Windows validation or a CI run of the local binary.

Original captured bytecode, private logs, authentication material, server-only scripts and unrelated engine/dependency source are excluded. Captured game programs were never executed. The public MM2 showcase has separate owner permission and remains in the source repository; it is not duplicated here. Runtime/extracted-package acceptance belongs to the matching runtime/evidence distribution, not this supplement. Failed strict analysis and missing contracts remain failures.

The two MSRV receipts distinguish the early sandbox-denied attempt from the successful Rust 1.85.0 Windows GNU check. Raw MSRV logs are omitted. Publication scans inspect bounded credential signatures and values without printing them and do not prove that arbitrary secrets cannot exist.

No release or Pages publication is established by this staging archive. Its durable Git publication identity must be recorded only after the actual push succeeds. A separately added reference-runtime ZIP, if present, must carry its own exact checksum and acceptance evidence; it is not a replacement for canonical CI assets.
