$SiteRoot = Split-Path $PSScriptRoot -Parent
$ver = '20260613'
$n = 0
Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    if ($c -notmatch 'klwl-chat-widget') { return }
    if ($c -match "klwl-chat-widget\.(css|js)\?v=$ver") { return }
    $c = $c -replace 'klwl-chat-widget\.css\?v=[^"]+', "klwl-chat-widget.css?v=$ver"
    $c = $c -replace 'klwl-chat-widget\.js\?v=[^"]+', "klwl-chat-widget.js?v=$ver"
    [System.IO.File]::WriteAllText($_.FullName, $c, [System.Text.UTF8Encoding]::new($false))
    $n++
}
Write-Host "Updated $n files to v=$ver."
