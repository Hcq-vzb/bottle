$c = [IO.File]::ReadAllText("$PSScriptRoot\..\css\Home_611140efc94dcf9e0c26ce180f97eb4f.min8456.css")
foreach ($pat in @('e_container-14','e_container-23','cbox-23-2','h_head','head_whatsapp','p_navButton')) {
  Write-Host "=== $pat ==="
  [regex]::Matches($c, [regex]::Escape($pat) + '[^}]{0,350}') | Select-Object -First 4 | ForEach-Object { $_.Value; '---' }
}
