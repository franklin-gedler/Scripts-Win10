$CI = $(Test-Connection google.com -Count 2 -Quiet -ErrorAction SilentlyContinue)
while("$CI" -eq 'False'){
    Write-Output ""
    Write-Output " ###################################### "
    Write-Host "        Conectate a Internet . . .      " -ForegroundColor Red -BackgroundColor Black
    Write-Output " ###################################### "
    Pause
    $CI = $(Test-Connection google.com -Count 2 -Quiet -ErrorAction SilentlyContinue)
    Write-Output ""
}
function DownloadModules {
    param (
        $1
    )
    $token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    $headers = @{Authorization = "token $($token)"}
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $headers `
        -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/LimpiezaAD/$1.ps1" `
        -UseBasicParsing -OutFile "$PSScriptRoot\$1.ps1"
}

DownloadModules ProcessUpdate

. $PSScriptRoot\ProcessUpdate.ps1

Remove-Item $PSScriptRoot\ProcessUpdate.ps1 -Force
Remove-Item $PSScriptRoot\Firma.ps1 -Force

Pause