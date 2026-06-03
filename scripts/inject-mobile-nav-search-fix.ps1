# Inject mobile nav fix + hide search on pages with site header navigation
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$cssTagTpl = '<link type="text/css" rel="stylesheet" href="{0}npublic/css/mobile-nav-search-fix.css?v=20260609">'
$jsNavTpl = '<script src="{0}npublic/js/mobile-nav-fix.js?v=20260609"></script>'
$jsSearchTpl = '<script src="{0}npublic/js/disable-search.js?v=20260604"></script>'
$marker = 'mobile-nav-search-fix'

$count = 0

Get-ChildItem -Path $SiteRoot -Recurse -Include *.html -File |
    Where-Object { $_.FullName -notmatch '\\scripts\\' } |
    ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        if ($content -notmatch 'c_navigation_0061635239687823|e_navigationA-16') { return }
        if ($content -match $marker) { return }

        $rel = $_.FullName.Substring($SiteRoot.Length + 1)
        $depth = ([regex]::Matches($rel, '\\')).Count
        $prefix = if ($depth -eq 0) { '' } else { '../' * $depth }

        $cssTag = $cssTagTpl -f $prefix
        $jsNav = $jsNavTpl -f $prefix
        $jsSearch = $jsSearchTpl -f $prefix

        if ($content -match '<link type="text/css" rel="stylesheet" href="[^"]*whatsapp-header-btn\.css">') {
            $content = $content -replace '(<link type="text/css" rel="stylesheet" href="[^"]*whatsapp-header-btn\.css">)', "`$1`n    $cssTag"
        } elseif ($content -match '<link type="text/css" rel="stylesheet" href="[^"]*klwl-chat-widget\.css') {
            $content = $content -replace '(<link type="text/css" rel="stylesheet" href="[^"]*klwl-chat-widget\.css[^"]*">)', "`$1`n    $cssTag"
        } elseif ($content -match '</head>') {
            $content = $content -replace '(</head>)', "    $cssTag`n`$1"
        }

        if ($content -match '</body>') {
            $content = $content -replace '(</body>)', "    $jsNav`n    $jsSearch`n`$1"
        }

        [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
        $count++
    }

Write-Host "Injected mobile-nav-search-fix into $count HTML files."
