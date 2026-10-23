param([Parameter(Mandatory=$true)][string]$SourceExe,[Parameter(Mandatory=$true)][string]$Version,[string]$Notes='업데이트')
$ErrorActionPreference='Stop'
if($Version -notmatch '^\d+(\.\d+){1,3}$'){throw '올바른 버전을 입력하세요.'}
function Normalize([string]$text){$v=[version]$text;return [version]::new($v.Major,$v.Minor,[Math]::Max(0,$v.Build),[Math]::Max(0,$v.Revision))}
$source=Get-Item -LiteralPath $SourceExe
if((Normalize $source.VersionInfo.FileVersion) -ne (Normalize $Version)){throw 'EXE 내부 버전과 배포 버전이 다릅니다. 먼저 새 버전으로 빌드하세요.'}
$manifestPath=Join-Path $PSScriptRoot 'latest.json'
if(Test-Path -LiteralPath $manifestPath){$prior=Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json;if((Normalize $Version) -le (Normalize $prior.version)){throw '현재 배포보다 높은 버전으로 준비하세요.'}}
$folder=Join-Path $PSScriptRoot $Version
if(Test-Path -LiteralPath $folder){throw '같은 버전 폴더가 이미 있습니다. 덮어쓰지 않습니다.'}
New-Item -ItemType Directory -Path $folder | Out-Null
$dest=Join-Path $folder 'ToothFairyJapan.exe'
Copy-Item -LiteralPath $source.FullName -Destination $dest
if(Test-Path -LiteralPath ($source.FullName+'.config')){Copy-Item -LiteralPath ($source.FullName+'.config') -Destination ($dest+'.config')}
$manifest=[ordered]@{product='ToothFairyJapan';version=$Version;file="$Version/ToothFairyJapan.exe";sha256=(Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant();size=(Get-Item -LiteralPath $dest).Length;notes=$Notes}
$manifest | ConvertTo-Json | Set-Content -Encoding utf8 -LiteralPath $manifestPath
Write-Output '배포 준비 완료. GitHub Desktop에서 새 폴더와 latest.json을 함께 Commit / Push하세요.'
