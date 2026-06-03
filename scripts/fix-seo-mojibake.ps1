$SiteRoot = Split-Path $PSScriptRoot -Parent
$n = 0
Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    if ($c -notmatch '鈥') { return }
    $c2 = $c -replace '鈥\?', ' - '
    if ($c2 -ne $c) {
        [System.IO.File]::WriteAllText($_.FullName, $c2, [System.Text.UTF8Encoding]::new($false))
        $n++
    }
}
Write-Host "Fixed mojibake in $n files."
