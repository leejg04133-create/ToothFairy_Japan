param([string]$Root = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
function Normalize([string]$text) {
    $v=[version]$text
    return [version]::new($v.Major,$v.Minor,[Math]::Max(0,$v.Build),[Math]::Max(0,$v.Revision))
}
$candidates=@(Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -match '^\d+(\.\d+){1,3}$' } | ForEach-Object {
    $exe=Join-Path $_.FullName 'ToothFairyJapan.exe'
    if(Test-Path -LiteralPath $exe){[pscustomobject]@{Folder=$_.Name;Version=(Normalize $_.Name);Exe=$exe}}
} | Sort-Object Version -Descending)
if($candidates.Count -eq 0){throw 'No version folder containing ToothFairyJapan.exe was found.'}
$latest=$candidates[0]
if(@($candidates | Where-Object {$_.Version -eq $latest.Version}).Count -ne 1){throw 'Duplicate version folder numbers. Keep one folder for each version.'}
$file=Get-Item -LiteralPath $latest.Exe
if($file.Length -lt 1024 -or $file.Length -gt 200MB){throw 'Invalid EXE size (or Git LFS pointer).'}
$internal=[Diagnostics.FileVersionInfo]::GetVersionInfo($file.FullName).FileVersion
if(!$internal -or (Normalize $internal) -ne $latest.Version){throw "Folder version $($latest.Folder) does not match EXE version $internal. Build the EXE with the new version first."}
$hash=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
$manifestPath=Join-Path $Root 'latest.json'
$notes="ToothFairy Japan $($latest.Folder)"
if(Test-Path -LiteralPath $manifestPath){
    $prior=Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if((Normalize $prior.version) -gt $latest.Version){throw 'Refusing to downgrade the published update.'}
    if((Normalize $prior.version) -eq $latest.Version){
        if($prior.sha256 -ne $hash){throw 'An existing version was overwritten. Publish a new version folder and EXE version instead.'}
        $notes=$prior.notes
    }
}
$notesPath=Join-Path $file.DirectoryName 'notes.txt'
if(Test-Path -LiteralPath $notesPath){$notes=(Get-Content -LiteralPath $notesPath -Raw -Encoding UTF8).Trim()}
$manifest=[ordered]@{product='ToothFairyJapan';version=$latest.Folder;file="$($latest.Folder)/ToothFairyJapan.exe";sha256=$hash;size=$file.Length;notes=$notes}
$json=($manifest | ConvertTo-Json -Depth 3)+[Environment]::NewLine
$temp=$manifestPath+'.tmp'
[IO.File]::WriteAllText($temp,$json,[Text.UTF8Encoding]::new($false))
Move-Item -LiteralPath $temp -Destination $manifestPath -Force
Write-Output "Validated $($latest.Folder); latest.json generated without executing the EXE."
