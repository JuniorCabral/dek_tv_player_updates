@echo off
setlocal EnableExtensions
REM 7zSD.sfx waits on this process, then deletes the extract folder.
powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0install.ps1"
exit /b %ERRORLEVEL%
