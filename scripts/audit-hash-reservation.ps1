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
$random = [Random]::new(190219)
$auditLines = [System.Collections.Generic.List[string]]::new()
for ($case = 0; $case -lt 128; $case++) {
    $count = 1 + $case % 17
    $keys = [System.Collections.Generic.List[int]]::new()
    $seen = [System.Collections.Generic.HashSet[int]]::new()
    if ($case % 2 -eq 0) {
        $keys.Add(1)
        [void] $seen.Add(1)
        if ($count -ge 2) { $keys.Add(2); [void] $seen.Add(2) }
    }
    while ($keys.Count -lt $count) {
        $key = $random.Next(8, 2048)
        if ($seen.Add($key)) { $keys.Add($key) }
    }
    $fields = @($keys | ForEach-Object { '[' + $_ + ']=' + $_ })
    $auditLines.Add('do local t = {' + [string]::Join(',', $fields) + '}; for k,v in t do print(' + $case + ',k,v) end; print(' + $case + ',#t) end')
}
[System.IO.File]::WriteAllText((Join-Path $PWD 'artifacts/hash-numeric-original.luau'), ([string]::Join("`n", $auditLines.ToArray()) + "`n"))
$reservedLines = [System.Collections.Generic.List[string]]::new()
foreach ($line in $auditLines) {
    if ($line -notmatch '^do local t = \{(.*?)\};(.*)$') { throw 'Unexpected hash audit fixture syntax' }
    $fields = $Matches[1].Split(',')
    $tail = $Matches[2]
    if ($fields[0] -notmatch '^\[([^\]]+)\]=') { throw 'Missing first key' }
    $firstKey = $Matches[1]
    $capacity = 1
    while ($capacity -lt $fields.Length) { $capacity *= 2 }
    $reserveCount = if ($capacity -eq 1) { 1 } else { [int]($capacity / 2) + 1 }
    $reserve = @()
    for ($i = 0; $i -lt $reserveCount; $i++) { $reserve += '[' + $firstKey + ']=nil' }
    $stores = @()
    foreach ($field in $fields) {
        if ($field -notmatch '^\[([^\]]+)\]=(.*)$') { throw 'Invalid hash field' }
        $stores += 't[' + $Matches[1] + ']=' + $Matches[2] + ';'
    }
    $reservedLines.Add('do local t = {' + [string]::Join(',', $reserve) + '}; ' + [string]::Join(' ', $stores) + $tail)
}
[System.IO.File]::WriteAllText((Join-Path $PWD 'artifacts/hash-reservation.luau'), ([string]::Join("`n", $reservedLines.ToArray()) + "`n"))
$rows = @()
foreach ($optimization in 0..2) {
    $comparison=Compare-TypedAudit 'artifacts/hash-numeric-original.luau' 'artifacts/hash-reservation.luau' $optimization $Runtime
    $passed=if ($comparison.matched) {128} else {0}
    Write-Output ('O' + $optimization + ': ' + $passed + '/128 typed cases matched')
    $rows += [ordered] @{oracle_protocol='LOBS/1'; optimization=$optimization; cases=128; passed=$passed; observations=$comparison}
}
[System.IO.File]::WriteAllText((Join-Path $PWD 'artifacts/hash-reservation-report.json'), ($rows | ConvertTo-Json -Depth 24), [System.Text.UTF8Encoding]::new($false))
if (@($rows | Where-Object { $_.passed -ne $_.cases }).Count -ne 0) { throw 'Numeric hash reservation mismatches.' }
} finally { Pop-Location }
