@echo off


:: Set your paths
set FOLDER_NAME=neovide
set SOURCE_PATH=%cd%\%FOLDER_NAME%
set TARGET_PATH=%appdata%\%FOLDER_NAME%

:: Remove existing nvim folder if it exists
if exist "%TARGET_PATH%" (
    echo Removing existing %FOLDER_NAME% folder...
    rmdir /S /Q "%TARGET_PATH%"
)

:: Create symbolic link
echo Creating symbolic link...
:: Create junction (doesn't require admin!)
mklink /J "%TARGET_PATH%" "%SOURCE_PATH%"

if %errorLevel% equ 0 (
    echo Symbolic link created successfully!
    echo %TARGET_PATH% now points to %SOURCE_PATH%
) else (
    echo Failed to create symbolic link.
)

pause
