#!/usr/bin/env bash
set -euo pipefail

# Deploy de Flutter Web a Netlify usando netlify-cli
# Requisitos:
#  - Flutter en PATH
#  - Node + npm
#  - netlify-cli (npm i -g netlify-cli)
#  - Haber vinculado el sitio una vez: `netlify init` o `netlify link`

RENDERER=${RENDERER:-canvaskit}   # canvaskit | html
OPEN=${OPEN:-false}
SKIP_BUILD=${SKIP_BUILD:-false}

die() { echo "ERROR: $*" >&2; exit 1; }
run() { echo "> $*"; eval "$*"; }

command -v flutter >/dev/null 2>&1 || die "Flutter no está en PATH"
command -v node >/dev/null 2>&1 || die "Node no está en PATH (requerido por netlify-cli)"
command -v netlify >/dev/null 2>&1 || die "Instalá netlify-cli: npm i -g netlify-cli"

if [ "$SKIP_BUILD" != "true" ]; then
  run flutter clean
  run flutter pub get
  run flutter build web --release --web-renderer "$RENDERER" --base-href "/"
fi

# Fallback SPA
cp -f build/web/index.html build/web/404.html || true

CMD="netlify deploy --prod --dir=build/web"
if [ "$OPEN" = "true" ]; then
  CMD+=" --open"
fi
run "$CMD"

echo "Listo: sitio desplegado en Netlify (deploy prod)."

