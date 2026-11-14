param([string]$Binary=(Join-Path $PSScriptRoot '../target/release/luau-decompile.exe'))
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$Binary=(Resolve-Path -LiteralPath $Binary).Path
$utf8=[Text.UTF8Encoding]::new($false)
$directory=Join-Path $taskRoot 'artifacts/examples-rc'
$destination=Join-Path $taskRoot 'examples/typed-output'
New-Item -ItemType Directory -Force -Path $directory,$destination | Out-Null
$compiler=Join-Path $taskRoot '.tools/luau-modern/luau-compile.exe'
$version=(& $Binary --version) -replace '^luau-decompile\s+',''
$items=@(@{id='verified_bytecode';kind='bytecode';retained='fixtures/runtime/verified.bc';source='fixtures/runtime/verified.luau'},@{id='roblox_identity';kind='bytecode'},@{id='roblox_position';kind='bytecode'},@{id='player_snapshot';file='roblox_snapshot';kind='bytecode'},@{id='generic_identity';kind='source'},@{id='generic_vararg';kind='source'},@{id='inferred_returns';kind='source'})
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Reuse-Examples {
    $path=Join-Path $destination 'manifest-rc.json'
    if(-not(Test-Path -LiteralPath $path)){return $false}
    try{
        $prior=Get-Content -LiteralPath $path -Raw|ConvertFrom-Json
        if($prior.schema -ne 1 -or $prior.executable_sha256 -cne (Hash $Binary) -or $prior.generator_sha256 -cne (Hash $PSCommandPath) -or $prior.compiler_sha256 -cne (Hash $compiler) -or $prior.examples.Count -ne $items.Count){return $false}
        $analyzerHash=Hash (Join-Path $taskRoot '.tools/luau-quality.exe')
        $manifestHash=Hash (Join-Path $taskRoot '.tools/luau-quality.exe.manifest.json')
        $definitionsHash=Hash (Join-Path $taskRoot 'definitions/roblox.d.luau')
        if($prior.analyzer_manifest_sha256 -cne $manifestHash){return $false}
        foreach($item in $items){
            $row=@($prior.examples|Where-Object{$_.id -ceq $item.id})
            if($row.Count -ne 1){return $false}
            $row=$row[0]
            if($row.configuration -cne ($item.id+'.config.json') -or $row.output -cne ($item.id+'.luau')){return $false}
            foreach($pair in @(@((Join-Path $taskRoot $row.known_source),$row.known_source_sha256),@((Join-Path $destination $row.configuration),$row.configuration_sha256),@((Join-Path $destination $row.output),$row.output_sha256),@((Join-Path $taskRoot $row.input_path),$row.input_sha256))){if(-not(Test-Path -LiteralPath $pair[0] -PathType Leaf) -or (Hash $pair[0]) -cne $pair[1]){return $false}}
            if(-not $row.validation.required_passed -or -not $row.validation.meaningful_typing.passed -or $row.validation.analyzer_sha256 -cne $analyzerHash -or $row.validation.definitions_sha256 -cne $definitionsHash){return $false}
            if(@($row.validation.attempts|Where-Object{$_.source_sha256 -ceq $row.output_sha256 -and $_.syntax -ceq 'passed' -and $_.compilation -ceq 'passed' -and $_.strict_analysis -ceq 'passed'}).Count -ne 1){return $false}
        }
        return $true
    }catch{return $false}
}
function Run-Cli([string[]]$Parameters,[string]$ErrorPath){
    $start=[Diagnostics.ProcessStartInfo]::new($Binary)
    $start.Arguments=(@($Parameters|ForEach-Object{if($_.Contains('"') -or $_.Contains([char]0)){throw 'Invalid native argument'};'"'+$_+'"'}) -join ' ')
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $child=[Diagnostics.Process]::Start($start)
    $output=$child.StandardOutput.ReadToEndAsync();$errors=$child.StandardError.ReadToEndAsync()
    try{
        if(-not $child.WaitForExit(120000)){$child.Kill();$child.WaitForExit();throw 'Example processing exceeded its deadline'}
        [IO.File]::WriteAllText($ErrorPath,$errors.Result,$utf8)
        if($child.ExitCode -ne 0){throw ('Example CLI failed: '+$errors.Result.Substring(0,[Math]::Min(4000,$errors.Result.Length)))}
        if(-not [string]::IsNullOrWhiteSpace($output.Result)){throw 'Example CLI unexpectedly wrote source to stdout'}
    }finally{$child.Dispose()}
}
function Compile-Example([string]$Source,[string]$Destination){
    $start=[Diagnostics.ProcessStartInfo]::new($compiler)
    $start.Arguments='--binary -O2 -g2 -t1 --fflags=LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false "'+$Source+'"'
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $child=[Diagnostics.Process]::Start($start)
    $errors=$child.StandardError.ReadToEndAsync()
    $file=[IO.File]::Create($Destination)
    try{$child.StandardOutput.BaseStream.CopyTo($file);$child.WaitForExit();if($child.ExitCode -ne 0){throw ('Compiler failed: '+$errors.Result)}}finally{$file.Dispose();$child.Dispose()}
    if([IO.File]::ReadAllBytes($Destination)[0] -ne 14){throw 'Expected the pinned version14 example profile.'}
}
function Generate-OrganizationExample {
    $source=Join-Path $taskRoot 'tests/source-corpus/module_organization.luau'
    $config=Join-Path $destination 'module_organization.config.json'
    $output=Join-Path $destination 'module_organization.luau'
    $manifest=Join-Path $destination 'module_organization.manifest.json'
    $tools=@{analyzer_sha256=(Hash (Join-Path $taskRoot '.tools/luau-quality.exe'));manifest_sha256=(Hash (Join-Path $taskRoot '.tools/luau-quality.exe.manifest.json'));definitions_sha256=(Hash (Join-Path $taskRoot 'definitions/roblox.d.luau'))}
    if((Test-Path -LiteralPath $manifest) -and (Test-Path -LiteralPath $output)){
        $prior=Get-Content -LiteralPath $manifest -Raw|ConvertFrom-Json
        if($prior.executable_sha256 -ceq (Hash $Binary) -and $prior.generator_sha256 -ceq (Hash $PSCommandPath) -and $prior.known_source_sha256 -ceq (Hash $source) -and $prior.configuration_sha256 -ceq (Hash $config) -and $prior.output_sha256 -ceq (Hash $output) -and $prior.analyzer_manifest_sha256 -ceq $tools.manifest_sha256 -and $prior.validation.strict_analysis -ceq 'passed' -and $prior.validation.analyzer_sha256 -ceq $tools.analyzer_sha256 -and $prior.validation.definitions_sha256 -ceq $tools.definitions_sha256){Write-Output 'Reused matching whole-module organization example';return}
    }
    $quality=Join-Path $directory 'module_organization-quality.json'
    Run-Cli @('decompile',$source,'--config',$config,'-o',$output,'--quality-report',$quality,'--force') (Join-Path $directory 'module_organization.stderr')
    $result=Get-Content -LiteralPath $quality -Raw|ConvertFrom-Json
    if(-not $result.validation.required_passed -or $result.validation.strict_analysis -cne 'passed'){throw 'Whole-module organization example failed its required strict gate'}
    $receipt=[ordered]@{schema=1;version=$version;executable_sha256=(Hash $Binary);generator_sha256=(Hash $PSCommandPath);known_source='tests/source-corpus/module_organization.luau';known_source_sha256=(Hash $source);configuration='module_organization.config.json';configuration_sha256=(Hash $config);output='module_organization.luau';output_sha256=(Hash $output);validation=$result.validation;types=$result.type_report;scope='Source preservation and dependency-aware presentation; runtime statements are not reordered. Explicit controlled modules are supplied by configuration.';behavior='Not executed by generator; controlled type_layout_whole_module_preserves_import_type_and_initialization_dependencies owns behavioral verification. Strict status and meaningful typing remain separate.'}
    $receipt.analyzer_manifest_sha256=$tools.manifest_sha256
    [IO.File]::WriteAllText($manifest,($receipt|ConvertTo-Json -Depth 32),$utf8)
    Write-Output 'Generated whole-module organization example with recorded independent quality results'
}
Generate-OrganizationExample
if(Reuse-Examples){Write-Output ('Reused matching final executable/tool/configuration/source/output example evidence: '+$items.Count);return}
$rows=[Collections.Generic.List[object]]::new()
foreach($item in $items){
    $id=$item.id
    $inputSource=if($item.source){Join-Path $taskRoot $item.source}elseif($item.kind -eq 'source'){Join-Path $taskRoot ('examples/source-input/'+$id+'.luau')}else{Join-Path $taskRoot ('tests/type-corpus/'+$(if($item.file){$item.file}else{$id})+'.luau')}
    $inputPath=if($item.retained){Join-Path $taskRoot $item.retained}elseif($item.kind -eq 'source'){$inputSource}else{Join-Path $directory ($id+'.bc')}
    if($item.kind -eq 'bytecode' -and -not $item.retained){Compile-Example $inputSource $inputPath}
    $configuration=[ordered]@{output_policy='verified_typed';naming='camelCase';input_format=$(if($item.kind -eq 'source'){'luau_source'}else{'luau_bytecode'});formatting=@{line_width=100};typing=@{binding_types=@{}}}
    if($item.kind -eq 'bytecode' -and -not $item.retained){
        $inventory=Join-Path $directory ($id+'-inventory.json')
        Run-Cli @('decompile',$inputPath,'--policy','faithful','--no-validation','--quality-report',$inventory,'-o',(Join-Path $directory ($id+'-baseline.luau')),'--force') (Join-Path $directory ($id+'-inventory.stderr'))
        $bindings=(Get-Content -LiteralPath $inventory -Raw|ConvertFrom-Json).bindings
        $player=@($bindings|Where-Object{$_.parameter -and $_.debug_name -eq 'player'})
        if($player.Count -ne 1){throw ('Player contract identity is ambiguous: '+$id)}
        $configuration.typing.binding_types[('p'+$player[0].proto+':b'+$player[0].id)]='Player'
    }
    $configPath=Join-Path $destination ($id+'.config.json')
    [IO.File]::WriteAllText($configPath,($configuration|ConvertTo-Json -Depth 8),$utf8)
    $output=Join-Path $destination ($id+'.luau')
    $quality=Join-Path $directory ($id+'-quality.json')
    Run-Cli @('decompile',$inputPath,'--config',$configPath,'--quality-report',$quality,'-o',$output,'--force') (Join-Path $directory ($id+'.stderr'))
    $result=Get-Content -LiteralPath $quality -Raw|ConvertFrom-Json
    if(-not $result.validation.required_passed -or -not $result.validation.meaningful_typing.passed){throw ('Example policy failed: '+$id)}
    $rows.Add([ordered]@{id=$id;input_kind=$item.kind;known_source=$inputSource.Substring($taskRoot.Length+1).Replace('\','/');known_source_sha256=(Hash $inputSource);input_path=$inputPath.Substring($taskRoot.Length+1).Replace('\','/');input_sha256=(Hash $inputPath);configuration=($id+'.config.json');configuration_sha256=(Hash $configPath);output=($id+'.luau');output_sha256=(Hash $output);validation=$result.validation;types=$result.type_report;behavior='not_run_by_example_generator; independent controlled release matrices are separate'})
}
$report=[ordered]@{schema=1;version=$version;executable_sha256=(Hash $Binary);generator_sha256=(Hash $PSCommandPath);compiler_sha256=(Hash $compiler);analyzer_manifest_sha256=(Hash (Join-Path $taskRoot '.tools/luau-quality.exe.manifest.json'));examples=$rows.ToArray()}
[IO.File]::WriteAllText((Join-Path $destination 'manifest-rc.json'),($report|ConvertTo-Json -Depth 32),$utf8)
Write-Output ('Verified examples generated from final executable: '+$rows.Count)
