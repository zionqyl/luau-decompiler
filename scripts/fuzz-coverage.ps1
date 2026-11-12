param(
    [ValidateRange(1,10000)][int]$Iterations=500,
    [ValidateRange(10,3600)][int]$MaxSeconds=240,
    [int]$Seed=3021603,
    [ValidateRange(16,512)][int]$MaxCorpus=128,
    [string]$Destination=(Join-Path $PSScriptRoot '../artifacts/coverage-fuzz-v3'),
    [string]$Report=(Join-Path $PSScriptRoot '../docs/results/coverage-guided-v3.json'),
    [string]$ProfilerRuntime=(Join-Path $PSScriptRoot '../artifacts/coverage-runtime/lib'),
    [switch]$SkipBuild
)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'env.ps1')
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination=(Resolve-Path -LiteralPath $Destination).Path
$target=Join-Path $taskRoot 'artifacts/coverage-build'
$corpusDir=Join-Path $Destination 'corpus'
$profileDir=Join-Path $Destination 'profiles'
New-Item -ItemType Directory -Force -Path $corpusDir,$profileDir | Out-Null
$sysroot=(& rustc --print sysroot)
$hostTriple=((& rustc -vV | Select-String '^host: ').ToString() -replace '^host: ','')
if($hostTriple -cne 'x86_64-pc-windows-gnu'){throw 'This measured coverage driver currently supports Windows GNU only; use the standard fuzz target on other hosts.'}
$llvmBin=Join-Path $sysroot ('lib/rustlib/'+$hostTriple+'/bin')
$profdata=Join-Path $llvmBin 'llvm-profdata.exe'
$cov=Join-Path $llvmBin 'llvm-cov.exe'
if(-not(Test-Path -LiteralPath $profdata)-or-not(Test-Path -LiteralPath $cov)){throw 'Install the matching official rustup component llvm-tools-preview.'}
$utf8=[Text.UTF8Encoding]::new($false)
function Source-Snapshot {
    $paths=@(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'src') -Filter '*.rs' -File)
    $paths+=@(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'definitions') -File -ErrorAction SilentlyContinue)
    $paths+=@(Get-Item -LiteralPath (Join-Path $taskRoot 'Cargo.toml'),(Join-Path $taskRoot 'Cargo.lock'),(Join-Path $taskRoot 'examples/coverage_harness.rs'),(Join-Path $taskRoot 'scripts/fuzz-coverage.ps1'))
    $paths+=@(Get-Item -LiteralPath (Join-Path $taskRoot 'scripts/build-coverage-runtime.ps1'))
    $paths+=@(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'scripts/coverage-runtime') -File)
    return @($paths|Sort-Object FullName|ForEach-Object{[ordered]@{path=$_.FullName.Substring($taskRoot.Length+1).Replace('\','/');sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}})
}
function Tool([string]$Executable,[string[]]$Arguments){
    foreach($argument in $Arguments){if($argument.Contains('"')){throw 'Unsupported quote in LLVM argument.'}}
    $info=[Diagnostics.ProcessStartInfo]::new($Executable)
    $info.Arguments=(@($Arguments|ForEach-Object{'"'+$_+'"'}) -join ' ')
    $info.UseShellExecute=$false;$info.CreateNoWindow=$true;$info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
    $process=[Diagnostics.Process]::Start($info)
    try{
        $output=$process.StandardOutput.ReadToEndAsync();$errorOutput=$process.StandardError.ReadToEndAsync()
        if(-not $process.WaitForExit(30000)){$process.Kill();$process.WaitForExit();throw 'LLVM subprocess exceeded its 30-second bound.'}
        $value=$output.GetAwaiter().GetResult();$diagnostic=$errorOutput.GetAwaiter().GetResult()
        if($process.ExitCode -ne 0){throw ('LLVM command failed: '+$diagnostic.Substring(0,[Math]::Min(2048,$diagnostic.Length)))}
        if(-not [string]::IsNullOrWhiteSpace($diagnostic)){throw ('LLVM emitted diagnostics; coverage is not accepted: '+$diagnostic.Substring(0,[Math]::Min(2048,$diagnostic.Length)))}
        if($value.Length -gt 8*1024*1024){throw 'LLVM summary exceeded its output bound.'}
        return $value
    }finally{$process.Dispose()}
}
function Executable-Sections([string]$Path){
    $bytes=[IO.File]::ReadAllBytes($Path);$pe=[BitConverter]::ToInt32($bytes,60)
    $count=[BitConverter]::ToUInt16($bytes,$pe+6);$optional=[BitConverter]::ToUInt16($bytes,$pe+20);$table=$pe+24+$optional
    $hashes=@{}
    for($index=0;$index -lt $count;$index++){
        $entry=$table+40*$index;$name=[Text.Encoding]::ASCII.GetString($bytes,$entry,8).Trim([char]0)
        if($name -eq '.lprfn'){continue}
        $offset=[BitConverter]::ToUInt32($bytes,$entry+20);$size=[BitConverter]::ToUInt32($bytes,$entry+8)
        if($size -eq 0){continue}
        $hash=[Security.Cryptography.SHA256]::Create()
        try{$hashes[$name]=[BitConverter]::ToString($hash.ComputeHash($bytes,$offset,$size)).Replace('-','').ToLowerInvariant()}finally{$hash.Dispose()}
    }
    return $hashes
}
function Coverage([string]$Profile){
    $value=(Tool $cov @('export',$coverageObject,('-instr-profile='+$Profile),'--summary-only'))|ConvertFrom-Json
    $prefix=($taskRoot.Replace('\','/')+'/src/')
    $files=@($value.data[0].files|Where-Object{$_.filename.Replace('\','/').StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)})
    if($files.Count -eq 0){throw 'LLVM export has no owned Rust-core source files; instrumentation is not valid.'}
    $covered=0L;$total=0L
    foreach($file in $files){$covered+=[long]$file.summary.regions.covered;$total+=[long]$file.summary.regions.count}
    return @{covered=$covered;total=$total;files=@($files|ForEach-Object{@{path=$_.filename.Replace('\','/').Substring($taskRoot.Length+1);regions=$_.summary.regions;functions=$_.summary.functions;lines=$_.summary.lines}})}
}
function Mutate([byte[]]$Bytes,[Random]$Random){
    $list=[Collections.Generic.List[byte]]::new();$list.AddRange($Bytes)
    switch($Random.Next(8)){
        0 {if($list.Count){$index=$Random.Next($list.Count);$list[$index]=$list[$index] -bxor (1 -shl $Random.Next(8))}}
        1 {if($list.Count){$list[$Random.Next($list.Count)]=[byte]$Random.Next(256)}}
        2 {$extra=New-Object byte[] ($Random.Next(1,9));$Random.NextBytes($extra);$list.InsertRange($Random.Next($list.Count+1),[byte[]]$extra)}
        3 {if($list.Count){$index=$Random.Next($list.Count);$list.RemoveRange($index,$list.Count-$index)}}
        4 {$extra=New-Object byte[] ($Random.Next(1,9));$Random.NextBytes($extra);$list.AddRange([byte[]]$extra)}
        5 {if($list.Count){$list[0]=[byte]$Random.Next(3,16)}}
        6 {if($list.Count){$index=$Random.Next($list.Count);$count=[Math]::Min($Random.Next(1,9),$list.Count-$index);for($j=0;$j -lt $count;$j++){$list[$index+$j]=0}}}
        7 {if($list.Count){$index=$Random.Next($list.Count);$count=[Math]::Min($Random.Next(1,17),$list.Count-$index);$chunk=$list.GetRange($index,$count);$list.InsertRange($Random.Next($list.Count+1),$chunk)}}
    }
    if($list.Count -gt 16384){$list.RemoveRange(16384,$list.Count-16384)}
    return ,$list.ToArray()
}
$sourceBefore=Source-Snapshot
$sourceSignature=$sourceBefore|ConvertTo-Json -Depth 5 -Compress
$oldFlags=$env:RUSTFLAGS;$oldEncoded=$env:CARGO_ENCODED_RUSTFLAGS;$oldTarget=$env:CARGO_TARGET_DIR;$oldProfile=$env:LLVM_PROFILE_FILE
$flags='-Cinstrument-coverage -Ccodegen-units=1 -Cdebuginfo=1'
$harness=Join-Path $target 'debug/examples/coverage_harness.exe'
$process=$null
Push-Location $taskRoot
try{
    $env:CARGO_TARGET_DIR=$target;$env:RUSTFLAGS=$flags;$env:LLVM_PROFILE_FILE=Join-Path $profileDir 'shutdown-%p.profraw'
    $encoded=@('-Cinstrument-coverage','-Ccodegen-units=1','-Cdebuginfo=1','-Cllvm-args=-enable-name-compression=false','-Clink-arg=-Wl,--no-gc-sections')
    if(Test-Path -LiteralPath (Join-Path $ProfilerRuntime 'libprofiler_builtins.rlib')){
        $runtimePath=(Resolve-Path -LiteralPath $ProfilerRuntime).Path
        $runtimeManifestPath=Join-Path (Split-Path -Parent $runtimePath) 'manifest.json'
        if(-not(Test-Path -LiteralPath $runtimeManifestPath)){throw 'Build the pinned GNU runtime with scripts/build-coverage-runtime.ps1 before fuzzing.'}
        $runtimeManifest=Get-Content -LiteralPath $runtimeManifestPath -Raw|ConvertFrom-Json
        if((Get-FileHash -LiteralPath (Join-Path $runtimePath 'libprofiler_builtins.rlib') -Algorithm SHA256).Hash.ToLowerInvariant() -cne $runtimeManifest.marker_sha256 -or (Get-FileHash -LiteralPath (Join-Path $runtimePath 'libprofiler-rt.a') -Algorithm SHA256).Hash.ToLowerInvariant() -cne $runtimeManifest.library_sha256){throw 'Profiling-runtime library differs from its build manifest.'}
        $linkerPath=Join-Path (Split-Path -Parent $runtimePath) 'bin'


        $encoded+=@('--cfg',('coverage_runtime_'+$runtimeManifest.marker_sha256))
        $encoded+=@('-L',('all='+$runtimePath),'-Clink-arg=-fuse-ld=lld',('-Clink-arg=-B'+$linkerPath+'/'))
    }
    $env:CARGO_ENCODED_RUSTFLAGS=$encoded -join ([char]31)
    $buildStampPath=Join-Path $target 'coverage-harness.manifest.json'
    $buildIdentity=[ordered]@{source_files=$sourceBefore;flags=$encoded;rustc=(& rustc -vV)}|ConvertTo-Json -Depth 8 -Compress
    if(-not $SkipBuild){
        & cargo build --offline --locked --features coverage-harness --example coverage_harness
        if($LASTEXITCODE -ne 0){throw 'Instrumented Rust harness build failed.'}
        if((Source-Snapshot|ConvertTo-Json -Depth 5 -Compress) -cne $sourceSignature){throw 'Coverage source changed during compilation.'}
        [IO.File]::WriteAllText($buildStampPath,(@{identity=$buildIdentity;harness_sha256=(Get-FileHash -LiteralPath $harness -Algorithm SHA256).Hash.ToLowerInvariant()}|ConvertTo-Json -Depth 4),$utf8)
    }else{
        if(-not(Test-Path -LiteralPath $buildStampPath)){throw 'SkipBuild requires a verified coverage build manifest; build normally first.'}
        $buildStamp=Get-Content -LiteralPath $buildStampPath -Raw|ConvertFrom-Json
        if($buildStamp.identity -cne $buildIdentity -or $buildStamp.harness_sha256 -cne (Get-FileHash -LiteralPath $harness -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'SkipBuild source/settings/tool/binary identity mismatch; rebuild normally.'}
    }
    if(-not(Test-Path -LiteralPath $harness)){throw 'Instrumented harness missing.'}




    $layout=(Tool $harness @('--coverage-layout'))|ConvertFrom-Json
    $image=[IO.File]::ReadAllBytes($harness);$pe=[BitConverter]::ToInt32($image,60)
    $sections=[BitConverter]::ToUInt16($image,$pe+6);$optional=[BitConverter]::ToUInt16($image,$pe+20);$table=$pe+24+$optional
    $nameBytes=$null
    for($i=0;$i -lt $sections;$i++){
        $entry=$table+40*$i;$name=[Text.Encoding]::ASCII.GetString($image,$entry,8).Trim([char]0)
        if($name -eq '.lprfn'){
            $rva=[BitConverter]::ToUInt32($image,$entry+12);$offset=[BitConverter]::ToUInt32($image,$entry+20);$size=[BitConverter]::ToUInt32($image,$entry+8)
            $prefix=[long]$layout.names_rva-$rva
            if($prefix -lt 0 -or $prefix+$layout.names_bytes -gt $size){throw 'Runtime names span is outside the PE section.'}
            $nameBytes=New-Object byte[] $layout.names_bytes;[Array]::Copy($image,$offset+$prefix,$nameBytes,0,$nameBytes.Length);break
        }
    }
    if(-not $nameBytes){throw 'Instrumented PE names section is missing.'}
    $readerNames=New-Object byte[] ($nameBytes.Length+1)
    [Array]::Copy($nameBytes,0,$readerNames,1,$nameBytes.Length)
    $namesPath=Join-Path $Destination 'coverage-names.bin';[IO.File]::WriteAllBytes($namesPath,$readerNames)
    $coverageObject=Join-Path $Destination 'coverage-analysis.exe'
    $objcopy=Join-Path $llvmBin 'llvm-objcopy.exe'
    $null=Tool $objcopy @(('--update-section=.lprfn='+$namesPath),$harness,$coverageObject)
    $beforeSections=Executable-Sections $harness;$afterSections=Executable-Sections $coverageObject
    foreach($name in $beforeSections.Keys){if($beforeSections[$name] -cne $afterSections[$name]){throw ('Analysis-copy transformation changed a section other than profile names: '+$name)}}
    $paths=[Collections.Generic.List[string]]::new()
    foreach($family in @('arithmetic','closures','while_repeat','tables','varargs_multret','numeric_for','generic_for','userdata_namecall')){
        foreach($mode in @('O0.D0','O2.D2')){
            foreach($root in @('tests/fixtures','tests/profile-fixtures/v14')){
                $path=Join-Path $taskRoot ($root+'/'+$family+'.'+$mode+'.bc')
                if((Test-Path -LiteralPath $path)-and(Get-Item -LiteralPath $path).Length -le 16384){$paths.Add($path)}
            }
        }
    }


    foreach($version in 7..13){
        foreach($family in @('arithmetic','closures')){
            foreach($mode in @('O0.D0','O2.D2')){
                $path=Join-Path $taskRoot ('tests/profile-fixtures/v'+$version+'/'+$family+'.'+$mode+'.bc')
                if(-not(Test-Path -LiteralPath $path)){throw ('Required versioned seed is missing: '+$path)}
                $paths.Add($path)
            }
        }
    }
    $paths=@($paths|Select-Object -Unique)
    if($paths.Count -lt 8){throw 'Fuzz seed families are incomplete; generate pinned fixtures first.'}
    if($paths.Count -gt $MaxCorpus){throw 'max_corpus must accommodate all required immutable seeds.'}
    $corpus=[Collections.Generic.List[object]]::new();$seeds=[Collections.Generic.List[object]]::new()
    foreach($path in $paths){$bytes=[IO.File]::ReadAllBytes($path);$sha=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant();$item=@{path=$path;bytes=$bytes;sha256=$sha;seed=$true};$corpus.Add($item);$seeds.Add(@{path=$path.Substring($taskRoot.Length+1).Replace('\','/');sha256=$sha;bytes=$bytes.Length;version=[int]$bytes[0]})}
    $startInfo=[Diagnostics.ProcessStartInfo]::new($harness);$startInfo.UseShellExecute=$false;$startInfo.CreateNoWindow=$true;$startInfo.RedirectStandardInput=$true;$startInfo.RedirectStandardOutput=$true;$startInfo.RedirectStandardError=$true
    $process=[Diagnostics.Process]::Start($startInfo)
    $errorTask=$process.StandardError.ReadToEndAsync()
    $random=[Random]::new($Seed)
    $rows=[Collections.Generic.List[object]]::new();$failures=[Collections.Generic.List[object]]::new()
    $globalProfile=Join-Path $Destination 'union.profdata';$candidateProfile=Join-Path $Destination 'candidate.profdata'
    $coverage=$null;$novel=0;$seedCovered=0L;$mutations=0;$accepted=0;$rejected=0;$clock=[Diagnostics.Stopwatch]::StartNew()
    for($index=0;$index -lt $paths.Count+$Iterations;$index++){
        if($clock.Elapsed.TotalSeconds -gt $MaxSeconds){break}
        $isSeed=$index -lt $paths.Count
        $parent=if($isSeed){$corpus[$index]}else{$corpus[$random.Next($corpus.Count)]}
        [byte[]]$bytes=if($isSeed){$parent.bytes}else{Mutate $parent.bytes $random}
        $case=Join-Path $Destination ('case-'+$index.ToString('D5')+'.bc');[IO.File]::WriteAllBytes($case,$bytes)
        $raw=Join-Path $profileDir ('case-'+$index.ToString('D5')+'.profraw')
        $request=@{input_path=$case;profile_path=$raw}|ConvertTo-Json -Compress
        $process.StandardInput.WriteLine($request);$process.StandardInput.Flush()
        $read=$process.StandardOutput.ReadLineAsync()
        if(-not $read.Wait(5000)){$failures.Add(@{case=$index;kind='timeout';path=$case});$process.Kill();break}
        $line=$read.GetAwaiter().GetResult()
        if(-not $line){$failures.Add(@{case=$index;kind='process_terminated';path=$case});break}
        $result=$line|ConvertFrom-Json
        if($result.status -eq 'panic'){$failures.Add(@{case=$index;kind='panic';path=$case;message=$result.message});break}
        if($result.profile_status -ne 0 -or -not(Test-Path -LiteralPath $raw)){throw 'LLVM profile was not successfully written.'}
        $arguments=@('merge','-sparse',$raw)
        if($coverage){$arguments+=$globalProfile}
        $arguments+=@('-o',$candidateProfile);$null=Tool $profdata $arguments
        $next=Coverage $candidateProfile
        $newRegions=if($coverage){$next.covered-$coverage.covered}else{$next.covered}
        if($newRegions -lt 0){throw 'Merged coverage regressed; campaign accounting is invalid.'}
        Copy-Item -LiteralPath $candidateProfile -Destination $globalProfile -Force
        $coverage=$next
        $sha=(Get-FileHash -LiteralPath $case -Algorithm SHA256).Hash.ToLowerInvariant()
        if(-not $isSeed){$mutations++}
        if($result.status -eq 'accepted'){$accepted++;if(-not $result.complete){throw 'Incomplete reconstruction was labeled accepted.'}}else{$rejected++}
        if($isSeed){$seedCovered=$coverage.covered}
        if(-not $isSeed -and $newRegions -gt 0){
            $novel++;$retained=Join-Path $corpusDir ($sha+'.bc');Copy-Item -LiteralPath $case -Destination $retained -Force
            if(-not @($corpus|Where-Object{$_.sha256 -ceq $sha}).Count){
                if($corpus.Count -ge $MaxCorpus){$remove=-1;for($j=0;$j -lt $corpus.Count;$j++){if(-not $corpus[$j].seed){$remove=$j;break}};if($remove -ge 0){$corpus.RemoveAt($remove)}}
                if($corpus.Count -lt $MaxCorpus){$corpus.Add(@{path=$retained;bytes=$bytes;sha256=$sha;seed=$false})}
            }
        }
        $rows.Add(@{case=$index;kind=if($isSeed){'seed'}else{'mutation'};parent_sha256=$parent.sha256;input_sha256=$sha;bytes=$bytes.Length;status=$result.status;stage=$result.stage;new_owned_regions=$newRegions;cumulative_owned_regions=$coverage.covered;elapsed_micros=$result.elapsed_micros;accounted_peak_bytes=$result.accounted_peak_bytes})
        Remove-Item -LiteralPath $case,$raw
        if(($index+1)%100 -eq 0){Write-Output ('Coverage cases '+($index+1)+': owned regions '+$coverage.covered+', novel mutations '+$novel)}
    }
    $clock.Stop();$process.StandardInput.Close()
    if(-not $process.WaitForExit(5000)){$process.Kill();$process.WaitForExit()}
    $stderr=$errorTask.GetAwaiter().GetResult()
    if($stderr){[IO.File]::WriteAllText((Join-Path $Destination 'harness.stderr'),$stderr,$utf8);$failures.Add(@{kind='runtime_stderr';message=$stderr.Substring(0,[Math]::Min(2048,$stderr.Length))})}
    $sourceAfter=Source-Snapshot;$sameSource=($sourceAfter|ConvertTo-Json -Depth 5 -Compress) -ceq $sourceSignature
    $complete=$mutations -eq $Iterations -and $failures.Count -eq 0 -and $sameSource -and $coverage -and $novel -gt 0
    $campaignReport=@{schema=1;passed=[bool]$complete;source_snapshot_unchanged=$sameSource;source_files=$sourceAfter;strategy='LLVM counter profiles merged into a covered-region union; only mutants increasing owned Rust-core coverage become mutation parents';never_executes_luau=$true;typing='off';strict_analysis='off';requested_mutation_iterations=$Iterations;mutations_executed=$mutations;seed_executions=$paths.Count;cases_executed=$rows.Count;accepted_validated_reconstructions=$accepted;rejected_inputs=$rejected;accepted_is_not_behavioral_equivalence=$true;novel_mutants=$novel;seed_owned_covered_regions=$seedCovered;final_owned_covered_regions=if($coverage){$coverage.covered}else{0};owned_regions_in_linked_instrumented_binary=if($coverage){$coverage.total}else{0};owned_files=if($coverage){$coverage.files}else{@()};random_seed=$Seed;random_generator='System.Random on the recorded .NET host';elapsed_seconds=$clock.Elapsed.TotalSeconds;global_time_bound_seconds=$MaxSeconds;max_corpus_parents=$MaxCorpus;harness_sha256=(Get-FileHash -LiteralPath $harness -Algorithm SHA256).Hash.ToLowerInvariant();llvm_cov_sha256=(Get-FileHash -LiteralPath $cov -Algorithm SHA256).Hash.ToLowerInvariant();llvm_profdata_sha256=(Get-FileHash -LiteralPath $profdata -Algorithm SHA256).Hash.ToLowerInvariant();instrumentation_flags=$flags;rustc=(& rustc --version);os=[Environment]::OSVersion.VersionString;dotnet=[Environment]::Version.ToString();seeds=$seeds.ToArray();failures=$failures.ToArray();results=$rows.ToArray();union_profile_sha256=if(Test-Path -LiteralPath $globalProfile){(Get-FileHash -LiteralPath $globalProfile -Algorithm SHA256).Hash.ToLowerInvariant()}else{$null}}
    $campaignReport.instrumentation_flags=$encoded
    $campaignReport.seed_versions=@($seeds.ToArray()|ForEach-Object {$_.version}|Sort-Object -Unique)
    $campaignReport.distinct_seed_bytecodes=@($seeds.ToArray()|ForEach-Object {$_.sha256}|Sort-Object -Unique).Count
    $campaignReport.analysis_copy_sha256=(Get-FileHash -LiteralPath $coverageObject -Algorithm SHA256).Hash.ToLowerInvariant()
    $campaignReport.analysis_copy_change='Only .lprfn representation: exactly one leading sentinel expected by the official linked-COFF reader; never executed.'
    $campaignReport.other_section_contents_unchanged=$true
    if($runtimeManifestPath){$campaignReport.runtime_manifest=$runtimeManifest;$campaignReport.runtime_manifest_sha256=(Get-FileHash -LiteralPath $runtimeManifestPath -Algorithm SHA256).Hash.ToLowerInvariant()}
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Report) | Out-Null
    [IO.File]::WriteAllText($Report,($campaignReport|ConvertTo-Json -Depth 16),$utf8)
    if(-not $complete){throw ('Coverage campaign incomplete or source changed: mutations '+$mutations+'/'+$Iterations+', failures '+$failures.Count+', source stable '+$sameSource)}
    Write-Output ('Real coverage-guided mutations '+$mutations+'/'+$Iterations+'; owned regions '+$seedCovered+' -> '+$coverage.covered+'; novel parents '+$novel)
}finally{
    if($process){if(-not $process.HasExited){$process.Kill();$process.WaitForExit()};$process.Dispose()}
    $env:RUSTFLAGS=$oldFlags;$env:CARGO_ENCODED_RUSTFLAGS=$oldEncoded;$env:CARGO_TARGET_DIR=$oldTarget;$env:LLVM_PROFILE_FILE=$oldProfile
    Pop-Location
}
