# Site-wide SEO: brand unification, title/description, canonical, og tags, empty keywords
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$BaseUrl = 'https://www.bottleblowtech.com'
)

$Brand = 'KlWL Machinery'
$BrandJunk = 'KlWL Machine_a high-tech enterprise integrating research'
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$DefaultOgImage = 'https://www.bottleblowtech.com/omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/image/0c8b8e98-6fdc-4662-8c78-2f5045b18df6.png'

# Keyword pyramid tiers (Google-aligned: title/description/H1 matter most; keywords for Bing/legacy)
$Tier1Core = @(
    'PET bottle blowing machine'
    'stretch blow molding machine'
    'plastic bottle making machine'
    'bottle blowing machine manufacturer'
)
$Tier3LongTail = @{
    SemiAuto   = 'semi automatic PET blowing machine'
    Jar        = 'jar blow molding machine'
    JarMaking  = 'plastic jar making machine'
    HandFeed   = 'hand feeding blow molding machine'
    Preform    = 'PET preform making machine'
    Water      = 'water bottle production machine'
    Capping    = 'bottle capping machine'
    Compressor = 'air compressor for bottle blowing line'
    Chiller    = 'industrial chiller for blow molding'
    Dryer      = 'cold dryer for PET blowing line'
    Mold       = 'PET bottle mold'
    Economic   = 'economic blow molding machine'
    HighSpeed  = 'high speed bottle blowing machine'
    EnergySave = 'energy saving blow molding machine'
}
$Tier4Trust = @(
    'bottle blowing machine manufacturer China'
    'factory direct PET blowing machine'
    'Jiangsu KlWL Machinery'
)

function Escape-HtmlAttr([string]$s) {
    if (-not $s) { return '' }
    return ($s -replace '&', '&amp;' -replace '"', '&quot;' -replace '<', '&lt;')
}

function Get-CleanPageTitle([string]$rawTitle) {
    $t = $rawTitle
    $t = $t -replace '-Product Center', ''
    $t = $t -replace [regex]::Escape($BrandJunk), ''
    $t = $t -replace '-Product Center-KlWL Machine[^\|]*', ''
    $t = $t -replace '-Product Center-KlWL Machinery', ''
    $t = $t -replace '-KlWL Machine[^\|]*', ''
    $t = $t -replace '-KlWL Machinery\s*$', ''
    $t = $t -replace ' from China-KlWL Machine[^\|]*', ''
    $t = $t -replace ' from China-KlWL Machinery[^\|]*', ''
    $t = $t -replace '\s\|\s*KlWL Machinery(\s\|\s*KlWL Machinery)+', ' | KlWL Machinery'
    $t = $t.Trim(' |-')
    if ($t -notmatch '\|\s*KlWL Machinery\s*$') {
        $t = "$t | $Brand"
    }
    return $t
}

function Fix-Description([string]$desc, [string]$pageTitle) {
    $d = $desc
    $d = $d -replace [regex]::Escape($BrandJunk), ''
    $d = $d -replace '\bKlWL Machine\b', $Brand
    $d = $d -replace 'Ring network cabinet\.?\s*', ''
    $d = $d -replace 'KlWL Machinery\s*-\s*', 'KlWL Machinery - '
    $d = $d -replace '鈥\?', ' - '
    $d = $d -replace '^Fast Quote\s*', ''
    $d = $d -replace '\s{2,}', ' '
    $d = $d.Trim()

    $base = ($pageTitle -replace '\s\|\s*KlWL Machinery\s*$', '').Trim()
    if ($d -match '&amp;lt;br|&lt;br') {
        $d = "$base from $Brand. PET and plastic bottle blowing machine - factory direct from China, export worldwide."
    }
    if ($d.Length -lt 50 -or $d -match '^(Product Center|Fast Quote|KlWL Machinery\s*-?\s*$)') {
        $d = "$Brand - $base. PET and plastic bottle blowing machines from Jiangsu KlWL Machinery Manufacturing Group Co., Ltd. Factory direct, serving 170+ countries."
    }
    if ($d.Length -gt 320) {
        $d = $d.Substring(0, 317).Trim() + '...'
    }
    return $d
}

function Get-AbsoluteOgImage([string]$content, [string]$baseUrl) {
    $m = [regex]::Match($content, '<meta property="og:image" content="([^"]*)"')
    $raw = if ($m.Success) { $m.Groups[1].Value.Trim() } else { '' }
    if ($raw -eq '') {
        $m2 = [regex]::Match($content, '<img[^>]+src="([^"]+omo-oss-image[^"]+)"')
        if ($m2.Success) { $raw = $m2.Groups[1].Value.Trim() }
    }
    if ($raw -eq '') { return $DefaultOgImage }
    if ($raw -match '^https?://') {
        return ($raw -replace '/\.\./', '/')
    }
    $path = $raw -replace '^\./', '' -replace '^\.\./', ''
    return "$baseUrl/$path"
}

