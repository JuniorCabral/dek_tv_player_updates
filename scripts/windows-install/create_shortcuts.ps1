param(
  [Parameter(Mandatory = $true)]
  [string]$InstallDir
)

$ErrorActionPreference = "Stop"
$exe = Join-Path $InstallDir "app_player.exe"
if (-not (Test-Path $exe)) { throw "app_player.exe nao encontrado em $InstallDir" }

$WshShell = New-Object -ComObject WScript.Shell

function New-Shortcut([string]$Path, [string]$Target, [string]$WorkDir) {
  $sc = $WshShell.CreateShortcut($Path)
  $sc.TargetPath = $Target
  $sc.WorkingDirectory = $WorkDir
  $sc.Description = "Dek TV Player"
  $sc.IconLocation = "$Target,0"
  $sc.Save()
}

$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Dek TV"
New-Item -ItemType Directory -Force -Path $startMenu | Out-Null

New-Shortcut -Path (Join-Path $desktop "Dek TV.lnk") -Target $exe -WorkDir $InstallDir
New-Shortcut -Path (Join-Path $startMenu "Dek TV.lnk") -Target $exe -WorkDir $InstallDir

Write-Host "Atalhos criados na Area de Trabalho e no Menu Iniciar."
