param(
    [string]$Directory=(Join-Path $PSScriptRoot '../artifacts/madium-live-v3'),
    [string]$Destination=(Join-Path $PSScriptRoot '../docs/results/madium-live-v3.json')
)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$Directory=(Resolve-Path -LiteralPath $Directory).Path
$capturePath=Join-Path $Directory 'initial-sandbox-timeout.json'
$planPath=Join-Path $Directory 'driver.luau.manifest.json'
$launchPath=Join-Path $Directory 'launch-manifest.json'
$hostProbePath=Join-Path $Directory 'host-probe.json'
$capture=Get-Content -LiteralPath $capturePath -Raw|ConvertFrom-Json
$plan=Get-Content -LiteralPath $planPath -Raw|ConvertFrom-Json
$launch=Get-Content -LiteralPath $launchPath -Raw|ConvertFrom-Json
$hostProbe=Get-Content -LiteralPath $hostProbePath -Raw|ConvertFrom-Json
$modelPath=Join-Path $taskRoot 'docs/results/native-v3-model.json'
$model=Get-Content -LiteralPath $modelPath -Raw|ConvertFrom-Json
if($capture.ok -or $capture.schema -ne 3 -or $capture.validation_id -cne $plan.validation_id -or $capture.comparisons.Count -ne 0 -or $capture.settings_comparisons.Count -ne 0 -or $capture.error.stage -ne 'deadline'){throw 'This recorder requires the actual zero-observation v0.3 deadline capture, not successful or substituted evidence.'}
if(-not $capture.raw_restored -or -not $capture.registry_cleared -or -not $capture.oracle_conformance.passed -or $capture.oracle_conformance.negative_collision_pairs -ne 7 -or $capture.oracle_conformance.unsupported_observations_rejected -ne 3){throw 'Failure cleanup/oracle evidence differs from the captured attempt.'}
foreach($id in @('numeric_second_argument','native_options_table','function_target','raw_native_target')){if(-not $capture.native_api.$id.rejected){throw ('Missing actual native-API rejection: '+$id)}}
foreach($item in @(@{path='adapter/decompile.luau';sha256=$plan.adapter_sha256},@{path='adapter/live-test-v3.luau';sha256=$plan.harness_sha256})){if((Get-FileHash -LiteralPath (Join-Path $taskRoot $item.path) -Algorithm SHA256).Hash.ToLowerInvariant() -cne $item.sha256){throw 'Live source changed after the failed captured run.'}}
if($launch.executable_sha256 -cne $hostProbe.executable_sha256 -or $hostProbe.package_version -ne '0.3.0' -or $hostProbe.status -ne 200 -or $hostProbe.endpoint -cne $launch.endpoint){throw 'Host capabilities/launch evidence mismatch.'}
$report=[ordered]@{
    schema=3;version='0.3.0';passed=$false;status='failed_transport_unavailable_in_this_test_context';recorded_at_utc=[DateTime]::UtcNow.ToString('o')
    executor=$capture.executor;runtime=$capture.runtime;client_pid_operator_record=14180;platform='windows';executor_architecture='not independently recorded';service_binary_architecture='Windows x64'
    service_binary_sha256=$launch.executable_sha256;service_binary_evidence='Host launch hash and matching authenticated package-version probe; operator record, not remote process-image attestation.'
    verified_typed_comparisons=0;distinct_known_source_native_programs_verified=0;distinct_unknown_source_native_models_behaviorally_verified=0;distinct_supplied_bytecode_programs_verified=0;controlled_place_native_programs_verified=0
    requested_plan=@{unknown_source_native_models=1;native_model_observations=33;supplied_programs=4;supplied_observations=20;settings_observations=5;total_behavioral_comparisons=58;warm_timing_repetitions=32;validation_id=$plan.validation_id;full_harness_endpoint=$plan.endpoint}
    completed_checks=@{native_api_rejections=$capture.native_api;oracle_conformance=$capture.oracle_conformance;raw_restored=$capture.raw_restored;registry_cleared=$capture.registry_cleared;out_of_order_restoration='not_reached in this live attempt; separately tested in host mocks';malformed_diagnostic='not_reached';per_request_settings_behavior='not_reached'}
    full_harness_attempt=@{status='failed';error=$capture.error;endpoint=$plan.endpoint;capture_path='artifacts/madium-live-v3/initial-sandbox-timeout.json';capture_sha256=(Get-FileHash -LiteralPath $capturePath -Algorithm SHA256).Hash.ToLowerInvariant();capture=$capture;fixture_plan=$plan;fixture_plan_sha256=(Get-FileHash -LiteralPath $planPath -Algorithm SHA256).Hash.ToLowerInvariant()}
    native_getter_and_model=@{status='exact packet guard/getscriptclosure reached before transport by recorded harness control flow; no completed reconstructed-source comparison';path='ReplicatedStorage.SocketTypes';native_hex=$model.native_hex;native_sha256=$model.native_sha256;bytes=47;encoding='explicit roblox_opcode227';profile='luau-v14';original_source='unknown';independent_semantic_matches=$model.semantic_matches;independent_complete_packet_matches=$model.complete_packet_matches;model_report_sha256=(Get-FileHash -LiteralPath $modelPath -Algorithm SHA256).Hash.ToLowerInvariant();model_is_not_original_source_provenance=$true}
    host_probe=$hostProbe;host_probe_sha256=(Get-FileHash -LiteralPath $hostProbePath -Algorithm SHA256).Hash.ToLowerInvariant();host_launch_attestation=$launch;host_launch_attestation_sha256=(Get-FileHash -LiteralPath $launchPath -Algorithm SHA256).Hash.ToLowerInvariant()
    transport_diagnosis=@{provenance='Bounded operator-recorded Madium MCP probes; host probe artifact retained separately';native_request_with_timeout='No completion within8seconds';native_request_without_timeout='No completion within10seconds';final_uncaptured_native_request='Still done=false after approximately1minute; no response';http_service_request_async='Immediately rejected with blocked Instance member in this Madium MCP context';outside_sandbox_service='Same failure with host-launched service; sandbox causality is not established';service_cpu_operator_observation='Approximately0.015seconds CPU and no observed executor HTTP traffic';cause='unknown';successful_executor_http_responses=0}
    latency=@{status='not_measured; no completed adapter round trip';successful_samples=0;timeout_is_not_a_success_latency_sample=$true;configured_service_cache_mib=64}
    source_validation=@{reconstruction='not_completed';syntax='not_run';compilation='not_run';strict_analysis='not_run';typed_behavior='not_run; zero pairs'}
    cleanup=@{operator_verified_owned_service_pids_stopped=@(3472,20900);process_paths_verified_before_stop=$true;temporary_auth_removed_from_session=$true;client_capture_and_probe_keys_removed=$true;adapter_registry_cleared=$true;native_http_tasks='No cancellation handle supplied by executor API; blocked native tasks may outlive wrapper timeout. Termination of all native threads is not claimed.'}
    limitations=@('No v0.3 native or supplied-bytecode end-to-end compatibility success is established.','The getter/model and argument/oracle/cleanup checks are separate partial evidence, not completed reconstruction.','The controlled14-program place is absent; known-source normal-engine native extraction remains not run.','Historical v0.2 success is preserved separately and does not certify this v0.3 attempt.','Failure cause remains unknown; no Rust change or sandbox attribution is justified by these probes.')
    recorder_sha256=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
[IO.File]::WriteAllText($Destination,($report|ConvertTo-Json -Depth 20),[Text.UTF8Encoding]::new($false))
Write-Output 'Recorded actual v0.3 live transport failure: zero verified pairs/native/supplied programs; partial API/oracle/cleanup evidence kept separate.'
