$SiteRoot = Split-Path $PSScriptRoot -Parent
$results = @{}
$empty = [System.Collections.Generic.List[string]]::new()
$withKw = [System.Collections.Generic.List[object]]::new()
$noTag = [System.Collections.Generic.List[string]]::new()
$allTerms = @{}

Get-ChildItem -Path $SiteRoot -Recurse -Filter *.html -File | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    $rel = $_.FullName.Substring($SiteRoot.Length + 1)
    if ($c -match '<meta\s+name="keywords"\s+content="([^"]*)"') {
        $kw = $Matches[1].Trim()
        if ($kw -eq '') {
            $empty.Add($rel)
        } else {
            $withKw.Add([PSCustomObject]@{ File = $rel; Keywords = $kw })
            if (-not $results.ContainsKey($kw)) {
                $results[$kw] = [System.Collections.Generic.List[string]]::new()
            }
            $results[$kw].Add($rel)
            foreach ($term in ($kw -split ',')) {
                $t = $term.Trim()
                if ($t -eq '') { continue }
                $key = $t.ToLowerInvariant()
                if (-not $allTerms.ContainsKey($key)) {
                    $allTerms[$key] = @{ Display = $t; Count = 0; Files = [System.Collections.Generic.List[string]]::new() }
                }
                $allTerms[$key].Count++
                if (-not $allTerms[$key].Files.Contains($rel)) {
                    $allTerms[$key].Files.Add($rel)
                }
            }
        }
    } else {
        $noTag.Add($rel)
    }
}

$out = Join-Path $SiteRoot 'scripts\meta-keywords-audit.txt'
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('=== SITE-WIDE META KEYWORDS AUDIT ===')
[void]$sb.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine('')
[void]$sb.AppendLine('--- SUMMARY ---')
[void]$sb.AppendLine("Pages with meta keywords tag: $($empty.Count + $withKw.Count)")
[void]$sb.AppendLine("Pages with EMPTY keywords: $($empty.Count)")
[void]$sb.AppendLine("Pages with keywords filled: $($withKw.Count)")
[void]$sb.AppendLine("Pages WITHOUT meta keywords tag: $($noTag.Count)")
[void]$sb.AppendLine("Unique keyword strings (full content): $($results.Count)")
[void]$sb.AppendLine("Unique individual terms: $($allTerms.Count)")
[void]$sb.AppendLine('')

[void]$sb.AppendLine('--- UNIQUE KEYWORD STRINGS (grouped by identical content) ---')
foreach ($entry in ($results.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending)) {
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("[ $($entry.Value.Count) pages ] $($entry.Key)")
    foreach ($f in ($entry.Value | Sort-Object)) {
        [void]$sb.AppendLine("  - $f")
    }
}

[void]$sb.AppendLine('')
[void]$sb.AppendLine('--- ALL INDIVIDUAL TERMS (sorted by page count) ---')
foreach ($entry in ($allTerms.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending)) {
    $disp = $entry.Value.Display
    $cnt = $entry.Value.Count
    $fc = $entry.Value.Files.Count
    [void]$sb.AppendLine("$fc pages | term: $disp")
}

[void]$sb.AppendLine('')
[void]$sb.AppendLine('--- PAGES WITH EMPTY KEYWORDS ---')
foreach ($f in ($empty | Sort-Object)) {
    [void]$sb.AppendLine("  - $f")
}

if ($noTag.Count -gt 0) {
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('--- PAGES WITHOUT META KEYWORDS TAG ---')
    foreach ($f in ($noTag | Sort-Object)) {
        [void]$sb.AppendLine("  - $f")
    }
}

[System.IO.File]::WriteAllText($out, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $out"
Write-Host "Empty: $($empty.Count) | Filled: $($withKw.Count) | Unique strings: $($results.Count) | Unique terms: $($allTerms.Count)"
