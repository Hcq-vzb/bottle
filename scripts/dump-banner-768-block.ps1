$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$start = $c.IndexOf('@media screen and (max-width:768px){#c_static_001_P_1080-1647501045930')
if ($start -lt 0) { Write-Host 'not found'; exit }
$depth = 0
$i = $start
while ($i -lt $c.Length) {
    if ($c[$i] -eq '{') { $depth++ }
    elseif ($c[$i] -eq '}') {
        $depth--
        if ($depth -eq 0) {
            Write-Host $c.Substring($start, $i - $start + 1)
            break
        }
    }
    $i++
}
