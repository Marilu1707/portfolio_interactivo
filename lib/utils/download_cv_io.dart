import 'package:url_launcher/url_launcher.dart';

/// En móviles/desktop abre el mismo link externo con url_launcher.
/// No usa archivos locales ni temporales.
Future<bool> descargarCV() async {
  const external = 'https://drive.google.com/uc?export=download&id=1Br8mApkGhV-jDszyj39468rD9ye3G9Qy';
  final uri = Uri.parse(external);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
