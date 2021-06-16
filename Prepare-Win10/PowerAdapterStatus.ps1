function PowerAdapterStatus {
    $validatecharger = [BOOL](Get-WmiObject -Class BatteryStatus -Namespace root\wmi).PowerOnLine
        while ("$validatecharger" -eq "false"){

            Write-Output ""
            Write-Output " ########################################### "
            Write-Host "   Por favor, Conectar cargador del equipo   " -ForegroundColor Yellow -BackgroundColor Black
            Write-Output " ########################################### "
            timeout /t 300
            $validatecharger = [BOOL](Get-WmiObject -Class BatteryStatus -Namespace root\wmi).PowerOnLine

            Write-Output ""
            
        }
    
}