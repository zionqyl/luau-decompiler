param(
    [string]$Destination=(Join-Path $PSScriptRoot '../artifacts/coverage-runtime'),
    [switch]$Offline
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot=Split-Path -Parent $PSScriptRoot
$lockPath=Join-Path $PSScriptRoot 'coverage-runtime/upstream.lock.json'
$lock=Get-Content -LiteralPath $lockPath -Raw|ConvertFrom-Json
$Destination=[IO.Path]::GetFullPath($Destination)
$sourceRoot=Join-Path $Destination 'compiler-rt'
$objects=Join-Path $Destination 'objects'
$library=Join-Path $Destination 'lib'
$linkerBin=Join-Path $Destination 'bin'
New-Item -ItemType Directory -Force -Path $sourceRoot,$objects,$library,$linkerBin|Out-Null
$rustInfo=@(& rustc -vV)
if(($rustInfo|Select-String '^host: ').ToString() -notmatch 'x86_64-pc-windows-gnu$'){throw 'This runtime helper is limited to the recorded Windows GNU host.'}
$llvmVersion=($rustInfo|Select-String '^LLVM version: ').ToString()
if($llvmVersion -notmatch '^LLVM version: 23\.'){throw 'The pinned LLVM 23 profiling runtime requires a Rust compiler using LLVM major 23; other profiling ABIs are unsupported.'}
foreach($file in $lock.files){
    $path=Join-Path $sourceRoot $file.path
    if((Test-Path -LiteralPath $path) -and (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ceq $file.sha256){continue}
    if($Offline){throw ('Missing or changed pinned compiler-rt source: '+$file.path)}
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path)|Out-Null
    & curl.exe --noproxy '*' -fsSL --max-time 30 ($lock.base_url+$file.path) -o $path
    if($LASTEXITCODE -ne 0 -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $file.sha256){throw ('Pinned compiler-rt download/hash failed: '+$file.path)}
}
$shim=Join-Path $PSScriptRoot 'coverage-runtime/InstrProfilingPlatformWindows.gnu.c'
$sources=@($lock.files|Where-Object {$_.path.EndsWith('.c') -or $_.path.EndsWith('/InstrProfilingRuntime.cpp')}|ForEach-Object {Join-Path $sourceRoot $_.path})+@($shim)
$include=Join-Path $sourceRoot 'include'
$profile=Join-Path $sourceRoot 'lib/profile'
$outputs=[Collections.Generic.List[string]]::new()
foreach($source in $sources){
    $object=Join-Path $objects (([IO.Path]::GetFileNameWithoutExtension($source))+'.o')
    $compiler=if($source.EndsWith('.cpp')){'g++'}else{'gcc'}
    $standard=if($source.EndsWith('.cpp')){'-std=c++17'}else{'-std=gnu11'}
    & $compiler @($standard,'-O2','-DCOMPILER_RT_HAS_ATOMICS=1','-D_WIN32_WINNT=0x0600',('-I'+$include),('-I'+$profile),'-c',$source,'-o',$object)
    if($LASTEXITCODE -ne 0){throw ('Profiling-runtime compilation failed: '+$source)}
    $outputs.Add($object)
}
$archive=Join-Path $library 'libprofiler-rt.a'
if(Test-Path -LiteralPath $archive){Remove-Item -LiteralPath $archive}
$archiveArguments=@('rcs',$archive)+$outputs.ToArray()
& ar @archiveArguments
if($LASTEXITCODE -ne 0){throw 'Profiling-runtime archive failed.'}
$oldBootstrap=$env:RUSTC_BOOTSTRAP
try{


    $env:RUSTC_BOOTSTRAP='1'
    & rustc @('--crate-name','profiler_builtins','--crate-type','rlib','--edition','2021',(Join-Path $PSScriptRoot 'coverage-runtime/profiler.rs'),'-L',('native='+$library),'-o',(Join-Path $library 'libprofiler_builtins.rlib'))
    if($LASTEXITCODE -ne 0){throw 'Rust profiler-runtime marker build failed.'}
}finally{$env:RUSTC_BOOTSTRAP=$oldBootstrap}
$sysroot=(& rustc --print sysroot)
$linker=Join-Path $sysroot 'lib/rustlib/x86_64-pc-windows-gnu/bin/rust-lld.exe'
if(-not(Test-Path -LiteralPath $linker)){throw 'Installed stable Rust linker is unavailable.'}
$linkerCopy=Join-Path $linkerBin 'ld.lld.exe'
if(-not(Test-Path -LiteralPath $linkerCopy) -or (Get-FileHash -LiteralPath $linkerCopy -Algorithm SHA256).Hash -cne (Get-FileHash -LiteralPath $linker -Algorithm SHA256).Hash){Copy-Item -LiteralPath $linker -Destination $linkerCopy -Force}
$manifest=[ordered]@{
    schema=1;purpose='Rust-only source coverage, never executes Luau';upstream_release=$lock.release
    upstream_lock_sha256=(Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash.ToLowerInvariant()
    shim_sha256=(Get-FileHash -LiteralPath $shim -Algorithm SHA256).Hash.ToLowerInvariant()
    wrapper_sha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'coverage-runtime/profiler.rs') -Algorithm SHA256).Hash.ToLowerInvariant()
    library_sha256=(Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    marker_sha256=(Get-FileHash -LiteralPath (Join-Path $library 'libprofiler_builtins.rlib') -Algorithm SHA256).Hash.ToLowerInvariant()
    linker_sha256=(Get-FileHash -LiteralPath $linker -Algorithm SHA256).Hash.ToLowerInvariant()
    compiler=(& gcc --version|Select-Object -First 1);rustc=(& rustc --version);rustc_verbose=$rustInfo;llvm_version=$llvmVersion;required_llvm_major=23
    flags=@('-O2','-DCOMPILER_RT_HAS_ATOMICS=1','-D_WIN32_WINNT=0x0600');sources=$lock.files
}
[IO.File]::WriteAllText((Join-Path $Destination 'manifest.json'),($manifest|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
Write-Output ('Built hash-pinned LLVM profiling runtime: '+$library)
