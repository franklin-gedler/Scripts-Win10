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
    $StatusDriversBasic = (Get-PnpDevice -Status ERROR).Status 2> NULL
    
    while ($StatusDriversBasic) {
        Start-Sleep -Seconds 5
        $StatusDriversBasic = (Get-PnpDevice -Status ERROR).Status 2> NULL
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