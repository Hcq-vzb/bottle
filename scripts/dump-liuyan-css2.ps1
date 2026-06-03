$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$j = $c.IndexOf('liuyantanceng')
Write-Host $c.Substring($j, 800)
