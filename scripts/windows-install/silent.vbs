' 7zSD.sfx prefixa RunProgram com ".\" — este .vbs precisa estar no payload.
' WindowStyle 0 = sem janela; Wait True = SFX só apaga a pasta depois do install.
Set sh = CreateObject("Wscript.Shell")
dir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
cmd = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & dir & "install.ps1"""
rc = sh.Run(cmd, 0, True)
WScript.Quit rc
