@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Drag and drop a file onto this script.
    pause
    exit /b
)

certutil -hashfile "%~1" SHA512

pause