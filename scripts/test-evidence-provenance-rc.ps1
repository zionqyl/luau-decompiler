$ErrorActionPreference='Stop'
$taskRoot=(Get-Location).Path
. ./scripts/release-integrity.ps1
$loaded=@('Assert-HistoricalLiveSources','Get-ArchivedExecutorBytes','Assert-ExecutorLobsFrame','Assert-IndependentExecutorEvidence','Assert-Rc2LiveSources')
foreach($path in @('scripts/verify-release-evidence-v3.ps1','scripts/verify-release-evidence-rc.ps1')){
 $parseErrors=$null;$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $taskRoot $path),[ref]$null,[ref]$parseErrors)
 if($parseErrors.Count){throw ($parseErrors|Out-String)}
 foreach($node in $ast.FindAll({param($candidate)$candidate -is [Management.Automation.Language.FunctionDefinitionAst]},$true)){
  if($node.Name -in $loaded){. ([scriptblock]::Create($node.Extent.Text))}
 }
}
$testRoot=Join-Path $taskRoot ('artifacts/evidence-provenance-negative-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $testRoot 'fixtures'),(Join-Path $testRoot 'docs/results'),(Join-Path $testRoot 'evidence/releases') -Force|Out-Null
Copy-Item -LiteralPath fixtures/historical -Destination (Join-Path $testRoot 'fixtures') -Recurse
Copy-Item -LiteralPath fixtures/observations -Destination (Join-Path $testRoot 'fixtures') -Recurse
$historicalManifestPath=Join-Path $taskRoot 'evidence/releases/0.4.0-rc.2-manifest.json'
if((Get-FileHash -LiteralPath $historicalManifestPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne 'c0ee70787fc558f769611f6f361c59bb9774620cc6bec3c3379257acb16acfa4'){throw 'Historical rc.2 evidence manifest changed'}
$historicalManifest=Get-Content -LiteralPath $historicalManifestPath -Raw|ConvertFrom-Json
if($historicalManifest.schema -ne 1 -or $historicalManifest.version -cne '0.4.0-rc.2' -or $historicalManifest.archive_path -cne 'evidence/releases/0.4.0-rc.2-evidence.zip'){throw 'Historical rc.2 evidence archive identity is unsupported'}
$historicalArchivePath=Join-Path $taskRoot $historicalManifest.archive_path
if((Get-FileHash -LiteralPath $historicalArchivePath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $historicalManifest.archive_sha256){throw 'Historical rc.2 evidence archive changed'}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$historicalArchive=[IO.Compression.ZipFile]::OpenRead($historicalArchivePath)
$historicalFixtures=@()
try{
 foreach($name in @('madium-live-v3.json','madium-live-rc2.json')){
  $relative='reports/docs/results/'+$name
  $record=@($historicalManifest.files|Where-Object{$_.path -ceq $relative})
  if($record.Count -ne 1 -or $record[0].bytes -lt 1 -or $record[0].bytes -gt 1048576){throw 'Historical report fixture is missing or unbounded'}
  $entry=$historicalArchive.GetEntry($relative)
  if(-not $entry -or $entry.Length -ne $record[0].bytes){throw 'Historical report fixture length changed'}
  $stream=$entry.Open();$buffer=[IO.MemoryStream]::new()
  try{$stream.CopyTo($buffer);$bytes=$buffer.ToArray()}finally{$buffer.Dispose();$stream.Dispose()}
  $algorithm=[Security.Cryptography.SHA256]::Create()
  try{$hash=([BitConverter]::ToString($algorithm.ComputeHash($bytes))).Replace('-','').ToLowerInvariant()}finally{$algorithm.Dispose()}
  if($hash -cne $record[0].sha256){throw 'Historical report fixture bytes changed'}
  [IO.File]::WriteAllBytes((Join-Path $testRoot ('docs/results/'+$name)),$bytes)
  $historicalFixtures+=@{name=$name;archive_entry=$relative;sha256=$hash;scope='Historical immutable test fixture; not current live evidence'}
 }
}finally{$historicalArchive.Dispose()}
$historicalPath=Join-Path $testRoot 'docs/results/madium-live-v3.json'
$rc2LivePath=Join-Path $testRoot 'docs/results/madium-live-rc2.json'
$historical=Get-Content -LiteralPath $historicalPath -Raw|ConvertFrom-Json
Assert-HistoricalLiveSources $historical $testRoot
$current=Assert-IndependentExecutorEvidence
$rc2Live=Get-Content -LiteralPath $rc2LivePath -Raw|ConvertFrom-Json
foreach($pair in @(@($rc2Live.archive_path,$rc2Live.archive_sha256),@($rc2Live.archive_manifest,$rc2Live.archive_manifest_sha256))){
 if($pair[0] -notin @('evidence/releases/0.4.0-rc.2-live.zip','evidence/releases/0.4.0-rc.2-live-manifest.json')){throw 'Historical rc.2 live fixture path is unsupported'}
 $source=Join-Path $taskRoot $pair[0]
 if((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -cne $pair[1]){throw 'Historical rc.2 live fixture bytes changed'}
 Copy-Item -LiteralPath $source -Destination (Join-Path $testRoot $pair[0])
}
$rc2Sources=Assert-Rc2LiveSources $rc2Live $testRoot
if($rc2Sources.Count -ne 2){throw 'Historical rc.2 embedded adapter/observer identities are incomplete'}
if($current.reports.Count -ne 2){throw 'External report presence statuses are incomplete'}
foreach($report in @($current.reports|Where-Object{$_.present})){if($report.matches_current_executable -ne ($report.recorded_executable_sha256 -ceq $report.current_executable_sha256)){throw 'Current executable equality was misreported'}}
foreach($source in $current.sources){$sourcePath=Join-Path $taskRoot $source.path;$actual=(Test-Path -LiteralPath $sourcePath -PathType Leaf) -and (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant() -ceq $source.recorded_sha256;if($source.matches_current_source -ne $actual){throw 'Current source equality was misreported'}}
$externalManifest=Get-Content fixtures/observations/rc-20261111/manifest.json -Raw|ConvertFrom-Json
foreach($identity in $externalManifest.reports){$archivedReport=@($externalManifest.files|Where-Object{$_.id -ceq $identity.archive_id})[0];[IO.File]::WriteAllBytes((Join-Path $testRoot $identity.path),(Get-ArchivedExecutorBytes $archivedReport $taskRoot))}
$independent=Assert-IndependentExecutorEvidence $testRoot
if(@($independent.reports|Where-Object{$_.matches_current_executable}).Count -ne 0 -or @($independent.sources|Where-Object{$_.matches_current_source}).Count -ne 0){throw 'Independent evidence was mislabeled current'}
foreach($name in @('madium-live-v3','madium-live-rc','native-functions-rc')){$normalizedPath=Join-Path $testRoot ('docs/results/'+$name+'.json');$normalized=[IO.File]::ReadAllText($normalizedPath).Replace("`r`n","`n");[IO.File]::WriteAllText($normalizedPath,$normalized,[Text.UTF8Encoding]::new($false))}
Assert-HistoricalLiveSources $historical $testRoot
$normalized=Assert-IndependentExecutorEvidence $testRoot
if($normalized.reports.Count -ne 2){throw 'Git line-ending normalization lost independent evidence'}
$negativeCount=0
function Expect-Rejection([scriptblock]$Action){$rejected=$false;try{& $Action}catch{$rejected=$true};if(-not $rejected){throw 'Tampered evidence accepted'};$script:negativeCount++}
$rc2Live.adapter_sha256=('0'*64)
Expect-Rejection {Assert-Rc2LiveSources $rc2Live $testRoot}
$rc2Live=Get-Content -LiteralPath $rc2LivePath -Raw|ConvertFrom-Json
$rc2Live.archive_sha256=('0'*64)
Expect-Rejection {Assert-Rc2LiveSources $rc2Live $testRoot}
$historical.full_harness_attempt.fixture_plan.adapter_sha256=('0'*64)
Expect-Rejection {Assert-HistoricalLiveSources $historical $testRoot}
$historical=Get-Content -LiteralPath $historicalPath -Raw|ConvertFrom-Json
$historicalGzip=Join-Path $testRoot 'fixtures/historical/v0.3/decompile.luau.gz'
[IO.File]::WriteAllBytes($historicalGzip,([IO.File]::ReadAllBytes($historicalGzip)+[byte]0))
Expect-Rejection {Assert-HistoricalLiveSources $historical $testRoot}
Copy-Item -LiteralPath fixtures/historical/v0.3/decompile.luau.gz -Destination $historicalGzip -Force
$rcGzip=Join-Path $testRoot 'fixtures/observations/rc-20261111/native_fixed_output.gz'
[IO.File]::WriteAllBytes($rcGzip,([IO.File]::ReadAllBytes($rcGzip)+[byte]0))
Expect-Rejection {Assert-IndependentExecutorEvidence $testRoot}
Copy-Item -LiteralPath fixtures/observations/rc-20261111/native_fixed_output.gz -Destination $rcGzip -Force
$rcReport=Join-Path $testRoot 'docs/results/native-functions-rc.json'
[IO.File]::AppendAllText($rcReport,' ')
Expect-Rejection {Assert-IndependentExecutorEvidence $testRoot}
$archivedNativeReport=@($externalManifest.files|Where-Object{$_.id -ceq 'native_report'})[0]
[IO.File]::WriteAllBytes($rcReport,(Get-ArchivedExecutorBytes $archivedNativeReport $taskRoot))
Expect-Rejection {Assert-ExecutorLobsFrame '4c4f4253010100000000000100000003ff'}
Expect-Rejection {Assert-ExecutorLobsFrame '4c4f425301010000000000010000000000'}
Move-Item -LiteralPath (Join-Path $testRoot 'docs/results/madium-live-rc.json') -Destination (Join-Path $testRoot 'docs/results/madium-live-rc.omitted')
$optional=Assert-IndependentExecutorEvidence $testRoot
if(@($optional.reports|Where-Object{$_.id -eq 'live' -and -not $_.present}).Count -ne 1){throw 'Unavailable external evidence is not optional'}
[ordered]@{passed=$true;current_present_reports=@($current.reports|Where-Object{$_.present}).Count;isolated_positive_reports=2;current_source_statuses=$current.sources.Count;historical_archive_positive=$true;historical_fixture_archive_sha256=$historicalManifest.archive_sha256;historical_report_fixtures=$historicalFixtures;independent_identity_false_positive=$true;git_line_ending_normalization_positive=$true;optional_report_absence=$true;tampered_cases_rejected=$negativeCount;test_directory=$testRoot.Substring($taskRoot.Length+1).Replace('\','/')}|ConvertTo-Json -Depth 5|Tee-Object -FilePath artifacts/evidence-provenance-focused-results.json
