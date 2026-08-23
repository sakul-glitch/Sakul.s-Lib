@echo off
REM Helper batch file for common tasks
color 0A
title Skaul's Lib Helper Tool

:menu
cls
echo ========================================
echo        Skaul's Lib Helper Tool
echo ========================================
echo.
echo 1. beckup seve file (google drive)
echo.
echo 2. chanche meta settings (PLZ READ 'README' OR option 3)
echo
echo 3. information about me and this tool.
echo
echo e. Exit.
echo
echo r. README file.
echo.
set /p choice="Select an option (1-4): "

if "%choice%"=="1" goto :beckup
if "%choice%"=="2" goto :meta_settings
if "%choice%"=="3" goto :info
if "%choice%"=="e" goto :exit
if "%choice%"=="r" goto :readme
rem else goto :invalid_choice

:invalid_choice
cls
echo Invalid choice. Please try again.
pause
goto :menu

:beckup
cls
echo Backing up save file to Google Drive...
timeout /t 5 /nobreak > nul
echo do you relly think i was going to do that?
echo you have to do it manualy, (\'v'/)
echo and guess what? i made a guide for that in the 'README' file! - ai fuckt this up
pause


:exit
cls
title plz star my github repo :) (all that what i ask)
echo Exiting Skaul's Lib Helper Tool...
echo Please press 'enter' to exit.
pause
exit