param([string]$Directory=(Join-Path $PSScriptRoot '../artifacts/constructor-profile-rc'))
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$destination=Join-Path $root 'docs/results/constructor-profile-rc'
New-Item -ItemType Directory -Force -Path $destination | Out-Null
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Archive([string]$Name){
    $inputPath=Join-Path $Directory ($Name+'.json')
    $outputPath=Join-Path $destination ($Name+'.json.gz')
    $inputStream=[IO.File]::OpenRead($inputPath)
    $outputStream=[IO.File]::Create($outputPath)
    $zip=[IO.Compression.GZipStream]::new($outputStream,[IO.Compression.CompressionMode]::Compress)
    try{$inputStream.CopyTo($zip)}finally{$inputStream.Dispose();$zip.Dispose();$outputStream.Dispose()}
    [ordered]@{path=('docs/results/constructor-profile-rc/'+$Name+'.json.gz');sha256=(Hash $outputPath);uncompressed_sha256=(Hash $inputPath)}
}
$before=(Get-Content -LiteralPath (Join-Path $Directory 'before.json') -Raw | ConvertFrom-Json).results[0]
$after=(Get-Content -LiteralPath (Join-Path $Directory 'after.json') -Raw | ConvertFrom-Json).results[0]
if($before.source_sha256 -cne $after.source_sha256){throw 'Constructor optimization changed the measured source output'}
$rows=@()
foreach($entry in @(@('before',$before),@('after',$after))){
    $row=$entry[1]
    $rows += [ordered]@{phase=$entry[0];allocations=$row.allocations;reallocations=$row.reallocations;bytes_requested=$row.bytes_requested;peak_additional_live_heap_bytes=$row.peak_additional_live_heap_bytes;reconstruction_microseconds=$row.result.Ok.reconstruct_micros;total_microseconds=$row.result.Ok.total_micros;output_sha256=$row.source_sha256}
}
$report=[ordered]@{schema=1;input_path='artifacts/v0.2-baseline/scale-corpus/large_module.bc';input_sha256=(Hash (Join-Path $root 'artifacts/v0.2-baseline/scale-corpus/large_module.bc'));configuration_sha256=(Hash (Join-Path $root 'artifacts/performance-rc-final/annotated-validation-off.json'));command='profile_allocations --config annotated-validation-off.json --stacks large_module.bc';validation='off; reconstruction/allocation profile only';instrumentation='Counting Rust allocator with bounded sampled allocation stacks; helper overhead is included in both runs';samples_per_version=1;timing_limit='One instrumented observation per version; timing is diagnostic and is not a latency distribution';optimization='Skip constructor-use indexing when the current body has no eligible prefill declaration; clone a binding name only on first insertion into its use map';before_executable_sha256=(Hash (Join-Path $Directory 'before-luau-decompile.exe'));after_executable_sha256=(Hash (Join-Path $root 'target/release/luau-decompile.exe'));before_helper_sha256=(Hash (Join-Path $Directory 'before-profile_allocations.exe'));after_helper_sha256=(Hash (Join-Path $root 'target/release/examples/profile_allocations.exe'));before_source_manifest_sha256=(Hash (Join-Path $Directory 'source-before/source-manifest.json'));output_unchanged=$true;results=$rows;raw=@((Archive 'before'),(Archive 'after'));generator_sha256=(Hash $PSCommandPath)}
[IO.File]::WriteAllText((Join-Path $root 'docs/results/constructor-performance-rc.json'),($report | ConvertTo-Json -Depth 16),[Text.UTF8Encoding]::new($false))
Write-Output 'Recorded matched constructor allocation observations; output SHA-256 is unchanged.'
