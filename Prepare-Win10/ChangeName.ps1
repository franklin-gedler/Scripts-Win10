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
    
}