# Replace language switcher with WhatsApp button across the site
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$WaUrl = 'https://wa.me/8617751189576'
$ErrorActionPreference = 'Stop'

$MainOld = @'
    <div class="cbox-23-2 p_item"><div class="e_substationNew-24 " needjs="true"> 
    <div class="p_title">
        <a href="lang/ms/worldwide.html" target="_blank">language</a>
        <svg t="1647312144701" class="p_openicon icon" viewBox="0 0 1024 1024" version="1.1"
            xmlns="http://www.w3.org/2000/svg" p-id="1689" width="16" height="16">
            <path d="M65.582671 288.791335l446.417329 446.41733 446.417329-446.41733z" p-id="1690"></path>
        </svg>
    </div>
    <div class="p_languageBox">
        <div class="p_language"></div>
    </div>
</div></div>
'@

$MainNew = @"
    <div class="cbox-23-2 p_item"><div class="e_whatsappBtn-24 head_whatsapp_btn">
    <a class="wa-consult-btn" href="$WaUrl" target="_blank" rel="noopener noreferrer" title="WhatsApp Consultation">
        <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" width="18" height="18" aria-hidden="true"><path fill="currentColor" d="M728.17777813 601.20177813C739.5555552 607.11822187 746.83733333 610.304 749.11288853 614.85511147 751.8435552 619.86133333 750.93333333 642.61688853 739.5555552 668.55822187 730.45333333 694.0444448 683.12177813 718.6204448 662.18666667 719.53066667 641.2515552 720.44088853 640.7964448 735.91466667 527.47377813 686.3075552 414.15111147 636.7004448 345.8844448 515.64088853 340.42311147 507.904 334.96177813 500.16711147 296.7324448 445.09866667 298.55288853 389.12 300.8284448 333.5964448 329.9555552 307.2 341.7884448 296.27733333 352.71111147 284.4444448 364.99911147 283.07911147 372.736 284.4444448L394.12622187 284.4444448C400.95288853 284.4444448 410.51022187 281.71377813 419.15733333 304.9244448L450.56 390.03022187C453.29066667 395.94666667 455.11111147 402.77333333 451.01511147 410.05511147L438.72711147 428.71466667 420.97777813 447.82933333C415.5164448 453.29066667 409.14488853 459.20711147 415.5164448 470.58488853 420.97777813 482.41777813 443.73333333 520.192 475.59111147 551.59466667 517.00622187 591.6444448 553.41511147 604.84266667 564.33777813 610.75911147 575.2604448 617.13066667 582.08711147 616.2204448 588.91377813 608.93866667L625.77777813 566.15822187C634.42488853 554.7804448 641.70666667 557.51111147 652.17422187 561.152L728.17777813 601.20177813M512 56.88888853C763.22133333 56.88888853 967.11111147 260.77866667 967.11111147 512 967.11111147 763.22133333 763.22133333 967.11111147 512 967.11111147 422.34311147 967.11111147 339.05777813 941.16977813 268.5155552 896.56888853L56.88888853 967.11111147 127.43111147 755.4844448C82.83022187 684.94222187 56.88888853 601.65688853 56.88888853 512 56.88888853 260.77866667 260.77866667 56.88888853 512 56.88888853M512 147.91111147C310.84088853 147.91111147 147.91111147 310.84088853 147.91111147 512 147.91111147 590.27911147 172.48711147 662.64177813 214.35733333 721.80622187L170.66666667 853.33333333 302.19377813 809.64266667C361.35822187 851.51288853 433.72088853 876.08888853 512 876.08888853 713.15911147 876.08888853 876.08888853 713.15911147 876.08888853 512 876.08888853 310.84088853 713.15911147 147.91111147 512 147.91111147Z"/></svg>
        <span>WhatsApp</span>
    </a>
</div></div>
"@

$LangSwitchRegex = '<span class="website_lang top_nav_btn"><a class="website_lang"\s+href=[^>]*>\s*switch language</a><i class="fa fa-angle-down"[^>]*></i></span>'
$LangSwitchNew = '<span class="top_nav_btn whatsapp_top_btn"><a href="' + $WaUrl + '" target="_blank" rel="noopener noreferrer"><i class="fa fa-whatsapp" aria-hidden="true"></i> WhatsApp</a></span>'

