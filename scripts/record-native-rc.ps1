param([string]$Directory=(Join-Path $PSScriptRoot '../artifacts/rc-native-functions'),[switch]$Reconstruct)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$utf8=[Text.UTF8Encoding]::new($false)
$binary=Join-Path $root 'target/release/luau-decompile.exe'
if($Reconstruct){
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
    $configPath=Join-Path $Directory 'config.json'
    if(-not (Test-Path -LiteralPath $configPath)){[IO.File]::WriteAllText($configPath,'{"output_policy":"faithful","entry_output":"function","bytecode_encoding":"roblox_opcode227","validation":{"mode":"off"}}',$utf8)}
}
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function TextHash([string]$Value){$algorithm=[Security.Cryptography.SHA256]::Create();try{([BitConverter]::ToString($algorithm.ComputeHash($utf8.GetBytes($Value)))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}}
$fixture=Get-Content -LiteralPath (Join-Path $root 'tests/function-dumps-rc.json') -Raw | ConvertFrom-Json
$rows=@()
foreach($case in $fixture.cases){
    if(-not $case.ok -or $case.kind -ne 'string'){throw 'Native fixture does not contain a captured byte string'}
    $inputPath=Join-Path $Directory ($case.id+'.bc')
    $sourcePath=Join-Path $Directory ($case.id+'.luau')
    $bytes=New-Object byte[] ($case.hex.Length/2)
    for($index=0;$index -lt $bytes.Length;$index++){$bytes[$index]=[Convert]::ToByte($case.hex.Substring($index*2,2),16)}
    if($Reconstruct){
        [IO.File]::WriteAllBytes($inputPath,$bytes)
        $start=[Diagnostics.ProcessStartInfo]::new($binary)
        $start.Arguments='decompile "'+$inputPath+'" --config "'+(Join-Path $Directory 'config.json')+'" -o "'+$sourcePath+'" --force'
        $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardError=$true;$start.RedirectStandardOutput=$true
        $child=[Diagnostics.Process]::Start($start);$errors=$child.StandardError.ReadToEndAsync();$output=$child.StandardOutput.ReadToEndAsync()
        try{if(-not $child.WaitForExit(10000)){$child.Kill();$child.WaitForExit();throw 'Native fixture CLI deadline exceeded'}
            [IO.File]::WriteAllText((Join-Path $Directory ($case.id+'.stderr')),$errors.Result,$utf8)
            $expected=if($case.id -eq 'captured'){1}else{0}
            if($child.ExitCode -ne $expected){throw ('Unexpected native fixture CLI status: '+$case.id)}
            if($expected -eq 1 -and $errors.Result -notmatch 'live upvalue values are absent'){throw 'Missing capture diagnostic was not preserved'}
        }finally{$child.Dispose()}
    }
    $actual=[IO.File]::ReadAllBytes($inputPath)
    if([Convert]::ToBase64String($actual) -cne [Convert]::ToBase64String($bytes)){throw 'Native packet bytes changed'}
    $row=[ordered]@{id=$case.id;known_source_sha256=(TextHash $case.source);packet_sha256=(Hash $inputPath);input_bytes=$bytes.Length;captured_upvalues_absent=($case.id -eq 'captured');cli_exit=if($case.id -eq 'captured'){1}else{0};output_sha256=if($case.id -ne 'captured'){Hash $sourcePath}else{$null};diagnostic_sha256=(Hash (Join-Path $Directory ($case.id+'.stderr')))}
    $rows+=$row
}
if($Reconstruct){
    [IO.File]::WriteAllText((Join-Path $Directory 'host-reconstruction.json'),([ordered]@{executable_sha256=(Hash $binary);fixture_sha256=(Hash (Join-Path $root 'tests/function-dumps-rc.json'));configuration_sha256=(Hash (Join-Path $Directory 'config.json'));results=$rows}|ConvertTo-Json -Depth 12),$utf8)
    Write-Output 'Native fixture CLI reconstruction recorded; live observations must be obtained separately.'
    exit
}
$hostReport=Get-Content -LiteralPath (Join-Path $Directory 'host-reconstruction.json') -Raw | ConvertFrom-Json
if($hostReport.executable_sha256 -cne (Hash $binary) -or ($hostReport.results|ConvertTo-Json -Depth 12 -Compress) -cne ($rows|ConvertTo-Json -Depth 12 -Compress)){throw 'Native host reconstruction identities changed'}
$native=Get-Content -LiteralPath (Join-Path $Directory 'native-result.json') -Raw | ConvertFrom-Json
if($native.comparisons -ne 20 -or -not $native.oracle.passed){throw 'Native behavioral observations are incomplete'}
foreach($row in $rows){
    $matches=@($native.cases.PSObject.Properties.Value|Where-Object{$_.id -eq $row.id})
    if($matches.Count -ne 1){throw 'Native case identity is missing or duplicated'}
    $observation=$matches[0]
    if($row.id -eq 'captured'){if(-not $observation.rejected -or $observation.verified){throw 'Missing capture must remain rejected'}}
    elseif(-not $observation.verified -or @($observation.inputs.PSObject.Properties).Count -ne 5 -or @($observation.inputs.PSObject.Properties.Value|Where-Object{-not $_.verified -or $_.expected_hex -cne $_.actual_hex}).Count -ne 0){throw 'Native function observations differ'}
}
$report=[ordered]@{schema=1;date=$fixture.observed_date;version='0.4.0-rc.1';executor=$fixture.executor;executor_build=$fixture.executor_build;roblox_build=$fixture.roblox_build;platform=$fixture.platform;architecture=$fixture.architecture;compiler_path=$fixture.compiler_path;transport=$native.transport;native_http_adapter_success=$false;distinct_accepted_programs=4;expected_rejections=1;runtime_observation_pairs=20;oracle_protocol='LOBS/1';executable_sha256=$hostReport.executable_sha256;fixture_sha256=$hostReport.fixture_sha256;configuration_sha256=$hostReport.configuration_sha256;adapter_sha256=(Hash (Join-Path $root 'adapter/decompile.luau'));observer_sha256=(Hash (Join-Path $root 'adapter/live-test-v3.luau'));harness_sha256=(Hash (Join-Path $root 'adapter/function-dump-test-rc.luau'));driver_sha256=(Hash (Join-Path $Directory 'driver-final.luau'));generator_sha256=(Hash $PSCommandPath);cli_results=$rows;native_observations=$native;limitations=@('Manual MCP exchange is not an HTTP adapter round trip','Executor loadstring function dumps are not normal-engine ModuleScript or LocalScript extraction','No Roblox userdata or vectors were exercised by these four programs','Serialized function dumps omit live upvalue values; the capture case is rejected','Native observer negative tests cover seven collision pairs and three unsupported observations; full host oracle conformance is a separate gate')}
[IO.File]::WriteAllText((Join-Path $root 'docs/results/native-functions-rc.json'),($report|ConvertTo-Json -Depth 30),$utf8)
Write-Output 'Four native function programs and twenty typed observation pairs recorded; HTTP integration remains unverified.'
