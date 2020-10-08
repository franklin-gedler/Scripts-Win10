# _________________________ Deshabilito Windows Update Poronga ____________________________
Stop-Service wuauserv -Force -PassThru
Set-Service wuauserv -StartupType Disabled -PassThru
Get-Service wuauserv | Select-Object *
echo ""
# _________________________________________________________________________________________

# Obtener Serial de equipo
$serial = (gwmi win32_bios).SerialNumber
$newnamecompu = "AR$serial"

#$newnamecompu = "ARSERIAL1"

# __________________ Verificando conexion con Dominio y Validando Credenciales _______________________
echo ""
echo " -------------- Verificando conexion con el Dominio -------------------- "
echo ""

$CAD = $(Test-Connection 10.40.54.1 -Count 2 -Quiet -ErrorAction SilentlyContinue)

while("$CAD" -eq 'False'){
    echo ""
    echo " ############################################################## "
    Write-Host " Error al conectar con ar.infra.d, por favor verificar conexion " -ForegroundColor Red -BackgroundColor Black
    echo " ############################################################## "
    Pause
    $CAD = $(Test-Connection 10.40.54.1 -Count 2 -Quiet -ErrorAction SilentlyContinue)
    echo ""
}
echo ""
echo " ########################## "
Write-Host " Conexion con el Dominio OK " -ForegroundColor Green
echo " ########################## "
echo ""

echo "_________________________________________________________________________________________"

$cred = Get-Credential AR\ -Message "Ingresar Credenciales, AR\User.Name"
echo ""
echo " ------------------ Validando credenciales ingresadas -------------------------- "
echo ""
Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\PS -Destination C:\ -Recurse
Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll"
Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll"
$Very = Get-ADDomain -Server 10.40.54.1 -Credential $cred -ErrorAction SilentlyContinue
while(!$Very){
    echo ""
    echo " ########################################################## "
    Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Yellow -BackgroundColor Black
    echo " ########################################################## "
    echo ""
    $cred = Get-Credential AR\ -Message "Vuelva a escribir sus credenciales, Ej: AR\User.name"
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll"
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll"
    $Very = Get-ADDomain -Server 10.40.54.1 -Credential $cred -ErrorAction SilentlyContinue
}
echo ""
echo " ##############################################################"
Write-Host "              Credenciales OK Alegria Alegria " -ForegroundColor Green
Write-Host "   Credenciales Validadas con el Dominio: $Very " -ForegroundColor Green
echo " ############################################################## "
echo ""


# ____________________________________ Binding AD ________________________________________
#mkdir C:\PS\ADPoSH

#Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll"
#Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll"
$consul = Get-ADComputer -LDAPFilter "(cn=$newnamecompu)" -SearchScope Subtree -Server ar.infra.d -Credential $cred | Select-Object -ExpandProperty DistinguishedName
if ($consul){
    echo ""
    echo "---------- Equipo existe, se procede a borrar -----------"
    Remove-ADObject -Identity "$consul" -Credential $cred -Server ar.infra.d -Confirm:$False -Verbose
    Start-Sleep -Seconds 10
    echo "Eliminado . . ."
}
#Remove-Module -Name ActiveDirectory
#Remove-Item C:\PS -Recurse -Force
echo ""
echo " ---------------- Enlazando equipo al AD ------------------- "
$Binding = (Add-Computer -DomainName ar.infra.d -NewName $newnamecompu -Force -passthru -verbose -Credential $cred).HasSucceeded

if("$Binding" -eq "True"){

    echo ""
    echo " ######################################################## "
    Write-Host " Se agrego al equipo $newnamecompu al Dominio AR.INFRA.D " -ForegroundColor Green -BackgroundColor Black
    echo " ######################################################## "
    echo ""

}else{

    echo ""
    echo " ################################################################# "
    Write-Host " Error a enlazar el equipo al AD, Por Favor realizarlo Manualmente " -ForegroundColor Red -BackgroundColor Black
    echo " ################################################################# "
    echo ""

}

