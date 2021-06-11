clear
Write-Output " _____________________________________________________________________________________________________"

Write-Output ""
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output " _____________________________________________________________________________________________________"

function DownloadModules {

    # Descargo todos los modulos necesarios
    $token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    $headers = @{Authorization = "token $($token)"}
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ShowMenu.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\ShowMenu.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/VerifyCred.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\VerifyCred.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ChangeName.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\ChangeName.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/JoinAD.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\JoinAD.ps1"
}

function RunScript {
    # Deshabilito el control de usuarios UAC
    Set-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 0


    # seteo el script que se va a ejecutar
    New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10' -Value "C:\PrepareWin10\SetupComplete.cmd"
        
}

function StopScript {
    # Habilito el control de usuarios UAC
    Set-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 1
    
    # Remuevo el Script que se va a Ejecutar
    Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10'
}

$Status= Get-ChildItem -Path C:\Users\admindesp\Desktop\ -Name Status.txt

if (!$Status){

    mkdir C:\PrepareWin10 -Force > NULL

    Copy-Item -Path "C:\Windows\Setup\Scripts\*" -Destination C:\PrepareWin10 -Force -Recurse

    # Descargo los Modulos
    DownloadModules

    Write-Output '1' > C:\Users\admindesp\Desktop\status.txt

    # Configuro Windows para que ejecute el script al iniciar Windows
    RunScript

    Pause
    # Ejecuto una sola vez ShowMenu ya que despues en los proximos reinicios con los archivos de estado se de que pais es.
    . $PSScriptRoot\ShowMenu.ps1



}else{
    
    DownloadModules
    $Status = Get-Content C:\Users\admindesp\Desktop\status.txt
    $Global:Pais = Get-Content C:\PrepareWin10\Pais.txt
    $Global:CodigoPais = Get-Content C:\PrepareWin10\CodigoPais.txt

    switch($Status){
    
        1{
        # LA agrego a Dominio
        . $PSScriptRoot\JoinAD.ps1
        JoinAD $Pais $CodigoPais
            
        }

        2{
            echo "sigo con lo demas"
        }
    }
}