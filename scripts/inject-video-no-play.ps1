# Inject video-no-play CSS/JS into Video category pages only
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$cssTag = '<link type="text/css" rel="stylesheet" href="../npublic/css/video-no-play.css">'
$jsTag = '<script src="../npublic/js/video-no-play.js"></script>'
$marker = 'video-no-play'
$count = 0

Get-ChildItem -Path (Join-Path $SiteRoot 'video') -Filter '*.html' -File | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    if ($content -notmatch 'videoCock') { return }
    if ($content -match $marker) { return }

    if ($content -match 'popbox-close-fix\.css') {
        $content = $content -replace '(<link type="text/css" rel="stylesheet" href="\.\./npublic/css/popbox-close-fix\.css">)', "`$1`n    $cssTag"
    } elseif ($content -match '</head>') {
        $content = $content -replace '(</head>)', "    $cssTag`n`$1"
    }

    if ($content -match 'popbox-close-fix\.js') {
        $content = $content -replace '(<script src="\.\./npublic/js/popbox-close-fix\.js"></script>)', "`$1`n    $jsTag"
    } elseif ($content -match '</body>') {
        $content = $content -replace '(</body>)', "    $jsTag`n`$1"
    }

    [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    $count++
}

Write-Host "Injected video-no-play into $count Video HTML files."
