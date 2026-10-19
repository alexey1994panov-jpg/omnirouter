param([string]$Path='/api/health',[string]$Method='Get',[object]$Body=$null,[switch]$Inference)
$ErrorActionPreference='Stop'
$backup='C:\Users\PanovAA\OmniRoute-DSH-Backups\20261019-omniroute-dsh-prechange'
$name=if($Inference){'dsh-api-key.dpapi'}else{'dashboard-password.dpapi'}
$secure=ConvertTo-SecureString ((Get-Content -Raw "$backup\$name").Trim())
$ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
  $secret=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
  $params=@{Uri="http://127.0.0.1:20128$Path";Method=$Method;UseBasicParsing=$true;TimeoutSec=150}
  if($Inference){$params.Headers=@{Authorization="Bearer $secret"}}
  else {
    $session=New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $login=@{password=$secret}|ConvertTo-Json -Compress
    $null=Invoke-WebRequest 'http://127.0.0.1:20128/api/auth/login' -Method Post -ContentType application/json -Body $login -WebSession $session -UseBasicParsing
    $params.WebSession=$session
  }
  if($null -ne $Body){$params.ContentType='application/json';$params.Body=[Text.Encoding]::UTF8.GetBytes(($Body|ConvertTo-Json -Depth 35 -Compress))}
  Invoke-WebRequest @params
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
  $secret=$null
}
