param([Parameter(Mandatory=$true)][DateTime]$NotBefore)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'release-integrity.ps1')
$requirements=Get-Content -LiteralPath tests/release-requirements-rc.json -Raw | ConvertFrom-Json
if($requirements.schema -ne 1 -or $requirements.version -cne '0.4.0-rc.4'){throw 'Unexpected candidate requirements manifest.'}
Assert-RequiredIdentities @('source_inputs','source_behavior_rc','source_rc2','types_rc','output_policy','scale_quality_rc','attribution') $requirements.mandatory_targets 'Candidate mandatory targets'
function Read-FreshEvidence([string]$Path) {
    if(-not(Test-Path -LiteralPath $Path) -or (Get-Item -LiteralPath $Path).LastWriteTimeUtc -lt $NotBefore){throw ('Missing or stale candidate evidence: '+$Path)}
    Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}
function Assert-Rc2LiveSources($Report,[string]$EvidenceRoot=$taskRoot){
    if($Report.version -cne '0.4.0-rc.2' -or $Report.archive_path -cne 'evidence/releases/0.4.0-rc.2-live.zip' -or $Report.archive_manifest -cne 'evidence/releases/0.4.0-rc.2-live-manifest.json'){throw 'Historical rc.2 source archive identity is unsupported.'}
    $archivePath=Join-Path $EvidenceRoot $Report.archive_path
    $manifestPath=Join-Path $EvidenceRoot $Report.archive_manifest
    if((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Report.archive_sha256 -or (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Report.archive_manifest_sha256){throw 'Historical rc.2 source archive or manifest changed.'}
    $manifest=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json
    $record=@($manifest.files|Where-Object{$_.path -ceq 'driver-redacted.luau'})
    if($record.Count -ne 1 -or $record[0].bytes -gt 1048576 -or $record[0].bytes -lt 1){throw 'Historical rc.2 source driver is missing or unbounded.'}
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive=[IO.Compression.ZipFile]::OpenRead($archivePath)
    try{
        $entry=$archive.GetEntry('driver-redacted.luau')
        if(-not $entry -or $entry.Length -ne $record[0].bytes){throw 'Historical rc.2 source driver length changed.'}
        $stream=$entry.Open();$buffer=[IO.MemoryStream]::new()
        try{$stream.CopyTo($buffer);$bytes=$buffer.ToArray()}finally{$buffer.Dispose();$stream.Dispose()}
    }finally{$archive.Dispose()}
    $algorithm=[Security.Cryptography.SHA256]::Create()
    try{$hash=([BitConverter]::ToString($algorithm.ComputeHash($bytes))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
    if($hash -cne $record[0].sha256){throw 'Historical rc.2 source driver bytes changed.'}
    $utf8=[Text.UTF8Encoding]::new($false,$true)
    $pattern='(?s)\Alocal Adapter=assert\(loadstring\(\[===\[(?<adapter>.*?)\n\]===\]\)\)\(\)\nlocal Observer=assert\(loadstring\(\[===\[(?<observer>.*?)\n\]===\]\)\)\(\)'
    $match=[regex]::Match($utf8.GetString($bytes),$pattern)
    if(-not $match.Success){throw 'Historical rc.2 source wrapper is not the recorded form.'}
    $results=@()
    foreach($pair in @(@('adapter','adapter/decompile.luau'),@('observer','adapter/live-test-v3.luau'))){
        $algorithm=[Security.Cryptography.SHA256]::Create()
        try{$hash=([BitConverter]::ToString($algorithm.ComputeHash($utf8.GetBytes($match.Groups[$pair[0]].Value)))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
        if($hash -cne $Report.($pair[0]+'_sha256')){throw ('Historical rc.2 embedded source differs from its report: '+$pair[0])}
        $currentPath=Join-Path $EvidenceRoot $pair[1]
        $currentMatches=(Test-Path -LiteralPath $currentPath -PathType Leaf) -and (Get-FileHash -LiteralPath $currentPath -Algorithm SHA256).Hash.ToLowerInvariant() -ceq $hash
        $results+=@{path=$pair[1];recorded_sha256=$hash;archive_entry='driver-redacted.luau';matches_current_source=[bool]$currentMatches;scope='Historical rc.2 live evidence; not a current adapter test.'}
    }
    return ,$results
}
function Get-ArchivedExecutorBytes($File,[string]$EvidenceRoot){
    if($File.id -cnotmatch '^[a-z_]+$' -or $File.compressed_path -cne ('fixtures/observations/rc-20261111/'+$File.id+'.gz') -or $File.uncompressed_bytes -lt 0 -or $File.uncompressed_bytes -gt 1048576){throw 'Invalid independent executor archive bounds or path.'}
    $path=Join-Path $EvidenceRoot $File.compressed_path
    if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $File.compressed_sha256){throw ('Independent executor compressed identity changed: '+$File.id)}
    $input=[IO.File]::OpenRead($path);$gzip=[IO.Compression.GZipStream]::new($input,[IO.Compression.CompressionMode]::Decompress);$output=[IO.MemoryStream]::new()
    try{
        $buffer=New-Object byte[] 8192
        while(($count=$gzip.Read($buffer,0,$buffer.Length)) -gt 0){if($output.Length+$count -gt $File.uncompressed_bytes){throw 'Independent executor decompression exceeded its recorded bound.'};$output.Write($buffer,0,$count)}
        $bytes=$output.ToArray();$algorithm=[Security.Cryptography.SHA256]::Create()
        try{$actual=([BitConverter]::ToString($algorithm.ComputeHash($bytes))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
        if($bytes.Length -ne $File.uncompressed_bytes -or $actual -cne $File.source_sha256){throw ('Independent executor source bytes changed: '+$File.id)}
        return ,$bytes
    }finally{$output.Dispose();$gzip.Dispose();$input.Dispose()}
}
function Assert-ExecutorLobsFrame([string]$Hex){
    if($Hex.Length -gt 2097152 -or $Hex -cnotmatch '^(?:[0-9a-f]{2})+$'){throw 'Native observation is not a bounded exact byte frame.'}
    $bytes=New-Object byte[] ($Hex.Length/2)
    for($index=0;$index -lt $bytes.Length;$index++){$bytes[$index]=[Convert]::ToByte($Hex.Substring($index*2,2),16)}
    $stream=[IO.MemoryStream]::new($bytes,$false);$reader=[IO.BinaryReader]::new($stream)
    function Read-ExecutorTuple {
        $values=$reader.ReadUInt32();if($values -gt 4096){throw 'Native observation tuple exceeds its bound.'}
        for($item=0;$item -lt $values;$item++){
            switch($reader.ReadByte()){
                0 {}
                1 {if($reader.ReadByte() -gt 1){throw 'Invalid native boolean.'}}
                2 {if($reader.ReadBytes(8).Length -ne 8){throw 'Truncated native number.'}}
                3 {$length=$reader.ReadUInt32();if($length -gt $stream.Length-$stream.Position){throw 'Truncated native binary string.'};if($reader.ReadBytes([int]$length).Length -ne $length){throw 'Truncated native binary string.'}}
                default {throw 'Unsupported native observation tag.'}
            }
        }
    }
    try{
        if([Text.Encoding]::ASCII.GetString($reader.ReadBytes(4)) -cne 'LOBS' -or $reader.ReadByte() -ne 1 -or $reader.ReadByte() -ne 1){throw 'Native observation is not a complete LOBS/1 frame.'}
        $effects=$reader.ReadUInt32();if($effects -gt 4096){throw 'Native effect count exceeds its bound.'}
        for($effect=0;$effect -lt $effects;$effect++){if($reader.ReadByte() -notin @(1,2)){throw 'Invalid native effect.'};Read-ExecutorTuple}
        if($reader.ReadByte() -notin @(0,1)){throw 'Invalid native outcome.'};Read-ExecutorTuple
        if($stream.Position -ne $stream.Length){throw 'Trailing native observation bytes.'}
    }finally{$reader.Dispose();$stream.Dispose()}
}
function Assert-IndependentExecutorEvidence([string]$EvidenceRoot=$taskRoot,[string]$ExecutablePath='target/release/luau-decompile.exe'){
    $manifestPath=Join-Path $EvidenceRoot 'fixtures/observations/rc-20261111/manifest.json'
    if((Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne 'ff9a5bc0e1fb969c1341bb2b313c6feffa430703f057d8f32307a8bdb3180a36'){throw 'Independent executor archive manifest changed.'}
    $manifest=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json
    if($manifest.schema -ne 1 -or $manifest.version -cne '0.4.0-rc.1' -or $manifest.reports.Count -ne 2 -or $manifest.files.Count -ne 23){throw 'Independent executor archive is incomplete.'}
    Assert-RequiredIdentities @('live','native') $manifest.reports.id 'Independent executor report identities'
    Assert-RequiredIdentities @('adapter','observer','native_harness','live_generator','native_generator','function_fixtures','live_driver','live_capture','live_host_capabilities','native_driver','native_config','native_observations','native_varargs_output','native_guarded_output','native_fixed_output','native_stateful_output','native_varargs_diagnostic','native_guarded_diagnostic','native_fixed_diagnostic','native_stateful_diagnostic','native_captured_diagnostic','live_report','native_report') $manifest.files.id 'Independent executor archived identities'
    $files=@{};$bytes=@{};$sourceMatches=@()
    foreach($file in $manifest.files){
        $files[$file.id]=$file;$bytes[$file.id]=Get-ArchivedExecutorBytes $file $EvidenceRoot
        if($file.current_source){$currentPath=Join-Path $EvidenceRoot $file.original_path;$matches=(Test-Path -LiteralPath $currentPath -PathType Leaf) -and (Get-FileHash -LiteralPath $currentPath -Algorithm SHA256).Hash.ToLowerInvariant() -ceq $file.source_sha256;$sourceMatches+=@{path=$file.original_path;recorded_sha256=$file.source_sha256;matches_current_source=[bool]$matches}}
    }
    $utf8=[Text.UTF8Encoding]::new($false,$true);$currentExecutable=Join-Path $EvidenceRoot $ExecutablePath
    $currentHash=if(Test-Path -LiteralPath $currentExecutable -PathType Leaf){(Get-FileHash -LiteralPath $currentExecutable -Algorithm SHA256).Hash.ToLowerInvariant()}else{$null}
    $results=@()
    foreach($identity in $manifest.reports){
        $expectedPath=if($identity.id -ceq 'live'){'docs/results/madium-live-rc.json'}else{'docs/results/native-functions-rc.json'}
        if($identity.path -cne $expectedPath){throw 'Independent executor report path changed.'}
        $path=Join-Path $EvidenceRoot $identity.path
        if(-not(Test-Path -LiteralPath $path -PathType Leaf)){$results+=@{id=$identity.id;present=$false;status='not_run_here; optional independently recorded external report absent'};continue}
        $reportText=[IO.File]::ReadAllText($path,$utf8).Replace("`r`n","`n");$algorithm=[Security.Cryptography.SHA256]::Create()
        try{$normalizedHash=([BitConverter]::ToString($algorithm.ComputeHash($utf8.GetBytes($reportText)))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
        if($identity.archive_id -cne ($identity.id+'_report') -or $files[$identity.archive_id].source_sha256 -cne $identity.sha256 -or $normalizedHash -cne $identity.normalized_lf_sha256){throw ('Independent executor report identity changed beyond Git line-ending normalization: '+$identity.id)}
        $report=Get-Content -LiteralPath $path -Raw|ConvertFrom-Json
        if($report.schema -ne 1 -or $report.version -cne $manifest.version -or $report.executable_sha256 -cne $identity.executable_sha256 -or $report.adapter_sha256 -cne $files.adapter.source_sha256){throw 'Independent executor tool/source provenance is incomplete.'}
        if($identity.id -ceq 'live'){
            if($report.generator_sha256 -cne $files.live_generator.source_sha256 -or $report.redacted_driver_sha256 -cne $files.live_driver.source_sha256 -or $report.captured_result_sha256 -cne $files.live_capture.source_sha256 -or $report.host_capabilities_sha256 -cne $files.live_host_capabilities.source_sha256){throw 'Live attempt source/capture identities changed.'}
            if($report.status -cne 'failed_transport' -or $report.completed_adapter_programs -ne 0 -or $report.verified_behavioral_pairs -ne 0 -or $report.successful_adapter_latency_samples -ne 0 -or $report.outcome.ok -or $report.outcome.complete -or -not $report.outcome.original_restored -or -not $report.cleanup.original_decompile_restored -or -not $report.cleanup.adapter_registry_cleared){throw 'Failed live transport was promoted to successful compatibility.'}
            $capture=$utf8.GetString($bytes.live_capture)|ConvertFrom-Json;$observed=@{}
            foreach($item in $capture.result.values[0].entries){if($observed.ContainsKey($item.key)){throw 'Duplicate live capture entry.'};$observed[$item.key]=$item.value}
            if(-not $capture.captured -or -not $capture.result.ok -or $capture.result.values[0].truncated -or $observed.Count -ne @($report.outcome.PSObject.Properties).Count){throw 'Live capture is incomplete.'}
            foreach($property in $report.outcome.PSObject.Properties){if(-not $observed.ContainsKey($property.Name) -or ($observed[$property.Name]|ConvertTo-Json -Compress) -cne ($property.Value|ConvertTo-Json -Compress)){throw 'Live outcome differs from the exact captured observation.'}}
        }else{
            foreach($pair in @(@('observer_sha256','observer'),@('harness_sha256','native_harness'),@('driver_sha256','native_driver'),@('generator_sha256','native_generator'),@('fixture_sha256','function_fixtures'),@('configuration_sha256','native_config'))){if($report.($pair[0]) -cne $files[$pair[1]].source_sha256){throw ('Native recorded source identity changed: '+$pair[0])}}
            $fixture=$utf8.GetString($bytes.function_fixtures)|ConvertFrom-Json;$native=$utf8.GetString($bytes.native_observations)|ConvertFrom-Json;$configuration=$utf8.GetString($bytes.native_config)|ConvertFrom-Json
            if($configuration.output_policy -cne 'faithful' -or $configuration.entry_output -cne 'function' -or $configuration.bytecode_encoding -cne 'roblox_opcode227' -or $configuration.validation.mode -cne 'off' -or $report.native_http_adapter_success -or $report.distinct_accepted_programs -ne 4 -or $report.expected_rejections -ne 1 -or $report.runtime_observation_pairs -ne 20 -or $report.oracle_protocol -cne 'LOBS/1' -or $report.cli_results.Count -ne 5 -or $report.native_observations.comparisons -ne 20 -or -not $native.oracle.passed -or $native.oracle.negative_collision_pairs -ne 7 -or $native.oracle.unsupported_observations_rejected -ne 3){throw 'Native evidence scope or observation counts changed.'}
            if(($native|ConvertTo-Json -Depth 30 -Compress) -cne ($report.native_observations|ConvertTo-Json -Depth 30 -Compress)){throw 'Native observations differ from their captured bytes.'}
            Assert-RequiredIdentities @('varargs','guarded','fixed','stateful','captured') $fixture.cases.id 'Native fixture identities'
            Assert-RequiredIdentities $fixture.cases.id $report.cli_results.id 'Native result identities'
            foreach($case in $fixture.cases){
                $row=@($report.cli_results|Where-Object{$_.id -ceq $case.id})[0];$algorithm=[Security.Cryptography.SHA256]::Create()
                try{$sourceHash=([BitConverter]::ToString($algorithm.ComputeHash($utf8.GetBytes($case.source)))).Replace('-','').ToLowerInvariant();$packet=New-Object byte[] ($case.hex.Length/2);for($index=0;$index -lt $packet.Length;$index++){$packet[$index]=[Convert]::ToByte($case.hex.Substring($index*2,2),16)};$packetHash=([BitConverter]::ToString($algorithm.ComputeHash($packet))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
                if($row.known_source_sha256 -cne $sourceHash -or $row.packet_sha256 -cne $packetHash -or $row.input_bytes -ne $packet.Length -or $row.diagnostic_sha256 -cne $files['native_'+$case.id+'_diagnostic'].source_sha256){throw ('Native source/packet/diagnostic mismatch: '+$case.id)}
                $observation=@($native.cases.PSObject.Properties.Value|Where-Object{$_.id -ceq $case.id});if($observation.Count -ne 1){throw 'Native observation identity missing or duplicated.'}
                if($case.id -ceq 'captured'){if($row.cli_exit -ne 1 -or $null -ne $row.output_sha256 -or -not $row.captured_upvalues_absent -or -not $observation[0].rejected -or $observation[0].verified){throw 'Absent live upvalues were counted as successful reconstruction.'}}
                else{if($row.cli_exit -ne 0 -or $row.output_sha256 -cne $files['native_'+$case.id+'_output'].source_sha256 -or -not $observation[0].verified -or @($observation[0].inputs.PSObject.Properties).Count -ne 5){throw 'Native successful output/observation identities are incomplete.'};foreach($input in $observation[0].inputs.PSObject.Properties.Value){if(-not $input.verified -or $input.expected_hex -cne $input.actual_hex){throw 'Native exact typed observations differ.'};Assert-ExecutorLobsFrame $input.actual_hex}}
            }
        }
        $results+=@{id=$identity.id;present=$true;report_sha256=$identity.sha256;recorded_executable_sha256=$report.executable_sha256;matches_current_executable=($report.executable_sha256 -ceq $currentHash);current_executable_sha256=$currentHash;status='independent external observation; source/executable equality is separate from recorded outcome'}
    }
    return [ordered]@{schema=1;version=$manifest.version;archive_manifest_sha256='ff9a5bc0e1fb969c1341bb2b313c6feffa430703f057d8f32307a8bdb3180a36';report_line_endings='Only CRLF to LF normalization is accepted for checked-in JSON; exact original bytes remain archived and hash-verified.';sources=$sourceMatches;reports=$results;live_compatibility_success=$false}
}
$tools=Get-QualityToolProvenance
$packagingBoundaries=Read-FreshEvidence 'docs/results/release-integrity-v3.json'
if(-not $packagingBoundaries.passed){throw 'Release boundary identity checks failed'}
Assert-RequiredIdentities $requirements.packaging_boundary_case_ids $packagingBoundaries.results.id 'Installer packaging boundary cases'
foreach($case in $packagingBoundaries.results){if(-not $case.passed){throw ('Release boundary case failed: '+$case.id)}}
$analyzer=Read-FreshEvidence 'artifacts/analyzer-conformance/report.json'
if(-not $analyzer.passed -or $analyzer.protocol -cne 'LQUAL/1' -or $analyzer.cases.Count -ne $requirements.analyzer_conformance_case_ids.Count -or $analyzer.analyzer_sha256 -cne $tools.analyzer_sha256 -or $analyzer.definitions_sha256 -cne $tools.definitions_sha256){throw 'Candidate analyzer conformance identities or tool provenance are incomplete.'}
Assert-RequiredIdentities $requirements.analyzer_conformance_case_ids $analyzer.cases.id 'Candidate analyzer conformance cases'
foreach($case in $analyzer.cases){
    if(-not $case.passed -or $case.result.strict -ne $case.expected_strict){throw ('Analyzer case outcome changed: '+$case.id)}
    if($case.id -in @('nested_function_any','nested_pack_record_any') -and ($case.result.inferred_any -le 0 -or $case.result.type_traversal_exhausted)){throw ('Nested analyzer any was omitted: '+$case.id)}
    if($case.id -eq 'nested_unknown' -and ($case.result.inferred_unknown -le 0 -or $case.result.type_traversal_exhausted)){throw 'Nested analyzer unknown was omitted.'}
    if($case.id -in @('generic_pack','recursive_record_clean','sdk_calls_clean') -and ($case.result.inferred_any -ne 0 -or $case.result.inferred_unknown -ne 0 -or $case.result.type_traversal_exhausted)){throw ('Clean analyzer type graph was misclassified: '+$case.id)}
}
if($analyzer.type_quality_budget_self_test.passed -ne $true){throw 'Analyzer bounded type-graph self-test is missing or failed.'}
foreach($flag in $requirements.analyzer_quality_self_test_flags){
    if($analyzer.type_quality_budget_self_test.$flag -ne $true){throw ('Analyzer type-graph invariant was not verified: '+$flag)}
}
$source=Read-FreshEvidence 'docs/results/source-input-rc.json'
if(-not $source.passed -or $source.compiled_cases -ne $requirements.source_compiled_cases -or $source.typed_comparisons -ne $requirements.source_typed_comparisons -or $source.failures.Count -ne 0){throw 'Source processing behavioral matrix is incomplete.'}
Assert-RequiredIdentities $requirements.source_case_ids $source.cases.id 'Source processing cases'
foreach($case in $source.cases){if(-not $case.passed -or $case.comparisons.Count -ne 3 -or @($case.comparisons|Where-Object{-not $_.equivalent -or -not $_.complete}).Count -ne 0){throw ('Incomplete source observation: '+$case.id)}}
function Assert-ExactBehavior($Rows,[string]$Label){
    foreach($row in $Rows){
        if(-not $row.verified -or -not $row.expected.complete -or -not $row.actual.complete -or $row.expected.protocol -cne 'LOBS/1' -or $row.actual.protocol -cne 'LOBS/1' -or ($row.expected|ConvertTo-Json -Depth 24 -Compress) -cne ($row.actual|ConvertTo-Json -Depth 24 -Compress)){throw ('Incomplete exact observation: '+$Label)}
    }
}
$boundaries=Read-FreshEvidence $requirements.rc2_source_boundaries.report
if(-not $boundaries.passed -or $boundaries.version -cne $requirements.version -or $boundaries.cases.Count -ne $requirements.rc2_source_boundaries.comparisons){throw 'Token-boundary behavioral matrix is incomplete.'}
Assert-ExactBehavior $boundaries.cases 'source boundaries'
$indexCases=@($boundaries.cases|Where-Object{$_.family -ceq 'long_string_index'})
$grammarCases=@($boundaries.cases|Where-Object{$_.family -ceq 'grammar'})
if($indexCases.Count -ne 48 -or $grammarCases.Count -ne 12){throw 'Token-boundary families changed.'}
foreach($equals in $requirements.rc2_source_boundaries.delimiter_equals){foreach($callable in @($false,$true)){foreach($mode in @('off','check')){foreach($style in $requirements.rc2_source_boundaries.styles){if(@($indexCases|Where-Object{$_.delimiter_equals -eq $equals -and $_.callable -eq $callable -and $_.validation -ceq $mode -and $_.style -ceq $style}).Count -ne 1){throw 'Required long-string configuration omitted or duplicated.'}}}}}
$generatedSource=Read-FreshEvidence $requirements.rc2_source_generated.report
if(-not $generatedSource.passed -or $generatedSource.version -cne $requirements.version -or $generatedSource.cases -ne 56 -or $generatedSource.comparisons.Count -ne 168){throw 'Generated source coverage is incomplete.'}
Assert-ExactBehavior $generatedSource.comparisons 'generated source'
Assert-RequiredIdentities $requirements.rc2_source_generated.case_ids $generatedSource.comparisons.id 'Generated source case identities'
$signatures=Read-FreshEvidence $requirements.rc2_source_signatures.report
if(-not $signatures.passed -or $signatures.version -cne $requirements.version -or $signatures.rows.Count -ne 6){throw 'Useful source signature coverage is incomplete.'}
Assert-RequiredIdentities $requirements.rc2_source_signatures.case_ids $signatures.rows.id 'Source signature identities'
Assert-ExactBehavior $signatures.rows 'source signatures'
foreach($row in $signatures.rows){if(-not $row.validation.required_passed -or -not $row.validation.meaningful_typing.passed -or $row.validation.strict_analysis -cne 'passed' -or $row.validation.output_policy -cne 'verified_typed'){throw 'Source signature was not verified typed.'}}
$aliases=Read-FreshEvidence $requirements.rc2_aliases.report
if(-not $aliases.all_verified -or $aliases.version -cne $requirements.version -or $aliases.cases -ne 96 -or $aliases.typed_comparisons -ne 288 -or $aliases.oracle_protocol -cne 'LOBS/1'){throw 'Alias dependency coverage is incomplete.'}
Assert-RequiredIdentities $requirements.rc2_aliases.case_ids $aliases.rows.id 'Alias dependency identities'
foreach($row in $aliases.rows){if(-not $row.verified -or -not $row.complete -or $row.inputs.Count -ne 3){throw 'Incomplete alias reconstruction.'};Assert-ExactBehavior $row.inputs $row.id}
foreach($family in @('logical_alias','loop_alias','shared_return','shared_pack','shared_effect')){
    $selected=@($aliases.rows|Where-Object{$_.id -ceq ($family+'/v14/O2/D2/T0')})
    if($selected.Count -ne 1 -or -not $selected[0].validation.required_passed -or $selected[0].validation.strict_analysis -cne 'passed' -or $selected[0].validation.syntax -cne 'passed' -or $selected[0].validation.compilation -cne 'passed'){throw ('Required selected alias strict gate failed: '+$family)}
}

$identityCases=Read-FreshEvidence $requirements.rc3_source_identities.report
$scalarCases=Read-FreshEvidence $requirements.rc3_scalar_loops.report
Assert-RequiredIdentities $requirements.rc3_source_identities.case_ids $identityCases.cases.id 'Source function identity cases'
Assert-RequiredIdentities $requirements.rc3_scalar_loops.case_ids $scalarCases.cases.id 'Scalar loop cases'
foreach($pair in @(@($identityCases,3,'source function identities'),@($scalarCases,4,'scalar loop dependencies'))){
    if(-not $pair[0].passed -or $pair[0].version -cne $requirements.version -or $pair[0].cases.Count -ne $pair[1]){throw ('Required rc3 regression missing: '+$pair[2])}
    Assert-ExactBehavior $pair[0].cases $pair[2]
    foreach($row in $pair[0].cases){if(-not $row.strict_passed){throw ('Official strict check failed: '+$pair[2])}}
}
$attribution=Read-FreshEvidence $requirements.rc3_attribution.report
if(-not $attribution.passed -or $attribution.version -cne $requirements.version -or -not $attribution.positive_validation.required_passed -or $attribution.negative_validation.required_passed -or -not $attribution.negative_source_retained){throw 'Finalized-source attribution quality boundaries failed.'}
Assert-RequiredIdentities $requirements.rc3_attribution.case_ids $attribution.cases.id 'Attribution behavioral identities'
Assert-ExactBehavior $attribution.cases 'attribution empty/literal semantics'
$captures=Read-FreshEvidence $requirements.rc4_captures.report
if($captures.version -cne $requirements.version -or $captures.cases -ne $requirements.rc4_captures.case_ids.Count -or -not $captures.behavior_verified -or $captures.oracle_protocol -cne 'LOBS/1'){throw 'Captured scalar and closure coverage is incomplete.'}
Assert-RequiredIdentities $requirements.rc4_captures.case_ids $captures.rows.id 'Captured scalar and closure identities'
Assert-ExactBehavior @(foreach($row in $captures.rows){@{verified=$row.behavior_verified;expected=$row.expected;actual=$row.actual}}) 'Captured scalar and closure behavior'
foreach($row in $captures.rows){
    $required=$row.id.Split('/')[0] -in $requirements.rc4_captures.required_strict_families
    if(-not $row.complete -or $row.strict_required -ne $required -or ($required -and -not $row.strict_passed)){throw ('Captured scalar strict annotation requirement failed: '+$row.id)}
}
if(@($captures.rows|Where-Object{$_.strict_required}).Count -ne $requirements.rc4_captures.required_strict_cases){throw 'Required captured-scalar strict positives changed.'}
$packet=Read-FreshEvidence $requirements.rc4_verified_packet.report
if($packet.version -cne $requirements.version -or $packet.id -cne $requirements.rc4_verified_packet.id -or -not $packet.complete -or -not $packet.behavior_verified -or -not $packet.validation.required_passed -or -not $packet.validation.meaningful_typing.passed -or $packet.validation.strict_analysis -cne 'passed'){throw 'Retained verified bytecode readability/quality acceptance failed.'}
Assert-ExactBehavior @(@{verified=$packet.behavior_verified;expected=$packet.expected;actual=$packet.actual}) 'Retained verified bytecode behavior'
if((Get-FileHash -LiteralPath $requirements.rc4_verified_packet.id -Algorithm SHA256).Hash.ToLowerInvariant() -cne $packet.input_sha256){throw 'Retained verified bytecode input identity changed.'}
foreach($spec in @($requirements.rc4_open_captures,$requirements.rc4_fresh_closures)){
    $evidence=Read-FreshEvidence $spec.report
    if($evidence.version -cne $requirements.version -or $evidence.cases -ne $spec.case_ids.Count){throw 'Open-result/fresh-closure regression coverage is incomplete.'}
    Assert-RequiredIdentities $spec.case_ids $evidence.rows.id 'Open-result/fresh-closure identities'
    Assert-ExactBehavior @(foreach($row in $evidence.rows){@{verified=$row.behavior_verified;expected=$row.expected;actual=$row.actual}}) 'Open-result/fresh-closure behavior'
}
$openEvidence=Read-FreshEvidence $requirements.rc4_open_captures.report
if(-not $openEvidence.active_capture_negative.rejected -or -not $openEvidence.active_capture_negative.producer_before_close){throw 'Active reference-capture producer protection was not retained.'}
$separators=Read-FreshEvidence $requirements.rc4_block_separators.report
if($separators.version -cne $requirements.version -or $separators.cases -ne 2 -or -not $separators.all_behavior_verified){throw 'Block-initial token separation regression coverage is incomplete.'}
Assert-RequiredIdentities $requirements.rc4_block_separators.case_ids $separators.rows.id 'Block separator identities'
Assert-ExactBehavior @(foreach($row in $separators.rows){@{verified=$row.behavior_verified;expected=$row.expected;actual=$row.actual}}) 'Block separator behavior'
$nestedCfg=Read-FreshEvidence $requirements.rc4_nested_cfg.report
if($nestedCfg.version -cne $requirements.version -or $nestedCfg.cases -ne 2 -or $nestedCfg.reconstruction_successes -ne 0 -or -not $nestedCfg.all_contextual_diagnostics){throw 'Nested unsupported CFG diagnostic regression is incomplete or mislabeled as reconstruction.'}
Assert-RequiredIdentities $requirements.rc4_nested_cfg.case_ids $nestedCfg.rows.id 'Nested CFG diagnostic identities'
foreach($row in $nestedCfg.rows){if($row.panic -or $row.reconstruction_complete -or $row.status -cne 'unsupported_control_flow_with_contextual_diagnostic' -or -not $row.original_observation.complete -or $row.original_observation.protocol -cne 'LOBS/1' -or $row.automatic_error -notmatch '^structure in proto [0-9]+ at pc [0-9]+:'){throw 'Nested CFG failure lost its original scope or was counted as success.'}}
$padding=Read-FreshEvidence $requirements.rc4_import_padding.report
if($padding.version -cne $requirements.version -or $padding.cases -ne 4 -or -not $padding.all_behavior_verified -or $padding.captured_programs_executed -ne 0){throw 'GETIMPORT padding behavioral proof is incomplete or misclassified.'}
Assert-RequiredIdentities $requirements.rc4_import_padding.case_ids $padding.rows.id 'GETIMPORT padding identities'
Assert-ExactBehavior @(foreach($row in $padding.rows){@{verified=$row.behavior_verified;expected=$row.expected;actual=$row.actual};@{verified=$row.behavior_verified;expected=$row.expected;actual=$row.mutated}}) 'GETIMPORT padding behavior'
if(($padding.rows|ForEach-Object{@($_.negative_inputs).Count}|Measure-Object -Sum).Sum -ne $requirements.rc4_import_padding.negative_inputs){throw 'GETIMPORT active-index/count negatives changed.'}
if($padding.negative_rejection_checks -ne $requirements.rc4_import_padding.negative_inputs -or $padding.distinct_negative_inputs -ne $requirements.rc4_import_padding.distinct_negative_inputs){throw 'GETIMPORT negative check/buffer identities were conflated.'}
Assert-RequiredIdentities @() @($padding.rows|ForEach-Object{$_.negative_inputs.input_sha256}) 'GETIMPORT distinct negative buffers'
foreach($row in $padding.rows){
    if(($row.path_lengths -join ',') -cne '1,2,3'){throw 'GETIMPORT path-length instruction coverage is incomplete.'}
    foreach($negative in $row.negative_inputs){if($negative.executed -or -not $negative.error -or $negative.input_sha256 -cnotmatch '^[0-9a-f]{64}$' -or $negative.kind -notin @('active_index','path_count')){throw 'Invalid GETIMPORT path mutation was accepted or executed.'}}
}
$snapshot=Read-FreshEvidence 'docs/results/types-rc-snapshot.json'
if($snapshot.cases -ne 16 -or -not $snapshot.all_strict_passed -or $snapshot.structural_behavior_comparisons -ne 16 -or $snapshot.native_engine_behavior_comparisons -ne 0){throw 'PlayerSnapshot required positive matrix is incomplete or misclassified.'}
Assert-RequiredIdentities $requirements.snapshot_case_ids $snapshot.results.id 'PlayerSnapshot cases'
$contracts=Read-FreshEvidence 'docs/results/types-rc-contracts.json'
if($contracts.cases -ne 2 -or @($contracts.results|Where-Object{$_.validation.required_passed -or $_.validation.syntax -ne 'passed' -or $_.validation.compilation -ne 'passed'}).Count -ne 0){throw 'Authoritative function contracts were omitted or counted as verified success.'}
Assert-RequiredIdentities @('explicit_binding_contract_checked','recovery_cannot_report_verified_success_after_discarding_contract') $contracts.results.id 'Authoritative function contract cases'
if(@($contracts.results|Where-Object{$_.id -eq 'explicit_binding_contract_checked' -and $_.validation.strict_analysis -ne 'failed'}).Count -ne 0){throw 'Conflicting explicit function contract escaped strict checking.'}
$scale=Read-FreshEvidence 'docs/results/scale-quality-rc.json'
if(-not $scale.passed -or $scale.supplied_number_parameter_contracts -ne 512 -or $scale.unresolved_context.required_passed -or $scale.unresolved_context.strict_analysis -ne 'failed' -or -not $scale.validation.required_passed -or -not $scale.validation.meaningful_typing.passed -or $scale.typed_comparisons.Count -ne 3 -or @($scale.typed_comparisons|Where-Object{-not $_.verified -or -not $_.expected.complete -or -not $_.actual.complete}).Count -ne 0){throw 'Large generated-module quality/context/behavior contract is incomplete.'}
$typed=Read-FreshEvidence 'docs/results/types-rc-behavior.json'
if(-not $typed.all_verified -or $typed.cases -ne 48 -or $typed.typed_comparisons -ne 144 -or $typed.oracle_protocol -ne 'LOBS/1'){throw 'Candidate inference/constructor behavior matrix is incomplete.'}
Assert-RequiredIdentities @('array_constructor','scalar_packs','transitive_alias') $typed.families 'Candidate inference families'
$typedIds=@(foreach($family in @('array_constructor','scalar_packs','transitive_alias')){foreach($version in @(6,14)){foreach($o in @(0,2)){foreach($d in @(0,2)){foreach($t in @(0,1)){'{0}/v{1}/O{2}/D{3}/T{4}' -f $family,$version,$o,$d,$t}}}}})
Assert-RequiredIdentities $typedIds $typed.results.id 'Candidate inference cases'
foreach($case in $typed.results){if(-not $case.verified -or -not $case.complete -or $case.inputs.Count -ne 3 -or @($case.inputs|Where-Object{-not $_.verified -or -not $_.expected.complete -or -not $_.actual.complete}).Count -ne 0){throw ('Incomplete candidate inference observation: '+$case.id)}}
foreach($case in $snapshot.results){
    if(-not $case.verified -or -not $case.behavior.verified -or -not $case.validation.required_passed -or -not $case.validation.meaningful_typing.passed -or $case.validation.strict_analysis -ne 'passed' -or $case.validation.analyzer_sha256 -cne $tools.analyzer_sha256 -or $case.validation.definitions_sha256 -cne $tools.definitions_sha256 -or $case.external_contract.type -ne 'Player'){throw ('Unverified PlayerSnapshot case: '+$case.id)}
}
$entry=Read-FreshEvidence 'docs/results/types-rc-function-entry.json'
if($entry.cases -ne 2 -or -not $entry.all_passed -or @($entry.results|Where-Object{-not $_.verified -or $_.native_dump}).Count -ne 0){throw 'Function-entry evidence is incomplete or confused with native getter evidence.'}
Assert-RequiredIdentities @('fixed','vararg') $entry.results.id 'Function entry cases'
function Assert-ExampleHash([string]$Path,[string]$Expected,[string]$Label){
    if($Expected -cnotmatch '^[0-9a-f]{64}$' -or -not(Test-Path -LiteralPath $Path -PathType Leaf) -or (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Expected){throw ('Example identity mismatch: '+$Label)}
}
$exampleManifestPath=$requirements.example_manifest
if($exampleManifestPath -cne 'examples/typed-output/manifest-rc.json' -or -not(Test-Path -LiteralPath $exampleManifestPath -PathType Leaf)){throw 'Required final example manifest is missing.'}
$examples=Get-Content -LiteralPath $exampleManifestPath -Raw|ConvertFrom-Json
if($examples.schema -ne 1 -or $examples.version -cne $requirements.version -or $examples.examples.Count -ne $requirements.examples.Count){throw 'Final example manifest schema/version/case count is incomplete.'}
Assert-RequiredIdentities $requirements.examples.id $examples.examples.id 'Final generated examples'
Assert-ExampleHash 'target/release/luau-decompile.exe' $examples.executable_sha256 'final release executable'
Assert-ExampleHash 'scripts/generate-examples-rc.ps1' $examples.generator_sha256 'example generator'
Assert-ExampleHash '.tools/luau-modern/luau-compile.exe' $examples.compiler_sha256 'pinned example compiler'
foreach($case in $examples.examples){
    $expected=@($requirements.examples|Where-Object{$_.id -ceq $case.id})
    if($expected.Count -ne 1 -or $case.known_source -cne $expected[0].known_source -or $case.input_kind -cne $expected[0].input_kind -or $case.configuration -cne ($case.id+'.config.json') -or $case.output -cne ($case.id+'.luau')){throw ('Example source/configuration/output paths differ from required identities: '+$case.id)}
    $configPath=Join-Path 'examples/typed-output' $case.configuration
    $outputPath=Join-Path 'examples/typed-output' $case.output
    Assert-ExampleHash $case.known_source $case.known_source_sha256 ($case.id+' known source')
    Assert-ExampleHash $configPath $case.configuration_sha256 ($case.id+' configuration')
    Assert-ExampleHash $outputPath $case.output_sha256 ($case.id+' emitted output')
    $inputPath=if($expected[0].retained_bytecode){$expected[0].retained_bytecode}elseif($case.input_kind -ceq 'source'){$case.known_source}else{Join-Path 'artifacts/examples-rc' ($case.id+'.bc')}
    Assert-ExampleHash $inputPath $case.input_sha256 ($case.id+' original input')
    $configuration=Get-Content -LiteralPath $configPath -Raw|ConvertFrom-Json
    $format=if($case.input_kind -ceq 'source'){'luau_source'}else{'luau_bytecode'}
    if($configuration.output_policy -cne 'verified_typed' -or $configuration.input_format -cne $format -or $configuration.naming -cne 'camelCase'){throw ('Example configuration is not its declared verified input policy: '+$case.id)}
    if(-not $case.validation.required_passed -or -not $case.validation.meaningful_typing.passed -or $case.validation.output_policy -cne 'verified_typed' -or $case.validation.syntax -cne 'passed' -or $case.validation.compilation -cne 'passed' -or $case.validation.strict_analysis -cne 'passed' -or $case.validation.analyzer_sha256 -cne $tools.analyzer_sha256 -or $case.validation.definitions_sha256 -cne $tools.definitions_sha256){throw ('Final example quality/tool provenance is incomplete: '+$case.id)}
    $validated=@($case.validation.attempts|Where-Object{$_.source_sha256 -ceq $case.output_sha256 -and $_.syntax -ceq 'passed' -and $_.compilation -ceq 'passed' -and $_.strict_analysis -ceq 'passed'})
    if($validated.Count -ne 1 -or $case.behavior -cne 'not_run_by_example_generator; independent controlled release matrices are separate'){throw ('Example final-source validation identity or behavioral scope is incorrect: '+$case.id)}
}
$currentLivePath='docs/results/madium-live-rc2.json'
if(Test-Path -LiteralPath $currentLivePath){
    $live=Get-Content -LiteralPath $currentLivePath -Raw|ConvertFrom-Json
    if($live.schema -ne 1 -or $live.version -cne '0.4.0-rc.2'){throw 'Historical rc.2 live report identity changed.'}
    $rc2ArchivedSources=Assert-Rc2LiveSources $live
    if($live.archive_path -cne 'evidence/releases/0.4.0-rc.2-live.zip' -or $live.archive_manifest -cne 'evidence/releases/0.4.0-rc.2-live-manifest.json' -or (Get-FileHash $live.archive_path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $live.archive_sha256 -or (Get-FileHash $live.archive_manifest -Algorithm SHA256).Hash.ToLowerInvariant() -cne $live.archive_manifest_sha256){throw 'Current live archive identities differ from its report.'}
    $liveManifest=Get-Content -LiteralPath $live.archive_manifest -Raw|ConvertFrom-Json
    if($liveManifest.archive_sha256 -cne $live.archive_sha256 -or $liveManifest.files.Count -ne 20){throw 'Current live entry manifest is incomplete.'}
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $liveArchive=[IO.Compression.ZipFile]::OpenRead((Join-Path $taskRoot $live.archive_path))
    try{
        if($liveArchive.Entries.Count -ne $liveManifest.files.Count){throw 'Current live archive entry count differs.'}
        Assert-RequiredIdentities $liveArchive.Entries.FullName $liveManifest.files.path 'Current live archive entries'
        foreach($entry in $liveManifest.files){
            if($entry.path -cnotmatch '^[a-z0-9][a-z0-9._-]+$' -or $entry.bytes -gt 4194304 -or $entry.bytes -lt 0){throw 'Unbounded current live entry.'}
            $stored=$liveArchive.GetEntry($entry.path)
            if(-not $stored -or $stored.Length -ne $entry.bytes){throw 'Current live archive entry is absent or truncated.'}
            $stream=$stored.Open();$algorithm=[Security.Cryptography.SHA256]::Create()
            try{$actual=([BitConverter]::ToString($algorithm.ComputeHash($stream))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose();$stream.Dispose()}
            if($actual -cne $entry.sha256){throw 'Current live observation entry was changed.'}
        }
    }finally{$liveArchive.Dispose()}
    if($live.status -ceq 'passed_with_scope_limitations'){
        $accepted=@($live.results|Where-Object{$_.accepted})
        if($accepted.Count -ne 5 -or ($accepted|Measure-Object behavioral_pairs -Sum).Sum -ne 21 -or $live.distinct_known_source_normal_engine_script_programs -ne 0 -or $live.native_calling_convention.script_round_trip -cne 'not_run' -or -not $live.cleanup.original_decompile_restored -or -not $live.cleanup.adapter_registry_cleared -or -not $live.cleanup.host_process_stopped){throw 'Current live evidence scope or cleanup was overstated.'}
        foreach($row in $accepted){if(-not $row.complete -or -not $row.recompiled){throw 'Incomplete live reconstruction was counted as success.'}}
    }
}
$independentExecutorEvidence=Assert-IndependentExecutorEvidence
$independentEvidenceDirectory=Join-Path $taskRoot 'artifacts/external-evidence-rc'
New-Item -ItemType Directory -Force -Path $independentEvidenceDirectory|Out-Null
[IO.File]::WriteAllText((Join-Path $independentEvidenceDirectory 'provenance.json'),($independentExecutorEvidence|ConvertTo-Json -Depth 12),[Text.UTF8Encoding]::new($false))
if($rc2ArchivedSources){[IO.File]::WriteAllText((Join-Path $independentEvidenceDirectory 'rc2-sources.json'),($rc2ArchivedSources|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))}
Write-Output 'Candidate source, meaningful typing, snapshot, function-entry and independent external evidence identities passed.'
