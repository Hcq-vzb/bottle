# Ultimate product image fix: force local paths, disable carousel lazy-load, verify downloads.
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"
$DestImgRoot = Join-Path $SiteRoot "omo-oss-image.thefastimg.com"
$ParentImgRoot = Join-Path (Split-Path $SiteRoot -Parent) "omo-oss-image.thefastimg.com"
$ParentImg1Root = Join-Path (Split-Path $SiteRoot -Parent) "omo-oss-image1.thefastimg.com"
$LogFile = Join-Path $SiteRoot "scripts\fix-product-images-ultimate.log"
$LocalCssId = "local-product-images-fix"

function Write-Log([string]$Message) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Normalize-PortalPath([string]$Raw) {
    if ([string]::IsNullOrWhiteSpace($Raw)) { return $null }
    $value = ($Raw -split '\?')[0].Trim()
    if ($value -match '(?:https?://)?/?(?:\.\./)*(?:\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/.+)$') {
        $value = $Matches[1]
    } elseif ($value -match '^(portal-saas/.+)$') {
        $value = $Matches[1]
    } else {
        return $null
    }
    return ($value -replace ',name:.*$','' -replace 'f160(\.(?:jpg|jpeg|png|webp|gif))$','$1')
}

function Get-LocalPrefix([string]$HtmlFile) {
    $relative = $HtmlFile.Substring($SiteRoot.Length).TrimStart('\', '/')
    if ($relative -match '^products_detail[\\/]') {
        return '../omo-oss-image.thefastimg.com/'
    }
    return './omo-oss-image.thefastimg.com/'
}

function To-LocalUrl([string]$PortalPath, [string]$Prefix) {
    return $Prefix + (Normalize-PortalPath $PortalPath)
}

function Is-PlaceholderSrc([string]$Src) {
    return ($Src -match '(?:/|\.\./|\./)?npublic/img/s\.png$')
}

function Extract-PortalFromValue([string]$Value) {
    return Normalize-PortalPath $Value
}

function Get-ProductPages() {
    $pages = New-Object 'System.Collections.Generic.List[string]'
    Get-ChildItem (Join-Path $SiteRoot "products_detail\*.html") -File | ForEach-Object { $pages.Add($_.FullName) }
    Get-ChildItem (Join-Path $SiteRoot "*.html") -File | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        if ($content -match 'c_product_detail_003|contentType":"product"') {
            $pages.Add($_.FullName)
        }
    }
    return $pages
}

function Extract-AllPortalPaths([string]$Content) {
    $paths = New-Object 'System.Collections.Generic.HashSet[string]'
    $patterns = @(
        '(?:src|data-src|lazy)\s*=\s*"(?:https?://)?/?(?:\.\./|\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"?]+)',
        'content\s*=\s*"(?:https?://)?/?(?:\.\./|\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"?]+)',
        'data-url\s*=\s*"(?:https?://)?/?(?:\.\./|\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"]+)"',
        'data-url\s*=\s*"(portal-saas/[^"]+)"',
        '\{url:(portal-saas/[^,\}]+)',
        '(?:\./|\.\./|https?://)?/?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"?\s>,]+)'
    )
    foreach ($pattern in $patterns) {
        [regex]::Matches($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | ForEach-Object {
            $normalized = Normalize-PortalPath $_.Groups[1].Value
            if ($normalized) { [void]$paths.Add($normalized) }
        }
    }
    return $paths
}

function Ensure-ImageFile([string]$PortalPath) {
    $portalPath = Normalize-PortalPath $PortalPath
    if (-not $portalPath) { return $false }

    $destFile = Join-Path $DestImgRoot $portalPath
    if ((Test-Path $destFile) -and ((Get-Item $destFile).Length -gt 0)) {
        return $true
    }

    if (Test-Path $destFile) { Remove-Item $destFile -Force }

    foreach ($sourceRoot in @($ParentImgRoot, $ParentImg1Root)) {
        if (-not (Test-Path $sourceRoot)) { continue }
        foreach ($candidate in @($portalPath, ($portalPath -replace '\.(jpg|jpeg|png|webp|gif)$','f160.$1'))) {
            $sourceFile = Join-Path $sourceRoot $candidate
            if ((Test-Path $sourceFile) -and ((Get-Item $sourceFile).Length -gt 0)) {
                $destDir = Split-Path $destFile -Parent
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                Copy-Item $sourceFile $destFile -Force
                return $true
            }
        }
    }

    $url = "https://omo-oss-image.thefastimg.com/$portalPath"
    try {
        $destDir = Split-Path $destFile -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Invoke-WebRequest -Uri $url -OutFile $destFile -UseBasicParsing -TimeoutSec 90 -Headers @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            "Referer"    = "https://www.ecengmachine.com/"
        } | Out-Null
        Start-Sleep -Milliseconds 50
        return ((Test-Path $destFile) -and ((Get-Item $destFile).Length -gt 0))
    } catch {
        Write-Log "Download failed: $url -> $($_.Exception.Message)"
        return $false
    }
}

