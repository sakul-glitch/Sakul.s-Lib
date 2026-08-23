@echo off
title Documentation Installer
color 0a
cls

echo.
:chooseSource
:start
echo Choose source: 1) Repository file  2) Wiki pages
set /p "sourceChoice=Select 1 or 2 (default 1): "
rem sanitize input: remove spaces and take first character to avoid parentheses or extra text
set "sourceChoice=%sourceChoice: =%"
if "%sourceChoice%"=="" set "sourceChoice=1"
if defined sourceChoice set "sourceChoice=%sourceChoice:~0,1%"
if /i "%sourceChoice%"=="1" goto :afterChoice
if /i "%sourceChoice%"=="2" goto :afterChoice
echo Invalid selection. Please enter 1 or 2.
goto :chooseSource
:afterChoice
if /i "%sourceChoice%"=="2" (
    rem --- Wiki flow using curl: list wiki pages from the wiki index and download as HTML ---
    set /p "installPath=Installation path (e.g., C:\Program Files\Documentation): "
    if not defined installPath (
        echo No installation path provided. Aborting.
        pause
        exit /b 1
    )

    mkdir "%installPath%" 2>nul

    set "wikiIndexUrl=https://github.com/sakul-glitch/Sakul.s-Lib/wiki"
    set "tmpIndex=%TEMP%\sakullib_wiki_index.html"
    echo Fetching wiki index...
    where curl >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo curl not found. Please install curl and try again.
        pause
        exit /b 1
    )
    curl -fsSL "%wikiIndexUrl%" -o "%tmpIndex%"
    if %ERRORLEVEL% neq 0 (
        echo Failed to fetch wiki index.
        del "%tmpIndex%" 2>nul
        pause
        exit /b 1
    )

    setlocal enabledelayedexpansion
    set /a idx=0
    for /f "usebackq delims=" %%L in ("%tmpIndex%") do (
        echo %%L | findstr /i "/sakul-glitch/Sakul.s-Lib/wiki/" >nul
        if !ERRORLEVEL! EQU 0 (
            for /f "tokens=2 delims=\"" %%A in ("%%L") do (
                set "link=%%A"
                echo !link! | findstr /i "/sakul-glitch/Sakul.s-Lib/wiki/" >nul
                if !ERRORLEVEL! EQU 0 (
                    set /a idx+=1
                    set "link!idx!=!link!"
                    set "pname=!link:/sakul-glitch/Sakul.s-Lib/wiki/=!"
                    echo !idx!. !pname!
                )
            )
        )
    )

    if %idx%==0 (
        endlocal
        del "%tmpIndex%" 2>nul
        echo No wiki pages found.
        pause
        exit /b 1
    )

    set /p "sel=Enter number to download (or 'all' to download all pages): "
    if /i "%sel%"=="all" (
        for /l %%i in (1,1,%idx%) do (
            set "ln=!link%%i!"
            set "pname=!ln:/sakul-glitch/Sakul.s-Lib/wiki/=!"
            set "pageUrl=https://github.com!ln!"
            echo Downloading !pname! as plain text...
            where powershell >nul 2>&1
            if !ERRORLEVEL! EQU 0 (
                set "pg=!pageUrl!"
                set "pn=!pname!"
                set "of=%installPath%\!pn!.txt"
                powershell -NoProfile -Command "param($u,$o) try{ (Invoke-WebRequest -UseBasicParsing -Uri $u).ParsedHtml.body.InnerText | Out-File -Encoding utf8 $o } catch { exit 1 }" -ArgumentList "!pg!","%of%"
                if errorlevel 1 echo Failed to extract text: !pname!
            ) else (
                echo PowerShell not found, saving raw HTML instead.
                curl -fsSL "!pageUrl!" -o "%installPath%\!pname!.html"
                if errorlevel 1 echo Failed: !pname!
            )
        )
    ) else (
        set /a choiceIndex=%sel% 2>nul
        if %choiceIndex% LSS 1 (
            echo Invalid selection.
            endlocal
            del "%tmpIndex%" 2>nul
            pause
            exit /b 1
        )
        if %choiceIndex% GTR %idx% (
            echo Invalid selection.
            endlocal
            del "%tmpIndex%" 2>nul
            pause
            exit /b 1
        )
        set "ln=!link%choiceIndex%!"
        set "pname=!ln:/sakul-glitch/Sakul.s-Lib/wiki/=!"
        set "pageUrl=https://github.com!ln!"
        echo Downloading !pname! as plain text...
        where powershell >nul 2>&1
        if !ERRORLEVEL! EQU 0 (
            set "pg=!pageUrl!"
            set "pn=!pname!"
            set "of=%installPath%\!pn!.txt"
            powershell -NoProfile -Command "param($u,$o) try{ (Invoke-WebRequest -UseBasicParsing -Uri $u).ParsedHtml.body.InnerText | Out-File -Encoding utf8 $o } catch { exit 1 }" -ArgumentList "!pg!","%of%"
            if errorlevel 1 (
                echo Download failed.
                endlocal
                del "%tmpIndex%" 2>nul
                pause
                exit /b 1
            )
        ) else (
            echo PowerShell not found, saving raw HTML instead.
            curl -fsSL "!pageUrl!" -o "%installPath%\!pname!.html"
            if errorlevel 1 (
                echo Download failed.
                endlocal
                del "%tmpIndex%" 2>nul
                pause
                exit /b 1
            )
        )
    )

    endlocal
    del "%tmpIndex%" 2>nul
    echo Done.
    pause
    exit /b 0
)
rem --- Repository file flow ---
set /p "installPath=Installation path (e.g., C:\Program Files\Documentation): "
set /p "docFile=Documentation filename to download (e.g., get-doc's.bat): "

set "missing="
if not defined installPath set "missing=%missing%Install path; "
if not defined docFile set "missing=%missing%Filename; "

if defined missing (
    echo Missing: %missing%
    set /p "retry=Do you want to retry? (y/N): "
    if /i "%retry%"=="y" (
        echo.
        goto :start
    ) else (
        echo Aborting.
        pause
        exit /b 1
    )
)

mkdir "%installPath%" 2>nul
set "url=https://raw.githubusercontent.com/sakul-glitch/Sakul.s-Lib/main/%docFile%"

echo Downloading "%docFile%" to "%installPath%" using curl...
where curl >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo curl not found. Please install curl and try again.
    pause
    exit /b 1
)

curl -fsSL -o "%installPath%\%docFile%" "%url%"
if %ERRORLEVEL% neq 0 (
    echo Download failed.
    pause
    exit /b 1
)

echo Done: "%installPath%\%docFile%"
pause
exit /b 0