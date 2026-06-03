# Fix omo-oss-image paths to resolve under www.ecengmachine.com (not parent ecengmachine-full)
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"
$extensions = @('*.html', '*.htm', '*.css', '*.js')
$excludeDirs = @('node_modules', '.git')

function Get-OssPrefix([string]$FilePath, [string]$Root) {
    $dir = [System.IO.Path]::GetDirectoryName($FilePath)
    if ($dir.Length -le $Root.Length) { return './' }
    $relative = $dir.Substring($Root.Length).TrimStart('\', '/')
    if ([string]::IsNullOrWhiteSpace($relative)) { return './' }
    $depth = @($relative -split '[\\/]' | Where-Object { $_ -ne '' }).Count
    if ($depth -le 0) { return './' }
    return ('../' * $depth)
}

function Fix-OssPaths([string]$Content, [string]$Prefix) {
    $target = $Prefix + 'omo-oss-image.thefastimg.com/'
    $content = $Content -replace '(?i)https?://omo-oss-image1?\.thefastimg\.com/', $target
    $content = $Content -replace '(?i)//omo-oss-image1?\.thefastimg\.com/', $target
    $content = [regex]::Replace($content, '(?i)(?:\.\./|\./)*omo-oss-image1?\.thefastimg\.com/', $target)
    $content = $content -replace '(?i)(omo-oss-image\.thefastimg\.com)/+', '$1/'
    return $content
}

$excludeFiles = @(
    (Join-Path $SiteRoot 'npublic\js\local-home-fix.js'),
    (Join-Path $SiteRoot 'upload\js\f443dc4c19004859b92c4f7a94153c208456.js')
)

$files = Get-ChildItem -Path $SiteRoot -Recurse -Include $extensions -File |
    Where-Object {
        $rel = $_.FullName.Substring($SiteRoot.Length + 1)
        -not ($excludeDirs | Where-Object { $rel -like "$_*\\*" -or $rel -like "$_/*" })
        -not ($excludeFiles -contains $_.FullName)
    }

$changed = 0
foreach ($file in $files) {
    $raw = [System.IO.File]::ReadAllText($file.FullName)
    if ($raw -notmatch '(?i)omo-oss-image1?\.thefastimg\.com') { continue }

    $prefix = Get-OssPrefix $file.FullName $SiteRoot
    $updated = Fix-OssPaths $raw $prefix
    if ($updated -ne $raw) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
        $changed++
    }
}

Write-Host "Fixed OSS image paths in $changed file(s) under $SiteRoot"
