$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$i = 0
$n = 0
while (($j = $c.IndexOf('p_navButton', $i)) -ge 0 -and $n -lt 20) {
    $s = [Math]::Max(0, $j - 250)
    $e = [Math]::Min($c.Length, $j + 300)
    Write-Host $c.Substring($s, $e - $s)
    Write-Host '===='
    $i = $j + 1
    $n++
}
