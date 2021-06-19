function WipeSystem {
    Write-Output {
        Remove-Item -LiteralPath C:\Windows\Setup\scripts -Recurse -Force
        Remove-Item -LiteralPath C:\PrepareWin10\ -Recurse -Force
    } > $env:TMP\AutoDelete.ps1

    & $env:TMP\AutoDelete.ps1
    
}