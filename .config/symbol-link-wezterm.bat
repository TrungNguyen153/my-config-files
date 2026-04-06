@echo off


:: Set your paths
set SOURCE_PATH=%cd%\wezterm
set TARGET_PATH=%userprofile%\.config\wezterm

:: Remove existing nvim folder if it exists
if exist "%TARGET_PATH%" (
    echo Removing existing nvim folder...
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
