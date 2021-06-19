
clear
Write-Output " _____________________________________________________________________________________________________"

Write-Output ""
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output " _____________________________________________________________________________________________________"
Write-Output ""
Write-host 'Preparando lo necesario . . . Espere' -ForegroundColor Yellow -BackgroundColor Black
Write-Output ""
#Write-Output "YO $env:USERNAME ejecuto el script"
#Get-Location

<#
function DownloadModules {

    # Descargo todos los modulos necesarios
    $token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    $headers = @{Authorization = "token $($token)"}
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ShowMenu.ps1" -UseBasicParsing -OutFile "C:\PrepareWin10\ShowMenu.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/VerifyCred.ps1" -UseBasicParsing -OutFile "C:\PrepareWin10\VerifyCred.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ChangeName.ps1" -UseBasicParsing -OutFile "C:\PrepareWin10\ChangeName.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/JoinAD.ps1" -UseBasicParsing -OutFile "C:\PrepareWin10\JoinAD.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ValidateConnectAD.ps1" -UseBasicParsing -OutFile "C:\PrepareWin10\ValidateConnectAD.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/TimeSet.ps1" -UseBasicParsing -OutFile "C:\PrepareWin10\TimeSet.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/Bitlocker.ps1" -UseBasicParsing -OutFile "C:\PrepareWin10\Bitlocker.ps1"
}
#>

function DownloadModules {
    param (
        $1
    )
    $token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    $headers = @{Authorization = "token $($token)"}
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $headers `
        -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/$1.ps1" `
        -UseBasicParsing -OutFile "C:\PrepareWin10\$1.ps1"
}

function RunScript {
    # Deshabilito el control de usuarios UAC
    Set-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 0 > NULL


    # seteo el script que se va a ejecutar
    #New-ItemProperty -Path 'HKCU:HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10' -Value "C:\PrepareWin10\SetupComplete.cmd"
    New-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10' -Value '"C:\PrepareWin10\SetupComplete.cmd"' > NULL
}

function StopScript {
    # Habilito el control de usuarios UAC
    Set-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 1
    
    # Remuevo el Script que se va a Ejecutar
    #Remove-ItemProperty -Path 'HKCU:HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10'
    Remove-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10'
}

$Status= Get-ChildItem -Path C:\Users\admindesp\Desktop\ -Name Status.txt

if (!$Status){

    mkdir C:\PrepareWin10 -Force > NULL

    Copy-Item -Path "C:\Windows\Setup\Scripts\*" -Destination C:\PrepareWin10 -Force -Recurse

    # Configuro Windows para que ejecute el script al iniciar Windows
    RunScript
    
    # Ejecuto una sola vez ShowMenu ya que despues en los proximos reinicios con los archivos de estado se de que pais es.
    DownloadModules "Firma"
    DownloadModules "MainAction"
    DownloadModules "ValidateConnectAD"
    DownloadModules "VerifyCred"
    DownloadModules "ChangeName"
    DownloadModules "TimeSet"
    . C:\PrepareWin10\MainAction.ps1
    MainAction

    # Activo Bitlocker
    $Pais = Get-Content C:\PrepareWin10\Pais.txt
    DownloadModules "Bitlocker"
    . C:\PrepareWin10\Bitlocker.ps1
    Bitlocker $Pais

    Write-Output '1' > C:\Users\admindesp\Desktop\status.txt
    timeout /t 10
    Restart-Computer


}else{
    
    Set-Location -Path C:\PrepareWin10\
    $Status = Get-Content C:\Users\admindesp\Desktop\status.txt
    $Pais = Get-Content C:\PrepareWin10\Pais.txt
    $CodigoPais = Get-Content C:\PrepareWin10\CodigoPais.txt

    switch($Status){
    
        1{
            
            DownloadModules "PowerAdapterStatus"
            DownloadModules "DellCommandUpdate"
            . C:\PrepareWin10\DellCommandUpdate.ps1
            DellCommandUpdate
            

            Write-Output '2' > C:\Users\admindesp\Desktop\status.txt
            
            timeout /t 10
            Restart-Computer
        }

        2{
            DownloadModules "UpdatingWindows"
            . C:\PrepareWin10\UpdatingWindows.ps1
            UpdatingWindows

            Write-Output '3' > C:\Users\admindesp\Desktop\status.txt
            #Pause
            timeout /t 10
            Restart-Computer
        }

        3{
            # Descargo he instalo el paquete de programas segun el Pais que hayan seleccionado
            switch ($Pais) {
                
                AR{
                    Write-Output "Programas Para AR"
                    DownloadModules "ARProgramPackages"
                    . C:\PrepareWin10\ARProgramPackages.ps1
                    ARProgramPackages
                }
                
            }
            
            Write-Output '4' > C:\Users\admindesp\Desktop\status.txt
            #Pause
            timeout /t 10
            Restart-Computer
        }

        4{

            DownloadModules "ChangePassAdmindesp"
            . C:\PrepareWin10\ChangePassAdmindesp.ps1
            ChangePassAdmindesp $CodigoPais

            # La agrego a Dominio
            DownloadModules "JoinAD"
            . C:\PrepareWin10\JoinAD.ps1
            JoinAD $Pais $CodigoPais

            Write-Output 'Lista Para Usar' > C:\Users\admindesp\Desktop\status.txt
            Pause
            timeout /t 10

            StopScript   # Esto elimina en el registro la ejecucion del script al inicio

            # Limpio el Sistema de los archivos de instalacion
            DownloadModules "WipeSystem"
            . C:\PrepareWin10\WipeSystem.ps1
            WipeSystem

            Restart-Computer
        }

    }
}