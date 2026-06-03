# Fix homepage (index.html) for offline viewing: images, CSS backgrounds, lazy load, banner text.
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"
$IndexFile = Join-Path $SiteRoot "index.html"
$HomeCss = Join-Path $SiteRoot "css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css"
$DestImgRoot = Join-Path $SiteRoot "omo-oss-image.thefastimg.com"
$ParentImgRoot = Join-Path (Split-Path $SiteRoot -Parent) "omo-oss-image.thefastimg.com"
$ParentImg1Root = Join-Path (Split-Path $SiteRoot -Parent) "omo-oss-image1.thefastimg.com"
$FixId = "local-home-fix"
$Prefix = "./omo-oss-image.thefastimg.com/"
$CssPrefix = "../omo-oss-image.thefastimg.com/"

function Normalize-PortalPath([string]$Raw) {
    if ([string]::IsNullOrWhiteSpace($Raw)) { return $null }
    $value = ($Raw -split '\?')[0].Trim().Trim('"', "'")
    if ($value -match '(?:https?://)?/?(?:\.\./)*(?:\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/.+)$') {
        $value = $Matches[1]
    } elseif ($value -match '^(portal-saas/.+)$') {
        $value = $Matches[1]
    } else { return $null }
    return ($value -replace ',name:.*$','' -replace 'f160(\.(?:jpg|jpeg|png|webp|gif))$','$1')
}

function Ensure-ImageFile([string]$PortalPath) {
    $portalPath = Normalize-PortalPath $PortalPath
    if (-not $portalPath) { return $false }
    $destFile = Join-Path $DestImgRoot $portalPath
    if ((Test-Path $destFile) -and ((Get-Item $destFile).Length -gt 0)) { return $true }
    foreach ($sourceRoot in @($ParentImgRoot, $ParentImg1Root)) {
        if (-not (Test-Path $sourceRoot)) { continue }
        $sourceFile = Join-Path $sourceRoot $portalPath
        if ((Test-Path $sourceFile) -and ((Get-Item $sourceFile).Length -gt 0)) {
            $destDir = Split-Path $destFile -Parent
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Copy-Item $sourceFile $destFile -Force
            return $true
        }
    }
    $url = "https://omo-oss-image.thefastimg.com/$portalPath"
    try {
        $destDir = Split-Path $destFile -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Invoke-WebRequest -Uri $url -OutFile $destFile -UseBasicParsing -TimeoutSec 90 -Headers @{
            "User-Agent" = "Mozilla/5.0"
            "Referer"    = "https://www.ecengmachine.com/"
        } | Out-Null
        Start-Sleep -Milliseconds 80
        return ((Test-Path $destFile) -and ((Get-Item $destFile).Length -gt 0))
    } catch {
        Write-Host "Download failed: $url"
        return $false
    }
}

