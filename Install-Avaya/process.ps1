$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $currentdirectory
#(Get-Location).Path
#######################################################################################################################

# Descargar desde Github 
$token = "Token Generado desde Gitgub"
$headers = @{Authorization = "token $($token)"}
Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Install-Avaya/ProcessUpdateLatest.ps1" -UseBasicParsing -OutFile "$currentdirectory\ProcessUpdateLatest.ps1"

Start-Process -Wait PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "ProcessUpdateLatest.ps1"'

Remove-Item ProcessUpdateLatest.ps1
