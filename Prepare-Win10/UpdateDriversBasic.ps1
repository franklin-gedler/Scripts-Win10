function UpdateDriversBasic {

    . C:\PrepareWin10\PowerAdapterStatus.ps1
    PowerAdapterStatus # valido si el cargador esta conectado

    Write-Output ""
    Write-Output " ================================================  "
    Write-Host "             Updating Drivers Basic                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " Esto puede tardar un poco, por favor Espere . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================================= "
    Write-Output ""

    #Set-Service wuauserv -StartupType Manual -InformationAction SilentlyContinue
    #Start-Service wuauserv -InformationAction SilentlyContinue
    Get-PnpDevice -Status ERROR 2> NULL
    $StatusDriversBasic = $?

    while ($StatusDriversBasic -eq "True") {
        Start-Sleep -Seconds 20
        Get-PnpDevice -Status ERROR 2> NULL
        $StatusDriversBasic = $?
    }

    Write-Output "Sali del While, verifica si estan todos los driver instalados"
    Pause

    <#
    Install-PackageProvider NuGet -Force > NULL
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module PSWindowsUpdate -Confirm:$False -Force
    Import-Module PSWindowsUpdate
    Pause

    Set-Service wuauserv -StartupType Manual -InformationAction SilentlyContinue
    Start-Service wuauserv -InformationAction SilentlyContinue

    Install-WindowsUpdate -Confirm:$False -AutoReboot
    #Install-WindowsUpdate -AcceptAll
    #>
    
    
}