#Add-Computer -DomainName ar.infra.d -NewName $newnamecompu -Force -passthru -verbose -Credential $cred
# _________________________________________________________________________________________

# _____________________ Habilito el bitlocker y envio el ID y pass al NAS _________________
echo ""
echo " ------- Verificando si el TPM esta Activo -------- "
$tpmpresent = (Get-Tpm).TpmPresent
$tpmready = (Get-Tpm).TpmReady

if("$tpmpresent" -eq "False" -And "$tpmready" -eq "False"){
    echo ""
    echo " ####################################################################################### "
    Write-Host " ERROR: TPM NO ACTIVO, POR FAVOR VERIFICAR EN EL BIOS Y ACTIVAR EL BITLOCKER MANUALMENTE " -ForegroundColor Red -BackgroundColor Black
    echo " ####################################################################################### "
    echo ""

}else {
    Write-Host " TPM Activo " -ForegroundColor Green -BackgroundColor Black
    echo ""
    Write-Host " -------------- Habilitando Bitlocker -------------- "
    Enable-BitLocker -MountPoint C: -RecoveryPasswordProtector

    (Get-BitLockerVolume -mount c).keyprotector | select $newnamecompu, KeyProtectorId, RecoveryPassword > C:\Users\admindesp\Desktop\$newnamecompu.txt
    #(Get-BitLockerVolume -mount c).keyprotector[1] | Select-Object $newnamecompu, KeyProtectorId, RecoveryPassword > C:\Users\admindesp\Desktop\$newnamecompu.txt

    echo " ----------- Verificando conexion al NAS ------------"
    $nas = Test-Connection 10.40.54.52 -Count 2 -Quiet
    if ("$nas" -eq 'False'){
        echo "Problemas para conectarnos al NAS, se creo archivo $newnamecompu en el escritorio con el ID y PASS Bitlocker"
    }else {
        Write-Host " Conexion con el NAS OK " -ForegroundColor Green -BackgroundColor Black
        echo " -------- Copiando ID y PASS al NAS --------- "
        New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles" -Credential $cred
        Copy-Item -LiteralPath C:\Users\admindesp\Desktop\$newnamecompu.txt -Destination Z:\
    }

}
# __________________________________________________________________________________________

# _____________________ Instalando TeamViewerHost con Politicas ___________________________
Start-Process msiexec -ArgumentList '/I "C:\WINDOWS\setup\scripts\TeamViewer_Host.msi" /qn SETTINGSFILE="C:\WINDOWS\setup\scripts\politicas.reg"' -Wait
# _________________________________________________________________________________________

# ______________________________ instalando AV  ____________________________________________
echo "--------------- Instalando AV -----------------------"
Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\McAfeeSmartInstall.exe -ArgumentList '-s'
#Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\McAfeeSmartInstall.exe -Destination C:\Users\admindesp\Desktop\
echo " ------ Instalado -------"
# __________________________________________________________________________________________

# _____________________________ Deploy Fusioninventory _____________________________________
echo ""
echo "------------- Instalando FusionInventory -------------"
#& "C:\WINDOWS\setup\scripts\fusioninventory-agent-deployment.vbs"
Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\fusioninventory-agent-deployment.vbs
echo " ------ Instalado -------"
# __________________________________________________________________________________________

echo ""
echo "------------------------------------"
Write-Host "         SE VA A REINICIAR          " -ForegroundColor Yellow -BackgroundColor Black
echo "------------------------------------"
$p = ConvertTo-SecureString "*+54#$serial*" -AsPlainText -Force
$u = (Get-LocalUser).Name[0]
Set-LocalUser -Name $u -Password $p -PasswordNeverExpires 1
Pause

