@echo off

REM Bypass for development
if not exist "bypass_update" (
    call update.bat
)

REM Exit if update.bat returned that data is corrupted
if not %errorlevel% equ 0 (
    echo Updating failed with corrupted data.
    pause
    exit /b 1
)

echo Checking for file integrity, please wait...
call verify_integrity.bat run_secure

REM Exit if verify_integrity.bat returned that data is corrupted
if %errorlevel% equ 0 (
    start cmd /C "call ./start_server.bat verified"
    start cmd /C "call ./start_client.bat verified"
) else (
    echo Hash verification failed, at least one file is corrupted. Use "verify_integrity.bat" for further information.
    pause
)