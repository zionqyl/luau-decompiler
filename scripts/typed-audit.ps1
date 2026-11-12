

function Invoke-AuditProcess([string]$Executable, [string]$Arguments) {
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName=$Executable; $start.Arguments=$Arguments; $start.UseShellExecute=$false; $start.CreateNoWindow=$true
    $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
    $process=[System.Diagnostics.Process]::new(); $process.StartInfo=$start
    $buffer=[System.IO.MemoryStream]::new()
    try {
        [void]$process.Start()
        $copy=$process.StandardOutput.BaseStream.CopyToAsync($buffer); $errors=$process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(30000)) {$process.Kill(); throw 'Typed audit subprocess deadline exceeded.'}
        $copy.GetAwaiter().GetResult()
        return [pscustomobject]@{bytes=$buffer.ToArray(); exit=$process.ExitCode; errors=$errors.GetAwaiter().GetResult()}
    } finally {$buffer.Dispose(); $process.Dispose()}
}
function Initialize-TypedAudit([string]$Runtime) {
    if ((& $Runtime --protocol-version) -ne 'LOBS/1 LARG/1') {throw 'Typed hash audit requires the LOBS/1 VM runner.'}
    & cargo build --offline --release --example oracle_compare
    if ($LASTEXITCODE -ne 0) {throw 'Typed audit comparator build failed.'}
}
function Compare-TypedAudit([string]$Original, [string]$Reserved, [int]$Optimization, [string]$Runtime) {
    $compiler=$env:LUAU_COMPILE
    if ([string]::IsNullOrWhiteSpace($compiler)) {throw 'LUAU_COMPILE is required.'}
    $observationPaths=@()
    foreach ($flavor in @('original','reserved')) {
        $source=if ($flavor -eq 'original') {$Original} else {$Reserved}
        $level=if ($flavor -eq 'original') {0} else {$Optimization}
        $compiled=Invoke-AuditProcess $compiler ('--binary -O' + $level + ' -g0 "' + $source + '"')
        if ($compiled.exit -ne 0 -or $compiled.bytes.Length -eq 0 -or $compiled.bytes[0] -eq 0) {throw ('Audit compile failed: ' + $compiled.errors)}
        $bytecode=$source + '.O' + $level + '.bc'
        [System.IO.File]::WriteAllBytes($bytecode,$compiled.bytes)
        $executed=Invoke-AuditProcess $Runtime ('"' + $bytecode + '"')
        if ($executed.exit -ne 0) {throw ('Typed audit runner failed: ' + $executed.errors)}
        $frame=$bytecode + '.obs'
        [System.IO.File]::WriteAllBytes($frame,$executed.bytes)
        $observationPaths += $frame
    }
    $comparator=Join-Path $taskRoot 'target/release/examples/oracle_compare.exe'
    $comparison=Invoke-AuditProcess $comparator ('"' + $observationPaths[0] + '" "' + $observationPaths[1] + '"')
    if ($comparison.exit -gt 1) {throw ('Typed audit comparison failed: ' + $comparison.errors)}
    return ([System.Text.UTF8Encoding]::new($false,$true).GetString($comparison.bytes) | ConvertFrom-Json)
}
