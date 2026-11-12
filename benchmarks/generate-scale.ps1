param(
    [ValidateSet(6,14)][int] $Version = 14,
    [ValidateRange(1000,10000)][int] $Inputs = 2000,
    [ValidateRange(1024,16384)][int] $FunctionUpdates = 4096,
    [ValidateRange(128,2048)][int] $ModuleFunctions = 512,
    [string] $Destination = (Join-Path $PSScriptRoot '../artifacts/scale-corpus')
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
if ($Version -eq 6) {
    $lock = Get-Content -LiteralPath (Join-Path $taskRoot 'upstream.lock.json') -Raw | ConvertFrom-Json
    $compiler = Join-Path $taskRoot '.tools/luau/luau-compile.exe'
    $flags = ''
} else {
    $locks = Get-Content -LiteralPath (Join-Path $taskRoot 'upstream.profiles.lock.json') -Raw | ConvertFrom-Json
    $lock = $locks.profiles | Where-Object { $_.tag -eq '0.746' }
    $compiler = Join-Path $taskRoot '.tools/luau-modern/luau-compile.exe'
    $flags = 'LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false'
}
$compilerHash = (Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash.ToLowerInvariant()
if ($compilerHash -ne $lock.windows_compiler_sha256) { throw 'Scale fixtures require the exact pinned official compiler.' }
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination = (Resolve-Path -LiteralPath $Destination).Path
$utf8 = [System.Text.UTF8Encoding]::new($false)
$newline = ([char]10).ToString()
$manifest = [System.Collections.Generic.List[object]]::new()

function Write-Case([string] $Name, [string] $Category, [int] $Scale, [System.Collections.Generic.List[string]] $Lines, [string] $Probe) {
    $sourcePath = Join-Path $Destination ($Name + '.luau')
    $source = [string]::Join($newline,$Lines.ToArray()) + $newline
    [System.IO.File]::WriteAllText($sourcePath,$source,$utf8)
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $compiler
    $start.Arguments = '--binary -O2 -g2'
    if ($flags) { $start.Arguments += ' --fflags=' + $flags }
    $start.Arguments += ' "' + $sourcePath + '"'
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $start
    $buffer = [System.IO.MemoryStream]::new()
    try {
        [void] $process.Start()
        $errors = $process.StandardError.ReadToEndAsync()
        $process.StandardOutput.BaseStream.CopyTo($buffer)
        $process.WaitForExit()
        $stderr = $errors.GetAwaiter().GetResult()
        $bytecode = $buffer.ToArray()
        if ($process.ExitCode -ne 0 -or $bytecode.Length -lt 2 -or $bytecode[0] -ne $Version -or $bytecode[1] -ne 3) { throw ('Scale compiler failed for ' + $Name + ': ' + $stderr) }
        $bytecodePath = Join-Path $Destination ($Name + '.bc')
        [System.IO.File]::WriteAllBytes($bytecodePath,$bytecode)
        $record = [ordered]@{
            name=$Name; category=$Category; scale=$Scale
            source=($Name+'.luau'); source_lines=$Lines.Count; source_bytes=([System.Text.Encoding]::UTF8.GetByteCount($source))
            source_sha256=(Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
            bytecode=($Name+'.bc'); bytecode_bytes=$bytecode.Length
            bytecode_sha256=(Get-FileHash -LiteralPath $bytecodePath -Algorithm SHA256).Hash.ToLowerInvariant()
            source_provenance='owned deterministic generator'; behavioral_validation='not run by generator'
        }
        if ($Probe) {
            $probePath=Join-Path $Destination ($Name+'.probe.luau')
            [System.IO.File]::WriteAllText($probePath,$Probe+$newline,$utf8)
            $record.probe=($Name+'.probe.luau')
            $record.probe_sha256=(Get-FileHash -LiteralPath $probePath -Algorithm SHA256).Hash.ToLowerInvariant()
        }
        $manifest.Add($record)
    } finally { $buffer.Dispose(); $process.Dispose() }
}

$largeFunction=[System.Collections.Generic.List[string]]::new()
$largeFunction.Add('local seed = ... or 1')
$largeFunction.Add('local value = seed')
for ($index=1;$index -le $FunctionUpdates;$index++) {
    $largeFunction.Add('value = (value * ' + (3+$index%17) + ' + ' + (17+$index*7) + ') % 1000003')
}
$largeFunction.Add('return value')
Write-Case 'large_function' 'one_large_function' $FunctionUpdates $largeFunction ''

$largeModule=[System.Collections.Generic.List[string]]::new()
$largeModule.Add('local operations = {}')
for ($index=1;$index -le $ModuleFunctions;$index++) {
    $largeModule.Add('operations['+$index+'] = function(seed)')
    $largeModule.Add('    local value = seed')
    for ($step=1;$step -le 24;$step++) {
        $largeModule.Add('    value = (value * '+(3+$step%11)+' + '+($index*31+$step)+') % 1000003')
    }
    $largeModule.Add('    return value')
    $largeModule.Add('end')
}
$largeModule.Add('return operations')
$probe = 'local seed = ... or 1'+$newline+'local total = 0'+$newline+'for index = 1, #module do total = (total + module[index](seed + index)) % 1000003 end'+$newline+'return total, #module'
Write-Case 'large_module' 'one_large_module' $ModuleFunctions $largeModule $probe

for ($inputIndex=0;$inputIndex -lt $Inputs;$inputIndex++) {
    $lines=[System.Collections.Generic.List[string]]::new()
    $lines.Add('local seed = ... or 1')
    $lines.Add('local value = seed + '+($inputIndex+1))
    switch ($inputIndex%4) {
        0 {
            for ($step=1;$step -le 8;$step++) { $lines.Add('value = (value * '+(3+$step)+' + '+($inputIndex*7+$step)+') % 1000003') }
        }
        1 {
            for ($step=1;$step -le 4;$step++) { $lines.Add('if value % '+(2+$step)+' == 0 then value += '+($inputIndex+$step)+' else value -= '+$step+' end') }
        }
        2 {
            $lines.Add('local function counter(start) local current = start; return function(delta) current += delta; return current end end')
            $lines.Add('local nextValue = counter(value)')
            $lines.Add('value = nextValue(3) + nextValue(-1)')
        }
        3 {
            $lines.Add('local values = {'+($inputIndex%31+1)+', 7, 13}')
            $lines.Add('for index, item in ipairs(values) do value += index * item end')
            $lines.Add('for index = 1, '+(2+$inputIndex%5)+' do value += index end')
        }
    }
    $lines.Add('return value')
    Write-Case ('input_'+$inputIndex.ToString('D4')) 'many_independent_inputs' $inputIndex $lines ''
}
$data=[ordered]@{
    schema=1; generator='benchmarks/generate-scale.ps1'; upstream_tag=$lock.tag; upstream_revision=$lock.revision
    compiler_sha256=$compilerHash; compiler_flags=$flags; bytecode_version=$Version; type_version=3; optimization=2; debug=2
    large_function_updates=$FunctionUpdates; large_module_functions=$ModuleFunctions; independent_inputs=$Inputs
    runtime_probe_seeds=@(-3,0,1,7); complete_behavioral_validation=$false
    cases=@($manifest.ToArray())
}
[System.IO.File]::WriteAllText((Join-Path $Destination 'manifest.json'),($data | ConvertTo-Json -Depth 8)+$newline,$utf8)
foreach ($group in @('all','many_independent_inputs','one_large_function','one_large_module')) {
    $paths=@($manifest | Where-Object { $group -eq 'all' -or $_.category -eq $group } | ForEach-Object { Join-Path $Destination $_.bytecode })
    [System.IO.File]::WriteAllText((Join-Path $Destination ('paths-'+$group+'.json')),(ConvertTo-Json -InputObject $paths)+$newline,$utf8)
}
Write-Output ('Generated '+$manifest.Count+' pinned scale fixtures ('+$Inputs+' independent scripts, one large function, one large module) in '+$Destination)
