param(
    [string] $Decompiler = (Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [string] $Runtime = $env:LUAU_VM_RUNNER,
    [string] $Compiler = $env:LUAU_COMPILE,
    [string] $Corpus = (Join-Path $PSScriptRoot '../artifacts/benchmark-corpus'),
    [int[]] $Seeds = @(-3, 0, 1, 7, 29),
    [Nullable[int]] $Seed = $null
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '../scripts/env.ps1')
$taskRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Runtime)) { $Runtime = $env:LUAU_VM_RUNNER }
if ([string]::IsNullOrWhiteSpace($Compiler)) { $Compiler = $env:LUAU_COMPILE }
if ($null -ne $Seed) { $Seeds = @([int]$Seed) }
if ($Seeds.Count -eq 0 -or $Seeds.Count -gt 128) { throw 'Provide 1..128 runtime seeds.' }
$Runtime = (Resolve-Path -LiteralPath $Runtime).Path
$Compiler = (Resolve-Path -LiteralPath $Compiler).Path
$Decompiler = (Resolve-Path -LiteralPath $Decompiler).Path
$Corpus = (Resolve-Path -LiteralPath $Corpus).Path
if ((& $Runtime --protocol-version) -ne 'LOBS/1 LARG/1') { throw 'A typed LOBS/1 VM runner is required; source-interpreter text output is not accepted.' }
& cargo build --manifest-path (Join-Path $taskRoot 'Cargo.toml') --offline --release --example oracle_compare
if ($LASTEXITCODE -ne 0) { throw 'Typed observation comparator build failed.' }
$comparator = Join-Path $taskRoot 'target/release/examples/oracle_compare.exe'
$manifest = Get-Content -LiteralPath (Join-Path $Corpus 'manifest.json') -Raw | ConvertFrom-Json
$utf8 = [System.Text.UTF8Encoding]::new($false, $true)
$rows = [System.Collections.Generic.List[object]]::new()

function Invoke-Bytes([string] $Executable, [string] $Arguments) {
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Executable; $start.Arguments = $Arguments
    $start.UseShellExecute = $false; $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true; $start.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::new(); $process.StartInfo = $start
    $buffer = [System.IO.MemoryStream]::new()
    try {
        [void]$process.Start()
        $stdout = $process.StandardOutput.BaseStream.CopyToAsync($buffer)
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(30000)) { $process.Kill(); throw 'Oracle subprocess exceeded thirty seconds.' }
        $stdout.GetAwaiter().GetResult()
        return [pscustomobject]@{ bytes=$buffer.ToArray(); errors=$stderr.GetAwaiter().GetResult(); exit=$process.ExitCode }
    } finally { $buffer.Dispose(); $process.Dispose() }
}
function Compile-Bytes([string] $Source, [string] $Output) {
    $compiled = Invoke-Bytes $Compiler ('--binary -O2 -g2 "' + $Source + '"')
    if ($compiled.exit -ne 0 -or $compiled.bytes.Length -eq 0 -or $compiled.bytes[0] -eq 0) { throw ('Compiler failed: ' + $compiled.errors) }
    [System.IO.File]::WriteAllBytes($Output, $compiled.bytes)
}
function Write-Arguments([string] $Path, [int] $Value) {
    $buffer = [System.IO.MemoryStream]::new(); $writer = [System.IO.BinaryWriter]::new($buffer)
    try {
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes('LARG')); $writer.Write([byte]1)
        $writer.Write([uint32]1); $writer.Write([byte]2); $writer.Write([double]$Value); $writer.Flush()
        [System.IO.File]::WriteAllBytes($Path, $buffer.ToArray())
    } finally { $writer.Dispose(); $buffer.Dispose() }
}

