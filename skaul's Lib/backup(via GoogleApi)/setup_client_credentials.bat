@echo off
setlocal
set "DEST=C:\Users\%user%\%Folder%\clpg\client_credentials.json"
echo.
set /p CLIENTID=Geben Sie die Client ID ein: 
set /p CLIENTSECRET=Geben Sie die Client Secret ein: 
powershell -NoProfile -Command "$data = @{client_id='%CLIENTID%'; client_secret='%CLIENTSECRET%'} | ConvertTo-Json; Set-Content -Path '%DEST%' -Value $data -Encoding UTF8"
if %ERRORLEVEL% neq 0 (
  echo Fehler beim Schreiben der Datei.
  pause
  exit /b 1
)
echo Client credentials saved to %DEST%
set /p RUNAUTH=Moechten Sie jetzt das initiale Authentifizierungs-Skript ausfuehren? (J/N): 
if /I "%RUNAUTH%"=="j"
(
  powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\%user%\%Folder%\clpg\backup_to_gdrive.ps1"
)
endlocal
exit /b 0
if /I "%RUNAUTH%"=="n"
(
  echo Authentifizierung uebersprungen.
  pause
  exit /b 0
)
else
(
  echo Ungueltige Eingabe. Bitte starten Sie das Skript erneut.
  pause
  exit /b 1
)