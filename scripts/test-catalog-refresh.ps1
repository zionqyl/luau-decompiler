param([switch]$NoBuild)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'env.ps1')
Add-Type -AssemblyName System.Net.Http
if(-not $NoBuild){& cargo build --manifest-path (Join-Path $taskRoot 'Cargo.toml') --offline --locked --example executor_catalog;if($LASTEXITCODE -ne 0){throw 'Catalog normalizer build failed.'}}
$directory=Join-Path $taskRoot ('artifacts/catalog-http-tests-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $directory | Out-Null
$cache=Join-Path $directory 'cache'
$output=Join-Path $directory 'result.json'
$matrix=Join-Path $directory 'matrix.md'
$refresh=Join-Path $PSScriptRoot 'refresh-executors.ps1'
$utf8=[Text.UTF8Encoding]::new($false)
$cases=[Collections.Generic.List[object]]::new()
function Check([bool]$Condition,[string]$Message){if(-not $Condition){throw $Message}}
function Refresh([scriptblock]$Fixture,[switch]$Force,[switch]$Offline,[string]$CachePath=$cache){
    & $refresh -NoBuild -CacheDirectory $CachePath -Destination $output -Matrix $matrix -MaxRetries 0 -ResponseFixture $Fixture -Force:$Force -Offline:$Offline
    return (Get-Content -LiteralPath $output -Raw|ConvertFrom-Json)
}
function StatusResponse([int]$Code){return [Net.Http.HttpResponseMessage]::new([Enum]::ToObject([Net.HttpStatusCode],$Code))}
function Expect-Failure([scriptblock]$Work,[string]$Pattern){
    $caught=$false
    try{& $Work}catch{$caught=$true;Check ($_.Exception.Message -match $Pattern) ('Unexpected failure: '+$_.Exception.Message)}
    Check $caught 'Expected a failed refresh.'
}
$ok=Refresh -Force -Fixture {
    param($Request)
    Check (([string]::Join(',',$Request.Headers.GetValues('User-Agent'))) -ceq 'WEAO-3PService') 'Required user agent missing.'
    $response=StatusResponse 200
    $response.Headers.ETag=[Net.Http.Headers.EntityTagHeaderValue]::new('"catalog-fixture-v1"')
    $response.Content=[Net.Http.StringContent]::new('[{"title":"Madium","platform":"Windows","version":"fixture-v1","extype":"wexecutor","sunc":{"key":"excluded"}},{"title":"Madius","platform":"Windows","extype":"wexternal"}]')
    return $response
}
Check ($ok.refresh_status -eq 'fixture_http_200' -and $ok.input_entries -eq 2) 'HTTP200 fixture did not normalize.'
Check (-not ([IO.File]::ReadAllText($output)).Contains('excluded')) 'Nonallowlisted metadata leaked.'
$cases.Add(@{id='http_200_required_user_agent_allowlist';passed=$true})
$observed=$ok.observed_at_utc
$fresh=Refresh -Fixture {throw 'Fresh cache must avoid HTTP.'}
Check ($fresh.refresh_status -eq 'fixture_fresh_cache') 'Fresh cache requested HTTP.'
$cases.Add(@{id='fresh_cache_no_request';passed=$true})
$conditional=Refresh -Force -Fixture {
    param($Request)
    Check (([string]::Join(',',$Request.Headers.GetValues('If-None-Match'))) -ceq '"catalog-fixture-v1"') 'Conditional ETag missing.'
    return (StatusResponse 304)
}
Check ($conditional.refresh_status -eq 'fixture_validated_cache_304' -and $conditional.observed_at_utc -eq $observed) 'HTTP304 fabricated a new observation timestamp.'
$cases.Add(@{id='http_304_conditional_preserves_observation';passed=$true})
$limited=Refresh -Force -Fixture {$response=StatusResponse 429;$response.Headers.RetryAfter=[Net.Http.Headers.RetryConditionHeaderValue]::new([TimeSpan]::FromSeconds(120));return $response}
Check ($limited.refresh_status -eq 'fixture_rate_limited_stale_cache') 'HTTP429 did not retain a labeled stale cache.'
$cases.Add(@{id='http_429_retry_after_stale_label';passed=$true})
$cooldown=Refresh -Force -Fixture {throw 'Cooldown must avoid HTTP even with Force.'}
Check ($cooldown.refresh_status -eq 'fixture_rate_limited_stale_cache') 'Force bypassed Retry-After.'
$cases.Add(@{id='retry_after_force_cannot_bypass';passed=$true})
$offline=Refresh -Force -Offline -Fixture {throw 'Offline must avoid HTTP.'}
Check ($offline.refresh_status -eq 'fixture_offline_cache') 'Offline path requested HTTP.'
$cases.Add(@{id='offline_no_request';passed=$true})
$cacheMetadata=Join-Path $cache 'http-cache.json'
$meta=Get-Content -LiteralPath $cacheMetadata -Raw|ConvertFrom-Json;$meta.not_before_utc=$null
[IO.File]::WriteAllText($cacheMetadata,($meta|ConvertTo-Json),$utf8)
Remove-Item -LiteralPath (Join-Path $cache 'rate-limit.json')
$before=(Get-FileHash -LiteralPath (Join-Path $cache 'body.json') -Algorithm SHA256).Hash
Expect-Failure {Refresh -Force -Fixture {$response=StatusResponse 200;$response.Content=[Net.Http.StringContent]::new('not JSON');return $response}} 'normalization failed'
Check ((Get-FileHash -LiteralPath (Join-Path $cache 'body.json') -Algorithm SHA256).Hash -ceq $before) 'Bad response replaced valid cache.'
$cases.Add(@{id='invalid_200_preserves_previous_cache';passed=$true})
$empty=Join-Path $directory 'empty-cache'
Expect-Failure {Refresh -Force -CachePath $empty -Fixture {$response=StatusResponse 429;$response.Headers.RetryAfter=[Net.Http.Headers.RetryConditionHeaderValue]::new([TimeSpan]::FromSeconds(120));return $response}} 'HTTP 429'
Check (Test-Path -LiteralPath (Join-Path $empty 'rate-limit.json')) 'Uncached429 cooldown was not persisted.'
$cases.Add(@{id='uncached_429_persists_cooldown';passed=$true})
Expect-Failure {Refresh -Force -CachePath $empty -Fixture {throw 'Uncached cooldown must avoid HTTP.'}} 'cooldown remains active'
$cases.Add(@{id='uncached_cooldown_no_request';passed=$true})
[IO.File]::WriteAllText((Join-Path $cache 'body.json'),'tampered',$utf8)
Expect-Failure {Refresh -Offline -Force -Fixture {throw 'Offline must not fetch.'}} 'Offline refresh requires'
$cases.Add(@{id='cache_hash_tamper_rejected';passed=$true})
$report=@{schema=1;passed=$true;cases=$cases.Count;results=$cases.ToArray();network='none; controlled HttpResponseMessage fixtures';normalizer_sha256=(Get-FileHash -LiteralPath (Join-Path $taskRoot 'target/debug/examples/executor_catalog.exe') -Algorithm SHA256).Hash.ToLowerInvariant();script_sha256=(Get-FileHash -LiteralPath $refresh -Algorithm SHA256).Hash.ToLowerInvariant();executed_at_utc=[DateTimeOffset]::UtcNow.ToString('o')}
[IO.File]::WriteAllText((Join-Path $taskRoot 'docs/results/catalog-http-v3.json'),($report|ConvertTo-Json -Depth 8),$utf8)
Write-Output ('Controlled catalog HTTP/cache cases: '+$cases.Count+'/'+$cases.Count)
