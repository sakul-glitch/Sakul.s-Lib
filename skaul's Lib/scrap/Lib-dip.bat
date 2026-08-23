@echo off
title the lib
color 0a
cls
echo.
echo -==========#==========#==========-
echo              -scrap-
echo -==========#==========#==========-
echo.
rem Prüfe, ob die Lib im übergeordneten game-Ordner vorhanden ist
set "libDest=%~dp0..\skaul's Lib"

rem Debug: zeige den Pfad, den wir prüfen
echo Pruefe Lib-Pfad: "%libDest%"

rem Prüfe, ob das Lib-Verzeichnis existiert
if not exist "%libDest%\" (
    echo Lib nicht gefunden, moechtest du sie herunterladen? (y/n)

    set /p answer=
    if /i "%answer%"=="y" (
        echo Herunterladen der Lib...
        echo.
        set "zipPath=%TEMP%\Sakul.s-Lib.zip"
        curl -L -o "%zipPath%" "https://github.com/sakul-glitch/Sakul.s-Lib/archive/refs/heads/main.zip"
        if errorlevel 1 (
            echo Fehler beim Herunterladen der Lib.
        ) else (
            echo Erstelle Zielordner und entpacke die Lib...
            mkdir "%libDest%" >nul 2>&1
            powershell -NoProfile -Command "Expand-Archive -LiteralPath \"%zipPath%\" -DestinationPath \"%libDest%\" -Force"
            if errorlevel 1 (
                echo Fehler beim Entpacken der Lib.
            ) else (
                echo Lib installiert.
            )
            del "%zipPath%" >nul 2>&1
        )
    ) else (
        echo Lib nicht heruntergeladen.
        echo Es beinhaltet alle Dateien, die fuer das Spiel benoetigt werden.
    )
) else (
    rem Ordner existiert - prüfe, ob das erwartete Flag (helper.bat) vorhanden ist
    if not exist "%libDest%\helper.bat" (
        echo Achtung: Lib-Ordner gefunden, aber "helper.bat" fehlt.
    ) else (
        echo Lib gefunden in "%libDest%" - Suche nach Mods in der Lib...
    )
)

echo Suche nach Mods in "%modFolder%"...
echo.