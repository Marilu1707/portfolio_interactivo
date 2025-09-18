# Script de deploy a Vercel para Flutter Web (CLI)
# - Construye localmente el sitio estático en build/web
# - Publica con Vercel CLI en producción
# Requisitos:
#   - Flutter instalado y en PATH
#   - Node.js + Vercel CLI (npm i -g vercel)

param(
  [switch]$Preview,
  [string]$Renderer = "html"  # o "canvaskit"
)

function Stop-OnError($msg) {
  Write-Host "`nERROR: $msg" -ForegroundColor Red
  exit 1
}

# Checks
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Stop-OnError "Flutter no está en PATH." }
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) { Stop-OnError "Vercel CLI no está instalado. Ejecutá: npm i -g vercel" }

# vercel.json SPA fallback si falta
if (-not (Test-Path vercel.json)) {
  @'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
'@ | Out-File -Encoding utf8 vercel.json
  Write-Host "✔ Creado vercel.json (SPA rewrites)"
}

Write-Host "`n[1/3] flutter clean + pub get" -ForegroundColor Yellow
flutter clean; if ($LASTEXITCODE) { Stop-OnError "flutter clean falló" }
flutter pub get; if ($LASTEXITCODE) { Stop-OnError "flutter pub get falló" }

Write-Host "`n[2/3] flutter build web (--web-renderer $Renderer, base-href '/')" -ForegroundColor Yellow
flutter build web --release --web-renderer $Renderer --base-href "/"; if ($LASTEXITCODE) { Stop-OnError "flutter build web falló" }

if ($Preview) {
  Write-Host "`n[3/3] Publicando PREVIEW en Vercel..." -ForegroundColor Yellow
  vercel build/web; if ($LASTEXITCODE) { Stop-OnError "vercel preview falló" }
} else {
  Write-Host "`n[3/3] Publicando PRODUCCIÓN en Vercel..." -ForegroundColor Yellow
  vercel --prod build/web; if ($LASTEXITCODE) { Stop-OnError "vercel --prod falló" }
}

Write-Host "`n✅ Deploy OK en Vercel. Revisá la URL que imprimió la CLI." -ForegroundColor Green
