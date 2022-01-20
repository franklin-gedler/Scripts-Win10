$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $currentdirectory
(Get-Location).Path
#############################################################################################

Function creadopor {
    Write-Output " _____________________________________________________________________________________________________"

    Write-Output ""
    Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
    Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
    Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
    Write-Output ""

    Write-Output " _____________________________________________________________________________________________________"

}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
creadopor

# __________________Descargas para Usuarios de Sucursal son todos los Files_____________________ #

function listsSucursal {

    $Global:listurl = @(
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596410",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596446",
    #"https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30567056",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/50761955",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30761673",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596372",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596376",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596403",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596441",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596378"
    )
    
    $Global:listfiles = @(
    "Downloads\Pre.zip",
    "Downloads\TsapiClient.zip",
    "Downloads\AvayaOneX.zip",
    "Downloads\CertificadoSSL.zip",
    "Downloads\ClickToDial.zip",
    "Downloads\CTI.zip",
    "Downloads\GlobalProtect.zip",
    "Downloads\ScreenPop.zip",
    "Downloads\DisableOREnable.zip"
    )

    $Global:listfolder = @(
    "Downloads\Pre",
    "Downloads\TsapiClient",
    "Downloads\AvayaOneX",
    "Downloads\CertificadoSSL",
    "Downloads\ClickToDial",
    "Downloads\CTI",
    "Downloads\GlobalProtect",
    "Downloads\ScreenPop",
    "Downloads\DisableOREnable" 
    )
}

