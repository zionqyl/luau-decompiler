function Copy-RuntimeLicenses([string]$Root,[string]$Output,[string]$RustTarget){
    $metadata=(& cargo metadata --offline --locked --format-version 1 --filter-platform $RustTarget|ConvertFrom-Json)
    if($LASTEXITCODE -ne 0){throw 'Cannot resolve the shipped Cargo dependency closure'}
    $nodes=@{};foreach($node in $metadata.resolve.nodes){$nodes[$node.id]=$node}
    $packages=@{};foreach($package in $metadata.packages){$packages[$package.id]=$package}
    $visited=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $queue=[Collections.Generic.Queue[string]]::new();$queue.Enqueue($metadata.resolve.root)
    $records=[Collections.Generic.List[object]]::new()
    $notices=Join-Path $Output 'third-party-licenses';New-Item -ItemType Directory -Path $notices -Force|Out-Null
    while($queue.Count){
        $id=$queue.Dequeue();if(-not $visited.Add($id)){continue}
        foreach($dependency in $nodes[$id].deps){$queue.Enqueue($dependency.pkg)}
        $package=$packages[$id]
        if($id -ceq $metadata.resolve.root){continue}
        $source=Split-Path -Parent $package.manifest_path
        $licenses=@(Get-ChildItem -LiteralPath $source -File|Where-Object{$_.Name -match '(?i)license|^copyright$|^notice'})
        if($package.license_file){$licenseFile=Get-Item -LiteralPath (Join-Path $source $package.license_file);if($licenses.FullName -notcontains $licenseFile.FullName){$licenses+=$licenseFile}}
        if(-not $licenses.Count){throw ('No license notice found for shipped dependency '+$package.name)}
        $directory=Join-Path $notices ($package.name+'-'+$package.version);New-Item -ItemType Directory -Path $directory -Force|Out-Null
        foreach($license in $licenses){Copy-Item -LiteralPath $license.FullName -Destination (Join-Path $directory $license.Name)}
        $records.Add([ordered]@{name=$package.name;version=$package.version;license=$package.license;notice_files=@($licenses.Name)})
    }
    foreach($name in @('LICENSE.txt','lua_LICENSE.txt')){Copy-Item -LiteralPath (Join-Path $Root ('vendor/luau-modern/'+$name)) -Destination (Join-Path $notices ('Luau-'+$name))}
    $sysroot=(& rustc --print sysroot)
    if($LASTEXITCODE -ne 0){throw 'Cannot locate Rust runtime attribution'}
    $rustCopyright=Join-Path $sysroot 'share/doc/rust/COPYRIGHT-library.html'
    if(-not(Test-Path -LiteralPath $rustCopyright)){throw 'Rust standard-library attribution is missing'}
    Copy-Item -LiteralPath $rustCopyright -Destination (Join-Path $notices 'Rust-COPYRIGHT-library.html')
    $toolchain=Get-Content -LiteralPath (Join-Path $Root 'licenses/toolchain/manifest.json') -Raw|ConvertFrom-Json
    foreach($file in $toolchain.files){$path=Join-Path $Root ('licenses/toolchain/'+$file.path);if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $file.sha256){throw 'Toolchain notice differs from its pinned identity'};Copy-Item -LiteralPath $path -Destination (Join-Path $notices $file.path)}
    $closure=[ordered]@{schema=1;target=$RustTarget;selection='Reachable Cargo root dependency graph after target filtering, including code-generating proc macros; unrelated cache crates excluded';rust=(& rustc --version);dependencies=@($records.ToArray()|Sort-Object name,version);tools=@('Pinned Luau analyzer/compiler/VM libraries and embedded Lua VM','Pinned luau-lsp Roblox definitions at definitions/LICENSE-luau-lsp','Rust standard-library attribution from the selected sysroot','Static GCC/libstdc++ runtime with GCC Runtime Library Exception; MinGW-w64 runtime');toolchain_notices=$toolchain}
    [IO.File]::WriteAllText((Join-Path $notices 'closure.json'),($closure|ConvertTo-Json -Depth 10),[Text.UTF8Encoding]::new($false))
    return $closure
}

