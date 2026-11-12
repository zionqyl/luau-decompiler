param(
    [string] $Corpus = (Join-Path $PSScriptRoot '../tests/corpus'),
    [string] $Destination = (Join-Path $PSScriptRoot '../tests/profile-fixtures'),
    [switch] $IncludeNewSources
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$specifications = @(
    @{ version=7; tool='luau-0.726'; flags='LuauEmitCallFeedback=false,DebugLuauUserDefinedClasses=false,LuauCompileUdataDirect=false,LuauIntegerType2=false'; tag='0.726' },
    @{ version=8; tool='luau-0.726'; flags='LuauEmitCallFeedback=false,DebugLuauUserDefinedClasses=false,LuauCompileUdataDirect=false,LuauIntegerType2=true'; tag='0.726' },
    @{ version=9; tool='luau-0.730'; flags='LuauBytecodeCostModel=false,LuauEmitCallFeedback=false,DebugLuauUserDefinedClasses=false'; tag='0.730' },
    @{ version=10; tool='luau-0.726'; flags='LuauEmitCallFeedback=false,DebugLuauUserDefinedClasses=true'; tag='0.726' },
    @{ version=11; tool='luau-0.726'; flags='LuauEmitCallFeedback=true,DebugLuauUserDefinedClasses=false'; tag='0.726' },
    @{ version=12; tool='luau-0.730'; flags='LuauBytecodeCostModel=true,DebugLuauUserDefinedClasses=false'; tag='0.730' },
    @{ version=13; tool='luau-modern'; flags='LuauCompileFastpcall=false,DebugLuauUserDefinedClasses=false'; tag='0.746' },
    @{ version=14; tool='luau-modern'; flags='LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false'; tag='0.746' }
)
$lock = Get-Content -LiteralPath (Join-Path $taskRoot 'upstream.profiles.lock.json') -Raw | ConvertFrom-Json
$manifest = [System.Collections.Generic.List[object]]::new()
$sourceFiles = @(Get-ChildItem -LiteralPath $Corpus -Filter '*.luau' | Sort-Object Name)
$existingManifest = Join-Path $Destination 'manifest.json'
if (-not $IncludeNewSources -and (Test-Path -LiteralPath $existingManifest)) {


    $sourceNames = @((Get-Content -LiteralPath $existingManifest -Raw | ConvertFrom-Json).fixtures.source | Sort-Object -Unique)
    $sourceFiles = @($sourceFiles | Where-Object { $sourceNames -contains $_.Name })
    if ($sourceFiles.Count -ne $sourceNames.Count) { throw 'A pinned profile source is missing from the corpus' }
}
foreach ($specification in $specifications) {
    $profileLock = $lock.profiles | Where-Object { $_.tag -eq $specification.tag }
    $compiler = Join-Path $taskRoot ('.tools/' + $specification.tool + '/luau-compile.exe')
    if ((Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash.ToLowerInvariant() -ne $profileLock.windows_compiler_sha256) { throw 'Compiler checksum mismatch' }
    $profileDirectory = Join-Path $Destination ('v' + $specification.version)
    New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    foreach ($source in $sourceFiles) {
        foreach ($optimization in 0..2) { foreach ($debug in 0..2) {
            $start = [System.Diagnostics.ProcessStartInfo]::new()
            $start.FileName = $compiler
            $start.Arguments = '--binary -O' + $optimization + ' -g' + $debug
            if ($specification.flags) { $start.Arguments += ' --fflags=' + $specification.flags }
            $start.Arguments += ' "' + $source.FullName + '"'
            $start.UseShellExecute = $false
            $start.CreateNoWindow = $true
            $start.RedirectStandardOutput = $true
            $start.RedirectStandardError = $true
            $process = [System.Diagnostics.Process]::new()
            $process.StartInfo = $start
            [void] $process.Start()
            $errors = $process.StandardError.ReadToEndAsync()
            $buffer = [System.IO.MemoryStream]::new()
            $process.StandardOutput.BaseStream.CopyTo($buffer)
            $process.WaitForExit()
            $stderr = $errors.GetAwaiter().GetResult()
            $bytes = $buffer.ToArray()
            if ($process.ExitCode -ne 0 -or $bytes.Length -eq 0 -or $bytes[0] -ne $specification.version) { throw ('Compiler profile mismatch for v' + $specification.version + ': ' + $stderr) }
            $name = $source.BaseName + '.O' + $optimization + '.D' + $debug + '.bc'
            $path = Join-Path $profileDirectory $name
            [System.IO.File]::WriteAllBytes($path, $bytes)
            $manifest.Add([ordered] @{
                profile = 'luau-v' + $specification.version
                version = $specification.version
                upstream_tag = $specification.tag
                upstream_revision = $profileLock.revision
                compiler_sha256 = $profileLock.windows_compiler_sha256
                compiler_flags = $specification.flags
                source = $source.Name
                source_sha256 = (Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
                optimization = $optimization
                debug = $debug
                bytecode = 'v' + $specification.version + '/' + $name
                bytes = $bytes.Length
                sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
            })
            $buffer.Dispose()
            $process.Dispose()
        } }
    }
}
$data = [ordered] @{ schema_version=1; fixtures=@($manifest.ToArray()) }
[System.IO.File]::WriteAllText((Join-Path $Destination 'manifest.json'), ($data | ConvertTo-Json -Depth 5) + "`n", [System.Text.UTF8Encoding]::new($false))
Write-Output ('Generated ' + $manifest.Count + ' exact-version compiler fixtures')
