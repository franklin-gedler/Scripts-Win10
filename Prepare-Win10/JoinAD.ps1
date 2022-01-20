function JoinAD {
    param (

        [Parameter(Mandatory)]
        [String]$1,
        
        [Parameter(Mandatory)]
        [Int32]$2
    )

    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################

    # $1 = Pais
    # $2 = CodigoPais

    #Write-Output "YO $env:USERNAME ejecuto el script"
    #$cred = Import-CliXml -Path "C:\PrepareWin10\CredSoporte_${env:USERNAME}_${env:COMPUTERNAME}.xml"

    # Importo Usuario y Clave
    $Ucred = Get-Content C:\PrepareWin10\Ucred.txt
    $Pcred = Get-Content C:\PrepareWin10\Pcred.txt | ConvertTo-SecureString -Key (Get-Content C:\PrepareWin10\aes.key)
    $cred = New-Object System.Management.Automation.PsCredential($Ucred,$Pcred)

    # Verifico si esta conectado al AD
    . C:\PrepareWin10\ValidateConnectAD.ps1
    ValidateConnectAD $1 $2

    $NCompu = $env:COMPUTERNAME

    $Domain = "NameDomain"
    $Domain = $Domain.ToLower()

    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
    #$consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" `
    #    -SearchScope Subtree -Server "IP_Domain" `
    #    -Credential $cred | Select-Object -ExpandProperty DistinguishedName

    $consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" -SearchScope Subtree -Credential $cred -Server $Domain | Select-Object -ExpandProperty DistinguishedName

    if ($consul){
        Write-Output " =============================================== "
        Write-Host "   Equipo existe en el AD, se procede a borrar   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " =============================================== "
        #Remove-ADObject -Identity "$consul" -Credential $cred -Server "IP_Domain" -Confirm:$False -verbose
        Remove-ADObject -Identity "$consul" -Credential $cred -Server $Domain -Confirm:$False -verbose
        Start-Sleep -Seconds 60
        Write-Output ""
        Write-Output " ############# "
        Write-Host "   Eliminado   " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ############# "
    }

    Write-Output ""
    Write-Output " ==================================== "
    Write-Host "        Enlazando equipo al AD        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================================== "

    $Ucred = $cred.UserName
    $Pcred = $cred.GetNetworkCredential().Password

    $JoinToAD = (Get-WMIObject -NameSpace "Root\Cimv2" -Class "Win32_ComputerSystem").JoinDomainOrWorkgroup("$Domain","$Pcred","$Ucred",$null,3)
    
    <#
    Add-Computer -DomainName "NameDomain" `
        -Credential $cred -Force -Options AccountCreate `
        -WarningAction SilentlyContinue
    
    #>
    
    if ($JoinToAD.ReturnValue -ne 0){
        Copy-Item C:\Windows\debug\NetSetup.LOG C:\Users\adminuser\Desktop\
        $ErrorToAD = $JoinToAD.ReturnValue
        Write-Output "Codigo de error: $ErrorToAD"
        Write-Output "La leyenda del codigo de error se puede buscar en:"
        Write-Output 'https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/joindomainorworkgroup-method-in-class-win32-computersystem'
        Write-Output ""
        Write-Output "Se Copio en el Escritorio el NetSetup.LOG para verificar el problema en la union al dominio"
        
    }else{
        Start-Sleep -Seconds 60

        ############ Para investigar comando Test-ComputerSecureChannel -Repair ###############
        $ConfianzaAD = Test-ComputerSecureChannel
        Write-Output $ConfianzaAD > C:\Users\adminuser\Desktop\ConfianzaAD.txt

        #$consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" `
        #    -SearchScope Subtree -Server "IP_Domain" `
        #    -Credential $cred | Select-Object -ExpandProperty DistinguishedName

        $consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" -SearchScope Subtree -Credential $cred -Server $Domain | Select-Object -ExpandProperty DistinguishedName

        if (!$consul){
            Write-Output ""
            Write-Output " ================================================ "
            Write-Host "              Problemas para Enlazar              " -ForegroundColor Red -BackgroundColor Black
            Write-Host "   Se Intentara Nuevamente Despues del Reinicio   " -ForegroundColor Red -BackgroundColor Black
            Write-Output " ================================================ "

            #Remove-Computer -UnjoinDomainCredential $cred -WorkgroupName "TRABAJO" -Force  ## bajo localmente el equipo de la falsa subida a dominio
            #Add-Computer -DomainName "NameDomain" `
            #    -Credential $cred -Force -Options AccountCreate `
            #    -WarningAction SilentlyContinue

            Copy-Item C:\Windows\debug\NetSetup.LOG C:\Users\adminuser\Desktop\
            
            # La Bajo de la falsa subida
            $UnJoinToAD = (Get-WMIObject -NameSpace "Root\Cimv2" -Class "Win32_ComputerSystem").UnJoinDomainOrWorkgroup("$Pcred","$Ucred",0)

            timeout /t 10
            Restart-Computer

            <#
            Start-Sleep -Seconds 10
            # La vuelvo a subir
            $JoinToAD = (Get-WMIObject -NameSpace "Root\Cimv2" -Class "Win32_ComputerSystem").JoinDomainOrWorkgroup("$Domain","$Pcred","$Ucred",$null,3)
            
            Start-Sleep -Seconds 60
            
            $consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" -SearchScope Subtree -Credential $cred -Server $Domain | Select-Object -ExpandProperty DistinguishedName
            
            #$consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" `
            #    -SearchScope Subtree -Server "IP_Domain" `
            #    -Credential $cred | Select-Object -ExpandProperty DistinguishedName
            #>
            
        }else {

            DownloadModules "ChangePassadminuser"
            . C:\PrepareWin10\ChangePassadminuser.ps1
            ChangePassadminuser $CodigoPais

            Write-Output ""
            Write-Output " ######################################################### "
            Write-Host "  Se agrego al equipo $NCompu al Dominio $Domain  " -ForegroundColor Green -BackgroundColor Black
            Write-Output " ######################################################### "

            # _____________________________________________________________________________________________________

            Write-Output 'Lista Para Usar' > C:\Users\adminuser\Desktop\status.txt
            
            OffScriptConfig   # Esto elimina en el registro la ejecucion del script al inicio

            # Limpio el Sistema de los archivos de instalacion
            DownloadModules "WipeSystem"
            . C:\PrepareWin10\WipeSystem.ps1
            WipeSystem

            timeout /t 10
    
        }
    
    }

}