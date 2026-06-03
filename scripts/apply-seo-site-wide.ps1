# Site-wide SEO: brand unification, title/description, canonical, og tags, empty keywords
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$BaseUrl = 'https://www.bottleblowtech.com'
)

$Brand = 'KlWL Machinery'
$BrandJunk = 'KlWL Machine_a high-tech enterprise integrating research'
$Utf8 = [System.Text.UTF8Encoding]::new($false)

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
        Keywords    = 'KlWL Machinery, stretch blow molding machine, plastic jar making machine, water bottle production machine'
    }
    'contact.html' = @{
        Title       = 'Contact KlWL Machinery | Get a Quote'
        Description = 'Contact KlWL Machinery for bottle blowing machine quotes and technical support. Jiangsu KlWL Machinery Manufacturing Group Co., Ltd. - fast response worldwide.'
        Keywords    = 'KlWL Machinery, water bottle production machine, jar making machine, stretch blow molding machine'
    }
    'jianjie.html' = @{
        Title       = 'About KlWL Machinery | Bottle Blowing Machine Manufacturer'
        Description = 'About Jiangsu KlWL Machinery Manufacturing Group Co., Ltd. - high-tech PET bottle blowing machine manufacturer founded in 2007, serving 170+ countries worldwide.'
        Keywords    = 'KlWL Machinery, plastic bottle manufacturing equipment, plastic bottle making machine, pet bottle making machine'
    }
    'advantages.html' = @{
        Title       = 'Enterprise Advantages | KlWL Machinery'
        Description = 'Discover KlWL Machinery enterprise advantages - R&D, production and global service for PET and plastic bottle blowing machines since 2007.'
        Keywords    = 'KlWL Machinery, plastic blowing machine, automatic blow molding machine'
    }
    'fazhan.html' = @{
        Title       = 'Corporate Vision | KlWL Machinery'
        Description = 'KlWL Machinery corporate vision - leading PET and plastic bottle blowing machine manufacturer from Jiangsu, China.'
        Keywords    = 'KlWL Machinery, plastic blowing machine, automatic blow molding machine'
    }
    'Download.html' = @{
        Title       = 'Downloads | KlWL Machinery'
        Description = 'Download KlWL Machinery product catalogs and technical resources for PET bottle blowing machines.'
        Keywords    = 'KlWL Machinery, plastic blowing machine, automatic blow molding machine'
    }
}

