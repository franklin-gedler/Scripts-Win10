function ValidateConnectAD {
    param (
        $1,$2
    )

    # $1 = Pais
    # $2 = CodigoPais
    $Domain = "$1.infra.d"
    $Domain = $Domain.ToLower()

    #Write-Output "YO $env:USERNAME ejecuto el script"
    Write-Output ""
    Write-Output " ================================================ "
    Write-Host "       Verificando conexion con el Dominio        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ================================================ "

    #$CAD = $(Test-Connection "10.40.$2.1" -Count 2 -Quiet -ErrorAction SilentlyContinue)

    $CAD = $(Test-Connection $Domain -Count 2 -Quiet -ErrorAction SilentlyContinue)

    while("$CAD" -eq 'False'){
        Write-Output ""
        Write-Output " ############################################################## "
        Write-Host " Error al conectar con $Domain, por favor verificar conexion " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ############################################################## "
        Pause
        #$CAD = $(Test-Connection "10.40.$2.1" -Count 2 -Quiet -ErrorAction SilentlyContinue)
        $CAD = $(Test-Connection $Domain -Count 2 -Quiet -ErrorAction SilentlyContinue)
        Write-Output ""
    }
    Write-Output ""
    Write-Output " ########################## "
    Write-Host " Conexion con el Dominio OK " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ########################## "

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
    Return
}