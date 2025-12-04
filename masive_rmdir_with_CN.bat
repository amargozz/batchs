@echo off
setlocal enabledelayedexpansion

set "prefix=PREFIX"
set "publicFolder=DIR_NAME"
set "dryRun=1"

set "activeCount=0"
set "deletedCount=0"
set "totalCount=0"

echo   SEARCHING NODES WITH PREFIX: %prefix%
echo   DRY RUN: %dryRun% (0 real, 1 simulation)
echo ==================================================
echo.
pause

for /f "usebackq delims=" %%i in (`dsquery computer -name %prefix%*`) do (

    set /a totalCount+=1

    :: Quitar comillas
    set "dn=%%i"
    set "dn=!dn:"=!"

    :: Extraer CN antes de la primera coma
    for /f "tokens=1 delims=," %%a in ("!dn!") do (
        set "cn=%%a"
    )

    :: QUITAR CN= DE FORMA SEGURA
    set "computer=!cn!"
    if /i "!computer:~0,3!"=="CN=" set "computer=!computer:~3!"

    :: PING
    ping -n 1 !computer! | find "TTL=" >nul
    if errorlevel 1 (
        echo [UNREACHABLE] !computer! - skkiped.
    ) else (

        set /a activeCount+=1

        set "target=\\!computer!\C$\Users\Public\Desktop\%publicFolder%"

        if exist "!target!" (
            if "%dryRun%"=="1" (
                echo [DRY RUN] target found: "!target!"
            ) else (
                echo removing...
                rmdir /S /Q "!target!"
                if errorlevel 0 (
                    echo [OK] target removed
                    set /a deletedCount+=1
                ) else (
                    echo [ERROR] can't remove target
                )
            )
        ) else (
            echo Target does not exist.
        )

    )
)

echo.
echo ==================================================
echo Total nodes: %totalCount%
echo Online: %activeCount%
if "%dryRun%"=="1" (
    echo DRY RUN: Nothing has been removed :)
) else (
    echo Targets removed: %deletedCount%
)
echo.
pause
exit /b