function Get-AttrValue([string]$Tag, [string]$Name) {
    if ($Tag -match "$Name=`"([^`"]*)`"") { return $Matches[1] }
    return $null
}

function Clean-Class([string]$Class) {
    if ([string]::IsNullOrWhiteSpace($Class)) { return $null }
    $parts = $Class -split '\s+' | Where-Object {
        $_ -and $_ -notmatch '^(lazyload|owl-carousel)$'
    }
    if ($parts.Count -eq 0) { return $null }
    return ($parts -join ' ')
}

function Rewrite-ImgTag([string]$Tag, [string]$Prefix) {
    $portal = $null
    $srcVal = Get-AttrValue $Tag 'src'
    $lazyVal = Get-AttrValue $Tag 'lazy'
    if (-not $lazyVal) { $lazyVal = Get-AttrValue $Tag 'data-src' }

    if ($lazyVal) {
        $portal = Extract-PortalFromValue $lazyVal
    }
    if (-not $portal -and $srcVal -and -not (Is-PlaceholderSrc $srcVal)) {
        $portal = Extract-PortalFromValue $srcVal
    }
    if (-not $portal) { return $Tag }

    $local = To-LocalUrl $portal $Prefix
    $attrs = @()
    foreach ($name in @('id', 'alt', 'title', 'class', 'style')) {
        $val = Get-AttrValue $Tag $name
        if ($null -eq $val) { continue }
        if ($name -eq 'class') {
            $val = Clean-Class $val
            if (-not $val) { continue }
        }
        $attrs += "$name=`"$val`""
    }
    $attrs += "src=`"$local`""
    return '<img ' + ($attrs -join ' ') + ' />'
}

function Fix-AllImgTags([string]$Content, [string]$Prefix) {
    return [regex]::Replace($Content, '<img\b[^>]*?/?>', {
        param($m)
        Rewrite-ImgTag $m.Value $Prefix
    }, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

function Fix-MagnifierCarousel([string]$Content, [string]$Prefix) {
    $content = $Content
    $content = [regex]::Replace($content, '<div class="e_magnifier-62([^"]*)"([^>]*)\sneedjs="true"([^>]*)>', '<div class="e_magnifier-62$1"$2$3>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    $content = [regex]::Replace($content, '(?s)(<div class="magnifier[^"]*"[^>]*id="magnifierWrapper"[^>]*>)(.*?)(<div class="magnifier-view"></div>)', {
        param($m)
        $block = $m.Groups[2].Value
        $block = $block -replace '\sneedjs="true"', ''
        $block = $block -replace '\s(onload|onerror|onclick)="[^"]*"', ''
        $block = [regex]::Replace($block, 'class="([^"]*)"', {
            param($c)
            $clean = Clean-Class $c.Groups[1].Value
            if ($clean) { 'class="' + $clean + '"' } else { '' }
        })
        $block = [regex]::Replace($block, '\{url:(portal-saas/[^,\}]+)', {
            param($u)
            '{url:' + (Normalize-PortalPath $u.Groups[1].Value)
        })
        $block = [regex]::Replace($block, 'data-url="(portal-saas/[^"]+)"', {
            param($d)
            'data-url="' + (Normalize-PortalPath $d.Groups[1].Value) + '"'
        })
        $m.Groups[1].Value + $block + $m.Groups[3].Value
    })

    return $content
}

function Fix-MetaImages([string]$Content, [string]$Prefix) {
    $patterns = @(
        '(?<tag>property="og:image"\s+content=")(?:https://|\./|\.\./|\../\.\./)?/?omo-oss-image1?\.thefastimg\.com/(?<path>portal-saas/[^"?]+)(?:\?[^"]*)?(?<q>")',
        '(?<tag>(?:property|name)="twitter:image"\s+content=")(?:https://|\./|\.\./|\../\.\./)?/?omo-oss-image1?\.thefastimg\.com/(?<path>portal-saas/[^"?]+)(?:\?[^"]*)?(?<q>")'
    )
    foreach ($mp in $patterns) {
        $Content = [regex]::Replace($Content, $mp, {
            param($m)
            $m.Groups['tag'].Value + (To-LocalUrl $m.Groups['path'].Value $Prefix) + $m.Groups['q'].Value
        }, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    return $Content
}

function Ensure-LocalCss([string]$Content, [string]$Prefix) {
    $galleryJs = if ($Prefix -eq '../omo-oss-image.thefastimg.com/') { '../npublic/js/local-product-gallery.js' } else { './npublic/js/local-product-gallery.js' }
    $css = @"
<style id="$LocalCssId">
#c_product_detail_003-1646786866002 .e_magnifier-62 .magnifier-container,
#magnifierWrapper .magnifier-container {
  min-height: 360px !important;
  position: relative !important;
}
#magnifierWrapper .images-cover .image-item {
  display: none;
  justify-content: center;
  align-items: center;
}
#magnifierWrapper .images-cover .image-item img,
#c_product_detail_003-1646786866002 .e_magnifier-62 .images-cover img {
  width: 100% !important;
  height: auto !important;
  max-height: 480px !important;
  object-fit: contain !important;
  opacity: 1 !important;
  visibility: visible !important;
}
#magnifierWrapper .thumbnail_box li,
#magnifierWrapper .static-img,
#magnifierWrapper .small-img {
  display: inline-block !important;
}
#magnifierWrapper .thumbnail_box li.local-gallery-active .small-img {
  outline: 2px solid #ed6c00 !important;
  outline-offset: 2px;
}
#magnifierWrapper .thumbnail_box img {
  display: inline-block !important;
  width: 72px !important;
  height: 72px !important;
  object-fit: cover !important;
  opacity: 1 !important;
  visibility: visible !important;
}
#magnifierWrapper .magnifier-btn-left,
#magnifierWrapper .magnifier-btn-right,
#magnifierWrapper .image-bigger {
  cursor: pointer !important;
}
.e_richText-14 img[src*="omo-oss-image"],
.e_richText-69 img[src*="omo-oss-image"],
.e_richText-46 img[src*="omo-oss-image"] {
  display: inline-block !important;
  max-width: 100% !important;
  height: auto !important;
}
</style>
<script id="local-product-images-lock">
(function(){
  document.querySelectorAll('img[src*="omo-oss-image"]').forEach(function(el){
    el.removeAttribute('lazy');
    el.removeAttribute('data-src');
    el.removeAttribute('loading');
  });
})();
</script>
<script src="$galleryJs"></script>
"@
    if ($Content -match "id=`"$LocalCssId`"") {
        return [regex]::Replace($Content, '<style id="local-product-images-fix">[\s\S]*?</style>(?:\s*<script id="local-product-images-lock">[\s\S]*?</script>)?(?:\s*<script src="(?:\.\./|\./)?npublic/js/local-product-gallery\.js"></script>)?', $css)
    }
    return [regex]::Replace($Content, '</head>', ($css + "`n</head>"), 1)
}

