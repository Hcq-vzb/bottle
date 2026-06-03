$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
foreach ($pat in @('liuyantanceng','hideOnline','showOnline','saf-onlinebtn','saf-online{')) {
    $idx = 0
    while (($j = $c.IndexOf($pat, $idx)) -ge 0) {
        Write-Host "=== $pat @ $j ==="
        Write-Host $c.Substring([Math]::Max(0,$j-80), [Math]::Min(500, $c.Length - [Math]::Max(0,$j-80)))
        $idx = $j + 1
    }
}
