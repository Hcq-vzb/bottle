$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\site8456.css")
foreach ($pat in @('liuyantanceng','saf-online','hideOnline','showOnline','768')) {
    if ($c -match [regex]::Escape($pat)) { Write-Host "contains $pat" }
}
$idx = 0
while (($j = $c.IndexOf('liuyantanceng', $idx)) -ge 0) {
    Write-Host $c.Substring([Math]::Max(0,$j-60), [Math]::Min(400, $c.Length - [Math]::Max(0,$j-60)))
    Write-Host '---'
    $idx = $j + 1
}
$idx = 0
while (($j = $c.IndexOf('saf-online', $idx)) -ge 0) {
    Write-Host $c.Substring([Math]::Max(0,$j-80), [Math]::Min(450, $c.Length - [Math]::Max(0,$j-80)))
    Write-Host '---'
    $idx = $j + 1
}
