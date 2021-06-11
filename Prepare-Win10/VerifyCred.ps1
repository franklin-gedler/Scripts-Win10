function VerifyCred {

    param (
        $1,$2
    )

    # $1 = Pais
    # $2 = CodigoPais

    Write-Output ""
    Write-Output " ================================================ "
    Write-Host "       Verificando conexion con el Dominio        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================================ "

    $CAD = $(Test-Connection "10.40.$2.1" -Count 2 -Quiet -ErrorAction SilentlyContinue)

    while("$CAD" -eq 'False'){
        Write-Output ""
        Write-Output " ############################################################## "
        Write-Host " Error al conectar con $1.INFRA.D, por favor verificar conexion " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ############################################################## "
        Pause
        $CAD = $(Test-Connection "10.40.$2.1" -Count 2 -Quiet -ErrorAction SilentlyContinue)
        Write-Output ""
    }
    Write-Output ""
    Write-Output " ########################## "
    Write-Host " Conexion con el Dominio OK " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ########################## "

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""

    $Global:cred = Get-Credential $1\ -Message "Ingresar Credenciales, $1\Nombre.Apellido"
    Write-Output " ============================================== "
    Write-Host "       Validando credenciales ingresadas        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================================== "
    Copy-Item -Path $PSScriptRoot\PS -Destination C:\ -Recurse -force
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
    $Global:Very = Get-ADDomain -Server "10.40.$2.1" -Credential $cred -ErrorAction SilentlyContinue
    while(!$Very){
        Write-Output ""
        Write-Output " ########################################################## "
        Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ########################################################## "
        Write-Output ""
        $Global:cred = Get-Credential $1\ -Message "Vuelva a escribir sus credenciales, Ej: $1\Nombre.Apellido"
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
        Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
        $Global:Very = Get-ADDomain -Server "10.40.$2.1" -Credential $cred -ErrorAction SilentlyContinue
    }
    Write-Output ""
    Write-Output " ##############################################################"
    Write-Host "              Credenciales OK Alegria Alegria " -ForegroundColor Green -BackgroundColor Black
    Write-Host "   Credenciales Validadas con el Dominio: $Very " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ############################################################## "

    $cred | Export-Clixml -Path C:\PrepareWin10\CredSoporte_${env:USERNAME}_${env:COMPUTERNAME}.xml
    Pause
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}