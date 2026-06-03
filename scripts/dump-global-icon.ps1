$c = [IO.File]::ReadAllText("$PSScriptRoot\..\npublic\libs\css\ceccbootstrap.min.css,global8456.css")
foreach ($pat in @('.icon{', '.icon ', 'svg path', 'svg{fill', '.p_openIcon')) {
    $idx = 0
    $n = 0
    while (($j = $c.IndexOf($pat, $idx)) -ge 0 -and $n -lt 3) {
        Write-Host $c.Substring([Math]::Max(0,$j-40), [Math]::Min(200, $c.Length - [Math]::Max(0,$j-40)))
        Write-Host '---'
        $idx = $j + 1
        $n++
    }
}