$LangBlockRegex = '(?s)<div class="cbox-23-2 p_item"><div class="e_substationNew-24[^>]*>.*?<a href="[^"]*worldwide\.html"[^>]*>language</a>.*?</div></div>'
$WorldwideNavRegex = '(?m)^\s*<li><a class="website_lang"[^>]*href=[^>]*worldwide[^>]*>.*?</li>\s*\r?\n'
$WorldwideFooterRegex = '(?m)^\s*<a href=[^>]*worldwide\.html[^>]*class="website_lang"[^>]*>.*?</a>\s*\r?\n'

$CssLink = '<link type="text/css" rel="stylesheet" href="npublic/css/whatsapp-header-btn.css">'
$CssLinkLang = '<link href="../../npublic/css/whatsapp-header-btn.css" rel="stylesheet" />'
$CssLinkLangSub = '<link href="../../../npublic/css/whatsapp-header-btn.css" rel="stylesheet" />'

$RedirectHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0;url=../../index.html">
<title>Redirecting...</title>
<script>location.replace('../../index.html');</script>
</head>
<body><p><a href="../../index.html">Go to homepage</a></p></body>
</html>
"@

$RedirectHtmlSub = $RedirectHtml -replace '../../index.html', '../../../index.html'

function Get-CssLinkForFile {
    param([string]$RelPath)
    $depth = ([regex]::Matches($RelPath, '\\')).Count
    if ($depth -eq 0) { return $CssLink }
    $prefix = ('../' * $depth)
    return "<link type=`"text/css`" rel=`"stylesheet`" href=`"${prefix}npublic/css/whatsapp-header-btn.css`">"
}

$mainCount = 0
$langCount = 0
$worldwideCount = 0
$navRemoved = 0
$blockRegexCount = 0

Get-ChildItem -Path $SiteRoot -Recurse -Include *.html -File | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    $orig = $content
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)

    if ($content.Contains($MainOld)) {
        $content = $content.Replace($MainOld, $MainNew)
        $mainCount++
    }

    if ($content -match $LangBlockRegex) {
        $n = ([regex]::Matches($content, $LangBlockRegex)).Count
        $content = [regex]::Replace($content, $LangBlockRegex, $MainNew)
        $blockRegexCount += $n
    }

    if ($content -match 'e_whatsappBtn-24' -and $content -notmatch 'whatsapp-header-btn\.css') {
        $cssForFile = Get-CssLinkForFile $rel
        if ($content -match '<link type="text/css" rel="stylesheet" href="css/site8456\.css') {
            $content = $content -replace '(<link type="text/css" rel="stylesheet" href="css/site8456\.css[^"]*">)', "`$1`n    $cssForFile"
        } elseif ($content -match '</head>') {
            $content = $content -replace '(</head>)', "    $cssForFile`n`$1"
        }
    }

    if ($content -match $LangSwitchRegex) {
        $content = [regex]::Replace($content, $LangSwitchRegex, $LangSwitchNew)
        $langCount++
    }

    $isLangPath = ($rel -like 'lang\*') -or ($_.FullName -match '[\\/]lang[\\/]')
    if ($isLangPath) {
        if ($content -match $WorldwideNavRegex) {
            $before = ([regex]::Matches($content, $WorldwideNavRegex)).Count
            $content = [regex]::Replace($content, $WorldwideNavRegex, '')
            $navRemoved += $before
        }
        if ($content -match $WorldwideFooterRegex) {
            $content = [regex]::Replace($content, $WorldwideFooterRegex, '')
        }
    }

    if ($_.Name -eq 'worldwide.html') {
        if ($rel -match '\\lang\\[^\\]+\\[^\\]+\\') {
            $content = $RedirectHtmlSub
        } else {
            $content = $RedirectHtml
        }
        $worldwideCount++
    }

    if ($isLangPath -and $content -notmatch 'whatsapp-header-btn\.css') {
        if ($rel -match '^lang\\[^\\]+\\[^\\]+\\') {
            $content = $content -replace '(<link href="../../intelling/static/css/style\.css" rel="stylesheet" />)', "`$1`n$CssLinkLangSub"
        } else {
            $content = $content -replace '(<link href="../intelling/static/css/style\.css" rel="stylesheet" />)', "`$1`n$CssLinkLang"
            if ($content -notmatch 'whatsapp-header-btn') {
                $content = $content -replace '(<link href="../../intelling/static/css/style\.css" rel="stylesheet" />)', "`$1`n$CssLinkLang"
            }
        }
    }

    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    }
}

Write-Host "Main pages updated (exact): $mainCount"
Write-Host "Language blocks replaced (regex): $blockRegexCount"
Write-Host "Lang switch buttons updated: $langCount"
Write-Host "Worldwide nav items removed: $navRemoved"
Write-Host "worldwide.html redirects: $worldwideCount"
