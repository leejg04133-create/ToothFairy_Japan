param([string]$Root=(Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),[string]$Tag=$env:RELEASE_TAG)
$ErrorActionPreference='Stop'
$repo='leejg04133-create/ToothFairy_Japan'
function Normalize([string]$text){$v=[version]$text;[version]::new($v.Major,$v.Minor,[Math]::Max(0,$v.Build),[Math]::Max(0,$v.Revision))}
if($Tag -notmatch '^\d+(\.\d+){1,3}$'){throw 'Use a numeric release tag, e.g. 1.0.1 or 1.1.'}
$release=gh api "repos/$repo/releases/tags/$Tag" | ConvertFrom-Json
if($LASTEXITCODE -or $release.draft -or $release.prerelease){throw 'A published stable release is required.'}
$asset=@($release.assets|Where-Object name -eq 'ToothFairyJapan.exe')
if($asset.Count -ne 1){throw 'Attach exactly one ToothFairyJapan.exe.'}
$dir=Join-Path ([IO.Path]::GetTempPath()) ('tfj-release-'+[Guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($dir)
try{
 gh release download $Tag --repo $repo --pattern ToothFairyJapan.exe --dir $dir
 if($LASTEXITCODE){throw 'Release download failed.'}
 $exe=Get-Item -LiteralPath (Join-Path $dir 'ToothFairyJapan.exe')
 if($exe.Length -lt 1024 -or $exe.Length -gt 2GB -or $exe.Length -ne $asset[0].size){throw 'Invalid download size.'}
 if((Normalize $exe.VersionInfo.FileVersion) -ne (Normalize $Tag)){throw 'EXE internal FileVersion must match the release tag.'}
 $hash=(Get-FileHash -LiteralPath $exe.FullName).Hash.ToLowerInvariant()
 if($asset[0].digest -and $asset[0].digest -ne "sha256:$hash"){throw 'GitHub asset digest mismatch.'}
 $path=Join-Path $Root 'latest.json'
 if(Test-Path -LiteralPath $path){$prior=Get-Content -LiteralPath $path -Raw|ConvertFrom-Json;if((Normalize $prior.version) -gt (Normalize $Tag)){throw 'Refusing version downgrade.'};if((Normalize $prior.version) -eq (Normalize $Tag) -and $prior.sha256 -ne $hash){throw 'Existing version differs. Publish a higher version.'}}
 $manifest=[ordered]@{product='ToothFairyJapan';version=$Tag;file="$Tag/ToothFairyJapan.exe";url="https://github.com/$repo/releases/download/$Tag/ToothFairyJapan.exe";sha256=$hash;size=$exe.Length;notes=$release.body}
 $manifest|ConvertTo-Json|Set-Content -LiteralPath $path -Encoding utf8NoBOM
 "Validated release $Tag without executing the EXE."
}finally{if([IO.Path]::GetFullPath($dir).StartsWith([IO.Path]::GetTempPath(),[StringComparison]::OrdinalIgnoreCase)){Remove-Item -LiteralPath $dir -Recurse -Force}}
