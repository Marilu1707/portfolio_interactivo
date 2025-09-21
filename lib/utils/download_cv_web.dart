import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/kawaii_toast.dart';

Future<void> descargarCV(BuildContext context) async {
  const cvUrl = 'CV_MASSIRONI_MARIA_LUJAN.pdf';
  final uri = Uri.parse(cvUrl);
  final launched = await launchUrl(uri);

  if (!context.mounted) return;

  if (!launched) {
    KawaiiToast.show(
      context,
      'No se pudo descargar el CV',
      color: Colors.redAccent,
      icon: Icons.error_outline,
      success: false,
    );
    return;
  }

  KawaiiToast.show(
    context,
    'Descargando CV...',
    color: Colors.brown,
    icon: Icons.download,
  );
}
