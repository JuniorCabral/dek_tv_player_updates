@echo off
setlocal EnableExtensions
REM Instala Dek TV Player em %%LOCALAPPDATA%%\DekTV\Player e cria atalhos.

set "INSTALL_DIR=%LOCALAPPDATA%\DekTV\Player"
set "SRC=%~dp0"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1

echo Instalando Dek TV em "%INSTALL_DIR%"...
robocopy "%SRC%." "%INSTALL_DIR%" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul
if errorlevel 8 (
  echo Falha ao copiar arquivos.
  pause
  exit /b 1
)

REM Remove o instalador da pasta destino se foi copiado.
if exist "%INSTALL_DIR%\install.cmd" del /f /q "%INSTALL_DIR%\install.cmd" >nul 2>&1
if exist "%INSTALL_DIR%\create_shortcuts.ps1" del /f /q "%INSTALL_DIR%\create_shortcuts.ps1" >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -File "%SRC%create_shortcuts.ps1" -InstallDir "%INSTALL_DIR%"
if errorlevel 1 (
  echo Aviso: nao foi possivel criar atalhos automaticamente.
)

start "" "%INSTALL_DIR%\app_player.exe"
exit /b 0
