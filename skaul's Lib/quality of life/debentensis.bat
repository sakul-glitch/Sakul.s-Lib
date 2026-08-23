@echo off
color 0a
title Debentensis
:MENU
cls
echo.
echo this script atomatically installs debentensis please follow the instructions on the screen!
echo.
echo do you wisch to continue? (y/n)
set /p answer=
if /i "%answer%"=="y" goto CONTINUE
if /i "%answer%"=="n" goto info

echo Invalid input. Please enter 'y' or 'n'. 
pause /2 >nul
goto :MENU

:info
cls
echo.
echo info: some scripts in this game need debentensis to work,
echo so this script will atomatically install debentensis for you,
echo if you start the scripts without debentensis, they will not work and show an error message,
echo so please install debentensis to avoid this problem!
echo.
echo after presing any key, the script will close...
echo.
pause /t 3 >nul
exit


:CONTINUE
cls
echo.
start credits.bat
echo.
echo installing debentensis...
echo.
winget install microsoft.edit
echo.
echo.
echo.
winget install curl
echo.
echo.
echo.

:END
echo.
echo debentensis has been installed!
echo (pls download 'curl' if you get prompted.)
echo in the future more debentensis will be needed, 
echo so please check the updates for this script to get the new debentensis!
echo.
echo after presing any key, thid will close...    
echo.
pause /t 3 >nul

set /p optional=do you wisch to install optional debentensis? (y/n)
if /i "%optional%"=="y" goto OPTIONAL
if /i "%optional%"=="n" goto FINISH

echo Invalid input. Please enter 'y' or 'n'.
pause >nul
goto :END

:OPTIONAL
cls
echo.
echo downloading optional debentensis...
echo.
curl -L --fail "https://example.com/optional-debentensis.zip" -o "%~dp0optional-debentensis.zip"
if errorlevel 1 (
    echo download failed.
    echo please check the URL or your internet connection.
    echo.
    pause >nul
    goto FINISH
)

echo optional debentensis downloaded successfully!
echo file saved to: "%~dp0optional-debentensis.zip"
echo.
pause >nul

goto FINISH

:FINISH
echo.
echo script finished.
exit /b