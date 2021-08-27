#------ Este Bloque le dice a Windows que no se suspenda ni apague la pantalla mientras el script se ejecuta--------
$code=@' 
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
  public static extern void SetThreadExecutionState(uint esFlags);
'@

$ste = Add-Type -memberDefinition $code -name System -namespace Win32 -passThru
$ES_CONTINUOUS = [uint32]"0x80000000" 
#$ES_AWAYMODE_REQUIRED = [uint32]"0x00000040" 
$ES_DISPLAY_REQUIRED = [uint32]"0x00000002"
$ES_SYSTEM_REQUIRED = [uint32]"0x00000001"

$ste::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED)

#$ste::SetThreadExecutionState($ES_CONTINUOUS)

#-------------------------------------------------------------------------------------------------------------------

# _________________________ Deshabilito Windows Update Poronga ____________________________
Stop-Service wuauserv -Force
Set-Service wuauserv -StartupType Disabled

$CI = $(Test-Connection google.com -Count 2 -Quiet -ErrorAction SilentlyContinue)

while("$CI" -eq 'False'){
    Write-Output ""
    Write-Output " ###################################### "
    Write-Host "        Conectate a Internet . . .      " -ForegroundColor Red -BackgroundColor Black
    Write-Output " ###################################### "
    Pause
    $CI = $(Test-Connection google.com -Count 2 -Quiet -ErrorAction SilentlyContinue)
    Write-Output ""
}

$token = "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"
$headers = @{Authorization = "token $($token)"}
Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/ProcessUpdateRegional.ps1" -UseBasicParsing -OutFile "$PSScriptRoot\ProcessUpdateRegional.ps1"

& $PSScriptRoot\ProcessUpdateRegional.ps1
