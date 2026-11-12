param(
    [Parameter(Mandatory=$true)][string]$Capture,
    [string]$FixtureManifest = (Join-Path $PSScriptRoot '../artifacts/madium-live/driver.luau.manifest.json'),
    [string]$ServiceBinary = (Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [string]$Destination = (Join-Path $PSScriptRoot '../docs/results/madium-live.json'),
    [int]$ConfiguredCacheMiB = 0
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$comparison = Join-Path $taskRoot 'target/release/examples/oracle_compare.exe'
if (-not (Test-Path -LiteralPath $comparison)) {throw 'Build cargo build --release --offline --example oracle_compare first.'}
$report = Get-Content -LiteralPath $Capture -Raw | ConvertFrom-Json
if (-not $report.ok -or -not $report.raw_restored -or -not $report.registry_cleared -or -not $report.out_of_order_restore) {throw 'Live test or restoration failed.'}
if ($report.oracle_protocol -ne 'LOBS/1' -or $report.capabilities.protocol_version -ne 2) {throw 'Unexpected protocol.'}
$version = (& $ServiceBinary --version) -replace '^luau-decompile ',''
if ($LASTEXITCODE -ne 0 -or $version -ne $report.capabilities.package_version) {throw 'Live service version does not match supplied binary.'}
$manifest = Get-Content -LiteralPath $FixtureManifest -Raw | ConvertFrom-Json
$preparedDriver = $FixtureManifest -replace '\.manifest\.json$',''
if ($preparedDriver -eq $FixtureManifest -or -not (Test-Path -LiteralPath $preparedDriver) -or (Get-FileHash -LiteralPath $preparedDriver -Algorithm SHA256).Hash.ToLowerInvariant() -cne $manifest.driver_sha256) {throw 'Prepared token-free driver is missing or changed.'}
if ($manifest.schema -ne 2 -or $report.schema -ne 2 -or -not $manifest.validation_id -or $report.validation_id -cne $manifest.validation_id) {throw 'Capture does not match this prepared test plan.'}
if ($manifest.repetitions -lt 1 -or $manifest.repetitions -gt 1000 -or $report.latency_repetitions -ne $manifest.repetitions -or $report.native.typed_comparisons -ne ($manifest.repetitions + 1) -or $report.native.observations.Count -ne $report.native.typed_comparisons) {throw 'Native observation/repetition count is incomplete.'}
if (-not $report.oracle_conformance.passed -or $report.oracle_conformance.negative_collision_pairs -ne 7 -or $report.oracle_conformance.unsupported_observations_rejected -ne 3) {throw 'Live oracle conformance failed.'}
foreach ($module in @(@{path='adapter/decompile.luau';expected=$manifest.adapter_sha256},@{path='adapter/live-test.luau';expected=$manifest.harness_sha256})) {
    if ((Get-FileHash -LiteralPath (Join-Path $taskRoot $module.path) -Algorithm SHA256).Hash.ToLowerInvariant() -cne $module.expected) {throw 'Live adapter/harness changed after test preparation.'}
}
$expectedCases = @{}
if ($manifest.fixtures.Count -lt 1 -or $manifest.fixtures.Count -ne @(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'tests/live-corpus') -Filter '*.luau').Count) {throw 'Live fixture catalog is empty or incomplete.'}
if ((Get-FileHash -LiteralPath (Join-Path $taskRoot '.tools/luau-modern/luau-compile.exe') -Algorithm SHA256).Hash.ToLowerInvariant() -cne $manifest.compiler_sha256) {throw 'Prepared live fixture compiler differs from the installed pinned compiler.'}
foreach ($fixture in $manifest.fixtures) {
    $source = Join-Path $taskRoot ('tests/live-corpus/' + $fixture.id + '.luau')
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -ne $fixture.source_sha256) {throw 'Live fixture source changed.'}
    foreach ($seed in @(-3,0,1,7,29)) {
        $key = $fixture.id + '/' + $seed
        if ($expectedCases.ContainsKey($key)) {throw 'Fixture manifest contains a duplicate case.'}
        $expectedCases[$key] = $fixture
    }
}
$expectedNative = '0e0300000128010000010a0004a3000000ff0000000000000082000200000001000118000000000100000000000a00'
if ($report.native.input_hex -cne $expectedNative -or $report.native.source -cne "return {}`n" -or -not $report.native.complete) {throw 'Native getter model changed; independently review the new fixture.'}

