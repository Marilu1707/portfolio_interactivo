# deploy_vercel.ps1
param(
  [string]$VercelToken = "n6K5kna6Yfwi03RtEW9xMZWu"
)

Write-Host "Verificando Node/npm..." -ForegroundColor Cyan
node -v; npm -v

Write-Host "Instalando Vercel CLI si hace falta..." -ForegroundColor Cyan
npm i -g vercel | Out-Null

Write-Host "Build Flutter Web..." -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build web --release

$env:VERCEL_TOKEN = $VercelToken

Write-Host "Configurando proyecto en Vercel..." -ForegroundColor Cyan
vercel pull --yes --environment=production --token $env:VERCEL_TOKEN

Write-Host "Deployando build/web a producción..." -ForegroundColor Cyan
vercel deploy build/web --prod --yes --token $env:VERCEL_TOKEN
