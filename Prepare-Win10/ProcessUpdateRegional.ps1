Write-Output " _____________________________________________________________________________________________________"

Write-Output ""
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output " _____________________________________________________________________________________________________"

# Carga de Funciones
#& $PSScriptRoot\functions.ps1

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
    Write-Output ""
}

function ChangeName {
    param (
        [String]$1
    )
    $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    $Global:NCompu = "$1$SCompu"
    #Write-Output "Nuevo nombre a Setear: $NCompu"
    while (!$NCompu) {
        $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
        $Global:NCompu = "$1$SCompu"
        #Write-Output "Nuevo nombre a Setear: $NCompu"
    }
}

function VerifyConnection {
    param (
        [String]$1
    )

    Write-Output ""
    Write-Output " ================================================ "
    Write-Host "       Verificando conexion con el Dominio        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================================ "

    $CAD = $(Test-Connection "$1.infra.d" -Count 2 -Quiet -ErrorAction SilentlyContinue)

    while("$CAD" -eq 'False'){
        Write-Output ""
        Write-Output " ############################################################## "
        Write-Host " Error al conectar con ar.infra.d, por favor verificar conexion " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ############################################################## "
        Pause
        $CAD = $(Test-Connection "$1.infra.d" -Count 2 -Quiet -ErrorAction SilentlyContinue)
        Write-Output ""
    }
    Write-Output ""
    Write-Output " ########################## "
    Write-Host " Conexion con el Dominio OK " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ########################## "
    Write-Output ""

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""   
}

function VerifyCred {

    param (
        [String]$1
    )

    $Global:cred = Get-Credential AR\ -Message "Ingresar Credenciales, AR\Nombre.Apellido"
    Write-Output " ============================================== "
    Write-Host "       Validando credenciales ingresadas        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================================== "
    Copy-Item -Path $PSScriptRoot\PS -Destination C:\ -Recurse -force
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
    $Global:Very = Get-ADDomain -Server "$1.infra.d" -Credential $cred -ErrorAction SilentlyContinue
    while(!$Very){
        Write-Output ""
        Write-Output " ########################################################## "
        Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ########################################################## "
        Write-Output ""
        $Global:cred = Get-Credential AR\ -Message "Vuelva a escribir sus credenciales, Ej: AR\Nombre.Apellido"
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
        $Global:Very = Get-ADDomain -Server "$1.infra.d" -Credential $cred -ErrorAction SilentlyContinue
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
        [String]$1
    )

    $Global:consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" -SearchScope Subtree -Server "$1.infra.d" -Credential $cred | Select-Object -ExpandProperty DistinguishedName
    if ($consul){
        Write-Output " =============================================== "
        Write-Host "   Equipo existe en el AD, se procede a borrar   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " =============================================== "
        Remove-ADObject -Identity "$consul" -Credential $cred -Server "$1.infra.d" -Confirm:$False -verbose
        Start-Sleep -Seconds 10
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

    $Global:Binding = Add-Computer -DomainName "$1.infra.d" -Credential $cred -Force -Options JoinWithNewName,AccountCreate -WarningAction SilentlyContinue -PassThru           
    
    #$Binding = Add-Computer -NewName "$NCompu" -DomainName ar.infra.d -Force -Credential $cred -PassThru
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

}

function VPNRegional {
    Write-Output " =========================== "
    Write-Host "   Instalando VPN Regional   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =========================== "
    Set-Location $PSScriptRoot
    Start-Process -Wait msiexec -ArgumentList '/i "E84.00_CheckPointVPN.msi" /quiet /norestart'
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
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath 7z1900-x64.exe -ArgumentList '/S'
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
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath AcroRdrDC1902120049_es_ES.exe -ArgumentList '/sAll'
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
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath java.exe -ArgumentList '/s'
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
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath ChromeStandaloneSetup64.exe -ArgumentList '/silent /install'
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
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath Office2016x64\setup.exe -ArgumentList '/config standard.ww\config.xml'
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
    Set-Location $PSScriptRoot
    Start-Process msiexec -ArgumentList '/I "TeamViewer_Host.msi" /qn SETTINGSFILE="politicas.reg"' -Wait
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
    Set-Location $PSScriptRoot
    #Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\McAfeeSmartInstall.exe -ArgumentList '-s'
    Start-Process -Wait -FilePath Instalador-Mcafee.exe -ArgumentList '/Install=Agent /ForceInstall /Silent'
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
    Set-Location $PSScriptRoot
    #& "C:\WINDOWS\setup\scripts\fusioninventory-agent-deployment.vbs"
    Start-Process -Wait -FilePath fusioninventory-agent-deployment.vbs
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
        Enable-BitLocker -MountPoint C: -RecoveryPasswordProtector

        (Get-BitLockerVolume -mount c).keyprotector | Select-Object $NCompu, KeyProtectorId, RecoveryPassword > C:\Users\admindesp\Desktop\$NCompu.txt
        #(Get-BitLockerVolume -mount c).keyprotector[1] | Select-Object $NCompu, KeyProtectorId, RecoveryPassword > C:\Users\admindesp\Desktop\$NCompu.txt

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

#___________________________________________________________________________________________#

Write-Output ""
showmenupais
Write-Output ""

while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "0"){
    
    switch($inp){

        0{"Exit"; break}
        default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccion una de las disponibles"}

        1{
                
            Write-Output "Ejecuto para AR"
            ChangeName "AR"
            VerifyConnection "ar"
            VerifyCred "ar"
            JoinAD "ar"
            BitLocker "AR"
            VPNRegional
            7Zip
            AcrobatReader
            Java
            GoogleChrome
            TeamViewer
            Antivirus
            FusionInventory
        }
        2{

            Write-Output "Ejecuto para UY"
            VerifyConnection "uy"

        }
        3{

            Write-Output "Ejecuto para BR"
            VerifyConnection "br"

        }
        4{

            Write-Output "Ejecuto para CO"
            VerifyConnection "co"
                
        }
        5{
            Write-Output "Ejecuto para CL"
            VerifyConnection "cl"

        }
        6{
            Write-Output "Ejecuto para MX"
            VerifyConnection "mx"

        }
        7{
            Write-Output "Ejecuto para PE"
            VerifyConnection "pe"
        }
            
    }
    Write-Output ""
    showmenupais
    Write-Output ""
} 