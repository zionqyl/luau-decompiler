param(
    [ValidateSet('start','stop','status','update','rollback')][string]$Action='start',
    [string]$Version,
    [switch]$Preview,
    [string]$Directory=(Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'LuauDecompiler/server'),
    [ValidateRange(1024,65535)][int]$Port=7879,
    [string]$Domain,
    [switch]$Https,
    [string]$DockerExecutable='docker'
)
$ErrorActionPreference='Stop'
$utf8=[Text.UTF8Encoding]::new($false)
$directoryPath=[IO.Path]::GetFullPath($Directory).TrimEnd('\','/')
$ownerPath=Join-Path $directoryPath 'ownership.json'
$credentialPath=Join-Path $directoryPath 'credential.txt'
$currentPath=Join-Path $directoryPath 'server.env'
$previousPath=Join-Path $directoryPath 'previous.env'
$pendingPath=Join-Path $directoryPath 'pending.env'
$composePath=Join-Path $directoryPath 'compose.yaml'
$release=Get-Content -LiteralPath (Join-Path $PSScriptRoot '../release.json') -Raw|ConvertFrom-Json
if($release.container_image -cnotmatch '^ghcr\.io/[a-z0-9_.-]+/[a-z0-9_.-]+$'){throw 'release.json has no supported configured container destination'}
$docker=(Get-Command $DockerExecutable -ErrorAction Stop).Source
function Hash([string]$Path){
    $stream=[IO.File]::OpenRead($Path)
    try{
        $algorithm=[Security.Cryptography.SHA256]::Create()
        try{([BitConverter]::ToString($algorithm.ComputeHash($stream))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
    }finally{$stream.Dispose()}
}
function Protect-Path([string]$Path){
    if($env:OS -ne 'Windows_NT'){return}
    $identity=[Security.Principal.WindowsIdentity]::GetCurrent().User
    $acl=Get-Acl -LiteralPath $Path
    $grant='*'+$identity.Value+':'+$(if((Get-Item -LiteralPath $Path).PSIsContainer){'(OI)(CI)F'}else{'F'})
    $parameters=@($Path,'/inheritance:r','/grant:r',$grant)
    $others=@($acl.GetAccessRules($true,$false,[Security.Principal.SecurityIdentifier])|Where-Object{$_.AccessControlType -eq 'Allow' -and $_.IdentityReference.Value -cne $identity.Value}|ForEach-Object{'*'+$_.IdentityReference.Value}|Select-Object -Unique)
    if($others.Count){$parameters+=@('/remove:g')+$others}
    & (Join-Path $env:SystemRoot 'System32/icacls.exe') @parameters | Out-Null
    if($LASTEXITCODE -ne 0){throw 'Could not protect server configuration for the current user'}
    $protected=Get-Acl -LiteralPath $Path
    if(-not $protected.AreAccessRulesProtected -or @($protected.GetAccessRules($true,$true,[Security.Principal.SecurityIdentifier])|Where-Object{$_.AccessControlType -eq 'Allow' -and $_.IdentityReference.Value -cne $identity.Value}).Count){throw 'Server configuration permissions still allow another principal'}
}
function Atomic-Text([string]$Path,[string]$Text){
    $temporary=$Path+'.new-'+[Guid]::NewGuid().ToString('N')
    [IO.File]::WriteAllText($temporary,$Text,$utf8);Protect-Path $temporary
    try{if(Test-Path -LiteralPath $Path){$backup=$Path+'.replace';[IO.File]::Replace($temporary,$Path,$backup);Remove-Item -LiteralPath $backup}else{[IO.File]::Move($temporary,$Path)}}finally{if(Test-Path -LiteralPath $temporary){Remove-Item -LiteralPath $temporary}}
}
function Quote-Native([string]$Value){
    if($Value.Contains([char]0) -or $Value.Contains("`r") -or $Value.Contains("`n")){throw 'Invalid Docker command argument'}
    '"'+[regex]::Replace($Value,'(\\*)("|$)',{param($match)$slashes=$match.Groups[1].Value;if($match.Groups[2].Value -eq '"'){$slashes+$slashes+'\"'}else{$slashes+$slashes}})+'"'
}
function Docker([string[]]$Parameters,[int]$TimeoutSeconds=60){
    $start=[Diagnostics.ProcessStartInfo]::new($docker)
    $start.Arguments=(@($Parameters|ForEach-Object{Quote-Native $_}) -join ' ')
    $start.UseShellExecute=$false;$start.CreateNoWindow=$true;$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true
    foreach($key in @($start.EnvironmentVariables.Keys)){if($key.StartsWith('LUAU_DECOMPILER_',[StringComparison]::OrdinalIgnoreCase) -or $key -in @('COMPOSE_PROFILES','DECOMPILER_DOMAIN')){$start.EnvironmentVariables.Remove($key)}}
    $process=[Diagnostics.Process]::Start($start)
    $output=$process.StandardOutput.ReadToEndAsync();$errors=$process.StandardError.ReadToEndAsync()
    try{
        if(-not $process.WaitForExit($TimeoutSeconds*1000)){
            & (Join-Path $env:SystemRoot 'System32/taskkill.exe') /PID $process.Id /T /F 2>$null | Out-Null
            $process.WaitForExit();throw 'Docker command exceeded its bounded timeout; working configuration was not activated'
        }
        if($process.ExitCode -ne 0){throw ('Docker command failed; check Docker availability and whether the configured version is published: '+$errors.Result.Trim())}
        $output.Result.Trim()
    }finally{$process.Dispose()}
}
function Env-Value([string]$Text,[string]$Key){$match=[regex]::Match($Text,'(?m)^'+[regex]::Escape($Key)+'=([^\r\n]*)');if($match.Success){$match.Groups[1].Value}else{$null}}
function Env-Set([string]$Text,[string]$Key,[string]$Value){
    if($Value -match '[\r\n]'){throw 'Multiline bootstrap settings are unsupported'}
    $pattern='(?m)^'+[regex]::Escape($Key)+'=[^\r\n]*'
    if([regex]::IsMatch($Text,$pattern)){[regex]::Replace($Text,$pattern,[Text.RegularExpressions.MatchEvaluator]{param($match)$Key+'='+$Value})}else{$Text.TrimEnd()+"`n"+$Key+'='+$Value+"`n"}
}
function Compose([string]$Environment,[string[]]$Parameters){Docker (@('compose','--project-name',$owner.project,'--env-file',$Environment,'--file',$composePath)+$Parameters) | Out-Null}
function Endpoint([string]$Environment){$text=[IO.File]::ReadAllText($Environment);'http://127.0.0.1:'+(Env-Value $text 'LUAU_DECOMPILER_PORT')}
function Check-Server([string]$Environment,[bool]$Wait){
    $text=[IO.File]::ReadAllText($Environment);$endpoint=Endpoint $Environment;$expected=Env-Value $text 'LUAU_DECOMPILER_VERSION'
    $headers=@{Authorization='Bearer '+$credential}
    $deadline=[DateTime]::UtcNow.AddSeconds($(if($Wait){60}else{30}))
    while([DateTime]::UtcNow -lt $deadline){
        $ready=$null
        try{
            $ready=Invoke-RestMethod -Uri ($endpoint+'/readyz') -Headers $headers -TimeoutSec 3
            if(-not $ready.ready){throw 'Container is not ready'}
        }catch{if(-not $Wait){throw};Start-Sleep -Seconds 1;continue}
        if($ready.package_version -cne $expected){throw 'Container version differs from the resolved image version'}
        $remaining=[Math]::Floor(($deadline-[DateTime]::UtcNow).TotalSeconds)
        if($remaining -lt 1){break}
        $body=@{source="local value: number = 42`nreturn value`n";input_format='luau_source';reconstruction_config=@{output_policy='verified_typed'}}|ConvertTo-Json -Depth 5 -Compress
        $result=Invoke-RestMethod -Uri ($endpoint+'/v1/process') -Method Post -Headers $headers -ContentType 'application/json' -Body $body -TimeoutSec ([Math]::Min(30,$remaining))
        if(-not $result.complete -or -not $result.validation.required_passed -or -not $result.validation.meaningful_typing.passed -or $result.validation.strict_analysis -cne 'passed' -or $result.validation.syntax -cne 'passed' -or $result.validation.compilation -cne 'passed'){throw 'Container failed the small verified-typed operation; inspect runtime assets and diagnostics'}
        return $endpoint
    }
    throw 'Container did not become ready within the bounded startup deadline'
}
if(Test-Path -LiteralPath $directoryPath){
    if((Get-Item -LiteralPath $directoryPath -Force).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Server directory must not be a symbolic link or junction'}
    if(-not (Test-Path -LiteralPath $ownerPath) -and @(Get-ChildItem -LiteralPath $directoryPath -Force).Count){throw 'Nonempty destination has no recognized server ownership metadata'}
}
New-Item -ItemType Directory -Force -Path $directoryPath | Out-Null
Protect-Path $directoryPath
$lock=[IO.File]::Open((Join-Path $directoryPath '.server.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
try{
    if(Test-Path -LiteralPath $ownerPath){$owner=Get-Content -LiteralPath $ownerPath -Raw|ConvertFrom-Json;if($owner.schema -ne 1 -or $owner.product -cne 'luau-decompiler-server' -or $owner.project -cnotmatch '^luau-decompiler-[0-9a-f]{12}$'){throw 'Invalid server ownership metadata'}}
    else{
        $hash=[Security.Cryptography.SHA256]::Create();try{$project=([BitConverter]::ToString($hash.ComputeHash($utf8.GetBytes($directoryPath)))).Replace('-','').ToLowerInvariant().Substring(0,12)}finally{$hash.Dispose()}
        $owner=[pscustomobject]@{schema=1;product='luau-decompiler-server';project='luau-decompiler-'+$project;compose_sha256=$null;caddy_sha256=$null}
        Atomic-Text $ownerPath ($owner|ConvertTo-Json)
    }
    if(-not (Test-Path -LiteralPath $credentialPath)){$random=[Security.Cryptography.RandomNumberGenerator]::Create();try{$bytes=New-Object byte[] 32;$random.GetBytes($bytes);Atomic-Text $credentialPath (([BitConverter]::ToString($bytes)).Replace('-','').ToLowerInvariant())}finally{$random.Dispose()}}
    $credential=[IO.File]::ReadAllText($credentialPath).Trim()
    if($credential -cnotmatch '^[0-9a-f]{64}$'){throw 'Credential file must contain the existing 64-character generated token'}
    $null=Docker @('version','--format','{{.Server.Version}}')
    $composeVersion=Docker @('compose','version','--short')
    if($composeVersion -notmatch '^v?2\.'){throw 'Docker Compose v2 is required'}
    foreach($entry in @(@('compose.yaml','compose_sha256'),@('Caddyfile','caddy_sha256'))){
        $target=Join-Path $directoryPath $entry[0]
        $source=Join-Path $PSScriptRoot $entry[0]
        if(Test-Path -LiteralPath $target){if($owner.($entry[1]) -cne (Hash $target)){throw ('Managed deployment file was modified; preserve it and reconcile explicitly before continuing: '+$entry[0])}}
        else{Copy-Item -LiteralPath $source -Destination $target;Protect-Path $target;$owner.($entry[1])=Hash $target}
    }
    Atomic-Text $ownerPath ($owner|ConvertTo-Json)
    if($Action -in @('stop','status','rollback') -and -not (Test-Path -LiteralPath $currentPath)){throw 'No active managed server configuration exists'}
    if($Action -eq 'stop'){
        try{Invoke-RestMethod -Method Post -Uri ((Endpoint $currentPath)+'/v1/shutdown') -Headers @{Authorization='Bearer '+$credential} -TimeoutSec 3|Out-Null}catch{}
        Compose $currentPath @('stop','--timeout','40');Write-Output 'Server stopped; configuration and credentials were preserved.';return
    }
    if($Action -eq 'status'){Write-Output (Check-Server $currentPath $false);return}
    $current=if(Test-Path -LiteralPath $currentPath){[IO.File]::ReadAllText($currentPath)}else{''}
    if($current -and (Env-Value $current 'LUAU_DECOMPILER_TOKEN') -cne $credential){throw 'Credential and active configuration differ; resolve the explicit credential change before updating'}
    if($Action -eq 'rollback'){
        if(-not (Test-Path -LiteralPath $previousPath)){throw 'No previous successful server configuration is available'}
        $candidate=[IO.File]::ReadAllText($previousPath)
    }else{
        if(-not $Version){$Version=Env-Value $current 'LUAU_DECOMPILER_VERSION'}
        if($Version -cnotmatch '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$'){throw 'Provide an explicit published semantic version using -Version'}
        if($PSBoundParameters.ContainsKey('Version') -and $Version.Contains('-') -and -not $Preview){throw 'Release candidates require explicit -Preview selection'}
        if($Domain -and $Domain -cnotmatch '^[A-Za-z0-9][A-Za-z0-9.-]*[A-Za-z0-9]$'){throw 'Provide a DNS hostname without a scheme, path, or credentials'}
        if($Https -and -not $Domain){throw 'HTTPS requires -Domain plus configured DNS and available ports 80/443'}
        $image=$release.container_image+':'+$Version
        $null=Docker @('pull','--quiet',$image) 300
        $digests=@((Docker @('image','inspect','--format','{{range .RepoDigests}}{{println .}}{{end}}',$image)) -split '\r?\n'|Where-Object{$_ -cmatch ('^'+[regex]::Escape($release.container_image)+'@sha256:[0-9a-f]{64}$')})
        if($digests.Count -ne 1){throw 'Pulled image did not resolve to one configured immutable repository digest'}
        $digest=$digests[0]
        $candidate=Env-Set $current 'LUAU_DECOMPILER_IMAGE' $digest
        $candidate=Env-Set $candidate 'LUAU_DECOMPILER_VERSION' $Version
        $candidate=Env-Set $candidate 'LUAU_DECOMPILER_TOKEN' $credential
        $candidate=Env-Set $candidate 'LUAU_DECOMPILER_PORT' $(if($current -and -not $PSBoundParameters.ContainsKey('Port')){Env-Value $current 'LUAU_DECOMPILER_PORT'}else{[string]$Port})
        if($Domain){$candidate=Env-Set $candidate 'DECOMPILER_DOMAIN' $Domain}
        if($Https){$candidate=Env-Set $candidate 'COMPOSE_PROFILES' 'https'}
    }
    Atomic-Text $pendingPath $candidate
    try{Compose $pendingPath @('up','--detach','--quiet-pull');$endpoint=Check-Server $pendingPath $true}
    catch{
        $failure=$_.Exception.Message
        if($current){Compose $currentPath @('up','--detach','--quiet-pull');$null=Check-Server $currentPath $true}
        else{Compose $pendingPath @('down')}
        throw ('Server activation failed; the previous working configuration was retained: '+$failure)
    }
    if($current){Atomic-Text $previousPath $current}
    Atomic-Text $currentPath $candidate
    Remove-Item -LiteralPath $pendingPath
    Write-Output ('Server ready: '+$endpoint)
    Write-Output ('Credential file: '+$credentialPath+'; retrieve it explicitly with Get-Content when needed. Routine commands do not print it.')
}finally{$lock.Dispose()}
