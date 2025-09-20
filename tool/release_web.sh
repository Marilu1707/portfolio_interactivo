#!/usr/bin/env bash
set -euo pipefail

# One-shot release script: analyze, build web, and sanity-check output.
# Usage:
#   tool/release_web.sh [--renderer canvaskit|auto]

RENDERER="canvaskit"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --renderer)
      RENDERER="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

echo "[1/4] flutter --version (informative)"
flutter --version || true

echo "[2/4] flutter analyze"
flutter pub get
flutter analyze || { echo "Analyzer found issues. Fix before releasing."; exit 1; }

echo "[3/4] flutter build web --release --web-renderer $RENDERER --pwa-strategy offline-first"
flutter build web --release --web-renderer "$RENDERER" --pwa-strategy offline-first

echo "[4/4] Sanity-check build artifacts"
[[ -f build/web/index.html ]] || { echo "Missing index.html in build/web"; exit 1; }
[[ -f build/web/flutter.js ]] || { echo "Missing flutter.js in build/web"; exit 1; }

echo "Done. Output in build/web. Publicá la carpeta en tu hosting preferido."

