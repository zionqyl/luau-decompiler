param([string]$Destination=(Join-Path $PSScriptRoot '../fixtures/roblox-v3'))
$ErrorActionPreference='Stop'
$Destination=[IO.Path]::GetFullPath($Destination)
New-Item -ItemType Directory -Force -Path $Destination|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
$large=[Text.StringBuilder]::new()
[void]$large.Append("return function(seed: number)`n    local value = seed`n")
for($index=1;$index -le 1024;$index++){[void]$large.Append(('    value = value + '+($index%17+1)+' - '+($index%11)+"`n"))}
[void]$large.Append("    return value, nil`nend`n")
[IO.File]::WriteAllText((Join-Path $Destination 'LargeFunction.luau'),$large.ToString(),$utf8)
$large=[Text.StringBuilder]::new();[void]$large.Append("local module = {}`n")
for($index=1;$index -le 128;$index++){[void]$large.Append(('function module.operation'+$index+"(value: number)`n    return value * "+$index+' + '+($index%13)+", nil`nend`n"))}
[void]$large.Append("return module`n")
[IO.File]::WriteAllText((Join-Path $Destination 'LargeModule.luau'),$large.ToString(),$utf8)
$rows=[Collections.Generic.List[object]]::new()
foreach($source in (Get-ChildItem -LiteralPath $Destination -Filter '*.luau'|Sort-Object Name)){
    $id=$source.BaseName;$class='ModuleScript';$storage='ReplicatedStorage.DecompilerV3Fixtures.'+$id;$runtime=$storage;$probe='scalar_function'
    if($id -in @('LocalBinary','LocalLoop')){$class='LocalScript';$storage='StarterPlayer.StarterPlayerScripts.DecompilerV3Fixtures.'+$id;$runtime='Players.LocalPlayer.PlayerScripts.DecompilerV3Fixtures.'+$id}
    if($id -eq 'ClientMethods'){$class='Script'}
    if($id -eq 'CaptureCounter'){$probe='stateful_function'}
    if($id -eq 'ModuleInterface'){$probe='module_interface'}
    if($id -eq 'LargeModule'){$probe='large_module'}
    $rows.Add([ordered]@{id=$id;class=$class;storage_path=$storage;runtime_path=$runtime;source_file=($id+'.luau');source_sha256=(Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToLowerInvariant();source_bytes=$source.Length;probe=$probe;inputs=@(-3,0,7);normal_engine_compilation='not_run';native_extraction='not_run'})
}
if($rows.Count -ne 14){throw 'Fixture identity set changed; update the explicit planned case count.'}
$plan=[ordered]@{schema=1;fixture_package='luau-decompiler-v0.3.0-native-r1';normal_engine_test_status='not_run';missing_environment='No connected Roblox Studio/test-place publishing environment; no controlled published-place native client run.';distinct_native_programs_planned=14;module_scripts_planned=11;local_scripts_planned=2;client_run_scripts_planned=1;runtime_inputs_per_program=3;behavioral_comparisons_planned=42;timing_repetitions_planned=0;compiled_fixture_observations=0;native_programs_verified=0;cases=$rows.ToArray()}
$core=$plan|ConvertTo-Json -Depth 12 -Compress
$hash=([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($utf8.GetBytes($core)))).Replace('-','').ToLowerInvariant()
$plan.fixture_plan_sha256=$hash
$xml=[Xml.XmlDocument]::new();$declaration=$xml.CreateXmlDeclaration('1.0','utf-8',$null);[void]$xml.AppendChild($declaration);$root=$xml.CreateElement('roblox');$root.SetAttribute('version','4');[void]$xml.AppendChild($root)
$script:NativeFixtureReferentSerial=0
function Item([Xml.XmlNode]$Parent,[string]$Class,[string]$Name){$script:NativeFixtureReferentSerial+=1;$item=$xml.CreateElement('Item');$item.SetAttribute('class',$Class);$item.SetAttribute('referent','RBX'+$script:NativeFixtureReferentSerial.ToString('D8'));[void]$Parent.AppendChild($item);$properties=$xml.CreateElement('Properties');[void]$item.AppendChild($properties);$nameValue=$xml.CreateElement('string');$nameValue.SetAttribute('name','Name');$nameValue.InnerText=$Name;[void]$properties.AppendChild($nameValue);return $item}
function Property([Xml.XmlElement]$Item,[string]$Type,[string]$Name,[string]$Value){$property=$xml.CreateElement($Type);$property.SetAttribute('name',$Name);if($Type -eq 'ProtectedString'){[void]$property.AppendChild($xml.CreateCDataSection($Value))}else{$property.InnerText=$Value};[void]$Item.SelectSingleNode('Properties').AppendChild($property)}
$null=Item $root 'Workspace' 'Workspace';$replicated=Item $root 'ReplicatedStorage' 'ReplicatedStorage';$modules=Item $replicated 'Folder' 'DecompilerV3Fixtures'
$marker=Item $modules 'StringValue' 'FixturePlan';Property $marker 'string' 'Value' $hash
$starter=Item $root 'StarterPlayer' 'StarterPlayer';$starterScripts=Item $starter 'StarterPlayerScripts' 'StarterPlayerScripts';$locals=Item $starterScripts 'Folder' 'DecompilerV3Fixtures'
foreach($case in $rows){$parent=if($case.class -eq 'LocalScript'){$locals}else{$modules};$item=Item $parent $case.class $case.id;Property $item 'ProtectedString' 'Source' ([IO.File]::ReadAllText((Join-Path $Destination $case.source_file)));if($case.class -ne 'ModuleScript'){Property $item 'bool' 'Disabled' 'true'};if($case.class -eq 'Script'){Property $item 'token' 'RunContext' '2'}}
$settings=[Xml.XmlWriterSettings]::new();$settings.Encoding=$utf8;$settings.Indent=$true;$settings.NewLineChars="`n"
$path=Join-Path $Destination 'controlled-place.rbxlx';$writer=[Xml.XmlWriter]::Create($path,$settings);try{$xml.Save($writer)}finally{$writer.Dispose()}
$parsed=[Xml.XmlDocument]::new();$parsed.Load($path);if($parsed.SelectNodes('//Item[@class="ModuleScript" or @class="LocalScript" or @class="Script"]').Count -ne 14){throw 'Place XML program count differs from plan'}
$plan.place_xml_sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $Destination 'manifest.json'),($plan|ConvertTo-Json -Depth 12),$utf8)
Write-Output ('Prepared XML-valid controlled place with 14 distinct source programs; engine/native execution NOT RUN: '+$path)
