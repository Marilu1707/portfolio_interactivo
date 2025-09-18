Param(
  [string]$Remote = "https://github.com/Marilu1707/marilu_portfolio.git",
  [string]$Branch = "main",
  [string]$Message = "Proyecto portfolio completo - niveles, home, AB test, assets"
)

function ExecGit {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
  Write-Host "git $Args" -ForegroundColor Yellow
  & git @Args
  if ($LASTEXITCODE -ne 0) { throw "Falló: git $Args" }
}

try {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git no está instalado o no está en PATH. Descargalo de https://git-scm.com/."
  }

  if (-not (Test-Path 'pubspec.yaml')) {
    Write-Warning "No se encontró pubspec.yaml. Ejecutá este script desde la carpeta raíz del proyecto."
  }

  if (-not (Test-Path '.git')) { ExecGit init }

  # Asegura rama principal
  ExecGit branch -M $Branch

  # Configura remote origin
  $hasOrigin = $false
  try { & git remote get-url origin *> $null; if ($LASTEXITCODE -eq 0) { $hasOrigin = $true } } catch {}
  if ($hasOrigin) { ExecGit remote set-url origin $Remote } else { ExecGit remote add origin $Remote }

  # Stage y commit si hay cambios
  & git add .
  & git diff --cached --quiet
  $needsCommit = $LASTEXITCODE -ne 0
  if ($needsCommit) {
    ExecGit commit -m $Message
  } else {
    Write-Host "No hay cambios para commitear." -ForegroundColor DarkGray
  }

  # Push inicial
  & git push -u origin $Branch
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "Push falló. Intento sincronizar con el remoto (pull con historias no relacionadas)."
    & git pull origin $Branch --allow-unrelated-histories --no-edit
    # Reintenta push
    ExecGit push -u origin $Branch
  }

  Write-Host "✔ Listo: push realizado a $Remote ($Branch)." -ForegroundColor Green
  Write-Host "Si GitHub pide credenciales, usá tu usuario y un token personal (PAT)." -ForegroundColor DarkGray
}
catch {
  Write-Error $_
  exit 1
}

