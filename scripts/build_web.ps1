Param(
  [switch]$Preview,
  [ValidateSet('html','auto','canvaskit')]
  [string]$Renderer = 'html'
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Yellow }

# Note: Recent Flutter versions removed --web-renderer flag. We'll omit it by default.
# If using an older Flutter, you may pass -Renderer canvaskit and uncomment the flag below.

Write-Step 'flutter clean'
flutter clean

Write-Step 'flutter pub get'
flutter pub get

$args = @('build','web','--release','--base-href','/')
if ($Preview) { $args = @('build','web','--profile','--base-href','/') }

# Uncomment for older Flutter versions that still support --web-renderer
switch ($Renderer) {
  'html'      { # $args += @('--web-renderer','html')
              }
  'auto'      { # $args += @('--web-renderer','auto')
              }
  'canvaskit' { # $args += @('--web-renderer','canvaskit')
              }
}

Write-Step ("flutter " + ($args -join ' '))
flutter @args

# Remove service worker to avoid stale cache during first deploy
if (Test-Path 'build/web/flutter_service_worker.js') {
  Write-Step 'Removing flutter_service_worker.js to avoid stale cache'
  Remove-Item 'build/web/flutter_service_worker.js' -Force
}

Write-Info 'Done. Output in build/web'

Write-Host "Note: On Windows, enable Developer Mode (Settings > Privacy & security > For developers) for symlink support required by Flutter plugins." -ForegroundColor DarkGray