function Join-Keywords([string[]]$terms) {
    $unique = $terms | Where-Object { $_ -and $_.Trim() -ne '' } | Select-Object -Unique
    return ($unique | Select-Object -First 5) -join ', '
}

function Get-ProductNameFromTitle([string]$title) {
    return ($title -replace '\s\|\s*KlWL Machinery\s*$', '').Trim()
}

function Get-ProductH1FromContent([string]$content) {
    $m = [regex]::Match($content, '<h1 class="e_h1-44[^"]*"[^>]*>\s*([\s\S]*?)\s*</h1>')
    if ($m.Success) {
        $h1 = ($m.Groups[1].Value -replace '<[^>]+>', '' -replace '\s{2,}', ' ').Trim()
        if ($h1 -and $h1 -notmatch '^(undefined|null|Picture Name|ONLINE MESSAGE|图片名称)$') {
            return $h1
        }
    }
    return ''
}

function Test-IsSpamProductTitle([string]$base) {
    if (-not $base) { return $true }
    if ($base -cmatch '^[a-z]') { return $true }
    if ($base -match '^(best|newest|quality)\b') { return $true }
    return $false
}

function Format-PyramidProductTitle([string]$name) {
    if (-not $name) { return '' }
    $name = ($name -replace '\s{2,}', ' ').Trim()
    $ti = [System.Globalization.CultureInfo]::GetCultureInfo('en-US').TextInfo
    $smallWords = @('a', 'an', 'the', 'and', 'or', 'for', 'of', 'in', 'to')
    $words = $name -split '\s+'
    $seriesCodes = @('YC', 'YCQ', 'SK', 'QH', 'QJ', 'KX', 'KB', 'PET', 'Q', 'K', 'H', 'J')
    $out = for ($i = 0; $i -lt $words.Count; $i++) {
        $w = $words[$i]
        if ($seriesCodes -contains $w.ToUpper()) { $w.ToUpper() }
        elseif ($w -match '^[A-Z]{1,3}\d+[A-Z0-9\-]*$' -or $w -match '^[A-Z]{1,3}[A-Z0-9]*-\d') { $w }
        elseif ($w.ToUpper() -eq 'PET') { 'PET' }
        elseif ($w -match '^\d+$') { $w }
        else {
            $lower = $w.ToLower()
            if ($i -gt 0 -and $smallWords -contains $lower) { $lower }
            else { $ti.ToTitleCase($lower) }
        }
    }
    return ($out -join ' ')
}

function Get-ProductNameFromFilename([string]$webPath) {
    $leaf = Split-Path $webPath -Leaf
    $base = [System.IO.Path]::GetFileNameWithoutExtension($leaf)
    if ($base -match '^c-_detailId=' -or $base -match '^\d+$') { return '' }
    $name = $base -replace '_', ' '
    return Format-PyramidProductTitle $name
}

function Get-PyramidProductTitle([string]$content, [string]$webPath, [string]$rawTitle) {
    $h1 = Get-ProductH1FromContent $content
    $name = $null

    if ($h1) {
        $name = Format-PyramidProductTitle $h1
    }
    if (-not $name) {
        $name = Get-ProductNameFromFilename $webPath
    }
    if (-not $name) {
        $cleaned = Get-CleanPageTitle $rawTitle
        $base = Get-ProductNameFromTitle $cleaned
        if (-not (Test-IsSpamProductTitle $base)) {
            $name = Format-PyramidProductTitle $base
        }
    }
    if (-not $name) {
        $name = Get-ProductNameFromFilename $webPath
    }
    if (-not $name) { $name = 'Product' }

    return "$name | $Brand"
}

