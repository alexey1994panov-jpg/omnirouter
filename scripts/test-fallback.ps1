$ErrorActionPreference='Stop'
$created=@()
try {
  $null=& "$PSScriptRoot\omni-api.ps1" -Path /api/keys/857175d4-ca6a-4285-8ccc-addc98d52810 -Method Patch -Body @{allowedCombos=@('DSH-Coding','DSH-Analysis','DSH-Fast','DSH-Auto','DSH-Fallback-Test','DSH-Unavailable-Test')}
  foreach($test in @(@{name='DSH-Fallback-Test';allDown=$false},@{name='DSH-Unavailable-Test';allDown=$true})) {
    $first=@{kind='model';model='kr/qwen3-coder-next';allowedConnectionIds=@('00000000-0000-4000-8000-000000000001')}
    $second=@{kind='model';model='kr/claude-haiku-4.5'}
    if($test.allDown){$second.allowedConnectionIds=@('00000000-0000-4000-8000-000000000002')}
    $body=@{name=$test.name;models=@($first,$second);strategy='priority';config=@{maxRetries=0;failoverBeforeRetry=$true;healthCheckEnabled=$true;targetTimeoutMs=20000}}
    $r=& "$PSScriptRoot\omni-api.ps1" -Path /api/combos -Method Post -Body $body
    $j=$r.Content|ConvertFrom-Json
    $id=if($j.combo){$j.combo.id}else{$j.id}
    if(!$id){throw 'Created combo ID absent'}
    $created+=$id
    try {
      $r=& "$PSScriptRoot\omni-api.ps1" -Inference -Path /v1/chat/completions -Method Post -Body @{model=$test.name;stream=$false;max_tokens=32;messages=@(@{role='user';content='Reply exactly FALLBACK_OK'})}
      $j=$r.Content|ConvertFrom-Json
      [pscustomobject]@{Test=$test.name;Status=$r.StatusCode;Model=$j.model;Text=$j.choices[0].message.content}|ConvertTo-Json -Compress
    } catch {
      $response=$_.Exception.Response
      if(!$response){throw}
      $reader=New-Object IO.StreamReader($response.GetResponseStream())
      [pscustomobject]@{Test=$test.name;Status=[int]$response.StatusCode;Error=$reader.ReadToEnd()}|ConvertTo-Json -Compress
    }
  }
} finally {
  $residual=@()
  try {
    foreach($id in $created){
      try{$r=& "$PSScriptRoot\omni-api.ps1" -Path "/api/combos/$id" -Method Delete; "temporary_combo_removed=$($r.StatusCode)"}
      catch{$residual+=$id; Write-Warning "Temporary combo cleanup failed: $id"}
    }
  } finally {
    $r=& "$PSScriptRoot\omni-api.ps1" -Path /api/keys/857175d4-ca6a-4285-8ccc-addc98d52810 -Method Patch -Body @{allowedCombos=@('DSH-Coding','DSH-Analysis','DSH-Fast','DSH-Auto')}
    "production_key_policy_restored=$($r.StatusCode)"
  }
  if($residual.Count){throw "Residual temporary combo IDs: $($residual -join ', ')"}
}
