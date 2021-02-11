@echo off
:Install Software Basic
start /wait %windir%\setup\scripts\E84.00_CheckPointVPN.msi /quiet /norestart
start /wait %windir%\setup\scripts\7z1900-x64.exe /S
start /wait %windir%\setup\scripts\AcroRdrDC1902120049_es_ES.exe /sAll
start /wait %windir%\setup\scripts\java.exe /s
start /wait %windir%\setup\scripts\ChromeStandaloneSetup64.exe /silent /install
start /wait %windir%\setup\scripts\Office2016x64\setup.exe /config %windir%\setup\scripts\Office2016x64\standard.ww\config.xml
:Script PowerShell
PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%windir%\setup\scripts\process.ps1"' -Verb RunAs}"





:Script Disable-WindowsUpdate temp
:PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%windir%\setup\scripts\DisableWindowsUpdate.ps1"' -Verb RunAs}"
:PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%windir%\setup\scripts\SetupComplete.ps1"'
:PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%~dpn0.ps1" '-Verb RunAs}"
:set LOCALAPPDATA=%USERPROFILE%\AppData\Local
:set PSExecutionPolicyPreference=Unrestricted
:powershell "%systemdrive%\MyScript.ps1" -Argument >"%systemdrive%\myscript_log.txt" 2>&1




