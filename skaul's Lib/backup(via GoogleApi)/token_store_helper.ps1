<# token_store_helper.ps1
Helpers to save/read small secrets (refresh_token, client_secret) securely using DPAPI via ConvertFrom-SecureString.
Note: Data encrypted this way can only be decrypted by the same Windows user account.
#>

function Save-EncryptedStringToFile {
    param(
        [Parameter(Mandatory=$true)] [string] $PlainText,
        [Parameter(Mandatory=$true)] [string] $FilePath
    )
    $ss = ConvertTo-SecureString $PlainText -AsPlainText -Force
    $enc = $ss | ConvertFrom-SecureString
    $enc | Out-File -FilePath $FilePath -Encoding ASCII
}

function Read-EncryptedStringFromFile {
    param(
        [Parameter(Mandatory=$true)] [string] $FilePath
    )
    if (-not (Test-Path $FilePath)) { return $null }
    $enc = Get-Content $FilePath -Raw
    try {
        $ss = $enc | ConvertTo-SecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss)
        $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        return $plain
    } catch {
        Write-Error "Failed to decrypt token file: $_"
        return $null
    }
}