$expectedNativeObservation = 'TE9CUwEBAAAAAAAFAAAAAgAAAAAAAPA/AwUAAAB0YWJsZQEBAQEBAA=='
if ($report.native.expected -cne $expectedNativeObservation) {throw 'Native expected observation differs from the independently specified empty-table probe.'}
if ($report.comparisons.Count -ne $manifest.fixtures.Count * 5) {throw 'Known-source case count incomplete.'}
foreach ($item in $report.comparisons) {
    $key = $item.id + '/' + $item.seed
    if (-not $expectedCases.ContainsKey($key)) {throw ('Duplicate or unknown live fixture/seed: ' + $key)}
    $fixture = $expectedCases[$key]
    if ($item.source_sha256 -cne $fixture.source_sha256 -or $item.bytecode_sha256 -cne $fixture.bytecode_sha256) {throw 'Captured fixture provenance differs from the prepared test plan.'}
    $expectedCases.Remove($key)
}
if ($expectedCases.Count -ne 0) {throw 'Some required live fixture/seed observations are missing.'}
$frames = Join-Path $taskRoot 'artifacts/madium-live/observations'
New-Item -ItemType Directory -Force -Path $frames | Out-Null
$all = @(foreach ($actual in $report.native.observations) { [pscustomobject]@{complete=$true;expected=$report.native.expected;actual=$actual} }) + @($report.comparisons)
for ($index=0; $index -lt $all.Count; $index++) {
    $item = $all[$index]
    if (-not $item.complete) {throw 'Incomplete live reconstruction.'}
    $expected = Join-Path $frames ($index.ToString('D3') + '.expected.obs')
    $actual = Join-Path $frames ($index.ToString('D3') + '.actual.obs')
    [IO.File]::WriteAllBytes($expected,[Convert]::FromBase64String($item.expected))
    [IO.File]::WriteAllBytes($actual,[Convert]::FromBase64String($item.actual))
    $decoded = (& $comparison $expected $actual | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0 -or -not $decoded.matched) {throw ('Rust typed observation validation failed at case ' + $index)}
    $item | Add-Member -NotePropertyName observation_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $actual -Algorithm SHA256).Hash.ToLowerInvariant()
}
$latencyBytes = [Convert]::FromBase64String($report.warm_adapter_ms_f64_le_base64)
if ($latencyBytes.Length -ne 8 * $report.latency_repetitions) {throw 'Latency frame truncated.'}
$latencies = @(for ($index=0; $index -lt $report.latency_repetitions; $index++) {
    $value = [BitConverter]::ToDouble($latencyBytes,8*$index)
    if ([double]::IsNaN($value) -or [double]::IsInfinity($value) -or $value -le 0) {throw 'Invalid latency sample.'}
    $value
})
$sorted = @($latencies | Sort-Object)
if ([double]::IsNaN($report.cold_adapter_ms) -or [double]::IsInfinity($report.cold_adapter_ms) -or $report.cold_adapter_ms -le 0) {throw 'Invalid cold latency sample.'}
$metrics = [ordered]@{samples=$sorted.Count;p50_ms=$sorted[[Math]::Ceiling($sorted.Count*.50)-1];p95_ms=$sorted[[Math]::Ceiling($sorted.Count*.95)-1];max_ms=$sorted[-1];cold_ms=$report.cold_adapter_ms;raw_ms=$latencies;timing='Executor getter through base64, HTTP, full service reconstruction, JSON and adapter completion; excludes recompilation and behavioral probes. Cold includes capabilities handshake.';configured_service_cache_mib=$ConfiguredCacheMiB;cache_setting_evidence='Host launch parameter recorded by test operator, not independently inferred from timing.'}
$report | Add-Member -NotePropertyName latency -NotePropertyValue $metrics
$report | Add-Member -NotePropertyName verified_at -NotePropertyValue ([DateTime]::UtcNow.ToString('o'))
$report | Add-Member -NotePropertyName service_binary_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $ServiceBinary -Algorithm SHA256).Hash.ToLowerInvariant()
$report | Add-Member -NotePropertyName service_binary_evidence -NotePropertyValue 'Operator-supplied binary hash; independently checked package-version equality with handshake, not remote process image attestation.'
$report | Add-Member -NotePropertyName oracle_comparator_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $comparison -Algorithm SHA256).Hash.ToLowerInvariant()
$report | Add-Member -NotePropertyName fixtures -NotePropertyValue $manifest
$report | Add-Member -NotePropertyName verified_typed_comparisons -NotePropertyValue ($report.native.typed_comparisons+$report.comparisons.Count)
$report | Add-Member -NotePropertyName provenance -NotePropertyValue 'Native getter fixture original source is unknown. Header-normalized bytes independently equal official0.746 return{} compiler output; separately supplied source fixtures pass real Roblox runtime probes. This verifies this executor/runtime/model and supplied fixtures, not arbitrary native extraction.'
$report | Add-Member -NotePropertyName capture_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $Capture -Algorithm SHA256).Hash.ToLowerInvariant()
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
[IO.File]::WriteAllText($Destination,($report | ConvertTo-Json -Depth 24),[Text.UTF8Encoding]::new($false))
Write-Output ('Verified ' + $report.verified_typed_comparisons + ' typed live comparisons; p50=' + $metrics.p50_ms + 'ms p95=' + $metrics.p95_ms + 'ms; wrote ' + $Destination)
