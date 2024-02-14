@echo off
setlocal enabledelayedexpansion

REM STATIC, NO_UPDATE

powershell.exe -ExecutionPolicy Bypass -File "pnp.ps1"

endlocal