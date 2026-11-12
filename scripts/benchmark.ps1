[CmdletBinding(DefaultParameterSetName='Paths')]
param(
    [Parameter(ParameterSetName='Paths')][string[]] $Inputs = @(),
    [Parameter(ParameterSetName='Manifest',Mandatory=$true)][string] $Manifest,
    [ValidateRange(1,64)][int[]] $Threads = @(1,2,4,8),
    [ValidateRange(1,10000)][int] $Iterations = 100,
    [ValidateRange(0,1000)][int] $Warmup = 3,
    [ValidateRange(0,60)][double] $MinimumSeconds = 1,
    [string] $Destination = (Join-Path $PSScriptRoot '../artifacts/benchmarks'),
    [string] $Binary = (Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'),
    [string] $Config,
    [switch] $SkipBuild,
    [switch] $SkipAllocations,
    [ValidateRange(1,128)][int] $AllocationSamples = 16,
    [ValidateRange(1,86400)][int] $TimeoutSeconds = 1800
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot=Split-Path -Parent $PSScriptRoot
$utf8=[System.Text.UTF8Encoding]::new($false)
$newline=([char]10).ToString()
if (@($Threads | Select-Object -Unique).Count -ne $Threads.Count) { throw 'Thread counts must be unique.' }
if ($Manifest) {
    $manifestPath=(Resolve-Path -LiteralPath $Manifest).Path
    if ((Get-Item -LiteralPath $manifestPath).Length -gt 4*1024*1024) { throw 'Path manifest exceeds 4 MiB.' }
    $manifestText=[System.IO.File]::ReadAllText($manifestPath)
    if (-not $manifestText.TrimStart().StartsWith('[')) { throw 'Manifest must be a JSON array of bytecode paths.' }
    $entries=$manifestText | ConvertFrom-Json
    $Inputs=@($entries | ForEach-Object {
        if ($_ -isnot [string]) { throw 'Manifest entries must be strings.' }
        $path=if ([System.IO.Path]::IsPathRooted($_)) {$_} else {Join-Path (Split-Path -Parent $manifestPath) $_}
        (Resolve-Path -LiteralPath $path).Path
    })
} elseif ($Inputs.Count -eq 0) {
    $Inputs=@(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'tests/fixtures') -Filter '*.bc' | Sort-Object Name | ForEach-Object {$_.FullName})
} else {
    $Inputs=@($Inputs | ForEach-Object {(Resolve-Path -LiteralPath $_).Path})
}
if ($Inputs.Count -eq 0 -or $Inputs.Count -gt 4096) { throw 'Provide 1..4096 benchmark inputs.' }
if ([long]$Inputs.Count*$Iterations -gt 1000000) { throw 'Benchmark exceeds one million latency samples per thread count.' }
if ($Config) { $Config=(Resolve-Path -LiteralPath $Config).Path }
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination=(Resolve-Path -LiteralPath $Destination).Path
$pathsFile=Join-Path $Destination 'input-paths.json'
[System.IO.File]::WriteAllText($pathsFile,(ConvertTo-Json -InputObject $Inputs)+$newline,$utf8)
$rows=[System.Collections.Generic.List[object]]::new()
$referenceOutputHashes=$null

function Quote-Argument([string] $Value) {
    if ($Value.Contains('"') -or $Value.Contains([char]0)) { throw 'Invalid native argument.' }
    return '"'+$Value+'"'
}
function Measure-Child([string] $Executable,[string[]] $Arguments,[string] $Stdout,[string] $Stderr,[bool] $RequirePeak=$true) {
    $clock=[System.Diagnostics.Stopwatch]::StartNew()
    $process=Start-Process -FilePath $Executable -ArgumentList $Arguments -PassThru -WindowStyle Hidden -RedirectStandardOutput $Stdout -RedirectStandardError $Stderr
    try {
        $null=$process.Handle
        $peak=0L
        $cpu=$null
        while (-not $process.HasExited) {
            $process.Refresh()
            try { $peak=[Math]::Max($peak,$process.PeakWorkingSet64) } catch {}
            try { $sample=$process.TotalProcessorTime.TotalSeconds; if ($null -eq $cpu -or $sample -gt $cpu) { $cpu=$sample } } catch {}
            if ($clock.Elapsed.TotalSeconds -gt $TimeoutSeconds) { $process.Kill(); $process.WaitForExit(); throw 'Benchmark child exceeded its timeout.' }
            Start-Sleep -Milliseconds 10
        }
        $process.WaitForExit()
        $clock.Stop()
        try { $peak=[Math]::Max($peak,$process.PeakWorkingSet64) } catch {}
        try { $sample=$process.TotalProcessorTime.TotalSeconds; if ($null -eq $cpu -or $sample -gt $cpu) { $cpu=$sample } } catch {}
        if ($process.ExitCode -ne 0) {
            $message=if (Test-Path -LiteralPath $Stderr) {[System.IO.File]::ReadAllText($Stderr)} else {''}
            throw ('Benchmark process failed with exit '+$process.ExitCode+': '+$message)
        }
        if ($peak -le 0) {
            if ($RequirePeak) { throw 'OS peak working-set accounting unavailable; zero is not a memory measurement.' }
            $peak=$null
        }
        return [pscustomobject]@{peak_memory_bytes=$peak;process_cpu_seconds=$cpu;process_wall_seconds=$clock.Elapsed.TotalSeconds}
    } finally { $process.Dispose() }
}

Push-Location $taskRoot
try {
    if (-not $SkipBuild) {
        $build=@('build','--release','--offline','--locked','--bin','luau-decompile')
        if (-not $SkipAllocations -and -not $Config) { $build+=@('--example','profile_allocations') }
        & cargo @build
        if ($LASTEXITCODE -ne 0) { throw 'Release benchmark build failed.' }
    }
    $Binary=(Resolve-Path -LiteralPath $Binary).Path
    $binaryHash=(Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash.ToLowerInvariant()
    foreach ($count in $Threads) {
        $report=Join-Path $Destination ('threads-'+$count+'.json')
        $rowIterations=$Iterations
        $maximumIterations=[int][Math]::Min(10000,[Math]::Floor(1000000/[double]$Inputs.Count))
        $calibration=[System.Collections.Generic.List[object]]::new()
        while ($true) {
            $arguments=@('benchmark','--manifest',(Quote-Argument $pathsFile),'--threads',$count.ToString(),'--iterations',$rowIterations.ToString(),'--warmup',$Warmup.ToString(),'-o',(Quote-Argument $report),'--force')
            if ($Config) { $arguments+=@('--config',(Quote-Argument $Config)) }
            $metrics=Measure-Child $Binary $arguments (Join-Path $Destination ('threads-'+$count+'.stdout')) (Join-Path $Destination ('threads-'+$count+'.stderr'))
            $data=Get-Content -LiteralPath $report -Raw | ConvertFrom-Json
            if (@($data.results).Count -ne 1 -or $data.results[0].scripts -ne [long]$Inputs.Count*$rowIterations) { throw 'Benchmark report is incomplete.' }
            if ($data.results[0].complete_reconstructions -ne $data.results[0].scripts) { throw 'Incomplete reconstruction cannot be benchmark success.' }
            $seconds=[double]$data.results[0].elapsed_ns/1000000000
            if ($seconds -ge $MinimumSeconds -or $rowIterations -ge $maximumIterations) { break }
            $calibration.Add([ordered]@{iterations=$rowIterations;elapsed_ns=$data.results[0].elapsed_ns;peak_memory_bytes=$metrics.peak_memory_bytes;included_in_final_row=$false})
            $next=[Math]::Ceiling($rowIterations*$MinimumSeconds/[Math]::Max($seconds,0.000001)*1.15)
            $rowIterations=[int][Math]::Min($maximumIterations,[Math]::Max($rowIterations+1,$next))
        }
        $hashes=@($data.results[0].output_sha256)
        if ($hashes.Count -ne $Inputs.Count) { throw 'Benchmark did not report one output hash for every input.' }
        $signature=$hashes -join ','
        if ($null -eq $referenceOutputHashes) { $referenceOutputHashes=$signature }
        elseif ($signature -cne $referenceOutputHashes) { throw 'Output hashes differ across thread counts.' }
        $data.peak_memory_bytes=$metrics.peak_memory_bytes
        $data.peak_memory_note='Windows PeakWorkingSet64 high-water counter sampled every 10ms in an isolated child; includes loaded corpus, output, workers and allocator overhead. A final peak after the last successful sample can be missed.'
        $data | Add-Member -Force -NotePropertyName process_cpu_seconds -NotePropertyValue $metrics.process_cpu_seconds
        $data | Add-Member -Force -NotePropertyName process_wall_seconds -NotePropertyValue $metrics.process_wall_seconds
        $data | Add-Member -Force -NotePropertyName executable_sha256 -NotePropertyValue $binaryHash
        $data | Add-Member -Force -NotePropertyName requested_iterations -NotePropertyValue $Iterations
        $data | Add-Member -Force -NotePropertyName requested_minimum_seconds -NotePropertyValue $MinimumSeconds
        $data | Add-Member -Force -NotePropertyName duration_target_reached -NotePropertyValue ($seconds -ge $MinimumSeconds)
        $data | Add-Member -Force -NotePropertyName calibration_runs -NotePropertyValue @($calibration.ToArray())
        [System.IO.File]::WriteAllText($report,($data | ConvertTo-Json -Depth 24)+$newline,$utf8)
        $rows.Add($data)
    }
    $allocation=[ordered]@{requested=(-not [bool]$SkipAllocations);population=$Inputs.Count;sampled=0;status='skipped';note='Allocation profiling is separate from uninstrumented timing.'}
    if ($Config -and -not $SkipAllocations) {
        $allocation.note='Skipped: allocation example supports the default configuration only.'
    } elseif (-not $SkipAllocations) {
        $sampleCount=[Math]::Min($AllocationSamples,$Inputs.Count)
        $selected=@(for ($index=0;$index -lt $sampleCount;$index++) {
            $offset=if ($sampleCount -eq 1) {0} else {[int][Math]::Floor($index*($Inputs.Count-1)/[double]($sampleCount-1))}
            $Inputs[$offset]
        })
        while ($selected.Count -gt 1 -and ((@($selected | ForEach-Object {(Quote-Argument $_).Length+1}) | Measure-Object -Sum).Sum -gt 24000)) { $selected=$selected[0..($selected.Count-2)] }
        $argvLength=(@($selected | ForEach-Object {(Quote-Argument $_).Length+1}) | Measure-Object -Sum).Sum
        if ($argvLength -gt 24000) {
            $allocation.note='Skipped: even one path exceeds the bounded native argument budget.'
        } else {
            $profiler=Join-Path $taskRoot 'target/release/examples/profile_allocations.exe'
            if (-not (Test-Path -LiteralPath $profiler)) { throw 'Allocation profiler unavailable; build it or pass -SkipAllocations.' }
            $profile=Join-Path $Destination 'allocations.json'
            $profileArgs=@($selected | ForEach-Object {Quote-Argument $_})
            $null=Measure-Child $profiler $profileArgs $profile (Join-Path $Destination 'allocations.stderr') $false
            $allocation.sampled=$selected.Count
            $allocation.status=if ($selected.Count -eq $Inputs.Count) {'complete_population'} else {'deterministic_evenly_spaced_sample'}
            $allocation.paths=$selected
            $allocation.profiler_sha256=(Get-FileHash -LiteralPath $profiler -Algorithm SHA256).Hash.ToLowerInvariant()
            $allocation.report='allocations.json'
        }
    }
    $processorName=$env:PROCESSOR_IDENTIFIER
    try { $processorName=(Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -ExpandProperty Name) } catch {
        try { $processorName=(Get-ItemProperty -LiteralPath 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0' -ErrorAction Stop).ProcessorNameString } catch {}
    }
    $summary=[ordered]@{
        schema=2;measured_at=[DateTime]::UtcNow.ToString('o');rustc=(& rustc --version);processor=$processorName
        os=[System.Environment]::OSVersion.VersionString;input_count=$Inputs.Count
        input_manifest='input-paths.json';input_manifest_sha256=(Get-FileHash -LiteralPath $pathsFile -Algorithm SHA256).Hash.ToLowerInvariant()
        executable_sha256=$binaryHash;deterministic_across_threads=$true;allocation_profile=$allocation;results=@($rows.ToArray())
    }
    [System.IO.File]::WriteAllText((Join-Path $Destination 'summary.json'),($summary | ConvertTo-Json -Depth 26)+$newline,$utf8)
    Write-Output ('Wrote isolated warm-core benchmarks to '+$Destination+'; allocation status: '+$allocation.status)
} finally { Pop-Location }
