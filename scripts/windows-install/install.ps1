# Silent install/update into %LOCALAPPDATA%\DekTV\Player (no console window).
param()

$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
$installDir = Join-Path $env:LOCALAPPDATA "DekTV\Player"

Get-Process -Name "DekTV","app_player" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
& robocopy $src $installDir /E /NFL /NDL /NJH /NJS /nc /ns /np /XF install.ps1 install.cmd create_shortcuts.ps1 | Out-Null
if ($LASTEXITCODE -ge 8) { exit $LASTEXITCODE }

$exe = Join-Path $installDir "DekTV.exe"
if (-not (Test-Path $exe)) { exit 1 }

$legacy = Join-Path $installDir "app_player.exe"
if (Test-Path $legacy) { Remove-Item $legacy -Force -ErrorAction SilentlyContinue }

$shortcutScript = Join-Path $src "create_shortcuts.ps1"
if (Test-Path $shortcutScript) {
  & $shortcutScript -InstallDir $installDir
}

# Processo novo, sem herdar o console do instalador.
Start-Process -FilePath $exe -WorkingDirectory $installDir -WindowStyle Normal
exit 0
