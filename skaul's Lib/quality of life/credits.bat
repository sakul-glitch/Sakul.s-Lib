@echo off
title Credits
color 0a
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

if /i "%answer%"=="y" (
    start "" "https://www.youtube.com/@coolnes_of_fire/subscrib=?sub_confirmation=1"
    start "" "https://www.github.com/sakul-glitch"
    start "" "https://www.tiktok.com/@coolnes_of_fire"
    goto END
)

if /i "%answer%"=="n" (
    echo ok.
    pause /t 3 >nul
    goto END
)

echo Invalid input. Please enter 'y' or 'n'.
pause
goto END

:END 
echo.
echo after presing any key, the script will close...
echo.
pause /t 3 >nul