param(
    [Parameter(Mandatory=$true)][string]$Capture,
    [string]$Fixtures=(Join-Path $PSScriptRoot '../fixtures/roblox-v3'),
    [string]$Destination=(Join-Path $PSScriptRoot '../artifacts/native-v3/verified-report.json')
)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$comparator=Join-Path $taskRoot 'target/release/examples/oracle_compare.exe'
if(-not(Test-Path -LiteralPath $comparator)){throw 'Build cargo build --release --offline --example oracle_compare first.'}
$manifest=Get-Content -LiteralPath (Join-Path $Fixtures 'manifest.json') -Raw|ConvertFrom-Json
$report=Get-Content -LiteralPath $Capture -Raw|ConvertFrom-Json
$errors=[Collections.Generic.List[string]]::new();$rows=[Collections.Generic.List[object]]::new()
if($report.fixture_package -cne $manifest.fixture_package -or $report.fixture_plan_sha256 -cne $manifest.fixture_plan_sha256){$errors.Add('Prepared fixture package/hash differs.')}
if($report.actual_place_id -ne $report.expected_place_id -or $report.actual_place_id -le 0){$errors.Add('Controlled published PlaceId was not verified.')}
if(-not $report.original_function_restored -or -not $report.registry_restored){$errors.Add('Adapter restoration/ambient registry restoration failed.')}
if($report.oracle_protocol -cne 'LOBS/1' -or $report.supplied_bytecode_fixtures -ne 0 -or $report.timing_repetitions -ne 0){$errors.Add('Native, supplied-input and repeated-timing denominators are not separated.')}
$temporary=Join-Path $taskRoot ('artifacts/native-v3/verify-'+[Guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Force -Path $temporary|Out-Null
$seen=@{};$matched=0;$verifiedPrograms=0;$binaryHashes=[Collections.Generic.List[string]]::new()
foreach($case in $report.cases){
    $failures=[Collections.Generic.List[string]]::new();$expected=@($manifest.cases|Where-Object{$_.id -ceq $case.id})
    if($case.id -notmatch '^[A-Za-z][A-Za-z0-9_]{0,63}$'){$errors.Add('Invalid program identity; no observation paths created.');continue}
    if($seen.ContainsKey($case.id)){$failures.Add('Duplicate program identity.')}else{$seen[$case.id]=$true}
    if($expected.Count -ne 1){$failures.Add('Program absent from explicit fixture catalog.')}else{
        $expected=$expected[0];$source=Join-Path $Fixtures $expected.source_file
        if((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -cne $expected.source_sha256 -or $case.expected_source_sha256 -cne $expected.source_sha256){$failures.Add('Known-source fixture provenance changed.')}
        if($case.class -cne $expected.class -or $case.probe -cne $expected.probe){$failures.Add('Fixture class/probe does not match the pinned plan.')}
    }
    if($case.status -cne 'verified' -or -not $case.reconstruction_complete){$failures.Add('Native extraction/reconstruction/probe incomplete.')}
    $inputHash=$null
    try{$bytes=[Convert]::FromBase64String($case.native_bytecode_base64);if($bytes.Length -ne $case.native_bytecode_bytes -or $bytes.Length -le 0 -or [Convert]::ToBase64String($bytes) -cne $case.native_bytecode_base64){throw 'Native byte framing incomplete.'};$inputHash=([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($bytes))).Replace('-','').ToLowerInvariant();$binaryHashes.Add($inputHash)}catch{$failures.Add($_.Exception.Message)}
    $seeds=@{};$programComparisons=0
    foreach($comparison in $case.comparisons){
        $key=[string]$comparison.seed;if($seeds.ContainsKey($key)){$failures.Add('Duplicate runtime input.');continue};$seeds[$key]=$true
        if($comparison.seed -notin @(-3,0,7)){$failures.Add('Unexpected runtime input.');continue}
        try{
            $a=[Convert]::FromBase64String($comparison.expected_base64);$b=[Convert]::FromBase64String($comparison.actual_base64)
            if([Convert]::ToBase64String($a) -cne $comparison.expected_base64 -or [Convert]::ToBase64String($b) -cne $comparison.actual_base64){throw 'Noncanonical binary observation.'}
            $original=Join-Path $temporary ($case.id+'-'+$key+'.original.obs');$actual=Join-Path $temporary ($case.id+'-'+$key+'.actual.obs');[IO.File]::WriteAllBytes($original,$a);[IO.File]::WriteAllBytes($actual,$b)
            $decoded=(& $comparator $original $actual|ConvertFrom-Json)
            if($LASTEXITCODE -ne 0 -or -not $decoded.matched -or -not $comparison.matched){throw 'Typed observation mismatch/incomplete frame.'}
            $programComparisons+=1;$matched+=1
        }catch{$failures.Add($_.Exception.Message)}
    }
    if($programComparisons -ne 3){$failures.Add('Required three-input probe is incomplete.')}
    if($failures.Count -eq 0){$verifiedPrograms+=1}else{foreach($failure in $failures){$errors.Add($case.id+': '+$failure)}}
    $rows.Add([ordered]@{id=$case.id;complete=($failures.Count -eq 0);native_bytecode_sha256=$inputHash;comparisons_verified=$programComparisons;diagnostics=$failures.ToArray()})
}
foreach($case in $manifest.cases){if(-not $seen.ContainsKey($case.id)){$errors.Add('Missing native program: '+$case.id)}}
if($verifiedPrograms -ne 14 -or $matched -ne 42 -or -not $report.completed){$errors.Add('Complete controlled-native denominator was not satisfied.')}
$verified=[ordered]@{schema=1;passed=($errors.Count -eq 0);oracle_protocol='LOBS/1';distinct_native_programs_verified=$verifiedPrograms;required_distinct_native_programs=14;distinct_native_bytecode_hashes=@($binaryHashes|Select-Object -Unique).Count;typed_comparisons_verified=$matched;required_typed_comparisons=42;supplied_bytecode_fixtures=0;timing_repetitions=0;runtime=$report.runtime;executor=$report.executor;platform=$report.platform;architecture=$report.architecture;architecture_evidence=$report.architecture_evidence;place_id=$report.actual_place_id;capture_sha256=(Get-FileHash -LiteralPath $Capture -Algorithm SHA256).Hash.ToLowerInvariant();manifest_sha256=(Get-FileHash -LiteralPath (Join-Path $Fixtures 'manifest.json') -Algorithm SHA256).Hash.ToLowerInvariant();source_provenance='Controlled fixture XML/manifest and operator-controlled normal-engine publication; raw native bytes retained separately. No claim that inaccessible native Source text was extracted.';diagnostics=$errors.ToArray();results=$rows.ToArray()}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination)|Out-Null
[IO.File]::WriteAllText($Destination,($verified|ConvertTo-Json -Depth 12),[Text.UTF8Encoding]::new($false))
if($errors.Count){throw ('Controlled native verification failed; retained full report: '+$Destination)}
Write-Output ('Verified14 distinct native programs/42 typed observations: '+$Destination)
