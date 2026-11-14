# Install and use offline

Windows x64 is the supported transactional-installer target. Linux x64 runtime/container acceptance passed clean Ubuntu 24.04 CI; its publication and deployment boundaries are described in [hosting](hosting.md#evidence-boundary-for-this-candidate). The runtime contains the Rust executable, pinned analyzer and manifest, Roblox definitions, a small check fixture, and the required notices. Ordinary processing needs no Roblox, executor, account, server, Git, Rust, Python, CMake, or C++ compiler.

## Current distribution status

The [rc.5 release](https://github.com/zionqyl/luau-decompiler/releases/tag/v0.4.0-rc.5) publishes matching Windows/Linux runtimes, source, evidence, indexes and checksum sidecars from source `090c1e64635c6af7344973a283b164e9e5f944d8`. Its [Windows](https://github.com/zionqyl/luau-decompiler/actions/runs/43545344892/job/132295248819) and [Linux](https://github.com/zionqyl/luau-decompiler/actions/runs/43545344892/job/132295248434) canonical CI jobs passed. The public Windows ZIP is **5,577,821 bytes**, SHA-256 `41b45bbdd4e13fc6e2f46e0a682a772efe218d592bc227e26c412c1da3bc2371`; [runtime-publication.json](https://github.com/zionqyl/luau-decompiler/releases/download/v0.4.0-rc.5/runtime-publication.json) records the matching assets.

The actual public online installation used a separate Unicode/space destination with `-NoPath`; its first attempt hit the one-second atomic bootstrap deadline. The owned intent was preserved and the exact same command succeeded on retry. That initial attempt is a recorded failure, not a clean first-pass installation. The retry passed diagnosis, and the installed runtime then passed all ten runtime acceptance cases, including verified bytecode, CLI/stdin, HTTP quality rejection and exact output attribution. The main and tag-pinned installer bytes matched. Ordinary installation requires no account or developer tools; the default adds the owned per-user command directory to PATH.

## Windows: one-command installation

```powershell
& ([scriptblock]::Create((Invoke-RestMethod https://raw.githubusercontent.com/zionqyl/luau-decompiler/v0.4.0-rc.5/scripts/install.ps1))) -Repository zionqyl/luau-decompiler -Version 0.4.0-rc.5 -Preview
```

The version and preview channel are explicit. The installer resolves one release, verifies its runtime checksum and every manifest file, then runs a small verified-typed diagnosis before activation. Its streaming SHA-256 implementation does not depend on the optional PowerShell `Get-FileHash` function.

## Windows: install a downloaded runtime

Keep `install.ps1`, the runtime ZIP, and its `.sha256` sidecar together. The installer is also included inside the runtime ZIP. From their directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./install.ps1 -Archive ./luau-decompiler-0.4.0-rc.5-windows-x64.zip -Preview
```

The default destination is `%LOCALAPPDATA%\LuauDecompiler`. Use `-Destination 'D:\My applications\LuauDecompiler'` to choose another location. `-NoPath` leaves persistent PATH unchanged. The installer prints an immediately usable executable path; a terminal started from an older environment may need refreshing before the command shim is discoverable.

```powershell
luau-decompile doctor --json
luau-decompile decompile input.luau --policy verified-typed -o output.luau --quality-report quality.json
```

Use the printed executable path in place of `luau-decompile` until your shell sees the PATH update. File input preserves bytes. For stdin, the caller must send UTF-8 source or unchanged bytecode bytes; PowerShell 5 text pipelines can transcode Unicode and are unsuitable for arbitrary binary data. Prefer file input when unsure.

`verified-typed` requires the exact final source to pass the pinned parser/compiler/strict analyzer and meaningful-typing requirements. A rejected quality result keeps faithful source and diagnostics and exits unsuccessfully. `--policy faithful --no-validation` is an explicit faster choice. Supported formats and source restrictions are reported by `capabilities` and described in [source input](source-input.md).

## Updates, rollback and removal

A current installed updater installs management files from the newly verified runtime payload. It never promotes its own invoking script in place of the release's `install.ps1` and `release.json`. An explicit `-Version 0.4.0-rc.5 -Preview` selects that candidate; omitting `-Preview` admits stable releases only. Online resolution selects one release and downloads its matching runtime/checksum pair. Local `-Archive` installation works without network access.
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA/LuauDecompiler/install.ps1" -Doctor
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA/LuauDecompiler/install.ps1" -Rollback
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA/LuauDecompiler/install.ps1" -Uninstall
```

For a custom destination, pass the same `-Destination` to these operations. Updates verify the archive, every runtime file, matching component version, and a small verified-typed diagnosis before beginning activation. Interrupted or corrupt downloads leave the working runtime active. Previous verified payloads remain available for rollback. Rollback selects the earlier runtime while retaining the current management scripts, so rollback does not discard newer recovery logic.

Activation writes a bounded journal before changing management files or the active pointer. Pointer, script and ownership writes are atomic; restart completes the same verified transaction under the installation lock before checking the potentially interrupted metadata. Rerun the current installer or its `-Doctor` operation after a process interruption. Ownership is rechecked against the stored metadata snapshot after download and diagnosis; a file changed or created during those phases is never adopted as previously owned. Recovery validates the payload and every intended file hash; an intervening user modification blocks recovery and remains untouched. The lock file persists to avoid a deletion/recreation race between concurrent management operations.

Removal deletes unchanged owned files and the owned PATH entry; it preserves modified files, user configuration, inputs and outputs. A small ownership marker remains for safe reinstallation. A preserved or otherwise unowned management filename is not permission to overwrite it after uninstall: reinstallation refuses that collision. Move the file explicitly or choose another destination. Modified files inside an older runtime remain preserved when a new version directory is installed.

## Upgrading an rc.2 installed updater

An unmodified rc.2 updater copies its own old management script after staging a newer runtime. No new release can retroactively change that already-running code. Prefer the new release's checksummed archive and included installer for the upgrade command shown above.

If an older updater has already activated the new runtime, run the new installer stored inside that verified active version once:

```powershell
$installation = "$env:LOCALAPPDATA/LuauDecompiler"
$active = (Get-Content -LiteralPath "$installation/current" -Raw).Trim()
powershell -NoProfile -ExecutionPolicy Bypass -File "$installation/$active/install.ps1" -Destination "$installation" -RepairManagement
```

This explicit migration verifies the active runtime and its diagnosis, promotes that payload's management bytes, and journals the change. It also repairs an rc.2 activation interrupted after its pointer changed but before ownership metadata caught up. In that legacy case the unknown original archive hash remains absent; the recovered active manifest hash is recorded instead. The repair refuses modified management files rather than overwriting them. It requires the installer inside the active payload, not an unrelated script. Native `doctor` remains a read-only diagnostic; it does not perform hidden management migration.

Checksums and manifests establish integrity relative to the configured publisher; they are not signing keys. The installer rejects unowned nonempty destinations, archive traversal, duplicate entries, symbolic links, excessive sizes and mismatched component versions.

## Linux and container downloads

The same [release](https://github.com/zionqyl/luau-decompiler/releases/tag/v0.4.0-rc.5) provides `luau-decompiler-0.4.0-rc.5-linux-x64.tar.gz` and its checksum. The Linux runtime and exact container passed clean Ubuntu 24.04 CI at the source identity above. The published TAR is 4,490,645 bytes, SHA-256 `c84308311ac75c035d2c47c07f22ffa83da6f863c85ae7c918be0ed4cd2648d7`. Linux currently uses the portable TAR rather than the Windows transactional installer.

The published image's anonymous digest pull passed. [Self-hosting](hosting.md) documents the current image, bootstrap prerequisites and evidence boundaries. The focused Linux bootstrap test is historical rc.4 evidence; it was not rerun against rc.5. Successful distinct-image upgrades/rollback, actual Windows Docker bootstrap and HTTPS remain separate untested boundaries.

## Interrupted first installation

Before creating staging or provisional version files, the current installer writes a durable bootstrap transaction under the installation lock. Retry recovers only the exact staging identity and manifest-owned provisional version recorded by that transaction. Unknown staging-like folders, changed ownership markers, reparse points and modified payload files are preserved. An activation journal takes precedence and completes before bootstrap cleanup or ordinary metadata admission. Failed downloads need neither manual staging deletion nor an existing successful installation.

The focused `scripts/test-install.py --bootstrap-only` profile terminates real installer processes at staging, extraction and version-move boundaries, plus during a real partial HTTP archive download. It also rejects an unrelated staging-like directory without removing it. The final extracted-package owner includes these cases together with existing update, activation, rollback, ownership and uninstall scenarios.

## Rc.5 atomic-write recovery

The rc.5 installer records a bounded write intent in the exclusively held installation lock and flushes it before creating a transaction temporary file. Retry recovers only that exact owned temporary, after checking its path, identity and bytes. Incomplete intents created before any temporary file are safely cleared. Modified temporary files and unrelated staging-like files remain untouched. This covers interruption inside journal and ownership-marker writes, separately from interrupted download and activation tests. Streaming hashes were already present in the published rc.4 installer; rc.5 does not claim to repair that completed change again.

## Windows publication and file contention

The current installer checks the checksum, manifest and version in staging, then records ownership and moves the payload to a provisional version directory before diagnosis. Activation still requires diagnosis to pass. This avoids renaming the directory from which a doctor/analyzer process has just run. Healthy existing versions are diagnosed once.

Atomic replacement retries only Windows sharing/locking codes 32/33 and code 1175, with at most eight attempts under one one-second scheduling deadline. Each attempt checks the unchanged prior target and complete intended candidate. Synchronous operating-system I/O cannot be forcibly interrupted. The [Microsoft ReplaceFile contract](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-replacefilew) distinguishes unchanged-name failure 1175 from partial-publication failures 1176/1177; these latter states are never retried as ordinary contention.

Missing or modified prior targets, ambiguous legacy intents without a prior hash, and partial native publication retain the owned intent and candidate for diagnosis. They are not silently deleted or automatically replayed. A legacy intent can be cleared automatically only when its target already equals the intended bytes. These exceptional states can require manual resolution; universal interrupted-update recovery is not claimed. Ordinary hard-kill, contention, update and user-file preservation cases have separate recorded tests.
