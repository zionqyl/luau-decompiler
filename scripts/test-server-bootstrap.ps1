param([string]$Python=$env:LUAU_PYTHON)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
if(-not $Python){$Python=(Get-Command python -ErrorAction Stop).Source}
$Python=(Resolve-Path -LiteralPath $Python).Path
$directory=Join-Path $root ('artifacts/server-bootstrap-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $directory | Out-Null
$statePath=Join-Path $directory 'mock-state.json'
$utf8=[Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText($statePath,'{"running":false,"version":"none","token":"none","fail_quality":[],"commands":[]}', $utf8)
$mock=Join-Path $directory 'mock-docker.exe'
$source=@'
using System;
using System.IO;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Security.Cryptography;
using System.Text;
public class MockDocker {
    public static int Main(string[] args) {
        string path=Environment.GetEnvironmentVariable("BOOTSTRAP_TEST_STATE");
        var json=new JavaScriptSerializer();
        var state=json.Deserialize<Dictionary<string,object>>(File.ReadAllText(path));
        if(args.Length==0)return 2;
        if(args[0]=="version"){Console.WriteLine("25.0.0");return 0;}
        if(args.Length>1&&args[0]=="compose"&&args[1]=="version"){Console.WriteLine("2.27.0");return 0;}
        if(args[0]=="pull") {
            if(Environment.GetEnvironmentVariable("BOOTSTRAP_TEST_FAIL_PULL")=="1"){Console.Error.WriteLine("intentional fixture pull failure");return 17;}
            Console.WriteLine("pulled");return 0;
        }
        if(args[0]=="image") {
            string tag=args[args.Length-1];
            string digest;
            using(var hash=SHA256.Create()){digest=BitConverter.ToString(hash.ComputeHash(Encoding.UTF8.GetBytes(tag))).Replace("-","").ToLowerInvariant();}
            Console.WriteLine(tag.Substring(0,tag.LastIndexOf(':'))+"@sha256:"+digest);return 0;
        }
        if(args[0]=="compose") {
            int index=Array.IndexOf(args,"--env-file");
            var values=new Dictionary<string,string>();
            foreach(var line in File.ReadAllLines(args[index+1])){int equal=line.IndexOf('=');if(equal>0)values[line.Substring(0,equal)]=line.Substring(equal+1);}
            if(Array.IndexOf(args,"up")>=0){
                state["running"]=true;state["version"]=values["LUAU_DECOMPILER_VERSION"];state["token"]=values["LUAU_DECOMPILER_TOKEN"];
            } else if(Array.IndexOf(args,"stop")>=0||Array.IndexOf(args,"down")>=0){state["running"]=false;}
            string temporary=path+".new";
            File.WriteAllText(temporary,json.Serialize(state),new UTF8Encoding(false));
            File.Replace(temporary,path,null);
            return 0;
        }
        return 3;
    }
}
'@
Add-Type -TypeDefinition $source -OutputAssembly $mock -OutputType ConsoleApplication -ReferencedAssemblies System.Web.Extensions
$probe=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,0);$probe.Start();$port=$probe.LocalEndpoint.Port;$probe.Stop()
$env:BOOTSTRAP_TEST_STATE=$statePath
$env:BOOTSTRAP_TEST_PORT=[string]$port
$start=[Diagnostics.ProcessStartInfo]::new($Python)
$start.Arguments='"'+(Join-Path $root 'tests/bootstrap_server.py')+'"'
$start.UseShellExecute=$false;$start.CreateNoWindow=$true
$server=[Diagnostics.Process]::Start($start)
$installation=Join-Path $directory ('spaces and Unicode '+[char]0x00fc+' '+[char]0x6f22+[char]0x5b57)
$script=Join-Path $root 'deployment/start-server.ps1'
$cases=[Collections.Generic.List[object]]::new()
function Invoke-Bootstrap([string[]]$Parameters,[bool]$ExpectedSuccess=$true){
    $arguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File',$script,'-Directory',$installation,'-DockerExecutable',$mock,'-Port',[string]$port)+$Parameters
    $child=[Diagnostics.ProcessStartInfo]::new((Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'))
    $child.Arguments=(@($arguments|ForEach-Object{'"'+$_+'"'}) -join ' ')
    $child.UseShellExecute=$false;$child.CreateNoWindow=$true;$child.RedirectStandardOutput=$true;$child.RedirectStandardError=$true
    $process=[Diagnostics.Process]::Start($child);$output=$process.StandardOutput.ReadToEndAsync();$errors=$process.StandardError.ReadToEndAsync()
    try{if(-not $process.WaitForExit(90000)){$process.Kill();$process.WaitForExit();throw 'Bootstrap contract test exceeded deadline'}
        if(($process.ExitCode -eq 0) -ne $ExpectedSuccess){throw ('Unexpected bootstrap status: '+$output.Result+' '+$errors.Result)}
        $credential=Join-Path $installation 'credential.txt'
        if(Test-Path -LiteralPath $credential){$token=[IO.File]::ReadAllText($credential).Trim();if($output.Result.Contains($token) -or $errors.Result.Contains($token)){throw 'Routine bootstrap output exposed authentication token'}}
        return $output.Result
    }finally{$process.Dispose()}
}
try{
    Start-Sleep -Milliseconds 200
    $null=Invoke-Bootstrap @('start','-Version','0.4.0-rc.2','-Preview')
    $tokenHash=(Get-FileHash (Join-Path $installation 'credential.txt') -Algorithm SHA256).Hash
    $first=[IO.File]::ReadAllText((Join-Path $installation 'server.env'))
    if($first -notmatch 'ghcr.io/zionqyl/luau-decompiler@sha256:[0-9a-f]{64}'){throw 'Bootstrap did not pin immutable image'}
    $cases.Add(@{id='fresh_unicode_destination_verified_and_no_secret_log';passed=$true})
    $null=Invoke-Bootstrap @('start')
    if((Get-FileHash (Join-Path $installation 'credential.txt') -Algorithm SHA256).Hash -ne $tokenHash){throw 'Rerun changed authentication'}
    $cases.Add(@{id='rerun_preserves_credentials';passed=$true})
    [IO.File]::AppendAllText((Join-Path $installation 'server.env'),"`nCUSTOM_KEEP=yes`n",$utf8)
    $null=Invoke-Bootstrap @('update','-Version','0.4.0-rc.3','-Preview')
    if([IO.File]::ReadAllText((Join-Path $installation 'server.env')) -notmatch 'CUSTOM_KEEP=yes'){throw 'Upgrade discarded user configuration'}
    $cases.Add(@{id='upgrade_preserves_configuration_and_credentials';passed=$true})
    $null=Invoke-Bootstrap @('rollback')
    if([IO.File]::ReadAllText((Join-Path $installation 'server.env')) -notmatch 'LUAU_DECOMPILER_VERSION=0.4.0-rc.2'){throw 'Rollback did not select previous version'}
    $cases.Add(@{id='explicit_rollback';passed=$true})
    $beforeFailure=[IO.File]::ReadAllText((Join-Path $installation 'server.env'))
    $env:BOOTSTRAP_TEST_FAIL_PULL='1'
    $null=Invoke-Bootstrap @('update','-Version','0.4.0-rc.4','-Preview') $false
    $env:BOOTSTRAP_TEST_FAIL_PULL=$null
    if([IO.File]::ReadAllText((Join-Path $installation 'server.env')) -cne $beforeFailure){throw 'Failed download changed active configuration'}
    $cases.Add(@{id='failed_pull_retains_working_configuration';passed=$true})
    $state=Get-Content $statePath -Raw|ConvertFrom-Json;$state.fail_quality=@('0.4.0-rc.5');[IO.File]::WriteAllText($statePath,($state|ConvertTo-Json -Depth 8),$utf8)
    $null=Invoke-Bootstrap @('update','-Version','0.4.0-rc.5','-Preview') $false
    if([IO.File]::ReadAllText((Join-Path $installation 'server.env')) -cne $beforeFailure){throw 'Failed validation changed active configuration'}
    if((Get-Content $statePath -Raw|ConvertFrom-Json).version -cne '0.4.0-rc.2'){throw 'Failed validation did not restore previous container contract'}
    $cases.Add(@{id='failed_verified_operation_rolls_back';passed=$true})
    $null=Invoke-Bootstrap @('status')
    $null=Invoke-Bootstrap @('stop')
    if(-not (Test-Path (Join-Path $installation 'server.env')) -or (Get-FileHash (Join-Path $installation 'credential.txt') -Algorithm SHA256).Hash -ne $tokenHash){throw 'Stop removed configuration or credentials'}
    $cases.Add(@{id='readiness_and_stop_preserve_owned_state';passed=$true})
    $report=@{schema=1;passed=$true;scope='Windows PowerShell control contracts with fake Docker CLI and local fixture HTTP; no real Docker/container/Linux execution';cases=$cases.ToArray();bootstrap_sha256=(Get-FileHash $script -Algorithm SHA256).Hash.ToLowerInvariant();fixture_sha256=(Get-FileHash (Join-Path $root 'tests/bootstrap_server.py') -Algorithm SHA256).Hash.ToLowerInvariant();harness_sha256=(Get-FileHash $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()}
    [IO.File]::WriteAllText((Join-Path $directory 'report.json'),($report|ConvertTo-Json -Depth 10),$utf8)
    Write-Output ('Bootstrap mocked contracts passed: '+$cases.Count+'; report '+(Join-Path $directory 'report.json'))
}finally{
    $env:BOOTSTRAP_TEST_FAIL_PULL=$null;$env:BOOTSTRAP_TEST_STATE=$null;$env:BOOTSTRAP_TEST_PORT=$null
    if(-not $server.HasExited){$server.Kill();$server.WaitForExit()};$server.Dispose()
}
