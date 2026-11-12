param(
    [Parameter(Mandatory=$true)][string] $Report,
    [Parameter(Mandatory=$true)][string] $Binary,
    [Parameter(Mandatory=$true)][string] $Destination
)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$nm=Join-Path $taskRoot '.tools/mingw64/bin/nm.exe'
$objdump=Join-Path $taskRoot '.tools/mingw64/bin/objdump.exe'
if (-not (Test-Path -LiteralPath $nm) -or -not (Test-Path -LiteralPath $objdump)) { throw 'Install GNU nm/objdump through setup-tools.ps1.' }
$Binary=(Resolve-Path -LiteralPath $Binary).Path
$baseLine=@(& $objdump -p $Binary | Select-String '^ImageBase\s+([0-9a-fA-F]+)\s*$')
if ($LASTEXITCODE -ne 0 -or $baseLine.Count -ne 1) { throw 'Unable to read PE image base.' }
$imageBase=[Convert]::ToUInt64($baseLine[0].Matches[0].Groups[1].Value,16)
$symbols=[System.Collections.Generic.List[object]]::new()
foreach ($line in (& $nm -n -C $Binary)) {
    if ($line -match '^([0-9a-fA-F]+) [tT] (.+)$') { $symbols.Add([pscustomobject]@{address=[Convert]::ToUInt64($Matches[1],16);name=$Matches[2]}) }
}
if ($LASTEXITCODE -ne 0 -or $symbols.Count -eq 0) { throw 'Unable to read executable text symbols.' }
$rows=[System.Collections.Generic.List[object]]::new()
$data=Get-Content -LiteralPath $Report -Raw | ConvertFrom-Json
foreach ($row in $data.results) {
    $stacks=[System.Collections.Generic.List[object]]::new()
    $firstSites=@{}
    foreach ($sample in $row.allocation_stack_samples) {
        $frames=[System.Collections.Generic.List[string]]::new()
        foreach ($rvaText in $sample.image_relative_addresses) {
            $rva=[Convert]::ToUInt64($rvaText.Substring(2),16)
            if ($rva -gt 64*1024*1024) { $frames.Add('<outside executable>'); continue }
            $address=$imageBase+$rva
            $low=0; $high=$symbols.Count
            while ($low -lt $high) { $middle=[int][Math]::Floor(($low+$high)/2); if ($symbols[$middle].address -le $address) {$low=$middle+1} else {$high=$middle} }
            if ($low -eq 0) { $frames.Add('<no preceding text symbol>') } else { $frames.Add($symbols[$low-1].name+'+0x'+($address-$symbols[$low-1].address).ToString('x')) }
        }
        $site=@($frames | Where-Object { $_ -match '^luau_decompiler::' } | Select-Object -First 1)
        $key=if ($site.Count) {($site[0] -replace '\+0x[0-9a-f]+$','')} else {'<no core frame>'}
        if (-not $firstSites.ContainsKey($key)) {$firstSites[$key]=0}
        $firstSites[$key]++
        $stacks.Add([ordered]@{allocation_bytes=$sample.allocation_bytes;frames=$frames.ToArray()})
    }
    $rows.Add([ordered]@{path=$row.path;sample_candidates=$row.sample_candidates;retained_samples=$stacks.Count;first_core_frame_counts=$firstSites;stacks=$stacks.ToArray()})
}
$symbolReport=[ordered]@{
    schema=1;binary_sha256=(Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash.ToLowerInvariant()
    raw_report_sha256=(Get-FileHash -LiteralPath $Report -Algorithm SHA256).Hash.ToLowerInvariant()
    method='Windows fixed stack capture every256allocation/reallocation events; deterministic64-slot reservoir. GNU nm nearest preceding text-symbol resolution; no inline frames or source-line attribution; counts are sampled allocation events, not bytes or CPU time.'
    results=$rows.ToArray()
}
[IO.File]::WriteAllText($Destination,($symbolReport | ConvertTo-Json -Depth 10),[Text.UTF8Encoding]::new($false))