function Validate-Page([string]$HtmlPath, [string]$ExpectedPrefix) {
    $content = Get-Content $HtmlPath -Raw -Encoding UTF8
    $issues = @()
    if ($content -match '\blazy\s*=') { $issues += 'lazy attr remains' }
    if ($content -match '\bdata-src\s*=') { $issues += 'data-src remains' }
    if ($content -match '\bloading="lazy"') { $issues += 'loading=lazy remains' }
    if ($content -match 'src="(?:/|\.\./|\./)?npublic/img/s\.png"') { $issues += 'placeholder remains' }
    if ($content -match 'src="https://omo-oss-image') { $issues += 'remote src remains' }

    $carousel = ''
    if ($content -match '(?s)(<div class="images-cover">.*?</div>\s*<!--右下角的加号-->)') {
        $carousel = $Matches[1]
    }
    $carouselImgs = [regex]::Matches($carousel, '<img\b')
    $badPrefix = [regex]::Matches($carousel, 'src="(?!' + [regex]::Escape($ExpectedPrefix) + ')[^"]*omo-oss-image')
    if ($badPrefix.Count -gt 0) { $issues += 'carousel wrong prefix' }

    $missing = @()
    [regex]::Matches($content, 'src="([^"]*omo-oss-image\.thefastimg\.com/portal-saas/[^"?]+)"') | ForEach-Object {
        $portal = Normalize-PortalPath $_.Groups[1].Value
        if ($portal -and -not (Test-Path (Join-Path $DestImgRoot $portal))) {
            $missing += $portal
        }
    }

    return @{
        Issues = $issues
        CarouselCount = $carouselImgs.Count
        Missing = ($missing | Select-Object -Unique)
    }
}

