param([switch] $PortableToolchain, [switch] $BuildOracle)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
Push-Location $taskRoot
try {
    $lock = Get-Content -LiteralPath upstream.lock.json -Raw | ConvertFrom-Json
    New-Item -ItemType Directory -Force -Path .tools | Out-Null
    function Get-CheckedDownload([string] $Url, [string] $Path, [string] $Sha256) {
        if (-not (Test-Path -LiteralPath $Path)) { Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Path }
        if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Sha256) {
            throw ('Download checksum mismatch: ' + $Path)
        }
    }
    $ripgrepDirectory = '.tools/ripgrep-14.1.1-x86_64-pc-windows-msvc'
    $ripgrepExecutable = Join-Path $ripgrepDirectory 'rg.exe'
    if (-not (Test-Path -LiteralPath $ripgrepExecutable)) {
        Get-CheckedDownload 'https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-pc-windows-msvc.zip' '.tools/ripgrep-14.1.1-windows.zip' 'd0f534024c42afd6cb4d38907c25cd2b249b79bbe6cc1dbee8e3e37c2b6e25a1'
        Expand-Archive -LiteralPath '.tools/ripgrep-14.1.1-windows.zip' -DestinationPath '.tools' -Force
    }
    if ((Get-FileHash -LiteralPath $ripgrepExecutable -Algorithm SHA256).Hash.ToLowerInvariant() -ne 'f162b54de2adfc72d78adb1dbada2dedda111ae0a5e2f6e9500f4f909664c5d2') {
        throw 'Pinned ripgrep binary checksum mismatch'
    }
    $ripgrepVersion = @(& $ripgrepExecutable --version)
    if ($LASTEXITCODE -ne 0 -or $ripgrepVersion[0] -cne 'ripgrep 14.1.1 (rev 4649aa9700)') { throw 'Pinned ripgrep version check failed' }
    if (-not (Test-Path -LiteralPath 'vendor/luau/.git')) {
        & git clone --branch $lock.tag --depth 1 $lock.repository vendor/luau
        if ($LASTEXITCODE -ne 0) { throw 'Official Luau clone failed' }
    }
    if ((& git -C vendor/luau rev-parse HEAD) -ne $lock.revision) { throw 'Official Luau revision mismatch' }
    if (-not (Test-Path -LiteralPath '.tools/luau/luau-compile.exe')) {
        Get-CheckedDownload $lock.windows_release_url '.tools/luau-windows.zip' $lock.windows_release_sha256
        Expand-Archive -LiteralPath .tools/luau-windows.zip -DestinationPath .tools/luau
    }
    if ((Get-FileHash -LiteralPath '.tools/luau/luau-compile.exe' -Algorithm SHA256).Hash.ToLowerInvariant() -ne $lock.windows_compiler_sha256) {
        throw 'Pinned compiler binary checksum mismatch'
    }
    if ($PortableToolchain) {
        $gccUrl = 'https://github.com/brechtsanders/winlibs_mingw/releases/download/16.2.0posix-23.1.3-14.0.0-ucrt-r3/winlibs-x86_64-posix-seh-gcc-16.2.0-mingw-w64ucrt-14.0.0-r3.zip'
        if (-not (Test-Path -LiteralPath '.tools/mingw64/bin/g++.exe')) {
            Get-CheckedDownload $gccUrl '.tools/mingw.zip' '3c69305081e4a647144339a936244fcf7d3d9e558319e1ad7be2cd2886d4b6a1'
            Expand-Archive -LiteralPath .tools/mingw.zip -DestinationPath .tools
        }
        if (-not (Test-Path -LiteralPath '.tools/cargo/bin/cargo.exe')) {
            Get-CheckedDownload 'https://static.rust-lang.org/rustup/archive/1.29.3/x86_64-pc-windows-msvc/rustup-init.exe' '.tools/rustup-init.exe' '38027d51d69a5d05493627a0634dbea52d6cd793c8f072d2373d3f4163eec7db'
            $env:RUSTUP_HOME = Join-Path $taskRoot '.tools/rustup'
            $env:CARGO_HOME = Join-Path $taskRoot '.tools/cargo'
            & .tools/rustup-init.exe -y --no-modify-path --profile minimal --default-host x86_64-pc-windows-gnu --default-toolchain 1.99.1
            if ($LASTEXITCODE -ne 0) { throw 'Portable Rust installation failed' }
        }
    }
    . (Join-Path $PSScriptRoot 'env.ps1')
    & cargo build --release --locked
    if ($LASTEXITCODE -ne 0) { throw 'Rust release build failed' }
    if ($BuildOracle) { & (Join-Path $PSScriptRoot 'build-vm.ps1') }
} finally { Pop-Location }
