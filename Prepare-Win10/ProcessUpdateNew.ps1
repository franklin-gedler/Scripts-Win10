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
    $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    $Global:NCompu = "AR$SCompu"
    #Write-Output "Nuevo nombre a Setear: $NCompu"
    while (!$NCompu) {
        $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
        $Global:NCompu = "AR$SCompu"
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
    Set-Location $PSScriptRoot
    Start-Process -Wait msiexec -ArgumentList '/i "E84.00_CheckPointVPN.msi" /quiet /norestart'
}

function 7Zip {
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath 7z1900-x64.exe -ArgumentList '/S'
}

function AcrobatReader {
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath AcroRdrDC1902120049_es_ES.exe -ArgumentList '/sAll'
}
function Java {
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath java.exe -ArgumentList '/s'
}

function GoogleChrome {
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath ChromeStandaloneSetup64.exe -ArgumentList '/silent /install'
}

function Office2016 {
    Set-Location $PSScriptRoot
    Start-Process -Wait -FilePath Office2016x64\setup.exe -ArgumentList '/config standard.ww\config.xml'
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
            ChangeName
            VerifyConnection "ar"
            VerifyCred "ar"
            JoinAD "ar"
            VPNRegional
            7Zip
            AcrobatReader
            Java
            GoogleChrome
            
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