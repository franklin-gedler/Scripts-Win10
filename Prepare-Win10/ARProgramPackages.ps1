function ARProgramPackages {
    

    Write-Output ""
    Write-Output " ================================= "
    Write-Host "    Instalando FusionInventory     " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================= "
    #Set-Location $PSScriptRoot
    #& "C:\PrepareWin10\fusioninventory-agent-deployment.vbs"
    Start-Process -Wait -FilePath C:\PrepareWin10\fusioninventory-agent-deployment.vbs
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 

    Write-Output " =================== "
    Write-Host "   Instalando 7Zip   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath C:\PrepareWin10\7z1900-x64.exe -ArgumentList '/S'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    Write-Output " ============================= "
    Write-Host "   Instalando Acrobat Reader   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================= "
    #Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath C:\PrepareWin10\AcroRdrDC1902120049_es_ES.exe -ArgumentList '/sAll'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 

    Write-Output " =================== "
    Write-Host "   Instalando Java   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =================== "
    #Set-Location $PSScriptRoot
    #Start-Process -Wait -FilePath C:\PrepareWin10\java.exe -ArgumentList '/s'
    mkdir $env:TMP\javadownload > NULL

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://api.github.com/repos/franklin-gedler/Only-Download-Prepare-Windows10/releases/assets/36871675" `
                    -Headers $Headers -UseBasicParsing -OutFile $env:TMP\javadownload\jre-8u291-windows-i586.exe

    Start-Process -Wait -FilePath $env:TMP\javadownload\jre-8u291-windows-i586.exe -ArgumentList '/s'

    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    Write-Output " ============================ "
    Write-Host "   Instalando Google Chrome   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================ "
    #Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath C:\PrepareWin10\ChromeStandaloneSetup64.exe -ArgumentList '/silent /install'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    Write-Output " =========================================== "
    Write-Host "   Instalando TeamViewerHost con Politicas   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =========================================== "
    #Set-Location $PSScriptRoot
    Start-Process msiexec -ArgumentList '/i "C:\PrepareWin10\TeamViewer_Host.msi" /qn SETTINGSFILE="C:\PrepareWin10\politicas.reg"' -Wait
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    Write-Output " =================== "
    Write-Host "   Instalando Zoom   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait msiexec -ArgumentList '/i "C:\PrepareWin10\ZoomInstallerFull.msi" ZoomAutoUpdate=true /qn'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    Write-Output " ==================================== "
    Write-Host "   Instalando Google Rapid Response   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================================== "
    Start-Process -Wait -FilePath C:\PrepareWin10\GRR_3.4.2.4_amd64.exe
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    Write-Output " =========================== "
    Write-Host "   Instalando VPN Regional   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =========================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait msiexec -ArgumentList '/i "C:\PrepareWin10\E84.00_CheckPointVPN.msi" /quiet /norestart'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""  

}