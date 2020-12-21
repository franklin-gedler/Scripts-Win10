$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
cd $currentdirectory
(pwd).Path
#Add-MpPreference -ExclusionPath "$currentdirectory"
###########################################################################################################################

Function creadopor {
    echo " _____________________________________________________________________________________________________"

    echo ""
    echo "                                  ++++++++++++++++++++++++++++++++++++"
    Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
    Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
    Write-Host "                                         Updates Franklin Diaz                                        " -ForegroundColor green -BackgroundColor Black
    echo "                                  ++++++++++++++++++++++++++++++++++++"
    echo ""

    echo " _____________________________________________________________________________________________________"

}

creadopor

###########################################################################################################################

Function extyagent {
    echo ""
    echo " ------------------------------------"
    Write-Host "   Ingrese Numero de Extension . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ------------------------------------"
    echo ""
    $Global:interno = Read-Host
    $Global:interno = $interno.replace(' ' , '')

    echo ""
    echo " ------------------------------------"
    Write-Host "     Ingrese Numero de Agente . . .  " -ForegroundColor Yellow -BackgroundColor Black
    echo " ------------------------------------"
    echo ""
    $Global:agente = Read-Host
    $Global:agente = $agente.Replace(' ' , '')

    echo ""
    echo " _____________________________________________________________________________________________________"

}

Function netframework {
    Stop-Service wuauserv -Force -PassThru
    Rename-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -NewName "WindowsUpdateold"
    Set-Service wuauserv -StartupType Manual -PassThru
    Start-Service wuauserv -PassThru

    echo ""
    echo " ======================================"
    Write-Host "   Installing Net Framework Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ======================================"
    echo ""

    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All

    # Verificar que se instalo los net framework:
    # Get-WindowsOptionalFeature -Online -FeatureName "NetFX4"
    # Get-WindowsOptionalFeature -Online -FeatureName "NetFX3"

    # Deshabilitar framework 3.5
    # Disable-WindowsOptionalFeature -Online -FeatureName "NetFx3"

    echo ""
    echo " _____________________________________________________________________________________________________"

}

