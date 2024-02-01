@echo off

setlocal enabledelayedexpansion

powershell.exe -ExecutionPolicy Bypass -WindowStyle Minimized -File "./server.ps1"

endlocal