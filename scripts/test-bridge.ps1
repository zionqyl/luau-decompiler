param(
    [string] $Decompiler = (Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [string] $Fixture = (Join-Path $PSScriptRoot '../tests/fixtures/arithmetic.O2.D2.bc'),
    [string] $Destination = (Join-Path $PSScriptRoot '../artifacts/bridge-smoke'),
    [switch] $NoBuild
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot = Split-Path -Parent $PSScriptRoot
if (-not $NoBuild) {
    & cargo build --manifest-path (Join-Path $taskRoot 'Cargo.toml') --release --offline --bin luau-decompile
    if ($LASTEXITCODE -ne 0) { throw 'Release bridge build failed.' }
}
$Decompiler = (Resolve-Path -LiteralPath $Decompiler).Path
$Fixture = (Resolve-Path -LiteralPath $Fixture).Path
New-Item -ItemType Directory -Path $Destination -Force | Out-Null
$Destination = (Resolve-Path -LiteralPath $Destination).Path
Add-Type -AssemblyName System.Net.Http
$tokenBytes = New-Object byte[] 32
$tokenRandom = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try { $tokenRandom.GetBytes($tokenBytes) } finally { $tokenRandom.Dispose() }
$token = [Convert]::ToBase64String($tokenBytes)
$bytes = [System.IO.File]::ReadAllBytes($Fixture)
if ($bytes.Length -eq 0) { throw 'Bridge test fixture is empty.' }
$expectedPath = Join-Path $Destination 'expected.luau'
& $Decompiler decompile $Fixture -o $expectedPath --force
if ($LASTEXITCODE -ne 0) { throw 'CLI baseline decompilation failed.' }
$expectedSource = [System.IO.File]::ReadAllText($expectedPath)
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.UseProxy = $false
$handler.AllowAutoRedirect = $false
$client = [System.Net.Http.HttpClient]::new($handler)
$client.Timeout = [TimeSpan]::FromSeconds(10)
$process = [System.Diagnostics.Process]::new()
$started = $false
$stage = 'process startup'
$rows = [System.Collections.Generic.List[object]]::new()

function Invoke-Bridge([byte[]] $Body, [string] $ContentType, [string] $Bearer) {
    $request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Post, $endpoint)
    $request.Version = [Version]::new(1, 1)
    $request.Headers.ExpectContinue = $false
    $request.Headers.TransferEncodingChunked = $false
    $request.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $Bearer)
    $request.Content = [System.Net.Http.ByteArrayContent]::new($Body)
    $request.Content.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::new($ContentType)
    $response = $null
    try {
        $response = $client.SendAsync($request).GetAwaiter().GetResult()
        $responseBody = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        if ($responseBody.Contains($token)) { throw 'Bridge response exposed the authentication token.' }
        $cache = if ($response.Headers.Contains('X-Decompiler-Cache')) { [string]::Join(',', $response.Headers.GetValues('X-Decompiler-Cache')) } else { '' }
        return [pscustomobject] @{ status = [int] $response.StatusCode; body = $responseBody; cache = $cache }
    } finally {
        if ($response) { $response.Dispose() }
        $request.Dispose()
    }
}