Function silverlight {
    echo ""
    echo " =============================================="
    Write-Host "   Installing Microsoft Silverlight Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " =============================================="
    echo ""

    Start-Process -Wait -FilePath Pre\Silverlight_x64.exe -ArgumentList "/q"

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function visual {
    echo ""
    echo " ========================================================================"
    Write-Host "   Installing Microsoft Visual C++ 2017 Redistributable (x64) Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ========================================================================"
    echo ""

    Start-Process -Wait -FilePath Pre\VC_redist.x64.exe -ArgumentList "/install /quiet /norestart"

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function tsapi {
    echo ""
    echo " ====================================="
    Write-Host "   Installing Tsapi-Client Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ====================================="
    echo ""

    Start-Process -Wait -FilePath TsapiClient\setup.exe -ArgumentList "/s /f1$currentdirectory\TsapiClient\setup.iss"

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function avaya {
    echo ""
    echo " ===================================="
    Write-Host "   Installing Avaya One X Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ===================================="
    echo ""

    Start-Process -Wait -FilePath AvayaOneX\OnexAgentSetup\application\OneXAgentSetup.exe -ArgumentList "/qn"
    Start-Process -Wait regedit.exe -ArgumentList "/s $currentdirectory\AvayaOneX\DisableMuteButton.reg"

    Remove-Item -Path "$env:appdata\Avaya\" -Force -Recurse -ErrorAction SilentlyContinue

    Copy-Item AvayaOneX\Avaya "$env:appdata\" -Force -Recurse

    # Seteo extension
    $File = "$env:appdata\Avaya\one-X Agent\2.5\Profiles\default\Settings.xml"
    $Content = [System.IO.File]::ReadAllText("$File")
    $Content = $Content.Replace('1111111', "$interno")
    $Content = $Content.Trim()
    [System.IO.File]::WriteAllText("$File", $Content)

    # Seteo Agente
    $Content = [System.IO.File]::ReadAllText("$File")
    $Content = $Content.Replace('2222222', "$agente")
    $Content = $Content.Trim()
    [System.IO.File]::WriteAllText("$File", $Content)

    

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function certificados {
    echo ""
    echo " ===================================="
    Write-Host "    Config. Certificate Wait . . .   " -ForegroundColor Yellow -BackgroundColor Black
    echo " ===================================="
    echo ""

    $huella = (New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "127.0.0.1" -FriendlyName "MySiteCert" -NotAfter (Get-Date).AddYears(10)).Thumbprint
    $cert = (Get-ChildItem -Path cert:\LocalMachine\My\$huella)
    Export-Certificate -Cert $cert -FilePath $currentdirectory\CertificadoSSL\avaya.cer -Force > $env:TEMP\out.txt
    $cert = (Get-ChildItem -Path $currentdirectory\CertificadoSSL\avaya.cer)
    $cert | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root > $env:TEMP\out.txt

    Copy-Item CertificadoSSL\OneXAgentAPIConfig.bat 'C:\Program Files (x86)\Avaya\Avaya one-X Agent' -Force

    #Start-Process -Wait cmd.exe -ArgumentList "C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentAPIConfig.bat 60001 1 $huella"

    Start-Process -Wait 'C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentAPIConfig.bat' -ArgumentList "60001 1 $huella"

    Start-Process -Wait regedit.exe -ArgumentList "/s $currentdirectory\CertificadoSSL\registro_ssl.reg"

    Remove-Item $currentdirectory\CertificadoSSL\avaya.cer -Force

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function nginx {
    echo ""
    echo " ======================================"
    Write-Host "   Installing Click to Dial Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ======================================"
    echo ""

    Copy-Item ClickToDial\* C:\ -Force -Recurse

    Start-Process C:\Nginx-1.17.8\start.bat

    Start-Sleep -s 10

    Start-Process C:\Nginx-1.17.8\stop.bat

    Start-Process -Wait C:\nssm-2.24\createservice.bat

    Start-Process -Wait C:\sslCert\sslCert.bat

    Restart-Service nginx -PassThru

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function cti {
    echo ""
    echo " ===================="
    Write-Host "   Config. CTI . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ===================="
    echo ""

    Remove-Item -Path "C:\CTI.ini" -Force -ErrorAction SilentlyContinue

    $File = "CTI\CTI.ini"
    $Content = [System.IO.File]::ReadAllText("$currentdirectory\$File")
    $Content = $Content.Replace('7XXXXXX', "$interno")
    $Content = $Content.Trim()
    [System.IO.File]::WriteAllText("C:\CTI.ini", $Content)
    

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function globalprotect {
    echo ""
    echo " ======================================="
    Write-Host "   Installing Global Protect Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
    echo " ======================================="
    echo ""

    Start-Process -Wait msiexec -ArgumentList '/i GlobalProtect\GlobalProtect64.msi /quiet Portal="170.80.97.6"'

    # Este bloque se debe verificar ya que es el certificado de Global Protec
    $cert = (Get-ChildItem -Path $currentdirectory\GlobalProtect\GP.cer)
    $cert | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root

    echo ""
    echo " _____________________________________________________________________________________________________"
}

Function screenpop {
    echo ""
    echo " ===================================="
    Write-Host "   Installing ScreenPop Wait . . .   " -ForegroundColor Yellow -BackgroundColor Black
    echo " ===================================="
    echo ""

    #& rundll32.exe dfshim.dll, ShOpenVerbApplication https://despegar.teleperformance.co/spop/Install/TPSPOPDespegar.application

    #Start-Process -Wait rundll32.exe -ArgumentList "dfshim.dll,ShOpenVerbApplication https://despegar.teleperformance.co/spop/Install/TPSPOPDespegar.application"

    Start-Process -Wait ScreenPop\install.vbs
}

############################################################################################################################

Function disableall {
    Start-Process -Wait -FilePath DisableOREnable\Stop.bat
}

Function enableall {
    Start-Process -Wait -FilePath DisableOREnable\Start.bat
}

############################################################################################################################

Function credencials {
    $Global:cred = Get-Credential Pais\Nombre.Apellido -Message "Ingresar Credenciales, Ejemplo AR\Fulano.Perencejo"

    echo " ============================================== "
    Write-Host "       Validando credenciales ingresadas        " -ForegroundColor Yellow -BackgroundColor Black
    echo " ============================================== "

    Copy-Item -LiteralPath PS\ -Destination C:\ -Recurse -Force
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue

    $Very = Get-ADDomain -Server 10.40.54.1 -Credential $cred -ErrorAction SilentlyContinue

    while(!$Very){

        echo ""
        echo " ########################################################## "
        Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
        echo " ########################################################## "
        echo ""

        $Global:cred = Get-Credential Pais\Nombre.Apellido -Message "Ingresar Credenciales, Ejemplo AR\Fulano.Perencejo"
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
        $Very = Get-ADDomain -Server 10.40.54.1 -Credential $cred -ErrorAction SilentlyContinue
    }

    echo ""
    echo " ##############################################################"
    Write-Host "              Credenciales OK Alegria Alegria " -ForegroundColor Green -BackgroundColor Black
    Write-Host "   Credenciales Validadas con el Dominio: $Very " -ForegroundColor Green -BackgroundColor Black
    echo " ############################################################## "
    echo ""
    echo "_________________________________________________________________________________________"
    echo ""
}

Function moveou {
    
    # AR Sucursales GUID {479502b9-d1d8-4bb9-b72c-76b0b2c4fe47}
    # UY PCI GUID {51559502-9b54-49b9-8473-eff00e9267ec}
    # Cl Sucursales {69be72ec-f3fd-4c3a-bb75-8ccb81bd002b}
    # CO PCI {ab67334e-1f0f-48bf-8eef-9287ca32a427}

    #echo "Este es el valor de crdednciales: $cred"
    $Computer = hostname
    $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).objectGUID).Guid
    
    echo ""
    showmenupais
    echo ""

    while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "5"){

        switch($inp){
            1{
                Move-ADObject -Identity "$Identity" -TargetPath "479502b9-d1d8-4bb9-b72c-76b0b2c4fe47"
                Start-Sleep -Seconds 15
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).objectGUID).Guid
                echo $Identiny
                Pause
                exit
            }
            2{
                Move-ADObject -Identity "$Identity" -TargetPath "51559502-9b54-49b9-8473-eff00e9267ec"
                Start-Sleep -Seconds 15
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).objectGUID).Guid
                echo $Identiny
                Pause
                exit
            }
            3{
                Move-ADObject -Identity "$Identity" -TargetPath "69be72ec-f3fd-4c3a-bb75-8ccb81bd002b"
                Start-Sleep -Seconds 15
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).objectGUID).Guid
                echo $Identiny
                Pause
                exit
            }
            4{
                Move-ADObject -Identity "$Identity" -TargetPath "ab67334e-1f0f-48bf-8eef-9287ca32a427"
                Start-Sleep -Seconds 15
                $Identity = ((Get-ADComputer -LDAPFilter "(cn=$Computer)" -SearchScope Subtree -Server ar.infra.d -Credential $cred).objectGUID).Guid
                echo $Identiny
                Pause
                exit
            }
            5{"Exit"; break}
            default {Write-Host -ForegroundColor red -BackgroundColor white "Opcion Invalida, por favor seleccion una de las disponibles"}
    
        }

    echo ""
    showmenupais
    echo ""
    }
}


