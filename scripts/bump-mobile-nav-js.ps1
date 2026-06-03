$SiteRoot = Split-Path $PSScriptRoot -Parent
$n = 0
Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    if ($c -match 'mobile-nav-fix\.js\?v=20260605') { return }
    if ($c -notmatch 'mobile-nav-fix\.js') { return }
    $c = $c -replace 'mobile-nav-fix\.js\?v=[^"]+', 'mobile-nav-fix.js?v=20260605'
    [System.IO.File]::WriteAllText($_.FullName, $c, [System.Text.UTF8Encoding]::new($false))
    $n++
}
Write-Host "Updated $n files."
