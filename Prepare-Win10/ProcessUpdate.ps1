Write-Output " _____________________________________________________________________________________________________"

Write-Output ""
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output " _____________________________________________________________________________________________________"
#echo ""
# _________________________ Deshabilito Windows Update Poronga ____________________________
#Stop-Service wuauserv -Force -PassThru
#Set-Service wuauserv -StartupType Disabled -PassThru
#Get-Service wuauserv | Select-Object *
#echo ""
# _________________________________________________________________________________________

# Obtener Serial de equipo
#$SCompu = (gwmi win32_bios).SerialNumber

$SCompu = (Get-WmiObject win32_bios).SerialNumber
$NCompu = "AR$SCompu"
Write-Output "Nuevo nombre a Setear: $NCompu"
while (!$NCompu) {
    $SCompu = (Get-WmiObject win32_bios).SerialNumber
    $NCompu = "AR$SCompu"
    Write-Output "Nuevo nombre a Setear: $NCompu"
}

#$NCompu = "AR1234567"

#Rename-Computer -NewName $NCompu -force
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" "ComputerName" "$NCompu"
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName" "$NCompu"
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "Hostname" "$NCompu"
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "NV Hostname" "$NCompu"
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "COMPUTERNAME" "$NCompu"


#Set-ItemProperty -Path "HKCU:\Volatile Environment" "LOGONSERVER" "\\$NCompu"
#Set-ItemProperty -Path "HKCU:\Volatile Environment" "USERDOMAIN" "$NCompu"
#Set-ItemProperty -Path "HKCU:\Volatile Environment" "USERDOMAIN_ROAMINGPROFILE" "$NCompu"


#Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "DefaultDomainName" -value $ComputerName
#Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "DefaultDomainName" -value $ComputerName


# __________________ Verificando conexion con Dominio y Validando Credenciales _______________________
Write-Output ""
Write-Output " ================================================ "
Write-Host "       Verificando conexion con el Dominio        " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ================================================ "

$CAD = $(Test-Connection 10.40.54.1 -Count 2 -Quiet -ErrorAction SilentlyContinue)

while("$CAD" -eq 'False'){
    Write-Output ""
    Write-Output " ############################################################## "
    Write-Host " Error al conectar con ar.infra.d, por favor verificar conexion " -ForegroundColor Red -BackgroundColor Black
    Write-Output " ############################################################## "
    Pause
    $CAD = $(Test-Connection 10.40.54.1 -Count 2 -Quiet -ErrorAction SilentlyContinue)
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

$cred = Get-Credential AR\ -Message "Ingresar Credenciales, AR\User.Name"
Write-Output " ============================================== "
Write-Host "       Validando credenciales ingresadas        " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ============================================== "
Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\PS -Destination C:\ -Recurse
Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
$Very = Get-ADDomain -Server 10.40.54.1 -Credential $cred -ErrorAction SilentlyContinue
while(!$Very){
    Write-Output ""
    Write-Output " ########################################################## "
    Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
    Write-Output " ########################################################## "
    Write-Output ""
    $cred = Get-Credential AR\ -Message "Vuelva a escribir sus credenciales, Ej: AR\User.name"
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


# _____________________ Habilito el bitlocker y envio el ID y pass al NAS _________________
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
        New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles" -Credential $cred
        Copy-Item -LiteralPath C:\Users\admindesp\Desktop\$NCompu.txt -Destination Z:\
    }

}
Write-Output ""
Write-Output "_________________________________________________________________________________________"
Write-Output ""

# ____________________________________ Binding AD ________________________________________
#mkdir C:\PS\ADPoSH

#Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll"
#Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll"
$consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" -SearchScope Subtree -Server ar.infra.d -Credential $cred | Select-Object -ExpandProperty DistinguishedName
if ($consul){
    Write-Output " =============================================== "
    Write-Host "   Equipo existe en el AD, se procede a borrar   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =============================================== "
    Remove-ADObject -Identity "$consul" -Credential $cred -Server ar.infra.d -Confirm:$False -verbose
    Start-Sleep -Seconds 10
    Write-Output ""
    Write-Output " ############# "
    Write-Host "   Eliminado   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############# "
}
#Remove-Module -Name ActiveDirectory
#Remove-Item C:\PS -Recurse -Force

Write-Output ""
Write-Output " ==================================== "
Write-Host "        Enlazando equipo al AD        " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ==================================== "

Rename-Computer -NewName $NCompu -WarningAction SilentlyContinue
Start-Sleep -Seconds 5

#$Binding = Add-Computer -NewName "$NCompu" -DomainName ar.infra.d -Force -Credential $cred -PassThru

$Binding = Add-Computer -DomainName ar.infra.d -Credential $cred -Force -Options JoinWithNewName,AccountCreate -WarningAction SilentlyContinue -PassThru

if( $Binding.HasSucceeded -eq $true ){
    
    Write-Output ""
    Write-Output " ######################################################### "
    Write-Host "  Se agrego al equipo $NCompu al Dominio AR.INFRA.D  " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######################################################### "

}else{
    
    Write-Output ""
    Write-Output " ################################################################### "
    Write-Host "  Error a enlazar el equipo al AD, Por Favor realizarlo Manualmente  " -ForegroundColor Red -BackgroundColor Black
    Write-Output " ################################################################### "
    Write-Output ""

}

#Add-Computer -DomainName ar.infra.d -Force -passthru -verbose -Credential $cred
# _________________________________________________________________________________________