function Get-PyramidKeywords([string]$productName, [string]$webPath) {
    $terms = [System.Collections.Generic.List[string]]::new()
    $terms.Add('KlWL Machinery')
    $n = ($productName.ToLower() -replace '[^a-z0-9\s\-]', ' ' -replace '\s{2,}', ' ').Trim()
    $leaf = (Split-Path $webPath -Leaf).ToLower()
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($leaf)

    # Tier 2: model from title, else filename (e.g. K6_6_Cavity_..., QX9000_...)
    $model = $null
    if ($productName -match '\b([A-Z]{1,3}\d+[A-Z0-9\-]*)\b') {
        $model = $Matches[1]
    } elseif ($baseName -match '^([a-z]{1,3}\d+[a-z0-9\-]*)') {
        $model = $Matches[1].ToUpper()
    }
    if ($model) {
        if ($n -match 'stretch' -or $baseName -match 'stretch') {
            $terms.Add("$model PET stretch blow molding machine")
        } else {
            $terms.Add("$model PET blowing machine")
        }
    }
    if ($n -match '(\d+)\s*cavity' -or $baseName -match '(\d+)[_\s-]?cavity') {
        $c = if ($Matches[1]) { $Matches[1] } else { '' }
        if ($c) { $terms.Add("$c cavity bottle making machine") }
    }

    # Tier 3: long-tail by product type
    if ($n -match 'semi[\s\-]?auto|semi automatic' -or $leaf -match 'semi_auto|semi-auto') {
        $terms.Add($Tier3LongTail.SemiAuto)
    }
    if ($n -match 'jar' -or $leaf -match 'jar') {
        $terms.Add($Tier3LongTail.Jar)
        $terms.Add($Tier3LongTail.JarMaking)
    }
    if ($n -match 'hand[\s\-]?feed' -or $leaf -match 'hand_feed') {
        $terms.Add($Tier3LongTail.HandFeed)
    }
    if ($n -match 'preform' -or $leaf -match 'preform') {
        $terms.Add($Tier3LongTail.Preform)
    }
    if ($n -match '5[\s\-]?gallon|gallon' -or $leaf -match '5_gallon|gallon') {
        $terms.Add('5 gallon bottle blowing machine')
    }
    if ($n -match 'water|mineral|beverage|soda') {
        $terms.Add($Tier3LongTail.Water)
    }
    if ($n -match 'capping' -or $leaf -match 'capping') {
        $terms.Add($Tier3LongTail.Capping)
    }
    if ($n -match 'compressor' -or $leaf -match 'compressor') {
        $terms.Add($Tier3LongTail.Compressor)
    }
    if ($n -match 'chiller' -or $leaf -match 'chiller') {
        $terms.Add($Tier3LongTail.Chiller)
    }
    if ($n -match 'cold[\s\-]?dryer|dryer' -or $leaf -match 'dryer') {
        $terms.Add($Tier3LongTail.Dryer)
    }
    if ($n -match 'mold|mould' -and $n -notmatch 'blow.?mold|blow.?mould') {
        $terms.Add($Tier3LongTail.Mold)
    }
    if ($n -match 'economic' -or $leaf -match 'ycq|economic') {
        $terms.Add($Tier3LongTail.Economic)
    }
    if ($n -match 'energy[\s\-]?sav' -or $leaf -match 'energy') {
        $terms.Add($Tier3LongTail.EnergySave)
    }
    if ($n -match 'high[\s\-]?speed' -or $leaf -match 'qh') {
        $terms.Add($Tier3LongTail.HighSpeed)
    }

    # Tier 1: core commercial fallback
    if ($n -match 'stretch') {
        $terms.Add($Tier1Core[1])
    }
    if ($terms.Count -lt 4) {
        $terms.Add($Tier1Core[0])
    }
    if ($terms.Count -lt 4) {
        $terms.Add($Tier1Core[2])
    }
    if ($terms.Count -lt 4) {
        $terms.Add('automatic blow molding machine')
    }

    return Join-Keywords $terms
}

function Get-Tier1Keywords([int]$pick = 3) {
    return Join-Keywords (@('KlWL Machinery') + ($Tier1Core | Select-Object -First $pick))
}

function Get-Tier4Keywords() {
    return Join-Keywords (@('KlWL Machinery') + ($Tier4Trust | Select-Object -First 2) + @($Tier1Core[0]))
}

function Get-NewsKeywords([string]$articleTitle) {
    $terms = [System.Collections.Generic.List[string]]::new()
    $terms.Add('KlWL Machinery')
    $t = ($articleTitle.ToLower() -replace '[^a-z0-9\s\-]', ' ' -replace '\s{2,}', ' ').Trim()

    if ($t -match '(\d+)\s*cavity') { $terms.Add("$($Matches[1]) cavity bottle making machine") }
    if ($t -match 'pet') { $terms.Add($Tier1Core[0]) }
    if ($t -match 'stretch') { $terms.Add($Tier1Core[1]) }
    if ($t -match 'semi.?auto|semi automatic') { $terms.Add($Tier3LongTail.SemiAuto) }
    if ($t -match 'jar') { $terms.Add($Tier3LongTail.Jar) }
    if ($t -match 'water|mineral|beverage|soda') { $terms.Add($Tier3LongTail.Water) }
    if ($t -match 'plastic|bottle') { $terms.Add($Tier1Core[2]) }
    if ($t -match 'blow|mold|mould') { $terms.Add('automatic blow molding machine') }

    if ($terms.Count -lt 3) { $terms.Add($Tier1Core[0]) }
    if ($terms.Count -lt 4) { $terms.Add($Tier1Core[2]) }

    return Join-Keywords $terms
}

