@echo off
:Install Software Basic
start /wait %windir%\Setup\Scripts\E84.00_CheckPointVPN.msi /quiet /norestart
start /wait %windir%\Setup\Scripts\7z1900-x64.exe /S
start /wait %windir%\Setup\Scripts\AcroRdrDC1902120049_es_ES.exe /sAll
start /wait %windir%\Setup\Scripts\java.exe /s
start /wait %windir%\Setup\Scripts\ChromeStandaloneSetup64.exe /silent /install
:start /wait %windir%\Setup\Scripts\Office2016x64\setup.exe /config %windir%\setup\scripts\Office2016x64\standard.ww\config.xml
:Script PowerShell
PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%windir%\Setup\Scripts\process.ps1"' -Verb RunAs}"




