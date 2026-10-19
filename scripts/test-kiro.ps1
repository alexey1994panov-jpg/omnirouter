$ErrorActionPreference='Stop'
$created=@()
try {
  $null=& "$PSScriptRoot\omni-api.ps1" -Path /api/keys/857175d4-ca6a-4285-8ccc-addc98d52810 -Method Patch -Body @{allowedCombos=@('DSH-Coding','DSH-Analysis','DSH-Fast','DSH-Auto','DSH-Kiro-Test')}
  foreach($model in 'kr/claude-haiku-4.5','kr/qwen3-coder-next') {
    $r=& "$PSScriptRoot\omni-api.ps1" -Path /api/combos -Method Post -Body @{name='DSH-Kiro-Test';models=@(@{kind='model';model=$model});strategy='priority';config=@{maxRetries=0;targetTimeoutMs=30000}}
    $j=$r.Content|ConvertFrom-Json
    $id=if($j.combo){$j.combo.id}else{$j.id}
    $created+=$id
    try {
      $body=@{model='DSH-Kiro-Test';stream=$false;max_tokens=128;messages=@(@{role='user';content='Call add with a=2 and b=3.'});tools=@(@{type='function';function=@{name='add';description='Add two integers';parameters=@{type='object';properties=@{a=@{type='integer'};b=@{type='integer'}};required=@('a','b')}}});tool_choice='required'}
      $r=& "$PSScriptRoot\omni-api.ps1" -Inference -Path /v1/chat/completions -Method Post -Body $body
      $j=$r.Content|ConvertFrom-Json
      [pscustomobject]@{Model=$model;Status=$r.StatusCode;Calls=$j.choices[0].message.tool_calls;Text=$j.choices[0].message.content}|ConvertTo-Json -Depth 6 -Compress
    } catch {
      $resp=$_.Exception.Response
      if(!$resp){throw}
      $reader=New-Object IO.StreamReader($resp.GetResponseStream())
      [pscustomobject]@{Model=$model;Status=[int]$resp.StatusCode;Error=$reader.ReadToEnd()}|ConvertTo-Json -Compress
    }
    $null=& "$PSScriptRoot\omni-api.ps1" -Path "/api/combos/$id" -Method Delete
    $created=@()
  }
} finally {
  $residual=@()
  try {
    foreach($id in $created){
      try{$null=& "$PSScriptRoot\omni-api.ps1" -Path "/api/combos/$id" -Method Delete}
      catch{$residual+=$id; Write-Warning "Temporary combo cleanup failed: $id"}
    }
  } finally {
    $null=& "$PSScriptRoot\omni-api.ps1" -Path /api/keys/857175d4-ca6a-4285-8ccc-addc98d52810 -Method Patch -Body @{allowedCombos=@('DSH-Coding','DSH-Analysis','DSH-Fast','DSH-Auto')}
  }
  if($residual.Count){throw "Residual temporary combo IDs: $($residual -join ', ')"}
}