function Is-ProductDetailPage([string]$webPath, [string]$content) {
    if (Is-404Page $content) { return $false }
    if ($webPath -like 'products_detail/*') { return $true }
    if ($webPath -match '_(Machine|machine|Blowing_Machine|Moulding_Machine|Making_Machine|capping_machine)\.html$') { return $true }
    if ($webPath -match '^(K|Q|YC|SK|J|H|KB|KX|QJ)[0-9A-Z_\-]+\.html$') { return $true }
    if ($webPath -match 'Cavity_.*\.html$') { return $true }
    if ($webPath -match '_capping_machine\.html$') { return $true }
    if ($webPath -match '^(Air_Compressor|Chiller|Cold_Dryer|Blowing_Machine_Mold)\.html$') { return $true }
    return $false
}

function Is-404Page([string]$content) {
    if ($content -match '<title>Page (404|Not Found)\s*\|\s*KlWL Machinery</title>') { return $true }
    if ($content -match '404_b26d1bad248c150dbac90b0e20e5dc3a') { return $true }
    return $false
}

function Should-SkipHtml([string]$rel) {
    $r = $rel -replace '\\', '/'
    if ($r -match '^scripts/node_modules/') { return $true }
    if ($r -match '^omo-oss-image\.thefastimg\.com/') { return $true }
    if ($r -match '^public/css/iconfont') { return $true }
    if ($r -match 'glyphicons-halflings') { return $true }
    if ($r -match '^intelling/') { return $true }
    return $false
}

$PageOverrides = @{
    'index.html' = @{
        Title       = 'PET Bottle Blowing Machine Manufacturer | KlWL Machinery'
        Description = 'KlWL Machinery manufactures PET and plastic bottle blowing machines for water, oil, medical and packaging applications. Jiangsu KlWL Machinery Manufacturing Group Co., Ltd. - factory direct since 2007, export to 170+ countries.'
        Keywords    = 'KlWL Machinery, PET bottle blowing machine, plastic bottle blowing machine, bottle blowing machine manufacturer'
    }
    'products.html' = @{
        Title       = 'PET Bottle Blowing Machines | Products | KlWL Machinery'
        Description = 'Explore KlWL Machinery PET and plastic bottle blowing machines - automatic, semi-automatic, stretch blow molding and jar machines. Factory direct from bottleblowtech.com.'
        Keywords    = (Get-Tier1Keywords 3)
    }
    'contact.html' = @{
        Title       = 'Contact KlWL Machinery | Get a Quote'
        Description = 'Contact KlWL Machinery for bottle blowing machine quotes and technical support. Jiangsu KlWL Machinery Manufacturing Group Co., Ltd. - fast response worldwide.'
        Keywords    = 'KlWL Machinery, bottle blowing machine quote, factory direct PET blowing machine, bottle blowing machine manufacturer China'
    }
    'jianjie.html' = @{
        Title       = 'About KlWL Machinery | Bottle Blowing Machine Manufacturer'
        Description = 'About Jiangsu KlWL Machinery Manufacturing Group Co., Ltd. - high-tech PET bottle blowing machine manufacturer founded in 2007, serving 170+ countries worldwide.'
        Keywords    = (Get-Tier4Keywords)
    }
    'advantages.html' = @{
        Title       = 'Enterprise Advantages | KlWL Machinery'
        Description = 'Discover KlWL Machinery enterprise advantages - R&D, production and global service for PET and plastic bottle blowing machines since 2007.'
        Keywords    = 'KlWL Machinery, bottle blowing machine manufacturer, PET bottle blowing machine, factory direct PET blowing machine'
    }
    'fazhan.html' = @{
        Title       = 'Corporate Vision | KlWL Machinery'
        Description = 'KlWL Machinery corporate vision - leading PET and plastic bottle blowing machine manufacturer from Jiangsu, China.'
        Keywords    = 'KlWL Machinery, bottle blowing machine manufacturer China, Jiangsu KlWL Machinery, PET bottle blowing machine'
    }
    'Download.html' = @{
        Title       = 'Downloads | KlWL Machinery'
        Description = 'Download KlWL Machinery product catalogs and technical resources for PET bottle blowing machines.'
        Keywords    = 'KlWL Machinery, PET bottle blowing machine catalog, stretch blow molding machine, plastic bottle making machine'
    }
}

