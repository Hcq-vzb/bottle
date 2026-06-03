$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\site8456.css")
foreach ($pat in @('liuyantanceng','hideOnline','showOnline','saf-online','saf-onlinebtn')) {
    $idx = 0
    $n = 0
    while (($j = $c.IndexOf($pat, $idx)) -ge 0 -and $n -lt 5) {
        $s = [Math]::Max(0, $j - 40)
        Write-Host $c.Substring($s, [Math]::Min(280, $c.Length - $s))
        Write-Host '---'
        $idx = $j + 1
        $n++
    }
}
