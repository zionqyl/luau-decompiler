param([switch]$Fix)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
Push-Location $taskRoot
try {
    $files=@(& rg --files src tests adapter examples scripts benchmarks fuzz -g '*.rs' -g '*.cpp' -g '*.h' -g '*.luau' -g '*.lua' -g '!tests/*corpus/**' -g '!tests/fixtures/**' -g '!tests/profile-fixtures/**' -g '!tests/oracle/fixtures/**' -g '!fuzz/target/**')
    if($LASTEXITCODE -ne 0){throw 'Cannot inventory first-party code.'}
    $mode=if($Fix){'--write'}else{'--check'}
    function Check-CodeChunk([string[]]$Paths){
        & cargo run --offline --locked --example code_comments -- $mode @Paths
        if($LASTEXITCODE -ne 0){throw 'First-party comment check failed.'}
    }
    $chunk=[Collections.Generic.List[string]]::new();$characters=0
    foreach($path in $files){
        $cost=$path.Length+3
        if($cost -gt 22000){throw 'A code-check path exceeds the bounded command-line budget'}
        if($characters+$cost -gt 22000){Check-CodeChunk $chunk.ToArray();$chunk.Clear();$characters=0}
        $chunk.Add($path);$characters+=$cost
    }
    if($chunk.Count){Check-CodeChunk $chunk.ToArray()}
    $failed=$false
    foreach($path in @(& rg --files scripts benchmarks deployment -g '*.ps1')) {
        $tokens=$null;$errors=$null
        $null=[Management.Automation.Language.Parser]::ParseFile((Join-Path $taskRoot $path),[ref]$tokens,[ref]$errors)
        if($errors.Count -gt 0){throw ('PowerShell syntax errors in '+$path)}
        $comments=@($tokens | Where-Object {$_.Kind -eq 'Comment' -and $_.Text -notmatch '^(#!|#requires)' -and $_.Text -notmatch '(?i)copyright|SPDX-License-Identifier'})
        if($comments.Count -eq 0){continue}
        if(-not $Fix){Write-Output ($path+': '+$comments.Count+' explanatory comments');$failed=$true;continue}
        $text=[IO.File]::ReadAllText((Join-Path $taskRoot $path))
        foreach($comment in @($comments | Sort-Object {$_.Extent.StartOffset} -Descending)) {
            $start=$comment.Extent.StartOffset;$end=$comment.Extent.EndOffset
            $replacement=[regex]::Replace($text.Substring($start,$end-$start),'[^\r\n]',' ')
            $text=$text.Substring(0,$start)+$replacement+$text.Substring($end)
        }
        $text=[regex]::Replace($text,'[\t ]+(?=\r?$)','',[Text.RegularExpressions.RegexOptions]::Multiline)
        [IO.File]::WriteAllText((Join-Path $taskRoot $path),$text,[Text.UTF8Encoding]::new($false))
    }
    if($failed){throw 'PowerShell code contains explanatory comments.'}
} finally {Pop-Location}