$SeriesSeo = @{
    'Q_Series_Energy_Saving_PET_Blowing_Machine.html' = @{
        Title       = 'Q Series Energy Saving PET Blowing Machine'
        Keywords    = 'KlWL Machinery, PET bottle blowing machine, energy saving blow molding machine, stretch blow molding machine'
        Description = 'KlWL Machinery Q Series energy-saving PET bottle blowing machines - high output, lower power consumption. Automatic stretch blow molding from China factory direct.'
    }
    'K_Series_Fast_Bottle_Blowing_Machine.html' = @{
        Title       = 'K Series Fast Bottle Blowing Machine'
        Keywords    = 'KlWL Machinery, PET bottle blowing machine, automatic blow molding machine, plastic bottle making machine'
        Description = 'KlWL Machinery K Series fast bottle blowing machines - high-speed automatic PET blow molding for water and beverage bottle production.'
    }
    'H_Series_Hand_Feeding_Blowing_Machine.html' = @{
        Title       = 'H Series Hand Feeding Blowing Machine'
        Keywords    = 'KlWL Machinery, hand feeding blow molding machine, semi automatic PET blowing machine, plastic bottle making machine'
        Description = 'KlWL Machinery H Series hand feeding bottle blowing machines for flexible PET bottle production. Ideal for startups and custom bottle runs.'
    }
    'J_Series_Jar_Blow_Molding_Machine.html' = @{
        Title       = 'J Series Jar Blow Molding Machine'
        Keywords    = 'KlWL Machinery, jar blow molding machine, plastic jar making machine, PET jar manufacturing machine'
        Description = 'KlWL Machinery J Series jar blow molding machines for plastic and PET jars. Multi-cavity automatic production from factory direct.'
    }
    'YC_Series_Semi_Auto_PET_Blowing_Machine.html' = @{
        Title       = 'YC Series Semi Auto PET Blowing Machine'
        Keywords    = 'KlWL Machinery, semi automatic PET blowing machine, semi auto blow molding machine, plastic bottle making machine'
        Description = 'KlWL Machinery YC Series semi-automatic PET blowing machines - cost-effective bottle production for water, oil and packaging bottles.'
    }
    'YCQ_Series_Economic_Blow_Molding_Machine.html' = @{
        Title       = 'YCQ Series Economic Blow Molding Machine'
        Keywords    = 'KlWL Machinery, economic blow molding machine, PET bottle blowing machine, semi automatic PET blowing machine'
        Description = 'KlWL Machinery YCQ Series economic blow molding machines - reliable PET bottle production at competitive factory-direct pricing.'
    }
    'QH_Series.html' = @{
        Title       = 'QH Series High Speed PET Blowing Machine'
        Keywords    = 'KlWL Machinery, high speed bottle blowing machine, PET bottle blowing machine, stretch blow molding machine'
        Description = 'KlWL Machinery QH Series high-performance PET bottle blowing machines for high-speed production lines.'
    }
    'QJ_Series.html' = @{
        Title       = 'QJ Series Auto Jar Making Machine'
        Keywords    = 'KlWL Machinery, jar making machine, jar blow molding machine, plastic jar making machine'
        Description = 'KlWL Machinery QJ Series auto jar making machines - multi-cavity blow molding for PET and plastic jars.'
    }
    'Auxiliary_Machine_Series.html' = @{
        Title       = 'Auxiliary Machine Series'
        Keywords    = 'KlWL Machinery, air compressor for bottle blowing line, industrial chiller for blow molding, cold dryer for PET blowing line'
        Description = 'KlWL Machinery auxiliary equipment for bottle blowing lines - air compressors, chillers, cold dryers and more.'
    }
    'Blowing_Machine_Mold.html' = @{
        Title       = 'Blowing Machine Mold'
        Keywords    = 'KlWL Machinery, PET bottle mold, blow mold, blowing machine mold'
        Description = 'KlWL Machinery blow molds and PET bottle molds - precision tooling for bottle blowing production lines.'
    }
    'Capping_Machine_Series.html' = @{
        Title       = 'Capping Machine Series'
        Keywords    = 'KlWL Machinery, bottle capping machine, capping machine, multi cavity capping machine'
        Description = 'KlWL Machinery capping machine series - high-speed multi-cavity capping for PET bottle production lines.'
    }
}

