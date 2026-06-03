# Sync About Us Honor certificate images (Certificate1-14) with homepage patent carousel
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$HomeImages = @(
    'fdb5845b-f3ad-4d81-9852-a2d3693617ae.jpg',
    '793d1b16-abb2-45d1-9af0-eff13e58d8ce.jpg',
    '5822c780-8902-4b24-b4d1-e72d71830ba0.jpg',
    '4eb7e1f3-f922-4b13-a2b0-a25e20be60ef.jpg',
    '129aaec5-b9ad-448a-9f11-718e6bd90700.jpg',
    'f853e0cf-b591-4b88-ab77-bcd613535b8a.jpg',
    '800ed61c-653b-4d68-a841-45d2ac5314b2.jpg',
    'd37c688e-6617-4585-815c-1803672601e2.jpg',
    'd8cc6623-50a7-4156-8bc5-b8267dd81882.jpg',
    'bcff0745-ebdd-421b-9cd4-a1e753d1460e.jpg',
    'cdd8df3a-d3d0-4bf2-b6e5-27b70c1ea16a.jpg',
    '5bb3cde4-6d9e-4a09-bbe0-d248cc06474a.jpg',
    'e766f184-9661-4820-b830-7067c4f25eb2.jpg',
    'be4e57e7-c77e-4dad-b14b-b9c4ef97ed9c.jpg'
)

$ImageBase = 'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/image/'
$HonorSectionId = 'c_introl_detail_007_P_012-17491136567160'
$CertMap = @{}
for ($n = 14; $n -ge 1; $n--) {
    $CertMap["Certificate$n"] = $HomeImages[14 - $n]
}

# CE Certification / CE Report also use homepage patent images
$CertMap['CE Certification'] = $HomeImages[2]
$CertMap['CE Report'] = $HomeImages[3]

$files = @(
    (Join-Path $SiteRoot 'jianjie.html'),
    (Join-Path $SiteRoot 'jianjie\p-0-8.html'),
    (Join-Path $SiteRoot 'jianjie\p-8-8.html'),
    (Join-Path $SiteRoot 'jianjie\p-16-8.html')
)

$updated = 0

foreach ($file in $files) {
    if (-not (Test-Path $file)) { continue }
    $content = [System.IO.File]::ReadAllText($file)
    $orig = $content

    $sectionStart = $content.IndexOf("id=`"$HonorSectionId`"")
    if ($sectionStart -lt 0) { continue }
    $sectionEnd = $content.IndexOf('id="c_introl_detail_007_P_012-1712640787514"', $sectionStart)
    if ($sectionEnd -lt 0) { $sectionEnd = $content.Length }

    $before = $content.Substring(0, $sectionStart)
    $section = $content.Substring($sectionStart, $sectionEnd - $sectionStart)
    $after = $content.Substring($sectionEnd)

    foreach ($label in $CertMap.Keys) {
        $fileName = $CertMap[$label]
        $newPath = $fileName
        $escapedLabel = [regex]::Escape($label)
        $pattern = '(?s)(<img\s+src="(?:\./|\.\./)?' + [regex]::Escape($ImageBase) + ')[^"]+("\s+alt="' + $escapedLabel + '")'
        $section = [regex]::Replace($section, $pattern, "`${1}$newPath`${2}")
    }

    $content = $before + $section + $after
    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($file, $content, [System.Text.UTF8Encoding]::new($false))
        $updated++
    }
}

Write-Host "Updated Honor images in $updated file(s)."
