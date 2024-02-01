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
set "output=update.txt"

set update=0
set version=0

if exist "!output!" (
    echo.>> !output!
    echo.>> !output!
)

echo Date: %DATE% %TIME%>> !output!
echo.>> !output!

REM Find current version
if exist "!manifest!" (
    echo Manifest found
    echo Manifest found>> !output!
    for /f "tokens=*" %%a in ('type %manifest% ^| findstr /r "^[^;].*="') do (
        set "line=%%a"
        for /f "tokens=1,* delims== " %%b in ("!line!") do (
            set "key=%%b"
            set "value=%%c"

            if "!key!" equ "fVersion" (
                set version=!value!
                echo Version: !version!
                echo Version: !version!>> !output!
                goto :AfterOldManifest
            )
        )
    )
) else (
    echo Manifest not found
    echo Manifest not found>> !output!
)

:AfterOldManifest

REM Downloading server manifest
curl --silent --retry !retries! --output "!manifest!" "!qualified!!manifest!"

REM Check for errors
if %errorlevel% equ 0 (
    echo Downloaded new manifest successfully
    echo Downloaded new manifest successfully>> !output!
) else (
    echo Failed to download new manifest, exiting
    echo Failed to download new manifest, exiting>> !output!
    exit /b 0
)

REM Find new version and compare
REM Find current version
if exist "!manifest!" (
    for /f "tokens=*" %%a in ('type %manifest% ^| findstr /r "^[^;].*="') do (
        set "line=%%a"
        for /f "tokens=1,* delims== " %%b in ("!line!") do (
            set "key=%%b"
            set "value=%%c"

            if "!key!" equ "fVersion" (
                if !version! neq !value! (
                    set update=1
                    echo New Version: !value!
                    echo Require update
                    echo New Version: !value!>> !output!
                    echo Require update>> !output!
                ) else (
                    echo Client is up to date
                    echo Client is up to date>> !output!
                )

                goto :AfterNewManifest
            )
        )
    )

    echo New version not found, exiting
    echo New version not found, exiting>> !output!
    exit /b 0
) else (
    echo New manifest not found, exiting
    echo New manifest not found, exiting>> !output!
    exit /b 0
)

:AfterNewManifest

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

REM Update if requested
if !update! equ 1 (
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
                        exit /b 1
                    )

                    REM check for file integrity based on manifest
                    certutil -hashfile "!sPath!!sFile!" SHA512 | findstr /i /x /c:"!sHash!" > nul
                    if !errorlevel! equ 0 (
                        echo Hash of file !sPath!!sFile! is valid
                        echo Hash: !sHash!
                    ) else (
                        echo Hash of file !sPath!!sFile! is invalid
                        echo Hash: !sHash!
                        echo Exiting
                        exit /b 1
                    )
                )
            )
        )
    )

    echo Finished Update
    echo Finished Update>> !output!
)



endlocal