param([string] $Runtime = $env:LUAU_VM_RUNNER)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'env.ps1')
if ([string]::IsNullOrWhiteSpace($Runtime)) { $Runtime = $env:LUAU_VM_RUNNER }
if ([string]::IsNullOrWhiteSpace($Runtime)) { throw 'Set LUAU_VM_RUNNER to the typed VM oracle.' }
$Runtime = (Resolve-Path -LiteralPath $Runtime).Path
Push-Location $taskRoot
try {
. (Join-Path $PSScriptRoot 'typed-audit.ps1')
Initialize-TypedAudit $Runtime
New-Item -ItemType Directory -Force -Path artifacts | Out-Null
$random = [Random]::new(6767)
$originalLines = [System.Collections.Generic.List[string]]::new()
$reservedLines = [System.Collections.Generic.List[string]]::new()
for ($case = 0; $case -lt 192; $case++) {
    $fields = @()
    $count = 1 + $case % 19
    for ($index = 0; $index -lt $count; $index++) {
        $key = switch (($case + $index) % 6) {
            0 { '"name' + $random.Next(0, 13) + '"' }
            1 { [string] $random.Next(1, 17) }
            2 { [string](- $random.Next(1, 23)) }
            3 { if ($index % 2 -eq 0) { 'true' } else { 'false' } }
            4 { [string] $random.Next(1024, 4096) }
            5 { [string]($random.Next(1, 128)) + '.5' }
        }
        $value = if ($index % 5 -eq 4) { 'nil' } else { [string]($index + 1) }
        $fields += '[' + $key + ']=' + $value
    }
    $firstKey = [Regex]::Match($fields[0], '^\[([^\]]+)\]=').Groups[1].Value
    $capacity = 1
    while ($capacity -lt $fields.Length) { $capacity *= 2 }
    $reserveCount = if ($capacity -eq 1) { 1 } else { [int]($capacity / 2) + 1 }
    $reserve = @()
    for ($i = 0; $i -lt $reserveCount; $i++) { $reserve += '[' + $firstKey + ']=nil' }
    $stores = @()
    foreach ($field in $fields) { $stores += 't' + $field + ';' }
    $tail = ' for k,v in t do print(' + $case + ',k,v) end; print(' + $case + ',#t) end'
    $originalLines.Add('do local t = {' + [string]::Join(',', $fields) + '};' + $tail)
    $reservedLines.Add('do local t = {' + [string]::Join(',', $reserve) + '}; ' + [string]::Join(' ', $stores) + $tail)
}
[System.IO.File]::WriteAllText((Join-Path $PWD 'artifacts/hash-mixed-original.luau'), ([string]::Join("`n", $originalLines.ToArray()) + "`n"))
[System.IO.File]::WriteAllText((Join-Path $PWD 'artifacts/hash-mixed-reserved.luau'), ([string]::Join("`n", $reservedLines.ToArray()) + "`n"))
$rows = @()
foreach ($optimization in 0..2) {
    $comparison=Compare-TypedAudit 'artifacts/hash-mixed-original.luau' 'artifacts/hash-mixed-reserved.luau' $optimization $Runtime
    $passed=if ($comparison.matched) {192} else {0}
    Write-Output ('O0->O' + $optimization + ': ' + $passed + '/192 typed cases matched')
    $rows += [ordered]@{oracle_protocol='LOBS/1'; optimization=$optimization; cases=192; passed=$passed; observations=$comparison}
}
[System.IO.File]::WriteAllText((Join-Path $PWD 'artifacts/hash-mixed-report.json'), ($rows | ConvertTo-Json -Depth 24), [System.Text.UTF8Encoding]::new($false))
if (@($rows | Where-Object { $_.passed -ne $_.cases }).Count -ne 0) { throw 'Mixed hash reservation mismatches.' }
} finally { Pop-Location }
