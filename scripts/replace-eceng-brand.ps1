# Replace visible brand "Eceng" with "KlWL" site-wide (preserve domains/paths)
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$protect = [ordered]@{
    'www.ecengmachine.com' = '___PROTECT_DOMAIN_WWW___'
    'ecengmachine.com'     = '___PROTECT_DOMAIN___'
    'eceng-chuipingji.com' = '___PROTECT_EXT_DOMAIN___'
}

$replacements = @(
    @{ Old = 'Eceng Machinery'; New = 'KlWL Machinery' },
    @{ Old = 'Eceng Machine'; New = 'KlWL Machine' },
    @{ Old = 'Eceng machinery'; New = 'KlWL machinery' },
    @{ Old = 'Eceng machine'; New = 'KlWL machine' },
    @{ Old = 'Eceng'; New = 'KlWL' }
)

$fileCount = 0
$extensions = @('*.html', '*.htm', '*.xml')

Get-ChildItem -Path $SiteRoot -Recurse -Include $extensions -File |
    Where-Object { $_.FullName -notmatch '\\scripts\\' } |
    ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        if ($content -notmatch 'Eceng') { return }

        $original = $content

        foreach ($key in $protect.Keys) {
            $content = $content.Replace($key, $protect[$key])
        }

        foreach ($pair in $replacements) {
            if ($content.Contains($pair.Old)) {
                $content = $content.Replace($pair.Old, $pair.New)
            }
        }

        foreach ($key in $protect.Keys) {
            $content = $content.Replace($protect[$key], $key)
        }

        if ($content -ne $original) {
            [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
            $fileCount++
        }
    }

Write-Host "Updated $fileCount files."

$remaining = @()
Get-ChildItem -Path $SiteRoot -Recurse -Include $extensions -File |
    Where-Object { $_.FullName -notmatch '\\scripts\\' } |
    ForEach-Object {
        $text = [System.IO.File]::ReadAllText($_.FullName)
        if ($text -match 'Eceng') {
            $remaining += $_.FullName.Substring($SiteRoot.Length + 1)
        }
    }

if ($remaining.Count -eq 0) {
    Write-Host 'Self-check passed: no remaining Eceng in HTML/XML.'
} else {
    Write-Host "Self-check: $($remaining.Count) files still contain Eceng:"
    $remaining | Select-Object -First 25 | ForEach-Object { Write-Host "  $_" }
}
