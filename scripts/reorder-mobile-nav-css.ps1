$SiteRoot = Split-Path $PSScriptRoot -Parent
$newVersion = '20260609'
$newTagTpl = '<link type="text/css" rel="stylesheet" href="{0}npublic/css/mobile-nav-search-fix.css?v=' + $newVersion + '">'
$cssPattern = '<link type="text/css" rel="stylesheet" href="[^"]*mobile-nav-search-fix\.css\?v=[^"]+">\s*'
$jsPattern = 'mobile-nav-fix\.js\?v=[^"]+'
$n = 0

Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    if ($content -notmatch 'mobile-nav-search-fix\.css') { return }

    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    $depth = ([regex]::Matches($rel, '\\')).Count
    $prefix = if ($depth -eq 0) { '' } else { '../' * $depth }
    $newTag = $newTagTpl -f $prefix

    if ($content -match $cssPattern) {
        $content = [regex]::Replace($content, $cssPattern, '', 1)
    }

    if ($content -match '</head>') {
        $content = $content -replace '(</head>)', "    $newTag`n`$1"
    } else {
        return
    }

    if ($content -match $jsPattern) {
        $content = [regex]::Replace($content, $jsPattern, "mobile-nav-fix.js?v=$newVersion")
    }

    [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    $n++
}

Write-Host "Moved mobile-nav CSS to end of head on $n files (v=$newVersion)."
