function Bitlocker {
   
    param (
        $1
    )

    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################

    $NCompu = Get-Content C:\PrepareWin10\NCompu.txt

    # Importo Usuario y Clave de RED
    $Ucred = Get-Content C:\PrepareWin10\Ucred.txt
    $Pcred = Get-Content C:\PrepareWin10\Pcred.txt | ConvertTo-SecureString -Key (Get-Content C:\PrepareWin10\aes.key)
    $cred = New-Object System.Management.Automation.PsCredential($Ucred,$Pcred)
    
    Write-Output ""
    Write-Output " ========================================= "
    Write-Host "     Verificando si el TPM esta Activo     " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ========================================= "
    $tpmpresent = (Get-Tpm).TpmPresent
    $tpmready = (Get-Tpm).TpmReady

    if("$tpmpresent" -eq "False" -And "$tpmready" -eq "False"){
        Write-Output ""
        Write-Output " ####################################################################################### "
        Write-Host " ERROR: TPM NO ACTIVO, POR FAVOR VERIFICAR EN EL BIOS Y ACTIVAR EL BITLOCKER MANUALMENTE " -ForegroundColor Red -BackgroundColor Black
        Write-Output " ####################################################################################### "
        Write-Output ""

    }else {
        Write-Output ""
        Write-Output " ############ "
        Write-Host "  TPM Activo  " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ############ "
        Write-Output ""
        Write-Output " ============================== "
        Write-Host "     Habilitando Bitlocker      " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ============================== "
       
        Clear-BitLockerAutoUnlock > NULL
        Disable-BitLocker -MountPoint C: > NULL
        #Clear-Tpm > NULL    Si activo esto tengo que reiniciar para que se inicialice el TPM y poder activar bitlocker
        Start-Sleep -Seconds 10

        Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector
        Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -TpmProtector
        #Get-Command -Name manage-bde
        manage-bde.exe -on $env:SystemDrive > NULL

        # Respaldo la llave ID y Pass en el Escritorio
        (Get-BitLockerVolume -mount c).keyprotector | Select-Object $NCompu, KeyProtectorId, RecoveryPassword > C:\Users\admindesp\Desktop\$NCompu.txt
        
        $KeyID = Get-BitLockerVolume -MountPoint C: | Select-Object -ExpandProperty KeyProtector `
                | Where-Object KeyProtectorType -eq 'RecoveryPassword' `
                | Select-Object -ExpandProperty KeyProtectorId

        $PassRecovery = Get-BitLockerVolume -MountPoint C: | Select-Object -ExpandProperty KeyProtector `
                        | Where-Object KeyProtectorType -eq 'RecoveryPassword' | Select-Object -ExpandProperty RecoveryPassword

        $Global:IdKeyBitlocker = "KeyProtectorId:  $KeyID ------------------------------ RecoveryPassword:  $PassRecovery"
        
        # Envia el mail con id y recovery -----------------------------------------------------------------
        $Mail = 'soportescripts@gmail.com'
        $PassFile = "C:\PrepareWin10\passfile"
        $Key = "C:\PrepareWin10\key"

        $credMail = New-Object -TypeName System.Management.Automation.PSCredential `
                    -ArgumentList "$Mail", (Get-Content "$PassFile" | ConvertTo-SecureString -Key (Get-Content "$Key"))

        #$PassMail = ConvertTo-SecureString "micontraseña" -AsPlainText -Force
        #$PassMail = Get-Content $env:USERPROFILE\Desktop\file | ConvertTo-SecureString -Force
        #$credMail = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Mail, $PassMail
        
        Send-MailMessage -From "$Mail" -To "soporte@despegar.com" `
                        -Subject "$NCompu" -Body "$IdKeyBitlocker" -Priority High `
                        -UseSsl -SmtpServer smtp.gmail.com -Port 587 -Credential $credMail
        #--------------------------------------------------------------------------------------------------
        
        
        
        
        Write-Output ""
        Write-Output " ============================= "
        Write-Host "  Verificando conexion al NAS  " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ============================= "
        $nas = Test-Connection 10.40.54.52 -Count 2 -Quiet
        if ("$nas" -eq 'False'){
            Write-Output ""
            Write-Output " ############################################################################################################## "
            Write-Host "  Problemas para conectarnos al NAS, se creo archivo $NCompu en el escritorio con el ID y PASS Bitlocker  " -ForegroundColor Red -BackgroundColor Black
            Write-Output " ############################################################################################################## "
        }else {
            Write-Output ""
            Write-Output " ######################## "
            Write-Host "  Conexion con el NAS OK  " -ForegroundColor Green -BackgroundColor Black
            Write-Output " ######################## "
            Write-Output ""
            Write-Output ""
            Write-Output " =========================== "
            Write-Host "  Copiando ID y PASS al NAS  " -ForegroundColor Yellow -BackgroundColor Black
            Write-Output " =========================== "
            New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\reg-soporte-storage-00.infra.d\Soporte\BitLockerFiles\$1" -Credential $cred
            Copy-Item -LiteralPath C:\Users\admindesp\Desktop\$NCompu.txt -Destination Z:\
        }
    }

    Write-Output ""
    Write-Output "_________________________________________________________________________________________"
    Write-Output ""
}