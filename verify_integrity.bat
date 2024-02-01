@echo off

setlocal enabledelayedexpansion

set "manifest=manifest.ini"

REM Find manifest
if not exist "!manifest!" (
    echo Failed to find manifest.
    exit /b 1
)

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
                    
                REM check for file integrity based on manifest
                certutil -hashfile "!sPath!!sFile!" SHA512 | findstr /i /x /c:"!sHash!" > nul
                if !errorlevel! equ 0 (
                    if "%1" neq "run_secure" (
                        echo Hash of file !sPath!!sFile! is valid
                        echo Hash: !sHash!
                    )
                ) else (
                    if "%1" neq "run_secure" (
                        echo Hash of file !sPath!!sFile! is invalid
                        echo Hash: !sHash!
                    ) else (
                        exit /b 1
                    )
                )
            )
        )
    )
)

if "%1"=="run_secure" (
    exit /b 0
) else (
    echo:
    pause
)

endlocal