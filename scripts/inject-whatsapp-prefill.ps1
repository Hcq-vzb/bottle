# Inject whatsapp-prefill.js on pages with WhatsApp links (before klwl-chat-widget when present)
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$Version = '20260613'
)

$Utf8 = [System.Text.UTF8Encoding]::new($false)
$marker = 'whatsapp-prefill.js'
$jsTagTpl = '<script src="{0}npublic/js/whatsapp-prefill.js?v={1}"></script>'
$count = 0

Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    if ($rel -match '^scripts/') { return }

    $content = [System.IO.File]::ReadAllText($_.FullName)
    if ($content -match $marker) { return }
    if ($content -notmatch 'wa\.me|api\.whatsapp\.com|wa-consult-btn|whatsapp_top_btn') { return }

    $depth = ([regex]::Matches($rel, '\\')).Count
    $prefix = if ($depth -eq 0) { '' } else { '../' * $depth }
    $jsTag = $jsTagTpl -f $prefix, $Version

    if ($content -match '<script src="[^"]*klwl-chat-widget\.js') {
        $content = $content -replace '(<script src="[^"]*klwl-chat-widget\.js[^"]*"></script>)', "$jsTag`n    `$1"
    } elseif ($content -match '</body>') {
        $content = $content -replace '(</body>)', "    $jsTag`n`$1"
    } else {
        return
    }

    [System.IO.File]::WriteAllText($_.FullName, $content, $Utf8)
    $count++
}

Write-Host "Injected whatsapp-prefill.js into $count HTML files."
