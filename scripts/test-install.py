import argparse
import base64
import ctypes
from ctypes import wintypes
import hashlib
import http.server
import json
import os
import pathlib
import subprocess
import sys
import threading
import time
import traceback
import zipfile


REGISTRY_PATH_SCRIPT = r"""param(
    [Parameter(Mandatory=$true)][ValidateSet('user_path','machine_path','command_path','set_user_path')][string]$Action,
    [string]$ValueFile
)
$ErrorActionPreference='Stop'
$value=''
switch($Action){
    'user_path'{$value=[Environment]::GetEnvironmentVariable('Path','User')}
    'machine_path'{$value=[Environment]::GetEnvironmentVariable('Path','Machine')}
    'command_path'{$value=(Get-Command luau-decompile).Source}
    'set_user_path'{
        if(-not $ValueFile -or -not [IO.File]::Exists($ValueFile)){throw 'A UTF-8 PATH value file is required'}
        [Environment]::SetEnvironmentVariable('Path',[IO.File]::ReadAllText($ValueFile,[Text.Encoding]::UTF8),'User')
    }
}
[Console]::Write([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes([string]$value)))
"""


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main(failure_context=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('--archive', required=True)
    parser.add_argument('--installer', default=str(pathlib.Path(__file__).with_name('install.ps1')))
    parser.add_argument('--report', required=True)
    parser.add_argument('--work-dir', required=True)
    parser.add_argument('--registry-path', action='store_true')
    parser.add_argument('--previous-archive')
    parser.add_argument('--modern-previous-archive')
    parser.add_argument('--legacy-only', action='store_true')
    parser.add_argument('--admission-only', action='store_true')
    parser.add_argument('--bootstrap-only', action='store_true')
    args = parser.parse_args()
    if os.name != 'nt':
        parser.error('these installer scenarios require Windows')
    if args.legacy_only and (not args.previous_archive or args.registry_path):
        parser.error('--legacy-only requires --previous-archive and cannot select registry tests')
    if args.admission_only and (args.legacy_only or args.previous_archive or args.modern_previous_archive or args.registry_path):
        parser.error('--admission-only cannot select legacy or registry tests')
    if args.bootstrap_only and (args.legacy_only or args.admission_only or args.previous_archive or args.modern_previous_archive or args.registry_path):
        parser.error('--bootstrap-only cannot select other test profiles')
    if args.legacy_only and args.modern_previous_archive:
        parser.error('--legacy-only cannot select modern updater tests')
    archive = pathlib.Path(args.archive).resolve()
    installer = pathlib.Path(args.installer).resolve()
    work = pathlib.Path(args.work_dir).resolve()
    work.mkdir(parents=True, exist_ok=False)
    managed = work / 'managed installation \u00fc \u0394 \u6c49\u5b57 space'
    powershell = pathlib.Path(os.environ['SystemRoot']) / 'System32/WindowsPowerShell/v1.0/powershell.exe'
    with zipfile.ZipFile(archive) as bundle:
        entries = {name: bundle.read(name) for name in bundle.namelist() if not name.endswith('/')}
    manifest = json.loads(entries['runtime-manifest.json'])
    version = manifest['version']
    archive_bytes = archive.read_bytes()
    archive_sha = digest(archive_bytes)
    cases = []
    report = {'schema': 1, 'passed': False, 'version': version, 'archive_sha256': archive_sha,
              'installer_sha256': digest(installer.read_bytes()), 'harness_sha256': digest(pathlib.Path(__file__).read_bytes()),
              'boundary': 'actual Windows local runtime and transactional installer; release API and interrupted transport use a controlled loopback mirror',
              'path_updates': 'NoPath selected: no persistent user registry changes; absolute installed executable and shim are exercised', 'cases': cases}
    report['selection'] = 'bootstrap recovery only' if args.bootstrap_only else 'legacy upgrades only' if args.legacy_only else 'admission races only' if args.admission_only else 'complete installer scenarios'
    report_path = pathlib.Path(args.report).resolve()
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2)+'\n')
    if failure_context is not None:
        failure_context.update({'report': report, 'path': report_path})

    def install(arguments, success=True, no_path=True, manager=None):
        operation = next((str(value) for value in arguments if str(value) in ['-Doctor', '-Uninstall', '-Rollback', '-RepairManagement']), 'install')
        report['last_operation'] = {'operation': operation, 'destination': str(managed.relative_to(work)),
                                    'manager_sha256': digest(pathlib.Path(manager or installer).read_bytes()), 'expected_success': success}
        result = subprocess.run([str(powershell), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(manager or installer),
                                 '-Destination', str(managed), *(['-NoPath'] if no_path else []), *map(str, arguments)], cwd=work,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=120)
        if (result.returncode == 0) != success:
            raise AssertionError(result.stderr.decode('utf-8', 'replace')[:3000])
        return result

    def local(path, checksum=None, success=True, manager=None):
        return install(['-Archive', path, '-ExpectedSha256', checksum or digest(path.read_bytes()), '-Preview'], success, manager=manager)

    def current():
        return (managed / 'current').read_text().strip()

    def record(identity, **extra):
        cases.append({'id': identity, 'passed': True, **extra})
        report['last_completed_case'] = identity
        report_path.write_text(json.dumps(report, indent=2)+'\n')

    def variant(identity, overrides):
        payload = dict(entries)
        payload.update(overrides)
        inventory = json.loads(payload['runtime-manifest.json'])
        for file in inventory['files']:
            data = payload[file['path']]
            file['bytes'] = len(data)
            file['sha256'] = digest(data)
        payload['runtime-manifest.json'] = json.dumps(inventory).encode()
        path = work / (identity+'.zip')
        with zipfile.ZipFile(path, 'w', compression=zipfile.ZIP_DEFLATED) as bundle:
            for name, data in payload.items():
                bundle.writestr(name, data)
        return path

    def management_bytes(identity):
        source = installer.read_bytes()
        marker = b"$ErrorActionPreference='Stop'"
        assert source.count(marker) == 1
        return source.replace(marker, marker+b"\n$managementReleaseIdentity='"+identity.encode()+b"'", 1)

    def interrupt_activation(identity, archive, checkpoint):
        report['last_operation'] = {'operation': 'interrupt_activation', 'checkpoint': checkpoint, 'destination': str(managed.relative_to(work))}
        signal = work / (identity+'.checkpoint')
        source = installer.read_text(encoding='utf-8-sig')
        if checkpoint == 'after_pointer':
            marker = "        if($actual -cne $write.sha256){Atomic-Bytes $path $bytes}"
            condition = "$write.path -ceq 'current'"
        else:
            marker = '    Remove-Item -LiteralPath $activationPath'
            condition = '$true'
        assert source.count(marker) == 1
        escaped = str(signal).replace("'", "''")
        pause = "if("+condition+"){[IO.File]::WriteAllText('"+escaped+"','ready');while(Test-Path -LiteralPath '"+escaped+"'){Start-Sleep -Milliseconds 100}}"
        source = source.replace(marker, marker+'\n'+pause if checkpoint == 'after_pointer' else pause+'\n'+marker, 1)
        injected = work / (identity+'-instrumented.ps1')
        injected.write_text(source, encoding='utf-8')
        process = subprocess.Popen([str(powershell), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(injected),
                                    '-Destination', str(managed), '-NoPath', '-Archive', str(archive),
                                    '-ExpectedSha256', digest(archive.read_bytes()), '-Preview'], cwd=work,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            deadline = time.monotonic()+45
            while not signal.exists():
                if process.poll() is not None:
                    raise AssertionError(process.communicate()[1].decode('utf-8', 'replace'))
                if time.monotonic() >= deadline:
                    raise AssertionError('activation checkpoint was not reached')
                time.sleep(.025)
            process.kill()
            process.communicate(timeout=10)
        finally:
            if process.poll() is None:
                process.kill()
                process.communicate(timeout=10)
        assert (managed / '.luau-activation.json').is_file()
        return {'checkpoint': checkpoint, 'invoker_sha256': digest(injected.read_bytes()),
                'runtime_archive_sha256': digest(archive.read_bytes()), 'fault': 'actual process termination at an instrumented write boundary; payload installer remains unmodified'}

    if not args.admission_only and not args.legacy_only:
        primary_managed = managed
        try:
            lock_results = []
            for order in ['staging_control', 'provisional_version']:
                managed = work / ('post doctor cwd '+order)
                signal = work / (order+'.doctor-checkpoint')
                resume = work / (order+'.doctor-resume')
                ready = work / (order+'.holder-ready')
                move_failure = work / (order+'.move-failure.json')
                source = installer.read_text(encoding='utf-8-sig')
                move = '    if($movePayload){[IO.Directory]::Move($payload,$versionPath)}'
                diagnosis = '    if($movePayload){$null=Run-Check $versionPath}'
                version_selection = "    $relative='versions/'+$manifest.version+'-'+$expected.Substring(0,12).ToLowerInvariant()"
                assert source.count(move) == source.count(diagnosis) == source.count(version_selection) == 1
                if order == 'staging_control':
                    source = source.replace(diagnosis+'\n', '', 1).replace(version_selection, '    $null=Run-Check $payload\n'+version_selection, 1)
                return_marker = '        return $result'
                assert source.count(return_marker) == 1
                signal_text = str(signal).replace("'", "''")
                resume_text = str(resume).replace("'", "''")
                failure_text = str(move_failure).replace("'", "''")
                pause = "        [IO.File]::WriteAllText('"+signal_text+"',[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Directory)));while(-not(Test-Path -LiteralPath '"+resume_text+"')){Start-Sleep -Milliseconds 100}\n"
                source = source.replace(return_marker, pause+return_marker, 1)
                observed_move = "    if($movePayload){try{[IO.Directory]::Move($payload,$versionPath)}catch{[IO.File]::WriteAllText('"+failure_text+"',(@{hresult=$_.Exception.GetBaseException().HResult;message=$_.Exception.GetBaseException().Message}|ConvertTo-Json));throw}}"
                source = source.replace(move, observed_move, 1)
                instrumented = work / (order+'-cwd-instrumented.ps1')
                instrumented.write_text(source, encoding='utf-8')
                process = subprocess.Popen([str(powershell), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(instrumented),
                                            '-Destination', str(managed), '-NoPath', '-Archive', str(archive),
                                            '-ExpectedSha256', archive_sha, '-Preview'], cwd=work,
                                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                holder = None
                try:
                    deadline = time.monotonic()+45
                    while not signal.exists():
                        if process.poll() is not None:
                            raise AssertionError(process.communicate()[1].decode('utf-8', 'replace'))
                        if time.monotonic() >= deadline:
                            raise AssertionError('post-doctor checkpoint was not reached')
                        time.sleep(.025)
                    checked_directory = pathlib.Path(base64.b64decode(signal.read_text(encoding='utf-8-sig')).decode('utf-8'))
                    assert checked_directory.is_relative_to(managed)
                    holder = subprocess.Popen([sys.executable, '-c', "import pathlib,sys;pathlib.Path(sys.argv[1]).write_text('ready',encoding='ascii');sys.stdin.buffer.read(1)", str(ready)],
                                              cwd=checked_directory, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
                                              creationflags=subprocess.CREATE_NO_WINDOW)
                    while not ready.exists():
                        if holder.poll() is not None:
                            raise AssertionError(holder.communicate()[1].decode('utf-8', 'replace'))
                        if time.monotonic() >= deadline:
                            raise AssertionError('CWD-holder process did not become ready')
                        time.sleep(.025)
                    resume.write_bytes(b'resume')
                    output, errors = process.communicate(timeout=120)
                    assert holder.poll() is None
                    if order == 'staging_control':
                        assert process.returncode != 0 and move_failure.is_file(), errors.decode('utf-8', 'replace')
                        failure = json.loads(move_failure.read_text(encoding='utf-8-sig'))
                        assert failure['hresult'] & 0xffff in (5, 32), failure
                        assert not (managed / 'current').exists()
                    else:
                        assert process.returncode == 0, errors.decode('utf-8', 'replace')
                        assert managed / current() == checked_directory and not move_failure.exists()
                        assert not (managed / '.luau-bootstrap.json').exists()
                    lock_results.append({'ordering': order, 'invoker_sha256': digest(instrumented.read_bytes()),
                                         'installer_exit_code': process.returncode, 'independent_cwd_holder_alive_at_result': True,
                                         'directory_move_denied': move_failure.exists()})
                finally:
                    if holder is not None and holder.poll() is None:
                        holder.communicate(input=b'x', timeout=10)
                    if process.poll() is None:
                        process.kill()
                        process.communicate(timeout=10)
                local(archive)
                if order == 'provisional_version':
                    before_pointer = (managed / 'current').read_bytes()
                    before_metadata = (managed / '.luau-installation.json').read_bytes()
                    before_versions = sorted(path.name for path in (managed / 'versions').iterdir())
                    rejected = variant('diagnosis-fails-'+order, {'bin/luau-quality.exe': b'invalid controlled analyzer executable'})
                    local(rejected, success=False)
                    assert (managed / 'current').read_bytes() == before_pointer
                    assert (managed / '.luau-installation.json').read_bytes() == before_metadata
                    assert sorted(path.name for path in (managed / 'versions').iterdir()) == before_versions
                    assert not (managed / '.luau-bootstrap.json').exists()
                    assert not list(managed.glob('.staging-*'))
                install(['-Uninstall'])
            record('diagnosis_in_final_owned_version_avoids_live_cwd_rename_and_preserves_failed_updates',
                   controlled_orderings=lock_results, failed_diagnosis_preserves_active_runtime=True,
                   scope='Actual separate Windows process holds the diagnosed directory as CWD until installer completion; old staging order is a required failing control')
            atomic_results = []
            kernel = ctypes.WinDLL('kernel32', use_last_error=True)
            kernel.CreateFileW.argtypes = [wintypes.LPCWSTR, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, wintypes.HANDLE]
            kernel.CreateFileW.restype = wintypes.HANDLE
            kernel.CloseHandle.argtypes = [wintypes.HANDLE]
            kernel.CloseHandle.restype = wintypes.BOOL
            for condition in ['released', 'held', 'modified', 'partial']:
                managed = work / ('atomic contention '+condition)
                ready = work / (condition+'.atomic-ready')
                start = work / (condition+'.atomic-start')
                observed = work / (condition+'.atomic-observed')
                resume = work / (condition+'.atomic-resume')
                result_path = work / (condition+'.atomic-result.json')
                source = installer.read_text(encoding='utf-8-sig').split("if($env:OS -ne 'Windows_NT'", 1)[0]
                def literal(path):
                    return "'"+str(path).replace("'", "''")+"'"
                setup = "\n$script:observedAttempts=0;$script:attemptTimes=@()\n"
                call = '                if($null -ne $previousHash){[IO.File]::Replace($temporary,$Path,[NullString]::Value)}else{[IO.File]::Move($temporary,$Path)}'
                assert source.count(call) == 1
                replacement = '                $script:observedAttempts=$attempt;$script:attemptTimes+=@($clock.ElapsedMilliseconds)\n'
                replacement += ("                [IO.File]::Delete($Path);throw [IO.IOException]::new('controlled partial publication',-2147023720)" if condition == 'partial' else call)
                source = source.replace(call, replacement, 1)
                failure_marker = '                $remaining=1000-$clock.ElapsedMilliseconds'
                assert source.count(failure_marker) == 1
                if condition != 'partial':
                    pause = "                if($attempt -eq 1){[IO.File]::WriteAllText("+literal(observed)+",[string]($nativeHresult -band 65535));while(-not(Test-Path -LiteralPath "+literal(resume)+")){Start-Sleep -Milliseconds 5}}\n"
                    source = source.replace(failure_marker, pause+failure_marker, 1)
                setup += "New-Item -ItemType Directory -Path $root -Force|Out-Null\n[IO.File]::WriteAllText($metadataPath,'previous controlled bytes',$utf8)\n"
                setup += "$lock=[IO.File]::Open($lockPath,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)\n"
                setup += "[IO.File]::WriteAllText("+literal(ready)+",'ready');while(-not(Test-Path -LiteralPath "+literal(start)+")){Start-Sleep -Milliseconds 5}\n"
                setup += "$operationClock=[Diagnostics.Stopwatch]::StartNew();$failure=$null\ntry{Atomic-Text $metadataPath 'next controlled bytes'}catch{$failure=$_.Exception.Message}\n$operationClock.Stop()\n"
                setup += "$candidate=@(Get-ChildItem -LiteralPath $root -Filter '.luau-installation.json.new-*' -File);$retained=$lock.Length -gt 0 -and $candidate.Count -eq 1\n"
                setup += "$recoveryFailure=$null;try{Recover-AtomicWrite}catch{$recoveryFailure=$_.Exception.Message}\n"
                if condition == 'partial':
                    setup += "$lock.Position=0;$data=[byte[]]::new([int]$lock.Length);$null=$lock.Read($data,0,$data.Length);$legacy=$utf8.GetString($data).Substring('LUAU-ATOMIC/1 '.Length)|ConvertFrom-Json;$legacy.PSObject.Properties.Remove('previous_sha256');$data=$utf8.GetBytes('LUAU-ATOMIC/1 '+($legacy|ConvertTo-Json -Compress)+\"`n\");$lock.SetLength(0);$lock.Position=0;$lock.Write($data,0,$data.Length);$lock.Flush($true);$legacyFailure=$null;try{Recover-AtomicWrite}catch{$legacyFailure=$_.Exception.Message}\n"
                else:
                    setup += "$legacyFailure=$null\n"
                setup += "$targetHash=$null;if(Test-Path -LiteralPath $metadataPath){$targetHash=Hash $metadataPath};$remainingCandidates=@(Get-ChildItem -LiteralPath $root -Filter '.luau-installation.json.new-*' -File)\n"
                setup += "$result=@{failure=$failure;attempts=$script:observedAttempts;attempt_started_ms=$script:attemptTimes;elapsed_ms=$operationClock.ElapsedMilliseconds;target_sha256=$targetHash;intent_and_candidate_retained_on_error=$retained;recovery_failure=$recoveryFailure;legacy_recovery_failure=$legacyFailure;remaining_candidates=$remainingCandidates.Count;remaining_intent_bytes=$lock.Length}\n$lock.Dispose();[IO.File]::WriteAllText("+literal(result_path)+",($result|ConvertTo-Json -Depth 6),$utf8)\n"
                instrumented = work / (condition+'-atomic-contention.ps1')
                instrumented.write_text(source+setup, encoding='utf-8')
                process = subprocess.Popen([str(powershell), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(instrumented), '-Destination', str(managed), '-NoPath'],
                                           cwd=work, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                handle = None
                try:
                    deadline = time.monotonic()+30
                    for checkpoint in [ready, observed] if condition != 'partial' else [ready]:
                        while not checkpoint.exists():
                            if process.poll() is not None:
                                raise AssertionError(process.communicate()[1].decode('utf-8', 'replace'))
                            if time.monotonic() >= deadline:
                                raise AssertionError('atomic contention checkpoint was not reached: '+condition)
                            time.sleep(.005)
                        if checkpoint == ready:
                            if condition != 'partial':
                                handle = kernel.CreateFileW(str(managed / '.luau-installation.json'), 0x80000000, 3, None, 3, 0, None)
                                if handle in (None, ctypes.c_void_p(-1).value):
                                    raise ctypes.WinError(ctypes.get_last_error())
                            start.write_bytes(b'start')
                    if condition == 'released':
                        assert kernel.CloseHandle(handle)
                        handle = None
                    elif condition == 'modified':
                        (managed / '.luau-installation.json').write_bytes(b'user modified bytes')
                    resume.write_bytes(b'resume')
                    output, errors = process.communicate(timeout=15)
                    assert process.returncode == 0, errors.decode('utf-8', 'replace')
                    result = json.loads(result_path.read_text(encoding='utf-8-sig'))
                    result['observed_win32_code'] = int(observed.read_text(encoding='utf-8-sig')) if condition != 'partial' else None
                    assert condition == 'partial' or result['observed_win32_code'] == 32, result
                    assert 1 <= result['attempts'] <= 8 and all(value < 1000 for value in result['attempt_started_ms']), result
                    if condition == 'released':
                        assert result['failure'] is None and result['attempts'] >= 2
                        assert result['target_sha256'] == digest(b'next controlled bytes')
                    else:
                        assert result['failure'] and result['intent_and_candidate_retained_on_error']
                        if condition == 'held':
                            assert result['target_sha256'] == digest(b'previous controlled bytes')
                            assert result['attempts'] >= 2 and result['recovery_failure'] is None
                            assert result['remaining_candidates'] == 0 and result['remaining_intent_bytes'] == 0
                        elif condition == 'modified':
                            assert result['target_sha256'] == digest(b'user modified bytes')
                            assert result['recovery_failure'] and result['remaining_candidates'] == 1 and result['remaining_intent_bytes'] > 0
                        else:
                            assert result['attempts'] == 1 and result['target_sha256'] is None
                            assert 'Win32 1176' in result['failure']
                            assert result['recovery_failure'] and result['legacy_recovery_failure']
                            assert result['remaining_candidates'] == 1 and result['remaining_intent_bytes'] > 0
                    atomic_results.append({'condition': condition, 'invoker_sha256': digest(instrumented.read_bytes()), **result})
                finally:
                    if handle not in (None, ctypes.c_void_p(-1).value):
                        kernel.CloseHandle(handle)
                    if process.poll() is None:
                        process.kill()
                        process.communicate(timeout=10)
            record('atomic_contention_is_classified_bounded_and_partial_or_changed_publication_is_preserved', controls=atomic_results,
                   native_contention='Actual deny-delete file handles; only partial1176 is an explicit fault injection, not an observed OS failure')
            for atomic_target in ['intent', 'bootstrap', 'stage_owner', 'activation']:
                managed = work / ('atomic interrupted '+atomic_target)
                signal = work / (atomic_target+'.atomic-checkpoint')
                source = installer.read_text(encoding='utf-8-sig')
                marker = ('    $lock.Position=0;$lock.Write($intent,0,$intent.Length);$lock.Flush($true)' if atomic_target == 'intent' else
                          '        try{$stream.Write($Bytes,0,$Bytes.Length);$stream.Flush($true)}finally{$stream.Dispose()}')
                assert source.count(marker) == 1
                escaped = str(signal).replace("'", "''")
                condition = {'intent': '$true', 'bootstrap': '$Path -ceq $bootstrapPath', 'activation': '$Path -ceq $activationPath',
                             'stage_owner': "[IO.Path]::GetFileName($Path) -ceq '.luau-stage-owner.json'"}[atomic_target]
                pause = "if("+condition+"){$stream.Write($Bytes,0,[int]($Bytes.Length/2));$stream.Flush($true);[IO.File]::WriteAllText('"+escaped+"','ready');while(Test-Path -LiteralPath '"+escaped+"'){Start-Sleep -Milliseconds 100}}"
                injected = work / (atomic_target+'-atomic-instrumented.ps1')
                if atomic_target == 'intent':
                    pause = "$lock.Position=0;$lock.Write($intent,0,[int]($intent.Length/2));$lock.Flush($true);[IO.File]::WriteAllText('"+escaped+"','ready');while(Test-Path -LiteralPath '"+escaped+"'){Start-Sleep -Milliseconds 100}"
                    replacement = pause+'\n'+marker
                else:
                    replacement = marker.replace('try{', 'try{'+pause, 1)
                injected.write_text(source.replace(marker, replacement, 1), encoding='utf-8')
                process = subprocess.Popen([str(powershell), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(injected),
                                            '-Destination', str(managed), '-NoPath', '-Archive', str(archive),
                                            '-ExpectedSha256', archive_sha, '-Preview'], cwd=work,
                                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                try:
                    deadline = time.monotonic()+45
                    while not signal.exists():
                        if process.poll() is not None:
                            raise AssertionError(process.communicate()[1].decode('utf-8', 'replace'))
                        if time.monotonic() >= deadline:
                            raise AssertionError('atomic write checkpoint was not reached: '+atomic_target)
                        time.sleep(.025)
                    process.kill()
                    process.communicate(timeout=10)
                finally:
                    if process.poll() is None:
                        process.kill()
                        process.communicate(timeout=10)
                journal = (managed / '.install.lock').read_text(encoding='utf-8')
                assert journal.startswith('LUAU-ATOMIC/1 ')
                if atomic_target == 'intent':
                    assert not journal.endswith('\n') and not list(managed.rglob('*.new-*'))
                    local(archive)
                    assert json.loads(install(['-Doctor', '-Json']).stdout)['passed']
                    assert (managed / '.install.lock').stat().st_size == 0
                    record('hard_kill_inside_lock_intent_write_retries_before_managed_file_creation',
                           invoker_sha256=digest(injected.read_bytes()), fault='actual termination after a partial durable lock intent, before temporary creation')
                    install(['-Uninstall'])
                    continue
                write = json.loads(journal.split(' ', 1)[1])
                partial = managed / (write['path']+'.new-'+write['transaction_id'])
                assert 0 < partial.stat().st_size < len(base64.b64decode(write['bytes']))
                if atomic_target == 'stage_owner':
                    original_partial = partial.read_bytes()
                    partial.write_bytes(b'user-modified partial file')
                    local(archive, success=False)
                    assert partial.read_bytes() == b'user-modified partial file'
                    partial.write_bytes(original_partial)
                local(archive)
                assert json.loads(install(['-Doctor', '-Json']).stdout)['passed']
                assert not partial.exists() and (managed / '.install.lock').stat().st_size == 0
                assert not list(managed.rglob('*.new-*')) and not list(managed.rglob('*.previous-*'))
                record('hard_kill_inside_'+atomic_target+'_write_recovers_only_recorded_partial',
                       invoker_sha256=digest(injected.read_bytes()), modified_partial_preservation_checked=atomic_target == 'stage_owner',
                       fault='actual termination after a durable partial write inside Atomic-Bytes')
                install(['-Uninstall'])
            checkpoints = {
                'staging': "    if($Archive){$archivePath=(Resolve-Path -LiteralPath $Archive).Path}else{$resolved=Resolve-Release $stage;$archivePath=$resolved.path}",
                'extraction': '        [IO.Compression.ZipFile]::ExtractToDirectory($archivePath,$expanded)',
                'version_move': '    if($movePayload){[IO.Directory]::Move($payload,$versionPath)}',
            }
            for checkpoint, marker in checkpoints.items():
                managed = work / ('fresh interrupted '+checkpoint)
                report['last_operation'] = {'operation': 'interrupt_bootstrap', 'checkpoint': checkpoint, 'destination': str(managed.relative_to(work))}
                signal = work / (checkpoint+'.bootstrap-checkpoint')
                source = installer.read_text(encoding='utf-8-sig')
                assert source.count(marker) == 1
                escaped = str(signal).replace("'", "''")
                pause = "[IO.File]::WriteAllText('"+escaped+"','ready');while(Test-Path -LiteralPath '"+escaped+"'){Start-Sleep -Milliseconds 100}"
                if checkpoint == 'staging':
                    pause = "$partial=Join-Path $stage 'partial-download.zip';[IO.File]::WriteAllBytes($partial,[byte[]](1,2,3));"+pause
                elif checkpoint == 'extraction':
                    pause = "$partial=Join-Path $expanded 'partial-extraction.bin';[IO.File]::WriteAllBytes($partial,[byte[]](1,2,3));"+pause
                replacement = marker+'\n'+pause if checkpoint == 'version_move' else pause+'\n'+marker
                source = source.replace(marker, replacement, 1)
                instrumented = work / (checkpoint+'-bootstrap-instrumented.ps1')
                instrumented.write_text(source, encoding='utf-8')
                process = subprocess.Popen([str(powershell), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(instrumented),
                                            '-Destination', str(managed), '-NoPath', '-Archive', str(archive),
                                            '-ExpectedSha256', archive_sha, '-Preview'], cwd=work,
                                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                try:
                    deadline = time.monotonic()+45
                    while not signal.exists():
                        if process.poll() is not None:
                            raise AssertionError(process.communicate()[1].decode('utf-8', 'replace'))
                        if time.monotonic() >= deadline:
                            raise AssertionError('bootstrap checkpoint was not reached: '+checkpoint)
                        time.sleep(.025)
                    process.kill()
                    process.communicate(timeout=10)
                finally:
                    if process.poll() is None:
                        process.kill()
                        process.communicate(timeout=10)
                ownership = json.loads((managed / '.luau-bootstrap.json').read_text())
                stage = managed / ownership['stage_name']
                assert stage.is_dir() and not (managed / '.luau-installation.json').exists()
                assert json.loads((stage / '.luau-stage-owner.json').read_text())['transaction_id'] == ownership['transaction_id']
                local(archive)
                assert json.loads(install(['-Doctor', '-Json']).stdout)['passed']
                assert not stage.exists() and not (managed / '.luau-bootstrap.json').exists()
                record('fresh_interrupted_'+checkpoint+'_retries_from_durable_owned_bootstrap',
                       invoker_sha256=digest(instrumented.read_bytes()), fault='actual process termination before initial activation',
                       scope='owned partial bytes are present before termination; retry uses the unmodified installer')
                install(['-Uninstall'])
            managed = work / 'unowned staging preserved'
            managed.mkdir()
            unowned = managed / ('.staging-'+'f'*32)
            unowned.mkdir()
            user_file = unowned / 'user.txt'
            user_file.write_text('preserve')
            local(archive, success=False)
            assert user_file.read_text() == 'preserve'
            record('staging_like_unowned_directory_is_never_recovered_or_deleted')
        finally:
            managed = primary_managed
    if not args.bootstrap_only:
        manager_a = management_bytes('payload-a')
        manager_b = management_bytes('payload-b')
        management_a = variant('management-a', {'install.ps1': manager_a})
        management_b = variant('management-b', {'install.ps1': manager_b})

        install(['-Archive', archive, '-ExpectedSha256', archive_sha], success=False)
        record('preview_requires_explicit_selection')
        local(archive)
        original = current()
        if args.modern_previous_archive:
            modern_archive = pathlib.Path(args.modern_previous_archive).resolve()
            with zipfile.ZipFile(modern_archive) as prior_bundle:
                modern_manifest = json.loads(prior_bundle.read('runtime-manifest.json'))
                modern_installer = prior_bundle.read('install.ps1')
            assert modern_manifest['version'] != version and b'function Activate(' in modern_installer
            primary_managed = managed
            try:
                managed = work / 'modern installed updater transition'
                local(modern_archive)
                updater = managed / 'install.ps1'
                assert updater.read_bytes() == modern_installer
                local(archive, manager=updater)
                assert updater.read_bytes() == entries['install.ps1']
                assert json.loads(install(['-Doctor', '-Json'], manager=updater).stdout)['version'] == version
                record('genuine_modern_version_transition_installs_new_payload_management',
                       previous_version=modern_manifest['version'], version=version,
                       previous_archive_sha256=digest(modern_archive.read_bytes()),
                       previous_updater_sha256=digest(modern_installer), payload_updater_sha256=digest(entries['install.ps1']))
                install(['-Uninstall'])
            finally:
                managed = primary_managed
        if args.previous_archive:
            previous_archive = pathlib.Path(args.previous_archive).resolve()
            with zipfile.ZipFile(previous_archive) as old_bundle:
                previous_manifest = json.loads(old_bundle.read('runtime-manifest.json'))
                previous_installer = old_bundle.read('install.ps1')
            assert previous_manifest['version'] != version
            primary_managed = managed
            try:
                managed = work / 'legacy installed updater'
                local(previous_archive)
                old_manager = managed / 'install.ps1'
                assert old_manager.read_bytes() == previous_installer
                local(archive, manager=old_manager)
                assert old_manager.read_bytes() == previous_installer
                old_result = install(['-Doctor', '-Json'], manager=managed / current() / 'install.ps1')
                assert json.loads(old_result.stdout)['version'] == version
                repair = install(['-RepairManagement', '-Json'], manager=managed / current() / 'install.ps1')
                assert json.loads(repair.stdout)['repaired_management']
                assert old_manager.read_bytes() == entries['install.ps1']
                local(management_a, manager=old_manager)
                assert old_manager.read_bytes() == manager_a
                record('genuine_version_transition_from_old_installed_updater_requires_explicit_verified_repair',
                       previous_version=previous_manifest['version'], version=version,
                       previous_archive_sha256=digest(previous_archive.read_bytes()),
                       old_updater_sha256=digest(previous_installer), new_management_sha256=digest(entries['install.ps1']),
                       scope='Unmodified older updater first installs the new runtime while retaining its own old script; explicit new payload repair then promotes verified new management, and its next update installs new payload bytes')
                install(['-Uninstall'])
                managed = work / 'legacy interrupted activation'
                local(previous_archive)
                signal = work / 'legacy-activation.checkpoint'
                escaped = str(signal).replace("'", "''")
                marker = '    Atomic-Text $pointerPath ($relative+"`n")'
                source = previous_installer.decode('utf-8-sig')
                assert source.count(marker) == 1
                source = source.replace(marker, marker+"\n[IO.File]::WriteAllText('"+escaped+"','ready');while(Test-Path -LiteralPath '"+escaped+"'){Start-Sleep -Milliseconds 100}",1)
                manager = managed / 'install.ps1'
                manager.write_text(source,encoding='utf-8')
                instrumented_sha256 = digest(manager.read_bytes())
                ownership = json.loads((managed / '.luau-installation.json').read_text())
                next(file for file in ownership['root_files'] if file['path']=='install.ps1')['sha256'] = digest(manager.read_bytes())
                (managed / '.luau-installation.json').write_text(json.dumps(ownership),encoding='utf-8')
                child = subprocess.Popen([str(powershell),'-NoProfile','-ExecutionPolicy','Bypass','-File',str(manager),
                                          '-Destination',str(managed),'-NoPath','-Archive',str(archive),
                                          '-ExpectedSha256',archive_sha,'-Preview'],cwd=work,
                                         stdout=subprocess.PIPE,stderr=subprocess.PIPE)
                try:
                    deadline = time.monotonic()+45
                    while not signal.exists():
                        if child.poll() is not None:
                            raise AssertionError(child.communicate()[1].decode('utf-8','replace'))
                        if time.monotonic()>=deadline:
                            raise AssertionError('legacy activation checkpoint was not reached')
                        time.sleep(.025)
                    child.kill()
                    child.communicate(timeout=10)
                finally:
                    if child.poll() is None:
                        child.kill()
                        child.communicate(timeout=10)
                assert json.loads((managed / '.luau-installation.json').read_text())['current_version']==previous_manifest['version']
                assert not (managed / '.luau-activation.json').exists()
                repair = install(['-RepairManagement','-Json'],manager=managed / current() / 'install.ps1')
                assert json.loads(repair.stdout)['version']==version
                recovered = json.loads((managed / '.luau-installation.json').read_text())
                assert recovered['current_version']==version and recovered['versions'][-1]['archive_sha256'] is None
                assert recovered['versions'][-1]['recovered_from_active_manifest']
                assert manager.read_bytes()==entries['install.ps1']
                record('legacy_interrupted_activation_repaired_explicitly_from_verified_active_payload',
                       previous_version=previous_manifest['version'], version=version,
                       instrumented_updater_sha256=instrumented_sha256,
                       scope='Actual process termination after old updater pointer write, before ownership metadata; original updater and owned fixture state were instrumented solely to expose the boundary')
                install(['-Uninstall'])
            finally:
                managed = primary_managed
        if args.legacy_only:
            install(['-Uninstall'])
            report['passed'] = True
            report_path.write_text(json.dumps(report, indent=2)+'\n')
            print('Legacy installer scenarios passed:', len(cases))
            return
        if not args.admission_only:
            installed = managed / original / 'bin/luau-decompile.exe'
            assert digest(installed.read_bytes()) == next(file['sha256'] for file in manifest['files'] if file['path']=='bin/luau-decompile.exe')
            record('fresh_install_unicode_and_spaces', executable_sha256=digest(installed.read_bytes()))
            local(archive)
            assert current() == original
            record('idempotent_rerun')
            restricted_modules = work / 'isolated module lookup'
            restricted_modules.mkdir()
            restricted_manager = work / 'installer-without-optional-module-functions.ps1'
            source = installer.read_text(encoding='utf-8-sig')
            assert source.count("$ErrorActionPreference='Stop'") == 1
            restricted_source = source.split("$ErrorActionPreference='Stop'", 1)[0]
            restricted_source += "$ErrorActionPreference='Stop'\n"
            for module in ['Utility', 'Management']:
                restricted_source += "Import-Module ([Reflection.Assembly]::Load('Microsoft.PowerShell.Commands."+module+", Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35').Location)\n"
            restricted_source += "$PSModuleAutoLoadingPreference='None'\n"
            restricted_source += "$env:PSModulePath='"+str(restricted_modules).replace("'", "''")+"'\n"
            restricted_source += "if(Get-Command Get-FileHash -ErrorAction SilentlyContinue){throw 'Optional file-hash command unexpectedly available'}\n"
            restricted_source += "& '"+str(installer).replace("'", "''")+"' @PSBoundParameters\n"
            restricted_manager.write_text(restricted_source, encoding='utf-8-sig')
            local(archive, manager=restricted_manager)
            assert current() == original
            assert json.loads(install(['-Doctor', '-Json'], manager=restricted_manager).stdout)['passed']
            record('installer_stream_hashing_without_optional_file_hash_command', unavailable_command='Get-FileHash',
                   module_auto_loading='None', scope='Controlled Windows PowerShell child; not an observation of the CI module environment')
            installed_diagnosis = install(['-Doctor', '-Json'])
            assert json.loads(installed_diagnosis.stdout)['passed']
            shim = subprocess.run([os.environ['COMSPEC'], '/d', '/c', str(managed / 'luau-decompile.cmd'), 'doctor', '--json'],
                                  stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=35)
            assert shim.returncode == 0 and json.loads(shim.stdout)['passed']
            record('offline_doctor_and_command_shim_from_separate_directory')
            damaged = work / 'corrupt.zip'
            damaged.write_bytes(archive_bytes[:len(archive_bytes)//2]+b'corrupt')
            local(damaged, archive_sha, success=False)
            assert current() == original
            record('corrupt_archive_preserves_working_runtime')
            changed = dict(entries)
            changed['README.md'] += b'\n'
            changed_manifest = json.loads(changed['runtime-manifest.json'])
            for file in changed_manifest['files']:
                if file['path'] == 'README.md':
                    file['bytes'] = len(changed['README.md'])
                    file['sha256'] = digest(changed['README.md'])
            changed['runtime-manifest.json'] = json.dumps(changed_manifest).encode()
            update = work / 'updated.zip'
            with zipfile.ZipFile(update, 'w', compression=zipfile.ZIP_DEFLATED) as output:
                for name, data in changed.items():
                    output.writestr(name, data)
            local(update)
            assert current() != original
            record('verified_same_version_payload_update')
            install(['-Rollback'])
            assert current() == original
            record('rollback_to_verified_previous_payload')
            local(management_a)
            assert (managed / 'install.ps1').read_bytes() == manager_a
            assert digest(manager_a) != digest(installer.read_bytes())
            record('management_files_come_from_verified_payload_not_invoker', installed_sha256=digest(manager_a))
            local(management_b, manager=managed / 'install.ps1')
            assert (managed / 'install.ps1').read_bytes() == manager_b
            record('installed_updater_advances_to_new_payload_management', old_sha256=digest(manager_a), new_sha256=digest(manager_b))
            for checkpoint in ['after_pointer', 'after_metadata']:
                recovering = variant('activation-'+checkpoint, {'install.ps1': manager_b, 'README.md': entries['README.md']+checkpoint.encode()})
                before_metadata = (managed / '.luau-installation.json').read_bytes()
                fault = interrupt_activation('activation-'+checkpoint, recovering, checkpoint)
                journal = json.loads((managed / '.luau-activation.json').read_text())
                after_metadata = (managed / '.luau-installation.json').read_bytes()
                assert (after_metadata == before_metadata) == (checkpoint == 'after_pointer')
                diagnosis = install(['-Doctor', '-Json'], manager=managed / 'install.ps1')
                assert json.loads(diagnosis.stdout)['passed']
                assert not (managed / '.luau-activation.json').exists()
                assert current() == journal['target_path']
                recovered = json.loads((managed / '.luau-installation.json').read_text())
                assert next(file['sha256'] for file in recovered['root_files'] if file['path']=='current') == digest((managed / 'current').read_bytes())
                assert not (managed / journal['stage_name']).exists()
                record('interrupted_activation_'+checkpoint+'_recovers_before_consistency_checks', **fault)
            recovering = variant('activation-user-change', {'install.ps1': manager_b, 'README.md': entries['README.md']+b'user-change'})
            fault = interrupt_activation('activation-user-change', recovering, 'after_pointer')
            configuration = managed / 'release.json'
            release_bytes = configuration.read_bytes()
            configuration.write_bytes(release_bytes+b' ')
            install(['-Doctor'], success=False, manager=managed / 'install.ps1')
            assert configuration.read_bytes() == release_bytes+b' ' and (managed / '.luau-activation.json').exists()
            configuration.write_bytes(release_bytes)
            install(['-Doctor'], manager=managed / 'install.ps1')
            record('activation_recovery_preserves_intervening_user_modification', **fault)
            local(archive)
            original = current()
    state = {'interrupted': True, 'resolutions': 0}
    asset_name = 'luau-decompiler-'+version+'-windows-x64.zip'
    pause_asset = threading.Event()
    asset_reached = threading.Event()
    resume_asset = threading.Event()
    pause_after_prefix = threading.Event()

    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self, *unused):
            pass

        def do_GET(self):
            if self.path.startswith('/releases'):
                state['resolutions'] += 1
                base = 'http://127.0.0.1:'+str(self.server.server_port)
                release = {'id': 1, 'tag_name': 'v'+version, 'prerelease': '-' in version, 'draft': False,
                           'published_at': '2026-11-11T00:00:00Z', 'assets': [
                               {'name': asset_name, 'browser_download_url': base+'/'+asset_name},
                               {'name': asset_name+'.sha256', 'browser_download_url': base+'/'+asset_name+'.sha256'}]}
                body = json.dumps([release] if '?' in self.path else release).encode()
            elif self.path.endswith('.sha256'):
                body = (archive_sha+'  '+asset_name+'\n').encode()
            else:
                body = archive_bytes
                if pause_after_prefix.is_set():
                    self.send_response(200)
                    self.send_header('Content-Length',str(len(body)))
                    self.end_headers()
                    self.wfile.write(body[:65536])
                    self.wfile.flush()
                    asset_reached.set()
                    if resume_asset.wait(40):
                        try:
                            self.wfile.write(body[65536:])
                        except (ConnectionError, OSError):
                            pass
                    self.close_connection = True
                    return
                if pause_asset.is_set():
                    asset_reached.set()
                    if not resume_asset.wait(40):
                        self.close_connection = True
                        return
                if state['interrupted']:
                    self.send_response(200)
                    self.send_header('Content-Length',str(len(body)))
                    self.end_headers()
                    self.wfile.write(body[:4096])
                    self.close_connection = True
                    return
            self.send_response(200)
            self.send_header('Content-Length',str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    try:
        mirror = 'http://127.0.0.1:'+str(server.server_port)+'/releases'
        primary_managed = managed
        if not args.admission_only:
            managed = work / 'fresh killed during real download'
            report['last_operation'] = {'operation': 'interrupt_http_download', 'destination': str(managed.relative_to(work))}
            state['interrupted'] = False
            asset_reached.clear()
            resume_asset.clear()
            pause_after_prefix.set()
            process = subprocess.Popen([str(powershell), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(installer),
                                        '-Destination', str(managed), '-NoPath', '-ReleaseApi', mirror, '-Preview'], cwd=work,
                                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            try:
                if not asset_reached.wait(40):
                    raise AssertionError('real fresh archive download was not reached')
                deadline = time.monotonic()+10
                while True:
                    journal = json.loads((managed / '.luau-bootstrap.json').read_text())
                    partial = managed / journal['stage_name'] / asset_name
                    if partial.exists() and partial.stat().st_size > 0:
                        break
                    if time.monotonic() >= deadline or process.poll() is not None:
                        raise AssertionError('real fresh archive bytes were not persisted')
                    time.sleep(.025)
                partial_bytes = partial.stat().st_size
                assert 0 < partial_bytes < len(archive_bytes)
                process.kill()
                process.communicate(timeout=10)
                assert partial.exists() and not (managed / '.luau-installation.json').exists()
            finally:
                if process.poll() is None:
                    process.kill()
                    process.communicate(timeout=10)
                resume_asset.set()
                pause_after_prefix.clear()
            local(archive)
            assert json.loads(install(['-Doctor', '-Json']).stdout)['passed']
            assert not partial.exists() and not (managed / '.luau-bootstrap.json').exists()
            record('fresh_killed_mid_http_download_retries_without_unowned_residue', partial_download_bytes=partial_bytes,
                   complete_archive_bytes=len(archive_bytes), fault='actual process termination during incomplete controlled loopback release-mirror archive body')
            install(['-Uninstall'])
            managed = primary_managed
        if args.bootstrap_only:
            report['passed'] = True
            report_path.write_text(json.dumps(report, indent=2)+'\n')
            print('Installer bootstrap scenarios passed:', len(cases))
            return
        for collision in ['modified_owned', 'new_unowned']:
            if collision == 'new_unowned':
                managed = work / 'concurrent fresh installation'
            report['last_operation'] = {'operation': 'concurrent_download', 'collision': collision, 'destination': str(managed.relative_to(work))}
            state['interrupted'] = False
            pause_asset.set()
            asset_reached.clear()
            resume_asset.clear()
            process = subprocess.Popen([str(powershell),'-NoProfile','-ExecutionPolicy','Bypass','-File',str(installer),
                                        '-Destination',str(managed),'-NoPath','-ReleaseApi',mirror,'-Preview'],cwd=work,
                                       stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            management = managed / 'install.ps1'
            previous = None
            try:
                if not asset_reached.wait(40):
                    raise AssertionError('controlled release download boundary was not reached')
                previous = management.read_bytes() if management.exists() else None
                user_bytes = (previous or b'')+b"\n$userOwnedDuringDownload='preserve me'\n"
                management.write_bytes(user_bytes)
                resume_asset.set()
                stdout, stderr = process.communicate(timeout=60)
                assert process.returncode != 0, 'management modification during download was overwritten'
                assert b'Modified or unowned management file was preserved' in stderr
                assert management.read_bytes() == user_bytes and not (managed/'.luau-activation.json').exists()
                if collision == 'modified_owned':
                    assert current() == original
                else:
                    assert not (managed/'current').exists() and not (managed/'.luau-installation.json').exists()
                record('activation_rejects_'+collision+'_management_created_during_download')
            finally:
                resume_asset.set()
                pause_asset.clear()
                if process.poll() is None:
                    process.kill()
                    process.communicate(timeout=10)
                if previous is not None:
                    management.write_bytes(previous)
                managed = primary_managed
        if args.admission_only:
            install(['-Uninstall'])
            report['passed'] = True
            report_path.write_text(json.dumps(report, indent=2)+'\n')
            print('Installer admission scenarios passed:', len(cases))
            return
        state['interrupted'] = True
        prior_resolutions = state['resolutions']
        install(['-ReleaseApi', mirror, '-Preview'], success=False)
        assert current() == original and state['resolutions'] == prior_resolutions+1
        record('interrupted_download_preserves_working_runtime')
        state['interrupted'] = False
        install(['-ReleaseApi', mirror, '-Version', version, '-Preview'])
        assert current() == original and state['resolutions'] == prior_resolutions+2
        record('explicit_version_resolved_once_and_verified_before_activation')
    finally:
        server.shutdown()
        server.server_close()
    preserved = managed / 'user-configuration.json'
    preserved.write_text('{"custom":true}')
    modified = managed / current() / 'README.md'
    modified.write_text('user notes')
    empty_user_directory = managed / current() / 'user-owned-empty-directory'
    empty_user_directory.mkdir()
    install(['-Uninstall'])
    assert preserved.read_text() == '{"custom":true}' and modified.read_text() == 'user notes' and empty_user_directory.is_dir()
    assert not (managed / 'current').exists() and not (managed / 'luau-decompile.cmd').exists()
    record('uninstall_removes_owned_payload_and_preserves_user_and_modified_files')
    local(archive)
    assert preserved.is_file() and modified.is_file()
    record('reinstall_preserves_previous_user_data')
    install(['-Uninstall'])
    local(archive)
    management = managed / 'install.ps1'
    preserved_manager = b"$userOwnedManagement='preserve me'\n"
    management.write_bytes(preserved_manager)
    install(['-Uninstall'])
    assert management.read_bytes()==preserved_manager
    local(archive, success=False)
    assert management.read_bytes()==preserved_manager and not (managed/'current').exists()
    record('uninstall_retained_management_cannot_be_overwritten_by_reinstall')
    retained = managed / 'user-owned-management.ps1'
    management.rename(retained)
    local(archive)
    assert retained.read_bytes()==preserved_manager
    install(['-Uninstall'])
    record('reinstall_after_explicit_user_move_preserves_retained_management')
    if args.registry_path:
        registry_probe = work / 'registry-path-actions.ps1'
        registry_probe.write_text(REGISTRY_PATH_SCRIPT, encoding='utf-8')

        def shell_value(action, environment=None, value_file=None):
            report['last_operation'] = {'operation': 'registry_'+action, 'destination': str(managed.relative_to(work))}
            arguments = [str(powershell),'-NoProfile','-ExecutionPolicy','Bypass','-File',str(registry_probe),'-Action',action]
            if value_file is not None:
                arguments += ['-ValueFile',str(value_file)]
            value = subprocess.run(arguments, env=environment,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15, check=True).stdout.strip()
            return base64.b64decode(value).decode('utf-8')

        before = shell_value('user_path')
        try:
            install(['-Archive', archive, '-ExpectedSha256', archive_sha, '-Preview'], no_path=False)
            after = shell_value('user_path')
            assert after == (before+';' if before else '')+str(managed)
            environment = dict(os.environ)
            environment['PATH'] = shell_value('machine_path')+';'+after
            assert pathlib.Path(shell_value('command_path', environment)) == managed/'luau-decompile.cmd'
            install(['-Uninstall'], no_path=False)
            assert shell_value('user_path') == before
            record('actual_per_user_path_discovery_and_owned_entry_removal')
            report['path_updates'] = 'Actual temporary per-user PATH entry and fresh environment command discovery; unrelated entries preserved'
        finally:
            current_path = shell_value('user_path')
            parts = current_path.split(';')
            for index in range(len(parts)-1,-1,-1):
                if parts[index].casefold() == str(managed).casefold():
                    del parts[index]
                    value_file = work / 'restore-user-path.utf8'
                    value_file.write_text(';'.join(parts), encoding='utf-8')
                    shell_value('set_user_path', value_file=value_file)
                    break
    report['passed'] = True
    report_path.write_text(json.dumps(report, indent=2)+'\n')
    print('Installer scenarios passed:',len(cases))


if __name__ == '__main__':
    failure_context = {}
    try:
        main(failure_context)
    except Exception as error:
        if failure_context:
            report = failure_context['report']
            report['passed'] = False
            frames = traceback.extract_tb(error.__traceback__)
            report['failure'] = {'exception_type': type(error).__name__, 'message': str(error)[:4096],
                                 'last_completed_case': report.get('last_completed_case'), 'last_operation': report.get('last_operation'),
                                 'location': {'file': frames[-1].filename, 'line': frames[-1].lineno, 'function': frames[-1].name},
                                 'traceback': ''.join(traceback.format_exception(type(error), error, error.__traceback__))[-8192:]}
            try:
                failure_context['path'].write_text(json.dumps(report, indent=2)+'\n')
            except OSError as report_error:
                error.add_note('Could not retain installer failure report: '+str(report_error)[:1024])
        raise
