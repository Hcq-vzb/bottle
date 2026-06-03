# Remove non-English language site (lang/*) and its dedicated assets (intelling/*)
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$targets = @(
    (Join-Path $SiteRoot 'lang'),
    (Join-Path $SiteRoot 'intelling')
)

foreach ($path in $targets) {
    if (Test-Path $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Host "Removed: $path"
    } else {
        Write-Host "Skip (not found): $path"
    }
}

# Remove legacy CMS language remap (hn -> es) from English pages
$hnBlock = @"
    if(window.tenant && window.tenant.language == 'hn'){
        window.tenant.language = 'es'
    }
"@

$n = 0
Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    if ($_.FullName -match '[\\/]scripts[\\/]node_modules[\\/]') { return }
    $c = [System.IO.File]::ReadAllText($_.FullName)
    if ($c -notmatch [regex]::Escape($hnBlock.Trim())) { return }
    $c = $c.Replace($hnBlock, '')
    [System.IO.File]::WriteAllText($_.FullName, $c, [System.Text.UTF8Encoding]::new($false))
    $n++
}
Write-Host "Removed hn->es language remap from $n HTML files."
