function DellCommandUpdate {
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
        Invoke-WebRequest -Uri "https://dl.dell.com/FOLDER06986472M/2/Dell-Command-Update-Application-for-Windows-10_DF2DT_WIN_4.1.0_A00.EXE" `
            -UseBasicParsing -OutFile $env:TMP\dellcommand\Dell-Command-Update-Application-for-Windows-10_DF2DT_WIN_4.1.0_A00.EXE
        #-----------------------------------------------------------------------------------------------------------------------------

        # Instalo Dell Command Update ----------------------------------------------------------------------------------------------------
        Start-Process -Wait $env:TMP\dellcommand\Dell-Command-Update-Application-for-Windows-10_DF2DT_WIN_4.1.0_A00.EXE -ArgumentList '/s'
        #---------------------------------------------------------------------------------------------------------------------------------


        #Start-Process -Wait "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" `
        #    -ArgumentList '/configure -userConsent=disable -autoSuspendBitLocker=enable'

        

    }
    
}