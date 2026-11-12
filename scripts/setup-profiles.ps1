param([switch] $BuildOracle)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
Push-Location $taskRoot
try {
    $lock = Get-Content -LiteralPath upstream.profiles.lock.json -Raw | ConvertFrom-Json
    foreach ($profile in $lock.profiles) {
        $source = 'vendor/' + $profile.directory
        $tools = '.tools/' + $profile.directory
        $archive = $tools + '.zip'
        if (-not (Test-Path -LiteralPath ($source + '/.git'))) {
            & git clone --branch $profile.tag --depth 1 $lock.repository $source
            if ($LASTEXITCODE -ne 0) { throw ('Official source clone failed: ' + $profile.tag) }
        }
        if ((& git -C $source rev-parse HEAD) -ne $profile.revision) { throw ('Official source revision mismatch: ' + $profile.tag) }
        New-Item -ItemType Directory -Force -Path $tools | Out-Null
        if (-not (Test-Path -LiteralPath ($tools + '/luau-compile.exe'))) {
            if (-not (Test-Path -LiteralPath $archive)) {
                Invoke-WebRequest -UseBasicParsing -Uri ('https://github.com/luau-lang/luau/releases/download/' + $profile.tag + '/luau-windows.zip') -OutFile $archive
            }
            if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $profile.windows_release_sha256) { throw ('Release checksum mismatch: ' + $profile.tag) }
            Expand-Archive -LiteralPath $archive -DestinationPath $tools -Force
        }
        if ((Get-FileHash -LiteralPath ($tools + '/luau-compile.exe') -Algorithm SHA256).Hash.ToLowerInvariant() -ne $profile.windows_compiler_sha256) { throw ('Compiler checksum mismatch: ' + $profile.tag) }
        if ((Get-FileHash -LiteralPath ($tools + '/luau.exe') -Algorithm SHA256).Hash.ToLowerInvariant() -ne $profile.windows_interpreter_sha256) { throw ('Interpreter checksum mismatch: ' + $profile.tag) }
        if ($BuildOracle) {
            & (Join-Path $PSScriptRoot 'build-vm.ps1') -SourceRoot $source -Revision $profile.revision -Output ($tools + '/vm-runner.exe')
            if ($LASTEXITCODE -ne 0) { throw ('Typed VM oracle build failed: ' + $profile.tag) }
        }
    }
} finally { Pop-Location }
