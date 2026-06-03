# Remove header search block from all HTML pages
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$pattern = '(?s)\s*<div class="nav-search h_search">\s*<div class="seabtn">.*?</div>\s*</div>\s*'
$count = 0

Get-ChildItem -Path $SiteRoot -Recurse -Include *.html -File |
    Where-Object { $_.FullName -notmatch '\\scripts\\' } |
    ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        if ($content -notmatch 'nav-search h_search') { return }
        $newContent = [regex]::Replace($content, $pattern, "`n")
        if ($newContent -eq $content) { return }
        [System.IO.File]::WriteAllText($_.FullName, $newContent, [System.Text.UTF8Encoding]::new($false))
        $count++
    }

Write-Host "Removed search block from $count HTML files."
