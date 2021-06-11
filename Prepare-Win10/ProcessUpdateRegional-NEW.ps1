clear
Write-Output " _____________________________________________________________________________________________________"

Write-Output ""
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
Write-Host "                                      Soporte Despegar Argentina                                      " -ForegroundColor green -BackgroundColor Black
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output " _____________________________________________________________________________________________________"

$Status= Get-ChildItem -Path C:\Users\admindesp\Desktop\ -Name Status.txt

if (!$Status){

    mkdir C:\PrepareWin10 -Force > NULL

    Copy-Item -Path "C:\Windows\Setup\Scripts\*" -Destination C:\PrepareWin10 -Force -Recurse

    # Descargo todos los modulos necesarios
    $token = "569b159288f7c200c33d6472bd5f26a9f2aa7d21"
    $headers = @{Authorization = "token $($token)"}
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ShowMenu.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\ShowMenu.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/VerifyCred.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\VerifyCred.ps1"
    Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ChangeName.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\ChangeName.ps1"

    Write-Output '1' > C:\Users\admindesp\Desktop\status.txt

    # creo la tarea de windows para que se llame el script a el mismo
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
            -WorkingDirectory "C:\PrepareWin10\" `
            -Argument '-NoProfile -ExecutionPolicy Bypass -File ProcessUpdateRegional-NEW.ps1'

    $trigger =  New-ScheduledTaskTrigger -AtStartup

    Register-ScheduledTask -RunLevel Highest -User admindesp `
            -Action $action -Trigger $trigger -TaskName 'Preparacion Win 10' `
            -Description "Esta Tarea se ejcuta cuando se prepara un equipo"

    # Ejecuto una sola vez ShowMenu ya que despues en los proximos reinicios con los archivos de estado se de que pais es.
    . $PSScriptRoot\ShowMenu.ps1



}else{
    
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