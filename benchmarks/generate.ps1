param(
    [string] $Compiler = $env:LUAU_COMPILE,
    [string] $Destination = (Join-Path $PSScriptRoot '../artifacts/benchmark-corpus'),
    [switch] $AllowCustomCompiler
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Compiler)) {
    . (Join-Path $taskRoot 'scripts/env.ps1')
    $Compiler = $env:LUAU_COMPILE
}
if ([string]::IsNullOrWhiteSpace($Compiler)) { throw 'Set LUAU_COMPILE or pass -Compiler for the pinned Luau compiler.' }
$Compiler = (Resolve-Path -LiteralPath $Compiler).Path
$lock = Get-Content -LiteralPath (Join-Path $taskRoot 'upstream.lock.json') -Raw | ConvertFrom-Json
$compilerHash = (Get-FileHash -LiteralPath $Compiler -Algorithm SHA256).Hash.ToLowerInvariant()
$verifiedRelease = $compilerHash -eq $lock.windows_compiler_sha256
if (-not $verifiedRelease -and -not $AllowCustomCompiler) {
    throw 'Compiler hash differs from the verified pinned Windows release. For a compiler built from the pinned revision, pass -AllowCustomCompiler; its hash will be recorded.'
}
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination = (Resolve-Path -LiteralPath $Destination).Path
$utf8 = [System.Text.UTF8Encoding]::new($false)
$cases = [System.Collections.Generic.List[object]]::new()

function Add-Case([string] $Name, [string] $Category, [int] $Scale, [System.Collections.Generic.List[string]] $Lines) {
    $cases.Add([ordered] @{ name = $Name; category = $Category; scale = $Scale; lines = $Lines })
}

foreach ($scale in @(512, 1024)) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('local seed = ... or 1')
    $lines.Add('local value = seed')
    for ($index = 1; $index -le $scale; $index++) {
        $increment = 1013904223 + ($index * 977)
        $lines.Add('value = (value * 1664525 + ' + $increment + ') % 2147483647')
    }
    $lines.Add('return value')
    Add-Case ('linear_' + $scale) 'linear_arithmetic' $scale $lines
}

foreach ($scale in @(64, 128)) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('local seed = ... or 1')
    $lines.Add('local value = seed')
    for ($index = 1; $index -le $scale; $index++) {
        $divisor = 3 + ($index % 29)
        $residue = $index % $divisor
        $lines.Add('if value % ' + $divisor + ' == ' + $residue + ' then')
        $lines.Add('    value = (value + ' + ($index * 17) + ') % 1000003')
        $lines.Add('else')
        $lines.Add('    value = (value * 3 + ' + $index + ') % 1000003')
        $lines.Add('end')
    }
    $lines.Add('return value')
    Add-Case ('branches_' + $scale) 'branch_joins' $scale $lines
}

foreach ($scale in @(64, 128)) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('local seed = ... or 1')
    $lines.Add('local functions = {}')
    for ($index = 1; $index -le $scale; $index++) {
        $lines.Add('functions[' + $index + '] = function(delta)')
        $lines.Add('    return ((seed + delta + ' + $index + ') * ' + ($index + 3) + ') % 1000003')
        $lines.Add('end')
    }
    $lines.Add('return functions')
    Add-Case ('functions_' + $scale) 'escaping_functions' $scale $lines
}

foreach ($scale in @(16, 32)) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('local seed = ... or 1')
    $lines.Add('local total = seed')
    for ($index = 1; $index -le $scale; $index++) {
        $lines.Add('for outer = 1, seed % 17 + ' + (3 + $index % 7) + ' do')
        $lines.Add('    for inner = 1, 5 do')
        $lines.Add('        total = (total + outer * inner + ' + $index + ') % 1000003')
        $lines.Add('    end')
        $lines.Add('end')
    }
    $lines.Add('return total')
    Add-Case ('loops_' + $scale) 'nested_numeric_loops' $scale $lines
}

foreach ($scale in @(16, 32)) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('local seed = ... or 1')
    $lines.Add('local factories = {}')
    for ($index = 1; $index -le $scale; $index++) {
        $lines.Add('factories[' + $index + '] = function(step)')
        $lines.Add('    local current = seed + step + ' + $index)
        $lines.Add('    return function(delta)')
        $lines.Add('        current = current + delta')
        $lines.Add('        return function(scale)')
        $lines.Add('            current = current + scale')
        $lines.Add('            return current')
        $lines.Add('        end')
        $lines.Add('    end')
        $lines.Add('end')
    }
    $lines.Add('return factories')
    Add-Case ('closures_' + $scale) 'nested_mutable_captures' $scale $lines
}

$manifest = [System.Collections.Generic.List[object]]::new()
foreach ($case in $cases) {
    $sourceName = $case.name + '.luau'
    $sourcePath = Join-Path $Destination $sourceName
    [System.IO.File]::WriteAllText($sourcePath, ([string]::Join("`n", $case.lines.ToArray()) + "`n"), $utf8)
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Compiler
    $start.Arguments = '--binary -O2 -g2 "' + $sourcePath + '"'
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $start
    $buffer = [System.IO.MemoryStream]::new()
    try {
        [void] $process.Start()
        $errors = $process.StandardError.ReadToEndAsync()

        $process.StandardOutput.BaseStream.CopyTo($buffer)
        $process.WaitForExit()
        $stderr = $errors.GetAwaiter().GetResult()
        $bytes = $buffer.ToArray()
        if ($process.ExitCode -ne 0 -or $bytes.Length -lt 2 -or $bytes[0] -ne 6 -or $bytes[1] -ne 3) {
            throw ('Pinned O2/g2 compilation failed for ' + $sourceName + ': ' + $stderr)
        }
        $bytecodeName = $case.name + '.O2.D2.bc'
        $bytecodePath = Join-Path $Destination $bytecodeName
        [System.IO.File]::WriteAllBytes($bytecodePath, $bytes)
        $manifest.Add([ordered] @{
            name = $case.name
            category = $case.category
            scale = $case.scale
            source = $sourceName
            source_lines = $case.lines.Count
            source_bytes = (Get-Item -LiteralPath $sourcePath).Length
            source_sha256 = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
            bytecode = $bytecodeName
            bytecode_bytes = $bytes.Length
            bytecode_sha256 = (Get-FileHash -LiteralPath $bytecodePath -Algorithm SHA256).Hash.ToLowerInvariant()
        })
    } finally {
        $buffer.Dispose()
        $process.Dispose()
    }
}
$data = [ordered] @{
    schema = 1
    generator = 'benchmarks/generate.ps1'
    upstream_tag = $lock.tag
    upstream_revision = $lock.revision
    optimization = 2
    debug = 2
    bytecode_version = 6
    type_version = 3
    compiler_sha256 = $compilerHash
    verified_release_compiler = $verifiedRelease
    cases = @($manifest.ToArray())
}
[System.IO.File]::WriteAllText((Join-Path $Destination 'manifest.json'), (($data | ConvertTo-Json -Depth 8) + "`n"), $utf8)
Write-Output ('Generated ' + $manifest.Count + ' deterministic benchmark inputs in ' + $Destination)
