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
New-Item -ItemType Directory -Force -Path $dist, $work | Out-Null

# 7zSD.sfx sem manifesto dispara o detector de instalador do Windows (UAC).
# asInvoker: CreateProcess do Flutter e duplo-clique sem admin.
# mt.exe so adiciona RT_MANIFEST; o stub PE continua valido (7za lista o SFX).
$sfxAsInvoker = Join-Path $work "7zSD.asInvoker.sfx"
Copy-Item $sfx $sfxAsInvoker -Force
$manPath = Join-Path $work "asInvoker.manifest"
$manXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="asInvoker" uiAccess="false" />
      </requestedPrivileges>
    </security>
  </trustInfo>
</assembly>
"@
[System.IO.File]::WriteAllText($manPath, $manXml, (New-Object System.Text.UTF8Encoding $false))
$mt = $null
$cmdMt = Get-Command mt.exe -ErrorAction SilentlyContinue
if ($cmdMt) { $mt = $cmdMt.Source }
if (-not $mt -and (Test-Path "C:\Program Files (x86)\Windows Kits\10\bin")) {
  $kitMt = Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin" -Recurse -Filter mt.exe -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\x64\\mt\.exe$' } |
    Select-Object -First 1
  if ($kitMt) { $mt = $kitMt.FullName }
}
if ($mt) {
  $prevEap = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  & $mt -nologo -manifest $manPath "-outputresource:$sfxAsInvoker;#1"
  $mtCode = $LASTEXITCODE
  $ErrorActionPreference = $prevEap
  if ($mtCode -ne 0) { Write-Host "Aviso: mt.exe nao aplicou o manifesto asInvoker ($mtCode)" }
  else { $sfx = $sfxAsInvoker; Write-Host "SFX asInvoker: $sfx" }
} else {
  Write-Host "Aviso: mt.exe ausente; o instalador pode pedir UAC."
}

$stage = Join-Path $work "stage"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# Copia Release + scripts de instalacao/atalhos
Copy-Item -Path (Join-Path $ReleaseDir "*") -Destination $stage -Recurse -Force
$installScripts = Join-Path $PSScriptRoot "windows-install"
Copy-Item (Join-Path $installScripts "install.ps1") $stage -Force
Copy-Item (Join-Path $installScripts "install.cmd") $stage -Force
Copy-Item (Join-Path $installScripts "silent.vbs") $stage -Force
Copy-Item (Join-Path $installScripts "create_shortcuts.ps1") $stage -Force

if (-not $OutExe) { $OutExe = Join-Path $dist "dektv-player-windows.exe" }

# 7zSD.sfx (oficial): RunProgram e prefixado com ".\" — o exe tem de estar no payload.
# GUIMode/OverwriteMode sao de SFX modificados e sao ignorados aqui; Progress="no" e o equivalente.
# Nao use RunProgram="powershell.exe ..." — vira .\powershell.exe e falha com "arquivo nao encontrado".
$configPath = Join-Path $work "config.txt"
$config = @"
;!@Install@!UTF-8!
Title="Dek TV Player"
Progress="no"
RunProgram="silent.vbs"
;!@InstallEnd@!
"@
[System.IO.File]::WriteAllText($configPath, $config.Trim() + "`r`n", (New-Object System.Text.UTF8Encoding $false))

$archive = Join-Path $work "payload.7z"
if (Test-Path $archive) { Remove-Item $archive -Force }
& $7za a -t7z -mx=7 $archive "$stage\*"
if ($LASTEXITCODE -ne 0) { throw "7za falhou: $LASTEXITCODE" }

if (Test-Path $OutExe) { Remove-Item $OutExe -Force }
cmd /c "copy /b `"$sfx`" + `"$configPath`" + `"$archive`" `"$OutExe`"" | Out-Null
Get-Item $OutExe | Format-List FullName, Length, LastWriteTime
Write-Host "OK: $OutExe"
