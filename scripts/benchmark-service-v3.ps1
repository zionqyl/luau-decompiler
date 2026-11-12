[CmdletBinding()]
param(
    [string]$Binary=(Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [string]$Destination=(Join-Path $PSScriptRoot '../artifacts/v3-performance/service'),
    [ValidateRange(1,200)][int]$Samples=20,
    [ValidateRange(1,4)][int]$CpuThreads=2,
    [ValidateRange(30,1800)][int]$MaximumSeconds=600
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
. (Join-Path $PSScriptRoot 'release-integrity.ps1')
$taskRoot=Split-Path -Parent $PSScriptRoot
Add-Type -AssemblyName System.Net.Http
$Binary=(Resolve-Path -LiteralPath $Binary).Path
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination=(Resolve-Path -LiteralPath $Destination).Path
$utf8=[Text.UTF8Encoding]::new($false)
$reportPath=Join-Path $Destination 'report.json'
$publishedReport=Join-Path $taskRoot 'docs/results/service-performance-v3.json'
$running='{"schema":1,"version":"0.3.0","passed":false,"state":"running","adapter_latency":"not_measured"}'
[IO.File]::WriteAllText($reportPath,$running,$utf8);[IO.File]::WriteAllText($publishedReport,$running,$utf8)
$campaign=[Diagnostics.Stopwatch]::StartNew()
$binaryHash=(Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash.ToLowerInvariant()
$measuredDriver=[IO.File]::ReadAllBytes($PSCommandPath)
$driverHash=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()
function Digest([byte[]]$Bytes) {
    $sha=[Security.Cryptography.SHA256]::Create()
    try {return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant()} finally {$sha.Dispose()}
}
function Check-Deadline {
    if($campaign.Elapsed.TotalSeconds -gt $MaximumSeconds){throw 'Service benchmark exceeded its bounded campaign deadline.'}
}
function Quantiles($Values) {
    $sorted=@($Values|Sort-Object)
    if($sorted.Count -eq 0){return $null}
    $sum=($sorted|Measure-Object -Sum).Sum
    return [ordered]@{samples=$sorted.Count;min=$sorted[0];p50=$sorted[[Math]::Max(0,[Math]::Ceiling($sorted.Count*0.50)-1)];p95=$sorted[[Math]::Max(0,[Math]::Ceiling($sorted.Count*0.95)-1)];max=$sorted[-1];mean=$sum/$sorted.Count}
}
function Sample-Memory($Server) {
    $Server.process.Refresh()
    try {$Server.parent_peak=[Math]::Max($Server.parent_peak,$Server.process.PeakWorkingSet64);$current=$Server.process.WorkingSet64} catch {$current=0L}
    try {
        $children=@(Get-CimInstance Win32_Process -Filter ('ParentProcessId='+$Server.process.Id) -OperationTimeoutSec 3 -ErrorAction Stop)
        $Server.child_discovery='Windows CIM parent-PID query at request boundaries'
        foreach($child in $children) {
            $id=[int]$child.ProcessId
            if(-not $Server.children.ContainsKey($id)) {
                try {$observed=[Diagnostics.Process]::GetProcessById($id);$Server.children[$id]=@{process=$observed;name=$observed.ProcessName;peak=0L}} catch {continue}
            }
        }
    } catch {$Server.child_discovery='unavailable; parent RSS only: '+$_.Exception.GetType().Name}
    foreach($child in $Server.children.Values) {
        try {if(-not $child.process.HasExited){$child.process.Refresh();$child.peak=[Math]::Max($child.peak,$child.process.PeakWorkingSet64);$current+=$child.process.WorkingSet64}} catch {}
    }
    $Server.aggregate_sample_peak=[Math]::Max($Server.aggregate_sample_peak,$current)
}
function Memory-Report($Server) {
    $children=@($Server.children.GetEnumerator()|Sort-Object Key|ForEach-Object {@{pid=$_.Key;name=$_.Value.name;peak_working_set_bytes=$_.Value.peak}})
    return [ordered]@{parent_pid=$Server.process.Id;parent_peak_working_set_bytes=$Server.parent_peak;child_discovery=$Server.child_discovery;children=$children;sum_individual_peak_working_set_bytes=$Server.parent_peak+(@($children|ForEach-Object {$_.peak_working_set_bytes})|Measure-Object -Sum).Sum;sampled_aggregate_working_set_peak_bytes=$Server.aggregate_sample_peak;note='Parent/child Windows PeakWorkingSet64 high-water counters sampled after requests. Sum of individual peaks is not a simultaneous peak. Aggregate WorkingSet64 is sampled only at request boundaries and can miss transients. Startup/priming memory is included; child absence is distinct from unavailable discovery.'}
}
function Start-Server([string]$Id,[hashtable]$Configuration,[int]$CacheMiB) {
    Check-Deadline
    $directory=Join-Path $Destination $Id
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $configurationPath=Join-Path $directory 'config.json'
    [IO.File]::WriteAllText($configurationPath,($Configuration|ConvertTo-Json -Depth 10),$utf8)
    $bytes=New-Object byte[] 32;$rng=[Security.Cryptography.RandomNumberGenerator]::Create();$rng.GetBytes($bytes);$rng.Dispose();$token=[Convert]::ToBase64String($bytes)
    $start=[Diagnostics.ProcessStartInfo]::new($Binary)
    $start.WorkingDirectory=$taskRoot
    $start.Arguments='serve --listen 127.0.0.1:0 --workers 2 --cpu-threads '+$CpuThreads+' --queue 4 --memory-mib 1024 --cache-mib '+$CacheMiB+' --timeout-ms 20000 --config "'+$configurationPath+'"'
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true

    $start.EnvironmentVariables['LUAU_DECOMPILER_TOKEN']=$token
    $watch=[Diagnostics.Stopwatch]::StartNew()
    $process=[Diagnostics.Process]::Start($start)
    $stdout=$process.StandardOutput.ReadToEndAsync()
    $handler=[Net.Http.HttpClientHandler]::new();$handler.UseProxy=$false
    $client=[Net.Http.HttpClient]::new($handler);$client.Timeout=[TimeSpan]::FromSeconds(25)
    $client.DefaultRequestHeaders.ExpectContinue=$false
    $client.DefaultRequestHeaders.Authorization=[Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer',$token)
    $server=@{process=$process;stdout=$stdout;client=$client;handler=$handler;children=@{};parent_peak=0L;aggregate_sample_peak=0L;child_discovery='not_sampled';directory=$directory;configuration=$Configuration;config_sha256=(Get-FileHash -LiteralPath $configurationPath -Algorithm SHA256).Hash.ToLowerInvariant()}
    try {
        $read=$process.StandardError.ReadLineAsync();$lines=[Collections.Generic.List[string]]::new();$address=$null
        while($watch.Elapsed.TotalSeconds -lt 20 -and -not $process.HasExited) {
            Check-Deadline
            if($read.Wait(25)) {
                $line=$read.Result
                if($null -eq $line){break}
                $lines.Add($line)
                if($line -match '^bridge listening on http://(127\.0\.0\.1:\d+)/v1/decompile '){$address=$Matches[1];break}
                if($lines.Count -gt 32){throw 'Unexpected excessive service startup diagnostics.'}
                $read=$process.StandardError.ReadLineAsync()
            }
        }
        if(-not $address){throw ('Service did not bind its isolated port: '+[string]::Join(' | ',$lines))}
        $server.stderr=$process.StandardError.ReadToEndAsync();$server.startup_lines=$lines.ToArray();$server.base='http://'+$address
        $response=$client.GetAsync($server.base+'/v1/capabilities').GetAwaiter().GetResult()
        $caps=$response.Content.ReadAsStringAsync().GetAwaiter().GetResult()|ConvertFrom-Json
        if(-not $response.IsSuccessStatusCode -or $caps.package_version -ne '0.3.0' -or $caps.protocol_version -ne 2 -or -not $caps.features.per_request_settings){throw 'Expected v0.3 bounded service capabilities.'}
        $watch.Stop();$server.startup_ms=$watch.Elapsed.TotalMilliseconds;$server.capabilities=$caps
        Sample-Memory $server
        return $server
    } catch {Stop-Server $server;throw}
}
function Stop-Server($Server) {
    if($null -eq $Server){return}
    try {
        Sample-Memory $Server
        foreach($child in $Server.children.Values){try {if(-not $child.process.HasExited){$child.process.Kill();$child.process.WaitForExit()}} catch {}; $child.process.Dispose()}
        if(-not $Server.process.HasExited){$Server.process.Kill();$Server.process.WaitForExit()}
        if($Server.stderr){[IO.File]::WriteAllText((Join-Path $Server.directory 'service.stderr'),([string]::Join("`n",$Server.startup_lines)+"`n"+$Server.stderr.Result),$utf8)}
    } finally {$Server.client.Dispose();$Server.handler.Dispose();$Server.process.Dispose()}
}
function Request($Server,[hashtable]$Patch=@{}) {
    Check-Deadline
    $body=@{bytecode_base64=$script:encodedBytecode;reconstruction_config=$Patch}|ConvertTo-Json -Depth 10 -Compress
    $content=[Net.Http.StringContent]::new($body,$utf8,'application/json')
    $clock=[Diagnostics.Stopwatch]::StartNew()
    try {$response=$Server.client.PostAsync($Server.base+'/v1/decompile',$content).GetAwaiter().GetResult();$payload=$response.Content.ReadAsStringAsync().GetAwaiter().GetResult();$clock.Stop()} finally {$content.Dispose()}
    if(-not $response.IsSuccessStatusCode){throw ('Service request failed ('+[int]$response.StatusCode+'): '+$payload)}

    $result=$payload|ConvertFrom-Json
    if(-not $result.complete -or [string]::IsNullOrEmpty($result.source)){throw 'Incomplete reconstruction is not a successful timing sample.'}
    $cache='absent';if($response.Headers.Contains('X-Decompiler-Cache')){$cache=[string]::Join(',',$response.Headers.GetValues('X-Decompiler-Cache'))}
    $sourceHash=Digest ($utf8.GetBytes($result.source))
    $row=[ordered]@{latency_ms=$clock.Elapsed.TotalMilliseconds;response_bytes=$utf8.GetByteCount($payload);complete=$result.complete;source_sha256=$sourceHash;service_cache=$cache;stats=$result.stats;syntax=$result.validation.syntax;compilation=$result.validation.compilation;strict_analysis=$result.validation.strict_analysis;required_passed=$result.validation.required_passed;analyzer_cache_hit=$result.validation.cache_hit;analyzer_micros=$result.validation.analyzer_micros;compiler_micros=$result.validation.compiler_micros;analyzer_sha256=$result.validation.analyzer_sha256;definitions_sha256=$result.validation.definitions_sha256;context_sha256=$result.validation.context_sha256;useful_emitted_annotations=$result.type_report.emitted_useful_annotations;selected_strategy=$result.validation.selected_strategy}
    $response.Dispose();Sample-Memory $Server
    return $row
}
function Assert-Strict($Row) {
    if($Row.syntax -ne 'passed' -or $Row.compilation -ne 'passed' -or $Row.strict_analysis -ne 'passed' -or -not $Row.required_passed -or $Row.analyzer_sha256 -cne $script:qualityTools.analyzer_sha256 -or $Row.definitions_sha256 -cne $script:qualityTools.definitions_sha256){throw 'Strict-positive benchmark fixture failed independent source/strict/provenance gates.'}
}
function Summarize([string]$Name,$Rows,$Processes,[string]$Note) {
    $phase=[ordered]@{}
    foreach($phaseName in @('decode_micros','reconstruct_micros','type_infer_micros','format_micros','validation_micros','total_micros')){$phase[$phaseName]=Quantiles @($Rows|ForEach-Object {$_.stats.$phaseName})}
    $milliseconds=($Rows|ForEach-Object {$_.latency_ms}|Measure-Object -Sum).Sum
    return [ordered]@{name=$Name;requests=$Rows.Count;distinct_source_programs=1;latency_ms=(Quantiles @($Rows|ForEach-Object {$_.latency_ms}));serial_http_requests_per_second=1000*$Rows.Count/$milliseconds;phase_distributions=$phase;analyzer_micros=(Quantiles @($Rows|ForEach-Object {$_.analyzer_micros}));compiler_micros=(Quantiles @($Rows|ForEach-Object {$_.compiler_micros}));source_sha256=@($Rows|ForEach-Object {$_.source_sha256}|Sort-Object -Unique);service_cache_counts=@($Rows|Group-Object service_cache|ForEach-Object {@{status=$_.Name;count=$_.Count}});analyzer_cache_hits=@($Rows|Where-Object {$_.analyzer_cache_hit}).Count;processes=$Processes;note=$Note;samples=$Rows}
}

Push-Location $taskRoot
try {
    $script:qualityTools=Get-QualityToolProvenance
    $profileLock=Get-Content -LiteralPath upstream.profiles.lock.json -Raw|ConvertFrom-Json
    $pin=@($profileLock.profiles|Where-Object {$_.tag -eq '0.746'})[0]
    $compiler=(Resolve-Path -LiteralPath .tools/luau-modern/luau-compile.exe).Path
    if((Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash.ToLowerInvariant() -cne $pin.windows_compiler_sha256){throw 'Service corpus compiler pin mismatch.'}
    $source="local value: number = 41`nlocal result: number = value + 1`nreturn result`n"
    $sourcePath=Join-Path $Destination 'known-source-scalar.luau';[IO.File]::WriteAllText($sourcePath,$source,$utf8)
    $compile=[Diagnostics.ProcessStartInfo]::new($compiler)
    $compile.Arguments='--binary -O0 -g2 -t1 --fflags=LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false "'+$sourcePath+'"'
    $compile.UseShellExecute=$false;$compile.CreateNoWindow=$true;$compile.RedirectStandardOutput=$true;$compile.RedirectStandardError=$true
    $child=[Diagnostics.Process]::Start($compile);$memory=[IO.MemoryStream]::new();$errorTask=$child.StandardError.ReadToEndAsync();$child.StandardOutput.BaseStream.CopyTo($memory);$child.WaitForExit();$bytecode=$memory.ToArray()
    if($child.ExitCode -ne 0 -or $bytecode.Length -eq 0 -or $bytecode[0] -ne 14){throw ('Known-source compiler failed: '+$errorTask.Result)}
    $child.Dispose();$memory.Dispose();[IO.File]::WriteAllBytes((Join-Path $Destination 'known-source-scalar.bc'),$bytecode);$script:encodedBytecode=[Convert]::ToBase64String($bytecode)
    $proofs=[ordered]@{}
    $preflight=Start-Server 'preflight-not-timed' @{typing=@{mode='annotated'};validation=@{mode='strict_required';max_workers=1;max_cache_bytes=0}} 0
    try {foreach($mode in @('off','annotated')){$row=Request $preflight @{typing=@{mode=$mode}};Assert-Strict $row;$proofs[$mode]=$row}} finally {Stop-Server $preflight}
    $groups=[Collections.Generic.List[object]]::new()
    foreach($group in @(
        @{name='faithful_core_validation_off';typing='off';validation='off';analyzer_cache=0;service_cache=0;prime=$false;fresh_each=$false},
        @{name='annotated_core_validation_off';typing='annotated';validation='off';analyzer_cache=0;service_cache=0;prime=$false;fresh_each=$false},
        @{name='analyzer_first_request_new_process';typing='annotated';validation='strict_required';analyzer_cache=0;service_cache=0;prime=$false;fresh_each=$true},
        @{name='persistent_analyzer_no_result_cache';typing='annotated';validation='strict_required';analyzer_cache=0;service_cache=0;prime=$true;fresh_each=$false},
        @{name='analyzer_result_cache_hits';typing='annotated';validation='strict_required';analyzer_cache=16777216;service_cache=0;prime=$true;fresh_each=$false},
        @{name='service_cache_hits';typing='annotated';validation='strict_required';analyzer_cache=16777216;service_cache=4;prime=$true;fresh_each=$false}
    )) {
        $rows=[Collections.Generic.List[object]]::new();$processes=[Collections.Generic.List[object]]::new();$server=$null
        try {
            for($i=0;$i -lt $Samples;$i++) {
                if($null -eq $server){$server=Start-Server ($group.name+'/'+$i) @{typing=@{mode=$group.typing};validation=@{mode=$group.validation;max_workers=1;max_cache_bytes=$group.analyzer_cache}} $group.service_cache;if($group.prime){$priming=Request $server;Assert-Strict $priming}}
                $row=Request $server
                if($row.source_sha256 -cne $proofs[$group.typing].source_sha256){throw ($group.name+': timed source differs from independently strict-checked source.')}
                if($group.validation -eq 'off'){if($row.strict_analysis -ne 'not_run'){throw 'Disabled validation was unexpectedly measured.'}} else {Assert-Strict $row}
                if($group.name -eq 'service_cache_hits'){if($row.service_cache -ne 'hit'){throw 'Expected service cache hit.'}}
                elseif($row.service_cache -eq 'hit'){throw 'Service cache polluted a non-cache scenario.'}
                if($group.name -eq 'analyzer_result_cache_hits'){if(-not $row.analyzer_cache_hit){throw 'Expected independent analyzer cache hit.'}}
                elseif($group.name -ne 'service_cache_hits' -and $row.analyzer_cache_hit){throw 'Analyzer cache polluted an uncached scenario.'}
                $rows.Add($row)
                if($group.fresh_each -or $i -eq $Samples-1){$processes.Add(@{startup_ms=$server.startup_ms;configuration=$server.configuration;config_sha256=$server.config_sha256;memory=(Memory-Report $server)});Stop-Server $server;$server=$null}
            }
        } finally {if($server){Stop-Server $server}}
        $note=if($group.validation -eq 'off'){'Validation excluded from timed path; every emitted source hash equals a separately independently strict-checked preflight output.'}elseif($group.name -eq 'service_cache_hits'){'Reported server phase/quality statistics belong to the original cached computation, not current cache-hit CPU work.'}elseif($group.name -eq 'analyzer_result_cache_hits'){'Rust reconstruction/typing/formatting rerun; independent analyzer result is cached. Backend compiler/analyzer microsecond fields are zero because backend work is skipped.'}elseif($group.fresh_each){'Each sample uses a fresh service and first analyzer request; service startup/capabilities excluded, analyzer process/bootstrap included. OS executable/file caches are uncontrolled.'}else{'One priming request excluded; persistent analyzer worker reused, service and analyzer result caches disabled.'}
        $groups.Add((Summarize $group.name $rows.ToArray() $processes.ToArray() $note))
        Write-Output ($group.name+': '+$rows.Count+' gated HTTP samples')
    }
    if((Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash.ToLowerInvariant() -cne $binaryHash){throw 'Executable changed during service measurement.'}
    if((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $driverHash){throw 'Service measurement driver changed during timing.'}
    $toolsAfter=Get-QualityToolProvenance
    if(($toolsAfter|ConvertTo-Json -Compress) -cne ($script:qualityTools|ConvertTo-Json -Compress)){throw 'Analyzer/definitions changed during service measurement.'}
    $report=[ordered]@{schema=1;version='0.3.0';passed=$true;measured_at_utc=[DateTime]::UtcNow.ToString('o');executable_sha256=$binaryHash;script_sha256=$driverHash;measured_driver_base64=[Convert]::ToBase64String($measuredDriver);compiler_revision=$pin.revision;compiler_sha256=$pin.windows_compiler_sha256;compiler_settings=@{optimization=0;debug=2;type_information=1;format=14;flags='LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false'};quality_tools=$script:qualityTools;source_program=$source;source_sha256=(Digest ($utf8.GetBytes($source)));bytecode_base64=$script:encodedBytecode;bytecode_sha256=(Digest $bytecode);input_bytes=$bytecode.Length;distinct_known_source_programs=1;distinct_native_programs=0;samples_per_group=$Samples;cpu_threads=$CpuThreads;server_workers=2;queue_bound=4;memory_limit_bytes=1073741824;maximum_campaign_seconds=$MaximumSeconds;strict_preflight_outputs=$proofs;groups=$groups.ToArray();timing_scope='Serial authenticated localhost HTTP until complete response text received. Request base64/JSON construction, response JSON interpretation, memory queries, service startup/capabilities and behavioral execution are excluded. Server decoding/reconstruction/typing/formatting/response serialization/transmission are included; independent analyzer bootstrap is included only where requested.';throughput_note='Requests/s uses summed measured serial HTTP durations, excluding measurement gaps/startup; it is not concurrent service throughput.';behavioral_execution='not_run; this measurement never executes original or recovered Luau';adapter_latency='not_measured; no executor/getter/adapter/scheduler work is included';native_integration='not_measured; a host-compiler supplied packet is used repeatedly';memory_note='Per-process and sampled aggregate Windows working sets, not weighted admission; measurement limitations retained per process.';machine=@{os=[Environment]::OSVersion.VersionString;logical_processors=[Environment]::ProcessorCount;process_architecture=$env:PROCESSOR_ARCHITECTURE;stopwatch_frequency=[Diagnostics.Stopwatch]::Frequency};elapsed_seconds=$campaign.Elapsed.TotalSeconds}
    [IO.File]::WriteAllText($reportPath,($report|ConvertTo-Json -Depth 18),$utf8)
    [IO.File]::WriteAllText($publishedReport,($report|ConvertTo-Json -Depth 18),$utf8)
    Write-Output 'Service-only benchmark complete; no executor latency or broad native coverage is claimed.'
} catch {
    $failure=@{schema=1;version='0.3.0';passed=$false;state='failed';executable_sha256=$binaryHash;error=$_.Exception.Message;adapter_latency='not_measured';elapsed_seconds=$campaign.Elapsed.TotalSeconds}
    [IO.File]::WriteAllText($reportPath,($failure|ConvertTo-Json -Depth 4),$utf8);[IO.File]::WriteAllText($publishedReport,($failure|ConvertTo-Json -Depth 4),$utf8)
    throw
} finally {Pop-Location}
