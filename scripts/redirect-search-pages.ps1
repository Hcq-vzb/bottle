# Replace search result pages with redirect to homepage
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$redirectRoot = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="0; url=index.html">
  <title>Redirecting…</title>
  <script>location.replace('index.html');</script>
</head>
<body>
  <p><a href="index.html">Go to homepage</a></p>
</body>
</html>
'@

$redirectSub = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="0; url=../index.html">
  <title>Redirecting…</title>
  <script>location.replace('../index.html');</script>
</head>
<body>
  <p><a href="../index.html">Go to homepage</a></p>
</body>
</html>
'@

$files = @(
    @{ Path = 'result31dc.html'; Content = $redirectRoot },
    @{ Path = 'result\p-0-12.html'; Content = $redirectSub },
    @{ Path = 'result\p-12-12.html'; Content = $redirectSub },
    @{ Path = 'result\p-24-12.html'; Content = $redirectSub },
    @{ Path = 'result\p-36-12.html'; Content = $redirectSub },
    @{ Path = 'result\p-48-12.html'; Content = $redirectSub }
)

foreach ($f in $files) {
    $full = Join-Path $SiteRoot $f.Path
    [System.IO.File]::WriteAllText($full, $f.Content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Updated $($f.Path)"
}
