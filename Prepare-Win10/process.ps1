#echo " Finalizando la configuracion del entorno . . ."
#Start-Sleep -Seconds 180
#Pause
# _________________________ Deshabilito Windows Update Poronga ____________________________
Stop-Service wuauserv -Force
Set-Service wuauserv -StartupType Disabled

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

$token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
$headers = @{Authorization = "token $($token)"}
Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ProcessUpdateRegional.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\ProcessUpdateRegional.ps1"

#& .\ProcessUpdate.ps1

#Start-Process -Wait PowerShell.exe -ArgumentList "C:\Windows\setup\scripts\ProcessUpdateRegional.ps1"

#Remove-Item ProcessUpdate.ps1

& $PSScriptRoot\ProcessUpdateRegional.ps1