Write-Output ""
Write-Output "_________________________________________________________________________________________"
Write-Output ""

# _____________________ Instalando TeamViewerHost con Politicas ___________________________
Write-Output " =========================================== "
Write-Host "   Instalando TeamViewerHost con Politicas   " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " =========================================== "
Start-Process msiexec -ArgumentList '/I "C:\WINDOWS\setup\scripts\TeamViewer_Host.msi" /qn SETTINGSFILE="C:\WINDOWS\setup\scripts\politicas.reg"' -Wait
Write-Output ""
Write-Output " ############# "
Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
Write-Output " ############# "

# _________________________________________________________________________________________

Write-Output ""
Write-Output "_________________________________________________________________________________________"
Write-Output ""

# ______________________________ instalando AV  ____________________________________________
Write-Output " ==================== "
Write-Host "    Instalando AV     " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ==================== "

#Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\McAfeeSmartInstall.exe -ArgumentList '-s'
Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\Instalador-Mcafee.exe -ArgumentList '/Install=Agent /ForceInstall /Silent'
#Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\McAfeeSmartInstall.exe -Destination C:\Users\admindesp\Desktop\
Write-Output ""
Write-Output " ############# "
Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
Write-Output " ############# "
# __________________________________________________________________________________________

Write-Output ""
Write-Output "_________________________________________________________________________________________"
Write-Output ""

# _____________________________ Deploy Fusioninventory _____________________________________
Write-Output " ================================= "
Write-Host "    Instalando FusionInventory     " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ================================= "
#& "C:\WINDOWS\setup\scripts\fusioninventory-agent-deployment.vbs"
Start-Process -Wait -FilePath C:\WINDOWS\setup\scripts\fusioninventory-agent-deployment.vbs
Write-Output ""
Write-Output " ############# "
Write-Host "   Instalado   " -ForegroundColor Green -BackgroundColor Black
Write-Output " ############# "
# __________________________________________________________________________________________

Write-Output ""
Write-Output "_________________________________________________________________________________________"
Write-Output ""

Write-Output "------------------------------------"
Write-Host "         SE VA A REINICIAR          " -ForegroundColor Yellow -BackgroundColor Black
Write-Output "------------------------------------"
$p = ConvertTo-SecureString "*+54#$SCompu*" -AsPlainText -Force
$u = (Get-LocalUser).Name[0]
Set-LocalUser -Name $u -Password $p -PasswordNeverExpires 1
Pause

# ________________ Habilito el Windows Update Poronga ______________________________________
Set-Service wuauserv -StartupType Manual -PassThru
Start-Service wuauserv -PassThru
Get-Service wuauserv | Select-Object *

# _______________ Elimino todo despues de ejecutar _____________________________
Write-Output {
Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
#Remove-Item -LiteralPath C:\PS -Recurse -Force
} > C:\Windows\Setup\scripts\AutoDelete.ps1
#& C:\Windows\Setup\scripts\AutoDelete.ps1
Start-Process -Wait PowerShell.exe -ArgumentList "& C:\Windows\Setup\scripts\AutoDelete.ps1"
Restart-Computer -Force
exit






# ----------------------------------- Solo notas de varios comandos ------------------------------------------

#New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles" -Credential $cred
#Copy-Item -LiteralPath C:\WINDOWS\setup\scripts\$NCompu.txt -Destination Z:\
#Copy-Item -LiteralPath C:\Users\admindesp\Desktop\$NCompu.txt -Destination Z:\

#Agregar equipo a Dominio AR (Puedes agregar -passthru -verbose para ver la salida del comando -Restart)
#Add-Computer -DomainName ar.infra.d -ComputerName ARDESPEGAR -NewName $NCompu -Force -passthru -verbose -Credential $cred

# Obtener Serial del equipo
#$var1 = $(wmic bios get serialnumber)
#$SCompu = $var1.split('')[4]
#$NCompu = "AR$SCompu"

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
#Rename-Computer -ComputerName ARDESPEGAR -NewName $NCompu -Force

# habilitar ejecutar script en powershell esto lo tengo que ejecutar como administrador
#Set-ExecutionPolicy Unrestricted -Force

#agregar valores al registro
#$RegPath = 'SOFTWARE\Policies\Microsoft\FVE'
#$RegName

# Muevo el file con el ID y passRecovery al NAS
# ver si debes importar el modulo de BitsTransfer 
#Import-Module BitsTransfer
#Start-BitsTransfer -Source C:\Users\admindesp\Desktop\$NCompu.csv -Destination \\10.40.54.52\Soporte\BitLockerFiles -Credential $cred
#Start-BitsTransfer 'C:\WINDOWS\setup\scripts\$NCompu.txt' '\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles' -TransferType Upload -Credential $cred 


#(Get-BitLockerVolume -mount c).keyprotector | select $NCompu, keyprotectorId, RecoveryPassword | ConvertTo-Csv | Out-File -Append -FilePath "C:\WINDOWS\setup\scripts\IdPassBitlocker.csv"
#$var1 = $(cat C:\WINDOWS\setup\scripts\IdPassBitlocker.csv)
#$var2 = $var1.split('')[4]
#$id = $var2.split(',')[1]
#$pass = $var2.split(',')[2]
#echo "ID: $id |------------| PASS: $pass" > C:\WINDOWS\setup\scripts\$NCompu.txt
#echo "ID: $id |------------| PASS: $pass" > C:\Users\admindesp\Desktop\$NCompu.txt