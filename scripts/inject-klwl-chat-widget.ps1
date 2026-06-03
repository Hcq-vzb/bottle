# Inject KlWL chat widget on pages with floating saf-online customer service
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$cssTagTpl = '<link type="text/css" rel="stylesheet" href="{0}npublic/css/klwl-chat-widget.css?v=20260601">'
$prefillTagTpl = '<script src="{0}npublic/js/whatsapp-prefill.js?v=20260613"></script>'
$jsTagTpl = '<script src="{0}npublic/js/klwl-chat-widget.js?v=20260613"></script>'
$marker = 'klwl-chat-widget'
$prefillMarker = 'whatsapp-prefill.js'

$count = 0

Get-ChildItem -Path $SiteRoot -Recurse -Include *.html -File |
    Where-Object { $_.FullName -notmatch '\\scripts\\' } |
    ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        if ($content -notmatch '<saf-online') { return }
        if ($content -match $marker) { return }

        $rel = $_.FullName.Substring($SiteRoot.Length + 1)
        $depth = ([regex]::Matches($rel, '\\')).Count
        $prefix = if ($depth -eq 0) { '' } else { '../' * $depth }

        $cssTag = $cssTagTpl -f $prefix
        $prefillTag = $prefillTagTpl -f $prefix
        $jsTag = $jsTagTpl -f $prefix

        if ($content -match '<link type="text/css" rel="stylesheet" href="[^"]*popbox-close-fix\.css">') {
            $content = $content -replace '(<link type="text/css" rel="stylesheet" href="[^"]*popbox-close-fix\.css">)', "`$1`n    $cssTag"
        } elseif ($content -match '<link type="text/css" rel="stylesheet" href="[^"]*whatsapp-header-btn\.css">') {
            $content = $content -replace '(<link type="text/css" rel="stylesheet" href="[^"]*whatsapp-header-btn\.css">)', "`$1`n    $cssTag"
        } elseif ($content -match '</head>') {
            $content = $content -replace '(</head>)', "    $cssTag`n`$1"
        }

        if ($content -match '<script src="[^"]*popbox-close-fix\.js"></script>') {
            if ($content -notmatch $prefillMarker) {
                $content = $content -replace '(<script src="[^"]*popbox-close-fix\.js"></script>)', "`$1`n    $prefillTag"
            }
            $content = $content -replace '(<script src="[^"]*klwl-chat-widget\.js[^"]*"></script>)', $jsTag
            if ($content -notmatch 'klwl-chat-widget\.js') {
                $content = $content -replace '(<script src="[^"]*whatsapp-prefill\.js[^"]*"></script>)', "`$&`n    $jsTag"
                if ($content -notmatch 'klwl-chat-widget\.js') {
                    $content = $content -replace '(<script src="[^"]*popbox-close-fix\.js"></script>)', "`$1`n    $jsTag"
                }
            }
        } elseif ($content -match '</body>') {
            if ($content -notmatch $prefillMarker) {
                $content = $content -replace '(</body>)', "    $prefillTag`n`$1"
            }
            $content = $content -replace '(</body>)', "    $jsTag`n`$1"
        }

        [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
        $count++
    }

Write-Host "Injected klwl-chat-widget into $count HTML files."
