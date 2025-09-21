// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Abre el CV en Google Drive en una pestaña nueva.
/// Sin fallbacks locales ni HEAD checks.
Future<bool> descargarCV() async {
  const external = 'https://drive.google.com/uc?export=download&id=1Br8mApkGhV-jDszyj39468rD9ye3G9Qy';
  try {
    html.window.open(external, '_blank');
    return true;
  } catch (_) {
    return false;
  }
}