New-Item -ItemType Directory -Path (Split-Path $LogFile -Parent) -Force | Out-Null
New-Item -ItemType Directory -Path $DestImgRoot -Force | Out-Null
Write-Log "=== Ultimate product image fix ==="

if (Test-Path $ParentImgRoot) {
    robocopy $ParentImgRoot $DestImgRoot /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
}

$productPages = Get-ProductPages
Write-Log "Product pages: $($productPages.Count)"

$allPaths = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($page in $productPages) {
    foreach ($p in (Extract-AllPortalPaths (Get-Content $page -Raw -Encoding UTF8))) {
        [void]$allPaths.Add($p)
    }
}

Write-Log "Unique image paths: $($allPaths.Count)"
$ok = 0; $fail = 0; $failed = @()
foreach ($path in ($allPaths | Sort-Object)) {
    if (Ensure-ImageFile $path) { $ok++ } else { $fail++; $failed += $path }
}
Write-Log "Images OK: $ok | Failed: $fail"
if ($failed.Count -gt 0) { Write-Log "Failed list: $(($failed | Select-Object -First 10) -join ', ')" }

$updated = 0
foreach ($page in $productPages) {
    $prefix = Get-LocalPrefix $page
    $original = Get-Content $page -Raw -Encoding UTF8
    $content = $original
    $content = Fix-MagnifierCarousel $content $prefix
    $content = Fix-AllImgTags $content $prefix
    $content = Fix-MetaImages $content $prefix
    $content = Ensure-LocalCss $content $prefix
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($page, $content, [System.Text.UTF8Encoding]::new($false))
        $updated++
    }
}
Write-Log "Updated pages: $updated"

$j2l2 = Validate-Page (Join-Path $SiteRoot "J2L2_2_Cavity_Plastic_Jar_Making_Machine.html") './omo-oss-image.thefastimg.com/'
$p19 = Validate-Page (Join-Path $SiteRoot "products_detail\19.html") '../omo-oss-image.thefastimg.com/'
Write-Log "J2L2: carousel=$($j2l2.CarouselCount) issues=$($j2l2.Issues -join ';') missing=$($j2l2.Missing.Count)"
Write-Log "19.html: carousel=$($p19.CarouselCount) issues=$($p19.Issues -join ';') missing=$($p19.Missing.Count)"
Write-Log "Disk images: $((Get-ChildItem $DestImgRoot -Recurse -File).Count)"
Write-Log "=== Done ==="