$LandingPageSeo = @{
    'best-6-cavity-pet-blowing-machine.html' = @{
        Title       = '6 Cavity PET Blowing Machine | KlWL Machinery'
        Description = 'KlWL Machinery 6 cavity PET blowing machine for high-speed beverage bottle production. Automatic stretch blow molding with factory-direct pricing and global support.'
        Keywords    = 'KlWL Machinery, 6 cavity PET blowing machine, stretch blow molding machine, beverage bottle making machine'
    }
    'best-4-cavity-pet-bottle-blowing-machine.html' = @{
        Title       = '4 Cavity PET Bottle Blowing Machine | KlWL Machinery'
        Description = 'KlWL Machinery 4 cavity PET bottle blowing machine for efficient water and beverage bottle production. Reliable automatic blow molding from China factory direct.'
        Keywords    = 'KlWL Machinery, 4 cavity PET bottle blowing machine, automatic blow molding machine, water bottle production machine'
    }
    'best-mineral-water-bottle-making-machine-factory.html' = @{
        Title       = 'Mineral Water Bottle Making Machine | KlWL Machinery'
        Description = 'Factory-direct mineral water bottle making machines from KlWL Machinery. PET stretch blow molding systems for high-volume water bottle production worldwide.'
        Keywords    = 'KlWL Machinery, mineral water bottle making machine, water bottle production machine, PET bottle blowing machine'
    }
    'quality-semi-automatic-pet-blowing-machine-manufacturer.html' = @{
        Title       = 'Semi Automatic PET Blowing Machine Manufacturer | KlWL Machinery'
        Description = 'KlWL Machinery semi automatic PET blowing machines for cost-effective bottle production. Ideal for startups, custom runs and flexible manufacturing.'
        Keywords    = 'KlWL Machinery, semi automatic PET blowing machine, semi auto blow molding machine, plastic bottle making machine'
    }
    'quality-plastic-bottle-blow-molding-machine-manufacturer.html' = @{
        Title       = 'Plastic Bottle Blow Molding Machine Manufacturer | KlWL Machinery'
        Description = 'KlWL Machinery plastic bottle blow molding machines for water, oil, medical and packaging bottles. Factory direct from Jiangsu, China since 2007.'
        Keywords    = 'KlWL Machinery, plastic bottle blow molding machine, blow molding machine manufacturer, PET bottle blowing machine'
    }
    'quality-2-cavity-blow-moulding-machine-manufacturer.html' = @{
        Title       = '2 Cavity Blow Moulding Machine Manufacturer | KlWL Machinery'
        Description = 'KlWL Machinery 2 cavity blow moulding machines for small to medium bottle production. Compact, efficient PET blow molding from factory direct.'
        Keywords    = 'KlWL Machinery, 2 cavity blow moulding machine, PET blow molding machine, bottle blowing machine manufacturer'
    }
    'newest-plastic-bottle-making-machine-manufacturer.html' = @{
        Title       = 'Plastic Bottle Making Machine Manufacturer | KlWL Machinery'
        Description = 'Latest plastic bottle making machines from KlWL Machinery - automatic and semi-automatic PET blow molding for global manufacturers.'
        Keywords    = 'KlWL Machinery, plastic bottle making machine, PET bottle blowing machine, bottle blowing machine manufacturer'
    }
    'newest-plastic-bottle-moulding-machine-factory.html' = @{
        Title       = 'Plastic Bottle Moulding Machine Factory | KlWL Machinery'
        Description = 'KlWL Machinery plastic bottle moulding machine factory - stretch blow molding systems, jar machines and auxiliary equipment. Export to 170+ countries.'
        Keywords    = 'KlWL Machinery, plastic bottle moulding machine, stretch blow molding machine, bottle blowing machine factory'
    }
}

$NewsListTitles = @{
    'news_lsit/1.html'  = 'News | KlWL Machinery'
    'news_lsit/2.html'  = 'Company News | KlWL Machinery'
    'news_lsit/3.html'  = 'Industry Information | KlWL Machinery'
    'news_lsit/4.html'  = 'News | KlWL Machinery'
    'news_lsit/5.html'  = 'News | KlWL Machinery'
    'news_lsit/6.html'  = 'Knowledge | KlWL Machinery'
}

