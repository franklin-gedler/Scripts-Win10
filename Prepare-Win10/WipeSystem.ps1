function WipeSystem {
    <#
    Write-Output {
        Start-Sleep -Seconds 5
        Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
        Remove-Item -LiteralPath C:\PrepareWin10\ -Recurse -Force
         "voy a ejecutar el reinicio desde el Script AutoDelete"
        Pause
        Restart-Computer
    } > $env:TMP\AutoDelete.ps1
    #>

    @'
    Start-Sleep -Seconds 5
    Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
    Remove-Item -LiteralPath C:\PrepareWin10\ -Recurse -Force
    Write-Output "voy a ejecutar el reinicio desde el Script AutoDelete"
    Pause
    Restart-Computer
'@ | Add-Content $env:TMP\AutoDelete.ps1

}