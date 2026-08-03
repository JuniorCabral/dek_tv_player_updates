# Empacota o build Flutter Windows Release em um .exe autoextrator (7-Zip SFX)
# que instala em %LOCALAPPDATA%\DekTV\Player e cria atalhos.
# Uso (depois de `flutter build windows --release`):
#   .\scripts\package-windows-exe.ps1 [-ReleaseDir caminho] [-OutExe caminho] [-Version 1.0.10]

param(
  [string]$ReleaseDir = "c:\Projetos\dek_tv\app_player\build\windows\x64\runner\Release",
  [string]$OutExe = "",
  [string]$Version = "1.0.10"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$tools = Join-Path $root "tools\7zip"
$7za = Join-Path $tools "extra\x64\7za.exe"
$sfx = Join-Path $tools "lzma\bin\7zSD.sfx"
if (-not (Test-Path $7za)) { throw "7za nao encontrado em $7za" }
if (-not (Test-Path $sfx)) { throw "7zSD.sfx nao encontrado em $sfx" }
if (-not (Test-Path $ReleaseDir)) { throw "ReleaseDir inexistente: $ReleaseDir" }

$dist = Join-Path $root "dist"
$work = Join-Path $dist "win_pack"
$stage = Join-Path $work "stage"
New-Item -ItemType Directory -Force -Path $dist, $work | Out-Null
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# Copia Release + scripts de instalacao/atalhos
Copy-Item -Path (Join-Path $ReleaseDir "*") -Destination $stage -Recurse -Force
$installScripts = Join-Path $PSScriptRoot "windows-install"
Copy-Item (Join-Path $installScripts "install.cmd") $stage -Force
Copy-Item (Join-Path $installScripts "create_shortcuts.ps1") $stage -Force

if (-not $OutExe) { $OutExe = Join-Path $dist "dektv-player-windows.exe" }

$configPath = Join-Path $work "config.txt"
@(
  ';!@Install@!UTF-8!',
  'Title="Dek TV Player"',
  "BeginPrompt=`"Instalar / atualizar Dek TV Player $Version?`"",
  'ExtractTitle="Extraindo Dek TV Player"',
  'ExtractDialogText="Aguarde enquanto os arquivos sao preparados."',
  'RunProgram="install.cmd"',
  ';!@InstallEnd@!'
) | Set-Content -Path $configPath -Encoding Ascii

$archive = Join-Path $work "payload.7z"
if (Test-Path $archive) { Remove-Item $archive -Force }
& $7za a -t7z -mx=7 $archive "$stage\*"
if ($LASTEXITCODE -ne 0) { throw "7za falhou: $LASTEXITCODE" }

if (Test-Path $OutExe) { Remove-Item $OutExe -Force }
cmd /c "copy /b `"$sfx`" + `"$configPath`" + `"$archive`" `"$OutExe`"" | Out-Null
Get-Item $OutExe | Format-List FullName, Length, LastWriteTime
Write-Host "OK: $OutExe"
