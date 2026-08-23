@echo off
title ANSI SGR Demo
rem Erzeuge ESC in einer Batch-Datei
for /F "delims=" %%A in ('"prompt $E & for %%B in (1) do rem"') do set "ESC=%%A"

echo %ESC%[1;31mFett/Hell Rot%ESC%[0m
echo %ESC%[1;32mFett/Hell Gruen%ESC%[0m
echo %ESC%[1;33mFett/Hell Gelb%ESC%[0m
echo %ESC%[1;34mFett/Hell Blau%ESC%[0m
echo %ESC%[1;35mFett/Hell Magenta%ESC%[0m
echo %ESC%[1;36mFett/Hell Cyan%ESC%[0m
echo %ESC%[1;37mFett/Hell Weiss%ESC%[0m
echo.

echo 256-Farben Beispiel (Code 202):
echo %ESC%[38;5;202mOrange-ish (38;5;202)%ESC%[0m
echo.

echo TrueColor Beispiel (255;100;0):
echo %ESC%[38;2;255;100;0mTrueColor Orange (38;2;255;100;0)%ESC%[0m
echo.
pause
exit /b
