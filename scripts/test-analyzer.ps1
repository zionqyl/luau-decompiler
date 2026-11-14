param([string]$Analyzer=(Join-Path $PSScriptRoot '../.tools/luau-quality.exe'),[string]$Definitions=(Join-Path $PSScriptRoot '../definitions/roblox.d.luau'),[string]$Destination=(Join-Path $PSScriptRoot '../artifacts/analyzer-conformance'))
$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
$typeQualitySelfTest=& $Analyzer --type-quality-self-test | ConvertFrom-Json
if($LASTEXITCODE -ne 0 -or -not $typeQualitySelfTest.passed -or -not $typeQualitySelfTest.node_budget_unknown -or -not $typeQualitySelfTest.edge_budget_unknown){throw 'Analyzer bounded recursive type-quality self-test failed.'}
$start=[Diagnostics.ProcessStartInfo]::new((Resolve-Path $Analyzer).Path)
$start.Arguments='"'+(Resolve-Path $Definitions).Path+'"'
$start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardInput=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
$child=[Diagnostics.Process]::Start($start)
function Read-Frame {
    $head=New-Object byte[] 4
    $task=$child.StandardOutput.BaseStream.ReadAsync($head,0,4)
    if(-not $task.Wait(30000)){throw 'Analyzer frame deadline exceeded'}
    if($task.Result -ne 4){throw 'Analyzer frame header missing'}
    $length=[BitConverter]::ToUInt32($head,0)
    if($length -gt 16MB){throw 'Analyzer frame limit exceeded'}
    $bytes=New-Object byte[] $length;$offset=0
    while($offset -lt $length){$count=$child.StandardOutput.BaseStream.Read($bytes,$offset,$length-$offset);if($count -le 0){throw 'Analyzer frame truncated'};$offset+=$count}
    return $utf8.GetString($bytes)|ConvertFrom-Json
}
function Send-Source([string]$source,[hashtable]$modules=@{},[string]$contract='') {
    $memory=[IO.MemoryStream]::new();$writer=[IO.BinaryWriter]::new($memory,$utf8,$true)
    function Write-Field([string]$value){$bytes=$utf8.GetBytes($value);$writer.Write([uint32]$bytes.Length);$writer.Write($bytes)}
    Write-Field 'LQRY/1';Write-Field 'main';Write-Field $source;Write-Field $contract;$writer.Write([uint32]10000)
    $writer.Write([uint32]$modules.Count);foreach($entry in $modules.GetEnumerator()){Write-Field $entry.Key;Write-Field $entry.Value}
    $writer.Write([uint32]0);$writer.Flush();$bytes=$memory.ToArray();$writer.Dispose();$memory.Dispose()
    $child.StandardInput.BaseStream.Write([BitConverter]::GetBytes([uint32]$bytes.Length),0,4);$child.StandardInput.BaseStream.Write($bytes,0,$bytes.Length);$child.StandardInput.BaseStream.Flush()
    return Read-Frame
}
$rows=[Collections.Generic.List[object]]::new()
try {
    $ready=Read-Frame
    if(-not $ready.ready){throw ('Pinned definition bootstrap failed: '+($ready|ConvertTo-Json -Depth 8 -Compress))}
    $cases=@(
        @{id='scalar';source='local answer: number = 42; return answer';expected=$true},
        @{id='roblox_snapshot';expected=$true;source=@'
export type PlayerSnapshot = {userId: number, displayName: string, position: Vector3?}
local function getPlayerSnapshot(player: Player): PlayerSnapshot
    local character: Model? = player.Character
    local position: Vector3? = nil
    if character ~= nil then position = character:GetPivot().Position end
    return {userId=player.UserId, displayName=player.DisplayName, position=position}
end
return getPlayerSnapshot
'@},
        @{id='generic_pack';source='local function forward<T...>(...: T...): T... return ... end; return forward(1,nil,"x")';expected=$true},
        @{id='resolved_module';source='local m = require("./dep"); return m.double(2)';modules=@{dep='return {double = function(x: number): number return x*2 end}'};expected=$true},
        @{id='resolved_module_bad_argument';source='local m = require("./dep"); return m.double("wrong")';modules=@{dep='return {double = function(x: number): number return x*2 end}'};expected=$false},
        @{id='unknown_datamodel_child';source='return game.Workspace.NotADeclaredChild';expected=$false},
        @{id='type_mismatch';source='local value: string = 42; return value';expected=$false},
        @{id='dynamic_require';source='local id = ...; return require(id)';expected=$false},
        @{id='syntax_error';source='local =';expected=$false},
        @{id='any_visible';source='local value: any = ...; return value';expected=$true}
        @{id='runtime_not_executed';source='while true do end';expected=$true},
        @{id='type_function_not_executed';source='type function neverRun() while true do end end; type T = neverRun<>; return 1';expected=$false},
        @{id='nested_function_any';source='local function preserve(callback: (...any) -> (...any)) return callback end; return preserve';expected=$true;recursive_any=$true},
        @{id='nested_pack_record_any';source='type Box<T> = {value: T}; local function preserve(value: {callback: ((number) -> (number, ...any))?, rows: {[string]: Box<any>}}) return value end; return preserve';expected=$true;recursive_any=$true},
        @{id='nested_unknown';source='local function preserve(callback: (unknown) -> unknown) return callback end; return preserve';expected=$true;recursive_unknown=$true},
        @{id='recursive_record_clean';source='type Node = {value: number, next: Node?}; local function preserve(node: Node): Node return node end; return preserve';expected=$true;recursive_clean=$true},
        @{id='sdk_calls_clean';source='local text: string = string.sub("abcd", 1, 2); print(text); return text';expected=$true;recursive_clean=$true}
        @{id='service_literal_precision';source='local service:TweenService=game:GetService("TweenService"); return service';expected=$true;recursive_clean=$true},
        @{id='service_alias_precision';source='local name:"TweenService"="TweenService"; print("retain alias"); local service:TweenService=game:GetService(name); return service';expected=$true;recursive_clean=$true},
        @{id='instance_alias_precision';source='local name:"Part"="Part"; print("retain alias"); local instance:Part=Instance.new(name); return instance';expected=$true;recursive_clean=$true},
        @{id='service_dynamic_boundary';source='local name:string="TweenService"; local service:TweenService=game:GetService(name); return service';expected=$false},
        @{id='service_wrong_class';source='local service:TweenService=game:GetService("RunService"); return service';expected=$false},
        @{id='service_nonservice_class';source='local name:"Part"="Part"; local instance:Part=game:GetService(name); return instance';expected=$false},
        @{id='instance_noncreatable_class';source='local instance:TweenService=Instance.new("TweenService"); return instance';expected=$false},
        @{id='service_extra_argument';source='return game:GetService("TweenService",42)';expected=$false},
        @{id='instance_invalid_parent';source='return Instance.new("Part",42)';expected=$false},
        @{id='context_module_number';source='local value:number=require("./dep"); return value';modules=@{dep='local value:number=1; return value'};expected=$true},
        @{id='context_changed_module_reject';source='local value:number=require("./dep"); return value';modules=@{dep='local value:string="different"; return value'};expected=$false},
        @{id='context_module_removed';source='local value:number=require("./dep"); return value';expected=$false},
        @{id='context_contract_number';source='local value:number=suppliedValue; return value';contract='declare suppliedValue: number';expected=$true},
        @{id='context_changed_contract_reject';source='local value:number=suppliedValue; return value';contract='declare suppliedValue: string';expected=$false},
        @{id='context_contract_string';source='local value:string=suppliedValue; return value';contract='declare suppliedValue: string';expected=$true},
        @{id='context_contract_removed';source='local value:number=suppliedValue; return value';expected=$false},
        @{id='context_plain_positive_after_rejections';source='local value:number=42; return value';expected=$true}
    )
    foreach($case in $cases){
        $modules=if($case.modules){$case.modules}else{@{}}
        $source='--!strict'+[char]10+$case.source
        $result=Send-Source $source $modules $case.contract
        $passed=($result.strict -eq $case.expected)
        if($case.id -eq 'any_visible'){$passed=$passed -and $result.explicit_any -gt 0 -and $result.inferred_any -gt 0}
        if($case.recursive_any){$passed=$passed -and $result.inferred_any -gt 0 -and -not $result.type_traversal_exhausted}
        if($case.recursive_unknown){$passed=$passed -and $result.inferred_unknown -gt 0 -and -not $result.type_traversal_exhausted}
        if($case.recursive_clean){$passed=$passed -and $result.inferred_any -eq 0 -and $result.inferred_unknown -eq 0 -and -not $result.type_traversal_exhausted}
        if($case.id -eq 'generic_pack'){$passed=$passed -and $result.inferred_any -eq 0 -and $result.inferred_unknown -eq 0 -and -not $result.type_traversal_exhausted}
        $rows.Add(@{id=$case.id;passed=$passed;expected_strict=$case.expected;result=$result;source=$source})
        if(-not $passed){throw ('Analyzer conformance failed '+$case.id+': '+($result|ConvertTo-Json -Depth 8 -Compress))}
    }
    $report=@{schema=1;protocol='LQUAL/1';passed=$true;cases=$rows.ToArray();type_quality_budget_self_test=$typeQualitySelfTest;analyzer_sha256=(Get-FileHash $Analyzer).Hash.ToLowerInvariant();definitions_sha256=(Get-FileHash $Definitions).Hash.ToLowerInvariant()}
    [IO.File]::WriteAllText((Join-Path $Destination 'report.json'),($report|ConvertTo-Json -Depth 14),$utf8)
    Write-Output ('Pinned analyzer conformance '+$rows.Count+'/'+$rows.Count+' passed.')
} finally {if(-not $child.HasExited){$child.Kill();$child.WaitForExit()};$child.Dispose()}
