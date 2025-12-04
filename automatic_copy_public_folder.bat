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
    rem Extraer el nombre del equipo desde el DN
    for /f "tokens=2 delims==," %%a in ("!dn!") do (
        set "computer=%%a"
        echo ping !computer!...
        ping -n 1 !computer! | find "TTL=" >nul
        if !errorlevel! == 0 (
            set /a activeCount+=1

            ::TARGET FULL PATH
            set "target=\\!computer!\C$\Users\Public\Desktop\PUBLIC_FOLDER_NAME"

            rem Crear carpeta destino si no existe
            if not exist "!destino!" (
                echo !computer! - folder does not exist, creating...
                mkdir "!target!"
            )

            rem Copiar archivos
            echo Copiando accesos a !computer!...
            xcopy "%source%\*" "!target!\" /E /Y /I
        )
    )
)

echo.
echo Total de equipos activos procesados: %activeCount%

endlocal

pause

