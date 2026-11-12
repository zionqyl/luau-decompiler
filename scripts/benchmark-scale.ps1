param(
    [string] $Corpus = (Join-Path $PSScriptRoot '../artifacts/scale-corpus'),
    [string] $Destination = (Join-Path $PSScriptRoot '../artifacts/benchmarks-scale'),
    [string] $Binary = (Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [ValidateRange(1,64)][int[]] $Threads = @(1,2,4,8),
    [ValidateRange(1,1000)][int] $SmallIterations = 10,
    [ValidateRange(1,10000)][int] $LargeFunctionIterations = 50,
    [ValidateRange(1,10000)][int] $LargeModuleIterations = 20,
    [ValidateRange(0,1000)][int] $Warmup = 3,
    [ValidateRange(0,60)][double] $MinimumSeconds = 1,
    [ValidateRange(1,20)][int] $BatchRuns = 2,
    [ValidateRange(1,32)][int] $Window = 8,
    [ValidateRange(1,86400)][int] $TimeoutSeconds = 1800,
    [switch] $SkipBuild
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot=Split-Path -Parent $PSScriptRoot
$Corpus=(Resolve-Path -LiteralPath $Corpus).Path
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination=(Resolve-Path -LiteralPath $Destination).Path
$utf8=[System.Text.UTF8Encoding]::new($false)
$newline=([char]10).ToString()
if (@($Threads | Select-Object -Unique).Count -ne $Threads.Count) { throw 'Thread counts must be unique.' }
$manifestPath=Join-Path $Corpus 'manifest.json'
$manifest=Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($manifest.cases.Count -lt 1002 -or $manifest.independent_inputs -lt 1000) { throw 'Scale measurements require at least 1000 independent scripts and two large cases.' }
$behaviorPath=Join-Path $taskRoot 'docs/results/scale-behavior.json'
if (-not (Test-Path -LiteralPath $behaviorPath)) { throw 'Run the typed large_scale_behavior test before measuring.' }
$behavior=Get-Content -LiteralPath $behaviorPath -Raw | ConvertFrom-Json
if ($behavior.oracle_protocol -ne 'LOBS/1' -or $behavior.input_count -ne 2 -or $behavior.typed_comparisons -ne 8 -or @($behavior.failures).Count -ne 0) { throw 'Large scale behavioral evidence is incomplete.' }

$groups=@('many_independent_inputs','one_large_function','one_large_module')
$groupPaths=@{}
$groupBytes=@{}
foreach ($group in $groups) {
    $cases=@($manifest.cases | Where-Object {$_.category -eq $group})
    if ($cases.Count -eq 0) { throw ('Missing benchmark category '+$group) }
    $paths=[System.Collections.Generic.List[string]]::new()
    $bytes=0L
    foreach ($case in $cases) {
        $source=Join-Path $Corpus $case.source
        $bytecode=Join-Path $Corpus $case.bytecode
        if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -ne $case.source_sha256) { throw ('Source hash mismatch: '+$case.name) }
        if ((Get-FileHash -LiteralPath $bytecode -Algorithm SHA256).Hash.ToLowerInvariant() -ne $case.bytecode_sha256) { throw ('Bytecode hash mismatch: '+$case.name) }
        $bytes+=(Get-Item -LiteralPath $bytecode).Length
        $paths.Add($bytecode)
        if ($group -ne 'many_independent_inputs') {
            $evidence=@($behavior.results | Where-Object {$_.name -eq $case.name})
            if ($evidence.Count -ne 1 -or -not $evidence[0].verified -or $evidence[0].fixture_sha256 -ne $case.bytecode_sha256) { throw ('Typed evidence does not match large fixture '+$case.name) }
        }
    }
    $pathManifest=Join-Path $Destination ('paths-'+$group+'.json')
    [System.IO.File]::WriteAllText($pathManifest,(ConvertTo-Json -InputObject $paths.ToArray())+$newline,$utf8)
    $groupPaths[$group]=$paths.ToArray()
    $groupBytes[$group]=$bytes
}

function Quote-Argument([string] $Value) {
    if ($Value.Contains('"') -or $Value.Contains([char]0)) { throw 'Invalid native argument.' }
    return '"'+$Value+'"'
}
function Measure-Batch([string[]] $Arguments,[string] $Stdout,[string] $Stderr) {
    $clock=[System.Diagnostics.Stopwatch]::StartNew()
    $process=Start-Process -FilePath $Binary -ArgumentList $Arguments -PassThru -WindowStyle Hidden -RedirectStandardOutput $Stdout -RedirectStandardError $Stderr
    try {
        $null=$process.Handle
        $peak=0L
        $cpu=$null
        while (-not $process.HasExited) {
            $process.Refresh()
            try { $peak=[Math]::Max($peak,$process.PeakWorkingSet64) } catch {}
            try { $sample=$process.TotalProcessorTime.TotalSeconds; if ($null -eq $cpu -or $sample -gt $cpu) { $cpu=$sample } } catch {}
            if ($clock.Elapsed.TotalSeconds -gt $TimeoutSeconds) { $process.Kill(); $process.WaitForExit(); throw 'Streaming batch exceeded its timeout.' }
            Start-Sleep -Milliseconds 10
        }
        $process.WaitForExit()
        $clock.Stop()
        try { $peak=[Math]::Max($peak,$process.PeakWorkingSet64) } catch {}
        try { $sample=$process.TotalProcessorTime.TotalSeconds; if ($null -eq $cpu -or $sample -gt $cpu) { $cpu=$sample } } catch {}
        if ($process.ExitCode -ne 0) {
            $message=if (Test-Path -LiteralPath $Stderr) {[System.IO.File]::ReadAllText($Stderr)} else {''}
            throw ('Streaming batch failed with exit '+$process.ExitCode+': '+$message)
        }
        if ($peak -le 0) { throw 'OS peak working-set measurement unavailable.' }
        return [pscustomobject]@{wall_seconds=$clock.Elapsed.TotalSeconds;process_cpu_seconds=$cpu;peak_memory_bytes=$peak}
    } finally { $process.Dispose() }
}

Push-Location $taskRoot
try {
    if (-not $SkipBuild) {
        & cargo build --release --offline --locked --bin luau-decompile
        if ($LASTEXITCODE -ne 0) { throw 'Release build failed.' }
    }
    $Binary=(Resolve-Path -LiteralPath $Binary).Path
    $binaryHash=(Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash.ToLowerInvariant()
    $warmRows=[System.Collections.Generic.List[object]]::new()
    $smallReference=$null
    foreach ($group in $groups) {
        $iterations=switch ($group) {
            'many_independent_inputs' {$SmallIterations}
            'one_large_function' {$LargeFunctionIterations}
            'one_large_module' {$LargeModuleIterations}
        }
        $warmDirectory=Join-Path $Destination ('warm-'+$group)
        $parameters=@{
            Manifest=(Join-Path $Destination ('paths-'+$group+'.json'))
            Threads=$Threads;Iterations=$iterations;Warmup=$Warmup;Destination=$warmDirectory
            MinimumSeconds=$MinimumSeconds
            Binary=$Binary;SkipBuild=$true;SkipAllocations=$true;TimeoutSeconds=$TimeoutSeconds
        }
        & (Join-Path $PSScriptRoot 'benchmark.ps1') @parameters
        $warm=Get-Content -LiteralPath (Join-Path $warmDirectory 'summary.json') -Raw | ConvertFrom-Json
        if (-not $warm.deterministic_across_threads -or $warm.input_count -ne $groupPaths[$group].Count) { throw 'Warm core report is incomplete or nondeterministic.' }
        $warmRows.Add([ordered]@{category=$group;input_count=$groupPaths[$group].Count;input_bytes=$groupBytes[$group];report=('warm-'+$group+'/summary.json');results=$warm.results})
        if ($group -eq 'many_independent_inputs') { $smallReference=@($warm.results[0].results[0].output_sha256) }
    }
    $paths=@($groupPaths['many_independent_inputs'])
    if ($smallReference.Count -ne $paths.Count) { throw 'Warm reference hashes are incomplete.' }
    $inputManifest=Join-Path $Destination 'paths-many_independent_inputs.json'
    $inputBudgetMiB=$Window*16
    $sourceBudgetMiB=$Window*64
    $streamRows=[System.Collections.Generic.List[object]]::new()
    foreach ($count in $Threads) {
        for ($run=1;$run -le $BatchRuns;$run++) {
            $directory=Join-Path $Destination ('stream-threads-'+$count+'-run-'+$run)
            $sources=Join-Path $directory 'sources'
            New-Item -ItemType Directory -Force -Path $sources | Out-Null
            $batchReport=Join-Path $directory 'stream.json'
            $arguments=@(
                'batch','--manifest',(Quote-Argument $inputManifest),'--out-dir',(Quote-Argument $sources)
                '--threads',$count.ToString(),'--window',$Window.ToString()
                '--batch-input-mib',$inputBudgetMiB.ToString(),'--batch-output-mib',$sourceBudgetMiB.ToString()
                '--batch-report',(Quote-Argument $batchReport),'--force'
            )
            $metrics=Measure-Batch $arguments (Join-Path $directory 'stdout') (Join-Path $directory 'stderr')
            $stream=Get-Content -LiteralPath $batchReport -Raw | ConvertFrom-Json
            if ($stream.submitted -ne $paths.Count -or $stream.succeeded -ne $paths.Count -or $stream.failed -ne 0) { throw 'Streaming batch reconstruction is incomplete.' }
            if ($stream.structured_reconstructions+$stream.dispatcher_reconstructions -ne $paths.Count) { throw 'Streaming batch quality counts are incomplete.' }
            $outputFiles=@(Get-ChildItem -LiteralPath $sources -Filter '*.luau' -File)
            if ($outputFiles.Count -ne $paths.Count) { throw 'Streaming output file count differs from input count.' }
            $bytes=0L
            $hashes=[System.Collections.Generic.List[object]]::new()
            for ($index=0;$index -lt $paths.Count;$index++) {
                $name=[System.IO.Path]::GetFileNameWithoutExtension($paths[$index])+'.luau'
                $output=Join-Path $sources $name
                $file=Get-Item -LiteralPath $output
                $hash=(Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()
                if ($hash -cne $smallReference[$index]) { throw ('Streaming output differs from warm core reference: '+$name) }
                $bytes+=$file.Length
                $hashes.Add([ordered]@{input=[System.IO.Path]::GetFileName($paths[$index]);output=$name;bytes=$file.Length;sha256=$hash})
            }
            if ($bytes -ne $stream.source_bytes) { throw 'Streaming source byte count differs from written files.' }
            if ($stream.peak_buffered_input_bytes -gt [long]$inputBudgetMiB*1024*1024 -or $stream.peak_retained_source_bytes -gt [long]$sourceBudgetMiB*1024*1024) { throw 'Streaming memory counters exceed configured bounds.' }
            [System.IO.File]::WriteAllText((Join-Path $directory 'output-hashes.json'),(ConvertTo-Json -InputObject $hashes.ToArray() -Depth 6)+$newline,$utf8)
            $streamRows.Add([ordered]@{
                threads=$count;run=$run;inputs=$paths.Count;input_bytes=$groupBytes['many_independent_inputs'];output_bytes=$bytes
                wall_seconds=$metrics.wall_seconds;inputs_per_second=$paths.Count/$metrics.wall_seconds
                input_bytes_per_second=$groupBytes['many_independent_inputs']/$metrics.wall_seconds
                output_bytes_per_second=$bytes/$metrics.wall_seconds;process_cpu_seconds=$metrics.process_cpu_seconds
                peak_memory_bytes=$metrics.peak_memory_bytes;window=$Window
                max_input_buffer_bytes=[long]$inputBudgetMiB*1024*1024;max_retained_source_bytes=[long]$sourceBudgetMiB*1024*1024
                stream_summary=$stream;output_hashes=('stream-threads-'+$count+'-run-'+$run+'/output-hashes.json')
                deterministic_against_warm_core=$true
            })
        }
    }
    $summary=[ordered]@{
        schema=1;measured_at=[DateTime]::UtcNow.ToString('o');executable_sha256=$binaryHash
        corpus_manifest_sha256=(Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
        bytecode_version=$manifest.bytecode_version;compiler_sha256=$manifest.compiler_sha256
        source_provenance='owned deterministic scale generator; source/bytecode hashes checked before measurements'
        behavior_report_sha256=(Get-FileHash -LiteralPath $behaviorPath -Algorithm SHA256).Hash.ToLowerInvariant()
        behavioral_scope='two large inputs at four seeds; many-input benchmark reconstruction/hash determinism is separate from behavioral validation'
        warm_core_timing='complete decompile calls; corpus file I/O and pool construction excluded; output hashing included in throughput'
        stream_timing='complete CLI process launch, manifest/input reads, pool construction, decompilation and logical file writes; excludes post-process file hashing; OS filesystem cache was primed by input validation and is uncontrolled; durable disk flush is not measured'
        peak_memory_note='Windows PeakWorkingSet64 high-water counter sampled every 10ms per isolated process; includes input/output/runtime/allocator overhead; final peak can be missed'
        deterministic_across_threads_and_runs=$true;warm_core=@($warmRows.ToArray());stream_batch=@($streamRows.ToArray())
    }
    [System.IO.File]::WriteAllText((Join-Path $Destination 'summary.json'),($summary | ConvertTo-Json -Depth 32)+$newline,$utf8)
    Write-Output ('Wrote separate scale warm-core and bounded-stream measurements to '+$Destination)
} finally { Pop-Location }
