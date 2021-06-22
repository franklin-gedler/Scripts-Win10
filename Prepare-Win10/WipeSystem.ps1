function WipeSystem {
    
    @'
    Start-Sleep -Seconds 5
    Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
    Remove-Item -LiteralPath C:\PrepareWin10\ -Recurse -Force
'@ | Add-Content C:\PrepareWin10\AutoDelete.ps1
    
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
            -WorkingDirectory "C:\Program Files\Dell\" `
            -Argument '-NoProfile -ExecutionPolicy Bypass -File C:\PrepareWin10\AutoDelete.ps1'

    $trigger =  New-ScheduledTaskTrigger -AtStartup

    Register-ScheduledTask -RunLevel Highest -User SYSTEM `
            -Action $action -Trigger $trigger -TaskName 'AutoDelete' `
            -Description "Finalizacion del Script"

    Return
}