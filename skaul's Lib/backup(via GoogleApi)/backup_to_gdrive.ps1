<#
backup_to_gdrive.ps1
PowerShell-only Google Drive backup (skeleton). No external tools required.
Edit the variables below (Source path, ClientId/Secret path) before first run.
Run once interactively to perform initial OAuth and store refresh_token.
#>

# Configuration - edit these
# Path to the local folder you want to back up (set to the project's `game` folder by default)
$SourcePath = "d:\Lukas\Stuff\clpg\game"
# Paths for logs, token and client credentials (uses current user profile)
$LogDir = Join-Path $env:USERPROFILE "Desktop\clpg\logs"
$TokenFile = Join-Path $env:USERPROFILE "Desktop\clpg\token.enc"
$ClientCredFile = Join-Path $env:USERPROFILE "Desktop\clpg\client_credentials.json" # optional file with client_id and client_secret
$UploadFolderName = "CLPG_Backups"  # folder name in Drive where files will be placed
$MultipartThresholdBytes = 5MB

# End configuration

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
$LogFile = Join-Path $LogDir ("backup_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

. "C:\Users\%user%\Desktop\clpg\token_store_helper.ps1" 2>$null

function Write-Log { param($msg) $t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; "[$t] $msg" | Tee-Object -FilePath $LogFile -Append }

# Load client credentials if file exists
$ClientId = $null; $ClientSecret = $null
if (Test-Path $ClientCredFile) {
    try {
        $json = Get-Content $ClientCredFile -Raw | ConvertFrom-Json
        $ClientId = $json.client_id
        $ClientSecret = $json.client_secret
    } catch { Write-Log "Failed to read client credentials: $_" }
}

function Start-Interactive-Auth {
    param()
    if (-not $ClientId) { Write-Log "Client ID not configured. Create client in Google Cloud Console and place client_credentials.json at $ClientCredFile"; throw "No Client ID" }

    $scope = [System.Web.HttpUtility]::UrlEncode("https://www.googleapis.com/auth/drive.file")
    $redirect = "urn:ietf:wg:oauth:2.0:oob"
    $authUrl = "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=$ClientId&redirect_uri=$redirect&scope=$scope&access_type=offline&prompt=consent"
    Write-Log "Opening browser for interactive authorization. If browser does not open, open this URL manually:`n$authUrl"
    Start-Process $authUrl
    $code = Read-Host "After granting access, paste the authorization code here"

    # Exchange code for tokens
    $body = @{ code = $code; client_id = $ClientId; client_secret = $ClientSecret; redirect_uri = $redirect; grant_type = 'authorization_code' }
    try {
        $resp = Invoke-RestMethod -Method Post -Uri 'https://oauth2.googleapis.com/token' -Body $body
        $refresh = $resp.refresh_token
        if ($refresh) {
            Save-EncryptedStringToFile -PlainText $refresh -FilePath $TokenFile
            Write-Log "Refresh token saved to $TokenFile"
        } else {
            Write-Log "No refresh_token returned. Response: $($resp | ConvertTo-Json -Depth 2)"
            throw "No refresh token"
        }
    } catch {
        Write-Log "Token exchange failed: $_"
        throw $_
    }
}

function Get-AccessToken {
    param()
    $refresh = $null
    if (Test-Path $TokenFile) {
        $refresh = Read-EncryptedStringFromFile -FilePath $TokenFile
    }
    if (-not $refresh) { Write-Log "No refresh token found; starting interactive auth."; Start-Interactive-Auth; $refresh = Read-EncryptedStringFromFile -FilePath $TokenFile }

    $body = @{ client_id = $ClientId; client_secret = $ClientSecret; refresh_token = $refresh; grant_type = 'refresh_token' }
    try {
        $resp = Invoke-RestMethod -Method Post -Uri 'https://oauth2.googleapis.com/token' -Body $body
        return $resp.access_token
    } catch {
        Write-Log "Access token refresh failed: $_"; throw $_
    }
}

function Ensure-DriveFolder {
    param($accessToken, $folderName)
    # Find folder by name in root (simple approach). If not found, create it.
    $headers = @{ Authorization = "Bearer $accessToken" }
    $q = "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder' and 'root' in parents and trashed = false"
    $uri = "https://www.googleapis.com/drive/v3/files?q=$( [System.Web.HttpUtility]::UrlEncode($q) )&fields=files(id,name)"
    $res = Invoke-RestMethod -Headers $headers -Uri $uri -Method Get
    if ($res.files.Count -gt 0) { return $res.files[0].id }
    # create folder
    $meta = @{ name = $folderName; mimeType = 'application/vnd.google-apps.folder'; parents = @('root') } | ConvertTo-Json
    $create = Invoke-RestMethod -Uri 'https://www.googleapis.com/drive/v3/files' -Headers $headers -Method Post -Body $meta -ContentType 'application/json'
    return $create.id
}

# Cache for folder lookups: key = parentId|folderName -> folderId
$DriveFolderCache = @{}

function Get-OrCreate-DriveFolder {
    param($accessToken, $parentId, $folderName)
    $key = "$parentId|$folderName"
    if ($DriveFolderCache.ContainsKey($key)) { return $DriveFolderCache[$key] }

    $headers = @{ Authorization = "Bearer $accessToken" }
    $q = "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder' and '$parentId' in parents and trashed = false"
    $uri = "https://www.googleapis.com/drive/v3/files?q=$( [System.Web.HttpUtility]::UrlEncode($q) )&fields=files(id,name)"
    try {
        $res = Invoke-RestMethod -Headers $headers -Uri $uri -Method Get -ErrorAction Stop
        if ($res.files.Count -gt 0) { $DriveFolderCache[$key] = $res.files[0].id; return $res.files[0].id }
    } catch {
        # ignore and try to create
    }

    $meta = @{ name = $folderName; mimeType = 'application/vnd.google-apps.folder'; parents = @($parentId) } | ConvertTo-Json
    $create = Invoke-RestMethod -Uri 'https://www.googleapis.com/drive/v3/files' -Headers $headers -Method Post -Body $meta -ContentType 'application/json'
    $DriveFolderCache[$key] = $create.id
    return $create.id
}

function Ensure-DrivePath {
    param($accessToken, $rootId, $relativePath)
    if (-not $relativePath) { return $rootId }
    # Normalize separators and split
    $relativePath = $relativePath -replace '/','\\'
    $parts = $relativePath -split '\\+'
    $current = $rootId
    foreach ($p in $parts) {
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        $current = Get-OrCreate-DriveFolder -accessToken $accessToken -parentId $current -folderName $p
    }
    return $current
}

function Upload-Multipart {
    param($accessToken, $filePath, $parentId)
    $metadata = @{ name = [System.IO.Path]::GetFileName($filePath); parents = @($parentId) } | ConvertTo-Json
    $boundary = "-------PSBoundary$(Get-Random)"
    $headers = @{ Authorization = "Bearer $accessToken"; 'Content-Type' = "multipart/related; boundary=$boundary" }

    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $metaPart = "--$boundary`r`nContent-Type: application/json; charset=UTF-8`r`n`r`n$metadata`r`n"
    $filePartHeader = "--$boundary`r`nContent-Type: application/octet-stream`r`n`r`n"
    $end = "`r`n--$boundary--`r`n"

    $ms = New-Object System.IO.MemoryStream
    $wr = New-Object System.IO.StreamWriter($ms)
    $wr.Write($metaPart); $wr.Flush()
    $ms.Write($fileBytes, 0, $fileBytes.Length)
    $wr = New-Object System.IO.StreamWriter($ms)
    $wr.Write($end); $wr.Flush()
    $ms.Position = 0

    try {
        $resp = Invoke-RestMethod -Uri "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart" -Headers $headers -Method Post -InFile $ms -ContentType "multipart/related; boundary=$boundary"
        Write-Log "Uploaded (multipart): $filePath -> $($resp.id)"
    } catch {
        Write-Log "Multipart upload failed for $filePath: ${_}"
        throw $_
    }
}

function Upload-Resumable {
    param($accessToken, $filePath, $parentId)
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $meta = @{ name = $fileName; parents = @($parentId) } | ConvertTo-Json
    $headers = @{ Authorization = "Bearer $accessToken"; 'X-Upload-Content-Type' = 'application/octet-stream' }
    $initUri = "https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable"
    try {
        $init = Invoke-RestMethod -Uri $initUri -Headers $headers -Method Post -Body $meta -ContentType 'application/json' -SkipHeaderValidation -ErrorAction Stop
    } catch {
        # When using Invoke-RestMethod the Location header isn't directly returned; use Invoke-WebRequest
        $initReq = Invoke-WebRequest -Uri $initUri -Headers $headers -Method Post -Body $meta -ContentType 'application/json' -ErrorAction Stop
        $sessionUri = $initReq.Headers['Location']
        if (-not $sessionUri) { Write-Log "Resumable init failed (no session URI)"; throw "No session URI" }
        # Now upload in one shot (simple implementation)
        $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
        $uploadReq = Invoke-WebRequest -Uri $sessionUri -Method Put -Body $fileBytes -ContentType 'application/octet-stream' -Headers @{ Authorization = "Bearer $accessToken" }
        Write-Log "Uploaded (resumable single-shot): $filePath"
        return
    }
    # If Invoke-RestMethod returned a response object with Location header (rare), attempt to use it
    $sessionUri = $init.Headers['Location']
    if (-not $sessionUri) { Write-Log "No session URI from resumable init"; throw "No session URI" }
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $uploadReq = Invoke-WebRequest -Uri $sessionUri -Method Put -Body $fileBytes -ContentType 'application/octet-stream' -Headers @{ Authorization = "Bearer $accessToken" }
    Write-Log "Uploaded (resumable): $filePath"
}

# Main
try {
    Write-Log "Backup run started. Source: $SourcePath"
    if (-not (Test-Path $SourcePath)) { Write-Log "Source path not found: $SourcePath"; exit 2 }
    $accessToken = Get-AccessToken
    if (-not $accessToken) { Write-Log "Failed to obtain access token"; exit 3 }
    $parentId = Ensure-DriveFolder -accessToken $accessToken -folderName $UploadFolderName

    # Build list of files to upload
    $files = Get-ChildItem -Path $SourcePath -File -Recurse
    foreach ($f in $files) {
        try {
            $full = $f.FullName
            # Compute relative directory inside the source folder
            $rel = $full.Substring($SourcePath.Length).TrimStart('\','/')
            $relDir = [System.IO.Path]::GetDirectoryName($rel)
            if ($relDir) {
                $targetParentId = Ensure-DrivePath -accessToken $accessToken -rootId $parentId -relativePath $relDir
            } else {
                $targetParentId = $parentId
            }

            if ($f.Length -lt $MultipartThresholdBytes) {
                Upload-Multipart -accessToken $accessToken -filePath $full -parentId $targetParentId
            } else {
                Upload-Resumable -accessToken $accessToken -filePath $full -parentId $targetParentId
            }
        } catch {
            Write-Log "Failed to upload $($f.FullName): $_"
        }
    }

    # Log rotation: delete logs older than 7 days
    Get-ChildItem -Path $LogDir -Filter *.log | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Log "Backup run completed."
    exit 0
} catch {
    Write-Log "Unhandled error: $_"
    exit 1
}