function Get-AttrValue([string]$Tag, [string]$Name) {
    if ($Tag -match "$Name=`"([^`"]*)`"") { return $Matches[1] }
    return $null
}

function Rewrite-ImgTag([string]$Tag) {
    $portal = $null
    $lazyVal = Get-AttrValue $Tag 'lazy'
    if (-not $lazyVal) { $lazyVal = Get-AttrValue $Tag 'data-src' }
    $srcVal = Get-AttrValue $Tag 'src'
    if ($lazyVal) { $portal = Normalize-PortalPath $lazyVal }
    if (-not $portal -and $srcVal -and $srcVal -notmatch 'npublic/img/s\.png') {
        $portal = Normalize-PortalPath $srcVal
    }
    if (-not $portal) { return $Tag }
    $local = $Prefix + (Normalize-PortalPath $portal)
    $attrs = @()
    foreach ($name in @('id', 'alt', 'title', 'class', 'style', 'la', 'needthumb')) {
        $val = Get-AttrValue $Tag $name
        if ($null -ne $val -and $val -ne '') { $attrs += "$name=`"$val`"" }
    }
    $attrs += "src=`"$local`""
    return '<img ' + ($attrs -join ' ') + ' />'
}

if (-not (Test-Path $IndexFile)) { throw "index.html not found: $IndexFile" }

Write-Host "Fixing homepage: $SiteRoot"
New-Item -ItemType Directory -Path $DestImgRoot -Force | Out-Null

$content = Get-Content $IndexFile -Raw -Encoding UTF8
$css = if (Test-Path $HomeCss) { Get-Content $HomeCss -Raw -Encoding UTF8 } else { '' }

$paths = New-Object 'System.Collections.Generic.HashSet[string]'
$patterns = @(
    '(?:src|lazy|data-src)\s*=\s*"(?:https?://)?/?(?:\.\./|\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"?]+)"',
    'background-image:\s*url\((?:https?://)?/?(?:\.\./|\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"?)\s]+)\)',
    'background-image:url\((?:https?://)?/?(?:\.\./|\./)?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"?)\s]+)\)'
)
foreach ($p in $patterns) {
    [regex]::Matches($content, $p, 'IgnoreCase') | ForEach-Object {
        $n = Normalize-PortalPath $_.Groups[1].Value
        if ($n) { [void]$paths.Add($n) }
    }
}
[regex]::Matches($css, 'url\((?:https?://)?/?omo-oss-image1?\.thefastimg\.com/(portal-saas/[^"?)\s]+)\)', 'IgnoreCase') | ForEach-Object {
    $n = Normalize-PortalPath $_.Groups[1].Value
    if ($n) { [void]$paths.Add($n) }
}

$ok = 0; $fail = 0
foreach ($path in ($paths | Sort-Object)) {
    if (Ensure-ImageFile $path) { $ok++ } else { $fail++ }
}
Write-Host "Images downloaded/copied: $ok | failed: $fail"

$content = $content -replace '\.\./omo-oss-image\.thefastimg\.com/', './omo-oss-image.thefastimg.com/'
$content = $content -replace 'https://omo-oss-image1?\.thefastimg\.com/', './omo-oss-image.thefastimg.com/'
$content = [regex]::Replace($content, '<img\b[^>]*?/?>', { param($m) Rewrite-ImgTag $m.Value }, 'IgnoreCase')

if ($css) {
    $css = $css -replace 'url\(https://omo-oss-image1\.thefastimg\.com/', "url($CssPrefix"
    $css = $css -replace 'url\(https://omo-oss-image\.thefastimg\.com/', "url($CssPrefix"
    [System.IO.File]::WriteAllText($HomeCss, $css, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Patched Home CSS backgrounds"
}

$inject = @"
<style id="$FixId">
.e_bannerD-1 .p_info{display:none!important}
.e_bannerD-1 .p_img{display:none!important}
.e_bannerD-1 .p_slide{background-size:cover!important;background-position:center center!important;background-repeat:no-repeat!important}
#c_effect_112-1690623837699{background-repeat:no-repeat!important;background-size:cover!important;background-position:center center!important;position:relative}
#c_effect_112-1690623837699 .e_container-8,#c_effect_112-1690623837699 .e_loop-1{position:relative!important;z-index:1!important}
#c_effect_112-1690623837699 .e_loop-1{display:block!important;visibility:visible!important;opacity:1!important;min-height:360px}
#c_effect_112-1690623837699 .honorSwip{overflow:hidden!important;padding:30px 0 50px!important;min-height:340px;width:100%}
#c_effect_112-1690623837699 .honorSwip .swiper-slide{width:190px!important;height:280px!important;flex-shrink:0!important;display:flex!important;align-items:center!important;justify-content:center!important;visibility:visible!important;opacity:1!important}
#c_effect_112-1690623837699 .honorSwip .e_image-2,#c_effect_112-1690623837699 .honorSwip .showihonor{display:block!important;visibility:visible!important;width:100%!important;height:auto!important}
#c_effect_112-1690623837699 .honorSwip .e_image-2 img,#c_effect_112-1690623837699 .e_image-2 img{display:block!important;visibility:visible!important;opacity:1!important;width:100%!important;height:auto!important;max-height:260px!important;object-fit:contain!important}
</style>
<script src="./npublic/js/local-home-fix.js"></script>
"@

if ($content -match "id=`"$FixId`"") {
    $content = [regex]::Replace($content, '<style id="local-home-fix">[\s\S]*?</style>\s*<script src="\./npublic/js/local-home-fix\.js"></script>', $inject)
} else {
    $content = [regex]::Replace($content, '</head>', ($inject + "`n</head>"), 1)
}

[System.IO.File]::WriteAllText($IndexFile, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Updated index.html"
$lazyLeft = ([regex]::Matches($content, '\blazy\s*=')).Count
$placeholderLeft = ([regex]::Matches($content, 'npublic/img/s\.png')).Count
Write-Host "Remaining lazy=$lazyLeft placeholder=$placeholderLeft"
