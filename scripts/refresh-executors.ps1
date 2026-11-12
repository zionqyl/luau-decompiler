param(
    [string]$CacheDirectory = (Join-Path $PSScriptRoot '../artifacts/executor-catalog-cache'),
    [string]$Destination = (Join-Path $PSScriptRoot '../docs/results/executor-catalog-v3.json'),
    [string]$Matrix = (Join-Path $PSScriptRoot '../docs/executors-v3.md'),
    [string]$InputSnapshot,
    [ValidateRange(0,86400)][int]$TtlSeconds = 3600,
    [ValidateRange(0,5)][int]$MaxRetries = 2,
    [switch]$Offline,
    [switch]$Force,
    [switch]$NoBuild,
    [Parameter(DontShow=$true)][scriptblock]$ResponseFixture
)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'env.ps1')
$endpoint='https://weao.xyz/api/status/exploits'
$userAgent='WEAO-3PService'
$maximumBytes=4*1024*1024
$utf8=[Text.UTF8Encoding]::new($false)
New-Item -ItemType Directory -Force -Path $CacheDirectory | Out-Null
$CacheDirectory=(Resolve-Path -LiteralPath $CacheDirectory).Path
$cacheLock=$null
try {$cacheLock=[IO.File]::Open((Join-Path $CacheDirectory 'refresh.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)} catch {throw 'Another catalog refresh owns this cache; retry after it finishes.'}
try {
$bodyPath=Join-Path $CacheDirectory 'body.json'
$metadataPath=Join-Path $CacheDirectory 'http-cache.json'
$cooldownPath=Join-Path $CacheDirectory 'rate-limit.json'
$candidatePath=Join-Path $CacheDirectory 'candidate.json'
$metadata=$null
if ((Test-Path -LiteralPath $metadataPath) -and (Test-Path -LiteralPath $bodyPath)) {
    try {
        $metadata=Get-Content -LiteralPath $metadataPath -Raw|ConvertFrom-Json
        if ($metadata.source_url -cne $endpoint -or $metadata.user_agent -cne $userAgent -or
            (Get-FileHash -LiteralPath $bodyPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $metadata.raw_sha256) {$metadata=$null}
    } catch {$metadata=$null}
}
function Read-Limited([IO.Stream]$Stream) {
    $memory=[IO.MemoryStream]::new();$scratch=New-Object byte[] 16384
    try {
        while (($count=$Stream.Read($scratch,0,$scratch.Length)) -ne 0) {
            if ($memory.Length+$count -gt $maximumBytes) {throw 'Catalog response exceeds 4 MiB.'}
            $memory.Write($scratch,0,$count)
        }
        return ,$memory.ToArray()
    } finally {$memory.Dispose()}
}
function Save-CacheMetadata($Value) {
    [IO.File]::WriteAllText($metadataPath,($Value|ConvertTo-Json -Depth 8),$utf8)
}
$now=[DateTimeOffset]::UtcNow
$status=''
$catalogInput=$null
$observed=$null
$pendingMetadata=$null
$cooldown=$null
if (Test-Path -LiteralPath $cooldownPath) {try{$cooldown=Get-Content -LiteralPath $cooldownPath -Raw|ConvertFrom-Json;$null=[DateTimeOffset]::Parse($cooldown.not_before_utc)}catch{$cooldown=$null}}
if ($InputSnapshot) {
    $catalogInput=(Resolve-Path -LiteralPath $InputSnapshot).Path
    if ((Get-Item -LiteralPath $catalogInput).Length -gt $maximumBytes) {throw 'Catalog snapshot exceeds 4 MiB.'}
    $observed=(Get-Item -LiteralPath $catalogInput).LastWriteTimeUtc.ToString('o')
    $status='imported_snapshot'
} elseif ($metadata -and -not $Force -and
    ($now-[DateTimeOffset]::Parse($metadata.validated_at_utc)).TotalSeconds -lt $TtlSeconds) {
    $catalogInput=$bodyPath;$observed=$metadata.observed_at_utc;$status='fresh_cache'
} elseif ($Offline) {
    if (-not $metadata) {throw 'Offline refresh requires an intact cached body/metadata pair or -InputSnapshot.'}
    $catalogInput=$bodyPath;$observed=$metadata.observed_at_utc;$status='offline_cache'
} elseif ($cooldown -and $now -lt [DateTimeOffset]::Parse($cooldown.not_before_utc)) {
    if (-not $metadata) {throw ('Catalog Retry-After cooldown remains active until '+$cooldown.not_before_utc+'; no cached inventory is available.')}
    $catalogInput=$bodyPath;$observed=$metadata.observed_at_utc;$status='rate_limited_stale_cache'
} elseif ($metadata -and $metadata.not_before_utc -and $now -lt [DateTimeOffset]::Parse($metadata.not_before_utc)) {
    $catalogInput=$bodyPath;$observed=$metadata.observed_at_utc;$status='rate_limited_stale_cache'
} else {
    Add-Type -AssemblyName System.Net.Http
    $previousTls=[Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol=$previousTls -bor [Net.SecurityProtocolType]::Tls12
    $handler=[Net.Http.HttpClientHandler]::new();$handler.AllowAutoRedirect=$false
    $client=[Net.Http.HttpClient]::new($handler);$client.Timeout=[TimeSpan]::FromSeconds(20)
    try {
        for ($attempt=0;$attempt -le $MaxRetries;$attempt++) {
            $request=[Net.Http.HttpRequestMessage]::new([Net.Http.HttpMethod]::Get,$endpoint)
            $null=$request.Headers.TryAddWithoutValidation('User-Agent',$userAgent)
            $null=$request.Headers.TryAddWithoutValidation('Accept','application/json')
            if ($metadata -and $metadata.etag) {$null=$request.Headers.TryAddWithoutValidation('If-None-Match',[string]$metadata.etag)}
            if ($metadata -and $metadata.last_modified) {$null=$request.Headers.TryAddWithoutValidation('If-Modified-Since',[string]$metadata.last_modified)}
            $response=$null
            try {
                $response=if($ResponseFixture){& $ResponseFixture $request}else{$client.SendAsync($request,[Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()}
                $code=[int]$response.StatusCode
                if ($code -eq 304) {
                    if (-not $metadata) {throw 'HTTP 304 without an intact cached representation.'}
                    $metadata.validated_at_utc=[DateTimeOffset]::UtcNow.ToString('o');$metadata.not_before_utc=$null
                    if(Test-Path -LiteralPath $cooldownPath){Remove-Item -LiteralPath $cooldownPath}
                    Save-CacheMetadata $metadata
                    $catalogInput=$bodyPath;$observed=$metadata.observed_at_utc;$status='validated_cache_304';break
                }
                if ($code -eq 429) {
                    $retrySeconds=60.0
                    if ($response.Headers.RetryAfter) {
                        if ($response.Headers.RetryAfter.Delta) {$retrySeconds=$response.Headers.RetryAfter.Delta.TotalSeconds}
                        elseif ($response.Headers.RetryAfter.Date) {$retrySeconds=($response.Headers.RetryAfter.Date-[DateTimeOffset]::UtcNow).TotalSeconds}
                    }
                    $retrySeconds=[Math]::Max(1,[Math]::Min(86400,$retrySeconds))
                    [IO.File]::WriteAllText($cooldownPath,(@{not_before_utc=[DateTimeOffset]::UtcNow.AddSeconds($retrySeconds).ToString('o')}|ConvertTo-Json),$utf8)
                    if ($metadata) {
                        $metadata.not_before_utc=[DateTimeOffset]::UtcNow.AddSeconds($retrySeconds).ToString('o');Save-CacheMetadata $metadata
                        $catalogInput=$bodyPath;$observed=$metadata.observed_at_utc;$status='rate_limited_stale_cache';break
                    }
                    throw ('Catalog HTTP 429; honor Retry-After for '+[Math]::Ceiling($retrySeconds)+' seconds. No cached inventory is available.')
                }
                if ($code -ne 200) {throw ('Catalog HTTP '+$code)}
                if ($response.Content.Headers.ContentLength -and $response.Content.Headers.ContentLength -gt $maximumBytes) {throw 'Catalog response exceeds 4 MiB.'}
                $stream=$response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
                try {$bytes=Read-Limited $stream} finally {$stream.Dispose()}
                [IO.File]::WriteAllBytes($candidatePath,$bytes)
                $observed=[DateTimeOffset]::UtcNow.ToString('o');$catalogInput=$candidatePath;$status='http_200'
                if(Test-Path -LiteralPath $cooldownPath){Remove-Item -LiteralPath $cooldownPath}
                $pendingMetadata=[ordered]@{schema=1;source_url=$endpoint;user_agent=$userAgent;controlled_fixture=[bool]$ResponseFixture;observed_at_utc=$observed;validated_at_utc=$observed;etag=if($response.Headers.ETag){$response.Headers.ETag.ToString()}else{$null};last_modified=if($response.Content.Headers.LastModified){$response.Content.Headers.LastModified.ToString()}else{$null};not_before_utc=$null;raw_sha256=(Get-FileHash -LiteralPath $candidatePath -Algorithm SHA256).Hash.ToLowerInvariant()}
                break
            } catch {
                if ($_.Exception.Message -match 'HTTP 429') {throw}
                if ($attempt -lt $MaxRetries) {Start-Sleep -Milliseconds ([Math]::Min(4000,500*[Math]::Pow(2,$attempt)));continue}
                if ($metadata) {$catalogInput=$bodyPath;$observed=$metadata.observed_at_utc;$status='network_failure_stale_cache';break}
                $failureKind=if($response){'HTTP '+[int]$response.StatusCode}else{$_.Exception.GetBaseException().GetType().Name}
                throw ('Catalog refresh failed ('+$failureKind+') without a cached inventory; no compatibility claim was produced.')
            } finally {if($response){$response.Dispose()};$request.Dispose()}
        }
    } finally {$client.Dispose();$handler.Dispose();[Net.ServicePointManager]::SecurityProtocol=$previousTls}
}
if (-not $catalogInput) {throw 'Catalog refresh produced no bounded representation.'}
Push-Location $taskRoot
try {
    if (-not $NoBuild) {& cargo build --offline --locked --example executor_catalog;if($LASTEXITCODE -ne 0){throw 'Catalog normalizer build failed.'}}
    $normalizer=Join-Path $taskRoot 'target/debug/examples/executor_catalog.exe'
    if (-not (Test-Path -LiteralPath $normalizer)) {throw 'Catalog normalizer missing; omit -NoBuild.'}
    & $normalizer $catalogInput $Destination $observed $status $Matrix
    if ($LASTEXITCODE -ne 0) {throw 'Catalog normalization failed; previous HTTP cache retained.'}
    if ($pendingMetadata) {

        Copy-Item -LiteralPath $candidatePath -Destination $bodyPath -Force
        Save-CacheMetadata $pendingMetadata
    }
    if ($InputSnapshot -or $ResponseFixture -or ($metadata -and $metadata.controlled_fixture)) {
        $report=Get-Content -LiteralPath $Destination -Raw|ConvertFrom-Json
        if($InputSnapshot){$report.observation_provenance='Imported existing HTTP snapshot supplied by the caller. observed_at_utc is the raw snapshot file timestamp, not a new HTTP request or independent runtime measurement.'}
        else{
            $report.observation_provenance='Controlled HTTP response fixture for transport/cache tests; not live catalog evidence.'
            $report.refresh_status='fixture_'+$report.refresh_status
            [IO.File]::WriteAllText($Matrix,('CONTROLLED HTTP FIXTURE: not live catalog evidence.'+"`n`n"+[IO.File]::ReadAllText($Matrix)),$utf8)
        }
        [IO.File]::WriteAllText($Destination,($report|ConvertTo-Json -Depth 16),$utf8)
    }
    Write-Output ('Catalog refresh status: '+$status+'; '+$Destination)
} finally {Pop-Location}
} finally {if($cacheLock){$cacheLock.Dispose()}}
