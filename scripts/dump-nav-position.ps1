$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$nav = 'c_navigation_0061635239687823'
foreach ($pat in @('right:', 'cbox-23', 'e_container-23', 'e_navigationA-16{', 'e_navigationA-16 ')) {
    $idx = 0
    $n = 0
    while (($j = $c.IndexOf($nav, $idx)) -ge 0 -and $n -lt 50) {
        $end = [Math]::Min($c.Length, $j + 600)
        $chunk = $c.Substring($j, $end - $j)
        if ($chunk -match $pat) {
            Write-Host $chunk
            Write-Host '---'
            $n++
        }
        $idx = $j + 1
    }
}
