@echo off
setlocal enabledelayedexpansion

    :: SET PARAMETERS (dryRun: 0=real, 1=simulation)
set "prefix=PREFIX"
set "dir_target=FOLDER_NAME"
set "dryRun=1"

set "activeCount=0"
set "deletedCount=0"
set "totalCount=0"

echo   SEARCHING NODES WITH PREFIX: %prefix%
echo   TARGET DIRECTORY: %dir_target%
echo   DRY RUN: %dryRun% (0 real, 1 simulation)
echo ==================================================
echo.
pause

for /f "usebackq delims=" %%i in (`dsquery computer -name %prefix%*`) do (

    set /a totalCount+=1

    :: EXTRACT CN
    set "dn=%%i"
    set "dn=!dn:"=!"
    for /f "tokens=1 delims=," %%a in ("!dn!") do (
        set "cn=%%a")
    set "computer=!cn!"
    if /i "!computer:~0,3!"=="CN=" set "computer=!computer:~3!"

    :: PING
    ping -n 1 !computer! | find "TTL=" >nul
    if errorlevel 1 (
        echo [UNREACHABLE] !computer! - skipped.
    ) else (

        set /a activeCount+=1
        :: HERE THE TARGET FULL PATH
        set "target=\\!computer!\C$\Users\Public\Desktop\%dir_target%"

        if exist "!target!" (
            if "%dryRun%"=="1" (
                echo [DRY RUN] !computer! - target found: "!target!"
            ) else (
                rmdir /S /Q "!target!"
                if errorlevel 0 (
                    echo [OK] !computer! - target removed
                    set /a deletedCount+=1
                ) else (
                    echo [ERROR] !computer! - can't remove target
                )
            )
        ) else (
            echo     !computer! Target does not exist
        )

    )
)

echo.
echo ==================================================
echo Total nodes: %totalCount%
echo Online: %activeCount%
if "%dryRun%"=="1" (
    echo DRY RUN: Relax, nothing has been removed
) else (
    echo Targets removed: %deletedCount%
)
echo.
pause
exit /b
