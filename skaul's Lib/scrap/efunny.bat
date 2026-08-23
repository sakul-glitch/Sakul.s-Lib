@echo off
title eFunny
color 0a
:MENU
cls
echo.
echo this file runs only ones!
echo so if you want to run it again, just run the file again! (or delete it whatever)
echo.
do you wisch to continue? (y/n)
set /p answer=  
if /i "%answer%"=="y" goto CONTINUE
if /i "%answer%"=="n" goto END
echo Invalid input. Please enter 'y' or 'n'.

:CONTINUE
cls
echo.
echo do you wisch to RESIVE an newsletter to your email? (y/n)
set /p answer2=


echo do you wisch to RESIVE an update-email to your email? (y/n)
set /p answer3=

if /i "%answer2%"=="y" (
    echo You will receive a newsletter to your email.
) else (
    echo You will not receive a newsletter to your email.
)

if /i "%answer3%"=="y" (
    echo You will receive an update email.
) else (
    echo You will not receive an update email.
)

echo.
echo plese check the output file and put in the games config folder! (thank you...)
echo output file: mail.txt
echo echo press any key to continue...
pause >nul
rem create output file if it doesn't exist (fixed filename)
if not exist mail.txt (
    echo.>mail.txt
)

rem --- BEGIN: Text import area ---
rem Edit the lines below to change the text that will be written into mail.txt
rem To OVERWRITE the file with the block below, use the single > operator:
( 
    echo "youer email"
    echo the script is still in development,
    echo so you will not receive any emails yet, 
    echo but in the future you will receive emails with news and updates about the game, 
    echo so please check the updates for this script to get the new emails!
) > mail.txt

rem To APPEND additional lines instead of overwriting, use >> like this:
rem echo Weitere Zeile >> mail.txt

rem You can also write a variable's content into the file:
rem set "meinText=Das ist ein Test"
rem echo %meinText% >> mail.txt
rem --- END: Text import area ---