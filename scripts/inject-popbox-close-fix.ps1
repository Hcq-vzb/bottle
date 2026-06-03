# Inject popbox close fix CSS/JS into pages that contain the online message modal
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$cssTagTpl = '<link type="text/css" rel="stylesheet" href="{0}npublic/css/popbox-close-fix.css">'
$jsTagTpl = '<script src="{0}npublic/js/popbox-close-fix.js"></script>'
$marker = 'popbox-close-fix'

$count = 0

Get-ChildItem -Path $SiteRoot -Recurse -Include *.html -File | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    if ($content -notmatch 'c_popbox-') { return }
    if ($content -match $marker) { return }

    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    $depth = ([regex]::Matches($rel, '\\')).Count
    $prefix = if ($depth -eq 0) { '' } else { '../' * $depth }

    $cssTag = $cssTagTpl -f $prefix
    $jsTag = $jsTagTpl -f $prefix

    if ($content -match '<link type="text/css" rel="stylesheet" href="css/site8456\.css') {
        $content = $content -replace '(<link type="text/css" rel="stylesheet" href="css/site8456\.css[^"]*">)', "`$1`n    $cssTag"
    } elseif ($content -match '</head>') {
        $content = $content -replace '(</head>)', "    $cssTag`n`$1"
    }

    if ($content -match '</body>') {
        $content = $content -replace '(</body>)', "    $jsTag`n`$1"
    }

    [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    $count++
}

Write-Host "Injected popbox close fix into $count HTML files."
