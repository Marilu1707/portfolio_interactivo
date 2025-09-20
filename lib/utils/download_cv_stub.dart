import 'package:flutter/material.dart';
import '../utils/kawaii_toast.dart';

Future<void> descargarCV(BuildContext context) async {
  KawaiiToast.show(
    context,
    'Descarga no soportada en esta plataforma.',
    color: Colors.orange,
    icon: Icons.warning_amber_rounded,
    success: false,
  );
}
