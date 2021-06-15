function JoinAD {
    param (
        $1,$2
    )

    # $1 = Pais
    # $2 = CodigoPais

    Write-Output "YO $env:USERNAME ejecuto el script"
    #$cred = Import-CliXml -Path "C:\PrepareWin10\CredSoporte_${env:USERNAME}_${env:COMPUTERNAME}.xml"

    # Importo Usuario y Clave
    #$Ucred = Get-Content C:\PrepareWin10\Ucred.txt
    $Ucred = Get-Content C:\PrepareWin10\Ucred.txt | ConvertTo-SecureString -Key (Get-Content C:\PrepareWin10\aes.key)
    $Pcred = Get-Content C:\PrepareWin10\Pcred.txt | ConvertTo-SecureString -Key (Get-Content C:\PrepareWin10\aes.key)
    $cred = New-Object System.Management.Automation.PsCredential($Ucred,$Pcred)

    # Verifico si esta conectado al AD
    . C:\PrepareWin10\ValidateConnectAD.ps1
    ValidateConnectAD $1 $2

    $NCompu = $env:COMPUTERNAME

    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.dll" -WarningAction SilentlyContinue
    Import-Module "C:\PS\ADPoSh\Microsoft.ActiveDirectory.Management.resources.dll" -WarningAction SilentlyContinue
    $Global:consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" `
        -SearchScope Subtree -Server "10.40.$2.1" `
        -Credential $cred | Select-Object -ExpandProperty DistinguishedName

    if ($consul){
        Write-Output " =============================================== "
        Write-Host "   Equipo existe en el AD, se procede a borrar   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " =============================================== "
        Remove-ADObject -Identity "$consul" -Credential $cred -Server "10.40.$2.1" -Confirm:$False -verbose
        Start-Sleep -Seconds 15
        Write-Output ""
        Write-Output " ############# "
        Write-Host "   Eliminado   " -ForegroundColor Green -BackgroundColor Black
        Write-Output " ############# "
    }

    Write-Output ""
    Write-Output " ==================================== "
    Write-Host "        Enlazando equipo al AD        " -ForegroundColor Yellow -BackgroundColor Black
    Write-Output " ==================================== "

    #add-computer -DomainName $domainname -Credential $Credential -OUPath $OU -force -Options JoinWithNewName,AccountCreate -restart

    Add-Computer -DomainName "$1.infra.d" `
        -Credential $cred -Force -Options AccountCreate `
        -WarningAction SilentlyContinue
    
    Start-Sleep -Seconds 20

    $Global:consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" `
        -SearchScope Subtree -Server "10.40.$2.1" `
        -Credential $cred | Select-Object -ExpandProperty DistinguishedName

    while (!$consul){
        Write-Output " ====================== "
        Write-Host "   Reintentando Enlazar   " -ForegroundColor Yellow -BackgroundColor Black
        Write-Output " ====================== "
        Remove-Computer -UnjoinDomainCredential $cred -WorkgroupName "TRABAJO" -Force  ## bajo localmente el equipo de la falsa subida a dominio
        
        Add-Computer -DomainName "$1.infra.d" `
            -Credential $cred -Force -Options AccountCreate `
            -WarningAction SilentlyContinue

        Start-Sleep -Seconds 20
        
        $Global:consul = Get-ADComputer -LDAPFilter "(cn=$NCompu)" `
            -SearchScope Subtree -Server "10.40.$2.1" `
            -Credential $cred | Select-Object -ExpandProperty DistinguishedName
    }
    <#
    while ($Binding.HasSucceeded -eq $False) {
        Write-Output ""
        Write-Output " #################################### "
        Write-Host "   Error en enlazar el equipo al AD   " -ForegroundColor Red -BackgroundColor Black
        Write-Output " #################################### "
        Write-Output ""
        $Global:cred = Get-Credential -Message "Ingresar Credenciales, Nombre.Apellido"
        #Write-Host "  Presione Enter para Intentar de Nuevo " -ForegroundColor Yellow -BackgroundColor Black
        #Write-Output ""
        #$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $Global:Binding = Add-Computer -DomainName "$1.infra.d" `
            -Credential $cred -Force -Options JoinWithNewName,AccountCreate `
            -WarningAction SilentlyContinue -PassThru  
    }
    #>
    
    Write-Output ""
    Write-Output " ######################################################### "
    Write-Host "  Se agrego al equipo $NCompu al Dominio $1.infra.d  " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######################################################### "

    Write-Output '2' > C:\Users\admindesp\Desktop\status.txt
    
    Pause
    timeout /t 10
    Restart-Computer

    # _____________________________________________________________________________________________________
}