Param(
  [string]$RepoName = "marilu_portfolio",
  [string]$Renderer = "canvaskit",  # canvaskit | html
  [string]$Branch = "main",
  [string]$CommitMessage = "Publicacion web: build en /docs (GitHub Pages)",
  [switch]$Push
)

function Exec([string]$cmd) {
  Write-Host "> $cmd" -ForegroundColor Yellow
  iex $cmd
  if ($LASTEXITCODE -ne 0) { throw "Falló: $cmd" }
}

try {
  if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter no está instalado o no está en PATH. Instalalo desde https://flutter.dev/."
  }

  # 1) Build web con base-href correcta
  $baseHref = "/$RepoName/"
  Exec "flutter clean"
  Exec "flutter pub get"
  Exec "flutter build web --release --web-renderer $Renderer --base-href $baseHref"

  # 2) Copiar a /docs
  $src = Join-Path (Get-Location) "build/web"
  $dst = Join-Path (Get-Location) "docs"
  if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
  New-Item -ItemType Directory -Path $dst | Out-Null

  if (Get-Command robocopy -ErrorAction SilentlyContinue) {
    # /MIR para espejar (cuidado: borra archivos previos en destino)
    Exec "robocopy `"$src`" `"$dst`" /MIR"
  } else {
    Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force
  }

  # Evita que GitHub Pages aplique Jekyll y rompa paths de assets
  New-Item -ItemType File -Path (Join-Path $dst ".nojekyll") -Force | Out-Null
  # Fallback SPA: 404.html = index.html
  Copy-Item -Path (Join-Path $dst "index.html") -Destination (Join-Path $dst "404.html") -Force

  # 3) Commit & (opcional) push
  if (Get-Command git -ErrorAction SilentlyContinue) {
    git add docs | Out-Null
    $hasChanges = (git status --porcelain) -match "^\s*M\s|^\?\?\s|^A\s|^D\s"
    if ($hasChanges) {
      git commit -m $CommitMessage | Out-Null
    } else {
      Write-Host "No hay cambios en /docs para commitear." -ForegroundColor DarkGray
    }

    if ($Push) {
      Exec "git push -u origin $Branch"
    }
  } else {
    Write-Warning "Git no está instalado o no está en PATH. Saltando commit/push."
  }

  Write-Host "Listo. Carpeta /docs creada y lista para GitHub Pages." -ForegroundColor Green
  Write-Host "Recorda activar Pages: Settings -> Pages -> Source: main /docs" -ForegroundColor DarkGray
}
catch {
  Write-Error $_
  exit 1
}
