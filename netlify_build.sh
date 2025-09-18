#!/usr/bin/env bash
set -euo pipefail

echo "==> Install Flutter (${FLUTTER_CHANNEL:-stable})"
FLUTTER_DIR="$HOME/flutter"
git clone --depth 1 -b "${FLUTTER_CHANNEL:-stable}" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --version

echo "==> Enable web"
flutter config --enable-web

echo "==> Pub get"
flutter pub get

echo "==> Build web (base-href=/, canvaskit)"
flutter build web --release --web-renderer canvaskit --base-href "/"

echo "==> Ensure SPA fallbacks"
cp -f build/web/index.html build/web/404.html || true

echo "==> Done"