foreach ($case in $manifest.cases) {
    $sourcePath = Join-Path $Corpus $case.source
    $bytecodePath = Join-Path $Corpus $case.bytecode
    if ((Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $case.source_sha256) { throw ('Source hash changed: ' + $case.source) }
    if ((Get-FileHash -LiteralPath $bytecodePath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $case.bytecode_sha256) { throw ('Bytecode hash changed: ' + $case.bytecode) }
    $outputPath = Join-Path $Corpus ($case.name + '.typed.out.luau')
    $decompilation = Invoke-Bytes $Decompiler ('decompile "' + $bytecodePath + '" -o "' + $outputPath + '" --force')
    $decompiled = $decompilation.exit -eq 0
    $recompiled = Join-Path $Corpus ($case.name + '.typed.out.bc')
    $probePath = Join-Path $Corpus ($case.name + '.typed.probe.luau')
    $probeBytecode = Join-Path $Corpus ($case.name + '.typed.probe.bc')
    $probe = 'local result = ...; return result'
    if ($case.category -eq 'escaping_functions') {
        $probe = 'local result = ...; return #result, result[1](3), result[' + $case.scale + '](11), result[1] == result[' + $case.scale + ']'
    } elseif ($case.category -eq 'nested_mutable_captures') {
        $probe = 'local result = ...; local first = result[1](2)(3); local separate = result[1](2)(3); local last = result[' + $case.scale + '](4)(5); return #result, first(5), first(7), separate(5), last(11), last(13), first == separate'
    }
    [System.IO.File]::WriteAllText($probePath, $probe, $utf8)
    $preparationError = if ($decompiled) {$null} else {$decompilation.errors}
    try { if ($decompiled) { Compile-Bytes $outputPath $recompiled }; Compile-Bytes $probePath $probeBytecode } catch { $preparationError = $_.Exception.Message }
    foreach ($inputSeed in $Seeds) {
        if (-not $decompiled -or $null -ne $preparationError) {
            $rows.Add([ordered]@{name=$case.name; seed=$inputSeed; status='reconstruction_or_compile_failed'; error=$preparationError}); continue
        }
        try {
            $argumentPath = Join-Path $Corpus ($case.name + '.seed' + $inputSeed + '.args')
            Write-Arguments $argumentPath $inputSeed
            $frames = @()
            foreach ($flavor in @('original', 'output')) {
                $bytecodeInput = if ($flavor -eq 'original') { $bytecodePath } else { $recompiled }
                $executed = Invoke-Bytes $Runtime ('"' + $bytecodeInput + '" --args "' + $argumentPath + '" --probe "' + $probeBytecode + '"')
                if ($executed.exit -ne 0) { throw ('Oracle transport failed: ' + $executed.errors) }
                $framePath = Join-Path $Corpus ($case.name + '.' + $flavor + '.seed' + $inputSeed + '.obs')
                [System.IO.File]::WriteAllBytes($framePath, $executed.bytes)
                $frames += $framePath
            }
            $comparison = Invoke-Bytes $comparator ('"' + $frames[0] + '" "' + $frames[1] + '"')
            if ($comparison.exit -gt 1) { throw ('Typed comparison failed: ' + $comparison.errors) }
            $observations = $utf8.GetString($comparison.bytes) | ConvertFrom-Json
            $rows.Add([ordered]@{name=$case.name; seed=$inputSeed; status=$(if ($observations.matched) {'passed'} else {'mismatch_or_incomplete'}); observations=$observations})
        } catch { $rows.Add([ordered]@{name=$case.name; seed=$inputSeed; status='oracle_failed'; error=$_.Exception.Message}) }
    }
}
$passed = @($rows | Where-Object {$_.status -eq 'passed'}).Count
$report = [ordered]@{schema=2; oracle_protocol='LOBS/1'; upstream_revision=$manifest.upstream_revision; runtime_sha256=(Get-FileHash -LiteralPath $Runtime -Algorithm SHA256).Hash.ToLowerInvariant(); compiler_sha256=(Get-FileHash -LiteralPath $Compiler -Algorithm SHA256).Hash.ToLowerInvariant(); decompiler_sha256=(Get-FileHash -LiteralPath $Decompiler -Algorithm SHA256).Hash.ToLowerInvariant(); seeds=$Seeds; note='Original compiled bytecode versus recompiled output, exact typed results/effects/errors, separate trusted probes, incomplete never passes.'; cases=$rows.Count; passed=$passed; results=@($rows.ToArray())}
[System.IO.File]::WriteAllText((Join-Path $Corpus 'oracle-report.json'), (($report | ConvertTo-Json -Depth 16) + "`n"), $utf8)
Write-Output ('Typed larger-corpus behavioral oracle: ' + $passed + '/' + $rows.Count)
if ($passed -ne $rows.Count) { throw 'Typed larger-corpus mismatch or incomplete observation; see oracle-report.json.' }
