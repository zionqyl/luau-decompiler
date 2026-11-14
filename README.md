# v0.4.0-rc.5 local comparison evidence

[Download the audited comparison archive](luau-decompiler-0.4.0-rc.5-current-local-comparison-review.zip) | [SHA-256](luau-decompiler-0.4.0-rc.5-current-local-comparison-review.zip.sha256) | [Member manifest](member-manifest.json)

This immutable review snapshot covers local Rust-engine correctness, actual generated-output quality, native performance and browser-local processing. It is separate from runtime releases and ordinary source packages.

Source commit: `6c45359b98dc878c2688f468064d6988687117f9`. Local engine: `36c81f2589bda731036dd505886d6676e67bca2f759bf0789d5b08e4feb8cfb4`. Portable engine text: `29427015a45d9f790d99bd352233ff71561bd48537be3d9cbfd707c589991ec6`.

The ZIP contains 14 members: three exact current comparison reports, portable configurations, compact identities/validation receipts, README, manifest and privacy audit. It contains no source code, captured bytecode, logs, screenshots, credentials, machine-specific paths, binaries or old rc.4 supplemental payloads. The original reports and observed failures remain unchanged.

Button and InventoryService remain unverified; Item is data only. No captured game script was executed. Native runtime/installer acceptance and publication are separate boundaries, not certified by this snapshot. See the [current release assessment](https://github.com/zionqyl/luau-decompiler/blob/main/docs/release-candidate.md) for their status and the archive README for measurement limits.
