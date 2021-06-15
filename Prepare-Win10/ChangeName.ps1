function ChangeName {
    param (
        [String]$1
    )
    $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    $Global:NCompu = "$1$SCompu"
    #Write-Output "Nuevo nombre a Setear: $NCompu"
    while (!$SCompu) {
        $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
        $Global:NCompu = "$1$SCompu"
        #Write-Output "Nuevo nombre a Setear: $NCompu"
    }
    Rename-Computer -NewName $NCompu -WarningAction SilentlyContinue

    Pause
    timeout /t 10
    Restart-Computer
    #Start-Sleep -Seconds 5
}