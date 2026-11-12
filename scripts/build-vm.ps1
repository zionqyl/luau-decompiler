param(
    [string] $Compiler = 'g++',
    [string] $SourceRoot = 'vendor/luau',
    [string] $Output = '.tools/vm-runner.exe',
    [string] $Revision = '8cc289fae430d9b0c22bde209fe5cf2d01751ff1'
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot = Split-Path -Parent $PSScriptRoot
Push-Location $taskRoot
try {
    $SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
    $actualRevision = (& git -C $SourceRoot rev-parse HEAD)
    if ($LASTEXITCODE -ne 0 -or $actualRevision -ne $Revision) { throw 'Official Luau checkout has the wrong revision' }
    $dirty = (& git -C $SourceRoot status --porcelain --untracked-files=no)
    if ($LASTEXITCODE -ne 0 -or $dirty) { throw 'Official Luau source has tracked modifications; an independent oracle requires the pinned clean source' }
    $Output = if ([System.IO.Path]::IsPathRooted($Output)) { [System.IO.Path]::GetFullPath($Output) } else { [System.IO.Path]::GetFullPath((Join-Path $taskRoot $Output)) }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Output) | Out-Null
    $sources = @(Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'VM/src') -Filter '*.cpp' | ForEach-Object { $_.FullName })
    $commonSources = Join-Path $SourceRoot 'Common/src'
    if (Test-Path -LiteralPath $commonSources) { $sources += @(Get-ChildItem -LiteralPath $commonSources -Filter '*.cpp' | ForEach-Object { $_.FullName }) }
    $harnessHashBefore = (Get-FileHash -LiteralPath tests/vm_runner.cpp -Algorithm SHA256).Hash.ToLowerInvariant()
    $featureEvidence = @()
    if (Select-String -LiteralPath (Join-Path $SourceRoot 'Common/include/Luau/Bytecode.h') -Pattern 'LOP_FASTPCALL' -Quiet) {
        $featureEvidence += '-DLUAU_ORACLE_FASTPCALL_EVIDENCE'
    }
    & $Compiler -std=c++17 -O2 -DNDEBUG -Wno-attributes -static ('-I' + (Join-Path $SourceRoot 'VM/include')) ('-I' + (Join-Path $SourceRoot 'VM/src')) ('-I' + (Join-Path $SourceRoot 'Common/include')) @featureEvidence tests/vm_runner.cpp @sources -o $Output
    if ($LASTEXITCODE -ne 0) { throw 'Official VM oracle build failed' }
    $protocol = (& $Output --protocol-version)
    if ($LASTEXITCODE -ne 0 -or $protocol -ne 'LOBS/1 LARG/1') { throw 'Built oracle protocol is not LOBS/1' }
    $harnessHashAfter = (Get-FileHash -LiteralPath tests/vm_runner.cpp -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($harnessHashBefore -ne $harnessHashAfter) { throw 'Oracle harness changed during compilation; rebuild for a verifiable source stamp' }
    $manifest = [ordered]@{ protocol='LOBS/1'; source_root=$SourceRoot; upstream_revision=$actualRevision; runner_sha256=(Get-FileHash -LiteralPath $Output -Algorithm SHA256).Hash.ToLowerInvariant(); harness_sha256=$harnessHashAfter }
    [System.IO.File]::WriteAllText(($Output + '.manifest.json'), ($manifest | ConvertTo-Json), [System.Text.UTF8Encoding]::new($false))
    Write-Output ('Built typed LOBS/1 oracle: ' + $Output)
} finally { Pop-Location }
