$ErrorActionPreference='Stop'
$failed=0
function Check([string]$Name,[bool]$Passed,[object]$Evidence){
  if(!$Passed){$script:failed++}
  [pscustomobject]@{Check=$Name;Status=if($Passed){'PASS'}else{'FAIL'};Evidence=$Evidence}|ConvertTo-Json -Depth 6 -Compress
}
$listeners=@(Get-NetTCPConnection -LocalPort 20128 -State Listen)
Check 'Loopback listener' ($listeners.Count -gt 0 -and @($listeners|Where-Object LocalAddress -ne '127.0.0.1').Count -eq 0) @($listeners.LocalAddress)
$r=Invoke-WebRequest http://127.0.0.1:20128/api/health -UseBasicParsing
Check 'Health' ($r.StatusCode -eq 200) $r.StatusCode
try{$null=Invoke-WebRequest http://127.0.0.1:20128/v1/models -UseBasicParsing; $status=200}catch{$status=[int]$_.Exception.Response.StatusCode}
Check 'Anonymous access denied' ($status -eq 401) $status
try{$null=Invoke-WebRequest http://127.0.0.1:20128/api/auth/login -Method Post -ContentType application/json -Body '{"password":"CHANGEME"}' -UseBasicParsing;$status=200}catch{$status=[int]$_.Exception.Response.StatusCode}
Check 'Default password rejected' ($status -eq 401) $status
$routes=@('DSH-Auto','DSH-Sonnet','DSH-DeepSeek','DSH-Qwen','DSH-MiniMax','DSH-Haiku','DSH-GLM')
$r=& "$PSScriptRoot\omni-api.ps1" -Inference -Path /v1/models
$ids=@(($r.Content|ConvertFrom-Json).data.id)
Check 'Only the documented DSH models exposed' (@(Compare-Object ($routes|Sort-Object) ($ids|Sort-Object)).Count -eq 0) $ids
# DSH-GLM is verified by test-glm.ps1 instead: its free tier answers 429 in bursts.
$liveRoutes=@($routes | Where-Object { $_ -ne 'DSH-GLM' })
foreach($route in $liveRoutes){
  $r=& "$PSScriptRoot\omni-api.ps1" -Inference -Path /v1/chat/completions -Method Post -Body @{model=$route;stream=$false;max_tokens=80;messages=@(@{role='user';content='Return only this JavaScript function, with no markdown and no explanation: (a,b)=>a+b'})}
  $j=$r.Content|ConvertFrom-Json
  $answer=$j.choices[0].message.content
  Check "$route coding generation" ($r.StatusCode -eq 200 -and ($answer -replace '\s','') -match '\(a,b\)=>a\+b') @{model=$j.model;answer=$answer}
  $body=@{model=$route;stream=$false;max_tokens=160;messages=@(@{role='user';content='Call add with a=2 and b=3. Use the tool, no text.'});tools=@(@{type='function';function=@{name='add';description='Add two integers';parameters=@{type='object';properties=@{a=@{type='integer'};b=@{type='integer'}};required=@('a','b')}}});tool_choice='required'}
  $r=& "$PSScriptRoot\omni-api.ps1" -Inference -Path /v1/chat/completions -Method Post -Body $body
  $j=$r.Content|ConvertFrom-Json
  $call=$j.choices[0].message.tool_calls[0]
  $argsValue=$call.function.arguments|ConvertFrom-Json
  Check "$route tool calling" ($call.function.name -eq 'add' -and $argsValue.a -eq 2 -and $argsValue.b -eq 3) @{model=$j.model;function=$call.function.name;arguments=$argsValue}
}
$r=& "$PSScriptRoot\omni-api.ps1" -Path /api/combos
$combos=($r.Content|ConvertFrom-Json).combos
$targets=@($combos.models.model)
$snapshot=Get-Content -Raw (Join-Path $PSScriptRoot '../docs/omniroute-dsh/configuration.json')|ConvertFrom-Json
$routeMatch=$combos.Count -eq $snapshot.omniroute.routes.Count
foreach($expected in $snapshot.omniroute.routes){
  $actual=@($combos|Where-Object name -eq $expected.name)
  if($actual.Count -ne 1 -or $actual[0].strategy -ne $expected.strategy -or (@($actual[0].models.model) -join '|') -ne (@($expected.models) -join '|')){$routeMatch=$false}
}
Check 'Exact documented routes and target order' $routeMatch $targets
$r=& "$PSScriptRoot\omni-api.ps1" -Path /api/providers
$providers=($r.Content|ConvertFrom-Json).connections
Check 'Codex subscription disabled' (@($providers|Where-Object {$_.provider -eq 'codex' -and $_.isActive}).Count -eq 0) 'No active Codex connection'
$r=& "$PSScriptRoot\omni-api.ps1" -Path /api/keys
$key=(($r.Content|ConvertFrom-Json).keys|Where-Object id -eq '857175d4-ca6a-4285-8ccc-addc98d52810')
$expectedConnections=@('287b4c9a-1f2f-4834-8615-e9575efd058f','cfa776c1-5906-4cd5-acda-a781bc5a5d4b')
Check 'DSH key permits Kiro and GLM only' ($key.allowedConnections.Count -eq $expectedConnections.Count -and @(Compare-Object ($expectedConnections|Sort-Object) (@($key.allowedConnections)|Sort-Object)).Count -eq 0) $key.allowedConnections
$x=& "$PSScriptRoot\dsh-rpc.ps1"
$namespaces=$x.result.value.namespaces
$default=($namespaces|Where-Object ns -eq 'agent-default-model').value
$omni=($namespaces|Where-Object ns -eq 'llm-pi-ai').value.providers.omniroute
$modelIds=@($omni.models.id)
$providerOk=($null -ne $omni -and $omni.baseURL -eq 'http://127.0.0.1:20128/v1' -and (@(Compare-Object ($routes|Sort-Object) ($modelIds|Sort-Object)).Count -eq 0))
$defaultOk=($default.provider -ne 'omniroute' -or $modelIds -contains $default.model)
Check 'OmniRoute provider and default model' ($providerOk -and $defaultOk) @{baseURL=$omni.baseURL;models=$modelIds;default="$($default.provider)/$($default.model)"}
if($failed){throw "$failed verification checks failed"}
