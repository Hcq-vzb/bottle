# Replace contact info and domain site-wide
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$replacements = @(
    @{ Old = 'zack@ecengcompany.com'; New = 'cathy@kiwlmachine.com' },
    @{ Old = 'www.ecengmachine.com'; New = 'bottleblowtech.com' },
    @{ Old = 'ecengmachine.com'; New = 'bottleblowtech.com' },
    @{ Old = '+86 13812983871'; New = '+86 18151132311' },
    @{ Old = '+8613812983871'; New = '+8618151132311' },
    @{ Old = '8613812983871'; New = '8618151132311' },
    @{ Old = '13812983871'; New = '18151132311' },
    @{ Old = 'zack'; New = 'cathy' }
)

$extensions = @('*.html', '*.htm', '*.xml', '*.js', '*.css')
$fileCount = 0

Get-ChildItem -Path $SiteRoot -Recurse -Include $extensions -File |
    Where-Object { $_.FullName -notmatch '\\scripts\\' } |
    ForEach-Object {
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
        }
    }

Write-Host "Updated $fileCount files."

$checks = @(
    'zack@ecengcompany.com',
    'www.ecengmachine.com',
    'ecengmachine.com',
    '13812983871',
    '\bzack\b'
)

foreach ($pattern in $checks) {
    $remaining = @()
    Get-ChildItem -Path $SiteRoot -Recurse -Include $extensions -File |
        Where-Object { $_.FullName -notmatch '\\scripts\\' } |
        ForEach-Object {
            $text = [System.IO.File]::ReadAllText($_.FullName)
            if ($text -match $pattern) {
                $remaining += $_.FullName.Substring($SiteRoot.Length + 1)
            }
        }
    if ($remaining.Count -eq 0) {
        Write-Host "OK: no remaining '$pattern'"
    } else {
        Write-Host "WARN: $($remaining.Count) files still match '$pattern'"
        $remaining | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
    }
}
