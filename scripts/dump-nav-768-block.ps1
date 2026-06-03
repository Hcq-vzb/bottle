$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
$start = $c.IndexOf('@media screen and (max-width:768px){#c_grid-116273709439191')
if ($start -lt 0) { Write-Host 'not found'; exit 1 }
$depth = 0
$i = $start
while ($i -lt $c.Length) {
    if ($c[$i] -eq '{') { $depth++ }
    elseif ($c[$i] -eq '}') {
        $depth--
        if ($depth -eq 0) {
            $block = $c.Substring($start, $i - $start + 1)
            $block -split '(?<=\})' | Where-Object { $_ -match 'c_navigation_0061635239687823' } | ForEach-Object { $_.Trim(); '---' }
            break
        }
    }
    $i++
}
