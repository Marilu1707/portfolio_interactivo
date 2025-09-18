#!/usr/bin/env bash
set -e

# ============================
# Deploy Flutter Web to GitHub Pages (/docs)
# Author: Marilu
# ============================

# ---- Config ----
REPO_NAME="marilu_portfolio"   # debe coincidir con el nombre del repo
BRANCH="main"                  # rama para publicar
RENDERER="canvaskit"          # o "html"
URL="https://marilu1707.github.io/${REPO_NAME}/"

# ---- Checks ----
command -v flutter >/dev/null 2>&1 || { echo "ERROR: Flutter no está en PATH"; exit 1; }
[ -d .git ] || { echo "ERROR: acá no hay repo git (.git). Corré 'git init' primero."; exit 1; }

# ---- Build ----
echo "[1/4] flutter clean + pub get"
flutter clean
flutter pub get

echo "[2/4] flutter build web (base-href=/$REPO_NAME/)"
flutter build web --release --web-renderer "$RENDERER" --base-href "/$REPO_NAME/"

# ---- Copy to /docs ----
echo "[3/4] Copiando build/web -> docs (sync)"
rm -rf docs
mkdir -p docs
# si tenés rsync, es más rápido:
if command -v rsync >/dev/null 2>&1; then
  rsync -av --delete build/web/ docs/
else
  cp -r build/web/* docs/
fi

# ---- Commit & push ----
echo "[4/4] git add/commit/push a $BRANCH"
git add docs
STAMP=$(date +"%Y-%m-%d %H:%M")
git commit -m "Deploy web ($STAMP) -> /docs" || true
git push origin "$BRANCH"

echo "✅ Deploy OK. Esperá 1–2 minutos y abrí: $URL"
# macOS: open; Linux (gnome): xdg-open
( command -v open >/dev/null 2>&1 && open "$URL" ) || ( command -v xdg-open >/dev/null 2>&1 && xdg-open "$URL" ) || true

