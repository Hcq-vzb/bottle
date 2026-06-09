# Inject Product / Article / WebSite JSON-LD for Google rich results
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$BaseUrl = 'https://www.bottleblowtech.com'
)

$Brand = 'KlWL Machinery'
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$DefaultImage = "$BaseUrl/omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/image/0c8b8e98-6fdc-4662-8c78-2f5045b18df6.png"

function Should-SkipHtml([string]$rel) {
    $r = $rel -replace '\\', '/'
    if ($r -match '^scripts/') { return $true }
    if ($r -match '^omo-oss-image') { return $true }
    if ($r -match 'glyphicons|iconfont') { return $true }
    if ($r -match '^intelling/') { return $true }
    return $false
}

function Get-PageTitle([string]$content) {
    $m = [regex]::Match($content, '<title>([^<]+)</title>')
    if (-not $m.Success) { return '' }
    return ($m.Groups[1].Value -replace '\s\|\s*KlWL Machinery\s*$', '').Trim()
}

function Get-PageDescription([string]$content) {
    $m = [regex]::Match($content, '<meta name="description" content="([^"]*)"')
    if ($m.Success) { return $m.Groups[1].Value }
    return ''
}

function Get-FirstImage([string]$content, [string]$baseUrl) {
    $m = [regex]::Match($content, '<meta property="og:image" content="([^"]+)"')
    if ($m.Success -and $m.Groups[1].Value.Trim() -ne '') {
        $img = $m.Groups[1].Value.Trim()
        if ($img -match '^https?://') { return ($img -replace '/\.\./', '/') }
        $path = $img -replace '^\./', '' -replace '^\.\./', ''
        return "$baseUrl/$path"
    }
    $m2 = [regex]::Match($content, '<img[^>]+src="([^"]+omo-oss-image[^"]+)"')
    if ($m2.Success) {
        $img = $m2.Groups[1].Value
        if ($img -match '^https?://') { return ($img -replace '/\.\./', '/') }
        $path = $img -replace '^\./', '' -replace '^\.\./', ''
        return "$baseUrl/$path"
    }
    return $DefaultImage
}

function Escape-Json([string]$s) {
    if (-not $s) { return '' }
    return ($s -replace '\\', '\\' -replace '"', '\"' -replace "`r", '' -replace "`n", ' ' -replace '\s{2,}', ' ').Trim()
}

function Remove-ExistingSchema([string]$content, [string]$id) {
    return [regex]::Replace($content, "<script type=`"application/ld\+json`" id=`"$id`">[\s\S]*?</script>\s*", '')
}

function Inject-Schema([string]$content, [string]$id, [string]$json) {
    $content = Remove-ExistingSchema $content $id
    $block = "<script type=`"application/ld+json`" id=`"$id`">`n$json`n</script>`n"
    if ($content -match '<!-- CUSTOM_HEAD_BEGIN_TAG -->') {
        return $content -replace '(<!-- CUSTOM_HEAD_BEGIN_TAG -->)', "$block`$1"
    }
    if ($content -match '</head>') {
        return $content -replace '</head>', "$block</head>"
    }
    return $content
}

function Is-404Page([string]$content) {
    return $content -match '<title>Page 404\s*\|\s*KlWL Machinery</title>'
}

function Is-ProductPage([string]$webPath, [string]$content) {
    if (Is-404Page $content) { return $false }
    if ($webPath -like 'products_detail/*') { return $true }
    if ($webPath -match '_(Machine|Blowing_Machine|Moulding_Machine|Making_Machine|Dryer|Compressor|Chiller)\.html$') { return $true }
    if ($webPath -match '^(K|Q|YC|SK|J|H|KB|KX|QJ)[0-9A-Z_\-]+\.html$') { return $true }
    if ($webPath -match 'Cavity_.*\.html$') { return $true }
    if ($webPath -match '^(Air_Compressor|Chiller|Cold_Dryer|Blowing_Machine_Mold)\.html$') { return $true }
    return $false
}

$nProduct = 0
$nArticle = 0
$nWebSite = 0

Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    if (Should-SkipHtml $rel) { return }

    $webPath = $rel -replace '\\', '/'
    $content = [System.IO.File]::ReadAllText($_.FullName)
    $orig = $content

    if (Is-404Page $content) { return }

    $absUrl = if ($webPath -eq 'index.html') { "$BaseUrl/" } else { "$BaseUrl/$webPath" }
    $title = Get-PageTitle $content
    $desc = Get-PageDescription $content
    $image = Get-FirstImage $content $BaseUrl

    if ($webPath -eq 'index.html') {
        $website = @"
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "$Brand",
  "url": "$BaseUrl/",
  "publisher": {
    "@type": "Organization",
    "name": "$Brand",
    "logo": "$DefaultImage"
  }
}
"@
        $content = Inject-Schema $content 'klwl-website-schema' $website
        $nWebSite++
    }

    if ($webPath -like 'news_detail/*') {
        $article = @"
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "$(Escape-Json $title)",
  "description": "$(Escape-Json $desc)",
  "image": "$image",
  "author": { "@type": "Organization", "name": "$Brand" },
  "publisher": {
    "@type": "Organization",
    "name": "$Brand",
    "logo": { "@type": "ImageObject", "url": "$DefaultImage" }
  },
  "mainEntityOfPage": { "@type": "WebPage", "@id": "$absUrl" }
}
"@
        $content = Inject-Schema $content 'klwl-article-schema' $article
        $nArticle++
    }
    elseif (Is-ProductPage $webPath $content) {
        $product = @"
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "$(Escape-Json $title)",
  "description": "$(Escape-Json $desc)",
  "image": "$image",
  "brand": { "@type": "Brand", "name": "$Brand" },
  "manufacturer": {
    "@type": "Organization",
    "name": "$Brand",
    "url": "$BaseUrl/"
  },
  "url": "$absUrl"
}
"@
        $content = Inject-Schema $content 'klwl-product-schema' $product
        $nProduct++
    }

    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $content, $Utf8)
    }
}

Write-Host "Structured data: WebSite=$nWebSite Product=$nProduct Article=$nArticle"
