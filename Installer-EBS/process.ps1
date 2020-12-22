#mkdir $env:TEMP\EBS
#cd $env:TEMP\Install-EBS
$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $currentdirectory
(Get-Location).Path
Add-MpPreference -ExclusionPath "$currentdirectory"

#######################################################################################################
Write-Output ""
Write-Output ""
# --------------- Instalacion JAVA ---------------------
Write-Output " ==========================="
Write-Host " Installing Java Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ==========================="
Start-Process -Wait -FilePath java.exe -ArgumentList '/s'
Write-Host " OK " -ForegroundColor Green -BackgroundColor Black
Write-Output ""
Write-Output ""
Write-Output " ================================="
Write-Host " Config. Java for EBS, Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ================================="
Expand-Archive Sun.zip $env:USERPROFILE\AppData\LocalLow\ -Force
Write-Host " OK " -ForegroundColor Green -BackgroundColor Black
Write-Output ""
Write-Output ""

# ---------------------- Instalacion Firefox ------------------------------
Write-Output " ========================================"
Write-Host " Installing Firefox for EBS-ORACLE . . . " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ========================================" 
Start-Process -FilePath firefox.exe -ArgumentList '-ms -ma' -Wait
Stop-Service MozillaMaintenance -Force -PassThru
Set-Service MozillaMaintenance -StartupType Disabled -PassThru
Start-Process -Wait -FilePath 'C:\Program Files (x86)\Mozilla Maintenance Service\Uninstall.exe' -ArgumentList '/S'
Remove-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\application.ini' -Force
Remove-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\maintenanceservice.exe' -Force
Remove-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\maintenanceservice_installer.exe' -Force
Remove-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\platform.ini' -Force
Remove-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\updater.exe' -Force
Remove-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\updater.ini' -Force
Remove-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\update-settings.ini' -Force
New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\Desktop\ -Name EBS-ORACLE -Value "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
Start-Process -FilePath $env:USERPROFILE\Desktop\EBS-ORACLE
Start-Sleep -Seconds 1
Stop-Process -Name firefox -Force
Expand-Archive EBS.zip -DestinationPath EBS\ -Force
$dir1 = (Get-ChildItem $env:USERPROFILE\AppData\Local\Mozilla\Firefox\Profiles\).Name
Copy-Item EBS\First\* $env:USERPROFILE\AppData\Local\Mozilla\Firefox\Profiles\$dir1 -Force -Recurse
Copy-Item -Path EBS\Second\* -Destination $env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\ -Force -Recurse
Start-Process -FilePath $env:USERPROFILE\Desktop\EBS-ORACLE
Write-Output " ==================================="
Write-Host " Finishing Installation, Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ===================================" 
Start-Sleep -Seconds 35
Remove-Item $env:USERPROFILE\AppData\Local\Mozilla\updates -Force -Recurse
Remove-Item 'C:\users\public\Desktop\Mozilla Firefox.lnk' -Force