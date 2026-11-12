
param([DateTime]$NotBefore = [DateTime]::MinValue)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'release-integrity.ps1')
$requirements = Get-Content -LiteralPath tests/release-requirements-v3.json -Raw | ConvertFrom-Json
if ($requirements.version -ne '0.3.0' -or $requirements.schema -ne 1) { throw 'Unexpected v0.3 release requirements manifest.' }
function Evidence([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path) -or (Get-Item -LiteralPath $Path).LastWriteTimeUtc -lt $NotBefore) { throw ('Required evidence missing or stale: ' + $Path) }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}
function Typed($Report, [string]$Label, [int]$Minimum) {
    if ($Report.oracle_protocol -ne 'LOBS/1' -or $Report.typed_comparisons -lt $Minimum -or $Report.failed_cases -gt 0 -or $Report.failures.Count -gt 0 -or @($Report.results | Where-Object {$_.verified -eq $false}).Count -gt 0) { throw ($Label + ': incomplete or failed typed evidence.') }
}
function Assert-HistoricalLiveSources($Report,[string]$EvidenceRoot=$taskRoot) {
    $manifestPath=Join-Path $EvidenceRoot 'fixtures/historical/v0.3/manifest.json'
    if((Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne '54d742a0369c7890afa1f3f4d5633135c231b448073f2309a52ea0dc355a9d35'){throw 'Historical v0.3 source manifest identity changed.'}
    $manifest=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json
    if($manifest.schema -ne 1 -or $manifest.version -cne '0.3.0' -or $manifest.archive.sha256 -cne '2878c8040c14d1187f6aed0335bbbad8ee173c4317e709f84e364e017b027a0f' -or $manifest.report.path -cne 'docs/results/madium-live-v3.json' -or $manifest.sources.Count -ne 2){throw 'Historical v0.3 archive provenance is incomplete.'}
    $reportText=[IO.File]::ReadAllText((Join-Path $EvidenceRoot $manifest.report.path),[Text.UTF8Encoding]::new($false,$true)).Replace("`r`n","`n")
    $algorithm=[Security.Cryptography.SHA256]::Create()
    try{$normalizedHash=([BitConverter]::ToString($algorithm.ComputeHash([Text.Encoding]::UTF8.GetBytes($reportText)))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
    if($normalizedHash -cne $manifest.report.normalized_lf_sha256){throw 'Immutable historical live report changed beyond Git line-ending normalization.'}
    Assert-RequiredIdentities @('adapter','harness') $manifest.sources.id 'Historical live source identities'
    foreach($source in @($manifest.sources)+@($manifest.report.archive_file)){
        $expectedPath=if($source.id -ceq 'adapter'){'adapter/decompile.luau'}elseif($source.id -ceq 'harness'){'adapter/live-test-v3.luau'}else{$manifest.report.path}
        $observedHash=if($source.id -ceq 'adapter'){$Report.full_harness_attempt.fixture_plan.adapter_sha256}elseif($source.id -ceq 'harness'){$Report.full_harness_attempt.fixture_plan.harness_sha256}else{$manifest.report.sha256}
        $compressedName=if($source.id -ceq 'report'){'report.gz'}else{[IO.Path]::GetFileName($expectedPath)+'.gz'}
        if($source.original_path -cne $expectedPath -or $source.compressed_path -cne ('fixtures/historical/v0.3/'+$compressedName) -or $source.uncompressed_bytes -le 0 -or $source.uncompressed_bytes -gt 1048576 -or $observedHash -cne $source.source_sha256){throw 'Historical live source observation does not match its archive.'}
        $compressedPath=Join-Path $EvidenceRoot $source.compressed_path
        if((Get-FileHash -LiteralPath $compressedPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $source.compressed_sha256){throw 'Historical live compressed source identity changed.'}
        $input=[IO.File]::OpenRead($compressedPath);$gzip=[IO.Compression.GZipStream]::new($input,[IO.Compression.CompressionMode]::Decompress);$output=[IO.MemoryStream]::new()
        try{
            $buffer=New-Object byte[] 8192
            while(($count=$gzip.Read($buffer,0,$buffer.Length)) -gt 0){if($output.Length+$count -gt $source.uncompressed_bytes){throw 'Historical source decompression exceeded its recorded bound.'};$output.Write($buffer,0,$count)}
            $algorithm=[Security.Cryptography.SHA256]::Create()
            try{$actual=([BitConverter]::ToString($algorithm.ComputeHash($output.ToArray()))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
            if($output.Length -ne $source.uncompressed_bytes -or $actual -cne $source.source_sha256){throw 'Historical live source bytes changed.'}
        }finally{$output.Dispose();$gzip.Dispose();$input.Dispose()}
    }
}
$baseline = Get-Content -LiteralPath tests/fixtures/manifest.json -Raw | ConvertFrom-Json
$modern = Get-Content -LiteralPath tests/profile-fixtures/manifest.json -Raw | ConvertFrom-Json
Assert-RequiredIdentities $requirements.baseline_source_catalog @($baseline.fixtures.source | Sort-Object -Unique) 'Baseline source catalog'
Assert-RequiredIdentities $requirements.modern_source_catalog @($modern.fixtures.source | Sort-Object -Unique) 'Modern source catalog'
$general = Evidence 'artifacts/validation/report.json'
if ($general.oracle_protocol -ne 'LOBS/1' -or $general.cases -lt $requirements.required_general_comparisons -or $general.passed -ne $general.cases -or @($general.results | Where-Object {$_.status -ne 'passed'}).Count -gt 0) { throw 'General typed matrix is incomplete.' }
Assert-RequiredIdentities $requirements.required_general_case_ids $general.results.case 'General behavioral case IDs'
$profiles = Evidence 'docs/results/profile-behavior.json'
if ($profiles.oracle_protocol -ne 'LOBS/1' -or $profiles.fixtures -lt $requirements.required_modern_comparisons -or $profiles.verified -ne $profiles.fixtures -or $profiles.failures.Count -gt 0 -or @($profiles.results | Where-Object {-not $_.verified}).Count -gt 0) { throw 'Version-specific matrix is incomplete.' }
Assert-RequiredIdentities $modern.fixtures.bytecode $profiles.results.fixture 'Modern fixture IDs'
& (Join-Path $PSScriptRoot 'verify-profile-hash-layout-v3.ps1') -NotBefore $NotBefore
$applications = Evidence 'docs/results/applications.json'
Typed $applications 'Application modules' $requirements.required_applications_comparisons
Assert-RequiredIdentities @('queue','signal','store','lru_cache') @($applications.results.module | Sort-Object -Unique) 'Application modules'
$applicationIds = foreach ($name in @('queue','signal','store','lru_cache')) { foreach ($profile in @('luau-v6','luau-v14')) { foreach ($o in @(0,1,2)) { foreach ($d in @(0,2)) { foreach ($mode in @('combined_program','standalone_module')) { '{0}/{1}/O{2}D{3}/{4}' -f $name,$profile,$o,$d,$mode } } } } }
$actualApplicationIds = @($applications.results | ForEach-Object {'{0}/{1}/O{2}D{3}/{4}' -f $_.module,$_.evidence.profile,$_.evidence.optimization,$_.evidence.debug,$_.mode})
Assert-RequiredIdentities $applicationIds $actualApplicationIds 'Application case IDs'
$old = Evidence 'docs/results/generated-programs.json'
Typed $old 'Preserved generated source catalog' $requirements.required_old_generated_comparisons
if ($old.program_count -lt $requirements.required_old_generated_programs -or $old.compiled_cases -lt $requirements.required_old_generated_compiled_cases -or -not $old.legacy_source_identities_preserved -or -not $old.debug_independent_of_source_family_and_seed) { throw 'Preserved generated matrix shrank or coupled debug settings to source selection.' }
Assert-RequiredIdentities $requirements.required_old_generated_case_ids $old.results.case_id 'Preserved generated case IDs'
$goldenPath='tests/support/legacy-v2-source-hashes.json'
$golden=Get-Content -LiteralPath $goldenPath -Raw|ConvertFrom-Json
$legacyEvidence=$old.legacy_source_preservation_evidence
if($golden.schema -ne 1 -or $golden.baseline_version -ne '0.2.0' -or $golden.source_count -ne 128 -or $golden.sources.Count -ne 128 -or $golden.baseline_archive_sha256 -cne 'cff3e8d5572824db99078c2f1ff7e5be7dcbd29001ed287bfc5e4cb8c3a21030' -or $golden.archived_reports.Count -ne 2 -or @($golden.archived_reports|Where-Object {$_.sha256 -cne '61d7d34b1eff7fc5801886d7745228da8ad1cbf7770c47e2f4c10005a3b9f785'}).Count -ne 0){throw 'Independent archived v0.2 source-hash provenance is incomplete.'}
if(-not $legacyEvidence.preserved -or $legacyEvidence.expected_sources -ne 128 -or $legacyEvidence.matched_sources -ne 128 -or $legacyEvidence.golden_catalog_sha256 -cne (Get-FileHash -LiteralPath $goldenPath -Algorithm SHA256).Hash.ToLowerInvariant() -or $legacyEvidence.baseline_archive_sha256 -cne $golden.baseline_archive_sha256){throw 'Generated corpus lacks computed128-source preservation evidence against the independent v0.2 golden catalog.'}
Assert-RequiredIdentities (0..127) $golden.sources.index 'Archived source seed identities'
$goldenBySeed=@{}
foreach($source in $golden.sources){$goldenBySeed[[string]$source.index]=$source.source_sha256}
foreach($row in $old.results){$seed=[string]$row.generator_seed;if(-not $goldenBySeed.ContainsKey($seed) -or $row.source_sha256 -cne $goldenBySeed[$seed]){throw ('Generated source changed from its actual archived v0.2 identity: '+$row.case_id)}}
$generated = Evidence 'docs/results/generated-programs-v3.json'
Typed $generated 'Orthogonal compositional generation' $requirements.required_new_generated_comparisons
if (-not $generated.complete -or $generated.stateful_sequence_observations -lt 144 -or $generated.calls_per_loaded_closure_sequence -lt 3) { throw 'Stateful compositional observations are incomplete.' }
Assert-RequiredIdentities $requirements.required_new_generated_source_ids @($generated.results.source_id | Sort-Object -Unique) 'Compositional source IDs'
Assert-RequiredIdentities $requirements.required_new_generated_case_ids $generated.results.case_id 'Compositional case IDs'
foreach ($kind in @('protected','structural')) {
    $path = if ($kind -eq 'protected') {'docs/results/v3-protected-calls.json'} else {'docs/results/v3-structural-semantics.json'}
    $report = Evidence $path
    $families = if ($kind -eq 'protected') {$requirements.required_protected_families} else {$requirements.required_structural_families}
    $minimum = if ($kind -eq 'protected') {$requirements.required_protected_comparisons} else {$requirements.required_structural_comparisons}
    Typed $report $kind $minimum
    if (-not $report.complete) { throw ($kind + ': reconstruction incomplete.') }
    Assert-RequiredIdentities $families @($report.results.case | Sort-Object -Unique) ($kind + ' feature families')
    foreach ($row in $report.results) {
        $hasTarget = if ($kind -eq 'protected') {@($row.target_instructions).Count -gt 0} else {$row.target_instructions -gt 0}
        if (-not $hasTarget) { throw ($kind + ': feature fixture lacks its target instruction.') }
    }
    $expectedIds = foreach ($family in $families) { foreach ($o in $(if ($kind -eq 'protected') {@(1,2)} else {@(0,1,2)})) { foreach ($d in @(0,2)) { foreach ($mode in $(if ($kind -eq 'structural' -and $family -eq 'hybrid_native_loops') {@('Auto','Dispatcher')} else {@('Auto')})) { '{0}/O{1}D{2}/{3}' -f $family,$o,$d,$mode } } } }
    $actualIds = @($report.results | ForEach-Object {'{0}/O{1}D{2}/{3}' -f $_.case,$_.optimization,$_.debug,$(if ($kind -eq 'protected') {'Auto'} else {$_.mode})})
    Assert-RequiredIdentities $expectedIds $actualIds ($kind + ' compiler/mode case IDs')
}
$types = Evidence 'docs/results/types-v3-behavior.json'
$repeated = Evidence 'docs/results/v3-repeated-entry.json'
Assert-RequiredIdentities $requirements.required_repeated_entry_case_ids $repeated.results.case_id 'Repeated loaded-entry case IDs'
Assert-RequiredIdentities $requirements.required_repeated_entry_families $repeated.required_families 'Repeated loaded-entry families'
if ($repeated.oracle_protocol -ne 'LOBS/1' -or $repeated.all_cases_verified -ne $false -or $repeated.cases -ne 32 -or $repeated.verified_supported_cases -ne $requirements.required_repeated_entry_verified -or $repeated.explicitly_unsupported_cases -ne $requirements.required_repeated_entry_unsupported -or $repeated.unexpected_mismatches.Count -ne 0) { throw 'Repeated-entry outcomes do not preserve the supported/unsupported boundary.' }
foreach ($row in $repeated.results) {
    if ($row.status -eq 'unsupported_repeated_entry') {
        if ($row.verified -or $row.strict_rejection.stage -ne 'structure' -or $null -eq $row.strict_rejection.proto -or $null -eq $row.strict_rejection.pc -or $row.single_scope_repeated_observation_matches -ne $false -or $row.target_duplicate_instructions -le 0) { throw ('Unsupported repeated-entry sharing was hidden: ' + $row.case_id) }
    } elseif ($row.status -ne 'verified_under_explicit_compiler_contract' -or -not $row.verified -or $row.entry_invocations -ne 2 -or -not $row.observations.complete -or -not $row.actual.complete) { throw ('Repeated-entry supported observation is incomplete: ' + $row.case_id) }
}
Typed $types 'Typed presentation semantics' $requirements.required_type_comparisons
if ($types.compiled_cases -lt $requirements.required_type_compiled_cases) { throw 'Typed presentation matrix shrank.' }
Assert-RequiredIdentities $requirements.required_type_families @($types.results.family | Sort-Object -Unique) 'Type families'
$typeCases = foreach ($family in $requirements.required_type_families) { foreach ($version in @(6,14)) { foreach ($o in @(0,2)) { foreach ($d in @(0,2)) { foreach ($t in @(0,1)) { '{0}/v{1}/O{2}/D{3}/T{4}' -f $family,$version,$o,$d,$t } } } } }
Assert-RequiredIdentities $typeCases $types.results.id 'Type matrix IDs'
$strict = Evidence 'docs/results/strict-v3.json'
if (-not $strict.passed) { throw 'Strict gate/recovery expected outcomes failed.' }
Assert-RequiredIdentities $requirements.required_strict_ids $strict.results.id 'Strict gate IDs'
$presentations = Evidence 'docs/results/types-v3-quality.json'
Assert-RequiredIdentities @('scalar_parameters','generic_identity','generic_record','generic_vararg','roblox_identity','roblox_position','roblox_snapshot') $presentations.results.family 'Typed presentation strict cases'
foreach ($row in $presentations.results) {
    if ($row.validation.syntax -ne 'passed' -or $row.validation.compilation -ne 'passed') { throw ('Presentation syntax/compile failed: ' + $row.family) }
    if ($row.validation.strict_analysis -ne 'passed' -or -not $row.validation.required_passed -or $row.type_report.emitted_useful_annotations -le 0) { throw ('Presentation lost strict checking or useful annotations: ' + $row.family) }
}
$oracle = Evidence 'artifacts/oracle-conformance/report.json'
if ($oracle.oracle_protocol -ne 'LOBS/1' -or $oracle.negative_collision_pairs -lt $requirements.required_oracle_collision_pairs -or $oracle.negative_pairs_passed -ne $oracle.negative_collision_pairs -or -not $oracle.empty_inputs_and_probes_are_rejected) { throw 'Typed oracle collision negatives failed.' }
$analysis = Evidence 'artifacts/analyzer-conformance/report.json'
if (-not $analysis.passed -or $analysis.protocol -ne 'LQUAL/1' -or $analysis.cases.Count -lt $requirements.required_analyzer_conformance_cases -or @($analysis.cases | Where-Object {-not $_.passed}).Count -gt 0) { throw 'Independent analyzer conformance failed.' }
Assert-RequiredIdentities @('scalar','roblox_snapshot','generic_pack','resolved_module','resolved_module_bad_argument','unknown_datamodel_child','type_mismatch','dynamic_require','syntax_error','any_visible','runtime_not_executed','type_function_not_executed') $analysis.cases.id 'Analyzer conformance IDs'
$catalog = Evidence 'docs/results/catalog-http-v3.json'
if (-not $catalog.passed -or $catalog.cases -lt 10 -or @($catalog.results | Where-Object {-not $_.passed}).Count -gt 0) { throw 'Catalog HTTP/cache conformance failed.' }
Assert-RequiredIdentities @('http_200_required_user_agent_allowlist','fresh_cache_no_request','http_304_conditional_preserves_observation','http_429_retry_after_stale_label','retry_after_force_cannot_bypass','offline_no_request','invalid_200_preserves_previous_cache','uncached_429_persists_cooldown','uncached_cooldown_no_request','cache_hash_tamper_rejected') $catalog.results.id 'Catalog fixture IDs'
$inventoryPath='docs/results/executor-catalog-v3.json'
$inventory=Get-Content -LiteralPath $inventoryPath -Raw|ConvertFrom-Json
$matrix=Evidence 'docs/results/executor-compatibility-v3.json'
if($matrix.catalog_normalized_sha256 -cne (Get-FileHash -LiteralPath $inventoryPath -Algorithm SHA256).Hash.ToLowerInvariant() -or $matrix.catalog_raw_sha256 -cne $inventory.raw_sha256 -or $matrix.catalog_observed_at_utc -cne $inventory.observed_at_utc -or $matrix.catalog_rows.Count -ne $inventory.entries.Count -or $matrix.generator_sha256 -cne (Get-FileHash -LiteralPath scripts/build-executor-compatibility-v3.ps1 -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Executor matrix does not match its actual catalog snapshot/generator.'}
Assert-RequiredIdentities $inventory.entries.id $matrix.catalog_rows.id 'Executor matrix catalog IDs'
foreach($row in $matrix.catalog_rows){if($null -ne $row.builds.actual_executor -or $null -ne $row.builds.actual_roblox -or $row.coverage.distinct_known_source_native_programs_verified -ne 0 -or $row.coverage.distinct_supplied_bytecode_programs_verified -ne 0 -or $row.capabilities.status -ne 'not_probed'){throw ('Catalog metadata was promoted to independent compatibility: '+$row.id)}}
Assert-RequiredIdentities @('mock-contract:volt','mock-contract:lynx','mock-contract:madium') $matrix.mock_contract_rows.id 'Separate wrapper mock IDs'
$mockEvidence=$matrix.mock_execution_evidence
if($null -eq $mockEvidence -or $mockEvidence.exit_code -ne 0 -or $mockEvidence.source_sha256 -cne (Get-FileHash -LiteralPath adapter/test-v3.luau -Algorithm SHA256).Hash.ToLowerInvariant() -or $mockEvidence.adapter_sha256 -cne (Get-FileHash -LiteralPath adapter/decompile.luau -Algorithm SHA256).Hash.ToLowerInvariant() -or $mockEvidence.runner_sha256 -cne (Get-FileHash -LiteralPath .tools/luau/luau.exe -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Wrapper contract mocks lack current successful command/tool/source provenance.'}
foreach($row in $matrix.mock_contract_rows){if($row.test_status -ne 'passed_injected_host_harness' -or $row.distinct_known_source_native_programs_verified -ne 0 -or $row.distinct_supplied_bytecode_programs_verified -ne 0){throw ('Wrapper mocks were missing or promoted to native evidence: '+$row.id)}}
if($matrix.historical_live_rows.Count -ne 1 -or $matrix.historical_live_rows[0].decompiler_version -ne '0.2.0' -or $matrix.historical_live_rows[0].report_sha256 -cne (Get-FileHash -LiteralPath docs/results/madium-live.json -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Historical v0.2 executor evidence lost its separate provenance.'}
$livePath='docs/results/madium-live-v3.json'
$live=Get-Content -LiteralPath $livePath -Raw|ConvertFrom-Json
if($live.passed -ne $false -or $live.status -ne 'failed_transport_unavailable_in_this_test_context' -or $live.verified_typed_comparisons -ne 0 -or $live.distinct_known_source_native_programs_verified -ne 0 -or $live.distinct_unknown_source_native_models_behaviorally_verified -ne 0 -or $live.distinct_supplied_bytecode_programs_verified -ne 0 -or $live.latency.successful_samples -ne 0 -or $live.transport_diagnosis.cause -ne 'unknown' -or -not $live.completed_checks.raw_restored -or -not $live.completed_checks.registry_cleared){throw 'Actual live transport failure was lost or promoted to behavioral success.'}
if($matrix.v0_3_live_rows.Count -ne 1 -or $matrix.v0_3_live_rows[0].report_sha256 -cne (Get-FileHash -LiteralPath $livePath -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Current live failure matrix lacks exact observed-report provenance.'}
Assert-HistoricalLiveSources $live
$service = Evidence 'docs/results/service-v3.json'
if (-not $service.all_leases_released -or -not $service.tiny.complete -or -not $service.near_raw_limit.complete -or $service.tiny.new_aggregate_peak_bytes -ge $service.tiny.legacy_admission_bytes -or $service.near_raw_limit.new_aggregate_peak_bytes -ge $service.memory_limit_bytes) { throw 'Staged resource-admission regression failed.' }
$native = Evidence 'docs/results/native-place-v3-preparation.json'
$model=Evidence 'docs/results/native-v3-model.json'
if($model.semantic_matches -ne 9 -or $model.complete_packet_matches -ne 6 -or $model.cases.Count -ne 9 -or $model.native_bytes -ne 47 -or $model.native_hex -cne '0e0300000128010000010a0004a3000000ff0000000000000082000200000001000118005a00000100000000000a00' -or $model.original_source_provenance -ne 'unknown' -or $model.native_known_source_programs_verified -ne 0 -or $model.compiler_sha256 -cne (Get-FileHash -LiteralPath .tools/luau-modern/luau-compile.exe -Algorithm SHA256).Hash.ToLowerInvariant() -or @($model.cases|Where-Object {-not $_.semantic_fields_equal}).Count -ne 0){throw 'Current native packet lacks complete independent effect-free compiler-model proof; this is distinct from known-source provenance.'}
$nativeManifest = Get-Content -LiteralPath fixtures/roblox-v3/manifest.json -Raw | ConvertFrom-Json
Assert-RequiredIdentities $nativeManifest.cases.id $native.cases.id 'Prepared native fixture IDs'
if ($native.host_compiler_cases -ne 14 -or $native.host_compiler_passed -ne 14 -or -not $native.xml_validated) { throw 'Controlled native fixture preparation failed; host validation is distinct from client execution.' }
$tools = Get-QualityToolProvenance
$coverage=Evidence 'docs/results/coverage-guided-v3.json'
if(-not $coverage.passed -or -not $coverage.source_snapshot_unchanged -or -not $coverage.never_executes_luau -or -not $coverage.other_section_contents_unchanged -or $coverage.requested_mutation_iterations -ne $requirements.required_coverage_mutations -or $coverage.mutations_executed -ne $requirements.required_coverage_mutations -or $coverage.seed_executions -ne $requirements.required_coverage_seed_executions -or $coverage.distinct_seed_bytecodes -ne $requirements.required_coverage_seed_executions -or $coverage.cases_executed -ne $requirements.required_coverage_cases -or $coverage.results.Count -ne $requirements.required_coverage_cases -or $coverage.global_time_bound_seconds -ne $requirements.required_coverage_seconds_bound -or $coverage.random_seed -ne $requirements.required_coverage_random_seed -or $coverage.failures.Count -ne 0 -or $coverage.novel_mutants -le 0 -or $coverage.seed_owned_covered_regions -le 0 -or $coverage.final_owned_covered_regions -le $coverage.seed_owned_covered_regions -or $coverage.final_owned_covered_regions -gt $coverage.owned_regions_in_linked_instrumented_binary){throw 'Required LLVM coverage-guided campaign is incomplete or lacks actual owned-region growth.'}
Assert-RequiredIdentities (6..14) $coverage.seed_versions 'Coverage seed versions'
Assert-RequiredIdentities $requirements.required_coverage_seed_paths $coverage.seeds.path 'Coverage seed identities'
Assert-RequiredIdentities (0..559) $coverage.results.case 'Coverage execution IDs'
foreach($seed in $coverage.seeds){if((Get-FileHash -LiteralPath $seed.path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $seed.sha256 -or (Get-Item -LiteralPath $seed.path).Length -ne $seed.bytes){throw ('Coverage immutable seed changed: '+$seed.path)}}
$expectedCoverageSources=@(Get-ChildItem -LiteralPath src -Filter '*.rs' -File)+@(Get-ChildItem -LiteralPath definitions -File)+@(Get-Item -LiteralPath Cargo.toml,Cargo.lock,examples/coverage_harness.rs,scripts/fuzz-coverage.ps1,scripts/build-coverage-runtime.ps1)+@(Get-ChildItem -LiteralPath scripts/coverage-runtime -File)
Assert-RequiredIdentities @($expectedCoverageSources|ForEach-Object {$_.FullName.Substring($taskRoot.Length+1).Replace('\','/')}) $coverage.source_files.path 'Coverage source snapshot closure'
foreach($file in $coverage.source_files){if((Get-FileHash -LiteralPath $file.path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $file.sha256){throw ('Coverage source no longer matches final snapshot: '+$file.path)}}
$coverageTools=@{'artifacts/coverage-build/debug/examples/coverage_harness.exe'=$coverage.harness_sha256;'artifacts/coverage-fuzz-v3/coverage-analysis.exe'=$coverage.analysis_copy_sha256;'artifacts/coverage-fuzz-v3/union.profdata'=$coverage.union_profile_sha256;'artifacts/coverage-runtime/manifest.json'=$coverage.runtime_manifest_sha256}
foreach($path in $coverageTools.Keys){if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $coverageTools[$path]){throw ('Coverage tool/profile differs from fresh campaign: '+$path)}}
$runtime=Get-Content -LiteralPath artifacts/coverage-runtime/manifest.json -Raw|ConvertFrom-Json
$runtimeLock=Get-Content -LiteralPath scripts/coverage-runtime/upstream.lock.json -Raw|ConvertFrom-Json
if($runtime.upstream_lock_sha256 -cne (Get-FileHash -LiteralPath scripts/coverage-runtime/upstream.lock.json -Algorithm SHA256).Hash.ToLowerInvariant() -or $runtime.shim_sha256 -cne (Get-FileHash -LiteralPath scripts/coverage-runtime/InstrProfilingPlatformWindows.gnu.c -Algorithm SHA256).Hash.ToLowerInvariant() -or $runtime.wrapper_sha256 -cne (Get-FileHash -LiteralPath scripts/coverage-runtime/profiler.rs -Algorithm SHA256).Hash.ToLowerInvariant() -or $runtime.library_sha256 -cne (Get-FileHash -LiteralPath artifacts/coverage-runtime/lib/libprofiler-rt.a -Algorithm SHA256).Hash.ToLowerInvariant() -or $runtime.marker_sha256 -cne (Get-FileHash -LiteralPath artifacts/coverage-runtime/lib/libprofiler_builtins.rlib -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Coverage runtime differs from pinned sources/linked artifacts.'}
foreach($file in $runtimeLock.files){if((Get-FileHash -LiteralPath ('artifacts/coverage-runtime/compiler-rt/'+$file.path) -Algorithm SHA256).Hash.ToLowerInvariant() -cne $file.sha256){throw ('Coverage upstream runtime source changed: '+$file.path)}}
$sysroot=(& rustc --print sysroot);$llvm=Join-Path $sysroot 'lib/rustlib/x86_64-pc-windows-gnu/bin'
if($coverage.llvm_cov_sha256 -cne (Get-FileHash -LiteralPath (Join-Path $llvm 'llvm-cov.exe') -Algorithm SHA256).Hash.ToLowerInvariant() -or $coverage.llvm_profdata_sha256 -cne (Get-FileHash -LiteralPath (Join-Path $llvm 'llvm-profdata.exe') -Algorithm SHA256).Hash.ToLowerInvariant() -or $runtime.linker_sha256 -cne (Get-FileHash -LiteralPath (Join-Path $llvm 'rust-lld.exe') -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Coverage LLVM reader/merger/linker provenance changed.'}
if ($analysis.analyzer_sha256 -cne $tools.analyzer_sha256 -or $analysis.definitions_sha256 -cne $tools.definitions_sha256) { throw 'Analyzer conformance used different tools or definitions.' }
foreach ($row in $strict.results) { if ($row.quality.analyzer_sha256 -cne $tools.analyzer_sha256 -or $row.quality.definitions_sha256 -cne $tools.definitions_sha256 -or [string]::IsNullOrWhiteSpace($row.quality.context_sha256)) { throw ('Strict result lacks current analyzer/definitions/context provenance: ' + $row.id) } }
foreach ($row in $presentations.results) { if ($row.validation.analyzer_sha256 -cne $tools.analyzer_sha256 -or $row.validation.definitions_sha256 -cne $tools.definitions_sha256 -or [string]::IsNullOrWhiteSpace($row.validation.context_sha256)) { throw ('Typed presentation lacks current analyzer/definitions/context provenance: ' + $row.family) } }
Write-Output 'v0.3 required identities, feature families, typed observations, independent strict outcomes, and provenance passed.'
