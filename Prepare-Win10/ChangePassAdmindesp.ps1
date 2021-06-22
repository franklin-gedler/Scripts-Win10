function ChangePassAdmindesp {
    param (
        $1
    )

    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################

    # Borro las claves que me creo el NTlite
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "AutoAdminLogon"
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultUserName"

    # capturo el serial del equipo
    $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    while (!$SCompu) {
        $Global:SCompu = (Get-WmiObject win32_bios).SerialNumber
    }

    # le Inyecto la clave que va con admindesp
    $p = ConvertTo-SecureString "*+$1#$SCompu*" -AsPlainText -Force
    $u = (Get-LocalUser).Name[0]
    Set-LocalUser -Name $u -Password $p -PasswordNeverExpires 1
    #Write-Host "Valor de u: " $u   # Esto es para ver que valor toma $u
    #Pause
    
}
