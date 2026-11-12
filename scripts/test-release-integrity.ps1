$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'release-integrity.ps1')
$cases=[Collections.Generic.List[object]]::new()
function Check-Rejection([string]$Id,$Actual) {
    $rejected=$false
    try {Assert-RequiredIdentities @('required-A','required-B') $Actual $Id} catch {$rejected=$true}
    if(-not $rejected){throw ('Release identity guard accepted invalid evidence: '+$Id)}
    $cases.Add(@{id=$Id;passed=$true})
}
Assert-RequiredIdentities @('required-A','required-B') @('required-A','required-B') 'complete'
$cases.Add(@{id='complete_required_set';passed=$true})
Assert-RequiredIdentities @('required-A','required-B') @('additional-C','required-B','required-A') 'additional'
$cases.Add(@{id='additional_coverage_and_order_independence';passed=$true})
Check-Rejection 'missing_required_case' @('required-A')
Check-Rejection 'duplicate_cannot_replace_missing' @('required-A','required-A')
Check-Rejection 'duplicate_even_when_complete' @('required-A','required-B','required-A')
Check-Rejection 'case_sensitive_identity' @('required-A','required-b')
Check-Rejection 'empty_identity' @('required-A','required-B','')
$inputFiles=@([ordered]@{path='src/core.rs';sha256='code'},[ordered]@{path='fixtures/config.json';sha256='configuration'},[ordered]@{path='scripts/check.ps1';sha256='command'},[ordered]@{path='README.md';sha256='old-prose'})
$semantic=@(Get-SemanticInputFiles $inputFiles)
$changedProse=@($inputFiles[0],$inputFiles[1],$inputFiles[2],[ordered]@{path='README.md';sha256='new-prose'})
Assert-SemanticSnapshot $semantic $changedProse
$cases.Add(@{id='prose_only_changes_reuse_matching_semantics';passed=$true})
$browserOnly=@([ordered]@{path='web/app/page.tsx';sha256='presentation'},[ordered]@{path='web/lib/worker.ts';sha256='browser'},[ordered]@{path='scripts/test-browser.mjs';sha256='browser-boundary'},[ordered]@{path='.github/workflows/pages.yml';sha256='static-deployment'})
Assert-SemanticSnapshot $semantic @($inputFiles+$browserOnly)
if(@(Get-SemanticInputFiles @($inputFiles+[ordered]@{path='src/wasm_api.rs';sha256='shared-engine-boundary'})).Count -ne $semantic.Count+1){throw 'Shared Rust platform boundary was excluded from native identities'}
$cases.Add(@{id='browser_only_changes_have_an_independent_gate_owner';passed=$true})
$unordered=@([ordered]@{path='z.rs';sha256='z'},[ordered]@{path='A.rs';sha256='A'},[ordered]@{path='a.rs';sha256='a'},[ordered]@{path='m.rs';sha256='m'})
$ordered=@(Get-OrderedSourceFiles $unordered)
if(($ordered.path -join ',') -cne 'A.rs,a.rs,m.rs,z.rs'){throw 'Source dictionaries were not sorted by ordinal path keys'}
Assert-SemanticSnapshot $unordered @($unordered[3],$unordered[2],$unordered[1],$unordered[0])
$cases.Add(@{id='source_dictionary_order_is_ordinal_and_enumeration_independent';passed=$true})
$duplicateRejected=$false;try{Get-OrderedSourceFiles @($unordered[0],$unordered[0])|Out-Null}catch{$duplicateRejected=$true}
if(-not $duplicateRejected){throw 'Duplicate source paths were accepted'}
$cases.Add(@{id='duplicate_source_paths_are_rejected';passed=$true})

foreach($index in @(0,1,2)){
    $changed=@($inputFiles|ForEach-Object{[ordered]@{path=$_.path;sha256=$_.sha256}})
    $changed[$index].sha256='changed'
    $rejected=$false;try{Assert-SemanticSnapshot $semantic $changed}catch{$rejected=$true}
    if(-not $rejected){throw ('Semantic reuse accepted a changed input: '+$changed[$index].path)}
    $cases.Add(@{id=('semantic_reuse_rejects_'+@('code','configuration','command')[$index]);passed=$true})
}
$report=@{schema=1;passed=$true;cases=$cases.Count;results=$cases.ToArray();requirements_sha256=(Get-FileHash -LiteralPath (Join-Path $taskRoot 'tests/release-requirements-v3.json') -Algorithm SHA256).Hash.ToLowerInvariant();guard_sha256=(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'release-integrity.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()}
[IO.File]::WriteAllText((Join-Path $taskRoot 'docs/results/release-integrity-v3.json'),($report|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
Write-Output ('Release identity guard: '+$cases.Count+'/'+$cases.Count+' passed.')
