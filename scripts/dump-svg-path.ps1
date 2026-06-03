$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
foreach ($pat in @('svg path', 'svg{', '.icon path', '.icon svg', 'p_openIcon')) {
    $idx = 0
    $n = 0
    while (($j = $c.IndexOf($pat, $idx)) -ge 0 -and $n -lt 5) {
        $s = [Math]::Max(0, $j - 120)
        $chunk = $c.Substring($s, [Math]::Min(350, $c.Length - $s))
        if ($chunk -match '0061635239687823|navigationA') {
            Write-Host $chunk
            Write-Host '---'
            $n++
        }
        $idx = $j + 1
    }
}
