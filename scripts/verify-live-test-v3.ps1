param(
    [Parameter(Mandatory=$true)][string]$Capture,
    [string]$FixtureManifest = (Join-Path $PSScriptRoot '../artifacts/madium-live-v3/driver.luau.manifest.json'),
    [string]$ServiceBinary = (Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [string]$Destination = (Join-Path $PSScriptRoot '../docs/results/madium-live-v3.json'),
    [int]$ConfiguredCacheMiB = 64,
    [string]$LaunchManifest,
    [int]$ClientPid = 14180
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$comparison = Join-Path $taskRoot 'target/release/examples/oracle_compare.exe'
if (-not (Test-Path -LiteralPath $comparison)) {throw 'Build cargo build --release --offline --example oracle_compare first.'}
$report = Get-Content -LiteralPath $Capture -Raw | ConvertFrom-Json
if (-not $report.ok -or -not $report.raw_restored -or -not $report.registry_cleared -or -not $report.out_of_order_restore) {throw 'Live test or restoration failed.'}
if ($report.oracle_protocol -ne 'LOBS/1' -or $report.capabilities.protocol_version -ne 2) {throw 'Unexpected protocol.'}
$version = (& $ServiceBinary --version) -replace '^luau-decompile ',''
if ($LASTEXITCODE -ne 0 -or $version -ne '0.3.0' -or $version -ne $report.capabilities.package_version) {throw 'Live service version does not match supplied v0.3 binary.'}
$manifest = Get-Content -LiteralPath $FixtureManifest -Raw | ConvertFrom-Json
$preparedDriver = $FixtureManifest -replace '\.manifest\.json$',''
if ($preparedDriver -eq $FixtureManifest -or -not (Test-Path -LiteralPath $preparedDriver) -or (Get-FileHash -LiteralPath $preparedDriver -Algorithm SHA256).Hash.ToLowerInvariant() -cne $manifest.driver_sha256) {throw 'Prepared token-free driver is missing or changed.'}
if ($manifest.schema -ne 3 -or $report.schema -ne 3 -or -not $manifest.validation_id -or $report.validation_id -cne $manifest.validation_id) {throw 'Capture does not match this prepared v0.3 test plan.'}
if ($manifest.repetitions -ne 32 -or $report.latency_repetitions -ne 32 -or $report.native.typed_comparisons -ne 33 -or $report.native.observations.Count -ne 33) {throw 'Required33 native model observations/32 timing repetitions incomplete.'}
if (-not $report.oracle_conformance.passed -or $report.oracle_conformance.negative_collision_pairs -ne 7 -or $report.oracle_conformance.unsupported_observations_rejected -ne 3) {throw 'Live oracle conformance failed.'}
foreach ($module in @(@{path='adapter/decompile.luau';expected=$manifest.adapter_sha256},@{path='adapter/live-test-v3.luau';expected=$manifest.harness_sha256})) {
    if ((Get-FileHash -LiteralPath (Join-Path $taskRoot $module.path) -Algorithm SHA256).Hash.ToLowerInvariant() -cne $module.expected) {throw 'Live adapter/harness changed after test preparation.'}
}
$expectedCases = @{}
if ($manifest.fixtures.Count -ne 4 -or $manifest.fixtures.Count -ne @(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'tests/live-corpus') -Filter '*.luau').Count) {throw 'Live fixture catalog is incomplete.'}
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
$expectedNative = '0e0300000128010000010a0004a3000000ff0000000000000082000200000001000118005a00000100000000000a00'
if ($report.native.input_hex -cne $expectedNative -or $manifest.expected_native_hex -cne $expectedNative -or -not $report.native.complete -or $report.native.path -cne 'ReplicatedStorage.SocketTypes' -or $report.native.profile -ne 'luau-v14' -or $report.native.validation.syntax -ne 'passed' -or $report.native.validation.compilation -ne 'passed' -or -not $report.native.validation.required_passed) {throw 'Native getter model or independent final-source validation changed.'}

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
if($report.distinct_known_source_native_programs -ne 0 -or $report.distinct_unknown_source_native_models -ne 1 -or $report.distinct_supplied_bytecode_programs -ne 4 -or $report.controlled_place_native_programs -ne 0){throw 'Native model/supplied/known-source counts lost their provenance boundary.'}
foreach($id in @('numeric_second_argument','native_options_table','function_target','raw_native_target')){if(-not $report.native_api.$id.rejected -or [string]::IsNullOrEmpty($report.native_api.$id.error)){throw ('Native Madium contract rejection missing: '+$id)}}
if(-not $report.settings.source_changed -or $report.settings.source -ceq $report.settings.baseline_source -or $report.settings.configuration.indent -cne '  ' -or $report.settings.configuration.naming -ne 'camelCase' -or $report.settings.configuration.typing.mode -ne 'off' -or $report.settings.configuration.validation.mode -ne 'off' -or $report.settings.validation.strict_analysis -ne 'not_run' -or $report.settings.type_report.emitted_annotations -ne 0 -or $report.settings_comparisons.Count -ne 5){throw 'Canonical per-request settings test is incomplete.'}
$settingsFixture=$manifest.fixtures[0];$remainingSeeds=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
foreach($seed in @(-3,0,1,7,29)){[void]$remainingSeeds.Add([string]$seed)}
foreach($row in $report.settings_comparisons){if($row.id -cne $settingsFixture.id -or $row.source_sha256 -cne $settingsFixture.source_sha256 -or $row.bytecode_sha256 -cne $settingsFixture.bytecode_sha256 -or -not $remainingSeeds.Remove([string]$row.seed)){throw 'Settings observations lost exact fixture/seed identities.'}}
if($remainingSeeds.Count -ne 0 -or $report.malformed_diagnostic.stage -ne 'decode' -or $report.malformed_diagnostic.status -ne 422 -or $report.malformed_diagnostic.offset -ne $settingsFixture.bytes -or [string]::IsNullOrEmpty($report.malformed_diagnostic.request_id)){throw 'Structured malformed-input diagnostic or settings inputs are incomplete.'}
$frames = Join-Path $taskRoot 'artifacts/madium-live-v3/observations'
New-Item -ItemType Directory -Force -Path $frames | Out-Null
$all = @(foreach ($actual in $report.native.observations) { [pscustomobject]@{complete=$true;expected=$report.native.expected;actual=$actual} }) + @($report.comparisons) + @($report.settings_comparisons)
if($all.Count -ne 58){throw 'Required58 typed native-model/supplied/settings comparisons are incomplete.'}
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
$metrics = [ordered]@{samples=$sorted.Count;p50_ms=$sorted[[Math]::Ceiling($sorted.Count*.50)-1];p95_ms=$sorted[[Math]::Ceiling($sorted.Count*.95)-1];max_ms=$sorted[-1];cold_ms=$report.cold_adapter_ms;raw_ms=$latencies;timing='Executor getter through base64, HTTP service/cache path, JSON and yielding adapter completion; excludes recompilation and behavioral probes. First adapter request includes handshake; prior service/analyzer/OS cache warmth is not established. With a configured64MiB service cache, repetitions do not imply repeated CPU reconstruction.';configured_service_cache_mib=$ConfiguredCacheMiB;cache_setting_evidence='Host launch parameter recorded by test operator, not independently inferred from timing or per-response cache headers.'}
$report | Add-Member -NotePropertyName latency -NotePropertyValue $metrics
$report | Add-Member -NotePropertyName verified_at -NotePropertyValue ([DateTime]::UtcNow.ToString('o'))
$report | Add-Member -NotePropertyName service_binary_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $ServiceBinary -Algorithm SHA256).Hash.ToLowerInvariant()
$report | Add-Member -NotePropertyName service_binary_evidence -NotePropertyValue 'Operator-supplied binary hash; independently checked package-version equality with handshake, not remote process image attestation.'
if($LaunchManifest){
    $launch=Get-Content -LiteralPath $LaunchManifest -Raw|ConvertFrom-Json
    if($launch.executable_sha256 -cne (Get-FileHash -LiteralPath $ServiceBinary -Algorithm SHA256).Hash.ToLowerInvariant() -or $launch.endpoint -cne $manifest.endpoint -or $launch.cache_mib -ne $ConfiguredCacheMiB -or $launch.package_version -ne '0.3.0'){throw 'Host launch attestation does not match live endpoint/configuration/binary.'}
    $report|Add-Member -NotePropertyName host_launch_attestation -NotePropertyValue $launch
    $report|Add-Member -NotePropertyName host_launch_attestation_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $LaunchManifest -Algorithm SHA256).Hash.ToLowerInvariant()
}
$report | Add-Member -NotePropertyName oracle_comparator_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $comparison -Algorithm SHA256).Hash.ToLowerInvariant()
$report | Add-Member -NotePropertyName fixtures -NotePropertyValue $manifest
$report | Add-Member -NotePropertyName verified_typed_comparisons -NotePropertyValue $all.Count
$report | Add-Member -NotePropertyName client_pid_operator_record -NotePropertyValue $ClientPid
$report | Add-Member -NotePropertyName provenance -NotePropertyValue 'One native SocketTypes getter packet has unknown original source; normalized bytes match the independently proven padded empty-table model.33 observations are repetitions of that model, not33native programs. Four supplied known-source fixtures have20observations plus5settings-variant observations. No controlled-place known-source normal-engine programs or function dumps were verified. Native options rejection, structured diagnostics and restoration are separate API checks.'
$report | Add-Member -NotePropertyName capture_sha256 -NotePropertyValue (Get-FileHash -LiteralPath $Capture -Algorithm SHA256).Hash.ToLowerInvariant()
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
[IO.File]::WriteAllText($Destination,($report | ConvertTo-Json -Depth 24),[Text.UTF8Encoding]::new($false))
Write-Output ('Verified ' + $report.verified_typed_comparisons + ' typed live comparisons; p50=' + $metrics.p50_ms + 'ms p95=' + $metrics.p95_ms + 'ms; wrote ' + $Destination)