try {
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Decompiler


    $start.Arguments = 'serve --listen 127.0.0.1:0 --workers 2 --queue 4 --cache-mib 4 --timeout-ms 3000'
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $start.RedirectStandardError = $true
    $start.RedirectStandardOutput = $true

    $start.EnvironmentVariables['LUAU_DECOMPILER_TOKEN'] = $token
    $process.StartInfo = $start
    [void] $process.Start()
    $started = $true
    $startup = $process.StandardError.ReadLineAsync()
    if (-not $startup.Wait(10000)) { throw 'Bridge did not announce its bound address within ten seconds.' }
    $line = $startup.GetAwaiter().GetResult()
    if ($line -notmatch '^bridge listening on (http://127\.0\.0\.1:[0-9]+/v1/decompile) ') {
        throw 'Bridge exited or returned an unexpected startup announcement.'
    }
    $endpoint = $Matches[1]

    $stage = 'raw bytecode'
    $raw = Invoke-Bridge $bytes 'application/octet-stream' $token
    if ($raw.status -ne 200 -or $raw.cache -ne 'miss') { throw 'Raw bytecode request did not return HTTP 200 with a cache miss.' }
    $rawJson = $raw.body | ConvertFrom-Json
    if ($rawJson.source -cne $expectedSource) { throw 'Raw bridge source differs from CLI baseline.' }
    $rows.Add([ordered] @{ case = 'raw_bytecode'; status = $raw.status; cache = $raw.cache; passed = $true })

    $stage = 'base64 JSON'
    $jsonText = @{ bytecode_base64 = [Convert]::ToBase64String($bytes) } | ConvertTo-Json -Compress
    $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonText)
    $encoded = Invoke-Bridge $jsonBytes 'application/json' $token
    if ($encoded.status -ne 200 -or $encoded.cache -ne 'hit') { throw 'Base64 JSON request did not return HTTP 200 with a cache hit.' }
    if (($encoded.body | ConvertFrom-Json).source -cne $expectedSource) { throw 'Base64 bridge source differs from CLI baseline.' }
    $rows.Add([ordered] @{ case = 'base64_json_same_source'; status = $encoded.status; cache = $encoded.cache; passed = $true })

    $stage = 'invalid token'



    $rejected = Invoke-Bridge ([byte[]] @()) 'application/octet-stream' ('invalid-' + ('x' * 40))
    if ($rejected.status -ne 401) { throw 'Invalid token did not return HTTP 401.' }
    $rows.Add([ordered] @{ case = 'invalid_token'; status = $rejected.status; passed = $true })

    $stage = 'unsupported version'
    $unsupported = [byte[]] $bytes.Clone()
    $unsupported[0] = 255
    $invalid = Invoke-Bridge $unsupported 'application/octet-stream' $token
    if ($invalid.status -ne 422) { throw 'Unsupported bytecode version did not return HTTP 422.' }
    $diagnostic = ($invalid.body | ConvertFrom-Json).error.message
    if ($diagnostic -notmatch '255' -or $diagnostic -notmatch 'version') { throw 'Unsupported version diagnostic lacks the rejected version.' }
    $rows.Add([ordered] @{ case = 'unsupported_bytecode'; status = $invalid.status; passed = $true })

    $stage = 'report serialization'
    $report = [ordered] @{
        schema = 1
        executable_sha256 = (Get-FileHash -LiteralPath $Decompiler -Algorithm SHA256).Hash.ToLowerInvariant()
        fixture_sha256 = (Get-FileHash -LiteralPath $Fixture -Algorithm SHA256).Hash.ToLowerInvariant()
        fixture_bytes = $bytes.Length
        note = 'Real release CLI child process, ephemeral numeric loopback binding, HttpClient binary/base64 transports; no live executor.'
        cases = $rows.Count
        passed = $rows.Count
        results = @($rows.ToArray())
    }
    [System.IO.File]::WriteAllText((Join-Path $Destination 'report.json'), (($report | ConvertTo-Json -Depth 6) + "`n"), [System.Text.UTF8Encoding]::new($false))
    Write-Output ('Release localhost bridge: ' + $rows.Count + '/' + $rows.Count + ' checks passed.')
} catch {
    $message = $_.Exception.GetBaseException().Message.Replace($token, '[redacted]')
    throw ('Bridge stage ' + $stage + ' failed: ' + $message)
} finally {

    if ($started -and -not $process.HasExited) {
        $process.Kill()
        [void] $process.WaitForExit(5000)
    }
    $process.Dispose()
    $client.Dispose()
    $handler.Dispose()
    $token = $null
    [Array]::Clear($tokenBytes, 0, $tokenBytes.Length)
}
