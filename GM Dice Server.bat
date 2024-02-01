@echo off

echo Checking for file integrity, please wait...
call verify_integrity.bat run_secure

if %ERRORLEVEL% == 0 (
    cd ./dice_server
    call ./dice_server.bat
) else (
    echo Hash verification failed, at least one file is corrupted. Use "verify_integrity.bat" for further information.
    pause
)