$SeriesSeo = @{
    'Q_Series_Energy_Saving_PET_Blowing_Machine.html' = @{
        Keywords    = 'KlWL Machinery, PET bottle blowing machine, energy saving blow molding machine, automatic bottle blowing machine'
        Description = 'KlWL Machinery Q Series energy-saving PET bottle blowing machines - high output, lower power consumption. Automatic stretch blow molding from China factory direct.'
    }
    'H_Series_Hand_Feeding_Blowing_Machine.html' = @{
        Keywords    = 'KlWL Machinery, hand feeding blow molding machine, semi automatic PET blowing machine'
        Description = 'KlWL Machinery H Series hand feeding bottle blowing machines for flexible PET bottle production. Ideal for startups and custom bottle runs.'
    }
    'J_Series_Jar_Blow_Molding_Machine.html' = @{
        Keywords    = 'KlWL Machinery, jar blowing machine, plastic jar making machine, PET jar manufacturing machine'
        Description = 'KlWL Machinery J Series jar blow molding machines for plastic and PET jars. Multi-cavity automatic production from factory direct.'
    }
    'YC_Series_Semi_Auto_PET_Blowing_Machine.html' = @{
        Keywords    = 'KlWL Machinery, semi automatic PET blowing machine, semi auto blow molding machine'
        Description = 'KlWL Machinery YC Series semi-automatic PET blowing machines - cost-effective bottle production for water, oil and packaging bottles.'
    }
    'YCQ_Series_Economic_Blow_Molding_Machine.html' = @{
        Keywords    = 'KlWL Machinery, economic blow molding machine, PET blow molding machine'
        Description = 'KlWL Machinery YCQ Series economic blow molding machines - reliable PET bottle production at competitive factory-direct pricing.'
    }
    'QH_Series.html' = @{
        Keywords    = 'KlWL Machinery, high speed bottle blowing machine, PET blowing machine'
        Description = 'KlWL Machinery QH Series high-performance PET bottle blowing machines for high-speed production lines.'
    }
    'QJ_Series.html' = @{
        Keywords    = 'KlWL Machinery, jar making machine, auto jar making machine, blow molding machine'
        Description = 'KlWL Machinery QJ Series auto jar making machines - multi-cavity blow molding for PET and plastic jars.'
    }
    'Auxiliary_Machine_Series.html' = @{
        Keywords    = 'KlWL Machinery, air compressor, chiller, cold dryer, bottle blowing auxiliary equipment'
        Description = 'KlWL Machinery auxiliary equipment for bottle blowing lines - air compressors, chillers, cold dryers and more.'
    }
    'Blowing_Machine_Mold.html' = @{
        Keywords    = 'KlWL Machinery, blow mold, PET bottle mold, blowing machine mold'
        Description = 'KlWL Machinery blow molds and PET bottle molds - precision tooling for bottle blowing production lines.'
    }
    'Capping_Machine_Series.html' = @{
        Keywords    = 'KlWL Machinery, capping machine, bottle capping machine, multi cavity capping machine'
        Description = 'KlWL Machinery capping machine series - high-speed multi-cavity capping for PET bottle production lines.'
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
    } elseif ($NewsListTitles.ContainsKey($webPath)) {
        $title = $NewsListTitles[$webPath]
        $description = "$Brand news and industry updates about PET bottle blowing machines, blow molding technology and KlWL Machinery exhibitions."
        $keywords = 'KlWL Machinery, plastic blowing machine, automatic blow molding machine'
    } elseif ($SeriesSeo.ContainsKey($webPath)) {
        $s = $SeriesSeo[$webPath]
        $title = Get-CleanPageTitle $rawTitle
        $description = $s.Description
        $keywords = $s.Keywords
    } elseif ($webPath -like 'products_list/*') {
        $title = Get-CleanPageTitle $rawTitle
        if ($title -match 'Product Center\s*\|') {
            $title = 'PET Bottle Blowing Machines | Product List | KlWL Machinery'
        }
        $description = 'Browse KlWL Machinery PET and plastic bottle blowing machines. Automatic and semi-automatic models for water, oil, jar and packaging bottles - factory direct.'
        $keywords = 'KlWL Machinery, PET bottle blowing machine, plastic bottle blowing machine, stretch blow molding machine'
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
        $keywords = 'KlWL Machinery, plastic blowing machine, automatic blow molding machine'
    } elseif ($webPath -like 'news_lsit/*') {
        $title = Get-CleanPageTitle $rawTitle
        if ($title -match 'News_News|News_Knowledge|News_Company') {
            $title = ($title -replace 'News_News', 'News' -replace 'News_Knowledge', 'Knowledge' -replace 'News_Company News', 'Company News' -replace 'News_Show information', 'News')
        }
        $description = "$Brand news and updates on PET bottle blowing machines, blow molding technology and global exhibitions."
        $keywords = 'KlWL Machinery, plastic blowing machine, automatic blow molding machine'
    } else {
        $title = Get-CleanPageTitle $rawTitle
        $m = [regex]::Match($content, '<meta name="description" content="([^"]*)"')
        $rawDesc = if ($m.Success) { $m.Groups[1].Value } else { '' }
        $description = Fix-Description $rawDesc $title
        $m2 = [regex]::Match($content, '<meta name="keywords" content="([^"]*)"')
        $keywords = if ($m2.Success -and $m2.Groups[1].Value.Trim() -ne '') {
            $kw = $m2.Groups[1].Value
            if ($kw -notmatch 'KlWL') { "KlWL Machinery, $kw" } else { $kw -replace '\bKlWL Machine\b', $Brand }
        } else {
            $base = ($title -replace '\s\|\s*KlWL Machinery\s*$', '').Trim()
            "KlWL Machinery, $base, bottle blowing machine"
        }
    }

    $et = Escape-HtmlAttr $title
    $ed = Escape-HtmlAttr $description
    $ek = Escape-HtmlAttr $keywords

    $content = [regex]::Replace($content, '<title>[^<]*</title>', "<title>$et</title>")
    $content = [regex]::Replace($content, '<meta name="description" content="[^"]*"', "<meta name=`"description`" content=`"$ed`"")
    $content = [regex]::Replace($content, '<meta name="keywords" content="[^"]*"', "<meta name=`"keywords`" content=`"$ek`"")

    $content = [regex]::Replace($content, '<meta property="og:title" content="[^"]*"', "<meta property=`"og:title`" content=`"$et`"")
    $content = [regex]::Replace($content, '<meta property="og:description" content="[^"]*"', "<meta property=`"og:description`" content=`"$ed`"")
    $content = [regex]::Replace($content, '<meta property="og:site_name" content="[^"]*"', "<meta property=`"og:site_name`" content=`"$Brand`"")
    $content = [regex]::Replace($content, '<meta property="og:url" content="[^"]*"', "<meta property=`"og:url`" content=`"$absUrl`"")

    $content = [regex]::Replace($content, '<meta name="twitter:title" content="[^"]*"', "<meta name=`"twitter:title`" content=`"$et`"")
    $content = [regex]::Replace($content, '<meta name="twitter:description" content="[^"]*"', "<meta name=`"twitter:description`" content=`"$ed`"")

    $content = [regex]::Replace($content, '<link rel="canonical" href="[^"]*"', "<link rel=`"canonical`" href=`"$absUrl`"")

    # Global brand junk cleanup in remaining body text (og already fixed)
    $content = $content -replace [regex]::Escape($BrandJunk), $Brand

    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $content, $Utf8)
        $updated++
    }
}

Write-Host "SEO meta updated in $updated HTML files (skipped $skipped)."
