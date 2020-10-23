$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
cd $currentdirectory
(pwd).Path
#######################################################################################################################

Stop-Service wuauserv -Force -PassThru
Rename-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -NewName "WindowsUpdateold"
Start-Service wuauserv -PassThru

# _________________________________________________________________________________________________________________________

echo " ===================================="
Write-Host " Installing Net Framework Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="

Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All

# Verificar que se instalo los net framework:
# Get-WindowsOptionalFeature -Online -FeatureName "NetFX4"
# Get-WindowsOptionalFeature -Online -FeatureName "NetFX3"

# Deshabilitar framework 3.5
# Disable-WindowsOptionalFeature -Online -FeatureName "NetFx3"

echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Installing Microsoft Silverlight Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="

Start-Process -Wait -FilePath Pre\Silverlight_x64.exe -ArgumentList "/q"

echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Installing Microsoft Visual C++ 2017 Redistributable (x64) Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="

Start-Process -Wait -FilePath Pre\VC_redist.x64.exe -ArgumentList "/install /quiet /norestart"


echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Installing Tsapi-Client Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="

Start-Process -Wait -FilePath TsapiClient\setup.exe -ArgumentList "/s /f1$currentdirectory\TsapiClient\setup.iss"

echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Installing Avaya One X Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="

Start-Process -Wait -FilePath AvayaOneX\OnexAgentSetup\application\OneXAgentSetup.exe -ArgumentList "/qn"
Start-Process -Wait regedit.exe -ArgumentList "/s $currentdirectory\AvayaOneX\DisableMuteButton.reg"

echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Config. Certificate Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="

$huella = (New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "127.0.0.1" -FriendlyName "MySiteCert" -NotAfter (Get-Date).AddYears(10)).Thumbprint
$cert = (Get-ChildItem -Path cert:\LocalMachine\My\$huella)
Export-Certificate -Cert $cert -FilePath $currentdirectory\CertificadoSSL\cert.cer
$cert = (Get-ChildItem -Path $currentdirectory\CertificadoSSL\cert.cer)
$cert | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root

Copy-Item CertificadoSSL\OneXAgentAPIConfig.bat 'C:\Program Files (x86)\Avaya\Avaya one-X Agent' -Force

Start-Process -Wait cmd.exe -ArgumentList "C:\Program Files (x86)\Avaya\Avaya one-X Agent\OneXAgentAPIConfig.bat 60001 1 $huella"

Start-Process -Wait regedit.exe -ArgumentList "/s $currentdirectory\CertificadoSSL\registro_ssl.reg"

echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Installing Click to Dial Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="

Copy-Item ClickToDial\* C:\ -Force -Recurse

Start-Process C:\Nginx-1.17.8\start.bat

Start-Sleep -s 10

Start-Process C:\Nginx-1.17.8\stop.bat

Start-Process -Wait C:\nssm-2.24\createservice.bat

Start-Process -Wait C:\sslCert\sslCert.bat

Restart-Service nginx -PassThru

echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Config. CTI . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="
echo ""
echo " ------------------------------------"
Write-Host " Ingrese Numero de interno . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ------------------------------------"
echo ""
$interno = Read-Host
$interno = $interno.replace(' ' , '')

$File = "CTI\CTI.ini"
$Content = [System.IO.File]::ReadAllText("$currentdirectory\$File")
$Content = $Content.Replace('7XXXXXX', "$interno")
$Content = $Content.Trim()
[System.IO.File]::WriteAllText("$currentdirectory\$File", $Content)
Copy-Item $File C:\ -Force

echo "_________________________________________________________________________________________________________________________"

echo " ===================================="
Write-Host " Installing Global Protect Wait . . . " -ForegroundColor Yellow -BackgroundColor Black
echo " ===================================="





echo "_________________________________________________________________________________________________________________________"







echo "_________________________________________________________________________________________________________________________"






echo "_________________________________________________________________________________________________________________________"




echo "_________________________________________________________________________________________________________________________"






echo "_________________________________________________________________________________________________________________________"





echo "_________________________________________________________________________________________________________________________"





echo "_________________________________________________________________________________________________________________________"




echo "_________________________________________________________________________________________________________________________"




echo "_________________________________________________________________________________________________________________________"







Pause


#Varios comandos:
#Start-Process -Wait -FilePath "dotnetfx35.exe" -ArgumentList "/q /norestart"
#Add-WindowsCapability -Online -Name dotnetfx35 -Source $currentdirectory\dotnetfx35.exe
#Start-Service C:\Nginx-1.17.8\nginx.exe -PassThru

#New-Service -Name "Nginx" -BinaryPathName "C:\Nginx-1.17.8\nginx.exe" -StartupType Automatic


#New-Service -Name "Nginx" -BinaryPathName "C:\Nginx-1.17.8\nginx.exe" -StartupType Automatic
#Start-Service Nginx -PassThru


#(Get-Content $File).replace('7XXXXXX', "$interno") | ? {$_ -ne "" } | Set-Content $File
#Set-Content CTI\CTI.ini -Filter "7XXXXXX" -Value "$interno"