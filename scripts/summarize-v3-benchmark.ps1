param(
    [string] $Comparison = (Join-Path $PSScriptRoot '../artifacts/v3-performance/comparison'),
    [string] $HelperComparison = (Join-Path $PSScriptRoot '../artifacts/v3-performance/pre-analyzer-accounting'),
    [string] $Destination = (Join-Path $PSScriptRoot '../docs/results/v3-performance.json')
)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$Comparison=(Resolve-Path -LiteralPath $Comparison).Path
$Destination=[IO.Path]::GetFullPath($Destination)
$rawDirectory=Join-Path (Split-Path -Parent $Destination) 'v3-performance-raw'
New-Item -ItemType Directory -Force -Path $rawDirectory | Out-Null
$data=Get-Content -LiteralPath (Join-Path $Comparison 'comparison.json') -Raw | ConvertFrom-Json
if (@($data.validation_profiles).Count -gt 0) {$HelperComparison=$Comparison}
$HelperComparison=(Resolve-Path -LiteralPath $HelperComparison).Path
$helper=Get-Content -LiteralPath (Join-Path $HelperComparison 'comparison.json') -Raw | ConvertFrom-Json
$raw=[Collections.Generic.List[object]]::new()
function Archive-Report([string]$Source,[string]$Name) {
    $target=Join-Path $rawDirectory ($Name+'.json.gz')
    $inputStream=[IO.File]::OpenRead($Source)
    $outputStream=[IO.File]::Create($target)
    $gzip=[IO.Compression.GZipStream]::new($outputStream,[IO.Compression.CompressionLevel]::Optimal)
    try {$inputStream.CopyTo($gzip)} finally {$gzip.Dispose();$outputStream.Dispose();$inputStream.Dispose()}
    $raw.Add([ordered]@{report=('v3-performance-raw/'+$Name+'.json.gz');sha256=(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant();uncompressed_sha256=(Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash.ToLowerInvariant();compression='gzip'})
}
function Percentile([object[]]$Values,[int]$Percent) {
    $sorted=@($Values | Sort-Object)
    if ($sorted.Count -eq 0) {return $null}
    $sorted[[Math]::Max(0,[int][Math]::Ceiling($sorted.Count*$Percent/100.0)-1)]
}
$rows=[Collections.Generic.List[object]]::new()
foreach ($group in $data.warm_core) {
    Archive-Report (Join-Path $Comparison $group.report) ($group.version+'-'+$group.scenario)
    foreach ($run in $group.data.results) {
        $r=$run.results[0]
        if ($r.complete_reconstructions -ne $r.scripts -or -not $group.data.deterministic_across_threads) {throw 'Incomplete or nondeterministic benchmark row.'}
        $rows.Add([ordered]@{version=$group.version;scenario=$group.scenario;threads=$r.threads;scripts=$r.scripts;iterations=$r.iterations;elapsed_ns=$r.elapsed_ns;throughput_per_second=$r.scripts_per_second;p50_latency_ns=$r.latency_p50_ns;p95_latency_ns=$r.latency_p95_ns;max_latency_ns=$r.latency_max_ns;peak_working_set_bytes=$run.peak_memory_bytes;phase_totals_micros=$r.phase_cpu_or_wait_micros_summed;phase_distributions=$r.phase_latency_distributions;binary_sha256=$run.executable_sha256;config_sha256=$group.config_sha256;minimum_duration_reached=$run.duration_target_reached})
    }
}
$validation=[Collections.Generic.List[object]]::new()
foreach ($mode in @('false','true')) {
    $source=Join-Path $HelperComparison ('validation-cache-'+$mode+'.json')
    Archive-Report $source ('helper-validation-cache-'+$mode)
    $report=Get-Content -LiteralPath $source -Raw | ConvertFrom-Json
    foreach ($group in ($report.results | Group-Object input_index)) {
        $items=@($group.Group)
        $warm=@($items | Select-Object -Skip 1)
        $strict=@($items | Group-Object {$_.validation.strict_analysis} | ForEach-Object {[ordered]@{status=$_.Name;observations=$_.Count}})
        $validation.Add([ordered]@{path=$items[0].path;cache_enabled=($mode -eq 'true');observations=$items.Count;warm_observations=$warm.Count;first_cohort=$items[0].cohort;first_wall_ns=$items[0].wall_ns;warm_p50_ns=(Percentile @($warm.wall_ns) 50);warm_p95_ns=(Percentile @($warm.wall_ns) 95);warm_cache_hits=@($warm | Where-Object {$_.validation.cache_hit}).Count;strict_outcomes=$strict;syntax=$items[0].validation.syntax;compilation=$items[0].validation.compilation;diagnostic_count=$items[0].validation.diagnostics.Count;explicit_any=$items[0].validation.explicit_any;inferred_any=$items[0].validation.inferred_any;type_assertions=$items[0].validation.type_assertions;first_validation_micros=$items[0].stats.validation_micros;first_compiler_micros=$items[0].validation.compiler_micros;first_analyzer_micros=$items[0].validation.analyzer_micros;source_sha256=$items[0].source_sha256;analyzer_sha256=$items[0].validation.analyzer_sha256;definitions_sha256=$items[0].validation.definitions_sha256})
    }
}
foreach ($mode in @('faithful','annotated')) {Archive-Report (Join-Path $HelperComparison ('allocations-'+$mode+'.json')) ('helper-final-allocations-'+$mode)}
$profiler=Join-Path $HelperComparison 'measured-profile_validation.exe'
$allocator=Join-Path $HelperComparison 'measured-profile_allocations.exe'
$profilerHash=if(Test-Path -LiteralPath $profiler){(Get-FileHash -LiteralPath $profiler -Algorithm SHA256).Hash.ToLowerInvariant()}else{$helper.validation_profiles[0].executable_sha256}
$allocatorHash=if(Test-Path -LiteralPath $allocator){(Get-FileHash -LiteralPath $allocator -Algorithm SHA256).Hash.ToLowerInvariant()}else{$helper.allocation_profiles[0].executable_sha256}
if(-not $profilerHash -or -not $allocatorHash){throw 'Measured helper hashes are unavailable.'}
$historicalHelpers=$helper.v3_binary_sha256 -ne $data.v3_binary_sha256
$summary=[ordered]@{
    schema=1;measured_at=$data.measured_at;warm_core_cli_sha256=$data.v3_binary_sha256;baseline_cli_sha256=$data.baseline_binary_sha256;corpus_manifest_sha256=$data.corpus_manifest_sha256
    machine=$data.warm_core[0].data.processor;os=$data.warm_core[0].data.os;rustc=$data.warm_core[0].data.rustc
    warm_core=$rows.ToArray();validation_helper=$validation.ToArray();raw_reports=$raw.ToArray()
    helper_provenance=[ordered]@{historical_helpers=$historicalHelpers;associated_cli_sha256=$helper.v3_binary_sha256;validation_helper_sha256=$profilerHash;allocation_helper_sha256=$allocatorHash;note=$(if($historicalHelpers){'Helpers were built before analyzer resident accounting changed64MiB to192MiB. They ran without an aggregate MemoryBudget, so that accounting branch was inactive. Their source/binary provenance is distinct from the final CLI comparison.'}else{'Helper executables are recorded separately from the CLI. These measurements ran without an aggregate MemoryBudget; external analyzer memory is excluded from the Rust helper process peak.'})}
    limitations=@('Owned synthetic corpus; no empirical performance claim for arbitrary native Roblox modules.','Warm large-case rows contain only calibrated samples shown; short runs are not robust tail-latency estimates.','Analyzer helper peak reports exclude external analyzer subprocess memory; no aggregate process-tree peak was measured.','Strict-analysis failure remains failure even when syntax/recompilation and timing succeeded.','No adapter/network latency is included; service timing is separate.','Per-stage histogram bounds are exact integer microseconds below2048 and logarithmic inclusive bounds above; they are not exact long-duration quantiles.')
}
[IO.File]::WriteAllText($Destination,($summary | ConvertTo-Json -Depth 20),[Text.UTF8Encoding]::new($false))
