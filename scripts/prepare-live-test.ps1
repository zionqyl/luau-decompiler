param(
    [string]$Endpoint = 'http://127.0.0.1:7879/v1/decompile',
    [string]$Destination = (Join-Path $PSScriptRoot '../artifacts/madium-live/driver.luau'),
    [int]$Repetitions = 64
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
if ($Endpoint -notmatch '^http://127\.0\.0\.1:([0-9]+)/v1/decompile$' -or [int]$Matches[1] -notin 1..65535) {throw 'Expected numeric loopback endpoint.'}
if ($Repetitions -lt 1 -or $Repetitions -gt 1000) {throw 'Repetitions must be 1..1000.'}
$compiler = Join-Path $taskRoot '.tools/luau-modern/luau-compile.exe'
if (-not (Test-Path -LiteralPath $compiler)) {throw 'Run scripts/setup-profiles.ps1 first.'}

$fixtures = [System.Collections.Generic.List[string]]::new()
$hashes = [System.Collections.Generic.List[object]]::new()
$validationId = [Guid]::NewGuid().ToString('N')

$manifest = Get-Content -LiteralPath (Join-Path $taskRoot 'tests/profile-fixtures/manifest.json') -Raw | ConvertFrom-Json
$v14 = @($manifest.fixtures | Where-Object {$_.version -eq 14})[0]
if ($null -eq $v14) {throw 'Version-14 fixture catalog missing.'}
$flags = '--fflags=' + $v14.compiler_flags
if ((Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash.ToLowerInvariant() -ne $v14.compiler_sha256) {throw 'Compiler differs from pinned profile catalog.'}
function Quote-Luau([string]$text) {
    $level = '=='
    while ($text.Contains((']' + $level + ']'))) {$level += '='}
    return '[' + $level + '[' + $text + ']' + $level + ']'
}
foreach ($source in (Get-ChildItem -LiteralPath (Join-Path $taskRoot 'tests/live-corpus') -Filter '*.luau' | Sort-Object Name)) {
    $start = [Diagnostics.ProcessStartInfo]::new($compiler)
    $start.Arguments = '--binary -O2 -g2 ' + $flags + ' "' + $source.FullName + '"'
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = [Diagnostics.Process]::Start($start)
    $memory = [IO.MemoryStream]::new()
    $process.StandardOutput.BaseStream.CopyTo($memory)
    $errorText = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {throw ('Compiler failed: ' + $errorText)}
    $bytes = $memory.ToArray()
    if ($bytes[0] -ne 14) {throw ('Expected format14, got ' + $bytes[0])}
    $hex = ([BitConverter]::ToString($bytes)).Replace('-','').ToLowerInvariant()
    $text = [IO.File]::ReadAllText($source.FullName)
    $sourceHash = (Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $bytecodeHash = ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($bytes))).Replace('-','').ToLowerInvariant()
    $fixtures.Add('{id="' + $source.BaseName + '",source_sha256="' + $sourceHash + '",bytecode_sha256="' + $bytecodeHash + '",source=' + (Quote-Luau $text) + ',bytecode=unhex("' + $hex + '")}')
    $hashes.Add([ordered]@{id=$source.BaseName;source_sha256=$sourceHash;bytecode_sha256=$bytecodeHash;bytes=$bytes.Length})
    $process.Dispose();$memory.Dispose()
}
$adapter = Quote-Luau ([IO.File]::ReadAllText((Join-Path $taskRoot 'adapter/decompile.luau')))
$test = Quote-Luau ([IO.File]::ReadAllText((Join-Path $taskRoot 'adapter/live-test.luau')))
$driver = 'local Adapter=assert(loadstring(' + $adapter + '))()' + "`n" + 'local Test=assert(loadstring(' + $test + '))()' + "`n" +
    'local function unhex(s) return (string.gsub(s,"..",function(x)return string.char(tonumber(x,16))end)) end' + "`n" +
    'return Test.run(Adapter,{token="__TOKEN__",validation_id="' + $validationId + '",endpoint="' + $Endpoint + '",timeout=15},' +
    'game:GetService("ReplicatedStorage"):FindFirstChild("UserGenerated"),{' + ($fixtures -join ",`n") + '},' + $Repetitions + ')' + "`n"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
[IO.File]::WriteAllText($Destination,$driver,[Text.UTF8Encoding]::new($false))
$evidence = [ordered]@{schema=2;validation_id=$validationId;repetitions=$Repetitions;endpoint=$Endpoint;adapter_sha256=(Get-FileHash -LiteralPath (Join-Path $taskRoot 'adapter/decompile.luau') -Algorithm SHA256).Hash.ToLowerInvariant();harness_sha256=(Get-FileHash -LiteralPath (Join-Path $taskRoot 'adapter/live-test.luau') -Algorithm SHA256).Hash.ToLowerInvariant();compiler_sha256=(Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash.ToLowerInvariant();flags=$flags;optimization=2;debug=2;fixtures=$hashes.ToArray();driver_sha256=(Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash.ToLowerInvariant();token_included=$false}
[IO.File]::WriteAllText(($Destination + '.manifest.json'),($evidence | ConvertTo-Json -Depth 10),[Text.UTF8Encoding]::new($false))
Write-Output ('Prepared token-free test driver: ' + $Destination)
