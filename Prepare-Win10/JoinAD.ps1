function JoinAD {
    param (
        $1,$2
    )

    # $1 = Pais
    # $2 = CodigoPais

    $cred = Import-CliXml -Path C:\PrepareWin10\CredSoporte_SYSTEM_DESPEGAR.xml

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

    $Global:Binding = Add-Computer -DomainName "$1.infra.d" `
        -Credential $cred -Force -Options JoinWithNewName,AccountCreate `
        -WarningAction SilentlyContinue -PassThru           
    
    #$Binding = Add-Computer -NewName "$NCompu" -DomainName ar.infra.d -Force -Credential $cred -PassThru
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

    Write-Output ""
    Write-Output " ######################################################### "
    Write-Host "  Se agrego al equipo $NCompu al Dominio $1.infra.d  " -ForegroundColor Green -BackgroundColor Black
    Write-Output " ######################################################### "
    Pause
    # _____________________________________________________________________________________________________
}