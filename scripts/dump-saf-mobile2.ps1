$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$j = $c.IndexOf('@media screen and (max-width:768px){#c_effect_109')
Write-Host $c.Substring($j, 2000)
