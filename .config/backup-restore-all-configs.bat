:: KnownPathList =^> https://superuser.com/questions/681744/how-to-generically-refer-to-the-appdata-folder-on-the-windows-command-line
:: XCOPY command =^> https://www.computerhope.com/xcopyhlp.htm
@echo off

:menu
echo Simple script backup/restore personal config files on Windows
echo 1 - Save Config
echo 2 - Load Config
echo 3 - Exit
choice /n /c:123 /M "Choose an options "
GOTO LABEL-%ERRORLEVEL%

:LABEL-1 CopyAll
echo Copy nvim settings...
rd /s /q %cd%\nvim
xcopy %LocalAppData%\nvim %cd%\nvim /I /E /Y

echo Copy Wezterm settings...
rd /s /q %cd%\wezterm
xcopy %UserProfile%\.config\wezterm %cd%\wezterm /I /E /Y

:: echo Copy Nushell setings...
:: rd /s /q %cd%\nushell
:: xcopy %AppData%\nushell %cd%\nushell /I /E /Y

echo Copy Neovide setings...
rd /s /q %cd%\neovide
xcopy %AppData%\neovide %cd%\neovide /I /E /Y

echo Done !!!
pause
goto exit

:LABEL-2 Restore
echo Restore nvim settings...
rd /s /q %LocalAppData%\nvim
xcopy %cd%\nvim %LocalAppData%\nvim /I /E /Y

echo Restore Wezterm settings...
rd /s /q %UserProfile%\.config\wezterm
xcopy %cd%\wezterm %UserProfile%\.config\wezterm /I /E /Y

:: echo Restore Nushell setings...
:: rd /s /q %AppData%\nushell
:: xcopy %cd%\nushell %AppData%\nushell /I /E /Y

echo Restore Neovide setings...
rd /s /q %AppData%\neovide
xcopy %cd%\neovide %AppData%\neovide /I /E /Y

echo Done restore !!!
pause
goto exit

:LABEL-3 Exit
:exit
@exit