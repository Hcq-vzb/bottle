# Process K4 product (19.html) carousel images - remove watermark
$siteRoot = "C:\My Websites\ecengmachine-full\www.ecengmachine.com"
$imgDir = Join-Path $siteRoot "omo-oss-image.thefastimg.com\portal-saas\pg2025032715012632289\cms\image"
$script = Join-Path $siteRoot "scripts\remove-watermark.js"
$page = Join-Path $siteRoot "products_detail\19.html"

$images = @(
  "c269b7ba-eba0-41d9-b793-661249dc1c51.jpg",
  "31f1412f-fe3c-4fd7-9b76-aa152b9a0444.jpg",
  "3e708038-9311-441e-8387-6a249c7eb386.jpg",
  "4c2eb6d3-f3a3-4fe4-882f-2532685dd9a6.jpg",
  "3e5d8353-0e5f-410c-b143-c494a3b227ac.jpg",
  "fe32834e-7c03-43cd-a87e-6902ba53b9bf.jpg",
  "3cdfc59e-cbba-49f1-8ebe-02a0aa180154.jpg",
  "8fd8ebf3-254e-49b6-b714-93eafac2bef3.jpg"
)

foreach ($name in $images) {
  $in = Join-Path $imgDir $name
  $out = Join-Path $imgDir ($name -replace '\.(jpg|jpeg|png|webp)$','-nowm.$1')
  if (-not (Test-Path $in)) { Write-Host "SKIP missing: $name"; continue }
  node $script $in $out
}

# Update 19.html to use -nowm versions for these 8 images
$content = Get-Content $page -Raw -Encoding UTF8
foreach ($name in $images) {
  $nowm = $name -replace '\.(jpg|jpeg|png|webp)$','-nowm.$1'
  $content = $content.Replace("/$name", "/$nowm")
}
[System.IO.File]::WriteAllText($page, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Updated products_detail/19.html to use -nowm images"
