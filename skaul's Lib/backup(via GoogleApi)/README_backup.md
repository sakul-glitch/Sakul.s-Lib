CLPG - Google Drive Backup (PowerShell-only)

Overview
- This folder contains a PowerShell-only backup solution that uploads files to Google Drive using the Drive REST API.
- No external binaries are required. Tokens are stored encrypted for the current Windows user.

Quickstart
1. Edit `backup_to_gdrive.ps1`: set `$SourcePath`, confirm `$ClientCredFile` path or create `client_credentials.json` as described in `gdrive_oauth_setup.txt`.
2. Run `backup_to_gdrive.ps1` interactively once:
   Open PowerShell and run:

   powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\%user%\%Folder%\clpg\backup_to_gdrive.ps1"
(if you do this on the desktop)
   The script will open a browser for OAuth. Paste the authorization code when prompted.
3. Verify a small file was uploaded to Drive folder `CLPG_Backups`.
4. Schedule the script using the `schtasks` example in `schtasks_example.txt`.

Files
- backup_to_gdrive.ps1: main script (upload logic, token handling, logging)
- token_store_helper.ps1: helpers to encrypt/decrypt token using DPAPI
- gdrive_oauth_setup.txt: how to create OAuth credentials in Google Cloud Console
- schtasks_example.txt: sample scheduled task command

Security
- Token file is protected by Windows DPAPI; only the same Windows user can decrypt it.
- Do not commit `client_credentials.json` or token files to a repository.

Support
- If upload fails, check logs in `logs` folder and ensure the Client ID/Secret are correct.
