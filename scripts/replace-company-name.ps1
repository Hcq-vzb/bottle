# Replace footer copyright and Zhangjiagang Eceng company name site-wide
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$newCompany = 'Jiangsu KlWL Machinery Manufacturing Group Co., Ltd.'
$newFooter = "&copy;2026 $newCompany"

$replacements = @(
    @{ Old = '&copy;2024 Zhangjiagang Eceng Machinery Co., Ltd.'; New = $newFooter },
    @{ Old = '&copy;2024 Zhangjiagang Eceng Machinery Co.,Ltd.'; New = $newFooter },
    @{ Old = '©2024 Zhangjiagang Eceng Machinery Co., Ltd.'; New = "©2026 $newCompany" },
    @{ Old = '©2024 Zhangjiagang Eceng Machinery Co.,Ltd.'; New = "©2026 $newCompany" },
    @{ Old = 'Zhangjiagang Eceng Machinery Co., Ltd.'; New = $newCompany },
    @{ Old = 'Zhangjiagang Eceng Machinery Co.,Ltd.'; New = $newCompany },
    @{ Old = 'Zhangjiagang Eceng Machinery Co., Ltd'; New = $newCompany.TrimEnd('.') },
    @{ Old = 'Zhangjiagang Eceng Machine Co., Ltd.'; New = $newCompany },
    @{ Old = 'Zhangjiagang Eceng Machine Co.,Ltd.'; New = $newCompany },
    @{ Old = 'Zhangjiagang Eceng Machine Co., Ltd'; New = $newCompany.TrimEnd('.') },
    @{ Old = 'Zhangjiagang Eceng Machinery co., Ltd.'; New = $newCompany },
    @{ Old = 'Zhangjiagang Eceng Machinery co., Ltd'; New = $newCompany.TrimEnd('.') },
    @{ Old = 'Zhangjiagang Eceng Machinery'; New = $newCompany },
    @{ Old = 'Zhangjiagang Eceng'; New = $newCompany }
)

$fileCount = 0
$changeCount = 0

Get-ChildItem -Path $SiteRoot -Recurse -Include *.html,*.htm,*.xml -File | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    $original = $content

    foreach ($pair in $replacements) {
        if ($content.Contains($pair.Old)) {
            $content = $content.Replace($pair.Old, $pair.New)
        }
    }

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
        $fileCount++
        $changeCount += ([regex]::Matches($original, 'Zhangjiagang Eceng|&copy;2024 Zhangjiagang|©2024 Zhangjiagang')).Count
    }
}

Write-Host "Updated $fileCount files."

# Self-check: report remaining matches
$remaining = @()
Get-ChildItem -Path $SiteRoot -Recurse -Include *.html,*.htm -File | ForEach-Object {
    $text = [System.IO.File]::ReadAllText($_.FullName)
    if ($text -match 'Zhangjiagang Eceng') {
        $rel = $_.FullName.Substring($SiteRoot.Length + 1)
        $remaining += $rel
    }
}

if ($remaining.Count -eq 0) {
    Write-Host 'Self-check passed: no remaining Zhangjiagang Eceng references.'
} else {
    Write-Host "Self-check: $($remaining.Count) files still contain Zhangjiagang Eceng:"
    $remaining | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" }
}
