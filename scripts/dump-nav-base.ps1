$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$i = $c.IndexOf('#c_navigation_0061635239687823{')
Write-Host $c.Substring($i, 800)
