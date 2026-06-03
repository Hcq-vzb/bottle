$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$block = 'c_static_001_P_1080-1647501045930'
$idx = 0
$n = 0
while (($j = $c.IndexOf($block, $idx)) -ge 0 -and $n -lt 40) {
    $s = [Math]::Max(0, $j)
    $chunk = $c.Substring($s, [Math]::Min(400, $c.Length - $s))
    if ($chunk -match '768|1024|100vh|height|max-height|min-height|margin-top') {
        Write-Host $chunk
        Write-Host '---'
        $n++
    }
    $idx = $j + 1
}
