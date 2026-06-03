$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$needle = 'e_image-15{margin-left:0}'
$j = $c.IndexOf($needle)
Write-Host $c.Substring($j, 2000)
