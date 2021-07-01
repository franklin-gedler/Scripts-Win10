function DownloadModules {
    param (
        $1
    )
    $token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    $headers = @{Authorization = "token $($token)"}
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $headers `
        -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/$1.ps1" `
        -UseBasicParsing -OutFile "$PSScriptRoot\$1.ps1"
}

DownloadModules Firma

# Mi firma ##################
. C:\PrepareWin10\Firma.ps1 #
#############################

$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $currentdirectory
(Get-Location).Path
Pause
###########################################################################################




Remove-Item -LiteralPath C:\PS -Recurse -Force -ErrorAction SilentlyContinue
Write-Output ""
Write-Output " ================================================ "
Write-Host "       Verificando conexion con el Dominio        " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ================================================ "

$Domain = 'ar.infra.d'

$CAD = $(Test-Connection $Domain -Count 2 -Quiet -ErrorAction SilentlyContinue)

while("$CAD" -eq 'False'){
    Write-Output ""
    Write-Output " ############################################################## "
    Write-Host " Error al conectar con $Domain, por favor verificar conexion " -ForegroundColor Red -BackgroundColor Black
    Write-Output " ############################################################## "
    Pause
    $CAD = $(Test-Connection $Domain -Count 2 -Quiet -ErrorAction SilentlyContinue)
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
Copy-Item -LiteralPath PS -Destination C:\ -Recurse
Start-Sleep -Seconds 30
Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
$Very = Get-ADDomain -Server $Domain -Credential $cred -InformationAction SilentlyContinue
while(!$Very){
    Write-Output ""
    Write-Output " ########################################################## "
    Write-Host " Error con credenciales, Vuelva a escribir sus credenciales " -ForegroundColor Red -BackgroundColor Black
    Write-Output " ########################################################## "
    Write-Output ""
    $cred = Get-Credential AR\ -Message "Vuelva a escribir sus credenciales, Ej: AR\User.name"
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
    $Very = Get-ADDomain -Server $Domain -Credential $cred -InformationAction SilentlyContinue
}
Write-Output ""
Write-Output " ##############################################################"
Write-Host "              Credenciales OK Alegria Alegria " -ForegroundColor Green -BackgroundColor Black
Write-Host "   Credenciales Validadas con el Dominio: $Very " -ForegroundColor Green -BackgroundColor Black
Write-Output " ############################################################## "

#$File = "Equipos.txt"
$Content = [System.IO.File]::ReadAllText("$currentdirectory\Equipos.txt")
$Content = $Content.Trim()
[System.IO.File]::WriteAllText("$currentdirectory\Equipos.txt", $Content)
#$Content = [System.IO.File]::ReadAllText("$currentdirectory\Equipos.txt")

Write-Output ""
Write-Output " ########################### "
Write-Host "        Procesando . . .     " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ########################### "

Foreach ($Computer in (Get-Content $currentdirectory\Equipos.txt ))
{
    $consul = Get-ADComputer -LDAPFilter "(cn=*$Computer)" -SearchScope Subtree -Server $Domain -Credential $cred | Select-Object -ExpandProperty DistinguishedName
    if ($consul){
        Write-Output "$consul ---->>>> Borrado pa la verga!!  " >> Encontrados.txt
        Remove-ADObject -Identity "$consul" -Credential $cred -Server $Domain -Confirm:$False -Verbose
    }else{
        Write-Output "$Computer ------>>>> No encontrado!!! " >> NoEncontrados.txt
    }

}

Pause

###########################################################################################