$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $currentdirectory
#(Get-Location).Path
#######################################################################################################################

# Descargar desde Github 
$token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
$headers = @{Authorization = "token $($token)"}
Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Install-Avaya/ProcessUpdatelatestV2.ps1" -UseBasicParsing -OutFile "$currentdirectory\ProcessUpdatelatestV2.ps1"

#& .\ProcessUpdate.ps1

#Start-Process -Wait PowerShell.exe -ArgumentList "& .\ProcessUpdatelatestV2.ps1"

Start-Process -Wait PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "ProcessUpdatelatestV2.ps1"'

Remove-Item ProcessUpdatelatestV2.ps1

#Pause