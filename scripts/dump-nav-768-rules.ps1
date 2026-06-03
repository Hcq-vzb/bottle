$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$nav = 'c_navigation_0061635239687823'
$idx = $c.IndexOf('@media screen and (max-width:768px){#c_grid-116273709439191')
Write-Host "start=$idx"
if ($idx -ge 0) {
    $chunk = $c.Substring($idx, [Math]::Min(12000, $c.Length - $idx))
    $rules = [regex]::Matches($chunk, '#c_navigation_0061635239687823[^{]+\{[^}]+\}')
    foreach ($m in $rules) { Write-Host $m.Value; Write-Host '---' }
}
