@echo off
setlocal EnableExtensions
REM Instala/atualiza SEMPRE na mesma pasta: %LOCALAPPDATA%\DekTV\Player

set "INSTALL_DIR=%LOCALAPPDATA%\DekTV\Player"
set "SRC=%~dp0"

echo.
echo ========================================
echo   Dek TV — instalacao / atualizacao
echo ========================================
echo Pasta: "%INSTALL_DIR%"
echo.

REM Encerra instancias antigas para liberar o .exe (atualizacao in-place).
taskkill /IM DekTV.exe /F >nul 2>&1
taskkill /IM app_player.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1

echo Copiando arquivos...
robocopy "%SRC%." "%INSTALL_DIR%" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul
set "RC=%ERRORLEVEL%"
if %RC% GEQ 8 (
  echo Falha ao copiar arquivos. Codigo robocopy=%RC%
  pause
  exit /b 1
)

REM Limpa scripts de instalacao e binario antigo (renomeado).
if exist "%INSTALL_DIR%\install.cmd" del /f /q "%INSTALL_DIR%\install.cmd" >nul 2>&1
if exist "%INSTALL_DIR%\create_shortcuts.ps1" del /f /q "%INSTALL_DIR%\create_shortcuts.ps1" >nul 2>&1
if exist "%INSTALL_DIR%\app_player.exe" del /f /q "%INSTALL_DIR%\app_player.exe" >nul 2>&1

if not exist "%INSTALL_DIR%\DekTV.exe" (
  echo ERRO: DekTV.exe nao encontrado apos a copia.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%SRC%create_shortcuts.ps1" -InstallDir "%INSTALL_DIR%"
if errorlevel 1 (
  echo Aviso: nao foi possivel criar/atualizar atalhos automaticamente.
)

echo.
echo Instalacao concluida. Abrindo Dek TV...
start "" "%INSTALL_DIR%\DekTV.exe"
exit /b 0
