$SiteRoot = Split-Path $PSScriptRoot -Parent
$bySection = @{}
Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    $section = if ($rel -match '\\') { ($rel -split '\\')[0] } else { '(root)' }
    if (-not $bySection.ContainsKey($section)) {
        $bySection[$section] = @{ Total = 0; Empty = 0; Filled = 0; NoTag = 0 }
    }
    $bySection[$section].Total++
    if ($c -match '<meta\s+name="keywords"\s+content="([^"]*)"') {
        if ($Matches[1].Trim() -eq '') { $bySection[$section].Empty++ }
        else { $bySection[$section].Filled++ }
    } else {
        $bySection[$section].NoTag++
    }
}
$bySection.GetEnumerator() | Sort-Object Name | ForEach-Object {
    $s = $_.Value
    Write-Host ("{0,-20} total={1,4} filled={2,4} empty={3,3} noTag={4,3}" -f $_.Key, $s.Total, $s.Filled, $s.Empty, $s.NoTag)
}
