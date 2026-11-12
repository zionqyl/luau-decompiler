[CmdletBinding()]
param(
    [string] $Corpus = (Join-Path $PSScriptRoot '../artifacts/v0.2-baseline/scale-corpus'),
    [string] $Baseline = (Join-Path $PSScriptRoot '../artifacts/v0.2-baseline/luau-decompile.exe'),
    [string] $Binary = (Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [string] $Destination = (Join-Path $PSScriptRoot '../artifacts/v3-performance/comparison'),
    [ValidateRange(1,64)][int[]] $Threads = @(1,2,4,8),
    [ValidateRange(0,100)][int] $Warmup = 3,
    [ValidateRange(0.1,60)][double] $MinimumSeconds = 1,
    [switch] $SkipBuild,
    [switch] $SkipValidation,
    [switch] $SkipAllocations
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot=Split-Path -Parent $PSScriptRoot
$utf8=[Text.UTF8Encoding]::new($false)
if (@($Threads | Select-Object -Unique).Count -ne $Threads.Count) { throw 'Thread counts must be unique.' }
$Corpus=(Resolve-Path -LiteralPath $Corpus).Path
$Baseline=(Resolve-Path -LiteralPath $Baseline).Path
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination=(Resolve-Path -LiteralPath $Destination).Path
$baselineManifest=Get-Content -LiteralPath (Join-Path (Split-Path -Parent $Baseline) 'manifest.json') -Raw | ConvertFrom-Json
if ((Get-FileHash -LiteralPath $Baseline -Algorithm SHA256).Hash.ToLowerInvariant() -ne $baselineManifest.binary_sha256 -or $baselineManifest.version -ne '0.2.0' -or -not $baselineManifest.baseline_gate_passed) { throw 'Preserved v0.2.0 executable provenance mismatch.' }
$corpusManifestPath=Join-Path $Corpus 'manifest.json'
$corpusManifest=Get-Content -LiteralPath $corpusManifestPath -Raw | ConvertFrom-Json
if ($corpusManifest.independent_inputs -ne 2000 -or $corpusManifest.large_function_updates -ne 4096 -or $corpusManifest.large_module_functions -ne 512 -or $corpusManifest.cases.Count -ne 2002) { throw 'Expected the preserved2000/4096/512 corpus.' }
$behavior=Get-Content -LiteralPath (Join-Path $taskRoot 'docs/results/scale-behavior.json') -Raw | ConvertFrom-Json
if ($behavior.oracle_protocol -ne 'LOBS/1' -or $behavior.typed_comparisons -ne 8 -or @($behavior.failures).Count -ne 0) { throw 'Run the controlled large_scale_behavior gate first.' }
$groups=@('many_independent_inputs','one_large_function','one_large_module')
$manifests=@{}
foreach ($group in $groups) {
    $paths=[Collections.Generic.List[string]]::new()
    foreach ($case in @($corpusManifest.cases | Where-Object {$_.category -eq $group})) {
        $source=Join-Path $Corpus $case.source
        $bytecode=Join-Path $Corpus $case.bytecode
        if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -ne $case.source_sha256 -or (Get-FileHash -LiteralPath $bytecode -Algorithm SHA256).Hash.ToLowerInvariant() -ne $case.bytecode_sha256) { throw ('Corpus changed: '+$case.name) }
        if ($group -ne 'many_independent_inputs') {
            $evidence=@($behavior.results | Where-Object {$_.name -eq $case.name})
            if ($evidence.Count -ne 1 -or -not $evidence[0].verified -or $evidence[0].fixture_sha256 -ne $case.bytecode_sha256) { throw ('Large-case typed evidence mismatch: '+$case.name) }
        }
        $paths.Add($bytecode)
    }
    if ($paths.Count -eq 0) { throw ('Missing group '+$group) }
    $manifestPath=Join-Path $Destination ('paths-'+$group+'.json')
    [IO.File]::WriteAllText($manifestPath,(ConvertTo-Json -InputObject $paths.ToArray()),$utf8)
    $manifests[$group]=$manifestPath
}
$faithfulConfig=Join-Path $Destination 'faithful-core.json'
$typedConfig=Join-Path $Destination 'annotated-core.json'
[IO.File]::WriteAllText($faithfulConfig,'{"typing":{"mode":"off"},"validation":{"mode":"off"}}',$utf8)
[IO.File]::WriteAllText($typedConfig,'{"typing":{"mode":"annotated"},"validation":{"mode":"off"}}',$utf8)

function Quote-Argument([string]$Value) {
    if ($Value.Contains('"') -or $Value.Contains([char]0)) { throw 'Invalid native argument.' }
    '"'+$Value+'"'
}
function Run-Profile([string]$Executable,[string[]]$Arguments,[string]$OutPath) {
    $process=Start-Process -FilePath $Executable -ArgumentList $Arguments -PassThru -WindowStyle Hidden -RedirectStandardOutput $OutPath -RedirectStandardError ($OutPath+'.stderr')
    try {
        $null=$process.Handle;$peak=0L;$watch=[Diagnostics.Stopwatch]::StartNew()
        while (-not $process.HasExited) {
            $process.Refresh();try {$peak=[Math]::Max($peak,$process.PeakWorkingSet64)} catch {}
            if ($watch.Elapsed.TotalSeconds -gt 1800) {$process.Kill();$process.WaitForExit();throw 'Profile timed out.'}
            Start-Sleep -Milliseconds 10
        }
        $process.WaitForExit();try {$peak=[Math]::Max($peak,$process.PeakWorkingSet64)} catch {}
        if ($process.ExitCode -ne 0) {throw ('Profile failed: '+[IO.File]::ReadAllText($OutPath+'.stderr'))}
        if ($peak -le 0) {throw 'No OS peak working-set measurement.'}
        [ordered]@{report=$OutPath;executable_sha256=(Get-FileHash -LiteralPath $Executable -Algorithm SHA256).Hash.ToLowerInvariant();peak_working_set_bytes=$peak;note='Isolated Rust helper Windows PeakWorkingSet64 sampled every10ms; includes loaded inputs, retained results, Rust workers and allocator overhead. External analyzer subprocess memory is excluded; this is not an aggregate process-tree peak.'}
    } finally {$process.Dispose()}
}

Push-Location $taskRoot
try {
    if (-not $SkipBuild) {
        & cargo build --release --offline --locked --bin luau-decompile --example profile_allocations --example profile_validation
        if ($LASTEXITCODE -ne 0) {throw 'Performance build failed.'}
    }
    $Binary=(Resolve-Path -LiteralPath $Binary).Path
    $versions=@(
        @{name='v0.2.0';binary=$Baseline;config=$null},
        @{name='v0.3.0-faithful';binary=$Binary;config=$faithfulConfig},
        @{name='v0.3.0-annotated';binary=$Binary;config=$typedConfig}
    )
    $reports=[Collections.Generic.List[object]]::new()
    foreach ($version in $versions) {
        foreach ($group in $groups) {
            $directory=Join-Path $Destination ($version.name+'/'+$group)
            $parameters=@{Manifest=$manifests[$group];Threads=$Threads;Iterations=1;Warmup=$Warmup;MinimumSeconds=$MinimumSeconds;Destination=$directory;Binary=$version.binary;SkipBuild=$true;SkipAllocations=$true}
            if ($version.config) {$parameters.Config=$version.config}
            & (Join-Path $PSScriptRoot 'benchmark.ps1') @parameters
            $data=Get-Content -LiteralPath (Join-Path $directory 'summary.json') -Raw | ConvertFrom-Json
            $reports.Add([ordered]@{version=$version.name;scenario=$group;report=($version.name+'/'+$group+'/summary.json');config_sha256=$(if($version.config){(Get-FileHash -LiteralPath $version.config -Algorithm SHA256).Hash.ToLowerInvariant()}else{$null});data=$data})
        }
    }
    $allocationRows=[Collections.Generic.List[object]]::new()
    if (-not $SkipAllocations) {
        $profiler=Join-Path $taskRoot 'target/release/examples/profile_allocations.exe'
        foreach ($mode in @(@{name='faithful';config=$faithfulConfig},@{name='annotated';config=$typedConfig})) {
            $output=Join-Path $Destination ('allocations-'+$mode.name+'.json')
            $arguments=@('--config',(Quote-Argument $mode.config),(Quote-Argument (Join-Path $Corpus 'large_function.bc')),(Quote-Argument (Join-Path $Corpus 'large_module.bc')))
            $allocationRows.Add((Run-Profile $profiler $arguments $output))
        }
    }
    $validationRows=[Collections.Generic.List[object]]::new()
    if (-not $SkipValidation) {
        $profiler=Join-Path $taskRoot 'target/release/examples/profile_validation.exe'
        foreach ($cache in @($false,$true)) {
            $output=Join-Path $Destination ('validation-cache-'+$cache.ToString().ToLowerInvariant()+'.json')
            $arguments=@('--config',(Quote-Argument $typedConfig),'--iterations','10',(Quote-Argument (Join-Path $Corpus 'input_0000.bc')),(Quote-Argument (Join-Path $Corpus 'large_function.bc')),(Quote-Argument (Join-Path $Corpus 'large_module.bc')))
            if ($cache) {$arguments+=@('--cache')}
            $validationRows.Add((Run-Profile $profiler $arguments $output))
        }
    }
    $result=[ordered]@{schema=1;measured_at=[DateTime]::UtcNow.ToString('o');corpus_manifest_sha256=(Get-FileHash -LiteralPath $corpusManifestPath -Algorithm SHA256).Hash.ToLowerInvariant();baseline_binary_sha256=$baselineManifest.binary_sha256;v3_binary_sha256=(Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash.ToLowerInvariant();threads=$Threads;warm_core=$reports.ToArray();allocation_profiles=$allocationRows.ToArray();validation_profiles=$validationRows.ToArray();note='Identical bytecode corpus; v2 default configuration vs v3 faithful/annotated with strict validation disabled. Core requests bypass service caches. Analyzer cold/warm/cache profiles are separate fresh processes. No adapter/network latency is included.'}
    [IO.File]::WriteAllText((Join-Path $Destination 'comparison.json'),($result | ConvertTo-Json -Depth 40),$utf8)
} finally {Pop-Location}
