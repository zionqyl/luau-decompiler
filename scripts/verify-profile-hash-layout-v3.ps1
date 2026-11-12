param([DateTime]$NotBefore=[DateTime]::MinValue)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'release-integrity.ps1')
$path=Join-Path $taskRoot 'docs/results/profile-hash-layout-v3.json'
if(-not(Test-Path -LiteralPath $path) -or (Get-Item -LiteralPath $path).LastWriteTimeUtc -lt $NotBefore){throw 'Required hash-layout regression evidence is missing or stale.'}
$report=Get-Content -LiteralPath $path -Raw|ConvertFrom-Json
$requirements=Get-Content -LiteralPath (Join-Path $taskRoot 'tests/release-requirements-v3.json') -Raw|ConvertFrom-Json
if($report.oracle_protocol -ne 'LOBS/1' -or $report.fixtures -ne $requirements.required_profile_hash_layout_fixtures -or $report.cases -ne $requirements.required_profile_hash_layout_cases -or $report.results.Count -ne $requirements.required_profile_hash_layout_cases -or $report.verified -ne $requirements.required_profile_hash_layout_cases -or $report.failed -ne 0 -or $report.observation_normalization -cne 'none; exact ordered typed effects and return tuples'){throw 'Hash-layout typed/physical regression evidence is incomplete.'}
Assert-RequiredIdentities $requirements.required_profile_hash_layout_modes $report.presentation_profiles 'Hash-layout presentation modes'
Assert-RequiredIdentities $requirements.required_profile_hash_layout_case_ids $report.results.case_id 'Hash-layout regression case IDs'
$manifest=Get-Content -LiteralPath (Join-Path $taskRoot 'tests/profile-fixtures/manifest.json') -Raw|ConvertFrom-Json
$fixtures=@($manifest.fixtures|Where-Object {$_.source -ceq 'hash_table_layout.luau'})
if($fixtures.Count -ne 72){throw 'Expected72 independently pinned modern hash-layout fixtures.'}
$byFixture=@{};foreach($fixture in $fixtures){$byFixture[$fixture.bytecode]=$fixture}
Assert-RequiredIdentities $fixtures.bytecode @($report.results.fixture|Select-Object -Unique) 'Hash-layout fixture identities'
$runners=@{}
foreach($row in $report.results){
    if(-not $byFixture.ContainsKey($row.fixture)){throw ('Unknown hash-layout fixture: '+$row.fixture)}
    $fixture=$byFixture[$row.fixture]
    if($row.case_id -cne ($row.fixture+'/'+$row.typing) -or $row.profile -cne $fixture.profile -or $row.compiler_sha256 -cne $fixture.compiler_sha256 -or -not $row.verified -or $row.syntax -ne 'passed' -or -not $row.original_observation.complete -or -not $row.rebuilt_observation.complete -or $row.original_observation.protocol -ne 'LOBS/1' -or $row.rebuilt_observation.protocol -ne 'LOBS/1'){throw ('Hash-layout result lost fixture/profile/compiler/complete-observation evidence: '+$row.case_id)}
    if($row.original_shape.opcode -cne 'NewTable' -or $row.original_shape.hash_hint -ne 4 -or $row.original_shape.array_hint -ne 0 -or $row.rebuilt_shape.opcode -cne $row.original_shape.opcode -or $row.rebuilt_shape.hash_hint -ne $row.original_shape.hash_hint -or $row.rebuilt_shape.array_hint -ne $row.original_shape.array_hint){throw ('Original NEWTABLE physical allocation shape changed: '+$row.case_id)}


    if(($row.original_observation|ConvertTo-Json -Depth 80 -Compress) -cne ($row.rebuilt_observation|ConvertTo-Json -Depth 80 -Compress)){throw ('Exact ordered typed observation changed: '+$row.case_id)}
    if(-not $runners.ContainsKey($fixture.upstream_tag)){
        $directory=switch($fixture.upstream_tag){'0.726'{'luau-0.726'}'0.730'{'luau-0.730'}'0.746'{'luau-modern'}default{throw 'Unpinned hash-layout compiler tag.'}}
        $runner=Join-Path $taskRoot ('.tools/'+$directory+'/vm-runner.exe')
        $runners[$fixture.upstream_tag]=(Get-FileHash -LiteralPath $runner -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    if($row.runner_sha256 -cne $runners[$fixture.upstream_tag]){throw ('Hash-layout oracle executable changed: '+$row.case_id)}
}
Write-Output 'Hash-layout gate passed:72 pinned fixtures/144 exact cases, both modes, original NEWTABLE shape and unsorted typed observations.'
