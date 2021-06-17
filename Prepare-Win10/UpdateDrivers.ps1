function UpdateDrivers {

    . C:\PrepareWin10\PowerAdapterStatus.ps1
    PowerAdapterStatus # valido si el cargador esta conectado

    Write-Output ""
    Write-Output " ===================  "
    Write-Host "   Updating Drivers   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================== "
    Write-Output ""
    
    Install-PackageProvider NuGet -Force > NULL
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module PSWindowsUpdate -Confirm:$False -Force
    Import-Module PSWindowsUpdate
    Pause

    Set-Service wuauserv -StartupType Manual -InformationAction SilentlyContinue
    Start-Service wuauserv -InformationAction SilentlyContinue

    Install-WindowsUpdate -Confirm:$False -AutoReboot
    #Install-WindowsUpdate -AcceptAll
    Pause
}