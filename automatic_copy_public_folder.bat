@echo off
setlocal enabledelayedexpansion

    ::PREFIX is FIRST LETTERS IN COMMON NAME
set "prefix=PREFIX"
set "source=\\SERVER\SOURCE\FOLDER"

set "activeCount=0"

echo   SEARCHING NODES WITH PREFIX: %prefix%
echo ==================================================
echo.
pause

for /f "tokens=*" %%i in ('dsquery computer -name %prefix%*') do (
    set "dn=%%i"
    ::EXTRACT COMPUTER NAME FROM CN
    for /f "tokens=2 delims==," %%a in ("!dn!") do (
        set "computer=%%a"

        ::PING COMPUTER
        ping -n 1 !computer! | find "TTL=" >nul
        if !errorlevel! == 0 (
            set /a activeCount+=1

            ::TARGET FULL PATH
            set "target=\\!computer!\C$\Users\Public\Desktop\PUBLIC_FOLDER_NAME"

           ::CREATING FOLDER IF NO EXIST
            if not exist "!destino!" (
                echo !computer! - folder does not exist, creating...
                mkdir "!target!"
            )

            ::COPY FILES FROM SRC TO DST
            echo [OK ] !computer! - Copying files 
            xcopy "%source%\*" "!target!\" /E /Y /I
        )
    )
)

echo.
echo Total completed: %activeCount%

endlocal

pause


