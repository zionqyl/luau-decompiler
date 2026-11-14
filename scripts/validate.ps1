param([switch]$Release)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
Push-Location $taskRoot
$packageVersion=$null
$gatePath = Join-Path $taskRoot 'artifacts/release-gate.json'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $gatePath) | Out-Null
[System.IO.File]::WriteAllText($gatePath, '{"schema":3,"passed":false,"state":"running","oracle_protocol":"LOBS/1"}', [System.Text.UTF8Encoding]::new($false))
try {
    if ($env:OS -ne 'Windows_NT' -or [IntPtr]::Size -ne 8) { throw 'This validated release workflow supports Windows x64 only. macOS/mobile validation is not run; use separate platform procedures rather than this gate.' }
    foreach ($target in @('oracle_protocol','oracle_runtime','behavior','reconstruction','profile_behavior','profiles','applications','generated_programs','scale_behavior','v3_semantics','v3_repeated_entry','types_v3_behavior','quality_v3','native_v3_model','profile_hash_layout_v3')) {
        if (-not (Test-Path -LiteralPath ('tests/' + $target + '.rs'))) { throw ('Required release-gate target is missing: ' + $target) }
    }
    foreach($target in @('source_inputs','source_behavior_rc','source_rc2','types_rc','types_rc5','types_v3','recovery_rc5','output_policy','attribution','scale_quality_rc')) {
        if(-not(Test-Path -LiteralPath ('tests/'+$target+'.rs'))){throw ('Required release-gate target is missing: '+$target)}
    }
    $manifestPath=Join-Path $taskRoot 'Cargo.toml'
    if(-not(Test-Path -LiteralPath $manifestPath -PathType Leaf)){throw 'Cargo.toml is missing; cannot identify the release version'}
    $packageVersion=([regex]::Match([IO.File]::ReadAllText($manifestPath),'(?m)^version\s*=\s*\x22([^\x22]+)\x22')).Groups[1].Value
    if($packageVersion -cnotmatch '^[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$'){throw 'Cargo.toml must declare a valid release package version'}
    . (Join-Path $PSScriptRoot 'env.ps1')
    . (Join-Path $PSScriptRoot 'release-integrity.ps1')
    Restore-HistoricalEvidence
    & (Join-Path $PSScriptRoot 'setup-profiles.ps1') -BuildOracle
    & (Join-Path $PSScriptRoot 'build-analyzer.ps1')
    & cargo build --release --offline --locked --bin luau-decompile
    if($LASTEXITCODE -ne 0){throw 'Release executable preparation failed.'}
    & (Join-Path $PSScriptRoot 'generate-examples-rc.ps1') -Binary (Join-Path $taskRoot 'target/release/luau-decompile.exe')
    $sourceFilesBefore = @(Get-GateSourceFiles)
    $sourceFingerprintBefore = @(Get-SemanticInputFiles $sourceFilesBefore) | ConvertTo-Json -Depth 5 -Compress
    [IO.File]::WriteAllText((Join-Path $taskRoot 'artifacts/release-sources-before.json'),($sourceFilesBefore|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
    $qualityToolsBefore = Get-QualityToolProvenance
    $validationStartedUtc = [DateTime]::UtcNow
    $catalogSnapshotSha256 = (Get-FileHash -LiteralPath docs/results/executor-catalog-v3.json -Algorithm SHA256).Hash.ToLowerInvariant()
    $liveObservationSha256 = (Get-FileHash -LiteralPath docs/results/madium-live-v3.json -Algorithm SHA256).Hash.ToLowerInvariant()
    $candidateRequirements=Get-Content -LiteralPath tests/release-requirements-rc.json -Raw|ConvertFrom-Json
    foreach($path in $candidateRequirements.measured_evidence_reports){if($path -cnotmatch '^docs/results/[a-z0-9-]+\.json$'){throw ('Candidate measured evidence must be a repository report path: '+$path)}}
    $candidateMeasuredBefore=@(foreach($path in $candidateRequirements.measured_evidence_reports){
        if(Test-Path -LiteralPath $path){
            [ordered]@{path=$path;sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant();observed_file_mtime_utc=(Get-Item -LiteralPath $path).LastWriteTimeUtc.ToString('o');scope='Retained independent candidate/platform/comparison measurement. Outcome and executable identities inside the report remain authoritative; not rerun or retimestamped by the offline validation gate.'}
        }
    })
    & (Join-Path $PSScriptRoot 'test-release-integrity.ps1')
    & cargo fmt --all -- --check
    if($LASTEXITCODE -ne 0){throw 'Formatting failed.'}
    & cargo clippy --offline --locked --all-targets -- -D warnings
    if($LASTEXITCODE -ne 0){throw 'Clippy failed.'}
    & (Join-Path $PSScriptRoot 'check-code-style.ps1')
    & (Join-Path $PSScriptRoot 'test-analyzer.ps1')
    $runner = Join-Path $taskRoot '.tools/vm-runner.exe'
    $runnerManifest = $runner + '.manifest.json'
    $harnessHash = (Get-FileHash -LiteralPath tests/vm_runner.cpp -Algorithm SHA256).Hash.ToLowerInvariant()
    $fresh = $false
    if ((Test-Path -LiteralPath $runner) -and (Test-Path -LiteralPath $runnerManifest)) {
        $stamp = Get-Content -LiteralPath $runnerManifest -Raw | ConvertFrom-Json
        $fresh = $stamp.protocol -eq 'LOBS/1' -and $stamp.harness_sha256 -eq $harnessHash -and $stamp.runner_sha256 -eq (Get-FileHash -LiteralPath $runner -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    if (-not $fresh) { & (Join-Path $PSScriptRoot 'build-vm.ps1') }
    if ((& $runner --protocol-version) -ne 'LOBS/1 LARG/1') { throw 'Typed behavioral oracle is unavailable.' }
    $env:LUAU_VM_RUNNER = $runner
    $cargoOptions = @('--offline', '--locked')
    if ($Release) { $cargoOptions += '--release' }
    & cargo test @cargoOptions --all-targets
    if ($LASTEXITCODE -ne 0) { throw 'Rust tests failed.' }
    $requiredTestInventory=@(foreach($target in $candidateRequirements.required_test_identities.PSObject.Properties){
        [string[]]$targetArguments=if($target.Name -ceq 'lib'){@('--lib')}else{@('--test',$target.Name)}
        $listed=@(& cargo test @cargoOptions @targetArguments -- --list)
        if($LASTEXITCODE -ne 0){throw ('Cannot list required candidate tests: '+$target.Name)}
        foreach($identity in $target.Value){if(($identity+': test') -cnotin $listed){throw ('Required candidate test is missing: '+$target.Name+'::'+$identity)}}
        [ordered]@{target=$target.Name;required=@($target.Value);identities_present=$true}
    })
    $requiredInventoryPath=Join-Path $taskRoot 'artifacts/rc5-required-tests.json'
    [IO.File]::WriteAllText($requiredInventoryPath,([ordered]@{schema=1;version=$packageVersion;passed=$true;scope='Required test identity presence only; ordinary and ignored execution is owned by this validation driver.';targets=$requiredTestInventory}|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
    & cargo test @cargoOptions --test oracle_runtime -- --ignored --nocapture
    if ($LASTEXITCODE -ne 0) { throw 'Actual-VM oracle negative/conformance tests failed.' }
    & cargo test @cargoOptions --test behavior -- --ignored --nocapture
    if ($LASTEXITCODE -ne 0) { throw 'Typed behavioral validation failed or reconstruction/observation was incomplete.' }
    if (Test-Path -LiteralPath tests/reconstruction.rs) {
        & cargo test @cargoOptions --test reconstruction -- --ignored --nocapture
        if ($LASTEXITCODE -ne 0) { throw 'Binding/dispatcher differential validation failed.' }
    }
    if (Test-Path -LiteralPath tests/profile_behavior.rs) {
        & cargo test @cargoOptions --test profile_behavior -- --ignored --nocapture
        if ($LASTEXITCODE -ne 0) { throw 'Version-specific typed compatibility validation failed.' }
        & cargo test @cargoOptions --test profiles native_probe_matches_independent_compiler_model -- --ignored --nocapture
        if ($LASTEXITCODE -ne 0) { throw 'Captured native opcode model validation failed.' }
    }
    foreach ($target in @('applications','generated_programs')) {
        if (Test-Path -LiteralPath ('tests/' + $target + '.rs')) {
            if ($target -eq 'generated_programs') {



                & cargo test @cargoOptions --test $target generated_valid_programs_behavior -- --ignored --nocapture
                if ($LASTEXITCODE -ne 0) { throw 'Preserved generated-program behavioral matrix failed.' }
                & cargo test @cargoOptions --test $target orthogonal_compositional_and_stateful_programs_behavior -- --ignored --nocapture
            } else {
                & cargo test @cargoOptions --test $target -- --ignored --nocapture
            }
            if ($LASTEXITCODE -ne 0) { throw ('Known-source/generated typed behavior gate failed: ' + $target) }
        }
    }
    foreach ($target in @('v3_semantics','v3_repeated_entry','types_v3_behavior','quality_v3','native_v3_model','profile_hash_layout_v3')) {
        & cargo test @cargoOptions --test $target -- --ignored --nocapture
        if ($LASTEXITCODE -ne 0) { throw ('Mandatory v0.3 semantic/typing/quality target failed: ' + $target) }
    }
    foreach($target in @('source_inputs','source_behavior_rc','source_rc2','types_rc','types_rc5','types_v3','recovery_rc5','output_policy','attribution')) {
        & cargo test @cargoOptions --test $target -- --ignored --nocapture
        if($LASTEXITCODE -ne 0){throw ('Mandatory candidate input/typing regression failed: '+$target)}
    }
    & (Join-Path $taskRoot 'benchmarks/generate-scale.ps1')
    & cargo test @cargoOptions --test scale_behavior -- --ignored --nocapture
    if ($LASTEXITCODE -ne 0) { throw 'Large-module/large-function typed behavior gate failed.' }
    & cargo test @cargoOptions --test scale_quality_rc -- --ignored --nocapture
    if($LASTEXITCODE -ne 0){throw 'Large-module verified typing with explicit contracts failed.'}
    & $env:LUAU_RUN adapter/test.luau
    if ($LASTEXITCODE -ne 0) { throw 'Adapter mock tests failed.' }
    & $env:LUAU_RUN adapter/live-test-conformance.luau
    if ($LASTEXITCODE -ne 0) { throw 'Live-observer conformance failed.' }
    & $env:LUAU_RUN adapter/test-v3.luau
    if ($LASTEXITCODE -ne 0) { throw 'Target-aware adapter/options/quality contract failed.' }
    & $env:LUAU_RUN adapter/test-rc.luau
    if($LASTEXITCODE -ne 0){throw 'Candidate adapter option/cancellation/policy boundary failed.'}
    $capturePython=if($env:LUAU_PYTHON){$env:LUAU_PYTHON}elseif(Test-Path -LiteralPath '.tools/python-3.12.10/python.exe'){(Resolve-Path -LiteralPath '.tools/python-3.12.10/python.exe').Path}else{(Get-Command python -ErrorAction Stop).Source}
    & $capturePython scripts/test-client-capture.py
    if($LASTEXITCODE -ne 0){throw 'Private client collector binary/path/resource contract failed.'}
    & (Join-Path $PSScriptRoot 'build-executor-compatibility-v3.ps1') -AdapterMocksVerified -MockRunner $env:LUAU_RUN
    & (Join-Path $PSScriptRoot 'verify-native-fixtures.ps1')
    & (Join-Path $PSScriptRoot 'test-catalog-refresh.ps1')
    & (Join-Path $PSScriptRoot 'build-coverage-runtime.ps1') -Offline
    & (Join-Path $PSScriptRoot 'fuzz-coverage.ps1') -Iterations 500 -MaxSeconds 240
    & (Join-Path $PSScriptRoot 'verify-release-evidence-v3.ps1') -NotBefore $validationStartedUtc
    & (Join-Path $PSScriptRoot 'verify-release-evidence-rc.ps1') -NotBefore $validationStartedUtc
    & (Join-Path $PSScriptRoot 'test-evidence-provenance-rc.ps1')
    $behavior = Get-Content -LiteralPath artifacts/validation/report.json -Raw | ConvertFrom-Json
    if ($behavior.oracle_protocol -ne 'LOBS/1' -or $behavior.cases -eq 0 -or $behavior.passed -ne $behavior.cases) { throw 'Typed behavioral report is incomplete; release is forbidden.' }
    $reportPaths = @('artifacts/oracle-conformance/report.json','artifacts/analyzer-conformance/report.json','artifacts/validation/report.json','artifacts/reconstruction/report.json','artifacts/features/report.json','artifacts/scope-captures/report.json','docs/results/profile-behavior.json','docs/results/profile-hash-layout-v3.json','docs/results/native-probe-model.json','docs/results/native-v3-model.json','docs/results/applications.json','docs/results/generated-programs.json','docs/results/generated-programs-v3.json','docs/results/v3-protected-calls.json','docs/results/v3-structural-semantics.json','docs/results/v3-repeated-entry.json','docs/results/types-v3-behavior.json','docs/results/types-v3-quality.json','docs/results/strict-v3.json','docs/results/service-v3.json','docs/results/catalog-http-v3.json','docs/results/executor-compatibility-v3.json','docs/results/native-place-v3-preparation.json','docs/results/release-integrity-v3.json','docs/results/coverage-guided-v3.json','docs/results/scale-behavior.json')
    $reports = [System.Collections.Generic.List[object]]::new()
    $reportPaths += @('docs/results/source-input-rc.json','docs/results/types-rc-snapshot.json','docs/results/types-rc-function-entry.json','docs/results/types-rc-behavior.json','docs/results/scale-quality-rc.json','docs/results/types-rc-contracts.json')
    $reportPaths += @('artifacts/external-evidence-rc/provenance.json','artifacts/evidence-provenance-focused-results.json')
    $reportPaths += @('artifacts/attribution-rc3/report.json','artifacts/rc3-reliability/source-signatures/report.json','artifacts/rc3-reliability/scalar-loop/report.json')
    $reportPaths += @('artifacts/source-rc2/report.json','artifacts/source-rc2-generated/report.json','artifacts/source-rc2-types/report.json','artifacts/rc2-types/report.json')
    $reportPaths += @('artifacts/rc4-core/captures/report.json','artifacts/rc4-core/verified-packet/report.json')
    $reportPaths += @('artifacts/rc4-core/open-captures/report.json','artifacts/rc4-core/fresh-closures/report.json')
    $reportPaths += @('artifacts/rc4-core/nested-cfg/report.json','artifacts/rc4-core/block-separators/report.json')
    $reportPaths += @('artifacts/rc4-core/import-padding/report.json')
    $reportPaths += @('artifacts/rc5-required-tests.json')
    foreach ($reportPath in $reportPaths) {
        if (-not (Test-Path -LiteralPath $reportPath) -or (Get-Item -LiteralPath $reportPath).LastWriteTimeUtc -lt $validationStartedUtc) { throw ('Required validation evidence is missing or stale: ' + $reportPath) }
        $evidence = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        switch ($reportPath) {
            'artifacts/oracle-conformance/report.json' {
                if ($evidence.oracle_protocol -ne 'LOBS/1' -or $evidence.negative_collision_pairs -lt 12 -or $evidence.negative_pairs_passed -ne $evidence.negative_collision_pairs -or -not $evidence.empty_inputs_and_probes_are_rejected) {throw 'Oracle conformance evidence is incomplete.'}
            }
            'artifacts/reconstruction/report.json' {
                if ($evidence.oracle -ne 'LOBS/1' -or -not $evidence.complete -or $evidence.sources -lt 6 -or $evidence.typed_comparisons -lt 288) {throw 'Dispatcher/binding evidence is incomplete.'}
            }
            'artifacts/features/report.json' {
                if ($evidence.oracle -ne 'LOBS/1' -or -not $evidence.complete -or $evidence.sources -lt 6 -or $evidence.typed_comparisons -lt 216) {throw 'Reconstruction feature evidence is incomplete.'}
            }
            'artifacts/scope-captures/report.json' {
                if ($evidence.oracle -ne 'LOBS/1' -or -not $evidence.complete -or $evidence.capturing_functions -lt 256 -or $evidence.typed_comparisons -lt 8) {throw 'Large closure-scope evidence is incomplete.'}
            }
            'docs/results/profile-behavior.json' {
                if ($evidence.oracle_protocol -ne 'LOBS/1' -or $evidence.fixtures -lt 1872 -or $evidence.verified -ne $evidence.fixtures -or $evidence.failures.Count -ne 0) {throw 'Version-profile evidence is incomplete.'}
            }
            'docs/results/native-probe-model.json' {
                if ($evidence.cases.Count -eq 0 -or $evidence.semantic_matches -ne $evidence.cases.Count) {throw 'Native opcode semantic-model evidence is incomplete.'}
            }
            'docs/results/applications.json' {
                if ($evidence.oracle_protocol -ne 'LOBS/1' -or $evidence.compiled_cases -le 0 -or $evidence.failed_cases -ne 0 -or $evidence.typed_comparisons -le 0) {throw 'Application evidence is incomplete.'}
            }
            'docs/results/generated-programs.json' {
                if ($evidence.oracle_protocol -ne 'LOBS/1' -or $evidence.compiled_cases -le 0 -or $evidence.failed_cases -ne 0 -or $evidence.typed_comparisons -le 0) {throw 'Generated-program evidence is incomplete.'}
            }
            'docs/results/scale-behavior.json' {
                if ($evidence.oracle_protocol -ne 'LOBS/1' -or $evidence.input_count -ne 2 -or $evidence.failures.Count -ne 0 -or $evidence.typed_comparisons -ne 8 -or @($evidence.results | Where-Object {-not $_.verified}).Count -ne 0) {throw 'Large scale-program evidence is incomplete.'}
            }
        }
        $reports.Add([ordered]@{path=$reportPath; sha256=(Get-FileHash -LiteralPath $reportPath -Algorithm SHA256).Hash.ToLowerInvariant()})
    }
    if ((Get-FileHash -LiteralPath docs/results/executor-catalog-v3.json -Algorithm SHA256).Hash.ToLowerInvariant() -cne $catalogSnapshotSha256) { throw 'Observed catalog snapshot changed during validation.' }
    $reports.Add([ordered]@{path='docs/results/executor-catalog-v3.json';sha256=$catalogSnapshotSha256;freshness='Retained observed HTTP snapshot; observation date is recorded inside the catalog, not reset by this gate.'})
    if((Get-FileHash -LiteralPath docs/results/madium-live-v3.json -Algorithm SHA256).Hash.ToLowerInvariant() -cne $liveObservationSha256){throw 'Recorded external live failure changed during the offline release gate.'}
    $measuredEvidence=@([ordered]@{path='docs/results/madium-live-v3.json';sha256=$liveObservationSha256;scope='Retained actual failed external transport attempt; zero verified behavioral pairs. Not rerun or retimestamped by offline release validation.'})
    $candidateMeasuredAfter=@(foreach($path in $candidateRequirements.measured_evidence_reports){
        if(Test-Path -LiteralPath $path){
            [ordered]@{path=$path;sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant();observed_file_mtime_utc=(Get-Item -LiteralPath $path).LastWriteTimeUtc.ToString('o');scope='Retained independent candidate/platform/comparison measurement. Outcome and executable identities inside the report remain authoritative; not rerun or retimestamped by the offline validation gate.'}
        }
    })
    if(($candidateMeasuredBefore|ConvertTo-Json -Depth 6 -Compress) -cne ($candidateMeasuredAfter|ConvertTo-Json -Depth 6 -Compress)){throw 'Independent candidate measurement reports changed during validation.'}
    $measuredEvidence+=@($candidateMeasuredAfter)
    $sourceFilesAfter = @(Get-GateSourceFiles)
    [IO.File]::WriteAllText((Join-Path $taskRoot 'artifacts/release-sources-after.json'),($sourceFilesAfter|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
    if ((@(Get-SemanticInputFiles $sourceFilesAfter) | ConvertTo-Json -Depth 5 -Compress) -cne $sourceFingerprintBefore) {
        $before=[Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
        $after=[Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
        foreach($file in @(Get-SemanticInputFiles $sourceFilesBefore)){$before.Add($file.path,$file.sha256)}
        foreach($file in @(Get-SemanticInputFiles $sourceFilesAfter)){$after.Add($file.path,$file.sha256)}
        $paths=[Collections.Generic.SortedSet[string]]::new([StringComparer]::Ordinal)
        foreach($path in @($before.Keys)+@($after.Keys)){$null=$paths.Add($path)}
        $difference=@(foreach($path in $paths){if($before[$path] -cne $after[$path]){[ordered]@{path=$path;before_sha256=$before[$path];after_sha256=$after[$path]}}})
        [IO.File]::WriteAllText((Join-Path $taskRoot 'artifacts/release-source-difference.json'),($difference|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
        throw 'Native engine, tests, fixtures or validation commands changed during validation; see artifacts/release-source-difference.json. No mixed semantic snapshot is permitted.'
    }
    $qualityToolsAfter = Get-QualityToolProvenance
    if (($qualityToolsAfter | ConvertTo-Json -Compress) -cne ($qualityToolsBefore | ConvertTo-Json -Compress)) { throw 'Analyzer or definitions changed during validation.' }
    $toolFiles = [Collections.Generic.List[object]]::new()
    foreach ($path in @('.tools/luau/luau-compile.exe','.tools/luau-modern/luau-compile.exe','.tools/luau-0.726/luau-compile.exe','.tools/luau-0.730/luau-compile.exe','.tools/vm-runner.exe','.tools/luau-modern/vm-runner.exe','.tools/luau-0.726/vm-runner.exe','.tools/luau-0.730/vm-runner.exe')) {
        if (-not (Test-Path -LiteralPath $path)) { throw ('Pinned validation tool missing: ' + $path) }
        $toolFiles.Add([ordered]@{path=$path;sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()})
    }
    $gate = [ordered]@{schema=3;version=$packageVersion;passed=$true;release_optimized=[bool]$Release;validation_started_utc=$validationStartedUtc.ToString('o');validation_finished_utc=[DateTime]::UtcNow.ToString('o');oracle_protocol='LOBS/1';behavioral_cases=$behavior.cases;behavioral_passed=$behavior.passed;behavior_report_sha256=(Get-FileHash -LiteralPath artifacts/validation/report.json -Algorithm SHA256).Hash.ToLowerInvariant();oracle_sha256=(Get-FileHash -LiteralPath $runner -Algorithm SHA256).Hash.ToLowerInvariant();requirements_manifest_sha256=(Get-FileHash -LiteralPath tests/release-requirements-v3.json -Algorithm SHA256).Hash.ToLowerInvariant();quality_tools=$qualityToolsAfter;validation_tool_files=$toolFiles.ToArray();validation_reports=@($reports.ToArray());measured_evidence=$measuredEvidence;source_files=$sourceFilesAfter;native_controlled_place='not_run; fixture preparation is independently reported';macos='not_run; user confirmed no Mac runner';mobile='not_run; no same-device or paired encrypted transport validation';integrity_note='SHA-256 freshness/integrity record, not a cryptographic identity signature.'}
    $gate.candidate_requirements_manifest_sha256=(Get-FileHash -LiteralPath tests/release-requirements-rc.json -Algorithm SHA256).Hash.ToLowerInvariant()
    $gate.semantic_input_files=@(Get-SemanticInputFiles $sourceFilesAfter)
    $gate.browser_validation='Separate static-export gate; native success does not certify browser assets or frontend source.'
    $gate.validation_ownership='One ordinary all-targets run; required ignored suites selected separately; runtime package acceptance belongs to the extracted artifact boundary.'
    $gate.examples_manifest_sha256=(Get-FileHash -LiteralPath $candidateRequirements.example_manifest -Algorithm SHA256).Hash.ToLowerInvariant()
    $gate.examples_executable_sha256=(Get-Content -LiteralPath $candidateRequirements.example_manifest -Raw|ConvertFrom-Json).executable_sha256
    $gate.executable_sha256=(Get-FileHash -LiteralPath target/release/luau-decompile.exe -Algorithm SHA256).Hash.ToLowerInvariant()
    [System.IO.File]::WriteAllText($gatePath, ($gate | ConvertTo-Json -Depth 8), [System.Text.UTF8Encoding]::new($false))
    Write-Output ('Typed mandatory validation gate passed: ' + $behavior.passed + '/' + $behavior.cases)
} catch {
    $failure = [ordered]@{schema=3;version=$packageVersion;passed=$false;state='failed';oracle_protocol='LOBS/1';error=$_.Exception.Message}
    [System.IO.File]::WriteAllText($gatePath, ($failure | ConvertTo-Json), [System.Text.UTF8Encoding]::new($false))
    throw
} finally { Pop-Location }
