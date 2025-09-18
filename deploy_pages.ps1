# ============================
# Deploy Flutter Web to GitHub Pages (/docs)
# Author: Marilu
# ============================

# ---- Config ----
$RepoName = "marilu_portfolio"   # nombre del repo (iguala la URL /<repo>/)
$Branch   = "main"               # rama desde la que publicás
$Renderer = "canvaskit"          # o "html"
$Url      = "https://marilu1707.github.io/$RepoName/"

function Stop-OnError($msg) {
  Write-Host "`nERROR: $msg" -ForegroundColor Red
  exit 1
}

# ---- Checks ----
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Stop-OnError "Flutter no está en PATH." }
if (-not (Test-Path .git)) { Stop-OnError "No es un repo git (faltan .git). Ejecutá 'git init' antes." }

# ---- Build ----
Write-Host "`n[1/4] flutter clean + pub get" -ForegroundColor Yellow
flutter clean; if ($LASTEXITCODE) { Stop-OnError "flutter clean falló" }
flutter pub get; if ($LASTEXITCODE) { Stop-OnError "flutter pub get falló" }

Write-Host "`n[2/4] flutter build web (base-href=/$RepoName/)" -ForegroundColor Yellow
flutter build web --release --web-renderer $Renderer --base-href "/$RepoName/"
if ($LASTEXITCODE) { Stop-OnError "flutter build web falló" }

# ---- Copy to /docs ----
Write-Host "`n[3/4] Copiando build/web -> docs (mirror)" -ForegroundColor Yellow
Remove-Item -Recurse -Force docs -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path docs | Out-Null
# /E copia todo; /MIR refleja (borra lo que ya no existe)
robocopy build\web docs /MIR | Out-Null

# ---- Commit & push ----
Write-Host "`n[4/4] git add/commit/push a $Branch" -ForegroundColor Yellow
git add docs
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "Deploy web ($stamp) -> /docs" | Out-Null
git push origin $Branch

if ($LASTEXITCODE) { Stop-OnError "git push falló" }

Write-Host "`n✅ Deploy OK. Esperá 1–2 minutos y abrí: $Url" -ForegroundColor Green
Start-Process $Url

