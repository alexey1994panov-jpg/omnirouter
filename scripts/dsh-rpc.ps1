param([string]$Method='settings/describe', [hashtable]$Arguments=@{})
$ErrorActionPreference='Stop'
$log=Get-Content -Raw 'C:\Users\PanovAA\AppData\Roaming\dsh-desktop\logs\harness.log'
$urls=[regex]::Matches($log,'http://127\.0\.0\.1:\d+/\?token=[A-Za-z0-9_-]+')
if(!$urls.Count){throw 'DSH launch URL not found'}
$launch=$urls[$urls.Count-1].Value
$base=([uri]$launch).GetLeftPart([System.UriPartial]::Authority)
$session=New-Object Microsoft.PowerShell.Commands.WebRequestSession
$null=Invoke-WebRequest $launch -WebSession $session -UseBasicParsing
$body=@{type='client-request';rpcId=[guid]::NewGuid().ToString();method=$Method;payload=@{args=$Arguments}}|ConvertTo-Json -Depth 30 -Compress
$response=Invoke-RestMethod "$base/api/$Method" -Method Post -WebSession $session -ContentType application/json -Body ([Text.Encoding]::UTF8.GetBytes($body))
$response
