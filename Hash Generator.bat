@echo off
setlocal enabledelayedexpansion

REM STATIC, NO_UPDATE

if "%~1"=="" (
    echo Drag and drop a file onto this script.
    pause
    exit /b
)

certutil -hashfile "%~1" SHA512

pause