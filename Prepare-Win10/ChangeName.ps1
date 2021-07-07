function ChangeName {
    param (
        [String]$1
    )

    Write-Output ""
    Write-Output " =============================== "
    Write-Host "   Cambiando Nombre del Equipo   " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " =============================== "

    #$VeryPCI = Get-Content C:\Users\admindesp\Desktop\PCI.txt
    
    if (!$PCI){

        $SCompu = (Get-WmiObject win32_bios).SerialNumber
        $Global:NCompu = "$1$SCompu"
        
        while (!$SCompu) {
            $SCompu = (Get-WmiObject win32_bios).SerialNumber
            $Global:NCompu = "$1$SCompu"
        }

        Rename-Computer -NewName $NCompu -WarningAction SilentlyContinue

    }else {
        
        switch ($PCI) {

            1{
                # Es PCI
                $SCompu = (Get-WmiObject win32_bios).SerialNumber
                $Global:NCompu = $1 + 'PCI' + $SCompu
                
                while (!$SCompu) {
                    $SCompu = (Get-WmiObject win32_bios).SerialNumber
                    $Global:NCompu = $1 + 'PCI' + $SCompu
                    
                }
    
                Rename-Computer -NewName $NCompu -WarningAction SilentlyContinue
            }
            
            2{
                # No es PCI
                $SCompu = (Get-WmiObject win32_bios).SerialNumber
                $Global:NCompu = "$1$SCompu"
                
                while (!$SCompu) {
                    $SCompu = (Get-WmiObject win32_bios).SerialNumber
                    $Global:NCompu = "$1$SCompu"
                    
                }
    
                Rename-Computer -NewName $NCompu -WarningAction SilentlyContinue
                #Write-Output $NCompu > C:\PrepareWin10\NCompu.txt
            }
        }
    }

    

    Write-Output ""
    Write-Output " ######### "
    Write-Host "   Listo   " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######### "
    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
    return
}