param(
    [string]$Version,
    [switch]$Preview,
    [string]$Destination=(Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'LuauDecompiler'),
    [string]$Archive,
    [string]$ExpectedSha256,
    [string]$Repository,
    [string]$ReleaseApi,
    [switch]$NoPath,
    [switch]$Uninstall,
    [switch]$Rollback,
    [switch]$RepairManagement,
    [switch]$Doctor,
    [switch]$Json
)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$utf8=[Text.UTF8Encoding]::new($false,$true)
$product='luau-decompiler'
$root=[IO.Path]::GetFullPath($Destination).TrimEnd('\','/')
$metadataPath=Join-Path $root '.luau-installation.json'
$pointerPath=Join-Path $root 'current'
$lockPath=Join-Path $root '.install.lock'
$activationPath=Join-Path $root '.luau-activation.json'
$bootstrapPath=Join-Path $root '.luau-bootstrap.json'
function Hash([string]$Path){
    $stream=[IO.File]::OpenRead($Path)
    try{
        $algorithm=[Security.Cryptography.SHA256]::Create()
        try{([BitConverter]::ToString($algorithm.ComputeHash($stream))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
    }finally{$stream.Dispose()}
}
function Hash-Bytes([byte[]]$Bytes){$algorithm=[Security.Cryptography.SHA256]::Create();try{([BitConverter]::ToString($algorithm.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}}
function Emit-Json($Value){$text=$Value|ConvertTo-Json -Depth 20;[regex]::Replace($text,'[^\x00-\x7f]',{param($match)'\u'+([int][char]$match.Value).ToString('x4')})}
function Atomic-Bytes([string]$Path,[byte[]]$Bytes){
    $temporary=$Path+'.new-'+[Guid]::NewGuid().ToString('N')
    try{
        $stream=[IO.FileStream]::new($temporary,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None,4096,[IO.FileOptions]::WriteThrough)
        try{$stream.Write($Bytes,0,$Bytes.Length);$stream.Flush($true)}finally{$stream.Dispose()}
        if(Test-Path -LiteralPath $Path){$backup=$Path+'.previous-'+[Guid]::NewGuid().ToString('N');[IO.File]::Replace($temporary,$Path,$backup);Remove-Item -LiteralPath $backup}else{[IO.File]::Move($temporary,$Path)}
    }finally{if(Test-Path -LiteralPath $temporary){Remove-Item -LiteralPath $temporary}}
}
function Atomic-Text([string]$Path,[string]$Value){Atomic-Bytes $Path ($utf8.GetBytes($Value))}
function Safe-Path([string]$Base,[string]$Relative){
    if([IO.Path]::IsPathRooted($Relative) -or $Relative -match '(^|[/\\])\.\.([/\\]|$)' -or $Relative.Contains(':')){throw 'Unsafe package or ownership path'}
    $path=[IO.Path]::GetFullPath((Join-Path $Base $Relative))
    if(-not $path.StartsWith($Base.TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Path escapes installation directory'}
    $parent=$path
    while($parent -and $parent -ine $Base){if((Test-Path -LiteralPath $parent) -and ((Get-Item -LiteralPath $parent -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'A managed path contains a symbolic link or junction'};$parent=[IO.Path]::GetDirectoryName($parent)}
    return $path
}
function Read-Metadata([switch]$Snapshot) {
    if(-not(Test-Path -LiteralPath $metadataPath)){if($Snapshot){return @{value=$null;sha256=$null}};return $null}
    $bytes=[IO.File]::ReadAllBytes($metadataPath)
    $value=$utf8.GetString($bytes)|ConvertFrom-Json
    if($value.schema -ne 1 -or $value.product -cne $product -or $value.installation_id -cnotmatch '^[0-9a-f]{32}$'){throw 'Destination is not a recognized managed installation'}
    foreach($entry in @($value.versions)){if($entry.path -cnotmatch '^versions/[0-9A-Za-z.-]+$'){throw 'Invalid installed version ownership metadata'}}
    if($Snapshot){return @{value=$value;sha256=(Hash-Bytes $bytes)}}
    return $value
}
function Assert-RootOwnership($Metadata,[string[]]$Names){
    if($Metadata){foreach($entry in @($Metadata.root_files)){if($entry.path -notin @('current','luau-decompile.cmd','install.ps1','release.json') -or $entry.sha256 -cnotmatch '^[0-9a-f]{64}$'){throw 'Invalid root ownership entry'}}}
    foreach($name in $Names){
        $path=Safe-Path $root $name
        if(-not(Test-Path -LiteralPath $path)){continue}
        $owned=@();if($Metadata){$owned=@($Metadata.root_files|Where-Object{$_.path -ceq $name})}
        if($owned.Count -ne 1 -or -not(Test-Path -LiteralPath $path -PathType Leaf) -or (Hash $path) -cne $owned[0].sha256){throw ('Modified or unowned management file was preserved: '+$name+'; move it explicitly or choose another destination')}
    }
}
function Check-Manifest([string]$Directory){
    $manifestPath=Join-Path $Directory 'runtime-manifest.json'
    if(-not(Test-Path -LiteralPath $manifestPath)){throw 'Archive is not a compact Luau runtime package with runtime-manifest.json'}
    $manifest=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json
    if($manifest.schema -ne 1 -or $manifest.product -cne $product -or $manifest.target -cne 'windows-x64' -or $manifest.version -cnotmatch '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$'){throw 'Runtime manifest product, version, or target is unsupported'}
    $seen=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach($file in @($manifest.files)){
        $path=Safe-Path $Directory $file.path
        if(-not $seen.Add($file.path) -or $file.sha256 -cnotmatch '^[0-9a-f]{64}$' -or -not(Test-Path -LiteralPath $path -PathType Leaf) -or (Get-Item -LiteralPath $path).Length -ne $file.bytes -or (Hash $path) -cne $file.sha256){throw ('Runtime integrity check failed: '+$file.path)}
    }
    if(@(Get-ChildItem -LiteralPath $Directory -Recurse -Force -File).Count -ne $seen.Count+1){throw 'Runtime contains files outside its integrity manifest'}
    return $manifest
}
function Run-Check([string]$Directory){
    $manifest=Check-Manifest $Directory
    $executable=Join-Path $Directory 'bin/luau-decompile.exe'
    $start=[Diagnostics.ProcessStartInfo]::new($executable)
    $start.Arguments='doctor --json';$start.WorkingDirectory=$Directory
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    $child=[Diagnostics.Process]::Start($start)
    $output=$child.StandardOutput.ReadToEndAsync();$errors=$child.StandardError.ReadToEndAsync()
    try{
        if(-not $child.WaitForExit(30000)){$child.Kill();$child.WaitForExit();throw 'Installation diagnosis exceeded 30 seconds'}
        if($child.ExitCode -ne 0){$reason=$errors.Result;try{$failed=$output.Result|ConvertFrom-Json;if($failed.error){$reason=$failed.error}elseif(@($failed.validation.diagnostics).Count){$reason=$failed.validation.diagnostics[0].message}}catch{};throw ('Installation diagnosis failed before activation: '+$reason.Substring(0,[Math]::Min(2000,$reason.Length)))}
        $result=$output.Result|ConvertFrom-Json
        if(-not $result.passed -or $result.version -cne $manifest.version){throw 'Installed components did not pass the matching-version verified-typed diagnosis'}
        return $result
    }finally{$child.Dispose()}
}
function Command-Shim {
    '@echo off'+"`r`n"+'setlocal'+"`r`n"+'set /p "LUAU_TARGET="<"%~dp0current"'+"`r`n"+'"%~dp0%LUAU_TARGET%\bin\luau-decompile.exe" %*'+"`r`n"+'exit /b %errorlevel%'+"`r`n"
}
function Cleanup-Stage([string]$Path){
    if(-not $Path -or -not(Test-Path -LiteralPath $Path)){return}
    $resolved=[IO.Path]::GetFullPath($Path)
    if([IO.Path]::GetDirectoryName($resolved) -ine $root -or [IO.Path]::GetFileName($resolved) -cnotmatch '^\.staging-[0-9a-f]{32}$' -or ((Get-Item -LiteralPath $resolved -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'Refusing unexpected staging cleanup target'}
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
function Read-Bootstrap {
    if(-not(Test-Path -LiteralPath $bootstrapPath -PathType Leaf)){return $null}
    if((Get-Item -LiteralPath $bootstrapPath).Length -gt 16384){throw 'Bootstrap ownership exceeds its size limit'}
    $plan=Get-Content -LiteralPath $bootstrapPath -Raw|ConvertFrom-Json
    if($plan.schema -ne 1 -or $plan.product -cne $product -or $plan.transaction_id -cnotmatch '^[0-9a-f]{32}$' -or $plan.installation_id -cnotmatch '^[0-9a-f]{32}$' -or $plan.stage_name -cne ('.staging-'+$plan.transaction_id)){throw 'Invalid bootstrap transaction ownership'}
    if($plan.previous_metadata_sha256 -and $plan.previous_metadata_sha256 -cnotmatch '^[0-9a-f]{64}$'){throw 'Invalid bootstrap metadata identity'}
    if($plan.target_path -and ($plan.target_path -cnotmatch '^versions/[0-9A-Za-z.-]+$' -or $plan.target_manifest_sha256 -cnotmatch '^[0-9a-f]{64}$')){throw 'Invalid bootstrap version ownership'}
    return $plan
}
function Recover-Bootstrap {
    $plan=Read-Bootstrap
    if(-not $plan){return}
    if(Test-Path -LiteralPath $activationPath){throw 'Pending activation must complete before bootstrap cleanup'}
    $snapshot=Read-Metadata -Snapshot
    $registered=@();if($snapshot.value -and $plan.target_path){$registered=@($snapshot.value.versions|Where-Object{$_.path -ceq $plan.target_path -and $_.manifest_sha256 -ceq $plan.target_manifest_sha256})}
    $committed=$snapshot.value -and $snapshot.value.installation_id -ceq $plan.installation_id -and $registered.Count -eq 1
    if(-not $committed -and $snapshot.sha256 -cne $plan.previous_metadata_sha256){throw 'Ownership changed during bootstrap; transaction files were preserved'}
    $staging=Safe-Path $root $plan.stage_name
    if(Test-Path -LiteralPath $staging){
        $marker=Safe-Path $staging '.luau-stage-owner.json'
        if(Test-Path -LiteralPath $marker -PathType Leaf){
            if((Get-Item -LiteralPath $marker).Length -gt 1024){throw 'Staging ownership exceeds its size limit'}
            $owner=Get-Content -LiteralPath $marker -Raw|ConvertFrom-Json
            if($owner.transaction_id -cne $plan.transaction_id -or $owner.installation_id -cne $plan.installation_id -or $owner.product -cne $product){throw 'Staging ownership changed; existing files were preserved'}
            if(@(Get-ChildItem -LiteralPath $staging -Recurse -Force|Where-Object{$_.Attributes -band [IO.FileAttributes]::ReparsePoint}).Count){throw 'Transaction staging contains a symbolic link or junction; files were preserved'}
        }elseif(@(Get-ChildItem -LiteralPath $staging -Force).Count){throw 'Nonempty staging lacks matching ownership; files were preserved'}
        Cleanup-Stage $staging
    }
    if($plan.target_path -and $plan.owns_target -and -not $committed){
        $target=Safe-Path $root $plan.target_path
        if(Test-Path -LiteralPath $target){Remove-Version @{path=$plan.target_path;manifest_sha256=$plan.target_manifest_sha256}}
    }
    $versions=Safe-Path $root 'versions'
    if($plan.created_versions -and (Test-Path -LiteralPath $versions -PathType Container) -and -not @(Get-ChildItem -LiteralPath $versions -Force).Count){Remove-Item -LiteralPath $versions}
    Remove-Item -LiteralPath $bootstrapPath
}
function Complete-Activation {
    if(-not(Test-Path -LiteralPath $activationPath)){return}
    if((Get-Item -LiteralPath $activationPath).Length -gt 1048576){throw 'Activation journal exceeds its size limit'}
    $plan=Get-Content -LiteralPath $activationPath -Raw|ConvertFrom-Json
    if($plan.schema -ne 1 -or $plan.product -cne $product -or $plan.target_path -cnotmatch '^versions/[0-9A-Za-z.-]+$' -or -not $plan.metadata_json -or $plan.metadata_json.Length -gt 524288){throw 'Invalid pending activation journal'}
    if($plan.stage_name -and $plan.stage_name -cnotmatch '^\.staging-[0-9a-f]{32}$'){throw 'Invalid activation staging ownership'}
    $metadata=$plan.metadata_json|ConvertFrom-Json
    if($metadata.schema -ne 1 -or $metadata.product -cne $product -or $metadata.installation_id -cnotmatch '^[0-9a-f]{32}$'){throw 'Invalid activation ownership metadata'}
    foreach($entry in @($metadata.versions)){if($entry.path -cnotmatch '^versions/[0-9A-Za-z.-]+$'){throw 'Invalid activation version ownership'}}
    $owners=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach($entry in @($metadata.root_files)){if($entry.path -notin @('install.ps1','release.json','luau-decompile.cmd','current') -or $entry.sha256 -cnotmatch '^[0-9a-f]{64}$' -or -not $owners.Add($entry.path)){throw 'Invalid activation root ownership'}}
    $targetHash=Hash-Bytes ($utf8.GetBytes($plan.metadata_json))
    $actualMetadata=$null;if(Test-Path -LiteralPath $metadataPath){$actualMetadata=Hash $metadataPath}
    if($actualMetadata -cne $plan.previous_metadata_sha256 -and $actualMetadata -cne $targetHash){throw 'Installation metadata changed during activation; pending recovery was preserved'}
    $directory=Safe-Path $root $plan.target_path
    $manifest=Check-Manifest $directory
    $selected=@($metadata.versions|Where-Object{$_.path -ceq $plan.target_path})
    if($manifest.version -cne $metadata.current_version -or $selected.Count -ne 1 -or $selected[0].manifest_sha256 -cne (Hash (Join-Path $directory 'runtime-manifest.json'))){throw 'Pending activation does not match the verified runtime'}
    $seen=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    if(@($plan.writes).Count -lt 1 -or @($plan.writes).Count -gt 4){throw 'Invalid activation write count'}
    foreach($write in $plan.writes){
        if($write.path -notin @('install.ps1','release.json','luau-decompile.cmd','current') -or -not $seen.Add($write.path) -or $write.sha256 -cnotmatch '^[0-9a-f]{64}$'){throw 'Invalid activation write ownership'}
        if($write.source){
            if($write.source -cne $write.path -or $write.source -notin @('install.ps1','release.json')){throw 'Invalid activation management source'}
            $source=Safe-Path $directory $write.source
            $entry=@($manifest.files|Where-Object{$_.path -ceq $write.source})
            if($entry.Count -ne 1 -or $entry[0].sha256 -cne $write.sha256){throw 'Management source is not owned by the verified release'}
            $bytes=[IO.File]::ReadAllBytes($source)
        }else{
            $expected=$(if($write.path -ceq 'current'){$plan.target_path+"`n"}elseif($write.path -ceq 'luau-decompile.cmd'){Command-Shim}else{throw 'Invalid inline activation file'})
            if($write.text -cne $expected){throw 'Pending management text is not canonical'}
            $bytes=$utf8.GetBytes($write.text)
        }
        if((Hash-Bytes $bytes) -cne $write.sha256){throw 'Pending management bytes changed'}
        $path=Safe-Path $root $write.path
        $actual=$null;if(Test-Path -LiteralPath $path){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw 'Managed file became a directory'};$actual=Hash $path}
        if($actual -and $actual -cne $write.previous_sha256 -and $actual -cne $write.sha256){throw ('Modified management file was preserved during recovery: '+$write.path)}
        $owner=@($metadata.root_files|Where-Object{$_.path -ceq $write.path})
        if($owner.Count -ne 1 -or $owner[0].sha256 -cne $write.sha256){throw 'Pending root metadata does not own its write'}
        if($actual -cne $write.sha256){Atomic-Bytes $path $bytes}
    }
    if(-not $seen.Contains('current')){throw 'Pending activation omits its active pointer'}
    Atomic-Text $metadataPath $plan.metadata_json
    if($plan.stage_name){Cleanup-Stage (Safe-Path $root $plan.stage_name)}
    Remove-Item -LiteralPath $activationPath
}
function Activate([string]$Relative,$Metadata,[bool]$Management,$ExpectedMetadataSha,$AuthorizedPointerSha=$null){
    $snapshot=Read-Metadata -Snapshot
    $persisted=$snapshot.value
    if($snapshot.sha256 -cne $ExpectedMetadataSha){throw 'Installation ownership metadata changed before activation; existing files were preserved'}
    $names=$(if($Management){@('install.ps1','release.json','luau-decompile.cmd','current')}else{@('current')})
    if($AuthorizedPointerSha){
        Assert-RootOwnership $persisted @($names|Where-Object{$_ -cne 'current'})
        if($AuthorizedPointerSha -cnotmatch '^[0-9a-f]{64}$' -or -not(Test-Path -LiteralPath $pointerPath -PathType Leaf) -or (Hash $pointerPath) -cne $AuthorizedPointerSha){throw 'Verified active pointer changed before explicit repair; existing files were preserved'}
    }else{Assert-RootOwnership $persisted $names}
    $directory=Safe-Path $root $Relative
    $manifest=Check-Manifest $directory
    $writes=[Collections.Generic.List[object]]::new()
    foreach($name in $names){
        $text=$null;$source=$null
        if($name -in @('install.ps1','release.json')){
            $entry=@($manifest.files|Where-Object{$_.path -ceq $name})
            if($entry.Count -ne 1){throw ('Verified release is missing its management file: '+$name)}
            $source=$name;$bytes=[IO.File]::ReadAllBytes((Safe-Path $directory $name))
        }else{$text=$(if($name -ceq 'current'){$Relative+"`n"}else{Command-Shim});$bytes=$utf8.GetBytes($text)}
        $previous=$null
        if($persisted){$owner=@($persisted.root_files|Where-Object{$_.path -ceq $name});if($owner.Count -eq 1){$previous=$owner[0].sha256}}
        if($name -ceq 'current' -and $AuthorizedPointerSha){$previous=$AuthorizedPointerSha}
        $writes.Add([ordered]@{path=$name;source=$source;text=$text;previous_sha256=$previous;sha256=(Hash-Bytes $bytes)})
    }
    $rootFiles=@($Metadata.root_files|Where-Object{$_.path -notin $names})
    foreach($write in $writes){$rootFiles+=@{path=$write.path;sha256=$write.sha256}}
    $Metadata.root_files=$rootFiles
    $plan=[ordered]@{schema=1;product=$product;target_path=$Relative;previous_metadata_sha256=$ExpectedMetadataSha;metadata_json=($Metadata|ConvertTo-Json -Depth 15);writes=$writes.ToArray();stage_name=$(if($stage){[IO.Path]::GetFileName($stage)}else{$null})}
    Atomic-Text $activationPath ($plan|ConvertTo-Json -Depth 20)
    Complete-Activation
    Recover-Bootstrap
}
function Download([string]$Uri,[string]$Path,[long]$Limit){
    $address=[Uri]$Uri
    if($address.Scheme -ne 'https' -and -not($address.Scheme -eq 'http' -and $address.IsLoopback)){throw 'Release downloads require HTTPS; HTTP is permitted only for an explicit loopback mirror'}
    $request=[Net.HttpWebRequest]::Create($address)
    if($address.IsLoopback){$request.Proxy=$null}
    $request.UserAgent='luau-decompiler-installer';$request.Accept='application/vnd.github+json';$request.Timeout=30000;$request.ReadWriteTimeout=30000;$request.MaximumAutomaticRedirections=5
    $response=$request.GetResponse()
    try{
        if($response.ContentLength -gt $Limit){throw 'Release asset exceeds the bounded download limit'}
        $inputStream=$response.GetResponseStream();$outputStream=[IO.File]::Create($Path)
        try{
            $buffer=New-Object byte[] 65536;$total=0L
            while(($count=$inputStream.Read($buffer,0,$buffer.Length)) -gt 0){$total+=$count;if($total -gt $Limit){throw 'Release download exceeded its bounded size'};$outputStream.Write($buffer,0,$count)}
            if($response.ContentLength -ge 0 -and $response.ContentLength -ne $total){throw 'Release download was interrupted'}
        }finally{$inputStream.Dispose();$outputStream.Dispose()}
    }finally{$response.Dispose()}
}
function Resolve-Release([string]$Directory){
    $api=$ReleaseApi
    if(-not $api){
        if($Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'){throw 'Configure a real repository in release.json or pass -Repository owner/name'}
        $api='https://api.github.com/repos/'+$Repository+'/releases'
    }
    $catalog=Join-Path $Directory 'release.json'
    if($Version){$uri=$api.TrimEnd('/')+'/tags/v'+[Uri]::EscapeDataString($Version.TrimStart('v'))}elseif($Preview){$uri=$api.TrimEnd('/')+'?per_page=100'}else{$uri=$api.TrimEnd('/')+'/latest'}
    Download $uri $catalog 4194304
    $resolved=Get-Content -LiteralPath $catalog -Raw|ConvertFrom-Json
    if($Preview -and -not $Version){$resolved=@($resolved|Where-Object{-not $_.draft}|Sort-Object published_at -Descending|Select-Object -First 1)[0]}
    if($null -eq $resolved -or $resolved.draft -or ($resolved.prerelease -and -not $Preview)){throw 'No release is available in the requested channel; release candidates require -Preview'}
    $resolvedVersion=$resolved.tag_name -replace '^v',''
    if($resolvedVersion -cnotmatch '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$' -or ($Version -and $resolvedVersion -cne $Version.TrimStart('v'))){throw 'Resolved release version does not match the request'}
    $name='luau-decompiler-'+$resolvedVersion+'-windows-x64.zip'
    $asset=@($resolved.assets|Where-Object{$_.name -ceq $name})
    $checksum=@($resolved.assets|Where-Object{$_.name -ceq ($name+'.sha256')})
    if($asset.Count -ne 1 -or $checksum.Count -ne 1){throw ('Release is missing matching runtime/checksum assets: '+$name)}
    $archivePath=Join-Path $Directory $name
    Download $checksum[0].browser_download_url ($archivePath+'.sha256') 4096
    Download $asset[0].browser_download_url $archivePath 134217728
    return [ordered]@{version=$resolvedVersion;path=$archivePath;release_id=$resolved.id;asset_name=$name}
}
function Set-CommandPath([bool]$Remove){
    $current=[string][Environment]::GetEnvironmentVariable('Path','User')
    $parts=[Collections.Generic.List[string]]::new();foreach($part in $current.Split([char]';')){$parts.Add($part)}
    if($Remove){for($index=$parts.Count-1;$index -ge 0;$index--){if($parts[$index].TrimEnd('\','/') -ieq $root){$parts.RemoveAt($index);break}};$updated=$parts -join ';'}elseif(@($parts|Where-Object{$_.TrimEnd('\','/') -ieq $root}).Count){$updated=$current}else{$updated=$(if($current){$current+';'}else{''})+$root}
    if($updated -cne $current){[Environment]::SetEnvironmentVariable('Path',$updated,'User')}
    if($Remove){$env:PATH=(@($env:PATH -split ';'|Where-Object{$_.TrimEnd('\','/') -ine $root}) -join ';')}elseif(-not(@($env:PATH -split ';') -icontains $root)){$env:PATH=$root+';'+$env:PATH}
}
function Remove-Version($Entry){
    $directory=Safe-Path $root $Entry.path
    if(-not(Test-Path -LiteralPath $directory)){return}
    $manifestPath=Join-Path $directory 'runtime-manifest.json'
    if(-not(Test-Path -LiteralPath $manifestPath) -or (Hash $manifestPath) -cne $Entry.manifest_sha256){Write-Warning 'Modified version metadata was preserved';return}
    $manifest=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json
    $ownedParents=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach($file in $manifest.files){$path=Safe-Path $directory $file.path;$parent=[IO.Path]::GetDirectoryName($path);while($parent -and $parent -ine $directory){$null=$ownedParents.Add($parent);$parent=[IO.Path]::GetDirectoryName($parent)};if((Test-Path -LiteralPath $path -PathType Leaf) -and (Hash $path) -ceq $file.sha256){Remove-Item -LiteralPath $path -Force}}
    Remove-Item -LiteralPath $manifestPath
    foreach($path in @($ownedParents|Sort-Object Length -Descending)){if((Test-Path -LiteralPath $path) -and -not((Get-Item -LiteralPath $path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -and -not @(Get-ChildItem -LiteralPath $path -Force).Count){Remove-Item -LiteralPath $path}}
    if(-not @(Get-ChildItem -LiteralPath $directory -Force).Count){Remove-Item -LiteralPath $directory}
}
if($env:OS -ne 'Windows_NT' -or [IntPtr]::Size -ne 8 -or $env:PROCESSOR_ARCHITECTURE -notin @('AMD64','x86')){throw 'This installer supports Windows x64 only; use a validated runtime for your OS/architecture'}
$configurationCandidates=@();if($PSScriptRoot){$configurationCandidates=@((Join-Path $PSScriptRoot 'release.json'),(Join-Path (Split-Path -Parent $PSScriptRoot) 'release.json'))}
$configurationPath=$configurationCandidates|Where-Object{Test-Path -LiteralPath $_}|Select-Object -First 1
if($configurationPath){$configuration=Get-Content -LiteralPath $configurationPath -Raw|ConvertFrom-Json;if(-not $Repository){$Repository=$configuration.repository};if(-not $ReleaseApi -and $Repository -ceq $configuration.repository){$ReleaseApi=$configuration.release_api}}
if(@($Uninstall,$Rollback,$RepairManagement,$Doctor|Where-Object{$_}).Count -gt 1){throw 'Choose only one management operation'}
if(-not(Test-Path -LiteralPath $root)){New-Item -ItemType Directory -Path $root -Force|Out-Null}
if((Get-Item -LiteralPath $root -Force).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Installation destination cannot be a symbolic link or junction'}
$lock=$null;$stage=$null
try{
    for($attempt=0;$attempt -lt 50;$attempt++){try{$lock=[IO.File]::Open($lockPath,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None);break}catch [IO.IOException]{Start-Sleep -Milliseconds 100}}
    if(-not $lock){throw 'Another installation operation is active; retry after it finishes'}
    Complete-Activation
    Recover-Bootstrap
    $existingSnapshot=Read-Metadata -Snapshot
    $existing=$existingSnapshot.value
    $existingMetadataHash=$existingSnapshot.sha256
    if(-not $existing -and @(Get-ChildItem -LiteralPath $root -Force|Where-Object{$_.Name -cne '.install.lock'}).Count){throw 'Destination contains unowned files; choose an empty directory or an existing managed installation'}
    if($Doctor){
        if(-not $existing){throw 'No managed installation exists at the destination'}
        $pointerBytes=[IO.File]::ReadAllBytes($pointerPath)
        $relative=$utf8.GetString($pointerBytes).Trim()
        if($relative -cnotmatch '^versions/[0-9A-Za-z.-]+$'){throw 'Invalid active installation pointer'}
        Assert-RootOwnership $existing @('current')
        $entry=@($existing.versions|Where-Object{$_.path -ceq $relative -and $_.version -ceq $existing.current_version})
        if($entry.Count -ne 1){throw 'Active runtime differs from ownership metadata; run the verified active payload installer with -RepairManagement'}
        $result=Run-Check (Safe-Path $root $relative)
        if($Json){Emit-Json $result}else{Write-Output ('Installation diagnosis passed: '+$result.version)}
        return
    }
    if($RepairManagement){
        if(-not $existing -or -not(Test-Path -LiteralPath $pointerPath -PathType Leaf)){throw 'No active managed runtime is available for management repair'}
        $pointerBytes=[IO.File]::ReadAllBytes($pointerPath)
        $relative=$utf8.GetString($pointerBytes).Trim()
        if($relative -cnotmatch '^versions/[0-9A-Za-z.-]+$'){throw 'Invalid active installation pointer'}
        $directory=Safe-Path $root $relative
        $manifest=Check-Manifest $directory
        $installer=Safe-Path $directory 'install.ps1'
        if(-not $PSCommandPath -or [IO.Path]::GetFullPath($PSCommandPath) -ine $installer){throw 'Run -RepairManagement using install.ps1 inside the verified active version directory'}
        Assert-RootOwnership $existing @('install.ps1','release.json','luau-decompile.cmd')
        $null=Run-Check $directory
        $prior=@($existing.versions|Where-Object{$_.path -ceq $relative})
        $entry=$(if($prior.Count -eq 1){$prior[0]}else{@{version=$manifest.version;path=$relative;manifest_sha256=(Hash (Join-Path $directory 'runtime-manifest.json'));archive_sha256=$null;recovered_from_active_manifest=$true}})
        $existing.versions=@(@($existing.versions|Where-Object{$_.path -cne $relative})+$entry)
        $existing.current_version=$manifest.version
        if($existing.PSObject.Properties.Name -contains 'uninstalled'){$existing.uninstalled=$false}
        Activate $relative $existing $true $existingMetadataHash (Hash-Bytes $pointerBytes)
        if($Json){Emit-Json @{passed=$true;version=$manifest.version;repaired_management=$true}}else{Write-Output ('Verified payload management files repaired for '+$manifest.version)}
        return
    }
    if($Uninstall){
        if(-not $existing){throw 'No managed installation exists at the destination'}
        foreach($entry in $existing.versions){Remove-Version $entry}
        foreach($name in @('current','luau-decompile.cmd','install.ps1','release.json')){$path=Join-Path $root $name;if(Test-Path -LiteralPath $path -PathType Leaf){$ownership=@($existing.root_files|Where-Object{$_.path -ceq $name});if($ownership.Count -eq 1 -and (Hash $path) -ceq $ownership[0].sha256){Remove-Item -LiteralPath $path -Force}}}
        if($existing.path_added -and -not $NoPath){Set-CommandPath $true}
        Atomic-Text $metadataPath (@{schema=1;product=$product;installation_id=$existing.installation_id;current_version=$null;versions=@();root_files=@();path_added=$false;uninstalled=$true}|ConvertTo-Json -Depth 5)
        Write-Output 'Owned payload files removed; ownership marker, user configuration and modified files were preserved.'
        return
    }
    if($Rollback){
        if(-not $existing -or @($existing.versions).Count -lt 2){throw 'No previous managed runtime is available for rollback'}
        $entry=@($existing.versions)[@($existing.versions).Count-2]
        Assert-RootOwnership $existing @('current')
        $null=Run-Check (Safe-Path $root $entry.path)
        $existing.versions=@(@($existing.versions|Where-Object{$_.path -cne $entry.path})+$entry)
        $existing.current_version=$entry.version
        Activate $entry.path $existing $false $existingMetadataHash
        Write-Output ('Rolled back to '+$entry.version)
        return
    }
    Assert-RootOwnership $existing @('install.ps1','release.json','luau-decompile.cmd','current')
    $transactionId=[Guid]::NewGuid().ToString('N')
    $installationId=$(if($existing){$existing.installation_id}else{[Guid]::NewGuid().ToString('N')})
    $bootstrap=[ordered]@{schema=1;product=$product;transaction_id=$transactionId;installation_id=$installationId;stage_name=('.staging-'+$transactionId);previous_metadata_sha256=$existingMetadataHash;target_path=$null;target_manifest_sha256=$null;owns_target=$false;created_versions=(-not(Test-Path -LiteralPath (Join-Path $root 'versions')))}
    Atomic-Text $bootstrapPath ($bootstrap|ConvertTo-Json -Depth 5)
    $stage=Join-Path $root $bootstrap.stage_name
    New-Item -ItemType Directory -Path $stage|Out-Null
    Atomic-Text (Join-Path $stage '.luau-stage-owner.json') (@{product=$product;transaction_id=$transactionId;installation_id=$installationId}|ConvertTo-Json)
    $resolved=$null
    if($Archive){$archivePath=(Resolve-Path -LiteralPath $Archive).Path}else{$resolved=Resolve-Release $stage;$archivePath=$resolved.path}
    $expected=$ExpectedSha256
    if(-not $expected){$checksumPath=$archivePath+'.sha256';if(-not(Test-Path -LiteralPath $checksumPath)){throw 'Provide the publisher checksum sidecar or -ExpectedSha256'};$expected=((Get-Content -LiteralPath $checksumPath -Raw).Trim() -split '\s+')[0]}
    if($expected -cnotmatch '^[0-9a-fA-F]{64}$' -or (Hash $archivePath) -cne $expected.ToLowerInvariant()){throw 'Runtime archive checksum mismatch; the working installation was not changed'}
    $expanded=Join-Path $stage 'p';New-Item -ItemType Directory -Path $expanded|Out-Null
    $zip=[IO.Compression.ZipFile]::OpenRead($archivePath)
    try{
        $total=0L;$names=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        if($zip.Entries.Count -gt 10000){throw 'Runtime archive has too many entries'}
        foreach($entry in $zip.Entries){$null=Safe-Path $expanded $entry.FullName;if(-not $names.Add($entry.FullName) -or (($entry.ExternalAttributes -shr 16) -band 61440) -eq 40960){throw 'Duplicate or symbolic-link archive entry'};$total+=$entry.Length;if($total -gt 536870912){throw 'Runtime archive exceeds the extracted size limit'}}
        [IO.Compression.ZipFile]::ExtractToDirectory($archivePath,$expanded)
    }finally{$zip.Dispose()}
    $payload=$expanded
    if(-not(Test-Path -LiteralPath (Join-Path $payload 'runtime-manifest.json'))){$children=@(Get-ChildItem -LiteralPath $expanded -Directory);if($children.Count -ne 1){throw 'Archive has no single runtime root'};$payload=$children[0].FullName}
    $manifest=Check-Manifest $payload
    if($manifest.version.Contains('-') -and -not $Preview){throw 'Release candidates require explicit -Preview selection'}
    if(($Version -and $manifest.version -cne $Version.TrimStart('v')) -or ($resolved -and $manifest.version -cne $resolved.version)){throw 'Runtime version differs from the resolved release'}
    $null=Run-Check $payload
    $relative='versions/'+$manifest.version+'-'+$expected.Substring(0,12).ToLowerInvariant()
    $versionPath=Safe-Path $root $relative
    New-Item -ItemType Directory -Path (Join-Path $root 'versions') -Force|Out-Null
    $movePayload=$true
    if(Test-Path -LiteralPath $versionPath){try{$null=Run-Check $versionPath;$movePayload=$false}catch{$relative+='-'+[Guid]::NewGuid().ToString('N').Substring(0,8);$versionPath=Safe-Path $root $relative}}
    $bootstrap.target_path=$relative;$bootstrap.target_manifest_sha256=Hash (Join-Path $(if($movePayload){$payload}else{$versionPath}) 'runtime-manifest.json');$bootstrap.owns_target=$movePayload
    Atomic-Text $bootstrapPath ($bootstrap|ConvertTo-Json -Depth 5)
    if($movePayload){[IO.Directory]::Move($payload,$versionPath)}
    $history=@()
    if($existing){$history=@($existing.versions|Where-Object{$_.path -cne $relative})}
    $history+=@{version=$manifest.version;path=$relative;manifest_sha256=(Hash (Join-Path $versionPath 'runtime-manifest.json'));archive_sha256=$expected.ToLowerInvariant()}
    $currentUserPath=[string][Environment]::GetEnvironmentVariable('Path','User')
    $pathAdded=-not $NoPath -and -not @($currentUserPath.Split([char]';')|Where-Object{$_.TrimEnd('\','/') -ieq $root}).Count
    if($existing -and $existing.path_added){$pathAdded=$true}
    $metadata=@{schema=1;product=$product;installation_id=$installationId;current_version=$manifest.version;versions=$history;root_files=@();path_added=$pathAdded}
    Activate $relative $metadata $true $existingMetadataHash
    if(-not $NoPath){try{Set-CommandPath $false}catch{Write-Warning 'The runtime is installed, but updating user PATH failed. Use the executable path below or add the command directory manually.';$metadata.path_added=$(if($existing){[bool]$existing.path_added}else{$false});Atomic-Text $metadataPath ($metadata|ConvertTo-Json -Depth 15)}}
    $executable=Join-Path $versionPath 'bin/luau-decompile.exe'
    if($Json){Emit-Json @{passed=$true;version=$manifest.version;executable=$executable;command_directory=$root;restart_shell_for_persistent_path=(-not $NoPath)}}else{Write-Output ('Installed '+$manifest.version+"`nExecutable: "+$executable+"`nCommand directory: "+$root);if(-not $NoPath){Write-Output 'Open a new shell for persistent PATH discovery; the executable path above works immediately.'}}
}finally{
    try{if($lock -and -not(Test-Path -LiteralPath $activationPath)){Recover-Bootstrap}}finally{if($lock){$lock.Dispose()}}
}
