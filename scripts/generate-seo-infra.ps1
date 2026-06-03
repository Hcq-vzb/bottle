# Generate robots.txt, sitemap.xml, Organization JSON-LD on homepage
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$BaseUrl = 'https://www.bottleblowtech.com'
)

$Utf8 = [System.Text.UTF8Encoding]::new($false)

function Should-SkipSitemap([string]$rel) {
    $r = $rel -replace '\\', '/'
    if ($r -match '^scripts/') { return $true }
    if ($r -match '^omo-oss-image\.thefastimg\.com/') { return $true }
    if ($r -match '^public/css/iconfont') { return $true }
    if ($r -match 'glyphicons-halflings') { return $true }
    if ($r -match '^intelling/') { return $true }
    if ($r -match '^result') { return $true }
    if ($r -match 'successfully\.html$') { return $true }
    return $false
}

function Get-Priority([string]$webPath) {
    if ($webPath -eq 'index.html') { return '1.0' }
    if ($webPath -eq 'products.html' -or $webPath -eq 'contact.html' -or $webPath -eq 'jianjie.html') { return '0.9' }
    if ($webPath -like 'products_detail/*' -or $webPath -like 'K*_*.html' -or $webPath -like 'Q*_*.html' -or $webPath -like 'YC*.html' -or $webPath -like 'SK*.html' -or $webPath -like 'J*.html' -or $webPath -like 'H*.html') { return '0.8' }
    if ($webPath -like 'news_detail/*') { return '0.6' }
    if ($webPath -like 'news_lsit/*' -or $webPath -like 'products_list/*') { return '0.7' }
    return '0.5'
}

# robots.txt
$robots = @"
User-agent: *
Allow: /

Sitemap: $BaseUrl/sitemap.xml
"@
[System.IO.File]::WriteAllText((Join-Path $SiteRoot 'robots.txt'), $robots, $Utf8)
Write-Host 'Wrote robots.txt'

# sitemap.xml
$urls = [System.Collections.Generic.List[string]]::new()
Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    if (Should-SkipSitemap $rel) { return }
    $webPath = ($rel -replace '\\', '/')
    $loc = if ($webPath -eq 'index.html') { "$BaseUrl/" } else { "$BaseUrl/$webPath" }
    $pri = Get-Priority $webPath
    $urls.Add("  <url>`n    <loc>$loc</loc>`n    <changefreq>weekly</changefreq>`n    <priority>$pri</priority>`n  </url>")
}

$sitemap = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
$($urls -join "`n")
</urlset>
"@
[System.IO.File]::WriteAllText((Join-Path $SiteRoot 'sitemap.xml'), $sitemap, $Utf8)
Write-Host "Wrote sitemap.xml with $($urls.Count) URLs"

# Organization schema on index.html
$indexPath = Join-Path $SiteRoot 'index.html'
$idx = [System.IO.File]::ReadAllText($indexPath)
$schemaMarker = 'klwl-organization-schema'
if ($idx -notmatch $schemaMarker) {
    $logoUrl = "$BaseUrl/omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/image/0c8b8e98-6fdc-4662-8c78-2f5045b18df6.png"
    $schema = @"
<script type="application/ld+json" id="$schemaMarker">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "KlWL Machinery",
  "legalName": "Jiangsu KlWL Machinery Manufacturing Group Co., Ltd.",
  "url": "$BaseUrl/",
  "logo": "$logoUrl",
  "description": "Manufacturer of PET and plastic bottle blowing machines. Factory direct from China since 2007.",
  "foundingDate": "2007",
  "sameAs": []
}
</script>
"@
    $idx = $idx -replace '(<!-- CUSTOM_HEAD_BEGIN_TAG -->)', "$schema`n`$1"
    [System.IO.File]::WriteAllText($indexPath, $idx, $Utf8)
    Write-Host 'Injected Organization schema on index.html'
} else {
    Write-Host 'Organization schema already present on index.html'
}
