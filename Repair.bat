@echo off
setlocal enabledelayedexpansion

REM STATIC, NO_UPDATE

set "protocol=https"
set "thirdLevel=raw"
set "secondLevel=githubusercontent"
set "firstLevel=com"
set "user=TheTimeee"
set "repository=PenAndPaper-Release"
set "branch=main"

set "qualified=!protocol!://!thirdLevel!.!secondLevel!.!firstLevel!/!user!/!repository!/!branch!/"

set retries=3
set "manifest=manifest.ini"
set "output=repair.log"
set "selfScript=%~nx0"

if exist "!output!" (
    echo.>> !output!
    echo.>> !output!
)

echo Date: %DATE% %TIME%>> !output!
echo.>> !output!

REM Ask for Confirmation
echo DO NEVER EXECUTE THIS SCRIPT OUTSIDE OF THE PROJECT ROOT, THIS SCRIPT WILL DELETE ALL FILES IN ROOT AND SUBDIRECTORIES
set /p userChoice=Do you want to proceed? (yes/no): 
if /i "%userChoice%" equ "yes" (
    echo Repair process confirmed, proceeding
    echo Repair process confirmed, proceeding>> !output!
) else (
    echo Repair process aborted, exiting
    echo Repair process aborted, exiting>> !output!
    pause
    exit /b 0
)

REM Deleting all Files except for .sav Files, .log Files and the Repair Script
echo Deleting all Files except for .sav Files, .log Files and the Repair Script
echo Deleting all Files except for .sav Files, .log Files and the Repair Script>> !output!
for /r %%F in (*) do (
    if "%%~nxF" neq "!selfScript!" if /i not "%%~xF" equ ".sav" if /i not "%%~xF" equ ".log" (
        echo Deleting "%%F"
        echo Deleting "%%F">> !output!

        del "%%F" /f /q
    )
)

REM Downloading Manifest
curl --silent --retry !retries! --output "!manifest!" "!qualified!!manifest!"

REM Check for errors
if %errorlevel% equ 0 (
    echo Downloaded Manifest successfully
    echo Downloaded Manifest successfully>> !output!
) else (
    echo Failed to download Manifest, exiting
    echo Failed to download Manifest, exiting>> !output!
    pause
    exit /b 1
)

REM Creating Directories
for /f "tokens=*" %%a in ('type %manifest% ^| findstr /r "^[^;].*="') do (
    set "line=%%a"
    for /f "tokens=1,* delims== " %%b in ("!line!") do (
        set "key=%%b"
        set "value=%%c"

        if "!key!" equ "sDir" (
            if not exist "!value!" (
                mkdir "!value!"
                echo Created Directory: !value!
                echo Created Directory: !value!>> !output!
            )
        )
    )
)

REM Start Repair
echo Starting Downloads
echo Starting Downloads>> !output!

REM Downloading Files
for /f "tokens=*" %%a in ('type %manifest% ^| findstr /r "^[^;].*="') do (
    set "line=%%a"
    for /f "tokens=1,* delims== " %%b in ("!line!") do (
        set "key=%%b"
        set "value=%%c"

        if "!key!" equ "sFile" (
            for /f "tokens=1-5 delims=," %%a in ("!value!") do (
                set "spaceChar= "

                REM Split Params
                set "sPath=%%a"
                set "sFile=%%b"
                set "sHash=%%c"
                set "iEncoding=%%d"
                set "iEol=%%e"

                REM Trim Data
                set "subStr=!sPath:~0,1!"
                if !subStr! equ !spaceChar! (
                    set "sPath=!sPath:~1!"
                )
                    
                set "subStr=!sFile:~0,1!"
                if !subStr! equ !spaceChar! (
                    set "sFile=!sFile:~1!"
                )

                set "subStr=!sHash:~0,1!"
                if !subStr! equ !spaceChar! (
                    set "sHash=!sHash:~1!"
                )

                set "subStr=!iEncoding:~0,1!"
                if !subStr! equ !spaceChar! (
                    set "iEncoding=!iEncoding:~1!"
                )

                set "subStr=!iEol:~0,1!"
                if !subStr! equ !spaceChar! (
                    set "iEol=!iEol:~1!"
                )
                    
                REM Downloading File
                curl --silent --retry !retries! --output "!sPath!!sFile!" "!qualified!!sPath!!sFile: =%%20!"

                REM Check for Errors
                if %errorlevel% equ 0 (
                    echo Downloaded !qualified!!sPath!!sFile: =%%20! successfully
                    echo Downloaded !qualified!!sPath!!sFile: =%%20! successfully>> !output!
                ) else (
                    echo Failed to download !qualified!!sPath!!sFile: =%%20!, exiting
                    echo Failed to download !qualified!!sPath!!sFile: =%%20!, exiting>> !output!
                    pause
                    exit /b 1
                )

                REM Check for File integrity based on Manifest
                certutil -hashfile "!sPath!!sFile!" SHA512 | findstr /i /x /c:"!sHash!" > nul
                if !errorlevel! equ 0 (
                    echo Hash of File !sPath!!sFile! is valid
                    echo Hash: !sHash!
                    echo Hash of File !sPath!!sFile! is valid>> !output!
                    echo Hash: !sHash!>> !output!
                ) else (
                    echo Hash of File !sPath!!sFile! is invalid
                    echo Hash: !sHash!
                    echo Exiting
                    echo Hash of File !sPath!!sFile! is invalid>> !output!
                    echo Hash: !sHash!>> !output!
                    echo Exiting>> !output!
                    pause
                    exit /b 1
                )
            )
        )
    )
)

echo Finished Downloads
echo Finished Downloads>> !output!

pause

endlocal