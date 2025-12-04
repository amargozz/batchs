@echo off
setlocal enabledelayedexpansion

::PREFIX is FIRST LETTERS IN COMMON NAME
set "prefix=PREFIX"
set "source=\\server\source\folder"

set "activeCount=0"

echo   SEARCHING NODES WITH PREFIX: %prefix%
echo ==================================================
echo.
pause

for /f "tokens=*" %%i in ('dsquery computer -name %prefix%*') do (
    set "dn=%%i"

    :: CLEAR COMPUTER NAME
    set "dn=!dn:"=!"
    for /f "tokens=1,2 delims==," %%a in ("!dn!") do (
        if /i "%%a"=="CN" (
            set "computer=%%b"
        )
    )
	
    ::PING COMPUTER
    ping -n 1 !computer! | find "TTL=" >nul
    if !errorlevel! == 0 (
        set /a activeCount+=1

        ::TARGET FULL PATH
        set "target=\\!computer!\C$\Users\Public\Desktop\TARGET"

        ::CREATE FOLDER IF MISSING
        if not exist "!target!" (
            echo !computer! - folder does not exist, creating...
            mkdir "!target!"
        )

        ::COPY FILES
        echo [OK] !computer! - Copying files...
        xcopy "%source%\*" "!target!\" /E /Y /I >nul
    )
)

echo.
echo ==================================================
echo Total completed: %activeCount%

endlocal
pause




