$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
foreach ($pat in @('max-width:768px','max-width: 1024px','min-width: 769px','p_navButton{display:none','p_navButton{display:flex')) {
    $count = ([regex]::Matches($c, [regex]::Escape($pat))).Count
    Write-Host "$pat : $count"
}
