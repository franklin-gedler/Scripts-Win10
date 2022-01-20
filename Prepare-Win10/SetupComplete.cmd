:Script PowerShell
PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%windir%\Setup\Scripts\process.ps1"' -Verb RunAs}"