function DownloadMotor {

    param(
        $1,$2,$3
    )
    
    $Token = "Token Generado por Github"
    
    $Headers = @{
    accept = "apoctstream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $1 -Headers $Headers -UseBasicParsing -OutFile $currentdirectory\$2
    $ProgressPreference = 'Continue'
    Expand-Archive $2 -DestinationPath $3 -Force

    # Verificacion de Descarga
    
    $NameFolder = Write-Output $3 | ForEach-Object{ $_.Split('\')[1]; }
    $NameFolder2 = (Get-ChildItem -Path Downloads -Force -Filter $NameFolder).Name

    if ( $NameFolder -eq $NameFolder2 ){
        
        Write-Host " $NameFolder Descarga OK " -ForegroundColor Green -BackgroundColor Black
        Write-Output ""

    }else{
        
        Write-Host " $NameFolder Descarga Fallo " -ForegroundColor Red -BackgroundColor Black
        Write-Output ""
    }
}

function DownloadUserSucursal {
    
    Write-Output ""
    Write-Output " ---------------------------------------------------------------- "
    Write-Host "  Descargando todos los Files necesarios, por favor Espere . . .  " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ---------------------------------------------------------------- "
    Write-Output ""

    listsSucursal
    for ($i = 0; $i -le 8; $i++){
        DownloadMotor $listurl[$i] $listfiles[$i] $listfolder[$i]
        
    }
}

# _________Descargas para Usuarios de Despegar son todos menos GlobalProtec y Screenpop__________ #

function listsDespegar {

    $Global:listurl = @(
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596410",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596446",
    #"https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30567056",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/50761955",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30761673",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596372",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596376",
    "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596378"
    )
    
    $Global:listfiles = @(
    "Downloads\Pre.zip",
    "Downloads\TsapiClient.zip",
    "Downloads\AvayaOneX.zip",
    "Downloads\CertificadoSSL.zip",
    "Downloads\ClickToDial.zip",
    "Downloads\CTI.zip",
    "Downloads\DisableOREnable.zip"
    )

    $Global:listfolder = @(
    "Downloads\Pre",
    "Downloads\TsapiClient",
    "Downloads\AvayaOneX",
    "Downloads\CertificadoSSL",
    "Downloads\ClickToDial",
    "Downloads\CTI",
    "Downloads\DisableOREnable" 
    )
}

function DownloadUserDespegar {
    
    Write-Output ""
    Write-Output " ---------------------------------------------------------------- "
    Write-Host "  Descargando todos los Files necesarios, por favor Espere . . .  " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ---------------------------------------------------------------- "
    Write-Output ""

    listsDespegar
    for ($i = 0; $i -le 6; $i++){
        DownloadMotor $listurl[$i] $listfiles[$i] $listfolder[$i]
        
    }
}

# _______________________________________________________________________________________________ #
Function extyagent {
    Write-Output ""
    Write-Output " ------------------------------------"
    Write-Host "   Ingrese Numero de Extension . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ------------------------------------"
    Write-Output ""
    $Global:interno = Read-Host
    $Global:interno = $interno.replace(' ' , '')

    Write-Output ""
    Write-Output " ------------------------------------"
    Write-Host "     Ingrese Numero de Agente . . .  " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ------------------------------------"
    Write-Output ""
    $Global:agente = Read-Host
    $Global:agente = $agente.Replace(' ' , '')

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function netframework {
    Stop-Service wuauserv -Force -PassThru
    Rename-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -NewName "WindowsUpdateold"
    Set-Service wuauserv -StartupType Manual -PassThru
    Start-Service wuauserv -PassThru

    Write-Output ""
    Write-Output " ======================================"
    Write-Host "   Installing Net Framework Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ======================================"
    Write-Output ""

    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart

    # Verificar que se instalo los net framework:
    # Get-WindowsOptionalFeature -Online -FeatureName "NetFX4"
    # Get-WindowsOptionalFeature -Online -FeatureName "NetFX3"

    # Deshabilitar framework 3.5
    # Disable-WindowsOptionalFeature -Online -FeatureName "NetFx3"

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function PreInstall {
    Write-Output ""
    Write-Output " =============================================="
    Write-Host "   Installing Microsoft Silverlight Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =============================================="
    Write-Output ""

    Start-Process -Wait -FilePath Downloads\Pre\Silverlight_x64.exe -ArgumentList "/q"

    Write-Output ""
    Write-Output " ========================================================================"
    Write-Host "   Installing Microsoft Visual C++ 2017 Redistributable (x64) Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ========================================================================"
    Write-Output ""

    Start-Process -Wait -FilePath Downloads\Pre\VC_redist.x64.exe -ArgumentList "/install /quiet /norestart"

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function tsapi {
    Write-Output ""
    Write-Output " ====================================="
    Write-Host "   Installing Tsapi-Client Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ====================================="
    Write-Output ""

    Start-Process -Wait -FilePath Downloads\TsapiClient\setup.exe -ArgumentList "/s /f1$currentdirectory\Downloads\TsapiClient\setup.iss"

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function avaya {
    Write-Output ""
    Write-Output " ===================================="
    Write-Host "   Installing Avaya One X Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================================="
    Write-Output ""

    #Start-Process -Wait -FilePath Downloads\AvayaOneX\OnexAgentSetup\application\OneXAgentSetup.exe -ArgumentList "/qn"
    Start-Process -Wait -FilePath Downloads\AvayaOneX\OneXAgentSetup.exe -ArgumentList "/qn"
    Start-Process -Wait regedit.exe -ArgumentList "/s Downloads\AvayaOneX\DisableMuteButton.reg"

    Start-Process -FilePath 'C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentUI.exe'
    Start-Sleep -Seconds 10

    Stop-Process -Name OneXAgentUI -Force

    # Seteo extension
    $Filein = "$currentdirectory\Downloads\AvayaOneX\Settings.xml"
    $Fileout = "$env:appdata\Avaya\one-X Agent\2.5\Profiles\default\Settings.xml"
    $Content = [System.IO.File]::ReadAllText("$Filein")
    $Content = $Content.Replace('1111111', "$interno")
    $Content = $Content.Trim()
    [System.IO.File]::WriteAllText("$Fileout", $Content)

    # Seteo Agente
    $Content = [System.IO.File]::ReadAllText("$Fileout")
    $Content = $Content.Replace('2222222', "$agente")
    $Content = $Content.Trim()
    [System.IO.File]::WriteAllText("$Fileout", $Content)

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function certificados {
    Write-Output ""
    Write-Output " ===================================="
    Write-Host "    Config. Certificate Wait . . .   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================================="
    Write-Output ""

    $huella = (New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "127.0.0.1" -FriendlyName "MySiteCert" -NotAfter (Get-Date).AddYears(10)).Thumbprint
    $cert = (Get-ChildItem -Path cert:\LocalMachine\My\$huella)
    Export-Certificate -Cert $cert -FilePath $currentdirectory\Downloads\CertificadoSSL\avaya.cer -Force
    $cert = (Get-ChildItem -Path $currentdirectory\Downloads\CertificadoSSL\avaya.cer)
    $cert | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root

    Copy-Item Downloads\CertificadoSSL\OneXAgentAPIConfig.bat 'C:\Program Files (x86)\Avaya\Avaya one-X Agent' -Force

    #Start-Process -Wait cmd.exe -ArgumentList "C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentAPIConfig.bat 60001 1 $huella"

    Start-Process 'C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentAPIConfig.bat' -ArgumentList "60001 1 $huella"

    Start-Sleep -Seconds 5

    Start-Process regedit.exe -ArgumentList "/s $currentdirectory\Downloads\CertificadoSSL\registro_ssl.reg"

    Remove-Item $currentdirectory\Downloads\CertificadoSSL\avaya.cer -Force

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function nginx {
    Write-Output ""
    Write-Output " ======================================"
    Write-Host "   Installing Click to Dial Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ======================================"
    Write-Output ""

    Copy-Item Downloads\ClickToDial\* C:\ -Force -Recurse

    #Start-Process C:\Nginx-1.17.8\start.bat
    #Start-Sleep -s 10
    #Start-Process C:\Nginx-1.17.8\stop.bat
    #Start-Process -Wait C:\nssm-2.24\createservice.bat
    #Start-Process -Wait C:\sslCert\sslCert.bat

    Start-Process -Wait cmd.exe -ArgumentList '/c start C:\nssm-2.24\win64\nssm.exe install nginx C:\Nginx-1.17.8\nginx.exe'

    Start-Process -Wait cmd.exe -ArgumentList '/c certutil -enterprise -f -v -AddStore "Root" "C:\nginx-1.17.8\conf\nginx-certificate.pem"'

    Restart-Service nginx -PassThru

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function cti {
    Write-Output ""
    Write-Output " ===================="
    Write-Host "   Config. CTI . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================="
    Write-Output ""

    Remove-Item -Path "C:\CTI.ini" -Force -ErrorAction SilentlyContinue

    $File = "Downloads\CTI\CTI.ini"
    $Content = [System.IO.File]::ReadAllText("$currentdirectory\$File")
    $Content = $Content.Replace('7XXXXXX', "$interno")
    $Content = $Content.Trim()
    [System.IO.File]::WriteAllText("C:\CTI.ini", $Content)
    
    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function globalprotect {
    Write-Output ""
    Write-Output " ======================================="
    Write-Host "   Installing Global Protect Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ======================================="
    Write-Output ""

    Start-Process -Wait msiexec -ArgumentList '/i Downloads\GlobalProtect\GlobalProtect64.msi /quiet Portal="170.80.97.6"'

    # Este bloque se debe verificar ya que es el certificado de Global Protec
    $cert = (Get-ChildItem -Path $currentdirectory\Downloads\GlobalProtect\GP.cer)
    $cert | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function screenpop {
    Write-Output ""
    Write-Output " ===================================="
    Write-Host "   Installing ScreenPop Wait . . .   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================================="
    Write-Output ""

    #& rundll32.exe dfshim.dll, ShOpenVerbApplication https://despegar.teleperformance.co/spop/Install/TPSPOPDespegar.application

    #Start-Process -Wait rundll32.exe -ArgumentList "dfshim.dll,ShOpenVerbApplication https://despegar.teleperformance.co/spop/Install/TPSPOPDespegar.application"

    Start-Process Downloads\ScreenPop\install.vbs

    #Start-Process -FilePath .\Downloads\ScreenPop\TPSPOPDespegar.application
}

# _______________________________________________________________________________________________ #

Function disableall {
    
    Start-Process -Wait -FilePath Downloads\DisableOREnable\Stop.bat
}
Function enableall {
    
    Start-Process -Wait -FilePath Downloads\DisableOREnable\Start.bat
}

function AutoDeleteNow {
    Remove-Item $currentdirectory\ProcessUpdateLatest.ps1 -Force
}

# _______________________________________________________________________________________________ #

Function DownloadPS {

    $Token = "Token Generado Desde Gitgub"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596420"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\PS.zip
    Expand-Archive Downloads\PS.zip -DestinationPath Downloads\ -Force
}
Function credencials {
    $Global:cred = Get-Credential Pais\Nombre.Apellido -Message "Ingresar Credenciales, Ejemplo AR\Fulano.Perencejo"

    Write-Output " ============================================== "
    Write-Host "       Validando credenciales ingresadas        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================================== "
    DownloadPS
    Copy-Item -LiteralPath Downloads\PS\ -Destination C:\ -Recurse -Force
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue

    $Very = Get-ADDomain -Server 'domain' -Credential $cred -ErrorAction SilentlyContinue

    while(!$Very){

        Write-Output ""
        Write-Output " ########################################################## "
        Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ########################################################## "
        Write-Output ""

        $Global:cred = Get-Credential Domain\Nombre.Apellido -Message "Ingresar Credenciales, Ejemplo domain\Fulano.Perencejo"
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
        $Very = Get-ADDomain -Server 'domain' -Credential $cred -ErrorAction SilentlyContinue
    }

    Write-Output ""
    Write-Output " ##############################################################"
    Write-Host "              Credenciales OK Alegria Alegria                    " -ForegroundColor Green -BackgroundColor Black
    Write-Host "   Credenciales Validadas con el Dominio: $Very " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############################################################## "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}
function moveou {
    param (
        [String]$1,[String]$2
    )
        #credencials
        $Computer = hostname

        # ___________________________________________________________________________________________________________________________________________"
        
        $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server "Domain.com" -Credential $cred).objectGUID).Guid
        while (!$Identity){
            $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server "Domain.com" -Credential $cred).objectGUID).Guid
        }
        Write-Output ""
        Write-Host   "   El ID del equipo es: $Identity" -ForegroundColor Yellow -BackgroundColor Black
        Write-Output ""
        
        # ___________________________________________________________________________________________________________________________________________"

        $currentou = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server "Domain.com" -Credential $cred).DistinguishedName
      
        while (!$currentou){
            $currentou = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server "Domain.com" -Credential $cred).DistinguishedName
        }
        Write-Output ""
        Write-Host   "   OU Actuales del equipo: $currentou" -ForegroundColor Yellow -BackgroundColor Black
        Write-Output ""
        
        # ___________________________________________________________________________________________________________________________________________"

        Write-Output ""
        Write-Host   "   Moviendo equipo, Espere . . ." -ForegroundColor Yellow -BackgroundColor Black
        Write-Output ""

        Move-ADObject -Identity "$Identity" -TargetPath "$2" -Credential $cred
        while ($? -eq $false){
            Move-ADObject -Identity "$Identity" -TargetPath "$2" -Credential $cred
        }
        Start-Sleep -Seconds 10 
        
        Write-Host   "   Listo. " -ForegroundColor Green -BackgroundColor Black
        Write-Output ""

        # ___________________________________________________________________________________________________________________________________________"

        $Confirm = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server "Domain.com" -Credential $cred).DistinguishedName
        while (!$Confirm){
            $Confirm = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server "Domain.com" -Credential $cred).DistinguishedName
        }
        Write-Output ""        
        Write-Host   "   Nueva OU del equipo: $Confirm" -ForegroundColor Yellow -BackgroundColor Black
        Write-Output ""

        # ___________________________________________________________________________________________________________________________________________"

        Pause
}
Function moverdeou {
    
    # AR Sucursales GUID {479502b9-d1d8-4bb9-b72c-76b0b2c4fe47}
    # UY PCI GUID {51559502-9b54-49b9-8473-eff00e9267ec}
    # Cl Sucursales {69be72ec-f3fd-4c3a-bb75-8ccb81bd002b}
    # CO PCI {ab67334e-1f0f-48bf-8eef-9287ca32a427}
    <#
    
    
    Write-Output ""
    showmenupais
    Write-Output ""

    while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "5"){
    
        switch($inp){
            1{
                
                moveou "ar" "479502b9-d1d8-4bb9-b72c-76b0b2c4fe47"
                
            }
            2{

                moveou "uy" "51559502-9b54-49b9-8473-eff00e9267ec"

            }
            3{

                moveou "cl" "69be72ec-f3fd-4c3a-bb75-8ccb81bd002b"

            }
            4{

                moveou "co" "ab67334e-1f0f-48bf-8eef-9287ca32a427"
                
            }
            5{"Exit"; break}
            default {Write-Host -ForegroundColor red -BackgroundColor white "Opcion Invalida, por favor seleccion una de las disponibles"}
        }

    Write-Output ""
    showmenupais
    Write-Output ""
    } 
    #>

    credencials
    $Global:DomainPC = (Get-ADDomain -Credential $cred).Name

    switch ($DomainPC) {
        ar {  
            moveou "ar" "479502b9-d1d8-4bb9-b72c-76b0b2c4fe47"
        }
        uy {  
            moveou "uy" "51559502-9b54-49b9-8473-eff00e9267ec"
        }
        cl {  
            moveou "cl" "69be72ec-f3fd-4c3a-bb75-8ccb81bd002b"
        }
        co {  
            moveou "co" "ab67334e-1f0f-48bf-8eef-9287ca32a427"
        }
    }
}

# _______________________________________________________________________________________________ #

<#
Function showmenupais {

    Write-Output ""
    Write-Host " **** De que pais es la maquina **** "
    Write-Host ""
    Write-Host "                1. AR                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                2. UY                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                3. CL                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                4. CO                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                5. Exit              " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " *********************************** "
    Write-Output ""

}
#>
Function showmenumain {
    #Clear-Host
    Write-Output ""
    Write-Host " ********************** "
    Write-Host "  1. Usuario Interno   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "  2. Usuario Externo  " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "  3. Reparar (No Usar)  " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "  4. Mover Equipo OU    " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "  5. Exit               " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " ********************** "
    Write-Output ""
}

# _______________________________________________________________________________________________ #
Function uninstallavaya {
    $Programa = Get-WmiObject -Class Win32_Product -Filter "Name = 'Avaya one-X Agent - 2.5.13'"
    $Programa.Uninstall()
    Remove-Item -Force $env:appdata\Avaya -Recurse
}

Function showmenurepair {
    Write-Output ""
    Write-Output " ************************************ "
    Write-Output "  1. Reinstalar Solo Avaya (Sin Pre) "
    
    Write-Output ""

}

# _______________________________________________________________________________________________ #

Write-Output ""
showmenumain

while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "5"){

switch($inp){
    
        1 {
            #Clear-Host
            Write-Output ""
            Write-Host "------------------------------"
            Write-Host " Ejecuto Script para usuario Interno " 
            Write-Host "------------------------------"
            Write-Output ""

            extyagent
            DownloadUserDespegar
            disableall
            netframework
            PreInstall
            tsapi
            avaya
            certificados
            nginx
            cti
            enableall
            AutoDeleteNow
            Pause
            #break
            $Result = [System.Environment]::Exitcode
            [System.Environment]::Exit($Result)
        }
        2 {
            #Clear-Host
            Write-Output ""
            Write-Host "------------------------------"
            Write-Host " Ejecuto Script para usuario Sucursal "
            Write-Host "------------------------------"
            Write-Output ""
            
            extyagent
            DownloadUserSucursal
            disableall
            netframework
            PreInstall
            tsapi
            avaya
            certificados
            nginx
            cti
            globalprotect
            screenpop
            enableall
            AutoDeleteNow
            Pause
            #break
            $Result = [System.Environment]::Exitcode
            [System.Environment]::Exit($Result)
        }
        3 {
            Write-Output ""
            Write-Output " NO USAR (No te Dije Pelotudo)  "
            Write-Output ""
            Start-Sleep -Seconds 5
            AutoDeleteNow
            $Result = [System.Environment]::Exitcode
            [System.Environment]::Exit($Result)
            #break
        }
        4 { 
            moverdeou
            AutoDeleteNow
            $Result = [System.Environment]::Exitcode
            [System.Environment]::Exit($Result)
            #break
        }
        5 {"Exit"; break}
        default {Write-Host -ForegroundColor red -BackgroundColor white "Opcion Invalida, por favor seleccion una de las disponibles"}
        
    }
Write-Output ""
showmenumain
}
[System.Environment]::Exit($Result)
