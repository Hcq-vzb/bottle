$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$needle = 'p_navButton{display:flex;justify-content:flex-end}'
$j = $c.IndexOf($needle)
$s = [Math]::Max(0, $j - 1500)
Write-Host $c.Substring($s, 3500)
