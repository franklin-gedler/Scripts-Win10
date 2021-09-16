function DellCommandUpdate {

    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################

    $machinebrand =  (Get-WmiObject -class win32_computersystem).Manufacturer
    
    if("$machinebrand" -eq "Dell Inc."){
    
        Write-Output " =================================  "
        Write-Host "   Instalando Dell Command Update   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ================================== "
        Write-Output ""
        mkdir $env:TMP\dellcommand > NULL

        . C:\PrepareWin10\PowerAdapterStatus.ps1
        PowerAdapterStatus # valido si el cargador esta conectado

        # Descargo el dell command update --------------------------------------------------------------------------------------------
        $ProgressPreference = 'SilentlyContinue'
        #$URL = 'https://dl.dell.com/FOLDER06986472M/2/Dell-Command-Update-Application-for-Windows-10_DF2DT_WIN_4.1.0_A00.EXE'
        #$URL = 'https://dl.dell.com/FOLDER07414802M/1/Dell-Command-Update-Application-for-Windows-10_W1RMW_WIN_4.2.1_A00.EXE'
        $URL = 'https://dl.dell.com/FOLDER07582763M/3/Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_02.EXE'

        Invoke-WebRequest -Uri $URL `
            -UseBasicParsing -OutFile $env:TMP\dellcommand\Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_02.EXE
        #-----------------------------------------------------------------------------------------------------------------------------

        # Instalo Dell Command Update ----------------------------------------------------------------------------------------------------
        Start-Process -Wait $env:TMP\dellcommand\Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_02.EXE -ArgumentList '/s'
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
        Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
            -ArgumentList '/applyUpdates -reboot=disable -updatetype=driver,bios -updateDeviceCategory=network,audio,video,input,chipset -outputLog=C:\Users\admindesp\Desktop\applyUpdateOutput.log'
        #-------------------------------------------------------------------------------------------------------------------------------------

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
    }
    
    Set-Service wuauserv -StartupType Automatic -InformationAction SilentlyContinue
    Start-Service wuauserv -InformationAction SilentlyContinue

}