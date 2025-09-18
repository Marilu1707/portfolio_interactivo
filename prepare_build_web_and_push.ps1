# ============================
# Prepare build/web and push to GitHub (static for Vercel)
# Steps: build Flutter Web -> allow versioning build/web -> ensure vercel.json -> commit and push
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\prepare_build_web_and_push.ps1 -RepoUrl "https://github.com/USER/REPO.git" -Branch main [-Renderer html] [-NoPush]
# ============================

param(
  [ValidateSet("canvaskit","html")]
  [string]$Renderer = "canvaskit",
  [string]$BaseHref = "/",
  [string]$Branch = "main",
  [string]$RepoUrl,
  [string]$CommitMessage = "Include build/web for Vercel + SPA rewrites",
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
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Stop-OnError "Flutter is not in PATH." }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Stop-OnError "Git is not in PATH." }

# 1) Build Flutter Web
Write-Host "[1/4] flutter clean + pub get + build web (--web-renderer $Renderer, base-href '$BaseHref')" -ForegroundColor Yellow
flutter clean; if ($LASTEXITCODE) { Stop-OnError "flutter clean failed" }
flutter pub get; if ($LASTEXITCODE) { Stop-OnError "flutter pub get failed" }
flutter build web --release --web-renderer $Renderer --base-href "$BaseHref"; if ($LASTEXITCODE) { Stop-OnError "flutter build web failed" }

if (-not (Test-Path "build/web/index.html")) { Stop-OnError "Missing build/web/index.html. Build produced no output." }

# 2) Allow versioning build/web (exceptions in .gitignore)
Write-Host "[2/4] Updating .gitignore to allow /build/web" -ForegroundColor Yellow
Ensure-LineInFile -Path ".gitignore" -Line "# Allow publishing build web to the repo (for Vercel)"
Ensure-LineInFile -Path ".gitignore" -Line "!/build/web/"
Ensure-LineInFile -Path ".gitignore" -Line "!/build/web/**"

# 3) vercel.json (SPA fallback)
Write-Host "[3/4] Ensuring vercel.json (SPA rewrites)" -ForegroundColor Yellow
if (-not (Test-Path "vercel.json")) {
  @'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
'@ | Out-File -Encoding utf8 "vercel.json"
  Write-Host "Created vercel.json"
}

# 4) Git: init if missing, commit and push
Write-Host "[4/4] Git commit and push" -ForegroundColor Yellow
if (-not (Test-Path .git)) {
  git init; if ($LASTEXITCODE) { Stop-OnError "git init failed" }
}

git add build/web vercel.json .gitignore | Out-Null

$staged = git diff --cached --name-only
if (-not $staged) {
  Write-Host "No changes to commit (no updates in build/web, vercel.json or .gitignore)." -ForegroundColor DarkYellow
} else {
  git commit -m $CommitMessage; if ($LASTEXITCODE) { Stop-OnError "git commit failed" }
}

git branch -M $Branch; if ($LASTEXITCODE) { Stop-OnError "git branch -M $Branch failed" }

if ($RepoUrl) {
  git remote remove origin 2>$null | Out-Null
  git remote add origin $RepoUrl; if ($LASTEXITCODE) { Stop-OnError "git remote add origin failed" }
}

if (-not $NoPush) {
  git push -u origin $Branch; if ($LASTEXITCODE) { Stop-OnError "git push failed (check authentication and permissions)" }
  Write-Host "Done: changes pushed to '$Branch'." -ForegroundColor Green
} else {
  Write-Host "NoPush flag active: skipped 'git push'." -ForegroundColor DarkYellow
}

Write-Host "Ready. In Vercel set Output Directory: build/web and leave Build Command empty." -ForegroundColor Green

