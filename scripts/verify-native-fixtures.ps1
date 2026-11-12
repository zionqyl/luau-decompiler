param([string]$Fixtures=(Join-Path $PSScriptRoot '../fixtures/roblox-v3'))
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$manifest=Get-Content -LiteralPath (Join-Path $Fixtures 'manifest.json') -Raw|ConvertFrom-Json
$xml=[Xml.XmlDocument]::new();$xml.Load((Join-Path $Fixtures 'controlled-place.rbxlx'))
if($manifest.distinct_native_programs_planned -ne 14 -or $manifest.cases.Count -ne 14){throw 'Explicit native fixture denominator changed.'}
if((Get-FileHash -LiteralPath (Join-Path $Fixtures 'controlled-place.rbxlx') -Algorithm SHA256).Hash.ToLowerInvariant() -cne $manifest.place_xml_sha256){throw 'Fixture place XML hash changed.'}
$compiler=(Resolve-Path -LiteralPath (Join-Path $taskRoot '.tools/luau-modern/luau-compile.exe')).Path
$lock=Get-Content -LiteralPath (Join-Path $taskRoot 'upstream.profiles.lock.json') -Raw|ConvertFrom-Json
$pin=@($lock.profiles|Where-Object{$_.tag -eq '0.746'})[0]
$compilerHash=(Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash.ToLowerInvariant()
if($compilerHash -cne $pin.windows_compiler_sha256){throw 'Host fixture compiler is not the pinned official compiler.'}
$output=Join-Path $taskRoot 'artifacts/native-v3-host-compile';New-Item -ItemType Directory -Force -Path $output|Out-Null
$rows=[Collections.Generic.List[object]]::new();$seen=@{}
foreach($case in $manifest.cases){
    if($case.id -notmatch '^[A-Za-z][A-Za-z0-9_]{0,63}$' -or $seen.ContainsKey($case.id)){throw 'Invalid/duplicate fixture identity.'};$seen[$case.id]=$true
    $source=Join-Path $Fixtures $case.source_file
    if((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -cne $case.source_sha256){throw 'Known fixture source hash changed.'}
    $nodes=@($xml.SelectNodes('//Item')|Where-Object{$_.GetAttribute('class') -eq $case.class -and $_.SelectSingleNode('Properties/string[@name="Name"]').InnerText -ceq $case.id})
    if($nodes.Count -ne 1){throw ('Missing/duplicate source instance in XML: '+$case.id)}
    if($nodes[0].SelectSingleNode('Properties/ProtectedString[@name="Source"]').InnerText -cne [IO.File]::ReadAllText($source)){throw ('Embedded XML source differs: '+$case.id)}
    if($case.class -ne 'ModuleScript' -and $nodes[0].SelectSingleNode('Properties/bool[@name="Disabled"]').InnerText -ne 'true'){throw 'Runnable fixtures must be disabled in the prepared place.'}
    if($case.class -eq 'Script' -and $nodes[0].SelectSingleNode('Properties/token[@name="RunContext"]').InnerText -ne '2'){throw 'Client RunContext must explicitly equal2.'}
    $start=[Diagnostics.ProcessStartInfo]::new($compiler);$start.Arguments='--binary -O2 -g2 -t1 --fflags=LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false "'+[IO.Path]::GetFullPath($source)+'"';$start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $process=[Diagnostics.Process]::Start($start);$memory=[IO.MemoryStream]::new();$process.StandardOutput.BaseStream.CopyTo($memory);$message=$process.StandardError.ReadToEnd();$process.WaitForExit()
    if($process.ExitCode -ne 0){throw ($case.id+': '+$message)};$bytes=$memory.ToArray();if($bytes[0] -ne 14){throw 'Host fixture compiler emitted unexpected profile.'}
    [IO.File]::WriteAllBytes((Join-Path $output ($case.id+'.bc')),$bytes)
    $rows.Add([ordered]@{id=$case.id;class=$case.class;source_sha256=$case.source_sha256;host_compiler_syntax='passed';host_bytecode_bytes=$bytes.Length;native_engine_execution='not_run'})
    $process.Dispose();$memory.Dispose()
}
& (Join-Path $taskRoot '.tools/luau/luau.exe') (Join-Path $taskRoot 'adapter/native-test-v3-conformance.luau')
if($LASTEXITCODE -ne 0){throw 'Native observation conformance failed.'}
$report=[ordered]@{schema=1;fixture_package=$manifest.fixture_package;fixture_plan_sha256=$manifest.fixture_plan_sha256;prepared_programs=14;xml_validated=$true;host_compiler_sha256=$compilerHash;host_compiler_cases=14;host_compiler_passed=14;observer_negative_collision_pairs=8;unsupported_observations_rejected=3;normal_engine_compilation='not_run';native_programs_verified=0;typed_native_observations=0;reason='No connected Roblox Studio/controlled published place; host compiler/XML validation do not establish normal-engine compilation or native extraction.';cases=$rows.ToArray()}
[IO.File]::WriteAllText((Join-Path $taskRoot 'docs/results/native-place-v3-preparation.json'),($report|ConvertTo-Json -Depth 10),[Text.UTF8Encoding]::new($false))
Write-Output 'Prepared native fixtures:14/14 host compiler cases and XML source hashes valid; controlled native execution NOT RUN.'
