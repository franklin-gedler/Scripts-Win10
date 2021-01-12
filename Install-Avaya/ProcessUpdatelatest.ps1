$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
cd $currentdirectory
(pwd).Path
#############################################################################################

Function creadopor {
    Write-Output " _____________________________________________________________________________________________________"

    Write-Output ""
    Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
    Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
    Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
    Write-Host "                                         Updates Franklin Diaz                                        " -ForegroundColor green -BackgroundColor Black
    Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
    Write-Output ""

    Write-Output " _____________________________________________________________________________________________________"

}

creadopor

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

    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All

    # Verificar que se instalo los net framework:
    # Get-WindowsOptionalFeature -Online -FeatureName "NetFX4"
    # Get-WindowsOptionalFeature -Online -FeatureName "NetFX3"

    # Deshabilitar framework 3.5
    # Disable-WindowsOptionalFeature -Online -FeatureName "NetFx3"

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

function DownloadPre {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596410"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\Pre.zip
    Expand-Archive Downloads\Pre.zip -DestinationPath Downloads\Pre\ -Force
}
Function PreInstall {
    Write-Output ""
    Write-Output " =============================================="
    Write-Host "   Installing Microsoft Silverlight Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =============================================="
    Write-Output ""

    DownloadPre

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

function DownloadTsapi {
    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596446"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\TsapiClient.zip
    Expand-Archive Downloads\TsapiClient.zip -DestinationPath Downloads\TsapiClient\ -Force
}
Function tsapi {
    Write-Output ""
    Write-Output " ====================================="
    Write-Host "   Installing Tsapi-Client Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ====================================="
    Write-Output ""

    DownloadTsapi
    Start-Process -Wait -FilePath TsapiClient\setup.exe -ArgumentList "/s /f1$currentdirectory\Downloads\TsapiClient\setup.iss"

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #

Function DownloadAvaya {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30567056"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\AvayaOneX.zip
    Expand-Archive Downloads\AvayaOneX.zip -DestinationPath Downloads\AvayaOneX\ -Force
}

Function avaya {
    Write-Output ""
    Write-Output " ===================================="
    Write-Host "   Installing Avaya One X Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================================="
    Write-Output ""

    DownloadAvaya

    Start-Process -Wait -FilePath Downloads\AvayaOneX\OnexAgentSetup\application\OneXAgentSetup.exe -ArgumentList "/qn"
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
Function DownloadCertificados {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596347"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\CertificadoSSL.zip
    Expand-Archive Downloads\CertificadoSSL.zip -DestinationPath Downloads\CertificadoSSL\ -Force
}

Function certificados {
    Write-Output ""
    Write-Output " ===================================="
    Write-Host "    Config. Certificate Wait . . .   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================================="
    Write-Output ""

    DownloadCertificados

    $huella = (New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "127.0.0.1" -FriendlyName "MySiteCert" -NotAfter (Get-Date).AddYears(10)).Thumbprint
    $cert = (Get-ChildItem -Path cert:\LocalMachine\My\$huella)
    Export-Certificate -Cert $cert -FilePath $currentdirectory\Downloads\CertificadoSSL\avaya.cer -Force
    $cert = (Get-ChildItem -Path $currentdirectory\Downloads\CertificadoSSL\avaya.cer)
    $cert | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root > $env:TEMP\out.txt

    Copy-Item Downloads\CertificadoSSL\OneXAgentAPIConfig.bat 'C:\Program Files (x86)\Avaya\Avaya one-X Agent' -Force

    #Start-Process -Wait cmd.exe -ArgumentList "C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentAPIConfig.bat 60001 1 $huella"

    Start-Process -Wait 'C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentAPIConfig.bat' -ArgumentList "60001 1 $huella"

    Start-Process -Wait regedit.exe -ArgumentList "/s $currentdirectory\Downloads\CertificadoSSL\registro_ssl.reg"

    Remove-Item $currentdirectory\Downloads\CertificadoSSL\avaya.cer -Force

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #
Function DownloadClickToDial {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596372"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\ClickToDial.zip
    Expand-Archive Downloads\ClickToDial.zip -DestinationPath Downloads\ClickToDial\ -Force
}
Function nginx {
    Write-Output ""
    Write-Output " ======================================"
    Write-Host "   Installing Click to Dial Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ======================================"
    Write-Output ""

    DownloadClickToDial

    Copy-Item Downloads\ClickToDial\* C:\ -Force -Recurse

    Start-Process C:\Nginx-1.17.8\start.bat

    Start-Sleep -s 10

    Start-Process C:\Nginx-1.17.8\stop.bat

    Start-Process -Wait C:\nssm-2.24\createservice.bat

    Start-Process -Wait C:\sslCert\sslCert.bat

    Restart-Service nginx -PassThru

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #
Function DownloadCTI {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596376"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\CTI.zip
    Expand-Archive Downloads\CTI.zip -DestinationPath Downloads\CTI\ -Force
}
Function cti {
    Write-Output ""
    Write-Output " ===================="
    Write-Host "   Config. CTI . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================="
    Write-Output ""

    DownloadCTI

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
Function DownloadGlobalProtect {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596403"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\GlobalProtect.zip
    Expand-Archive Downloads\GlobalProtect.zip -DestinationPath Downloads\GlobalProtect\ -Force
}

Function globalprotect {
    Write-Output ""
    Write-Output " ======================================="
    Write-Host "   Installing Global Protect Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ======================================="
    Write-Output ""

    DownloadGlobalProtect

    Start-Process -Wait msiexec -ArgumentList '/i Downloads\GlobalProtect\GlobalProtect64.msi /quiet Portal="170.80.97.6"'

    # Este bloque se debe verificar ya que es el certificado de Global Protec
    $cert = (Get-ChildItem -Path $currentdirectory\Downloads\GlobalProtect\GP.cer)
    $cert | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root

    Write-Output ""
    Write-Output " _____________________________________________________________________________________________________"
}

# _______________________________________________________________________________________________ #
Function DownloadScreenPop {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596441"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\ScreenPop.zip
    Expand-Archive Downloads\ScreenPop.zip -DestinationPath Downloads\ScreenPop\ -Force
}
Function screenpop {
    Write-Output ""
    Write-Output " ===================================="
    Write-Host "   Installing ScreenPop Wait . . .   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ===================================="
    Write-Output ""

    #& rundll32.exe dfshim.dll, ShOpenVerbApplication https://despegar.teleperformance.co/spop/Install/TPSPOPDespegar.application

    #Start-Process -Wait rundll32.exe -ArgumentList "dfshim.dll,ShOpenVerbApplication https://despegar.teleperformance.co/spop/Install/TPSPOPDespegar.application"
    DownloadScreenPop

    Start-Process -Wait Downloads\ScreenPop\install.vbs
}

# _______________________________________________________________________________________________ #
Function DownloadDisableOREnable {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $URI = "https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/30596378"

    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile $currentdirectory\Downloads\DisableOREnable.zip
    Expand-Archive Downloads\DisableOREnable.zip -DestinationPath Downloads\DisableOREnable\ -Force
}
Function disableall {
    DownloadDisableOREnable
    Start-Process -Wait -FilePath Downloads\DisableOREnable\Stop.bat
}
Function enableall {
    DownloadDisableOREnable
    Start-Process -Wait -FilePath Downloads\DisableOREnable\Start.bat
}

# _______________________________________________________________________________________________ #

Function DownloadPS {

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
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

    $Very = Get-ADDomain -Server 10.40.54.1 -Credential $cred -ErrorAction SilentlyContinue

    while(!$Very){

        Write-Output ""
        Write-Output " ########################################################## "
        Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ########################################################## "
        Write-Output ""

        $Global:cred = Get-Credential Pais\Nombre.Apellido -Message "Ingresar Credenciales, Ejemplo AR\Fulano.Perencejo"
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
        $Very = Get-ADDomain -Server 10.40.54.1 -Credential $cred -ErrorAction SilentlyContinue
    }

    Write-Output ""
    Write-Output " ##############################################################"
    Write-Host "              Credenciales OK Alegria Alegria " -ForegroundColor Green -BackgroundColor Black
    Write-Host "   Credenciales Validadas con el Dominio: $Very " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############################################################## "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}
Function moveou {
    
    # AR Sucursales GUID {479502b9-d1d8-4bb9-b72c-76b0b2c4fe47}
    # UY PCI GUID {51559502-9b54-49b9-8473-eff00e9267ec}
    # Cl Sucursales {69be72ec-f3fd-4c3a-bb75-8ccb81bd002b}
    # CO PCI {ab67334e-1f0f-48bf-8eef-9287ca32a427}

    Write-Output ""
    showmenupais
    Write-Output ""

    while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "5"){
    
        switch($inp){
            1{
                credencials
                $Computer = hostname
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).objectGUID).Guid
                
                if (!$Identity){

                    Write-Output ""
                    Write-Output " ****************************************** "
                    Write-Host "   El equipo NO existe en el AD, Verificar  " -ForegroundColor Red -BackgroundColor Black
                    Write-Output " ****************************************** "
                    Write-Output ""
                    
                } else {

                    disableall
                    $currentou = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).DistinguishedName

                    Write-Output ""
                    Write-Host " OU Actuales del equipo: $currentou " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""

                    Write-Output ""
                    Write-Host " Moviendo equipo, Espere . . . " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""

                    Move-ADObject -Identity "$Identity" -TargetPath "479502b9-d1d8-4bb9-b72c-76b0b2c4fe47"
                    Start-Sleep -Seconds 15

                    $verif = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).DistinguishedName
                    Write-Output ""
                    Write-host " Nueva OU del equipo: $verif " -ForegroundColor Green -BackgroundColor Black
                    Write-Output ""

                    enableall
                    Pause
                    exit
                }
                
            }
            2{
                credencials
                $Computer = hostname
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server uy.infra.d -Credential $cred).objectGUID).Guid
                
                if (!$Identity){

                    Write-Output ""
                    Write-Output " ****************************************** "
                    Write-Host "   El equipo no existe en el AD, Verificar  " -ForegroundColor Red -BackgroundColor Black
                    Write-Output " ****************************************** "
                    Write-Output ""
                    
                } else {
                    
                    disableall
                    $currentou = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server uy.infra.d -Credential $cred).DistinguishedName

                    Write-Output ""
                    Write-Host " OU Actuales del equipo: $currentou " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""

                    Write-Output ""
                    Write-Host " Moviendo equipo, Espere . . . " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""
                    
                    Move-ADObject -Identity "$Identity" -TargetPath "51559502-9b54-49b9-8473-eff00e9267ec"
                    Start-Sleep -Seconds 15
                    
                    $verif = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server uy.infra.d -Credential $cred).DistinguishedName
                    Write-Output ""
                    Write-host " Nueva OU del equipo: $verif " -ForegroundColor Green -BackgroundColor Black
                    Write-Output ""

                    enableall
                    Pause
                    exit
                }
            }
            3{
                credencials
                $Computer = hostname
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server cl.infra.d -Credential $cred).objectGUID).Guid
                
                if (!$Identity){

                    Write-Output ""
                    Write-Output " ****************************************** "
                    Write-Host "   El equipo no existe en el AD, Verificar  " -ForegroundColor Red -BackgroundColor Black
                    Write-Output " ****************************************** "
                    Write-Output ""
                    
                } else {

                    disableall
                    $currentou = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server cl.infra.d -Credential $cred).DistinguishedName

                    Write-Output ""
                    Write-Host " OU Actuales del equipo: $currentou " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""

                    Write-Output ""
                    Write-Host " Moviendo equipo, Espere . . . " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""

                    Move-ADObject -Identity "$Identity" -TargetPath "69be72ec-f3fd-4c3a-bb75-8ccb81bd002b"
                    Start-Sleep -Seconds 15

                    $verif = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server cl.infra.d -Credential $cred).DistinguishedName
                    Write-Output ""
                    Write-host " Nueva OU del equipo: $verif " -ForegroundColor Green -BackgroundColor Black
                    Write-Output ""
                    enableall
                    Pause
                    exit
                }
            }
            4{
                credencials
                $Computer = hostname
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server co.infra.d -Credential $cred).objectGUID).Guid
                
                if (!$Identity){

                    Write-Output ""
                    Write-Output " ****************************************** "
                    Write-Host "   El equipo no existe en el AD, Verificar  " -ForegroundColor Red -BackgroundColor Black
                    Write-Output " ****************************************** "
                    Write-Output ""
                    
                } else {
                    disableall
                    $currentou = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server co.infra.d -Credential $cred).DistinguishedName

                    Write-Output ""
                    Write-Host " OU Actuales del equipo: $currentou " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""

                    Write-Output ""
                    Write-Host " Moviendo equipo, Espere . . . " -ForegroundColor Yellow -BackgroundColor Black
                    Write-Output ""

                    Move-ADObject -Identity "$Identity" -TargetPath "ab67334e-1f0f-48bf-8eef-9287ca32a427"
                    Start-Sleep -Seconds 15
                    
                    $verif = (Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server co.infra.d -Credential $cred).DistinguishedName
                    Write-Output ""
                    Write-host " Nueva OU del equipo: $verif " -ForegroundColor Green -BackgroundColor Black
                    Write-Output ""
                    enableall
                    Pause
                    exit
                }
            }
            5{"Exit"; break}
            default {Write-Host -ForegroundColor red -BackgroundColor white "Opcion Invalida, por favor seleccion una de las disponibles"}
    
        }

    Write-Output ""
    showmenupais
    Write-Output ""
    } 
    
}

# _______________________________________________________________________________________________ #

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

Function showmenumain {
    #Clear-Host
    Write-Output ""
    Write-Host " ********************** "
    Write-Host "  1. Usuario Despegar   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "  2. Usuario Falabella  " -ForegroundColor Yellow -BackgroundColor Black
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
            Write-Host " Ejecuto Script para usuario Despegar " 
            Write-Host "------------------------------"
            Write-Output ""

            disableall
            extyagent
            netframework
            PreInstall
            tsapi
            avaya
            certificados
            nginx
            cti
            enableall
            Pause
            Exit
            
        }
        2 {
            #Clear-Host
            Write-Output ""
            Write-Host "------------------------------"
            Write-Host " Ejecuto Script para usuario Sucursal "
            Write-Host "------------------------------"
            Write-Output ""
            
            disableall
            extyagent
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
            Pause
            Exit
        }
        3 {
            Write-Output ""
            Write-Output " no usar (No te Dije Pelotudo)  "
            Write-Output ""
        }
        4 { 
            
            moveou
            
        }
        5 {"Exit"; break}
        default {Write-Host -ForegroundColor red -BackgroundColor white "Opcion Invalida, por favor seleccion una de las disponibles"}
        
    }

showmenumain
}