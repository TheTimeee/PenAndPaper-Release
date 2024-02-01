@echo off

REM Bypass for development
if not exist "bypass_update" (
    call update.bat
)

pause