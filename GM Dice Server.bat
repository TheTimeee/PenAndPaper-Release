@echo off
setlocal enabledelayedexpansion

REM STATIC, NO_UPDATE

powershell.exe -ExecutionPolicy Bypass -File "ds.ps1"

endlocal