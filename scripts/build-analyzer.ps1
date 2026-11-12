param([ValidateRange(1,8)][int]$Threads=4,[string]$Output='.tools/luau-quality.exe')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot=Split-Path -Parent $PSScriptRoot
$upstream=Join-Path $taskRoot 'vendor/luau-modern'
$revision='12a6ba75883272c79b66b59815efef4c574196f6'
if ((& git -C $upstream rev-parse HEAD) -cne $revision) {throw 'Analyzer upstream pin mismatch.'}
if ((& git -C $upstream status --porcelain --untracked-files=no)) {throw 'Analyzer upstream checkout is modified.'}
$objects=Join-Path $taskRoot 'artifacts/analyzer-objects'
New-Item -ItemType Directory -Force -Path $objects | Out-Null
$compiler=(Get-Command g++).Source
$libraries=@('Common','Ast','Config','Analysis','Compiler','Bytecode','VM')
$includes=@($libraries | ForEach-Object {'-I'+(Join-Path $upstream ($_+'/include'))})
$sources=@($libraries | ForEach-Object {Get-ChildItem -LiteralPath (Join-Path $upstream ($_+'/src')) -Filter '*.cpp' -ErrorAction SilentlyContinue})
$sources+=Get-Item -LiteralPath (Join-Path $taskRoot 'tests/analyzer_runner.cpp')
$runnerPath=Join-Path $taskRoot 'tests/analyzer_runner.cpp'
$runnerHash=(Get-FileHash -LiteralPath $runnerPath -Algorithm SHA256).Hash.ToLowerInvariant()
$active=[System.Collections.Generic.List[object]]::new()
$outputs=[System.Collections.Generic.List[string]]::new()
$compiled=$false
function Wait-Compilation {
    $item=$active[0]
    $item.process.WaitForExit()
    if($item.process.ExitCode -ne 0){throw ('Analyzer compilation failed: '+$item.source+' '+[IO.File]::ReadAllText($item.log))}
    if((Get-FileHash -LiteralPath $item.source -Algorithm SHA256).Hash -cne $item.hash){throw ('Analyzer source changed during compilation: '+$item.source)}
    [IO.File]::WriteAllText($item.stamp,$item.hash)
    $item.process.Dispose();$active.RemoveAt(0)
}
foreach($source in $sources) {
    $id=($source.FullName.Substring($taskRoot.Length+1)).Replace('\','_').Replace('/','_')
    $object=Join-Path $objects ($id+'.o');$stamp=$object+'.sha256'
    $hash=(Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash
    $outputs.Add($object)
    if((Test-Path -LiteralPath $object) -and (Test-Path -LiteralPath $stamp) -and [IO.File]::ReadAllText($stamp) -ceq $hash){continue}
    while($active.Count -ge $Threads){Wait-Compilation}
    $compiled=$true
    $log=$object+'.log'
    if(Test-Path -LiteralPath $stamp){Remove-Item -LiteralPath $stamp}
    $arguments=@('-std=c++17','-O1','-DNDEBUG','-Wno-attributes')+$includes+@('-c',('"'+$source.FullName+'"'),'-o',('"'+$object+'"'))
    $process=Start-Process -FilePath $compiler -ArgumentList $arguments -PassThru -WindowStyle Hidden -RedirectStandardError $log
    $null=$process.Handle
    $active.Add(@{process=$process;source=$source.FullName;log=$log;stamp=$stamp;hash=$hash})
}
while($active.Count){Wait-Compilation}
$Output=[IO.Path]::GetFullPath((Join-Path $taskRoot $Output))
$response=Join-Path $objects 'link.rsp'
[IO.File]::WriteAllLines($response,@($outputs | ForEach-Object {'"'+$_+'"'}))
$compilerVersion=(& $compiler --version|Select-Object -First 1)
$reuse=$false
if(-not $compiled -and (Test-Path -LiteralPath $Output) -and (Test-Path -LiteralPath ($Output+'.manifest.json'))){
    try {
        $prior=Get-Content -LiteralPath ($Output+'.manifest.json') -Raw|ConvertFrom-Json
        $reuse=$prior.protocol -ceq 'LQUAL/1' -and $prior.upstream_revision -ceq $revision -and $prior.source_sha256 -ceq $runnerHash -and $prior.compiler -ceq $compilerVersion -and $prior.binary_sha256 -ceq (Get-FileHash -LiteralPath $Output -Algorithm SHA256).Hash.ToLowerInvariant()
    }catch{$reuse=$false}
}
if(-not $reuse){
    & $compiler -static -municode ('@'+$response) -o $Output
    if($LASTEXITCODE -ne 0){throw 'Analyzer link failed.'}
}
$version=& $Output --version
if($LASTEXITCODE -ne 0 -or $version -notmatch '^LQUAL/1 Luau0.746'){throw 'Analyzer version check failed.'}
if((Get-FileHash -LiteralPath $runnerPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $runnerHash){throw 'Analyzer source changed during compilation; rebuild before recording provenance.'}
$manifest=[ordered]@{protocol='LQUAL/1';upstream_revision=$revision;source_sha256=$runnerHash;binary_sha256=(Get-FileHash $Output).Hash.ToLowerInvariant();compiler=$compilerVersion}
[IO.File]::WriteAllText(($Output+'.manifest.json'),($manifest|ConvertTo-Json),[Text.UTF8Encoding]::new($false))
Write-Output ('Built independent pinned analyzer '+$Output)