function New-RuntimePackage([string]$Root,[string]$Output,[string]$Version,[string]$Cli,[string]$Analyzer,[string]$AnalyzerManifest,$Provenance){
    $layout=Get-Content -LiteralPath (Join-Path $Root 'runtime-layout.json') -Raw|ConvertFrom-Json
    if($layout.schema -ne 1 -or $layout.product -cne 'luau-decompiler'){throw 'Invalid runtime layout'}
    New-Item -ItemType Directory -Path (Join-Path $Output 'bin') -Force|Out-Null
    foreach($entry in $layout.files){
        if($entry.target -and $entry.target -cne 'windows-x64'){continue}
        $destination=Join-Path $Output $entry.destination
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force|Out-Null
        Copy-Item -LiteralPath (Join-Path $Root $entry.source) -Destination $destination
    }
    Copy-Item -LiteralPath $Cli -Destination (Join-Path $Output 'bin/luau-decompile.exe')
    Copy-Item -LiteralPath $Analyzer -Destination (Join-Path $Output 'bin/luau-quality.exe')
    Copy-Item -LiteralPath $AnalyzerManifest -Destination (Join-Path $Output 'bin/luau-quality.exe.manifest.json')
    $null=Copy-RuntimeLicenses $Root $Output 'x86_64-pc-windows-gnu'
    $usage=@'
# Luau decompiler runtime

This complete Windows x64 runtime works offline without Roblox, an executor, an account, Rust, Python or a C++ compiler.

```powershell
./bin/luau-decompile.exe doctor --json
./bin/luau-decompile.exe decompile ./checks/verified.luau --policy verified-typed -o output.luau --quality-report quality.json
```

Install per user from this downloaded archive and its checksum sidecar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./install.ps1 -Archive PATH_TO_THIS_RUNTIME_ZIP -Preview
```

The installer reports an immediately usable executable path. `install.ps1 -Doctor`, `-Rollback` and `-Uninstall` use its ownership metadata. User configuration and modified files are preserved. The archive checksum and runtime manifest verify integrity; they are not a publisher signature.

Supported input is the declared Luau bytecode profiles and source subset shown by `capabilities`; standard Lua/LuaJIT bytecode is rejected. Failed verified typing retains faithful output and returns a nonzero status. Detailed source and versioned evidence are distributed separately. The configured repository in release.json is the canonical documentation location. MIT license and required notices are included.
'@
    $usage=$usage.Replace('PATH_TO_THIS_RUNTIME_ZIP',('../luau-decompiler-'+$Version+'-windows-x64.zip'))
    [IO.File]::WriteAllText((Join-Path $Output 'README.md'),$usage,[Text.UTF8Encoding]::new($false))
    $files=@(Get-ChildItem -LiteralPath $Output -Recurse -File|Sort-Object FullName|ForEach-Object{[ordered]@{path=$_.FullName.Substring($Output.Length+1).Replace('\','/');bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}})
    $manifest=[ordered]@{schema=1;product='luau-decompiler';version=$Version;target='windows-x64';files=$files;provenance=$Provenance;validation='Bounded installation diagnosis and comprehensive extracted artifact acceptance are separate recorded checks.'}
    [IO.File]::WriteAllText((Join-Path $Output 'runtime-manifest.json'),($manifest|ConvertTo-Json -Depth 12),[Text.UTF8Encoding]::new($false))
    return $manifest
}

function Write-PortableZip([string]$Directory,[string]$Archive){
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if(Test-Path -LiteralPath $Archive){throw ('Refusing to replace an existing release archive: '+$Archive)}
    $zip=[IO.Compression.ZipFile]::Open($Archive,[IO.Compression.ZipArchiveMode]::Create)
    try{foreach($file in @(Get-ChildItem -LiteralPath $Directory -Recurse -File|Sort-Object FullName)){$name=$file.FullName.Substring($Directory.Length+1).Replace('\','/');$null=[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$file.FullName,$name,[IO.Compression.CompressionLevel]::Optimal)}}finally{$zip.Dispose()}
    $hash=(Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllText(($Archive+'.sha256'),($hash+'  '+[IO.Path]::GetFileName($Archive)+"`n"),[Text.UTF8Encoding]::new($false))
    return $hash
}

function Write-SourceZip([string]$Root,$Files,[string]$SnapshotJson,[string]$Archive){
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if(Test-Path -LiteralPath $Archive){throw ('Refusing to replace an existing source archive: '+$Archive)}
    $zip=[IO.Compression.ZipFile]::Open($Archive,[IO.Compression.ZipArchiveMode]::Create)
    try{
        foreach($file in $Files){
            $name=[string]$file.path
            if(-not $name -or $name -eq 'source-manifest.json' -or [IO.Path]::IsPathRooted($name) -or $name -match '(^|/)\.\.?(/|$)' -or $name.Contains('\') -or $name.Contains(':')){throw 'Unsafe source archive member'}
            $absolute=[IO.Path]::GetFullPath((Join-Path $Root $name))
            if($env:OS -eq 'Windows_NT' -and -not $absolute.StartsWith('\\?\')){$absolute='\\?\'+$absolute}
            $input=[IO.File]::OpenRead($absolute)
            try{
                $algorithm=[Security.Cryptography.SHA256]::Create()
                try{$hash=([BitConverter]::ToString($algorithm.ComputeHash($input))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
                if($hash -cne $file.sha256){throw ('Source changed before packaging: '+$name)}
                $input.Position=0
                $entry=$zip.CreateEntry($name,[IO.Compression.CompressionLevel]::Optimal)
                $output=$entry.Open()
                try{$input.CopyTo($output)}finally{$output.Dispose()}
            }finally{$input.Dispose()}
        }
        $entry=$zip.CreateEntry('source-manifest.json',[IO.Compression.CompressionLevel]::Optimal)
        $output=$entry.Open()
        try{$bytes=[Text.UTF8Encoding]::new($false).GetBytes($SnapshotJson);$output.Write($bytes,0,$bytes.Length)}finally{$output.Dispose()}
    }finally{$zip.Dispose()}
    $hash=(Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllText(($Archive+'.sha256'),($hash+'  '+[IO.Path]::GetFileName($Archive)+"`n"),[Text.UTF8Encoding]::new($false))
    return $hash
}
