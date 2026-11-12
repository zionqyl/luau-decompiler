param(
    [string] $Compiler = $env:LUAU_COMPILE,
    [string] $Corpus = (Join-Path $PSScriptRoot '../tests/corpus'),
    [string] $Destination = (Join-Path $PSScriptRoot '../tests/fixtures')
)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Compiler)) {
    throw 'Set LUAU_COMPILE to the compiler built from the pinned Luau revision, or pass -Compiler.'
}
$Compiler = (Resolve-Path -LiteralPath $Compiler).Path
$Corpus = (Resolve-Path -LiteralPath $Corpus).Path
New-Item -ItemType Directory -Path $Destination -Force | Out-Null
$Destination = (Resolve-Path -LiteralPath $Destination).Path
$manifest = [System.Collections.Generic.List[object]]::new()
foreach ($source in (Get-ChildItem -LiteralPath $Corpus -Filter '*.luau' | Sort-Object Name)) {
    foreach ($optimization in 0..2) {
        foreach ($debug in 0..2) {
            $start = [System.Diagnostics.ProcessStartInfo]::new()
            $start.FileName = $Compiler
            $start.Arguments = '--binary -O' + $optimization + ' -g' + $debug + ' "' + $source.FullName + '"'
            $start.UseShellExecute = $false
            $start.CreateNoWindow = $true
            $start.RedirectStandardOutput = $true
            $start.RedirectStandardError = $true
            $process = [System.Diagnostics.Process]::new()
            $process.StartInfo = $start
            [void] $process.Start()
            $errors = $process.StandardError.ReadToEndAsync()
            $buffer = [System.IO.MemoryStream]::new()
            $process.StandardOutput.BaseStream.CopyTo($buffer)
            $process.WaitForExit()
            $stderr = $errors.GetAwaiter().GetResult()
            $bytes = $buffer.ToArray()
            if ($process.ExitCode -ne 0 -or $bytes.Length -eq 0 -or $bytes[0] -eq 0) {
                throw ('Compiler failed for ' + $source.Name + ' -O' + $optimization + ' -g' + $debug + ': ' + $stderr)
            }
            if ($bytes[0] -ne 6) { throw 'The pinned compiler must emit bytecode version 6.' }
            $name = $source.BaseName + '.O' + $optimization + '.D' + $debug + '.bc'
            $path = Join-Path $Destination $name
            [System.IO.File]::WriteAllBytes($path, $bytes)
            $manifest.Add([ordered] @{
                source = $source.Name
                source_sha256 = (Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
                optimization = $optimization
                debug = $debug
                bytecode = $name
                bytes = $bytes.Length
                sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
            })
            $buffer.Dispose()
            $process.Dispose()
        }
    }
}
$data = [ordered] @{
    upstream_tag = '0.654'
    upstream_revision = '8cc289fae430d9b0c22bde209fe5cf2d01751ff1'
    bytecode_version = 6
    compiler_sha256 = (Get-FileHash -LiteralPath $Compiler -Algorithm SHA256).Hash.ToLowerInvariant()
    fixtures = @($manifest.ToArray())
}
$json = $data | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText((Join-Path $Destination 'manifest.json'), $json + "`n", [System.Text.UTF8Encoding]::new($false))
Write-Output ('Generated ' + $manifest.Count + ' binary fixtures in ' + $Destination)
