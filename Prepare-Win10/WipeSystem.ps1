function WipeSystem {
    
    @'
    Start-Sleep -Seconds 5
    Remove-Item -LiteralPath C:\PrepareWin10\ -Recurse -Force
    Start-Sleep -Seconds 10
    Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
    Start-Sleep -Seconds 10
    
'@ | Add-Content C:\PS\AutoDelete.ps1
    
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
            -WorkingDirectory "C:\PS\" `
            -Argument '-NoProfile -ExecutionPolicy Bypass -File C:\PS\AutoDelete.ps1'

    $trigger =  New-ScheduledTaskTrigger -AtStartup

    Register-ScheduledTask -RunLevel Highest -User SYSTEM `
            -Action $action -Trigger $trigger -TaskName 'AutoDelete' `
            -Description "Finalizacion del Script"

    #Return
}