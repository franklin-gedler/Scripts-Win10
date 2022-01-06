function VerifyCred {

    param (
        $1,$2
    )

    # $1 = Pais
    # $2 = CodigoPais
    #Write-Output "YO $env:USERNAME ejecuto el scri"
    
    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################

    $Domain = "$1.infra.d"
    $Domain = $Domain.ToLower()

    # Verifico si esta conectado al AD
    . C:\PrepareWin10\ValidateConnectAD.ps1
    ValidateConnectAD $1 $2

    # Solicito Credenciales
    $cred = Get-Credential $1\ -Message "Ingresar Credenciales, $1\Nombre.Apellido"

    Write-Output " ============================================== "
    Write-Host "       Validando credenciales ingresadas        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================================== "
    Copy-Item -Path $PSScriptRoot\PS -Destination C:\ -Recurse -force
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
    #$Very = Get-ADDomain -Server "10.40.$2.1" -Credential $cred -ErrorAction SilentlyContinue
    $Very = Get-ADDomain -Server $Domain -Credential $cred -ErrorAction SilentlyContinue
    while(!$Very){
        Write-Output ""
        Write-Output " ########################################################## "
        Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ########################################################## "
        Write-Output ""
        $cred = Get-Credential $1\ -Message "Vuelva a escribir sus credenciales, Ej: $1\Nombre.Apellido"
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
        #$Very = Get-ADDomain -Server "10.40.$2.1" -Credential $cred -ErrorAction SilentlyContinue
        $Very = Get-ADDomain -Server $Domain -Credential $cred -ErrorAction SilentlyContinue
    }
    Write-Output ""
    Write-Output " ##############################################################"
    Write-Host "              Credenciales OK Alegria Alegria " -ForegroundColor Green -BackgroundColor Black
    Write-Host "   Credenciales Validadas con el Dominio: $Very " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############################################################## "

    #$cred | Export-Clixml -Path "C:\PrepareWin10\CredSoporte_${env:USERNAME}_${env:COMPUTERNAME}.xml"

    # Creo la llave
    $Key = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | out-file C:\PrepareWin10\aes.key

    # Exporto Usuario y Contraseña
    ($cred).UserName | Add-Content C:\PrepareWin10\Ucred.txt
    ($cred).Password | ConvertFrom-SecureString -Key (Get-Content C:\PrepareWin10\aes.key) | Set-Content C:\PrepareWin10\Pcred.txt

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
    Start-Sleep -Seconds 10
    Return
}
