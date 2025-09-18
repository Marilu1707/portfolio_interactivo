#!/usr/bin/env bash
set -euo pipefail

# Script de deploy a Vercel para Flutter Web (CLI)
# - Construye localmente el sitio estático en build/web
# - Publica con Vercel CLI en producción
# Requisitos:
#   - Flutter instalado y en PATH
#   - Node.js + Vercel CLI (npm i -g vercel)

RENDERER="${1:-canvaskit}"  # o "html"

# Checks
command -v flutter >/dev/null 2>&1 || { echo "ERROR: Flutter no está en PATH"; exit 1; }
command -v vercel  >/dev/null 2>&1 || { echo "ERROR: Vercel CLI no está en PATH (npm i -g vercel)"; exit 1; }

# vercel.json SPA fallback si falta
if [ ! -f "vercel.json" ]; then
  cat > vercel.json <<'JSON'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
JSON
  echo "✔ Creado vercel.json (SPA rewrites)"
fi

echo "[1/3] flutter clean + pub get"
flutter clean
flutter pub get

echo "[2/3] flutter build web (--web-renderer ${RENDERER}, base-href '/')"
flutter build web --release --web-renderer "${RENDERER}" --base-href "/"

echo "[3/3] vercel --prod build/web"
vercel --prod build/web

echo "✅ Deploy OK en Vercel. Revisá la URL que imprimió la CLI."