# ________________ Habilito el Windows Update Poronga ______________________________________
Set-Service wuauserv -StartupType Manual -PassThru
Start-Service wuauserv -PassThru
Get-Service wuauserv | Select-Object *

# _______________ Elimino todo despues de ejecutar _____________________________
echo {
Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
#Remove-Item -LiteralPath C:\PS -Recurse -Force
} > C:\Windows\Setup\scripts\AutoDelete.ps1
& C:\Windows\Setup\scripts\AutoDelete.ps1
Restart-Computer -Force
exit






# ----------------------------------- Solo notas de varios comandos ------------------------------------------

#New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles" -Credential $cred
#Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\$newnamecompu.txt -Destination Z:\
#Copy-Item -LiteralPath C:\Users\admindesp\Desktop\$newnamecompu.txt -Destination Z:\

#Agregar equipo a Dominio AR (Puedes agregar -passthru -verbose para ver la salida del comando -Restart)
#Add-Computer -DomainName ar.infra.d -ComputerName ARDESPEGAR -NewName $newnamecompu -Force -passthru -verbose -Credential $cred

# Obtener Serial del equipo
#$var1 = $(wmic bios get serialnumber)
#$serial = $var1.split('')[4]
#$newnamecompu = "AR$serial"

#Import-Module Enable-Bitlocker

#habilitar ID y clave de Bitloker
#Add-BitLockerKeyProtector -MountPoint c: -RecoveryPasswordProtector

# -------------- Backup drivers -------------------------------------
#mkdir C:\Users\admindesp\Desktop\DriverBackup
#Export-WindowsDriver -Online -Destination C:\Users\admindesp\Desktop\DriverBackup
# -------------- Retore drivers -------------------------------------
#Dism /online /Add-Driver /Driver:C:\Users\admindesp\Desktop\DriverBackup /Recurse

# -------------- pasar credenciales de texto plano a credenciales seguras ---------------------
#$username = 'AR\UserName'
#$password = 'password'
#$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
#$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword
# --------------- Pasar Password de segura a texto plano ------------------------------------
#[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($aca-va-la-variable-donde-esta-la-pass-encriptada))
#----------------------------------------------------------------------------------------------

# Para remover los id y pass de bitlocker
#$BLV = Get-BitLockerVolume -MountPoint "C:"
#Remove-BitlockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId

# Renombrar equipo
#Rename-Computer -ComputerName ARDESPEGAR -NewName $newnamecompu -Force

# habilitar ejecutar script en powershell esto lo tengo que ejecutar como administrador
#Set-ExecutionPolicy Unrestricted -Force

#agregar valores al registro
#$RegPath = 'SOFTWARE\Policies\Microsoft\FVE'
#$RegName

# Muevo el file con el ID y passRecovery al NAS
# ver si debes importar el modulo de BitsTransfer 
#Import-Module BitsTransfer
#Start-BitsTransfer -Source C:\Users\admindesp\Desktop\$newnamecompu.csv -Destination \\10.40.54.52\Soporte\BitLockerFiles -Credential $cred
#Start-BitsTransfer 'C:\WINDOWS\setup\scripts\$newnamecompu.txt' '\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles' -TransferType Upload -Credential $cred 


#(Get-BitLockerVolume -mount c).keyprotector | select $newnamecompu, keyprotectorId, RecoveryPassword | ConvertTo-Csv | Out-File -Append -FilePath "C:\WINDOWS\setup\scripts\IdPassBitlocker.csv"
#$var1 = $(cat C:\WINDOWS\setup\scripts\IdPassBitlocker.csv)
#$var2 = $var1.split('')[4]
#$id = $var2.split(',')[1]
#$pass = $var2.split(',')[2]
#echo "ID: $id |------------| PASS: $pass" > C:\WINDOWS\setup\scripts\$newnamecompu.txt
#echo "ID: $id |------------| PASS: $pass" > C:\Users\admindesp\Desktop\$newnamecompu.txt