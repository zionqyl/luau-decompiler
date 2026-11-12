param(
    [Parameter(Mandatory=$true)][string] $Source,
    [ValidateSet(6,14)][int] $Version = 14,
    [ValidateRange(0,2)][int] $Optimization = 2
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot = Split-Path -Parent $PSScriptRoot
$previousSource=$env:LUAU_MINIMIZE_SOURCE
$previousVersion=$env:LUAU_MINIMIZE_VERSION
$previousOptimization=$env:LUAU_MINIMIZE_OPTIMIZATION
try {
    $env:LUAU_MINIMIZE_SOURCE=(Resolve-Path -LiteralPath $Source).Path
    $env:LUAU_MINIMIZE_VERSION=$Version.ToString()
    $env:LUAU_MINIMIZE_OPTIMIZATION=$Optimization.ToString()
    Push-Location $taskRoot
    try {
        & cargo test --offline --locked --test generated_programs minimize_generated_failure -- --ignored --nocapture
        if ($LASTEXITCODE -ne 0) { throw 'Failure minimization did not complete' }
    } finally { Pop-Location }
} finally {
    $env:LUAU_MINIMIZE_SOURCE=$previousSource
    $env:LUAU_MINIMIZE_VERSION=$previousVersion
    $env:LUAU_MINIMIZE_OPTIMIZATION=$previousOptimization
}
