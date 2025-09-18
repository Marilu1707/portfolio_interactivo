#!/usr/bin/env bash
set -euo pipefail

# Build Flutter Web (HTML renderer) with base-href "/"
# Requires Flutter with web enabled. On Windows, enable Developer Mode for symlink support.

echo "==> flutter clean"
flutter clean

echo "==> flutter pub get"
flutter pub get

echo "==> flutter build web --release --base-href \"/\""
flutter build web --release --base-href "/"

# Remove service worker to avoid stale cache on first deploy
if [ -f build/web/flutter_service_worker.js ]; then
  echo "==> Removing flutter_service_worker.js to avoid stale cache"
  rm -f build/web/flutter_service_worker.js
fi

echo "==> Done. Output in build/web"

# Optional (older Flutter versions): canvaskit renderer
# flutter build web --release --base-href "/" # --web-renderer canvaskit (deprecated in recent Flutter)

