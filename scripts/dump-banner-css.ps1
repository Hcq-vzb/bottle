$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$idx = 0
$n = 0
while (($j = $c.IndexOf('e_bannerD-1', $idx)) -ge 0 -and $n -lt 25) {
    $s = [Math]::Max(0, $j - 30)
    Write-Host $c.Substring($s, [Math]::Min(350, $c.Length - $s))
    Write-Host '---'
    $idx = $j + 1
    $n++
}
