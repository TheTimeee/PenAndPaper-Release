@echo off

if not "%1"=="verified" (
    echo Checking for file integrity, please wait...
    call verify_integrity.bat run_secure
)

if %errorlevel% == 0 (
    cd ./client
    call ./server.bat
) else (
    echo Hash verification failed, at least one file is corrupted. Use "verify_integrity.bat" for further information.
    pause
)