param(
  [Parameter(Mandatory = $true)]
  [string]$InstallDir
)

$ErrorActionPreference = "Stop"
$exe = Join-Path $InstallDir "DekTV.exe"
if (-not (Test-Path $exe)) { throw "DekTV.exe nao encontrado em $InstallDir" }

$WshShell = New-Object -ComObject WScript.Shell

function New-Shortcut([string]$Path, [string]$Target, [string]$WorkDir) {
  $sc = $WshShell.CreateShortcut($Path)
  $sc.TargetPath = $Target
  $sc.WorkingDirectory = $WorkDir
  $sc.Description = "Dek TV"
  $sc.IconLocation = "$Target,0"
  $sc.Save()
}

$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Dek TV"
New-Item -ItemType Directory -Force -Path $startMenu | Out-Null

# Atalhos canonicos (sobrescreve se ja existirem).
New-Shortcut -Path (Join-Path $desktop "Dek TV.lnk") -Target $exe -WorkDir $InstallDir
New-Shortcut -Path (Join-Path $startMenu "Dek TV.lnk") -Target $exe -WorkDir $InstallDir

# Remove atalhos legados / nomes antigos apontando para app_player.
@(
  (Join-Path $desktop "app_player.lnk"),
  (Join-Path $desktop "Dek TV Player.lnk"),
  (Join-Path $startMenu "app_player.lnk")
) | ForEach-Object {
  if (Test-Path $_) { Remove-Item $_ -Force -ErrorAction SilentlyContinue }
}

Write-Host "Atalhos Dek TV atualizados (Area de Trabalho + Menu Iniciar)."
