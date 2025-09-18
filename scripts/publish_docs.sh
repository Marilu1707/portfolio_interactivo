#!/usr/bin/env bash
set -euo pipefail

# Publish Flutter Web build to /docs for GitHub Pages (branch main /docs)
# Defaults: repo name marilu_portfolio, renderer canvaskit, branch main.

REPO_NAME="marilu_portfolio"
RENDERER="canvaskit"   # or html
BRANCH="main"
COMMIT_MSG="Publicacion web: build en /docs (GitHub Pages)"
DO_PUSH=false

usage() {
  echo "Usage: $0 [-n REPO_NAME] [-r RENDERER] [-b BRANCH] [-m MESSAGE] [-p]" >&2
  echo "  -n  Repo name (for --base-href), default: $REPO_NAME" >&2
  echo "  -r  Renderer (canvaskit|html), default: $RENDERER" >&2
  echo "  -b  Git branch, default: $BRANCH" >&2
  echo "  -m  Commit message" >&2
  echo "  -p  Push after committing" >&2
}

while getopts ":n:r:b:m:ph" opt; do
  case $opt in
    n) REPO_NAME="$OPTARG" ;;
    r) RENDERER="$OPTARG" ;;
    b) BRANCH="$OPTARG" ;;
    m) COMMIT_MSG="$OPTARG" ;;
    p) DO_PUSH=true ;;
    h) usage; exit 0 ;;
    :) echo "Option -$OPTARG requires an argument" >&2; usage; exit 1 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter no está instalado o no está en PATH" >&2
  exit 1
fi

BASE_HREF="/${REPO_NAME}/"
echo "> flutter clean"
flutter clean
echo "> flutter pub get"
flutter pub get
echo "> flutter build web --release --web-renderer ${RENDERER} --base-href ${BASE_HREF}"
flutter build web --release --web-renderer "${RENDERER}" --base-href "${BASE_HREF}"

SRC="build/web"
DST="docs"
echo "> Preparando carpeta ${DST}"
rm -rf "${DST}"
mkdir -p "${DST}"
cp -R ${SRC}/* "${DST}/"

# Evita procesamiento Jekyll y agrega 404.html = index.html (SPA)
touch "${DST}/.nojekyll"
cp -f "${DST}/index.html" "${DST}/404.html"

if command -v git >/dev/null 2>&1; then
  echo "> git add docs"
  git add docs
  if ! git diff --cached --quiet; then
    echo "> git commit"
    git commit -m "${COMMIT_MSG}"
  else
    echo "No hay cambios en /docs para commitear"
  fi
  if [ "${DO_PUSH}" = true ]; then
    echo "> git push origin ${BRANCH}"
    git push origin "${BRANCH}"
  fi
else
  echo "Git no está instalado; saltando commit/push" >&2
fi

echo "Listo. /docs listo para GitHub Pages. Activá Pages: Settings -> Pages -> main /docs"

