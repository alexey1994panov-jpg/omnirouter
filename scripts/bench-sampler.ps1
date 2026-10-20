param([int]$IntervalSeconds=60,[string]$OutFile='')
# Samples Kiro quota, request counts and OmniRoute health during a long run.
# Writes CSV rows so the run can be plotted afterwards. Uses Invoke-RestMethod,
# so it also works where Invoke-WebRequest stumbles on the console buffer.
$ErrorActionPreference='Continue'
$root=Split-Path $PSScriptRoot -Parent
if(-not $OutFile){$OutFile=Join-Path $root 'bench\samples.csv'}
$backup=Join-Path $env:USERPROFILE 'OmniRoute-DSH-Backups\20261019-omniroute-dsh-prechange'
$kiro='287b4c9a-1f2f-4834-8615-e9575efd058f'

$dir=Split-Path $OutFile -Parent
if(-not (Test-Path $dir)){New-Item -ItemType Directory -Path $dir -Force|Out-Null}
if(-not (Test-Path $OutFile)){
  'timestamp,kiroUsed,kiroRemaining,kiroRequests,glmRequests,health'|Set-Content -Encoding utf8 $OutFile
}

$secure=ConvertTo-SecureString ((Get-Content -Raw (Join-Path $backup 'dashboard-password.dpapi')).Trim())
$ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try{
  $pw=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
  while($true){
    $health='down'; $used=''; $remaining=''; $kiroReq=''; $glmReq=''
    try{
      $ws=$null
      $null=Invoke-RestMethod 'http://127.0.0.1:20128/api/auth/login' -Method Post -ContentType 'application/json' -Body (@{password=$pw}|ConvertTo-Json -Compress) -SessionVariable ws -TimeoutSec 15
      $health='ok'
      $q=Invoke-RestMethod "http://127.0.0.1:20128/api/usage/$kiro" -WebSession $ws -TimeoutSec 15
      $used=$q.quotas.credit.used
      $remaining=$q.quotas.credit.remaining
      $today=(Get-Date).ToString('yyyy-MM-dd')
      $rows=(Invoke-RestMethod 'http://127.0.0.1:20128/api/usage/requests-by-provider-date' -WebSession $ws -TimeoutSec 15).rows
      $kiroReq=($rows|Where-Object {$_.date -eq $today -and $_.provider -eq 'kiro'}|Measure-Object -Property requests -Sum).Sum
      $glmReq=($rows|Where-Object {$_.date -eq $today -and $_.provider -eq 'glm'}|Measure-Object -Property requests -Sum).Sum
    } catch { $health='down' }
    $inv=[Globalization.CultureInfo]::InvariantCulture
    $line=[string]::Format($inv,'{0},{1},{2},{3},{4},{5}',(Get-Date).ToString('yyyy-MM-ddTHH:mm:ss'),$used,$remaining,$kiroReq,$glmReq,$health)
    $line|Add-Content -Encoding utf8 $OutFile
    Write-Output $line
    Start-Sleep -Seconds $IntervalSeconds
  }
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
  $pw=$null
}
