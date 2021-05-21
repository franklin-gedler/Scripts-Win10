clear
Write-Output " _____________________________________________________________________________________________________"

Write-Output ""
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output " _____________________________________________________________________________________________________"

Function showmenupais {

    Write-Output ""
    Write-Host " ******* Seleccione el pais  ******* "
    Write-Host ""
    Write-Host "                0. Exit              " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    Write-Host "                1. AR                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                2. UY                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                3. BR                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                4. CO                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                5. CL                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                6. MX                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                7. PE                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " *********************************** "
}

function ShowMenuPci {
    
    Write-Output ""
    Write-Host " *** ¿Va ser PCI el equipo? ***  "
    Write-Host ""
    Write-Host "            0. Exit              " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    Write-Host "            1. SI                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "            2. NO                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " ******************************* "
}

function ChangeName {
    param (
        [String]$1
    )
    $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    $Global:NCompu = "$1$SCompu"
    #Write-Output "Nuevo nombre a Setear: $NCompu"
    while (!$SCompu) {
        $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
        $Global:NCompu = "$1$SCompu"
        #Write-Output "Nuevo nombre a Setear: $NCompu"
    }
}

function ChangeNamePCI {
    param (
        [String]$1
    )
    $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    $Global:NCompu = $1 + 'PCI' + $SCompu
    #Write-Output "Nuevo nombre a Setear: $NCompu"
    while (!$SCompu) {
        $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
        $Global:NCompu = "$1PCI$SCompu"
        #Write-Output "Nuevo nombre a Setear: $NCompu"
    }
}

function VerifyConnection {
    param (
        [String]$1,[String]$2
    )

    Write-Output ""
    Write-Output " ================================================ "
    Write-Host "       Verificando conexion con el Dominio        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================================ "

    $CAD = $(Test-Connection "10.40.$1.1" -Count 2 -Quiet -ErrorAction SilentlyContinue)

    while("$CAD" -eq 'False'){
        Write-Output ""
        Write-Output " ############################################################## "
        Write-Host " Error al conectar con $2.infra.d, por favor verificar conexion " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ############################################################## "
        Pause
        $CAD = $(Test-Connection "10.40.$1.1" -Count 2 -Quiet -ErrorAction SilentlyContinue)
        Write-Output ""
    }
    Write-Output ""
    Write-Output " ########################## "
    Write-Host " Conexion con el Dominio OK " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ########################## "

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""   
}

