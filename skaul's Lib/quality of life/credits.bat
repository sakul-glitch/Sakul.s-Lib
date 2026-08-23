@echo off
title Credits
color 0a
:MENU
cls
echo.
echo Credits:
echo.
echo gui disign: sakul-glitch
echo.
echo code: sakul-glitch
echo.
echo special thanks to:
echo - his frostraition
echo - his anger
echo - his sadness
echo - his depression
echo - his disepline
echo.
echo do you wisch to open his sozial links? (y/n)
set /p answer= 

:ASK
echo sure? (y/n)
set /p answer= 

if /i "%answer%"=="n" (
    start "" "https://www.youtube.com/@coolnes_of_fire/subscrib=?sub_confirmation=1"
    start "" "https://www.github.com/sakul-glitch"
    start "" "https://www.tiktok.com/@coolnes_of_fire"
    start "" "https://www.deviantart.com/deviskill/"
    goto END
)

if /i "%answer%"=="y" (
    echo ok.
    start "" "%~dp0..\gernerl\efunny.bat"
    goto END
)

echo Invalid input. Please enter 'y' or 'n'.
goto ASK

:END 
echo.
echo after presing any key, the script will close...
echo.
pause /t 3 >nul
exit