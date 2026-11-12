
function Get-OrderedSourceFiles($Files) {
    $ordered=[Collections.Generic.SortedDictionary[string,object]]::new([StringComparer]::Ordinal)
    foreach($file in $Files){
        if(-not $file.path -or $ordered.ContainsKey([string]$file.path)){throw 'Source snapshot contains an empty or duplicate path'}
        $ordered.Add([string]$file.path,$file)
    }
    @($ordered.Values)
}

function Get-GateSourceFiles {
    $files = [System.Collections.Generic.List[object]]::new()
    foreach ($directory in @('src','tests','adapter','scripts','benchmarks','examples','definitions','fixtures','fuzz','docs','deployment','.github','evidence','licenses','web')) {
        if (-not (Test-Path -LiteralPath $directory)) { throw ('Required source directory missing: ' + $directory) }
        foreach($relative in @(& rg --files --hidden -- $directory)) {
            $relative=$relative.Replace('\','/')
            if ($relative -notmatch '(^|/)(target|artifacts|\.git)/' -and $relative -notmatch '^docs/results/') {
                $files.Add([ordered]@{path=$relative;sha256=(Get-FileHash -LiteralPath $relative -Algorithm SHA256).Hash.ToLowerInvariant()})
            }
        }
    }
    foreach ($path in @('Cargo.toml','Cargo.lock','LICENSE','README.md','API.md','upstream.lock.json','upstream.profiles.lock.json','definitions.lock.json','AGENTS.md','.gitignore','.dockerignore','.gitattributes','release.json','runtime-layout.json','browser-toolchain.lock.json')) {
        if (-not (Test-Path -LiteralPath $path)) { throw ('Required source file missing: ' + $path) }
        $files.Add([ordered]@{path=$path; sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()})
    }
    return @(Get-OrderedSourceFiles $files.ToArray())
}

function Get-SemanticInputFiles($Files) {
    @(Get-OrderedSourceFiles @($Files | Where-Object {$_.path -notmatch '\.md$' -and $_.path -cne 'browser-toolchain.lock.json' -and $_.path -notmatch '^web/' -and $_.path -notmatch '^scripts/(build-browser\.py|test-browser\.mjs)$' -and $_.path -notmatch '^\.github/workflows/pages\.yml$'}))
}

function Assert-SemanticSnapshot($Expected,$Actual) {
    $expectedOrdered=@(Get-SemanticInputFiles $Expected)
    $current=@(Get-SemanticInputFiles $Actual)
    if(-not $expectedOrdered.Count -or ($current|ConvertTo-Json -Depth 5 -Compress) -cne ($expectedOrdered|ConvertTo-Json -Depth 5 -Compress)){throw 'Relevant code, tests, fixtures or commands changed; semantic evidence cannot be reused'}
}

function Restore-HistoricalEvidence {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $manifest=Get-Content -LiteralPath (Join-Path $taskRoot 'evidence/releases/0.4.0-rc.1-manifest.json') -Raw|ConvertFrom-Json
    $archive=Join-Path $taskRoot $manifest.archive_path
    if((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -cne $manifest.archive_sha256){throw 'Required historical evidence archive hash mismatch'}
    $directory=Join-Path $taskRoot 'docs/results'
    New-Item -ItemType Directory -Path $directory -Force|Out-Null
    $zip=[IO.Compression.ZipFile]::OpenRead($archive)
    try{
        foreach($name in @('executor-catalog-v3.json','madium-live.json','madium-live-v3.json','madium-live-rc.json','native-functions-rc.json','v3-performance.json')){
            $destination=Join-Path $directory $name
            if(Test-Path -LiteralPath $destination){continue}
            $expected=@($manifest.files|Where-Object{$_.path -ceq $name})
            $entry=$zip.GetEntry($name)
            if($expected.Count -ne 1 -or -not $entry -or $entry.Length -ne $expected[0].bytes -or $entry.Length -gt 33554432){throw ('Required historical report is missing or exceeds its recorded bound: '+$name)}
            $stream=$entry.Open();$output=[IO.MemoryStream]::new()
            try{$stream.CopyTo($output);$bytes=$output.ToArray()}finally{$stream.Dispose();$output.Dispose()}
            $algorithm=[Security.Cryptography.SHA256]::Create()
            try{$hash=([BitConverter]::ToString($algorithm.ComputeHash($bytes))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
            if($hash -cne $expected[0].sha256){throw ('Required historical report hash mismatch: '+$name)}
            [IO.File]::WriteAllBytes($destination,$bytes)
            [IO.File]::SetLastWriteTimeUtc($destination,$entry.LastWriteTime.UtcDateTime)
        }
    }finally{$zip.Dispose()}
}

function Assert-RequiredIdentities($Required, $Actual, [string]$Label) {
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($identity in @($Actual)) {
        if ([string]::IsNullOrEmpty([string]$identity) -or -not $seen.Add([string]$identity)) { throw ($Label + ': missing or duplicate identity ' + $identity) }
    }
    foreach ($identity in @($Required)) {
        if (-not $seen.Contains([string]$identity)) { throw ($Label + ': required identity disappeared: ' + $identity) }
    }
}

function Get-QualityToolProvenance {
    $definitionLock = Get-Content -LiteralPath definitions.lock.json -Raw | ConvertFrom-Json
    $analyzer = '.tools/luau-quality.exe'
    $manifestPath = $analyzer + '.manifest.json'
    foreach ($path in @($analyzer,$manifestPath,$definitionLock.path,$definitionLock.license_path)) {
        if (-not (Test-Path -LiteralPath $path)) { throw ('Required analyzer/definition artifact missing: ' + $path) }
    }
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $analyzerHash = (Get-FileHash -LiteralPath $analyzer -Algorithm SHA256).Hash.ToLowerInvariant()
    $definitionHash = (Get-FileHash -LiteralPath $definitionLock.path -Algorithm SHA256).Hash.ToLowerInvariant()
    $harnessHash = (Get-FileHash -LiteralPath tests/analyzer_runner.cpp -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($manifest.protocol -ne 'LQUAL/1' -or $manifest.upstream_revision -cne $definitionLock.analyzer_revision -or $manifest.binary_sha256 -cne $analyzerHash -or $manifest.source_sha256 -cne $harnessHash -or $definitionHash -cne $definitionLock.sha256) { throw 'Analyzer/definition provenance does not match pinned source and lock.' }
    return [ordered]@{protocol='LQUAL/1';analyzer_path=$analyzer;analyzer_sha256=$analyzerHash;manifest_path=$manifestPath;manifest_sha256=(Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant();harness_sha256=$harnessHash;upstream_revision=$manifest.upstream_revision;definitions_path=$definitionLock.path;definitions_sha256=$definitionHash;definitions_revision=$definitionLock.revision;definitions_license_path=$definitionLock.license_path;definitions_license_sha256=(Get-FileHash -LiteralPath $definitionLock.license_path -Algorithm SHA256).Hash.ToLowerInvariant()}
}
