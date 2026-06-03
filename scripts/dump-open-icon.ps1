$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
foreach ($pat in @('p_openIcon', 'p_iconBox', 'p_navButton', '.icon{', 'svg{', 'fill:')) {
    $idx = 0
    $n = 0
    while (($j = $c.IndexOf($pat, $idx)) -ge 0 -and $n -lt 8) {
        $s = [Math]::Max(0, $j - 100)
        $chunk = $c.Substring($s, [Math]::Min(280, $c.Length - $s))
        if ($chunk -match 'navigation_0061635239687823|p_openIcon|p_iconBox|p_navButton') {
            Write-Host $chunk
            Write-Host '---'
            $n++
        }
        $idx = $j + 1
    }
}
