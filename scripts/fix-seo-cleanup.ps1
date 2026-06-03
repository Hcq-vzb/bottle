# ASCII-safe cleanup: mojibake, double-encoded entities, bad news descriptions
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$Utf8 = [System.Text.UTF8Encoding]::new($false)
$Brand = 'KlWL Machinery'
$Mojibake = [string][char]0x9225 + '?'
$nMoji = 0
$nAmp = 0
$nNews = 0
$nProduct = 0

function Should-SkipHtml([string]$rel) {
    $r = $rel -replace '\\', '/'
    if ($r -match '^scripts/') { return $true }
    if ($r -match '^omo-oss-image') { return $true }
    if ($r -match 'glyphicons|iconfont') { return $true }
    return $false
}

function Get-ArticleTitleFromPageTitle([string]$pageTitle) {
    $t = $pageTitle -replace '\s\|\s*KlWL Machinery\s*$', ''
    $t = $t -replace '&amp;amp;', '&'
    $t = $t -replace '&amp;', '&'
    $t = $t -replace '&quot;', '"'
    return $t.Trim()
}

Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    if (Should-SkipHtml $rel) { return }

    $c = [System.IO.File]::ReadAllText($_.FullName)
    $orig = $c

    if ($c.Contains($Mojibake)) {
        $c = $c.Replace($Mojibake, ' - ')
        $nMoji++
    }

    if ($c -match '&amp;amp;') {
        $c = $c -replace '&amp;amp;', '&amp;'
        $nAmp++
    }

    $webPath = $rel -replace '\\', '/'
    if ($webPath -like 'news_detail/*' -and $c -match '<title>([^<]+)</title>') {
        $pageTitle = $Matches[1]
        $articleTitle = Get-ArticleTitleFromPageTitle $pageTitle
        $badDescPattern = 'KlWL Machinery\s*-\s*KlWL Machinery'
        $mDesc = [regex]::Match($c, '<meta name="description" content="([^"]*)"')
        if ($mDesc.Success -and ($mDesc.Groups[1].Value -match $badDescPattern -or $mDesc.Groups[1].Value.Length -lt 80)) {
            $newDesc = "$articleTitle. Industry news from $Brand, PET bottle blowing machine manufacturer in China."
            if ($newDesc.Length -gt 320) {
                $newDesc = $newDesc.Substring(0, 317).Trim() + '...'
            }
            $ed = $newDesc.Replace('&', '&amp;').Replace('"', '&quot;').Replace('<', '&lt;')
            $c = [regex]::Replace($c, '<meta name="description" content="[^"]*"', "<meta name=`"description`" content=`"$ed`"")
            $c = [regex]::Replace($c, '<meta property="og:description" content="[^"]*"', "<meta property=`"og:description`" content=`"$ed`"")
            $c = [regex]::Replace($c, '<meta name="twitter:description" content="[^"]*"', "<meta name=`"twitter:description`" content=`"$ed`"")
            $nNews++
        }
        $et = $pageTitle -replace '&amp;amp;', '&amp;'
        if ($et -ne $pageTitle) {
            $c = [regex]::Replace($c, '<title>[^<]*</title>', "<title>$et</title>")
            $c = [regex]::Replace($c, '<meta property="og:title" content="[^"]*"', "<meta property=`"og:title`" content=`"$et`"")
            $c = [regex]::Replace($c, '<meta name="twitter:title" content="[^"]*"', "<meta name=`"twitter:title`" content=`"$et`"")
        }
    }

    # Product pages: meta description polluted with encoded <br> or spec bullets
    $mDescProd = [regex]::Match($c, '<meta name="description" content="([^"]*)"', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($mDescProd.Success -and $mDescProd.Groups[1].Value -match '&amp;lt;br|&lt;br') {
        if ($c -match '<title>([^<]+)</title>') {
            $pageTitle = $Matches[1]
            $productName = Get-ArticleTitleFromPageTitle $pageTitle
            $newDesc = "$productName from $Brand. PET and plastic bottle blowing machine - factory direct from China, export worldwide."
            if ($newDesc.Length -gt 320) { $newDesc = $newDesc.Substring(0, 317).Trim() + '...' }
            $ed = $newDesc.Replace('&', '&amp;').Replace('"', '&quot;').Replace('<', '&lt;')
            $c = [regex]::Replace($c, '<meta name="description" content="[^"]*"', "<meta name=`"description`" content=`"$ed`"", [System.Text.RegularExpressions.RegexOptions]::Singleline)
            $c = [regex]::Replace($c, '<meta property="og:description" content="[^"]*"', "<meta property=`"og:description`" content=`"$ed`"", [System.Text.RegularExpressions.RegexOptions]::Singleline)
            $c = [regex]::Replace($c, '<meta name="twitter:description" content="[^"]*"', "<meta name=`"twitter:description`" content=`"$ed`"", [System.Text.RegularExpressions.RegexOptions]::Singleline)
            $nProduct++
        }
    }

    # Residual old brand in visible SEO (not Machinery/Manufacturing)
    if ($c -match 'KlWL Machine[^ry]') {
        $c = $c -replace 'KlWL Machine([^ry])', 'KlWL Machinery$1'
    }

    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $c, $Utf8)
    }
}

Write-Host "Mojibake files touched: $nMoji"
Write-Host "Amp-escape fixes: $nAmp"
Write-Host "News descriptions fixed: $nNews"
Write-Host "Product descriptions fixed: $nProduct"
