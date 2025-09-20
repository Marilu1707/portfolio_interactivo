// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../utils/game_popup.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> descargarCV(BuildContext context) async {
  const path = 'assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf';
  final a = html.AnchorElement(href: path)
    ..setAttribute('download', 'CV_MARIA_LUJAN_MASSIRONI.pdf')
    ..style.display = 'none';
  html.document.body?.append(a);
  a.click();
  a.remove();
  if (!context.mounted) return;
  GamePopup.show(context, 'Descargando CV...',
      color: Colors.brown, icon: Icons.download);
}