#############################################################################################################################

# Repair block

Function uninstallavaya {
    $Programa = Get-WmiObject -Class Win32_Product -Filter "Name = 'Avaya one-X Agent - 2.5.13'"
    $Programa.Uninstall()
    Remove-Item -Force $env:appdata\Avaya -Recurse
}

#############################################################################################################################

Function showmenurepair {
    echo ""
    echo " ************************************ "
    echo "  1. Reinstalar Solo Avaya (Sin Pre) "
    
    echo ""

}

Function showmenupais {

    echo ""
    Write-Host " **** De que pais es la maquina **** "
    Write-Host ""
    Write-Host "                1. AR  "
    Write-Host "                2. UY  "
    Write-Host "                3. CL  "
    Write-Host "                4. CO  "
    Write-Host "                5. Exit "
    Write-Host " *********************************** "
    echo ""

}

Function showmenumain {
    #Clear-Host
    echo ""
    Write-Host " ********************** "
    Write-Host "  1. Usuario Despegar   "
    Write-Host "  2. Usuario Falaverga  "
    Write-Host "  3. Reparar (No Usar)  "
    Write-Host "  4. Mover Equipo OU    "
    Write-Host "  5. Exit               "
    Write-Host " ********************** "
    echo ""
}

############################################################################################################################

echo ""
showmenumain

while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "5"){

switch($inp){
    
        1 {
            #Clear-Host
            echo ""
            Write-Host "------------------------------"
            Write-Host " Ejecuto Script para usuario Despegar " 
            Write-Host "------------------------------"
            echo ""

            disableall
            extyagent
            netframework
            silverlight
            visual
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
            echo ""
            Write-Host "------------------------------"
            Write-Host " Ejecuto Script para usuario Sucursal "
            Write-Host "------------------------------"
            echo ""
            
            disableall
            extyagent
            netframework
            silverlight
            visual
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
            echo ""
            echo " no usar (No te Dije Pelotudo)  "
            echo ""
        }
        4 { 
            disableall
            credencials
            moveou
            enableall
        }
        5 {"Exit"; break}
        default {Write-Host -ForegroundColor red -BackgroundColor white "Opcion Invalida, por favor seleccion una de las disponibles"}
        
    }

showmenumain
}