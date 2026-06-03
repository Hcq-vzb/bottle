# Replace Cases & Events inline video with Video-page cover display
param(
    [string]$SiteRoot = (Split-Path $PSScriptRoot -Parent)
)

$cssTag = '<link type="text/css" rel="stylesheet" href="../npublic/css/video-no-play.css">'
$jsTag = '<script src="../npublic/js/video-no-play.js"></script>'
$playIco = '<svg class="playIco" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" width="500" height="500"><path d="M435.2 665.6V358.4l256 153.6z" fill="#ffffff"></path><path d="M512 204.8c168.96 0 307.2 138.24 307.2 307.2s-138.24 307.2-307.2 307.2-307.2-138.24-307.2-307.2 138.24-307.2 307.2-307.2m0-51.2c-199.68 0-358.4 158.72-358.4 358.4s158.72 358.4 358.4 358.4 358.4-158.72 358.4-358.4-158.72-358.4-358.4-358.4z" fill="#ffffff"></path></svg>'
$count = 0

Get-ChildItem -Path (Join-Path $SiteRoot 'shouhou') -Filter '*.html' -File | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    if ($content -notmatch 'ckeditor-html5-video|<video') { return }

    if ($content -match '<video[^>]+src="([^"]+\.mp4)"') {
        $mp4 = $Matches[1]
        $coverBlock = @"
<div class="ckeditor-html5-video shouhou-video-cover videoCock" style="text-align: center;">
<div class="e_video-7 s_img">
<div class="p_video">
<span class="cover">
$playIco
<div class="coverImage">
<img src="../npublic/img/s.png" data-random-video-cover="true" alt="" title="" la="la"/>
</div>
</span>
<div class="videoBox">
<video class="video" muted controls></video>
<div class="closeVideo">Close video</div>
</div>
</div>
</div>
</div>
"@

        $content = [regex]::Replace(
            $content,
            '<div class="ckeditor-html5-video"[^>]*>\s*<video[^>]*>\s*(?:&nbsp;)?\s*</video>\s*</div>',
            [System.Text.RegularExpressions.MatchEvaluator]{ $coverBlock },
            1
        )
    }

    if ($content -notmatch 'video-no-play\.css') {
        if ($content -match 'popbox-close-fix\.css') {
            $content = $content -replace '(<link type="text/css" rel="stylesheet" href="\.\./npublic/css/popbox-close-fix\.css">)', "`$1`n    $cssTag"
        } elseif ($content -match '</head>') {
            $content = $content -replace '(</head>)', "    $cssTag`n`$1"
        }
    }

    if ($content -notmatch 'video-no-play\.js') {
        if ($content -match 'popbox-close-fix\.js') {
            $content = $content -replace '(<script src="\.\./npublic/js/popbox-close-fix\.js"></script>)', "`$1`n    $jsTag"
        } elseif ($content -match '</body>') {
            $content = $content -replace '(</body>)', "    $jsTag`n`$1"
        }
    }

    [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    $count++
}

Write-Host "Updated $count Cases & Events HTML files."
