function TimeSet {
    
    param(
        $1, $2
    )
    
    Write-Output ""
    Write-Output " ============================= "
    Write-Host "   Actualizando Hora y Fecha   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ============================= "
    Write-Output ""

    $Domain = "$2.infra.d"
    $Domain = $Domain.ToLower()

    # debo agregar el ar.infra.d como servidor de hora y fecha

    Set-TimeZone -Id "$1"

    Set-Service w32time -StartupType Automatic

    Start-Service w32time # Tengo que iniciar el servicio antes de setearle cualquier config.

    w32tm /config /syncfromflags:all /manualpeerlist:$Domain /reliable:yes /update > $null

    Stop-Service w32time
    #w32tm /config /syncfromflags:domhier /update > NULL

    Start-Sleep -Seconds 10

    Start-Service w32time

    Start-Sleep -Seconds 10

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

    Return
}