# Install and use offline

Windows x64 is the supported installer target. The runtime contains the Rust executable, pinned analyzer and manifest, Roblox definitions, a small check fixture, and the required notices. Ordinary processing needs no Roblox, executor, account, server, Git, Rust, Python, CMake, or C++ compiler.

## Current distribution status

The configured publisher is `zionqyl/luau-decompiler`, recorded in [release.json](../release.json). A configured repository is not proof of a published asset. Use the matching local runtime/checksum files while public release availability is unverified; the release assessment records actual publication evidence. The remote bootstrap below is inactive until the script and matching assets have been published.

## Windows: install a downloaded runtime

Keep `install.ps1`, the runtime ZIP, and its `.sha256` sidecar together. The installer is also included inside the runtime ZIP. From their directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./install.ps1 -Archive ./luau-decompiler-0.4.0-rc.4-windows-x64.zip -Preview
```

The default destination is `%LOCALAPPDATA%\LuauDecompiler`. Use `-Destination 'D:\My applications\LuauDecompiler'` to choose another location. `-NoPath` leaves persistent PATH unchanged. The installer prints an immediately usable executable path; a terminal started from an older environment may need refreshing before the command shim is discoverable.

```powershell
luau-decompile doctor --json
luau-decompile decompile input.luau --policy verified-typed -o output.luau --quality-report quality.json
```

Use the printed executable path in place of `luau-decompile` until your shell sees the PATH update. File input preserves bytes. For stdin, the caller must send UTF-8 source or unchanged bytecode bytes; PowerShell 5 text pipelines can transcode Unicode and are unsuitable for arbitrary binary data. Prefer file input when unsure.

`verified-typed` requires the exact final source to pass the pinned parser/compiler/strict analyzer and meaningful-typing requirements. A rejected quality result keeps faithful source and diagnostics and exits unsuccessfully. `--policy faithful --no-validation` is an explicit faster choice. Supported formats and source restrictions are reported by `capabilities` and described in [source input](source-input.md).

## Updates, rollback and removal

A current installed updater installs management files from the newly verified runtime payload. It never promotes its own invoking script in place of the release's `install.ps1` and `release.json`. An explicit `-Version 0.4.0-rc.4 -Preview` selects that candidate; omitting `-Preview` admits stable releases only. Online resolution selects one release and downloads its matching runtime/checksum pair. Local `-Archive` installation works without network access.
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

## Remote bootstrap after publication

This command names the real configured source location but is not operational until that script and matching assets are published:

```powershell
& ([scriptblock]::Create((Invoke-RestMethod https://raw.githubusercontent.com/zionqyl/luau-decompiler/main/scripts/install.ps1))) -Repository zionqyl/luau-decompiler -Preview
```

Linux installation and the prebuilt-container path require actual Linux/container acceptance and publication. Those environments are unavailable in this session. See [self-hosting](hosting.md), [evidence](evidence.md), and [contributor setup](development.md).

## Interrupted first installation

Before creating staging or provisional version files, the current installer writes a durable bootstrap transaction under the installation lock. Retry recovers only the exact staging identity and manifest-owned provisional version recorded by that transaction. Unknown staging-like folders, changed ownership markers, reparse points and modified payload files are preserved. An activation journal takes precedence and completes before bootstrap cleanup or ordinary metadata admission. Failed downloads need neither manual staging deletion nor an existing successful installation.

The focused `scripts/test-install.py --bootstrap-only` profile terminates real installer processes at staging, extraction and version-move boundaries, plus during a real partial HTTP archive download. It also rejects an unrelated staging-like directory without removing it. The final extracted-package owner includes these cases together with existing update, activation, rollback, ownership and uninstall scenarios.
