$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$nav = 'c_navigation_0061635239687823'
$matches = [regex]::Matches($c, '#?' + [regex]::Escape($nav) + '[^}]{0,400}')
foreach ($m in $matches) {
    if ($m.Value -match 'color:#fff|color:#FFF|color:#ffffff|fill:#fff|fill:#FFF|fill:#ffffff|fill:#fff|fill:currentColor|fill: inherit') {
        Write-Host $m.Value
        Write-Host '---'
    }
}
