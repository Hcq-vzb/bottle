$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$needle = 'p_navButton{display:flex;justify-content:flex-end}'
$j = $c.IndexOf($needle)
Write-Host $c.Substring($j, 2500)
