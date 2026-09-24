@echo off
setlocal

:: Point %APPDATA%\nushell at this repo's nushell folder. A junction needs no admin.
:: %~dp0 is this script's folder, so it works from any current directory.
set "SOURCE_PATH=%~dp0nushell"
set "TARGET_PATH=%APPDATA%\nushell"

if not exist "%SOURCE_PATH%\config.nu" (
    echo [abort] %SOURCE_PATH%\config.nu not found.
    pause
    exit /b 1
)

:: A junction left by an earlier run: plain rmdir removes the link itself and
:: never touches the repo files it points at.
rmdir "%TARGET_PATH%" 2>nul

if exist "%TARGET_PATH%\" (
    rem Nushell keeps its history and plugin registry beside the config. Move
    rem them into the repo folder ^(gitignored^) so replacing the folder keeps them.
    for %%F in (history.txt history.sqlite3 history.sqlite3-wal history.sqlite3-shm plugin.msgpackz) do (
        if exist "%TARGET_PATH%\%%F" if not exist "%SOURCE_PATH%\%%F" (
            echo Keeping %%F...
            move /Y "%TARGET_PATH%\%%F" "%SOURCE_PATH%\%%F" >nul
        )
    )
    if exist "%TARGET_PATH%\history.*" (
        echo [abort] History files are still in %TARGET_PATH% ^(close Nushell and retry^).
        pause
        exit /b 1
    )
    echo Removing existing nushell folder...
    rmdir /S /Q "%TARGET_PATH%"
)

if exist "%TARGET_PATH%\" (
    echo [abort] %TARGET_PATH% is still in use ^(close Nushell and retry^).
    pause
    exit /b 1
)

echo Creating junction...
mklink /J "%TARGET_PATH%" "%SOURCE_PATH%"
if %errorLevel% neq 0 (
    echo Failed to create the junction.
    pause
    exit /b 1
)
echo %TARGET_PATH% now points to %SOURCE_PATH%
pause
