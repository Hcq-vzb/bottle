$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$matches = [regex]::Matches($c, '#c_navigation_0061635239687823[^#{]+svg[^}]{0,120}')
foreach ($m in $matches) {
    Write-Host $m.Value
    Write-Host '---'
}
