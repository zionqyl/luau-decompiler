param([string]$Destination=(Join-Path $PSScriptRoot '../dist'),[switch]$PackageOnly,[string]$PreviousArchive,[string]$ModernPreviousArchive)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'env.ps1')
. (Join-Path $PSScriptRoot 'release-integrity.ps1')
. (Join-Path $PSScriptRoot 'runtime-package.ps1')
Push-Location $taskRoot
try{
    if(-not $PackageOnly){& (Join-Path $PSScriptRoot 'validate.ps1') -Release}
    $gate=Get-Content -LiteralPath artifacts/release-gate.json -Raw|ConvertFrom-Json
    $metadata=(& cargo metadata --offline --locked --no-deps --format-version 1|ConvertFrom-Json)
    $version=($metadata.packages|Where-Object{$_.name -ceq 'luau-decompiler'}).version
    if($gate.schema -ne 3 -or $gate.version -cne $version -or -not $gate.passed -or -not $gate.release_optimized -or $gate.oracle_protocol -cne 'LOBS/1' -or $gate.behavioral_passed -ne $gate.behavioral_cases){throw 'No matching complete optimized semantic gate; run release.ps1 without -PackageOnly'}
    $currentSources=@(Get-GateSourceFiles)
    $installerInputs=@(Get-InstallerInputFiles $currentSources)
    $semanticSources=@(Get-SemanticInputFiles $currentSources)
    Assert-SemanticSnapshot $gate.semantic_input_files $currentSources
    $tools=Get-QualityToolProvenance
    if(($tools|ConvertTo-Json -Compress) -cne ($gate.quality_tools|ConvertTo-Json -Compress)){throw 'Validation assets changed after the semantic gate'}
    foreach($tool in $gate.validation_tool_files){if((Get-FileHash -LiteralPath $tool.path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $tool.sha256){throw ('Validation tool changed: '+$tool.path)}}
    $cli=Join-Path $taskRoot 'target/release/luau-decompile.exe'
    $cliHash=(Get-FileHash -LiteralPath $cli -Algorithm SHA256).Hash.ToLowerInvariant()
    if($cliHash -cne $gate.executable_sha256){throw 'Executable differs from the validated semantic gate'}
    $workspace=Join-Path $taskRoot ('artifacts/release-'+$version+'-'+[Guid]::NewGuid().ToString('N'))
    $runtime=Join-Path $workspace 'runtime';$evidence=Join-Path $workspace 'evidence';$archives=Join-Path $workspace 'archives'
    New-Item -ItemType Directory -Path $runtime,$evidence,$archives -Force|Out-Null
    $oldHashes=@{};foreach($file in $gate.source_files){$oldHashes[$file.path]=$file.sha256}
    $currentHashes=@{};foreach($file in $currentSources){$currentHashes[$file.path]=$file.sha256}
    $documentationDelta=@(foreach($path in @(@($currentHashes.Keys)+@($oldHashes.Keys)|Sort-Object -Unique)){if($oldHashes[$path] -cne $currentHashes[$path]){[ordered]@{path=$path;previous_sha256=$oldHashes[$path];current_sha256=$currentHashes[$path]}}})
    $snapshot=[ordered]@{schema=1;version=$version;files=$currentSources;validated_semantic_inputs=$semanticSources;semantic_validation_started_utc=$gate.validation_started_utc;semantic_validation_finished_utc=$gate.validation_finished_utc;semantic_evidence_reused=[bool]$PackageOnly;documentation_changes_since_semantic_gate=$documentationDelta}
    $snapshot.non_native_changes_since_semantic_gate=$documentationDelta
    $snapshot.installer_inputs=$installerInputs
    $snapshot.installer_changes_since_native_gate=@($documentationDelta|Where-Object{$_.path -cin @('scripts/install.ps1','scripts/test-install.py')})
    $snapshot.documentation_changes_since_semantic_gate=@($documentationDelta|Where-Object{$_.path -match '\.md$'})
    $snapshot.browser_changes_since_native_gate=@($documentationDelta|Where-Object{$_.path -match '^browser-toolchain\.lock\.json$|^web/|^scripts/(build-browser\.py|test-browser\.mjs)$|^\.github/workflows/pages\.yml$'})
    $snapshotJson=$snapshot|ConvertTo-Json -Depth 8
    New-Item -ItemType Directory -Path $Destination -Force|Out-Null
    $Destination=[IO.Path]::GetFullPath($Destination)
    $sourceArchive=Join-Path $archives ('luau-decompiler-'+$version+'-source.zip')
    $sourceHash=Write-SourceZip $taskRoot $currentSources $snapshotJson $sourceArchive
    $provenance=[ordered]@{executable_sha256=$cliHash;semantic_gate_sha256=(Get-FileHash artifacts/release-gate.json -Algorithm SHA256).Hash.ToLowerInvariant();source_archive=[ordered]@{name=[IO.Path]::GetFileName($sourceArchive);sha256=$sourceHash};evidence_archive=('luau-decompiler-'+$version+'-evidence.zip');quality_tools=($tools|Select-Object analyzer_sha256,manifest_sha256,harness_sha256,upstream_revision,definitions_sha256,definitions_revision,definitions_license_sha256)}
    $null=New-RuntimePackage $taskRoot $runtime $version $cli (Join-Path $taskRoot $tools.analyzer_path) (Join-Path $taskRoot $tools.manifest_path) $provenance
    $runtimeArchive=Join-Path $archives ('luau-decompiler-'+$version+'-windows-x64.zip')
    $runtimeHash=Write-PortableZip $runtime $runtimeArchive
    $installed=Join-Path $workspace 'extracted'
    [IO.Compression.ZipFile]::ExtractToDirectory($runtimeArchive,$installed)
    $installedManifest=Get-Content -LiteralPath (Join-Path $installed 'runtime-manifest.json') -Raw|ConvertFrom-Json
    foreach($file in $installedManifest.files){$path=Join-Path $installed $file.path;if((Get-Item -LiteralPath $path).Length -ne $file.bytes -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $file.sha256){throw ('Extracted runtime integrity failed: '+$file.path)}}
    if(@(Get-ChildItem -LiteralPath $installed -Recurse -File).Count -ne $installedManifest.files.Count+1){throw 'Unexpected files in the extracted runtime'}
    $python=if($env:LUAU_PYTHON){(Resolve-Path -LiteralPath $env:LUAU_PYTHON).Path}else{(Get-Command python -ErrorAction Stop).Source}
    $work=Join-Path $workspace 'acceptance-work';New-Item -ItemType Directory -Path $work|Out-Null
    $acceptancePath=Join-Path $evidence 'runtime-acceptance.json'
    $previousPath=$env:PATH
    try{
        $env:PATH=$env:SystemRoot+'\System32;'+$env:SystemRoot
        & $python (Join-Path $taskRoot 'scripts/runtime-smoke.py') --bundle $installed --work-dir $work --compiler (Join-Path $taskRoot '.tools/luau-modern/luau-compile.exe') --oracle (Join-Path $taskRoot '.tools/luau-modern/vm-runner.exe') --report $acceptancePath
        if($LASTEXITCODE -ne 0){throw 'Final extracted runtime acceptance failed'}
    }finally{$env:PATH=$previousPath}
    $acceptance=Get-Content -LiteralPath $acceptancePath -Raw|ConvertFrom-Json
    if(-not $acceptance.passed -or $acceptance.executable_sha256 -cne $cliHash){throw 'Final runtime acceptance identity mismatch'}
    if($acceptance.harness_sha256 -cne (Get-FileHash -LiteralPath scripts/runtime-smoke.py -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Runtime acceptance harness identity mismatch'}
    $installerReportPath=Join-Path $evidence 'installer-acceptance.json'
    $installerArguments=@('--archive',$runtimeArchive,'--installer',(Join-Path $taskRoot 'scripts/install.ps1'),'--work-dir',(Join-Path $workspace 'installer-work'),'--report',$installerReportPath,'--registry-path')
    if($PreviousArchive){$installerArguments+=@('--previous-archive',(Resolve-Path -LiteralPath $PreviousArchive).Path)}
    if($ModernPreviousArchive){$installerArguments+=@('--modern-previous-archive',(Resolve-Path -LiteralPath $ModernPreviousArchive).Path)}
    & $python (Join-Path $taskRoot 'scripts/test-install.py') @installerArguments
    if($LASTEXITCODE -ne 0){
        $failureDetails='Installer harness did not retain a structured failure; inspect its traceback and partial report.'
        if(Test-Path -LiteralPath $installerReportPath){
            $partial=Get-Content -LiteralPath $installerReportPath -Raw|ConvertFrom-Json
            $lastCase=if($partial.last_completed_case){$partial.last_completed_case}else{'none'}
            $failureDetails='Last completed case: '+$lastCase
            if($partial.failure){
                $failureDetails+='; operation: '+($partial.failure.last_operation|ConvertTo-Json -Compress)+'; '+$partial.failure.exception_type+': '+$partial.failure.message+'; '+$partial.failure.traceback
            }
        }
        throw ('Final runtime installer acceptance failed. '+$failureDetails.Substring(0,[Math]::Min(12000,$failureDetails.Length))+'; partial report: '+$installerReportPath)
    }
    $installerAcceptance=Get-Content -LiteralPath $installerReportPath -Raw|ConvertFrom-Json
    if(-not $installerAcceptance.passed -or $installerAcceptance.archive_sha256 -cne $runtimeHash){throw 'Installer acceptance artifact identity mismatch'}
    $installerHashes=@{};foreach($inputFile in $installerInputs){$installerHashes[$inputFile.path]=$inputFile.sha256;if((Get-FileHash -LiteralPath $inputFile.path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $inputFile.sha256){throw ('Installer input changed during packaging: '+$inputFile.path)}}
    if($installerAcceptance.installer_sha256 -cne $installerHashes['scripts/install.ps1'] -or $installerAcceptance.harness_sha256 -cne $installerHashes['scripts/test-install.py'] -or $installerAcceptance.selection -cne 'complete installer scenarios'){throw 'Full installer acceptance does not match the packaged installer and current harness'}
    foreach($report in @($gate.validation_reports)+@($gate.measured_evidence)){
        if((Get-FileHash -LiteralPath $report.path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $report.sha256){throw ('Validated report changed: '+$report.path)}
        $path=Join-Path $evidence ('reports/'+$report.path);New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force|Out-Null;Copy-Item -LiteralPath $report.path -Destination $path
    }
    foreach($file in @(Get-ChildItem -LiteralPath docs/results -Recurse -File)){$relative=$file.FullName.Substring((Join-Path $taskRoot 'docs/results').Length+1);$path=Join-Path $evidence ('reports/docs/results/'+$relative);if(-not(Test-Path -LiteralPath $path)){New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force|Out-Null;Copy-Item -LiteralPath $file.FullName -Destination $path}}
    Copy-Item -LiteralPath artifacts/release-gate.json -Destination (Join-Path $evidence 'release-gate.json')
    [IO.File]::WriteAllText((Join-Path $evidence 'source-manifest.json'),$snapshotJson,[Text.UTF8Encoding]::new($false))
    $assessment=[ordered]@{schema=2;version=$version;status='windows_standalone_candidate_validated';executable_sha256=$cliHash;runtime_archive_sha256=$runtimeHash;source_archive_sha256=$sourceHash;semantic_gate_sha256=$provenance.semantic_gate_sha256;semantic_evidence_reused=[bool]$PackageOnly;semantic_validation_started_utc=$gate.validation_started_utc;semantic_validation_finished_utc=$gate.validation_finished_utc;extracted_runtime_acceptance=[ordered]@{passed=$acceptance.passed;harness_sha256=$acceptance.harness_sha256;report='runtime-acceptance.json';report_sha256=(Get-FileHash -LiteralPath $acceptancePath -Algorithm SHA256).Hash.ToLowerInvariant()};installer_acceptance=[ordered]@{passed=$installerAcceptance.passed;harness_sha256=$installerAcceptance.harness_sha256;report='installer-acceptance.json';report_sha256=(Get-FileHash -LiteralPath $installerReportPath -Algorithm SHA256).Hash.ToLowerInvariant()};documentation_changes_since_semantic_gate=$snapshot.documentation_changes_since_semantic_gate;browser_changes_since_native_gate=$snapshot.browser_changes_since_native_gate;platforms=[ordered]@{windows='passed_within_recorded_standalone_scope';linux='not_run';macos='not_run';mobile='not_run';container='not_run'};native_executor='Optional independent evidence retains its own observed outcomes and build/source identities; standalone acceptance does not certify live compatibility.';historical_evidence=[ordered]@{manifest='evidence/releases/0.4.0-rc.1-manifest.json';archive_sha256=(Get-Content evidence/releases/0.4.0-rc.1-manifest.json -Raw|ConvertFrom-Json).archive_sha256};limitations=@('Finite fixture/input coverage does not establish universal compatibility or absence of defects.','Strict analysis, useful annotations and behavioral observations remain independent facts.','Prebuilt release/image publication and actual Linux/container execution require their separately recorded prerequisites.')}
    $assessment.installer_inputs=$installerInputs
    $assessment.installer_changes_since_native_gate=$snapshot.installer_changes_since_native_gate
    [IO.File]::WriteAllText((Join-Path $evidence 'release-assessment.json'),($assessment|ConvertTo-Json -Depth 15),[Text.UTF8Encoding]::new($false))
    $evidenceArchive=Join-Path $archives ('luau-decompiler-'+$version+'-evidence.zip')
    $evidenceHash=Write-PortableZip $evidence $evidenceArchive
    $index=[ordered]@{schema=1;version=$version;artifacts=@([ordered]@{purpose='runtime';name=[IO.Path]::GetFileName($runtimeArchive);sha256=$runtimeHash;bytes=(Get-Item $runtimeArchive).Length},[ordered]@{purpose='source';name=[IO.Path]::GetFileName($sourceArchive);sha256=$sourceHash;bytes=(Get-Item $sourceArchive).Length},[ordered]@{purpose='evidence';name=[IO.Path]::GetFileName($evidenceArchive);sha256=$evidenceHash;bytes=(Get-Item $evidenceArchive).Length});assessment=$assessment}
    foreach($file in Get-ChildItem -LiteralPath $archives -File){if(Test-Path -LiteralPath (Join-Path $Destination $file.Name)){throw ('Refusing to replace an existing release asset: '+$file.Name)}}
    foreach($file in Get-ChildItem -LiteralPath $archives -File){Move-Item -LiteralPath $file.FullName -Destination (Join-Path $Destination $file.Name)}
    [IO.File]::WriteAllText((Join-Path $Destination ('luau-decompiler-'+$version+'-release.json')),($index|ConvertTo-Json -Depth 20),[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $taskRoot 'docs/results/release-candidate-summary-rc.json'),($assessment|ConvertTo-Json -Depth 15),[Text.UTF8Encoding]::new($false))
    Write-Output ('Validated compact runtime: '+(Join-Path $Destination ([IO.Path]::GetFileName($runtimeArchive))))
}finally{Pop-Location}
