Param(
  [string]$Renderer = "canvaskit",      # canvaskit | html
  [switch]$Open,                         # abre la URL al finalizar
  [switch]$SkipBuild                     # salta build si ya compilaste
)

# Deploy de Flutter Web a Netlify usando netlify-cli
# Requisitos:
#  - Flutter instalado en PATH
#  - Node + npm
#  - netlify-cli (npm i -g netlify-cli)
#  - Haber vinculado el sitio una vez: `netlify init` o `netlify link`

function Die($msg) { Write-Error $msg; exit 1 }
function Exec([string]$cmd) { Write-Host "> $cmd" -ForegroundColor Yellow; iex $cmd; if ($LASTEXITCODE -ne 0) { Die "Falló: $cmd" } }

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Die "Flutter no está en PATH." }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Die "Node.js no está en PATH (requerido por netlify-cli)." }
if (-not (Get-Command netlify -ErrorAction SilentlyContinue)) { Die "Instalá netlify-cli: npm i -g netlify-cli" }

if (-not $SkipBuild) {
  Exec "flutter clean"
  Exec "flutter pub get"
  Exec "flutter build web --release --web-renderer $Renderer --base-href '/'"
}

# Fallback SPA
Copy-Item -Path build\web\index.html -Destination build\web\404.html -Force

# Deploy en producción
$deployCmd = "netlify deploy --prod --dir=build/web"
if ($Open) { $deployCmd += " --open" }
Exec $deployCmd

Write-Host "Listo: sitio desplegado en Netlify (deploy prod)." -ForegroundColor Green