$updated = 0
$skipped = 0

Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    if (Should-SkipHtml $rel) {
        $skipped++
        return
    }

    $webPath = ($rel -replace '\\', '/')
    $absUrl = if ($webPath -eq 'index.html') { "$BaseUrl/" } else { "$BaseUrl/$webPath" }

    $content = [System.IO.File]::ReadAllText($_.FullName)
    $orig = $content

    if ($content -notmatch '<title>[^<]+</title>') {
        $skipped++
        return
    }

    $rawTitle = [regex]::Match($content, '<title>([^<]+)</title>').Groups[1].Value

    if ($PageOverrides.ContainsKey($webPath)) {
        $o = $PageOverrides[$webPath]
        $title = $o.Title
        $description = $o.Description
        $keywords = $o.Keywords
    } elseif ($LandingPageSeo.ContainsKey($webPath)) {
        $o = $LandingPageSeo[$webPath]
        $title = $o.Title
        $description = $o.Description
        $keywords = $o.Keywords
    } elseif ($NewsListTitles.ContainsKey($webPath)) {
        $title = $NewsListTitles[$webPath]
        $description = "$Brand news and industry updates about PET bottle blowing machines, blow molding technology and KlWL Machinery exhibitions."
        $keywords = Get-Tier1Keywords 3
    } elseif ($SeriesSeo.ContainsKey($webPath)) {
        $s = $SeriesSeo[$webPath]
        $name = if ($s.Title) { $s.Title } else { Get-ProductNameFromFilename $webPath }
        $title = "$name | $Brand"
        $description = $s.Description
        $keywords = $s.Keywords
    } elseif ($webPath -like 'products_list/*') {
        $title = Get-CleanPageTitle $rawTitle
        if ($title -match 'Product Center\s*\|') {
            $title = 'PET Bottle Blowing Machines | Product List | KlWL Machinery'
        }
        $description = 'Browse KlWL Machinery PET and plastic bottle blowing machines. Automatic and semi-automatic models for water, oil, jar and packaging bottles - factory direct.'
        $keywords = Get-Tier1Keywords 3
    } elseif ($webPath -like 'news_detail/*') {
        $title = Get-CleanPageTitle $rawTitle
        $title = $title -replace '&amp;amp;', '&amp;'
        $articleTitle = ($title -replace '\s\|\s*KlWL Machinery\s*$', '').Trim()
        $m = [regex]::Match($content, '<meta name="description" content="([^"]*)"')
        $rawDesc = if ($m.Success) { $m.Groups[1].Value } else { '' }
        $rawDesc = $rawDesc -replace [string][char]0x9225 + '\?', ' - '
        if ($rawDesc.Length -ge 80 -and $rawDesc -notmatch 'KlWL Machinery\s*-\s*KlWL Machinery' -and $rawDesc -notmatch 'Ring network cabinet') {
            $description = Fix-Description $rawDesc $title
        } else {
            $description = "$articleTitle. Industry news from $Brand, PET bottle blowing machine manufacturer in China."
            if ($description.Length -gt 320) { $description = $description.Substring(0, 317).Trim() + '...' }
        }
        $keywords = Get-NewsKeywords $articleTitle
    } elseif ($webPath -like 'news_lsit/*') {
        $title = Get-CleanPageTitle $rawTitle
        if ($title -match 'News_News|News_Knowledge|News_Company') {
            $title = ($title -replace 'News_News', 'News' -replace 'News_Knowledge', 'Knowledge' -replace 'News_Company News', 'Company News' -replace 'News_Show information', 'News')
        }
        $description = "$Brand news and updates on PET bottle blowing machines, blow molding technology and global exhibitions."
        $keywords = Get-Tier1Keywords 3
    } elseif (Is-ProductDetailPage $webPath $content) {
        $title = Get-PyramidProductTitle $content $webPath $rawTitle
        $productName = Get-ProductNameFromTitle $title
        $m = [regex]::Match($content, '<meta name="description" content="([^"]*)"')
        $rawDesc = if ($m.Success) { $m.Groups[1].Value } else { '' }
        $description = Fix-Description $rawDesc $title
        $spamDesc = ($rawDesc -match '^(best|newest|quality|The \d+ cavity|\d+ cavity pet)' -or (Test-IsSpamProductTitle $rawDesc) -or ($rawDesc.Length -ge 80 -and $productName.Length -ge 8 -and $rawDesc -notmatch [regex]::Escape($productName.Substring(0, 8))))
        if ($spamDesc -or $description.Length -lt 50) {
            $description = "$productName from $Brand. PET and plastic bottle blowing machine - factory direct from China, export worldwide."
        }
        $keywords = Get-PyramidKeywords $productName $webPath
    } elseif ($webPath -match '\.(html)$' -and $webPath -notlike 'news_*' -and $webPath -notlike 'video/*' -and $webPath -notlike 'yingyong/*' -and $webPath -notlike 'shouhou/*' -and $webPath -notlike 'jianjie/*' -and (Get-ProductH1FromContent $content)) {
        # Product-style pages with H1 but outside strict path rules (e.g. capping_machine lowercase)
        $title = Get-PyramidProductTitle $content $webPath $rawTitle
        $productName = Get-ProductNameFromTitle $title
        $m = [regex]::Match($content, '<meta name="description" content="([^"]*)"')
        $rawDesc = if ($m.Success) { $m.Groups[1].Value } else { '' }
        $description = Fix-Description $rawDesc $title
        if ((Test-IsSpamProductTitle $rawDesc) -or $description.Length -lt 50) {
            $description = "$productName from $Brand. PET and plastic bottle blowing machine - factory direct from China, export worldwide."
        }
        $keywords = Get-PyramidKeywords $productName $webPath
    } else {
        $title = Get-CleanPageTitle $rawTitle
        $m = [regex]::Match($content, '<meta name="description" content="([^"]*)"')
        $rawDesc = if ($m.Success) { $m.Groups[1].Value } else { '' }
        $description = Fix-Description $rawDesc $title
        $productName = Get-ProductNameFromTitle $title
        $keywords = Get-PyramidKeywords $productName $webPath
    }

    $et = Escape-HtmlAttr $title
    $ed = Escape-HtmlAttr $description
    $ek = Escape-HtmlAttr $keywords
    $ogImage = Escape-HtmlAttr (Get-AbsoluteOgImage $content $BaseUrl)

    if (Is-404Page $content) {
        $title = 'Page Not Found | KlWL Machinery'
        $description = 'The page you requested was not found. Browse KlWL Machinery PET and plastic bottle blowing machines or contact us for a quote.'
        $keywords = 'KlWL Machinery, PET bottle blowing machine'
        $et = Escape-HtmlAttr $title
        $ed = Escape-HtmlAttr $description
        $ek = Escape-HtmlAttr $keywords
    }

    $content = [regex]::Replace($content, '<title>[^<]*</title>', "<title>$et</title>")
    $content = [regex]::Replace($content, '<meta name="description" content="[^"]*"', "<meta name=`"description`" content=`"$ed`"")
    $content = [regex]::Replace($content, '<meta name="keywords" content="[^"]*"', "<meta name=`"keywords`" content=`"$ek`"")

    $content = [regex]::Replace($content, '<meta property="og:title" content="[^"]*"', "<meta property=`"og:title`" content=`"$et`"")
    $content = [regex]::Replace($content, '<meta property="og:description" content="[^"]*"', "<meta property=`"og:description`" content=`"$ed`"")
    $content = [regex]::Replace($content, '<meta property="og:site_name" content="[^"]*"', "<meta property=`"og:site_name`" content=`"$Brand`"")
    $content = [regex]::Replace($content, '<meta property="og:url" content="[^"]*"', "<meta property=`"og:url`" content=`"$absUrl`"")
    if ($content -match '<meta property="og:image"') {
        $content = [regex]::Replace($content, '<meta property="og:image" content="[^"]*"', "<meta property=`"og:image`" content=`"$ogImage`"")
    } else {
        $content = $content -replace '(<meta property="og:url"[^>]+>)', "`$1`n<meta property=`"og:image`" content=`"$ogImage`"/>"
    }
    if ($content -notmatch 'property="og:type"') {
        $content = $content -replace '(<meta property="og:site_name"[^>]+>)', "`$1`n<meta property=`"og:type`" content=`"website`"/>`n<meta property=`"og:locale`" content=`"en_US`"/>"
    }
    if ($content -match 'property="twitter:image"') {
        $content = [regex]::Replace($content, '<meta property="twitter:image" content="[^"]*"', "<meta property=`"twitter:image`" content=`"$ogImage`"")
    } elseif ($content -match 'name="twitter:card"') {
        $content = $content -replace '(<meta name="twitter:card"[^>]+>)', "<meta property=`"twitter:image`" content=`"$ogImage`"/>`n`$1"
    }

    if (Is-404Page $orig) {
        if ($content -notmatch 'name="robots"') {
            $content = $content -replace '(<meta name="description"[^>]+>)', "`$1`n        <meta name=`"robots`" content=`"noindex, follow`"/>"
        } else {
            $content = [regex]::Replace($content, '<meta name="robots" content="[^"]*"', '<meta name="robots" content="noindex, follow"')
        }
    }

    $content = [regex]::Replace($content, '<meta name="twitter:title" content="[^"]*"', "<meta name=`"twitter:title`" content=`"$et`"")
    $content = [regex]::Replace($content, '<meta name="twitter:description" content="[^"]*"', "<meta name=`"twitter:description`" content=`"$ed`"")

    $content = [regex]::Replace($content, '<link rel="canonical" href="[^"]*"', "<link rel=`"canonical`" href=`"$absUrl`"")

    # Global brand junk cleanup in remaining body text (og already fixed)
    $content = $content -replace [regex]::Escape($BrandJunk), $Brand

    $mustWrite = ($content -cne $orig)
    if (-not $mustWrite -and (Is-ProductDetailPage $webPath $orig)) {
        $expectedTitle = Get-PyramidProductTitle $orig $webPath $rawTitle
        if ($expectedTitle -cne (Get-CleanPageTitle $rawTitle)) { $mustWrite = $true }
    }

    if ($mustWrite) {
        [System.IO.File]::WriteAllText($_.FullName, $content, $Utf8)
        $updated++
    }
}

Write-Host "SEO meta updated in $updated HTML files (skipped $skipped)."
