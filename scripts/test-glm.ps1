param([int]$Attempts=3,[int]$DelaySeconds=10)
# Live probe for the Z.AI GLM fallback. Its free tier answers 429 in bursts,
# so this is a separate check rather than part of verify.ps1.
$ErrorActionPreference='Stop'
$results=@()
for($i=1;$i -le $Attempts;$i++){
  $body=@{
    model='DSH-GLM';stream=$false;max_tokens=700
    messages=@(@{role='user';content='Call add with a=2 and b=3. Use the tool, no text.'})
    tools=@(@{type='function';function=@{name='add';description='Add two integers';parameters=@{type='object';properties=@{a=@{type='integer'};b=@{type='integer'}};required=@('a','b')}}})
    tool_choice='required'
  }
  try{
    $r=& "$PSScriptRoot\omni-api.ps1" -Inference -Path /v1/chat/completions -Method Post -Body $body
    $j=$r.Content|ConvertFrom-Json
    $call=$j.choices[0].message.tool_calls[0]
    $argsValue=$call.function.arguments|ConvertFrom-Json
    $ok=($call.function.name -eq 'add' -and $argsValue.a -eq 2 -and $argsValue.b -eq 3)
    $results+=[pscustomobject]@{attempt=$i;status=$r.StatusCode;ok=$ok;model=$j.model;arguments=$argsValue}
    if($ok){break}
  } catch {
    $resp=$_.Exception.Response
    $status=if($resp){[int]$resp.StatusCode}else{0}
    $text=''
    if($resp){$reader=New-Object IO.StreamReader($resp.GetResponseStream());$text=$reader.ReadToEnd()}
    $results+=[pscustomobject]@{attempt=$i;status=$status;ok=$false;error=$text}
  }
  if($i -lt $Attempts){Start-Sleep -Seconds $DelaySeconds}
}
$results|ForEach-Object{$_|ConvertTo-Json -Depth 6 -Compress}
if(-not ($results|Where-Object ok)){
  throw 'DSH-GLM did not answer: the Z.AI free tier is likely cooling down. Retry later; this does not indicate a configuration error.'
}
