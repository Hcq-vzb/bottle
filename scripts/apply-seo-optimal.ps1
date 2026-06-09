# Run full SEO optimization pipeline (Google-aligned)
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$BaseUrl = 'https://www.bottleblowtech.com'
)

$scriptDir = $PSScriptRoot
Write-Host '=== KlWL Machinery SEO Pipeline ===' -ForegroundColor Cyan

& (Join-Path $scriptDir 'fix-seo-cleanup.ps1') -SiteRoot $SiteRoot
& (Join-Path $scriptDir 'apply-seo-site-wide.ps1') -SiteRoot $SiteRoot -BaseUrl $BaseUrl
& (Join-Path $scriptDir 'apply-seo-structured-data.ps1') -SiteRoot $SiteRoot -BaseUrl $BaseUrl
& (Join-Path $scriptDir 'generate-seo-infra.ps1') -SiteRoot $SiteRoot -BaseUrl $BaseUrl
& (Join-Path $scriptDir 'audit-meta-keywords.ps1') -SiteRoot $SiteRoot

Write-Host '=== SEO pipeline complete ===' -ForegroundColor Green