function VerifyCred {

    param (
        [String]$1,[String]$2
    )

    $Global:cred = Get-Credential $2\ -Message "Ingresar Credenciales, $2\Nombre.Apellido"
    Write-Output " ============================================== "
    Write-Host "       Validando credenciales ingresadas        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================================== "
    Copy-Item -Path $PSScriptRoot\PS -Destination C:\ -Recurse -force
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
    $Global:Very = Get-ADDomain -Server "10.40.$1.1" -Credential $cred -ErrorAction SilentlyContinue
    while(!$Very){
        Write-Output ""
        Write-Output " ########################################################## "
        Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ########################################################## "
        Write-Output ""
        $Global:cred = Get-Credential $2\ -Message "Vuelva a escribir sus credenciales, Ej: $2\Nombre.Apellido"
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
        $Global:Very = Get-ADDomain -Server "10.40.$1.1" -Credential $cred -ErrorAction SilentlyContinue
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

function JoinAD {
    
    param (
        [String]$1,$2
    )

    $Global:consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" `
        -SearchScope Subtree -Server "10.40.$2.1" `
        -Credential $cred | Select-Object -ExpandProperty DistinguishedName

    if ($consul){
        Write-Output " =============================================== "
        Write-Host "   Equipo existe en el AD, se procede a borrar   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " =============================================== "
        Remove-ADObject -Identity "$consul" -Credential $cred -Server "10.40.$2.1" -Confirm:$False -verbose
        Start-Sleep -Seconds 15
        Write-Output ""
        Write-Output " ############# "
        Write-Host "   Eliminado   " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ############# "
    }

    Write-Output ""
    Write-Output " ==================================== "
    Write-Host "        Enlazando equipo al AD        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================================== "

    Rename-Computer -NewName $NCompu -WarningAction SilentlyContinue
    Start-Sleep -Seconds 5

    #add-computer -DomainName $domainname -Credential $Credential -OUPath $OU -force -Options JoinWithNewName,AccountCreate -restart

    $Global:Binding = Add-Computer -DomainName "$1.infra.d" `
        -Credential $cred -Force -Options JoinWithNewName,AccountCreate `
        -WarningAction SilentlyContinue -PassThru           
    
    #$Binding = Add-Computer -NewName "$NCompu" -DomainName ar.infra.d -Force -Credential $cred -PassThru
    while ($Binding.HasSucceeded -eq $False) {
        Write-Output ""
        Write-Output " #################################### "
        Write-Host "   Error en enlazar el equipo al AD   " -ForegroundColor Red -BackgroundColor Black
        Write-Output " #################################### "
        Write-Output ""
        Write-Host "  Presione Enter para Intentar de Nuevo " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output ""
        $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $Global:Binding = Add-Computer -DomainName "$1.infra.d" `
            -Credential $cred -Force -Options JoinWithNewName,AccountCreate `
            -WarningAction SilentlyContinue -PassThru  
    }

    Write-Output ""
    Write-Output " ######################################################### "
    Write-Host "  Se agrego al equipo $NCompu al Dominio $1.infra.d  " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######################################################### "

    <#
    if( $Binding.HasSucceeded -eq $true ){
    
        Write-Output ""
        Write-Output " ######################################################### "
        Write-Host "  Se agrego al equipo $NCompu al Dominio $1.infra.d  " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ######################################################### "

    }else{
    
        Write-Output ""
        Write-Output " ################################################################### "
        Write-Host "  Error a enlazar el equipo al AD, Por Favor realizarlo Manualmente  " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ################################################################### "
        Write-Output ""

    }

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
    #>
}
function VPNRegional {
    Write-Output " =========================== "
    Write-Host "   Instalando VPN Regional   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =========================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait msiexec -ArgumentList '/i "C:\WINDOWS\setup\scripts\E84.00_CheckPointVPN.msi" /quiet /norestart'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""  
}

function 7Zip {
    Write-Output " =================== "
    Write-Host "   Instalando 7Zip   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\7z1900-x64.exe -ArgumentList '/S'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""  
}

function AcrobatReader {
    Write-Output " ============================= "
    Write-Host "   Instalando Acrobat Reader   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================= "
    #Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\AcroRdrDC1902120049_es_ES.exe -ArgumentList '/sAll'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}
function Java {
    Write-Output " =================== "
    Write-Host "   Instalando Java   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =================== "
    #Set-Location $PSScriptRoot
    #Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\java.exe -ArgumentList '/s'
    mkdir $env:TMP\javadownload > NULL

    $Token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    
    $Headers = @{
    accept = "application/octet-stream"
    authorization = "Token " + $Token
    }

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri https://api.github.com/repos/franklin-gedler/Only-Download-Prepare-Windows10/releases/assets/36871675 `
                    -Headers $Headers -UseBasicParsing -OutFile $env:TMP\javadownload\jre-8u291-windows-i586.exe

    Start-Process -Wait -FilePath $env:TMP\javadownload\jre-8u291-windows-i586.exe -ArgumentList '/s'

    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}

function GoogleChrome {
    Write-Output " ============================ "
    Write-Host "   Instalando Google Chrome   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================ "
    #Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\ChromeStandaloneSetup64.exe -ArgumentList '/silent /install'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}

function Office2016 {
    Write-Output " ========================== "
    Write-Host "   Instalando Office 2016   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ========================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\Office2016x64\setup.exe -ArgumentList '/config standard.ww\config.xml'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}
function TeamViewer {
    Write-Output " =========================================== "
    Write-Host "   Instalando TeamViewerHost con Politicas   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =========================================== "
    #Set-Location $PSScriptRoot
    Start-Process msiexec -ArgumentList '/i "C:\WINDOWS\setup\scripts\TeamViewer_Host.msi" /qn SETTINGSFILE="C:\WINDOWS\setup\scripts\politicas.reg"' -Wait
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""  
}
function Antivirus {
    Write-Output " ==================== "
    Write-Host "    Instalando AV     " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================== "
    #Set-Location $PSScriptRoot
    #Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\McAfeeSmartInstall.exe -ArgumentList '-s' /INSTALL=UPDATER


    #Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\Instalador-Mcafee.exe -ArgumentList '/Install=Agent /ForceInstall /Silent'
    #Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\Instalador-Mcafee.exe -ArgumentList '/INSTALL=UPDATER /ForceInstall /Silent'
    Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\Instalador-Mcafee.exe

    
    #Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\McAfeeSmartInstall.exe -Destination C:\Users\admindesp\Desktop\
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}
function FusionInventory {
    Write-Output " ================================= "
    Write-Host "    Instalando FusionInventory     " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================= "
    #Set-Location $PSScriptRoot
    #& "C:\WINDOWS\setup\scripts\fusioninventory-agent-deployment.vbs"
    Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\fusioninventory-agent-deployment.vbs
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}

function ZoomInstaller {
    Write-Output " =================== "
    Write-Host "   Instalando Zoom   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait msiexec -ArgumentList '/i "C:\WINDOWS\setup\scripts\ZoomInstallerFull.msi" ZoomAutoUpdate=true /qn'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}

function LibreOffice {

    Write-Output " ========================== "
    Write-Host "   Instalando LibreOffice   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ========================== "
    #Set-Location $PSScriptRoot
    Start-Process -Wait msiexec -ArgumentList '/i "C:\WINDOWS\setup\scripts\LibreOffice_7.1.1_Win_x64.msi" REGISTER_ALL_MSO_TYPES=1 RebootYesNo=No /qn'
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}
function BitLocker {
    param (
        [String]$1
    )
    
    Write-Output ""
    Write-Output " ========================================= "
    Write-Host "     Verificando si el TPM esta Activo     " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ========================================= "
    $tpmpresent = (Get-Tpm).TpmPresent
    $tpmready = (Get-Tpm).TpmReady

    if("$tpmpresent" -eq "False" -And "$tpmready" -eq "False"){
        Write-Output ""
        Write-Output " ####################################################################################### "
        Write-Host " ERROR: TPM NO ACTIVO, POR FAVOR VERIFICAR EN EL BIOS Y ACTIVAR EL BITLOCKER MANUALMENTE " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ####################################################################################### "
        Write-Output ""

    }else {
        Write-Output ""
        Write-Output " ############ "
        Write-Host "  TPM Activo  " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ############ "
        Write-Output ""
        Write-Output " ============================== "
        Write-Host "     Habilitando Bitlocker      " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ============================== "
        #Enable-BitLocker -MountPoint C: -RecoveryPasswordProtector

        #Enable-Bitlocker -MountPoint c: -UsedSpaceOnly -SkipHardwareTest -RecoveryPasswordProtector
        Enable-BitLocker -MountPoint C: -TpmProtector -SkipHardwareTest -UsedSpaceOnly -ErrorAction Continue
        Enable-BitLocker -MountPoint C: -RecoveryPasswordProtector -SkipHardwareTest
        manage-bde -on C: -UsedSpaceOnly -rp > NULL


        (Get-BitLockerVolume -mount c).keyprotector | Select-Object $NCompu, KeyProtectorId, RecoveryPassword > C:\Users\admindesp\Desktop\$NCompu.txt
        #(Get-BitLockerVolume -mount c).keyprotector[1] | Select-Object $NCompu, KeyProtectorId, RecoveryPassword > C:\Users\admindesp\Desktop\$NCompu.txt

        $KeyID = Get-BitLockerVolume -MountPoint C: | Select-Object -ExpandProperty KeyProtector `
                | Where-Object KeyProtectorType -eq 'RecoveryPassword' `
                | Select-Object -ExpandProperty KeyProtectorId

        $PassRecovery = Get-BitLockerVolume -MountPoint C: | Select-Object -ExpandProperty KeyProtector `
                        | Where-Object KeyProtectorType -eq 'RecoveryPassword' | Select-Object -ExpandProperty RecoveryPassword

        $Global:IdKeyBitlocker = "KeyProtectorId:  $KeyID ------------------------------ RecoveryPassword:  $PassRecovery"

        # Envia el mail con id y recovery
        SendMail

        Write-Output ""
        Write-Output " ============================= "
        Write-Host "  Verificando conexion al NAS  " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ============================= "
        $nas = Test-Connection 10.40.54.52 -Count 2 -Quiet
        if ("$nas" -eq 'False'){
            Write-Output ""
            Write-Output " ############################################################################################################## "
            Write-Host "  Problemas para conectarnos al NAS, se creo archivo $NCompu en el escritorio con el ID y PASS Bitlocker  " -ForegroundColor Red -BackgroundColor Black
            Write-Output " ############################################################################################################## "
        }else {
            Write-Output ""
            Write-Output " ######################## "
            Write-Host "  Conexion con el NAS OK  " -ForegroundColor Green -BackgroundColor Black
            Write-Output " ######################## "
            Write-Output ""
            Write-Output ""
            Write-Output " =========================== "
            Write-Host "  Copiando ID y PASS al NAS  " -ForegroundColor Yellow -BackgroundColor Black
            Write-Output " =========================== "
            New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles\$1" -Credential $cred
            Copy-Item -LiteralPath C:\Users\admindesp\Desktop\$NCompu.txt -Destination Z:\
        }

    }
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}
function SendMail {
    
    $Mail = 'soportescripts@gmail.com'
    $PassFile = "$PSScriptRoot\passfile"
    $Key = "$PSScriptRoot\key"

    $credMail = New-Object -TypeName System.Management.Automation.PSCredential `
                -ArgumentList "$Mail", (Get-Content "$PassFile" | ConvertTo-SecureString -Key (Get-Content "$Key"))

    #$PassMail = ConvertTo-SecureString "micontraseña" -AsPlainText -Force
    #$PassMail = Get-Content $env:USERPROFILE\Desktop\file | ConvertTo-SecureString -Force
    #$credMail = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Mail, $PassMail
    
    Send-MailMessage -From soportescripts@gmail.com -To soporte@despegar.com `
                     -Subject "$NCompu" -Body "$IdKeyBitlocker" -Priority High `
                     -UseSsl -SmtpServer smtp.gmail.com -Port 587 -Credential $credMail

}

function ReinicioWin {
    param (
        $1
    )

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    Write-Output "------------------------------------"
    Write-Host "         SE VA A REINICIAR          " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output "------------------------------------"
    $p = ConvertTo-SecureString "*+$1#$SCompu*" -AsPlainText -Force
    $u = (Get-LocalUser).Name[0]
    Set-LocalUser -Name $u -Password $p -PasswordNeverExpires 1
    
    # ________________ Habilito el Windows Update Poronga ______________________________________
    Set-Service wuauserv -StartupType Manual -InformationAction SilentlyContinue
    Start-Service wuauserv -InformationAction SilentlyContinue
    #Get-Service wuauserv | Select-Object *
    #Pause
    timeout /t 300

    # _______________ Elimino todo despues de ejecutar _____________________________
    Write-Output {
    Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
    #Remove-Item -LiteralPath C:\PS -Recurse -Force
    } > $env:TMP\AutoDelete.ps1
    #& C:\Windows\Setup\scripts\AutoDelete.ps1
    #Start-Process -Wait PowerShell.exe -ArgumentList "& AutoDelete.ps1"
    & $env:TMP\AutoDelete.ps1
    Restart-Computer -Force
    exit
}

function Sabre {
    Write-Output " ================================ "
    Write-Host "   Moviendo Sabre al Escritorio   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================ "

    if (!(Test-Path $env:USERPROFILE\Desktop\Extras)){
        New-Item -Path $env:USERPROFILE\Desktop\ -Name "Extras" -ItemType Directory
    }

    Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\Sabre_2.20.12.exe -Destination $env:USERPROFILE\Desktop\Extras -Force
    
    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}

function Avaya {
    Write-Output " ================================ "
    Write-Host "   Moviendo Avaya al Escritorio  " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================ "

    if (!(Test-Path $env:USERPROFILE\Desktop\Extras)){
        New-Item -Path $env:USERPROFILE\Desktop\ -Name "Extras" -ItemType Directory
    }

    Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\Install-Avaya.zip -Destination $env:USERPROFILE\Desktop\Extras -Force

    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}

function eLatam {
    Write-Output " ================================== "
    Write-Host "   Moviendo E-Latam al Escritorio   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================== "

    if (!(Test-Path $env:USERPROFILE\Desktop\Extras)){
        New-Item -Path $env:USERPROFILE\Desktop\ -Name "Extras" -ItemType Directory
    }

    Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\ELatam\ -Destination $env:USERPROFILE\Desktop\Extras -Force -Recurse

    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}

function WorldSpan {
    Write-Output " ==================================== "
    Write-Host "   Moviendo WorldSpan al Escritorio   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================================== "

    if (!(Test-Path $env:USERPROFILE\Desktop\Extras)){
        New-Item -Path $env:USERPROFILE\Desktop\ -Name "Extras" -ItemType Directory
    }

    Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\WorldSpan\ -Destination $env:USERPROFILE\Desktop\Extras -Force -Recurse

    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}

function CertAzul {
    
    Write-Output " ================================= "
    Write-Host "   Instalando Certificado ca.crt   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================= "

    Expand-Archive $PSScriptRoot\ca.zip $PSScriptRoot\ca\ -Force

    $certca = (Get-ChildItem -Path $PSScriptRoot\ca\ca.crt)
    $certca | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root

    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
    
}

function MicroSip {
    # No tiene instalador Silencioso
    Write-Output " =================================== "
    Write-Host "   Moviendo MicroSip al Escritorio   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =================================== "

    if (!(Test-Path $env:USERPROFILE\Desktop\Extras)){
        New-Item -Path $env:USERPROFILE\Desktop\ -Name "Extras" -ItemType Directory
    }

    Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\MicroSIP-3.20.5.exe -Destination $env:USERPROFILE\Desktop\Extras -Force

    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}

function SetRegionUpdateTime {
    
    param(
        $1,$2
    )
    Write-Output ""
    Write-Output " ============================= "
    Write-Host "   Actualizando Hora y Fecha   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================= "
    Write-Output ""

    Set-TimeZone -Id "$1"

    Set-Service w32time -StartupType Automatic
    Start-Service w32time
    w32tm /config /syncfromflags:manual /manualpeerlist:"$2.infra.d" /reliable:yes /update > $null
    Start-Sleep -Seconds 15
    #w32tm /query /status
    #Stop-Service w32time
    #Start-Service w32time
    

    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    <#
    AR: Set-TimeZone -Id "Argentina Standard Time"

    UY: Set-TimeZone -Id "Montevideo Standard Time"

    BR: Set-TimeZone -Id "E. South America Standard Time"

    CO: Set-TimeZone -Id "SA Pacific Standard Time"

    CL: Set-TimeZone -Id "Pacific SA Standard Time"

    MX: Set-TimeZone -Id "Central Standard Time (Mexico)"

    PE: Set-TimeZone -Id "SA Pacific Standard Time
    #>
    
    # Cambia Idioma de entorno, teclado
    #$UserLanguageList = New-WinUserLanguageList -Language "pt-BR"
    #$UserLanguageList.Add("pt-BR")
    #Set-WinUserLanguageList -LanguageList $UserLanguageList -Force

    # cambia la Region
    #Set-Culture -CultureInfo pt-BR

    # Cambia la Zona horaria
    #Set-TimeZone -Id "E. South America Standard Time"

     
}


function googlerapidresponse {
    Write-Output " ==================================== "
    Write-Host "   Instalando Google Rapid Response   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================================== "
    Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\GRR_3.4.2.4_amd64.exe
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output "" 
}

function DellAllUpdate {
    $machinebrand =  (Get-WmiObject -class win32_computersystem).Manufacturer
    
    if("$machinebrand" -eq "Dell Inc."){
    
        Write-Output " =================================  "
        Write-Host "   Instalando Dell Command Update   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ================================== "
        Write-Output ""
        mkdir $env:TMP\dellcommand > NULL

        ChargerStatus # valido si el cargador esta conectado

        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri https://dl.dell.com/FOLDER06986400M/2/Dell-Command-Update-Application_P5R35_WIN_4.1.0_A00.EXE `
            -UseBasicParsing -OutFile $env:TMP\dellcommand\Dell-Command-Win-4-1-0.exe

        Start-Process -Wait $env:TMP\dellcommand\Dell-Command-Win-4-1-0.exe -ArgumentList '/s' `
            -RedirectStandardError $env:USERPROFILE\Desktop\errDownloadDellCommand.txt

        Start-Process -Wait "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" `
            #-ArgumentList '/applyUpdates -autoSuspendBitLocker=enable -userConsent=disable -updateType=bios,driver' `
            -ArgumentList '/configure -userConsent=disable -autoSuspendBitLocker=enable -updatetype=bios,driver,firmware' `
            #-NoNewWindow -RedirectStandardError $env:USERPROFILE\Desktop\errRUNDellCommand.log

        Start-Process -Wait "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" `
            -ArgumentList '/applyUpdates'

            #dcu-cli.exe /configure -userConsent=disable -autoSuspendBitLocker=enable -updatetype=bios,driver,firmware > NULL
            #/applyUpdates
        Write-Output ""
        Write-Output "_________________________________________________________________________________________"
        Write-Output "" 
    }
    
}

function ChargerStatus {
    $validatecharger = [BOOL](Get-WmiObject -Class BatteryStatus -Namespace root\wmi).PowerOnLine
        while ("$validatecharger" -eq "false"){

            Write-Output ""
            Write-Output " ########################################### "
            Write-Host "   Por favor, Conectar cargador del equipo   " -ForegroundColor Yellow -BackgroundColor Black
            Write-Output " ########################################### "
            timeout /t 300
            $validatecharger = [BOOL](Get-WmiObject -Class BatteryStatus -Namespace root\wmi).PowerOnLine

            Write-Output ""
            
        }
    
}

#___________________________________________________________________________________________#


Write-Output ""
showmenupais
Write-Output ""

while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "0"){
    
    switch($inp){

        0{"Exit"; break}
        default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

        1{
                
            Write-Output "Ejecuto para AR"
            SetRegionUpdateTime "Argentina Standard Time" "ar"
            ChargerStatus
            ChangeName "AR"
            VerifyConnection "54" "ar"
            VerifyCred "54" "AR"
            JoinAD "ar" "54"
            BitLocker "AR"            
            7Zip
            AcrobatReader
            Java
            GoogleChrome
            TeamViewer
            ZoomInstaller
            FusionInventory
            ##########################
            #LibreOffice
            #CertAzul
            #Sabre
            #Avaya
            #WorldSpan
            #eLatam
            #MicroSip
            ############################
            googlerapidresponse
            Antivirus
            VPNRegional
            DellAllUpdate
            ReinicioWin "54"
        }
        2{

            Write-Output "Ejecuto para UY"
            SetRegionUpdateTime "Montevideo Standard Time" "uy"
            ChargerStatus
            ChangeName "UY"
            VerifyConnection "59"
            VerifyCred "59" "UY"
            JoinAD "uy" "59"
            BitLocker "uy"
            VPNRegional
            7Zip
            AcrobatReader
            Java
            GoogleChrome
            TeamViewer
            ZoomInstaller
            FusionInventory
            Sabre
            Avaya
            WorldSpan
            googlerapidresponse
            Antivirus
            DellAllUpdate
            ReinicioWin "59"

        }
        3{

            Write-Output "Ejecuto para BR"

            # Recuerda que debe haber un menu que pregunte si es PCI o NO

            Write-Output ""
            ShowMenuPci
            Write-Output ""

            while(($inpbr = Read-Host -Prompt "Seleccione una Opcion") -ne "0"){
                
                switch ($inpbr) {

                    0{"Exit"; break}
                    default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

                    1{
                        # Cuando es PCI
                        SetRegionUpdateTime "E. South America Standard Time" "br"
                        ChargerStatus
                        ChangeNamePCI "BR"
                        VerifyConnection "55" "br"
                        VerifyCred "55" "BR"
                        JoinAD "br" "55"
                        BitLocker "BR"
                        GoogleChrome
                        VPNRegional
                        LibreOffice
                        TeamViewer
                        FusionInventory
                        CertAzul
                        Sabre
                        Avaya
                        WorldSpan
                        eLatam
                        googlerapidresponse
                        Antivirus
                        DellAllUpdate
                        ReinicioWin "55"
                    }

                    2{
                        # Cuando no es PCI
                        SetRegionUpdateTime "E. South America Standard Time" "br"
                        ChargerStatus
                        ChangeName "BR"
                        VerifyConnection "55" "br"
                        VerifyCred "55" "BR"
                        JoinAD "br" "55"
                        BitLocker "BR"                        
                        7Zip
                        AcrobatReader
                        Java
                        GoogleChrome
                        TeamViewer
                        ZoomInstaller
                        MicroSip
                        FusionInventory
                        Sabre
                        Avaya
                        WorldSpan
                        eLatam
                        VPNRegional
                        googlerapidresponse
                        Antivirus
                        DellAllUpdate
                        ReinicioWin "55"
                    }
                }
            }
            
        }
        4{

            Write-Output "Ejecuto para CO"
            
            # Recuerda que debe haber un menu que pregunte si es PCI o NO

            Write-Output ""
            ShowMenuPci
            Write-Output ""

            while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "0"){

                switch ($inp) {
                    
                    0{"Exit"; break}
                    default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

                    1{
                        SetRegionUpdateTime "SA Pacific Standard Time" "co"
                        ChargerStatus
                        ChangeNamePCI "CO"
                        VerifyConnection "57"
                        VerifyCred "57" "CO"
                        JoinAD "co" "57"
                        BitLocker "CO"
                        GoogleChrome
                        FusionInventory
                        Sabre
                        Avaya
                        WorldSpan
                        googlerapidresponse
                        Antivirus
                        DellAllUpdate
                        ReinicioWin "57"  
                    }

                    2{
                        SetRegionUpdateTime "SA Pacific Standard Time" "co"
                        ChargerStatus
                        ChangeName "CO"
                        VerifyConnection "57"
                        VerifyCred "57" "CO"
                        JoinAD "co" "57"
                        BitLocker "CO"
                        VPNRegional
                        7Zip
                        AcrobatReader
                        Java
                        GoogleChrome
                        TeamViewer
                        ZoomInstaller
                        FusionInventory
                        Sabre
                        Avaya
                        WorldSpan
                        googlerapidresponse
                        Antivirus
                        DellAllUpdate
                        ReinicioWin "57"

                    }
                }

            }
                           
        }
        5{
            Write-Output "Ejecuto para CL"
            SetRegionUpdateTime "Pacific SA Standard Time" "cl"
            ChargerStatus
            ChangeName "CL"
            VerifyConnection "56"
            VerifyCred "56" "CL"
            JoinAD "cl" "56"
            BitLocker "CL"
            VPNRegional
            7Zip
            AcrobatReader
            Java
            GoogleChrome
            TeamViewer
            ZoomInstaller
            FusionInventory
            Sabre
            Avaya
            WorldSpan
            googlerapidresponse
            Antivirus
            DellAllUpdate
            ReinicioWin "56"

        }
        6{
            Write-Output "Ejecuto para MX"
            SetRegionUpdateTime "Central Standard Time (Mexico)" "mx"
            ChargerStatus
            ChangeName "MX"
            VerifyConnection "52"
            VerifyCred "52" "MX"
            JoinAD "mx" "52"
            BitLocker "MX"
            VPNRegional
            7Zip
            AcrobatReader
            Java
            GoogleChrome
            TeamViewer
            ZoomInstaller
            FusionInventory
            Sabre
            Avaya
            WorldSpan
            googlerapidresponse
            Antivirus
            DellAllUpdate
            ReinicioWin "52"

        }
        7{
            Write-Output "Ejecuto para PE"
            SetRegionUpdateTime "SA Pacific Standard Time" "pe"
            ChargerStatus
            ChangeName "PE"
            VerifyConnection "51"
            VerifyCred "51" "PE"
            JoinAD "pe" "51"
            BitLocker "PE"
            VPNRegional
            7Zip
            AcrobatReader
            Java
            GoogleChrome
            TeamViewer
            ZoomInstaller
            FusionInventory
            Sabre
            Avaya
            WorldSpan
            googlerapidresponse
            Antivirus
            DellAllUpdate
            ReinicioWin "51"
        }
            
    }
    Write-Output ""
    showmenupais
    Write-Output ""
} 