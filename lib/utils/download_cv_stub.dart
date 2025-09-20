import 'package:flutter/material.dart';
import '../utils/game_popup.dart';

Future<void> descargarCV(BuildContext context) async {
  GamePopup.show(context, 'Descarga no soportada en esta plataforma.',
      color: Colors.orange, icon: Icons.warning_amber_rounded);
}
