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
if /i "%answer%"=="n" goto END

echo Invalid input. Please enter 'y' or 'n'. 
pause /2 >nul
goto :MENU

:CONTINUE
cls
echo.
winget install microsoft.edit
echo.

:END
echo.
echo after presing any key, the script will close...    
echo.
pause /t 3 >nul