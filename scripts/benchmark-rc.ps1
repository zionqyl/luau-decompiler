[CmdletBinding()]
param(
    [string] $Corpus,
    [string] $BaselineV2,
    [string] $BaselineV3,
    [string] $BaselineRc1,
    [string] $BaselineRc2,
    [string] $BaselineRc3,
    [ValidateSet('v2','v3','rc1','rc2','rc3')][string[]] $Baselines = @('v2','v3'),
    [string] $Binary,
    [string] $Destination,
    [string] $Report,
    [ValidateRange(1,64)][int[]] $Threads = @(1,4),
    [ValidateRange(3,100)][int] $Iterations = 3,
    [ValidateRange(0,100)][int] $Warmup = 1,
    [ValidateRange(0.1,60)][double] $MinimumSeconds = 1,
    [ValidateRange(3,20)][int] $ValidationIterations = 5,
    [ValidateRange(3,20)][int] $ColdSamples = 3,
    [ValidateRange(30,1800)][int] $TimeoutSeconds = 600,
    [ValidateRange(0,8)][int] $BalancedModuleRounds = 0,
    [switch] $ProfileStacks,
    [switch] $Measure
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot = (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
$utf8 = [Text.UTF8Encoding]::new($false)
$defaults=@{Corpus='artifacts/v0.2-baseline/scale-corpus';BaselineV2='artifacts/v0.2-baseline/luau-decompile.exe';BaselineV3='artifacts/rc-baseline/v0.3.0-luau-decompile.exe';Binary='target/release/luau-decompile.exe';Destination='artifacts/performance-rc';Report='docs/results/performance-rc.json'}
foreach($name in $defaults.Keys){if(-not(Get-Variable -Name $name -ValueOnly)){Set-Variable -Name $name -Value (Join-Path $taskRoot $defaults[$name])}}
if (@($Threads | Select-Object -Unique).Count -ne $Threads.Count) { throw 'Thread counts must be unique.' }
foreach ($required in @(1,4)) { if ($Threads -notcontains $required) { throw 'The release comparison requires thread counts 1 and 4.' } }
if (@($Baselines | Select-Object -Unique).Count -ne $Baselines.Count -or $Baselines.Count -eq 0) { throw 'Select one or more unique baseline versions.' }
if ($Baselines -contains 'rc1' -and -not $BaselineRc1) { throw 'The rc1 baseline requires -BaselineRc1 with the preserved executable path.' }
if ($Baselines -contains 'rc2' -and -not $BaselineRc2) { throw 'The rc2 baseline requires -BaselineRc2 with the preserved executable path.' }
if ($Baselines -contains 'rc3' -and -not $BaselineRc3) { throw 'The rc3 baseline requires -BaselineRc3 with the preserved executable path.' }
if ($BalancedModuleRounds -and ($Baselines.Count -ne 1 -or $Baselines[0] -notin @('rc2','rc3'))) { throw 'Balanced module rounds require exactly one rc2 or rc3 baseline.' }
$resolveVariables = @('Corpus','Binary')
if ($Baselines -contains 'v2') { $resolveVariables += 'BaselineV2' }
if ($Baselines -contains 'v3') { $resolveVariables += 'BaselineV3' }
if ($Baselines -contains 'rc1') { $resolveVariables += 'BaselineRc1' }
if ($Baselines -contains 'rc2') { $resolveVariables += 'BaselineRc2' }
if ($Baselines -contains 'rc3') { $resolveVariables += 'BaselineRc3' }
foreach ($variable in $resolveVariables) {
    Set-Variable -Name $variable -Value ((Resolve-Path -LiteralPath (Get-Variable -Name $variable -ValueOnly)).Path)
}
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination = (Resolve-Path -LiteralPath $Destination).Path
$Report = [IO.Path]::GetFullPath($Report)

function Hash-File([string] $Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Save-Json([string] $Path, $Value) { [IO.File]::WriteAllText($Path,(ConvertTo-Json -InputObject $Value -Depth 48),$utf8) }
function Quote-Argument([string] $Value) {
    if ($Value.Contains('"') -or $Value.Contains([char]0) -or $Value.EndsWith('\')) { throw 'Invalid native argument.' }
    '"' + $Value + '"'
}
function Percentile([object[]] $Values, [int] $Percent) {
    $sorted = @($Values | Sort-Object)
    if ($sorted.Count -eq 0) { return $null }
    $sorted[[Math]::Max(0,[int][Math]::Ceiling($sorted.Count * $Percent / 100.0) - 1)]
}
function Public-Value($Value) {
    if ($null -eq $Value) { return $null }
    if ($Value -is [ValueType]) { return $Value }
    if ($Value -is [string]) {
        if ($Value.StartsWith($taskRoot,[StringComparison]::OrdinalIgnoreCase)) { return ('$workspace/' + $Value.Substring($taskRoot.Length).TrimStart('\','/').Replace('\','/')) }
        return $Value.Replace($taskRoot,'$workspace').Replace($taskRoot.Replace('\','/'),'$workspace')
    }
    if ($Value -is [Collections.IDictionary]) {
        $result = [ordered]@{}
        foreach ($key in $Value.Keys) { $result[$key] = Public-Value $Value[$key] }
        return $result
    }
    if ($Value -is [pscustomobject]) {
        $result = [ordered]@{}
        foreach ($property in $Value.PSObject.Properties) { $result[$property.Name] = Public-Value $property.Value }
        return $result
    }
    if ($Value -is [Collections.IEnumerable]) {
        $result = @($Value | ForEach-Object { Public-Value $_ })
        return ,$result
    }
    return $Value
}
function Source-Snapshot {
    $paths = [Collections.Generic.List[string]]::new()
    foreach ($directory in @('src','examples')) {
        Get-ChildItem -LiteralPath (Join-Path $taskRoot $directory) -Recurse -Filter '*.rs' -File | ForEach-Object { $paths.Add($_.FullName) }
    }
    foreach ($path in @('Cargo.toml','Cargo.lock','tests/analyzer_runner.cpp','tests/source-corpus/player_snapshot.luau','definitions/roblox.d.luau','definitions.lock.json','upstream.lock.json','upstream.profiles.lock.json','scripts/benchmark.ps1','scripts/benchmark-rc.ps1','scripts/symbolize-allocations.ps1')) { $paths.Add((Join-Path $taskRoot $path)) }
    @($paths | Sort-Object | ForEach-Object { [ordered]@{path=$_.Substring($taskRoot.Length + 1).Replace('\','/');sha256=(Hash-File $_)} })
}
function Measure-Process([string] $Executable, [string[]] $Arguments, [string] $Output, [bool] $RequirePeak = $false) {
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Executable
    $start.Arguments = $Arguments -join ' '
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    $stdout = [IO.File]::Create($Output)
    $stderr = [IO.File]::Create($Output + '.stderr')
    try {
        if (-not $process.Start()) { throw 'Performance process did not start.' }
        $copyOutput = $process.StandardOutput.BaseStream.CopyToAsync($stdout)
        $copyError = $process.StandardError.BaseStream.CopyToAsync($stderr)
        $null = $process.Handle
        $peak = 0L
        $cpu = $null
        while (-not $process.HasExited) {
            $process.Refresh()
            try { $peak = [Math]::Max($peak,$process.PeakWorkingSet64) } catch {}
            try { $sample = $process.TotalProcessorTime.TotalSeconds; if ($null -eq $cpu -or $sample -gt $cpu) { $cpu = $sample } } catch {}
            if ($clock.Elapsed.TotalSeconds -gt $TimeoutSeconds) { $process.Kill(); $process.WaitForExit(); throw 'Performance child exceeded the bounded timeout.' }
            Start-Sleep -Milliseconds 10
        }
        $process.WaitForExit()
        $null = $copyOutput.GetAwaiter().GetResult()
        $null = $copyError.GetAwaiter().GetResult()
        $stdout.Flush()
        $stderr.Flush()
        $clock.Stop()
        try { $peak = [Math]::Max($peak,$process.PeakWorkingSet64) } catch {}
        try { $sample = $process.TotalProcessorTime.TotalSeconds; if ($null -eq $cpu -or $sample -gt $cpu) { $cpu = $sample } } catch {}
        if ($process.ExitCode -ne 0) { throw ('Performance child failed, exit ' + $process.ExitCode + '; complete stderr retained in ' + $Output + '.stderr') }
        if ($peak -le 0 -and $RequirePeak) { throw 'No OS peak working-set measurement was available.' }
        [ordered]@{wall_ns=[long]($clock.Elapsed.TotalMilliseconds * 1000000);process_cpu_seconds=$cpu;peak_parent_working_set_bytes=$(if($peak -gt 0){$peak}else{$null});executable_sha256=(Hash-File $Executable);peak_note='Windows parent-process PeakWorkingSet64 sampled every 10ms; excludes analyzer subprocesses and can miss a final unsampled peak.'}
    } finally { $stdout.Dispose(); $stderr.Dispose(); $process.Dispose() }
}

function Read-HistoricalReport([string] $Name,[ValidateSet('0.4.0-rc.1','0.4.0-rc.2')][string]$Version='0.4.0-rc.1') {
    $manifestPath = Join-Path $taskRoot ('evidence/releases/'+$Version+'-manifest.json')
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $archivePath = Join-Path $taskRoot $manifest.archive_path
    if ((Hash-File $archivePath) -cne $manifest.archive_sha256) { throw 'Historical evidence archive identity mismatch.' }
    $identity = @($manifest.files | Where-Object {$_.path -ceq $Name})
    if ($identity.Count -ne 1) { throw ('Historical report identity missing: ' + $Name) }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($archivePath)
    try {
        $entry = $archive.GetEntry($Name)
        if ($null -eq $entry -or $entry.Length -ne $identity[0].bytes) { throw 'Historical report entry length mismatch.' }
        $stream = $entry.Open()
        $memory = [IO.MemoryStream]::new()
        try { $stream.CopyTo($memory); $bytes = $memory.ToArray() } finally { $memory.Dispose(); $stream.Dispose() }
        $algorithm = [Security.Cryptography.SHA256]::Create()
        try { $actual = [BitConverter]::ToString($algorithm.ComputeHash($bytes)).Replace('-','').ToLowerInvariant() } finally { $algorithm.Dispose() }
        if ($actual -cne $identity[0].sha256) { throw 'Historical report digest mismatch.' }
        return $utf8.GetString($bytes) | ConvertFrom-Json
    } finally { $archive.Dispose() }
}
$candidateVersion=([regex]::Match([IO.File]::ReadAllText((Join-Path $taskRoot 'Cargo.toml')),'(?m)^version\s*=\s*\x22([^\x22]+)\x22')).Groups[1].Value
$observedVersion=(& $Binary --version|Out-String).Trim()
if($LASTEXITCODE -ne 0 -or $observedVersion -cne ('luau-decompile '+$candidateVersion)){throw 'Candidate executable does not match the current Cargo package version; build it before preparing or measuring'}
$v2ManifestPath = $null
$v3ManifestPath = $null
$v2Manifest = $null
$v3Manifest = $null
$rc1Performance = $null
$rc2Performance = $null
if ($Baselines -contains 'v2') {
    $v2ManifestPath = Join-Path (Split-Path -Parent $BaselineV2) 'manifest.json'
    $v2Manifest = Get-Content -LiteralPath $v2ManifestPath -Raw | ConvertFrom-Json
    if ((Hash-File $BaselineV2) -cne $v2Manifest.binary_sha256 -or $v2Manifest.version -ne '0.2.0' -or -not $v2Manifest.baseline_gate_passed) { throw 'Preserved v0.2.0 identity mismatch.' }
}
if ($Baselines -contains 'v3') {
    $v3ManifestPath = Join-Path (Split-Path -Parent $BaselineV3) 'baseline.json'
    $v3Manifest = Get-Content -LiteralPath $v3ManifestPath -Raw | ConvertFrom-Json
    $historicalPerformance = Read-HistoricalReport 'v3-performance.json'
    if ((Hash-File $BaselineV3) -cne $v3Manifest.executable_sha256 -or $v3Manifest.version -ne '0.3.0' -or $v3Manifest.ordinary_check_exit_code -ne 0) { throw 'Preserved v0.3.0 identity mismatch.' }
    if ($historicalPerformance.helper_provenance.historical_helpers -or $historicalPerformance.helper_provenance.associated_cli_sha256 -cne $v3Manifest.executable_sha256 -or (Hash-File (Join-Path (Split-Path -Parent $BaselineV3) 'profile_validation.exe')) -cne $historicalPerformance.helper_provenance.validation_helper_sha256 -or (Hash-File (Join-Path (Split-Path -Parent $BaselineV3) 'profile_allocations.exe')) -cne $historicalPerformance.helper_provenance.allocation_helper_sha256) { throw 'Preserved v0.3 helper identities do not match its historical final performance evidence.' }
}
if ($Baselines -contains 'rc1') {
    $rc1Performance = Read-HistoricalReport 'performance-rc.json'
    if (-not $rc1Performance.passed -or $rc1Performance.status -ne 'measured' -or (Hash-File $BaselineRc1) -cne $rc1Performance.candidate_sha256) { throw 'Preserved rc.1 identity differs from its historical release evidence.' }
    $rc1Tools = @($rc1Performance.tools | Where-Object {$_.profile -ceq 'candidate'})
    if ($rc1Tools.Count -ne 1) { throw 'Historical rc.1 helper provenance is missing.' }
    foreach ($pair in @(@('profile_validation.exe','validation_helper_sha256'),@('profile_allocations.exe','allocation_helper_sha256'),@('luau-quality.exe','analyzer_sha256'),@('luau-quality.exe.manifest.json','analyzer_manifest_sha256'))) {
        if ((Hash-File (Join-Path (Split-Path -Parent $BaselineRc1) $pair[0])) -cne $rc1Tools[0].($pair[1])) { throw ('Preserved rc.1 helper identity mismatch: ' + $pair[0]) }
    }
}
if ($Baselines -contains 'rc2') {
    $rc2Performance = Read-HistoricalReport 'reports/docs/results/performance-rc.json' '0.4.0-rc.2'
    if (-not $rc2Performance.passed -or $rc2Performance.status -ne 'measured' -or (Hash-File $BaselineRc2) -cne $rc2Performance.candidate_sha256) { throw 'Preserved rc.2 identity differs from its historical release evidence.' }
    $rc2Tools = @($rc2Performance.tools | Where-Object {$_.profile -ceq 'candidate'})
    if ($rc2Tools.Count -ne 1) { throw 'Historical rc.2 helper provenance is missing.' }
    foreach ($pair in @(@('profile_validation.exe','validation_helper_sha256'),@('profile_allocations.exe','allocation_helper_sha256'),@('luau-quality.exe','analyzer_sha256'),@('luau-quality.exe.manifest.json','analyzer_manifest_sha256'))) {
        if ((Hash-File (Join-Path (Split-Path -Parent $BaselineRc2) $pair[0])) -cne $rc2Tools[0].($pair[1])) { throw ('Preserved rc.2 helper identity mismatch: ' + $pair[0]) }
    }
}
if ($Baselines -contains 'rc3') {
    $rc3Directory=Split-Path -Parent $BaselineRc3
    $rc3Performance=Get-Content -LiteralPath (Join-Path $rc3Directory 'performance.json') -Raw|ConvertFrom-Json
    if(-not $rc3Performance.passed -or $rc3Performance.status -cne 'measured' -or (Hash-File $BaselineRc3) -cne $rc3Performance.candidate_sha256){throw 'Preserved rc.3 CLI differs from its recorded performance identity.'}
    $rc3Tools=@($rc3Performance.tools|Where-Object{$_.profile -ceq 'candidate'})
    if($rc3Tools.Count -ne 1){throw 'Historical rc.3 helper provenance is missing.'}
    foreach($pair in @(@('profile_validation.exe','validation_helper_sha256'),@('profile_allocations.exe','allocation_helper_sha256'),@('luau-quality.exe','analyzer_sha256'),@('luau-quality.exe.manifest.json','analyzer_manifest_sha256'))){
        if((Hash-File (Join-Path $rc3Directory $pair[0])) -cne $rc3Tools[0].($pair[1])){throw ('Preserved rc.3 helper identity mismatch: '+$pair[0])}
    }
}
$corpusManifestPath = Join-Path $Corpus 'manifest.json'
$corpusManifest = Get-Content -LiteralPath $corpusManifestPath -Raw | ConvertFrom-Json
if ($corpusManifest.independent_inputs -ne 2000 -or $corpusManifest.large_function_updates -ne 4096 -or $corpusManifest.large_module_functions -ne 512 -or $corpusManifest.cases.Count -ne 2002) { throw 'Expected the preserved 2000/4096/512 workload.' }
$groups = @('many_independent_inputs','one_large_function','one_large_module')
$manifests = @{}
$groupPaths = @{}
$inputHashes = @{}
foreach ($group in $groups) {
    $paths = [Collections.Generic.List[string]]::new()
    foreach ($case in @($corpusManifest.cases | Where-Object { $_.category -eq $group })) {
        $source = Join-Path $Corpus $case.source
        $bytecode = Join-Path $Corpus $case.bytecode
        if ((Hash-File $source) -cne $case.source_sha256 -or (Hash-File $bytecode) -cne $case.bytecode_sha256) { throw ('Corpus identity mismatch: ' + $case.name) }
        $paths.Add($bytecode)
        $inputHashes[$bytecode] = $case.bytecode_sha256
    }
    if ($paths.Count -eq 0) { throw ('Missing workload ' + $group) }
    $groupPaths[$group] = $paths.ToArray()
    $pathManifest = Join-Path $Destination ('paths-' + $group + '.json')
    Save-Json $pathManifest $paths.ToArray()
    $manifests[$group] = $pathManifest
}
$faithfulConfig = Join-Path $Destination 'faithful-validation-off.json'
$annotatedConfig = Join-Path $Destination 'annotated-validation-off.json'
[IO.File]::WriteAllText($faithfulConfig,'{"typing":{"mode":"off"},"validation":{"mode":"off"}}',$utf8)
[IO.File]::WriteAllText($annotatedConfig,'{"typing":{"mode":"annotated"},"validation":{"mode":"off"}}',$utf8)
$profiles = @()
if ($Baselines -contains 'v2') { $profiles += @{id='v0.2.0-faithful';version='0.2.0';binary=$BaselineV2;config=$null} }
if ($Baselines -contains 'v3') {
    $profiles += @{id='v0.3.0-faithful';version='0.3.0';binary=$BaselineV3;config=$faithfulConfig}
    $profiles += @{id='v0.3.0-annotated';version='0.3.0';binary=$BaselineV3;config=$annotatedConfig}
}
if ($Baselines -contains 'rc1') {
    $profiles += @{id='v0.4.0-rc.1-faithful';version='0.4.0-rc.1';binary=$BaselineRc1;config=$faithfulConfig}
    $profiles += @{id='v0.4.0-rc.1-annotated';version='0.4.0-rc.1';binary=$BaselineRc1;config=$annotatedConfig}
}
if ($Baselines -contains 'rc2') {
    $profiles += @{id='v0.4.0-rc.2-faithful';version='0.4.0-rc.2';binary=$BaselineRc2;config=$faithfulConfig}
    $profiles += @{id='v0.4.0-rc.2-annotated';version='0.4.0-rc.2';binary=$BaselineRc2;config=$annotatedConfig}
}
if ($Baselines -contains 'rc3') {
    $profiles += @{id='v0.4.0-rc.3-faithful';version='0.4.0-rc.3';binary=$BaselineRc3;config=$faithfulConfig}
    $profiles += @{id='v0.4.0-rc.3-annotated';version='0.4.0-rc.3';binary=$BaselineRc3;config=$annotatedConfig}
}
$profiles += @{id='candidate-faithful';version='candidate';binary=$Binary;config=$faithfulConfig}
$profiles += @{id='candidate-annotated';version='candidate';binary=$Binary;config=$annotatedConfig}
$sourceBefore = @(Source-Snapshot)
$plan = [ordered]@{schema=1;status='prepared_not_measured';candidate_sha256=(Hash-File $Binary);baseline_v2_sha256=$(if($Baselines -contains 'v2'){Hash-File $BaselineV2}else{$null});baseline_v3_sha256=$(if($Baselines -contains 'v3'){Hash-File $BaselineV3}else{$null});baseline_rc1_sha256=$(if($Baselines -contains 'rc1'){Hash-File $BaselineRc1}else{$null});baseline_rc2_sha256=$(if($Baselines -contains 'rc2'){Hash-File $BaselineRc2}else{$null});baseline_rc3_sha256=$(if($Baselines -contains 'rc3'){Hash-File $BaselineRc3}else{$null});selected_baselines=$Baselines;balanced_module_rounds=$BalancedModuleRounds;allocation_stacks=[bool]$ProfileStacks;corpus_manifest_sha256=(Hash-File $corpusManifestPath);threads=$Threads;minimum_iterations=$Iterations;minimum_seconds=$MinimumSeconds;cold_samples=$ColdSamples;validation_observations_per_input=$ValidationIterations;profiles=$profiles;source_files=$sourceBefore;note='Preparation validates identities but is not performance evidence. Run -Measure only after candidate executable, helpers and source are frozen.'}
Save-Json (Join-Path $Destination 'plan.json') (Public-Value $plan)
if (-not $Measure) { Write-Output ('Prepared performance identities and workloads in ' + $Destination + '; no timing run.'); return }

$rawNamespace=$plan.candidate_sha256.Substring(0,12)+'-'+[Guid]::NewGuid().ToString('N')
$rawRelative='performance-rc-raw/'+$rawNamespace
$rawDirectory = Join-Path (Split-Path -Parent $Report) $rawRelative
New-Item -ItemType Directory -Force -Path $rawDirectory | Out-Null
$rawReports = [Collections.Generic.List[object]]::new()
function Archive-Report([string] $Path, [string] $Name) {
    $parsed = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    $bytes = $utf8.GetBytes(((Public-Value $parsed) | ConvertTo-Json -Depth 48))
    $archive = Join-Path $rawDirectory ($Name + '.json.gz')
    $stream = [IO.File]::Create($archive)
    $gzip = [IO.Compression.GZipStream]::new($stream,[IO.Compression.CompressionLevel]::Optimal)
    try { $gzip.Write($bytes,0,$bytes.Length) } finally { $gzip.Dispose(); $stream.Dispose() }
    $rawReports.Add([ordered]@{path=($rawRelative+'/' + $Name + '.json.gz');sha256=(Hash-File $archive);original_sha256=(Hash-File $Path);normalization='Only metadata strings beginning with the workspace path are rewritten to $workspace; source observations and timings are unchanged.'})
}
$pending = [ordered]@{schema=1;status='incomplete';passed=$false;measured_at=[DateTime]::UtcNow.ToString('o');candidate_sha256=$plan.candidate_sha256;reason='Measurement has started; a previous success cannot validate this attempt.'}
Save-Json $Report $pending
$warmRows = [Collections.Generic.List[object]]::new()
$coldRows = [Collections.Generic.List[object]]::new()
$validationRows = [Collections.Generic.List[object]]::new()
$allocationRows = [Collections.Generic.List[object]]::new()
$verifiedRows = [Collections.Generic.List[object]]::new()
$toolIdentities = [Collections.Generic.List[object]]::new()
$balancedRows = [Collections.Generic.List[object]]::new()
$stackRows = [Collections.Generic.List[object]]::new()
$started = [DateTime]::UtcNow.ToString('o')
Push-Location $taskRoot
try {
    foreach ($profile in $profiles) {
        foreach ($group in $groups) {
            $directory = Join-Path $Destination ($profile.id + '/' + $group)
            $parameters = @{Manifest=$manifests[$group];Threads=$Threads;Iterations=$Iterations;Warmup=$Warmup;MinimumSeconds=$MinimumSeconds;Destination=$directory;Binary=$profile.binary;SkipBuild=$true;SkipAllocations=$true;TimeoutSeconds=$TimeoutSeconds}
            if ($profile.config) { $parameters.Config = $profile.config }
            & (Join-Path $PSScriptRoot 'benchmark.ps1') @parameters
            $summaryPath = Join-Path $directory 'summary.json'
            $summary = Get-Content -LiteralPath $summaryPath -Raw | ConvertFrom-Json
            if (-not $summary.deterministic_across_threads) { throw 'Nondeterministic benchmark output.' }
            Archive-Report $summaryPath ($profile.id + '-' + $group)
            foreach ($run in $summary.results) {
                $result = $run.results[0]
                if ($result.complete_reconstructions -ne $result.scripts -or $result.iterations -lt 3 -or $result.scripts -lt 3) { throw 'Incomplete or undersampled warm-core row.' }
                if (@($run.corpus).Count -ne $groupPaths[$group].Count) { throw 'Warm-core input identities are incomplete.' }
                foreach ($input in $run.corpus) {
                    if (-not $inputHashes.ContainsKey([string]$input.path) -or $input.sha256 -cne $inputHashes[[string]$input.path]) { throw 'A warm-core input differed from the preserved corpus.' }
                }
                $warmRows.Add([ordered]@{profile=$profile.id;scenario=$group;threads=$result.threads;scripts=$result.scripts;iterations=$result.iterations;elapsed_ns=$result.elapsed_ns;scripts_per_second=$result.scripts_per_second;p50_latency_ns=$result.latency_p50_ns;p95_latency_ns=$result.latency_p95_ns;max_latency_ns=$result.latency_max_ns;phase_totals_micros=$result.phase_cpu_or_wait_micros_summed;phase_latency_distributions=$result.phase_latency_distributions;peak_parent_working_set_bytes=$run.peak_memory_bytes;process_wall_seconds=$run.process_wall_seconds;process_cpu_seconds=$run.process_cpu_seconds;executable_sha256=$summary.executable_sha256;configuration_sha256=$(if($profile.config){Hash-File $profile.config}else{$null});strict_validation_enabled=$false;minimum_duration_reached=$run.duration_target_reached;output_hashes_sha256=(Hash-File (Join-Path $directory ('threads-' + $result.threads + '.json')))})
            }
            $expectedOutput = $summary.results[0].results[0].output_sha256[0]
            for ($sample = 0; $sample -lt $ColdSamples; $sample++) {
                $sourcePath = Join-Path $directory ('cold-' + $sample + '.luau')
                $arguments = @('decompile',(Quote-Argument $groupPaths[$group][0]),'--threads','1','-o',(Quote-Argument $sourcePath),'--force')
                if ($profile.config) { $arguments += @('--config',(Quote-Argument $profile.config)) }
                if ((Hash-File $groupPaths[$group][0]) -cne $inputHashes[$groupPaths[$group][0]]) { throw 'Cold CLI input changed before loading.' }
                $metrics = Measure-Process $profile.binary $arguments (Join-Path $directory ('cold-' + $sample + '.stdout'))
                if ((Hash-File $groupPaths[$group][0]) -cne $inputHashes[$groupPaths[$group][0]]) { throw 'Cold CLI input changed during loading.' }
                if (-not (Test-Path -LiteralPath $sourcePath) -or (Hash-File $sourcePath) -cne $expectedOutput) { throw 'Cold CLI source differs from warm-core output.' }
                $coldRows.Add([ordered]@{profile=$profile.id;scenario=$group;sample=$sample;wall_ns=$metrics.wall_ns;peak_parent_working_set_bytes=$metrics.peak_parent_working_set_bytes;executable_sha256=$metrics.executable_sha256;source_sha256=$expectedOutput;strict_validation_enabled=$false;note='Fresh CLI process including startup, file input, source write and polling overhead; no analyzer or service cache.'})
            }
        }
    }
    if ($BalancedModuleRounds) {
        $baseline = @($profiles|Where-Object{$_.id -ceq ('v0.4.0-'+$Baselines[0].Insert(2,'.')+'-faithful')})[0]
        $candidate = @($profiles|Where-Object{$_.id -ceq 'candidate-faithful'})[0]
        $sequence = @($baseline,$candidate,$candidate,$baseline)
        for ($round = 0; $round -lt $BalancedModuleRounds; $round++) {
            for ($position = 0; $position -lt $sequence.Count; $position++) {
                $profile = $sequence[$position]
                $directory = Join-Path $Destination ('balanced-module-' + $round + '-' + $position)
                & (Join-Path $PSScriptRoot 'benchmark.ps1') -Manifest $manifests['one_large_module'] -Threads @(1) -Iterations $Iterations -Warmup $Warmup -MinimumSeconds $MinimumSeconds -Destination $directory -Binary $profile.binary -Config $profile.config -SkipBuild -SkipAllocations -TimeoutSeconds $TimeoutSeconds
                $summaryPath = Join-Path $directory 'summary.json'
                $summary = Get-Content -LiteralPath $summaryPath -Raw|ConvertFrom-Json
                if(-not $summary.deterministic_across_threads -or $summary.results.Count -ne 1){throw 'Incomplete balanced module profile'}
                $run=$summary.results[0];$row=$run.results[0]
                $reference=Get-Content -LiteralPath (Join-Path $Destination ($profile.id+'/one_large_module/summary.json')) -Raw|ConvertFrom-Json
                if($row.complete_reconstructions -ne $row.scripts -or $row.scripts -lt 3 -or $row.output_sha256[0] -cne $reference.results[0].results[0].output_sha256[0]){throw 'Balanced module output was incomplete or changed within its binary/configuration cohort'}
                if($run.corpus.Count -ne 1 -or $run.corpus[0].sha256 -cne $inputHashes[$groupPaths['one_large_module'][0]]){throw 'Balanced module input identity changed'}
                Archive-Report $summaryPath ('balanced-module-'+$round+'-'+$position)
                $balancedRows.Add([ordered]@{round=$round;position=$position;profile=$profile.id;sequence='baseline,candidate,candidate,baseline';threads=1;scripts=$row.scripts;iterations=$row.iterations;elapsed_ns=$row.elapsed_ns;scripts_per_second=$row.scripts_per_second;phase_totals_micros=$row.phase_cpu_or_wait_micros_summed;peak_parent_working_set_bytes=$run.peak_memory_bytes;source_sha256=$row.output_sha256[0];executable_sha256=$summary.executable_sha256;configuration_sha256=(Hash-File $profile.config);strict_validation_enabled=$false;minimum_duration_reached=$run.duration_target_reached})
            }
        }
    }
    $helperProfiles = @()
    if ($Baselines -contains 'v3') { $helperProfiles += @{id='v0.3.0';validation=(Join-Path (Split-Path -Parent $BaselineV3) 'profile_validation.exe');allocation=(Join-Path (Split-Path -Parent $BaselineV3) 'profile_allocations.exe');analyzer=(Join-Path (Split-Path -Parent $BaselineV3) 'luau-quality.exe');cli=$BaselineV3} }
    if ($Baselines -contains 'rc1') { $helperProfiles += @{id='v0.4.0-rc.1';validation=(Join-Path (Split-Path -Parent $BaselineRc1) 'profile_validation.exe');allocation=(Join-Path (Split-Path -Parent $BaselineRc1) 'profile_allocations.exe');analyzer=(Join-Path (Split-Path -Parent $BaselineRc1) 'luau-quality.exe');cli=$BaselineRc1} }
    if ($Baselines -contains 'rc2') { $helperProfiles += @{id='v0.4.0-rc.2';validation=(Join-Path (Split-Path -Parent $BaselineRc2) 'profile_validation.exe');allocation=(Join-Path (Split-Path -Parent $BaselineRc2) 'profile_allocations.exe');analyzer=(Join-Path (Split-Path -Parent $BaselineRc2) 'luau-quality.exe');cli=$BaselineRc2} }
    if ($Baselines -contains 'rc3') { $helperProfiles += @{id='v0.4.0-rc.3';validation=(Join-Path (Split-Path -Parent $BaselineRc3) 'profile_validation.exe');allocation=(Join-Path (Split-Path -Parent $BaselineRc3) 'profile_allocations.exe');analyzer=(Join-Path (Split-Path -Parent $BaselineRc3) 'luau-quality.exe');cli=$BaselineRc3} }
    $helperProfiles += @{id='candidate';validation=(Join-Path $taskRoot 'target/release/examples/profile_validation.exe');allocation=(Join-Path $taskRoot 'target/release/examples/profile_allocations.exe');analyzer=(Join-Path $taskRoot '.tools/luau-quality.exe');cli=$Binary}
    foreach ($profile in $helperProfiles) {
        foreach ($field in @('validation','allocation','analyzer')) { if (-not (Test-Path -LiteralPath $profile[$field])) { throw ('Missing measured helper: ' + $profile[$field]) } }
        $analyzerManifestPath = $profile.analyzer + '.manifest.json'
        $analyzerManifest = Get-Content -LiteralPath $analyzerManifestPath -Raw | ConvertFrom-Json
        if ($analyzerManifest.binary_sha256 -cne (Hash-File $profile.analyzer) -or $analyzerManifest.protocol -ne 'LQUAL/1') { throw 'Analyzer helper provenance mismatch.' }
        $toolIdentities.Add([ordered]@{profile=$profile.id;associated_cli_sha256=(Hash-File $profile.cli);validation_helper_sha256=(Hash-File $profile.validation);allocation_helper_sha256=(Hash-File $profile.allocation);analyzer_sha256=(Hash-File $profile.analyzer);analyzer_manifest_sha256=(Hash-File $analyzerManifestPath);analyzer_source_sha256=$analyzerManifest.source_sha256;analyzer_revision=$analyzerManifest.upstream_revision;definitions_sha256=(Hash-File (Join-Path $taskRoot 'definitions/roblox.d.luau'))})
        $validationConfig = Join-Path $Destination ($profile.id + '-validation-check.json')
        Save-Json $validationConfig @{typing=@{mode='annotated'};validation=@{mode='check';analyzer_path=$profile.analyzer;definitions_path=(Join-Path $taskRoot 'definitions/roblox.d.luau')}}
        foreach ($cache in @($false,$true)) {
            $output = Join-Path $Destination ($profile.id + '-validation-cache-' + $cache.ToString().ToLowerInvariant() + '.json')
            $arguments = @('--config',(Quote-Argument $validationConfig),'--iterations',$ValidationIterations.ToString(),(Quote-Argument $groupPaths['many_independent_inputs'][0]),(Quote-Argument $groupPaths['one_large_function'][0]),(Quote-Argument $groupPaths['one_large_module'][0]))
            if ($cache) { $arguments += '--cache' }
            $metrics = Measure-Process $profile.validation $arguments $output $true
            $data = Get-Content -LiteralPath $output -Raw | ConvertFrom-Json
            if (-not $data.complete_reconstruction -or $data.results.Count -ne $ValidationIterations * 3) { throw 'Incomplete validation profile.' }
            Archive-Report $output ($profile.id + '-validation-cache-' + $cache.ToString().ToLowerInvariant())
            foreach ($inputGroup in ($data.results | Group-Object input_index)) {
                $items = @($inputGroup.Group)
                $warm = @($items | Select-Object -Skip 1)
                if (@($items | Where-Object { $_.validation.syntax -ne 'passed' -or $_.validation.compilation -ne 'passed' -or -not $_.validation.analyzer_sha256 }).Count -ne 0) { throw 'Validation profile did not complete parser/compiler/analyzer checks.' }
                if ($cache -and @($warm | Where-Object { -not $_.validation.cache_hit }).Count -ne 0) { throw 'Requested warmed analyzer cache did not hit.' }
                $validationRows.Add([ordered]@{profile=$profile.id;scenario=$groups[[int]$inputGroup.Name];cache_enabled=$cache;observations=$items.Count;warm_observations=$warm.Count;first_cohort=$items[0].cohort;first_wall_ns=$items[0].wall_ns;warm_p50_ns=(Percentile @($warm.wall_ns) 50);warm_p95_ns=(Percentile @($warm.wall_ns) 95);warm_cache_hits=@($warm | Where-Object {$_.validation.cache_hit}).Count;strict_passed=@($items | Where-Object {$_.validation.strict_analysis -eq 'passed'}).Count;strict_failed=@($items | Where-Object {$_.validation.strict_analysis -eq 'failed'}).Count;strict_unavailable=@($items | Where-Object {$_.validation.strict_analysis -notin @('passed','failed')}).Count;first_diagnostic_count=$items[0].validation.diagnostics.Count;first_explicit_any=$items[0].validation.explicit_any;first_inferred_any=$items[0].validation.inferred_any;first_assertions=$items[0].validation.type_assertions;first_stats=$items[0].stats;first_compiler_micros=$items[0].validation.compiler_micros;first_analyzer_micros=$items[0].validation.analyzer_micros;source_sha256=$items[0].source_sha256;helper_sha256=$metrics.executable_sha256;peak_parent_working_set_bytes=$metrics.peak_parent_working_set_bytes;mode='strict_check_only; not verified_typed output policy'})
            }
        }
        foreach ($mode in @(@{id='faithful';config=$faithfulConfig},@{id='annotated';config=$annotatedConfig})) {
            $output = Join-Path $Destination ($profile.id + '-allocations-' + $mode.id + '.json')
            $arguments = @('--config',(Quote-Argument $mode.config),(Quote-Argument $groupPaths['one_large_function'][0]),(Quote-Argument $groupPaths['one_large_module'][0]))
            $metrics = Measure-Process $profile.allocation $arguments $output
            $data = Get-Content -LiteralPath $output -Raw | ConvertFrom-Json
            if ($data.results.Count -ne 2 -or @($data.results | Where-Object { $null -eq $_.result.Ok }).Count -ne 0) { throw 'Allocation reconstruction failed.' }
            Archive-Report $output ($profile.id + '-allocations-' + $mode.id)
            foreach ($row in $data.results) {
                $allocationRows.Add([ordered]@{profile=$profile.id;mode=$mode.id;input=([IO.Path]::GetFileName($row.path));input_bytes=$row.input_bytes;allocations=$row.allocations;reallocations=$row.reallocations;bytes_requested=$row.bytes_requested;peak_additional_live_heap_bytes=$row.peak_additional_live_heap_bytes;final_source_map_storage=$row.final_source_map_storage;helper_sha256=$metrics.executable_sha256;source_sha256=$row.source_sha256;note='Instrumented single-thread Rust heap only; input loading, analyzer processes, stacks and allocator metadata excluded.'})
            }
        }
        if ($ProfileStacks) {
            $output = Join-Path $Destination ($profile.id+'-module-allocation-stacks.json')
            $arguments = @('--stacks','--config',(Quote-Argument $faithfulConfig),(Quote-Argument $groupPaths['one_large_module'][0]))
            $metrics = Measure-Process $profile.allocation $arguments $output
            $data = Get-Content -LiteralPath $output -Raw|ConvertFrom-Json
            if(-not $data.stack_sampling -or $data.results.Count -ne 1 -or $null -eq $data.results[0].result.Ok -or -not $data.results[0].allocation_stack_samples.Count){throw 'Allocation stack profile was incomplete'}
            $symbolized = Join-Path $Destination ($profile.id+'-module-allocation-symbols.json')
            & (Join-Path $PSScriptRoot 'symbolize-allocations.ps1') -Report $output -Binary $profile.allocation -Destination $symbolized
            $symbols = Get-Content -LiteralPath $symbolized -Raw|ConvertFrom-Json
            Archive-Report $output ($profile.id+'-module-allocation-stacks')
            Archive-Report $symbolized ($profile.id+'-module-allocation-symbols')
            $stackRows.Add([ordered]@{profile=$profile.id;helper_sha256=$metrics.executable_sha256;source_sha256=$data.results[0].source_sha256;symbolizer_sha256=(Hash-File (Join-Path $PSScriptRoot 'symbolize-allocations.ps1'));nm_sha256=(Hash-File (Join-Path $taskRoot '.tools/mingw64/bin/nm.exe'));objdump_sha256=(Hash-File (Join-Path $taskRoot '.tools/mingw64/bin/objdump.exe'));sample_candidates=$symbols.results[0].sample_candidates;retained_samples=$symbols.results[0].retained_samples;first_core_frame_counts=$symbols.results[0].first_core_frame_counts;method=$symbols.method;scope='Separate instrumented allocation-event samples; these are not CPU samples, and observer allocations/timing do not replace the regular counter or warm-core measurements.'})
        }
    }
    $verifiedConfig = Join-Path $Destination 'candidate-verified-source.json'
    Save-Json $verifiedConfig @{output_policy='verified_typed';validation=@{mode='strict_required';analyzer_path=(Join-Path $taskRoot '.tools/luau-quality.exe');definitions_path=(Join-Path $taskRoot 'definitions/roblox.d.luau')}}
    $verifiedInput = Join-Path $taskRoot 'tests/source-corpus/player_snapshot.luau'
    for ($sample = 0; $sample -lt $ColdSamples; $sample++) {
        $sourcePath = Join-Path $Destination ('verified-source-' + $sample + '.luau')
        $qualityPath = Join-Path $Destination ('verified-source-' + $sample + '-quality.json')
        $arguments = @('decompile',(Quote-Argument $verifiedInput),'--threads','1','--input-format','luau-source','--config',(Quote-Argument $verifiedConfig),'--quality-report',(Quote-Argument $qualityPath),'-o',(Quote-Argument $sourcePath),'--force')
        $metrics = Measure-Process $Binary $arguments (Join-Path $Destination ('verified-source-' + $sample + '.stdout'))
        $quality = Get-Content -LiteralPath $qualityPath -Raw | ConvertFrom-Json
        if (-not $quality.validation.required_passed -or $quality.validation.strict_analysis -ne 'passed' -or -not $quality.validation.meaningful_typing.passed -or $quality.validation.output_policy -ne 'verified_typed') { throw 'Verified source profile did not satisfy the actual required quality gate.' }
        $verifiedRows.Add([ordered]@{sample=$sample;wall_ns=$metrics.wall_ns;executable_sha256=$metrics.executable_sha256;input_sha256=(Hash-File $verifiedInput);source_sha256=(Hash-File $sourcePath);configuration_sha256=(Hash-File $verifiedConfig);stats=[ordered]@{parse_micros=$quality.parse_micros;decode_micros=$quality.decode_micros;reconstruct_micros=$quality.reconstruct_micros;type_infer_micros=$quality.type_infer_micros;format_micros=$quality.format_micros;validation_micros=$quality.validation_micros;total_micros=$quality.total_micros};validation=$quality.validation;type_report=$quality.type_report;note='Fresh CLI verified_typed source processing including source parse, formatting, pinned analyzer startup, required typing gate and file output; no decompilation or behavioral execution.'})
        Archive-Report $qualityPath ('candidate-verified-source-' + $sample)
    }
    $sourceAfter = @(Source-Snapshot)
    if (($sourceBefore | ConvertTo-Json -Depth 5 -Compress) -cne ($sourceAfter | ConvertTo-Json -Depth 5 -Compress)) { throw 'Performance source/helper definitions changed during measurement.' }
    foreach ($profile in $profiles) {
        $expected = if($profile.version -eq '0.2.0'){$plan.baseline_v2_sha256}elseif($profile.version -eq '0.3.0'){$plan.baseline_v3_sha256}elseif($profile.version -eq '0.4.0-rc.1'){$plan.baseline_rc1_sha256}elseif($profile.version -eq '0.4.0-rc.2'){$plan.baseline_rc2_sha256}elseif($profile.version -eq '0.4.0-rc.3'){$plan.baseline_rc3_sha256}else{$plan.candidate_sha256}
        if ((Hash-File $profile.binary) -cne $expected) { throw 'A measured CLI executable changed during the run.' }
    }
    foreach ($profile in $helperProfiles) {
        $identity = @($toolIdentities | Where-Object {$_.profile -ceq $profile.id})[0]
        if ((Hash-File $profile.validation) -cne $identity.validation_helper_sha256 -or (Hash-File $profile.allocation) -cne $identity.allocation_helper_sha256 -or (Hash-File $profile.analyzer) -cne $identity.analyzer_sha256 -or (Hash-File ($profile.analyzer + '.manifest.json')) -cne $identity.analyzer_manifest_sha256 -or (Hash-File (Join-Path $taskRoot 'definitions/roblox.d.luau')) -cne $identity.definitions_sha256) { throw 'A measured helper, analyzer, manifest or definition file changed during the run.' }
    }
    $balancedSummary=$null
    if($balancedRows.Count){
        $pairs=@(foreach($round in 0..($BalancedModuleRounds-1)){
            $items=@($balancedRows|Where-Object{$_.round -eq $round})
            $old=@($items|Where-Object{$_.profile -ceq ('v0.4.0-'+$Baselines[0].Insert(2,'.')+'-faithful')})
            $new=@($items|Where-Object{$_.profile -ceq 'candidate-faithful'})
            if($old.Count -ne 2 -or $new.Count -ne 2){throw 'Incomplete balanced module pair'}
            $baseline=[Math]::Sqrt($old[0].scripts_per_second*$old[1].scripts_per_second)
            $candidate=[Math]::Sqrt($new[0].scripts_per_second*$new[1].scripts_per_second)
            [ordered]@{round=$round;baseline_geometric_scripts_per_second=$baseline;candidate_geometric_scripts_per_second=$candidate;candidate_to_baseline_ratio=$candidate/$baseline}
        })
        $balancedSummary=[ordered]@{rounds=$BalancedModuleRounds;pairs=$pairs;median_candidate_to_baseline_ratio=(Percentile @($pairs.candidate_to_baseline_ratio) 50);minimum_ratio=($pairs.candidate_to_baseline_ratio|Measure-Object -Minimum).Minimum;maximum_ratio=($pairs.candidate_to_baseline_ratio|Measure-Object -Maximum).Maximum;scope='One-thread faithful large-module ABBA ordering; geometric two-observation cohort means per round reduce order drift; finite shared-host samples do not establish statistical significance or isolate CPU mechanisms.'}
    }
    $processor = $env:PROCESSOR_IDENTIFIER
    try { $processor = (Get-ItemProperty -LiteralPath 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0').ProcessorNameString } catch {}
    $summary = [ordered]@{schema=1;status='measured';passed=$true;started_at=$started;finished_at=[DateTime]::UtcNow.ToString('o');candidate_sha256=$plan.candidate_sha256;baseline_v2_sha256=$plan.baseline_v2_sha256;baseline_v3_sha256=$plan.baseline_v3_sha256;baseline_rc1_sha256=$plan.baseline_rc1_sha256;baseline_rc2_sha256=$plan.baseline_rc2_sha256;baseline_rc3_sha256=$plan.baseline_rc3_sha256;historical_rc3_report_sha256=$(if($Baselines -contains 'rc3'){Hash-File (Join-Path (Split-Path -Parent $BaselineRc3) 'performance.json')}else{$null});selected_baselines=$Baselines;baseline_v2_manifest_sha256=$(if($v2ManifestPath){Hash-File $v2ManifestPath}else{$null});baseline_v3_manifest_sha256=$(if($v3ManifestPath){Hash-File $v3ManifestPath}else{$null});historical_archive_manifest_sha256=(Hash-File (Join-Path $taskRoot 'evidence/releases/0.4.0-rc.1-manifest.json'));historical_rc2_manifest_sha256=$(if($Baselines -contains 'rc2'){Hash-File (Join-Path $taskRoot 'evidence/releases/0.4.0-rc.2-manifest.json')}else{$null});corpus_manifest_sha256=$plan.corpus_manifest_sha256;input_cases=2002;independent_small_inputs=2000;large_function_updates=4096;large_module_functions=512;processor=$processor;logical_cpus=[Environment]::ProcessorCount;os=[Environment]::OSVersion.VersionString;rustc=(& rustc --version);threads=$Threads;minimum_iterations=$Iterations;minimum_core_seconds=$MinimumSeconds;cold_samples=$ColdSamples;validation_observations_per_input=$ValidationIterations;source_files=$sourceBefore;tools=$toolIdentities.ToArray();warm_core=$warmRows.ToArray();balanced_module=$balancedRows.ToArray();balanced_module_summary=$balancedSummary;allocation_stacks=$stackRows.ToArray();cold_cli=$coldRows.ToArray();strict_validation=$validationRows.ToArray();allocation_profiles=$allocationRows.ToArray();verified_source=$verifiedRows.ToArray();raw_reports=$rawReports.ToArray();limitations=@('Matched owned synthetic bytecode corpus; not representative native Roblox extraction coverage.','Core timing explicitly disables validation; it is not verified-typed latency. V2 provides only its faithful default and lacks newer per-stage counters.','Per-stage totals include summed worker time; histogram long-duration quantiles are inclusive bounds, not exact wall-time quantiles.','Cold CLI includes process launch, input/output files and 10ms polling overhead; filesystem cache state is not flushed.','Parent-only working sets exclude analyzer processes; aggregate process-tree service measurements are separate evidence.','Shared Windows host; unrelated processes and OS scheduling are not isolated. Baselines are rerun on the same host, not substituted from historical reports.','Large rows have only the actual calibrated sample counts shown; three observations are a minimum and p95 can equal the maximum.','Strict-check profiles remain distinct from verified_typed policy. A measured strict failure remains a failure, not a quality success.','No executor/transport latency is included; no recovered program executes in these performance measurements.','Coverage-guided fuzzing, correctness gates and resource admission are separate evidence, not inferred from timings.')}
    Save-Json $Report (Public-Value $summary)
    Save-Json (Join-Path $Destination 'comparison.json') $summary
    Write-Output ('Wrote performance evidence to ' + $Report)
} catch {
    Save-Json $Report (Public-Value ([ordered]@{schema=1;status='failed';passed=$false;started_at=$started;candidate_sha256=$plan.candidate_sha256;error=$_.Exception.Message;completed_warm_rows=$warmRows.Count;completed_cold_rows=$coldRows.Count;note='Partial or failed performance runs do not validate a final release.'}))
    throw
} finally { Pop-Location }
