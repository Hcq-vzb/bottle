$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$idx = 0
while (($j = $c.IndexOf('@media', $idx)) -ge 0) {
    $end = $c.IndexOf('}', $j)
    $depth = 0
    $k = $j
    while ($k -lt $c.Length) {
        if ($c[$k] -eq '{') { $depth++ }
        elseif ($c[$k] -eq '}') {
            $depth--
            if ($depth -eq 0) {
                $end = $k
                break
            }
        }
        $k++
    }
    $block = $c.Substring($j, $end - $j + 1)
    if ($block -match 'e_bannerD-1|1080-1647501045930') {
        Write-Host $block.Substring(0, [Math]::Min(1200, $block.Length))
        Write-Host '===='
    }
    $idx = $j + 1
}
