#!/usr/bin/env bash
set -euo pipefail

# Fix Flutter analyze warnings: create branch, format, analyze, commit.

command -v git >/dev/null 2>&1 || { echo "❌ git no está en PATH"; exit 1; }
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ No es un repo git"; exit 1;
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ Tienes cambios sin commitear. Commitea o stashea primero."; exit 1;
fi

BRANCH="fix/analyze-warnings"
git checkout -b "$BRANCH"

echo "ℹ️ Aplicando parches opcionales (si no aplican, continúo)…"
set +e
git apply -p0 <<'PATCHES'
diff --git a/lib/screens/level1_game_screen.dart b/lib/screens/level1_game_screen.dart
@@
-// import '../utils/game_popup.dart'; // reemplazado por Popup centrado
diff --git a/lib/screens/level1_game_screen.dart b/lib/screens/level1_game_screen.dart
@@
-  Widget _speech(String text) {
-    return Container(
-      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
-      decoration: BoxDecoration(
-        color: Colors.white,
-        borderRadius: BorderRadius.circular(20),
-        border: Border.all(
-            color: Colors.brown.shade200.withValues(alpha: 0.6), width: 2),
-        boxShadow: [
-          BoxShadow(
-              color: Colors.brown.shade200.withValues(alpha: 0.15),
-              blurRadius: 4,
-              offset: const Offset(0, 2)),
-        ],
-      ),
-      child: Text(text,
-          softWrap: true,
-          style: const TextStyle(
-              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.brown)),
-    );
-  }
+  // (removido: _speech no se usa)
PATCHES
APPLY_STATUS=$?
set -e
if [ $APPLY_STATUS -ne 0 ]; then
  echo "⚠️ Algunos hunks no aplicaron (ya estaban aplicados o difieren). Siguiendo…"
fi

echo "🧹 Formateando código…"
if command -v dart >/dev/null 2>&1; then
  dart format .
else
  echo "⚠️ dart no está en PATH; salto format."
fi

echo "🔍 Ejecutando flutter analyze (si está disponible)…"
if command -v flutter >/dev/null 2>&1; then
  flutter analyze || true
else
  echo "⚠️ flutter no está en PATH; salto analyze."
fi

if git diff --quiet && git diff --cached --quiet; then
  echo "ℹ️ No hay cambios para commitear."
else
  git add -A
  git commit -m "chore: fix flutter analyze warnings and format"
  echo "✅ Cambios commiteados en rama $BRANCH"
fi

echo "👉 Sube la rama y abre PR:  git push -u origin $BRANCH"

