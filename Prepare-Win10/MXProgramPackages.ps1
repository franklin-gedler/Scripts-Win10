function MXProgramPackages {
    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################

    function DownloadFilesInstaller {
        param (
            $1,$2
        )
        $Token = "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"
    
        $Headers = @{
        accept = "application/octet-stream"
        authorization = "Token " + $Token
        }

        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $1 `
                -Headers $Headers -UseBasicParsing -OutFile "C:\PrepareWin10\$2"
    }

    # ----------------------------------------------------------------------------------------------

    $InstallOffice365 = Get-Content C:\Users\admindesp\Desktop\Office365.txt

    if ($InstallOffice365 -eq 1) {

        Write-Output ""
        Write-Output " ========================== "
        Write-Host "    Instalando Office365    " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ========================== "
        Start-Process -Wait C:\PrepareWin10\Office365\setup.exe `
            -ArgumentList '/configure C:\PrepareWin10\Office365\installOfficeBusRet64.xml'

        Write-Output ""
        Write-Output " ############# "
        Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ############# "
        Write-Output ""
        Write-Output "_________________________________________________________________________________________"
        Write-Output "" 
    }
    
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
    
    @'
    mkdir $env:TMP\javadownload > NULL

    $Token = "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"
    
    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/43446413" `
        -Headers $Headers -UseBasicParsing -OutFile $env:TMP\javadownload\jre-8u301-windows-i586.exe

    Start-Process -Wait -FilePath $env:TMP\javadownload\jre-8u301-windows-i586.exe -ArgumentList '/s'
'@ > NULL  # Se puede Borrar despues de varias pruebas

    $URLinstaller = 'https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/43446413'
    $NameInstaller = 'jre-8u301-windows-i586.exe'

    DownloadFilesInstaller $URLinstaller $NameInstaller

    Start-Process -Wait -FilePath C:\PrepareWin10\$NameInstaller -ArgumentList '/s'

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
    
    $URLinstaller = 'https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/43715114'
    $NameInstaller = 'E84.71_CheckPointVPN.msi'

    DownloadFilesInstaller $URLinstaller $NameInstaller

    Start-Process -Wait msiexec -ArgumentList "/i C:\PrepareWin10\$NameInstaller /quiet /norestart"

    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""  

    Write-Output ""
    Write-Output " =========================== "
    Write-Host "    Instalando EBS Oracle    " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =========================== "

    $URL = 'https://www.talkingbyte.com/download.php?product_id=ThinForms_JavaHost_installer.zip'

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URL -UseBasicParsing -OutFile 'C:\PrepareWin10\ThinForms_JavaHost_installer.zip'

    Expand-Archive C:\PrepareWin10\ThinForms_JavaHost_installer.zip C:\PrepareWin10\ThinForms_JavaHost_installer\ -Force

    @'
    install_path=C:\\Program Files\\ThinApplet\\JavaHostPlugin
    reg_name=Despegar SA
    reg_key=5007-cb9b-8114-fba7
    all_users=true
'@ | Add-Content C:\PrepareWin10\ThinForms_JavaHost_installer\key.properties

    $fileinstaller = (Get-ChildItem C:\PrepareWin10\ThinForms_JavaHost_installer).Name | Select-String ".exe"

    Start-Process -Wait C:\PrepareWin10\ThinForms_JavaHost_installer\$fileinstaller

    New-Item -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist' -Force > NULL
    
    New-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist' `
        -Name '1' -Value 'nmjefghbgfcpoobigfbalocpncklkjhk;https://clients2.google.com/service/update2/crx' > NULL

    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    function Avaya {
        Write-Output " ================================ "
        Write-Host "   Moviendo Avaya al Escritorio  " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ================================ "
    
        if (!(Test-Path $env:USERPROFILE\Desktop\Extras)){
            New-Item -Path $env:USERPROFILE\Desktop\ -Name "Extras" -ItemType Directory
        }
    
        Copy-Item -LiteralPath C:\PrepareWin10\Install-Avaya.zip -Destination $env:USERPROFILE\Desktop\Extras -Force
    
        Write-Output ""
        Write-Output " ######### "
        Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ######### "
        Write-Output ""
        Write-Output "_________________________________________________________________________________________"
        Write-Output "" 
    }
}