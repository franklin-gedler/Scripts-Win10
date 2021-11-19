function DellCommandUpdate {

    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################

    $machinebrand =  (Get-WmiObject -class win32_computersystem).Manufacturer
    
    if("$machinebrand" -eq "Dell Inc."){
    
        Write-Output " ======================= "
        Write-Host "   Dell Command Update   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ======================= "
        Write-Output ""

        . C:\PrepareWin10\PowerAdapterStatus.ps1
        PowerAdapterStatus # valido si el cargador esta conectado

        $StateDellUpdate = Test-Path "C:\Program Files\Dell\"

        if($StateDellUpdate -eq $False){

            #mkdir $env:TMP\dellcommand > NULL

            # Descargo el dell command update --------------------------------------------------------------------------------------------
            #$ProgressPreference = 'SilentlyContinue'
            #$URL = 'https://dl.dell.com/FOLDER06986472M/2/Dell-Command-Update-Application-for-Windows-10_DF2DT_WIN_4.1.0_A00.EXE'
            #$URL = 'https://dl.dell.com/FOLDER07414802M/1/Dell-Command-Update-Application-for-Windows-10_W1RMW_WIN_4.2.1_A00.EXE'
            #$URL = 'https://dl.dell.com/FOLDER07582763M/3/Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_02.EXE'

            #Invoke-WebRequest -Uri $URL `
            #    -UseBasicParsing -OutFile $env:TMP\dellcommand\Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_02.EXE
            #-----------------------------------------------------------------------------------------------------------------------------

            function DownloadFilesInstaller {
                param (
                    $1,$2
                )
                $Token = "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"
            
                $Headers = @{
                accept = "application/octet-stream"
                authorization = "Token " + $Token
                }
        
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $1 `
                        -Headers $Headers -UseBasicParsing -OutFile "C:\PrepareWin10\$2"
            }
        
        
            $URLinstaller = 'https://api.github.com/repos/franklin-gedler/Scripts-Win10/releases/assets/47280151'
            $NameInstaller = 'Dell_Command_Update_GRVPK_WIN_4.3.0_A00_03.exe'  # Debes acortar el nombre del archivo ya que genera problemas
            
            DownloadFilesInstaller $URLinstaller $NameInstaller


            # Instalo Dell Command Update ----------------------------------------------------------------------------------------------------
            #Start-Process -Wait $env:TMP\dellcommand\Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_02.EXE -ArgumentList '/s'
            Start-Process -Wait C:\PrepareWin10\Dell_Command_Update_GRVPK_WIN_4.3.0_A00_03.exe -ArgumentList '/s'
            #---------------------------------------------------------------------------------------------------------------------------------

            # Configuro ------------------------------------------------------------------------------------
            Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                -ArgumentList '/configure -userConsent=disable -autoSuspendBitLocker=enable'
            #-----------------------------------------------------------------------------------------------
            
            # Actualizo drivers y bios -----------------------------------------------------------------------------------------------------------
            #Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
            #    -ArgumentList '/applyUpdates -reboot=disable -updatetype=driver,bios -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'
            #Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
            #    -ArgumentList '/applyUpdates -reboot=disable -updatetype=driver -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'
            #Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
            #    -ArgumentList '/applyUpdates -reboot=disable -updatetype=driver -updateDeviceCategory=network,audio,video,input,chipset -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'
            Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                -ArgumentList '/driverInstall -reboot=disable -outputLog=C:\Users\admindesp\Desktop\driverInstallOutput.log'
            #-------------------------------------------------------------------------------------------------------------------------------------

            Write-Output '1' > C:\Users\admindesp\Desktop\statusdellcommand.txt

        }else {
            
            $StatusDell = Get-Content C:\Users\admindesp\Desktop\statusdellcommand.txt

            switch($StatusDell){

                1{
                    #Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                    #    -ArgumentList '/applyUpdates -reboot=disable -updatetype=driver -updateDeviceCategory=network,audio,video,input,chipset -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'

                    Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                        -ArgumentList '/applyUpdates -reboot=disable -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'

                    Write-Output '2' > C:\Users\admindesp\Desktop\statusdellcommand.txt
                }

                2{
                    Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                        -ArgumentList '/applyUpdates -reboot=disable -updatetype=bios -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'

                    # --------------------------Tarea de Winodws para el futuro------------------------------ #

                    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
                        -WorkingDirectory "C:\Program Files\Dell\" `
                        -Argument '-NoProfile -ExecutionPolicy Bypass -File TaskDellUpdate.ps1'

                    $trigger =  New-ScheduledTaskTrigger -AtStartup

                    Register-ScheduledTask -RunLevel Highest -User SYSTEM `
                        -Action $action -Trigger $trigger -TaskName 'Dell Command Update' `
                        -Description "Esta Tarea actualiza Bios y Driver del equipo Dell"
                    # --------------------------------------------------------------------------------------- #
                    
                    # Script de Tarea Para mantener Drivers Actualizados --------------------------------------------------------------------------------
                    @'
                    Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                            -ArgumentList '/scan -updateDeviceCategory=audio,video,network,others -outputLog=C:\Users\admindesp\Desktop\ScanOutput.log'
                    
                    $ScanOutput = Get-Content C:\Users\admindesp\Desktop\ScanOutput.log
                    $patron = 'BIOS'
                    $SearchScanOutput = $ScanOutput | Select-String -AllMatches $patron

                    if ($SearchScanOutput){
                        echo "instalo primero bios"
                        Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                            -ArgumentList '/applyUpdates -reboot=disable -updatetype=bios -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'
                        
                    }else{
                        echo "no hay Bios, instalamos drivers"
                        Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
                            -ArgumentList '/applyUpdates -reboot=disable -updatetype=driver -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'
                    }
'@ | Add-Content "C:\Program Files\Dell\TaskDellUpdate.ps1"
                    
                    Write-Output '3' > C:\Users\admindesp\Desktop\status.txt

                    Set-Service wuauserv -StartupType Automatic -InformationAction SilentlyContinue
                    Start-Service wuauserv -InformationAction SilentlyContinue
                }

            }

        }

    }

}