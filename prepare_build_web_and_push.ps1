# ============================
# Preparar build/web y subir a GitHub (para Vercel estático)
# Pasos: build Flutter Web -> permitir versionar build/web -> asegurar vercel.json -> commit & push
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\prepare_build_web_and_push.ps1 -RepoUrl "https://github.com/USER/REPO.git" -Branch main [-Renderer html] [-NoPush]
# ============================

param(
  [ValidateSet("canvaskit","html")]
  [string]$Renderer = "canvaskit",
  [string]$BaseHref = "/",
  [string]$Branch = "main",
  [string]$RepoUrl,
  [string]$CommitMessage = "Incluye build/web para Vercel + SPA rewrites",
  [switch]$NoPush
)

function Stop-OnError($msg) {
  Write-Host "`nERROR: $msg" -ForegroundColor Red
  exit 1
}

function Ensure-LineInFile([string]$Path,[string]$Line) {
  if (-not (Test-Path $Path)) {
    New-Item -ItemType File -Path $Path -Force | Out-Null
  }
  $content = Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue
  if ($null -eq $content -or -not ($content -split "`r?`n" | ForEach-Object { $_.Trim() }) -contains $Line) {
    Add-Content -Path $Path -Value $Line
  }
}

# Checks
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Stop-OnError "Flutter no está en PATH." }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Stop-OnError "Git no está en PATH." }

# 1) Build Flutter Web
Write-Host "[1/4] flutter clean + pub get + build web (--web-renderer $Renderer, base-href '$BaseHref')" -ForegroundColor Yellow
flutter clean; if ($LASTEXITCODE) { Stop-OnError "flutter clean falló" }
flutter pub get; if ($LASTEXITCODE) { Stop-OnError "flutter pub get falló" }
flutter build web --release --web-renderer $Renderer --base-href "$BaseHref"; if ($LASTEXITCODE) { Stop-OnError "flutter build web falló" }

if (-not (Test-Path "build/web/index.html")) { Stop-OnError "No se encontró build/web/index.html. El build no generó salida." }

# 2) Permitir versionar build/web (excepciones en .gitignore)
Write-Host "[2/4] Ajustando .gitignore para permitir /build/web" -ForegroundColor Yellow
Ensure-LineInFile -Path ".gitignore" -Line "# Permitir publicar el build web en el repo (para Vercel)"
Ensure-LineInFile -Path ".gitignore" -Line "!/build/web/"
Ensure-LineInFile -Path ".gitignore" -Line "!/build/web/**"

# 3) vercel.json (SPA fallback)
Write-Host "[3/4] Asegurando vercel.json (SPA rewrites)" -ForegroundColor Yellow
if (-not (Test-Path "vercel.json")) {
  @'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
'@ | Out-File -Encoding utf8 "vercel.json"
  Write-Host "✔ Creado vercel.json"
}

# 4) Git: init (si falta), commit y push
Write-Host "[4/4] Git commit & push" -ForegroundColor Yellow
if (-not (Test-Path .git)) {
  git init; if ($LASTEXITCODE) { Stop-OnError "git init falló" }
}

git add build/web vercel.json .gitignore | Out-Null

$staged = git diff --cached --name-only
if (-not $staged) {
  Write-Host "No hay cambios para commitear (nada nuevo en build/web, vercel.json o .gitignore)." -ForegroundColor DarkYellow
} else {
  git commit -m $CommitMessage; if ($LASTEXITCODE) { Stop-OnError "git commit falló" }
}

git branch -M $Branch; if ($LASTEXITCODE) { Stop-OnError "git branch -M $Branch falló" }

if ($RepoUrl) {
  git remote remove origin 2>$null | Out-Null
  git remote add origin $RepoUrl; if ($LASTEXITCODE) { Stop-OnError "git remote add origin falló" }
}

if (-not $NoPush) {
  git push -u origin $Branch; if ($LASTEXITCODE) { Stop-OnError "git push falló (verificá autenticación y permisos)" }
  Write-Host "✅ Listo: cambios subidos a '$Branch'." -ForegroundColor Green
} else {
  Write-Host "⚠️ NoPush activo: omitido 'git push'." -ForegroundColor DarkYellow
}

Write-Host "Hecho. Vercel puede apuntar a Output Directory: build/web con Build Command vacío." -ForegroundColor Green

