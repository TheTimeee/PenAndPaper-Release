@echo off

setlocal enabledelayedexpansion

set "dir=%~dp0"
set "file=dice_server.ps1"
set "qualified=!dir!!file!"

powershell.exe -ExecutionPolicy Bypass -Command "& {Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""!qualified!""' -Verb RunAs}"

endlocal