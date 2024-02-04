@echo off
setlocal enabledelayedexpansion

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
set "output=repair.txt"

echo Date: %DATE% %TIME%>> !output!
echo.>> !output!

REM Downloading server manifest
curl --silent --retry !retries! --output "!manifest!" "!qualified!!manifest!"

REM Check for errors
if %errorlevel% equ 0 (
    echo Downloaded manifest successfully
    echo Downloaded manifest successfully>> !output!
) else (
    echo Failed to download new manifest, exiting
    echo Failed to download new manifest, exiting>> !output!
    pause
    exit /b 1
)

REM Creating directories
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

REM Repair
echo Starting update
echo Starting update>> !output!

REM Downloading Files
for /f "tokens=*" %%a in ('type %manifest% ^| findstr /r "^[^;].*="') do (
    set "line=%%a"
    for /f "tokens=1,* delims== " %%b in ("!line!") do (
        set "key=%%b"
        set "value=%%c"

        if "!key!" equ "sFile" (
            for /f "tokens=1-5 delims=," %%a in ("!value!") do (
                set "spaceChar= "

                REM Split params
                set "sPath=%%a"
                set "sFile=%%b"
                set "sHash=%%c"
                set "iEncoding=%%d"
                set "iEol=%%e"

                REM Trim data
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

                REM Check for errors
                if %errorlevel% equ 0 (
                    echo Downloaded !qualified!!sPath!!sFile: =%%20! successfully
                    echo Downloaded !qualified!!sPath!!sFile: =%%20! successfully>> !output!
                ) else (
                    echo Failed to download !qualified!!sPath!!sFile: =%%20!, exiting
                    echo Failed to download !qualified!!sPath!!sFile: =%%20!, exiting>> !output!
                    pause
                    exit /b 1
                )

                REM check for file integrity based on manifest
                certutil -hashfile "!sPath!!sFile!" SHA512 | findstr /i /x /c:"!sHash!" > nul
                if !errorlevel! equ 0 (
                    echo Hash of file !sPath!!sFile! is valid
                    echo Hash: !sHash!
                    echo Hash of file !sPath!!sFile! is valid>> !output!
                    echo Hash: !sHash!>> !output!
                ) else (
                    echo Hash of file !sPath!!sFile! is invalid
                    echo Hash: !sHash!
                    echo Exiting
                    echo Hash of file !sPath!!sFile! is invalid>> !output!
                    echo Hash: !sHash!>> !output!
                    echo Exiting>> !output!
                    pause
                    exit /b 1
                )
            )
        )
    )
)

echo Finished Update
echo Finished Update>> !output!

pause

endlocal