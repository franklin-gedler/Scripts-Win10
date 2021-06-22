function WipeSystem {

    @'
    Start-Sleep -Seconds 5
    Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
    Remove-Item -LiteralPath C:\PrepareWin10\ -Recurse -Force
    Pause
    Restart-Computer
'@ | Add-Content $env:TMP\AutoDelete.ps1

    Return
}