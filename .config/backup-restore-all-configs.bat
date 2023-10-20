:: KnownPathList =^> https://superuser.com/questions/681744/how-to-generically-refer-to-the-appdata-folder-on-the-windows-command-line
:: XCOPY command =^> https://www.computerhope.com/xcopyhlp.htm
@echo off

:menu
echo Simple script backup/restore personal config files on Windows
echo 1 - Copy all configs to cwd
echo 2 - Restore all configs in cwd to correct place
echo 3 - exit
choice /n /c:123 /M "Choose an options "
GOTO LABEL-%ERRORLEVEL%

:LABEL-1 CopyAll
echo Copy nvim settings...
rd /s /q %cd%\nvim
xcopy %LocalAppData%\nvim %cd%\nvim /I /E /Y

echo Copy Wezterm settings...
rd /s /q %cd%\wezterm
xcopy %UserProfile%\.config\wezterm %cd%\wezterm /I /E /Y

echo Copy Nushell setings...
rd /s /q %cd%\nushell
xcopy %AppData%\nushell %cd%\nushell /I /E /Y

echo Done !!!
pause
goto exit

:LABEL-2 Restore
echo Restore nvim settings...
xcopy %cd%\nvim %LocalAppData%\nvim /I /E /Y

echo Restore Wezterm settings...
xcopy %cd%\wezterm %UserProfile%\.config\wezterm /I /E /Y

echo Restore Nushell setings...
xcopy %cd%\nushell %AppData%\nushell /I /E /Y

echo Done restore !!!
pause
goto exit

:LABEL-3 Exit
:exit
@exit