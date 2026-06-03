$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$needle = 'p_navButton{display:flex'
$idx = 0
while (($j = $c.IndexOf($needle, $idx)) -ge 0) {
    $s = [Math]::Max(0, $j - 400)
    Write-Host $c.Substring($s, 500)
    Write-Host '===='
    $idx = $j + 1
}
