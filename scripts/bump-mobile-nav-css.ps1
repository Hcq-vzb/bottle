$SiteRoot = Split-Path $PSScriptRoot -Parent
$n = 0
Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    if ($c -notmatch 'mobile-nav-search-fix\.css') { return }
    if ($c -match 'mobile-nav-search-fix\.css\?v=20260606') { return }
    $c = $c -replace 'mobile-nav-search-fix\.css\?v=[^"]+', 'mobile-nav-search-fix.css?v=20260606'
    [System.IO.File]::WriteAllText($_.FullName, $c, [System.Text.UTF8Encoding]::new($false))
    $n++
}
Write-Host "Updated $n files."
