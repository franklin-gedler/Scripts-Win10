#------ Este Bloque le dice a Windows que no se suspenda ni apague la pantalla mientras el script se ejecuta--------
$code=@' 
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
  public static extern void SetThreadExecutionState(uint esFlags);
'@

$ste = Add-Type -memberDefinition $code -name System -namespace Win32 -passThru
$ES_CONTINUOUS = [uint32]"0x80000000" 
#$ES_AWAYMODE_REQUIRED = [uint32]"0x00000040" 
$ES_DISPLAY_REQUIRED = [uint32]"0x00000002"
$ES_SYSTEM_REQUIRED = [uint32]"0x00000001"

$ste::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED)

#$ste::SetThreadExecutionState($ES_CONTINUOUS)

#-------------------------------------------------------------------------------------------------------------------

function DownloadModules {
    param (
        $1
    )
    $token = "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"
    $headers = @{Authorization = "token $($token)"}
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $headers `
        -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/$1.ps1" `
        -UseBasicParsing -OutFile "$PSScriptRoot\$1.ps1"
}

DownloadModules Firma

# Mi firma ##################
. $PSScriptRoot\Firma.ps1 #
#############################

#$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
#Set-Location $currentdirectory
Set-Location $PSScriptRoot
(Get-Location).Path
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
$Content = [System.IO.File]::ReadAllText("$PSScriptRoot\Equipos.txt")
$Content = $Content.Trim()
[System.IO.File]::WriteAllText("$PSScriptRoot\Equipos.txt", $Content)
#$Content = [System.IO.File]::ReadAllText("$PSScriptRoot\Equipos.txt")

Write-Output ""
Write-Output " ########################### "
Write-Host "        Procesando . . .     " -ForegroundColor Yellow -BackgroundColor Black
Write-Output " ########################### "

Foreach ($Computer in (Get-Content $PSScriptRoot\Equipos.txt ))
{
    $consul = Get-ADComputer -LDAPFilter "(cn=*$Computer*)" -SearchScope Subtree -Server $Domain -Credential $cred | Select-Object -ExpandProperty DistinguishedName
    if ($consul){
        Write-Output "$consul ---->>>> Borrado pa la verga!!  " >> Encontrados.txt
        Remove-ADObject -Identity "$consul" -Credential $cred -Server $Domain -Confirm:$False -Verbose
        timeout /t 30
    }else{
        Write-Output "$Computer ------>>>> No encontrado!!! " >> NoEncontrados.txt
    }

}

###########################################################################################