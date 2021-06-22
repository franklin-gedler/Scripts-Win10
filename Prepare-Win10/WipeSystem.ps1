function WipeSystem {
    Write-Output {
        Start-Sleep -Seconds 5
        Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
        Remove-Item -LiteralPath C:\PrepareWin10\ -Recurse -Force
        echo "voy a ejecutar el reinicio desde el Script AutoDelete"
        Pause
        Restart-Computer
    } > $env:TMP\AutoDelete.ps1

    
    return
    
}