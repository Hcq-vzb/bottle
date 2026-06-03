$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$nav = 'c_navigation_0061635239687823'
foreach ($pat in @('cbox-23-0', 'cbox-14-1', 'e_container-14', 'max-width:768px')) {
    Write-Host "=== searching $pat near $nav ==="
    $idx = 0
    $count = 0
    while (($j = $c.IndexOf($nav, $idx)) -ge 0 -and $count -lt 30) {
        $end = [Math]::Min($c.Length, $j + 800)
        $chunk = $c.Substring($j, $end - $j)
        if ($chunk -match $pat) {
            Write-Host $chunk
            Write-Host '----'
            $count++
        }
        $idx = $j + 1
    }
}
