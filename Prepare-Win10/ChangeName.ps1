function ChangeName {
    param (
        [String]$1
    )

    Write-Output ""
    Write-Output " =============================== "
    Write-Host "   Cambiando Nombre del Equipo   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =============================== "

    $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    $Global:NCompu = "$1$SCompu"
    #Write-Output "Nuevo nombre a Setear: $NCompu"
    while (!$SCompu) {
        $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
        $Global:NCompu = "$1$SCompu"
        #Write-Output "Nuevo nombre a Setear: $NCompu"
    }
    Rename-Computer -NewName $NCompu -WarningAction SilentlyContinue
    Write-Output $NCompu > C:\PrepareWin10\NCompu.txt
    
    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
    return
}