import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/game_popup.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

Future<void> descargarCV(BuildContext context) async {
  const path = 'assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf';
  try {
    final bytes = await rootBundle.load(path);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/CV_MARIA_LUJAN_MASSIRONI.pdf');
    await file.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
    await OpenFilex.open(file.path);
  } catch (e) {
    if (!context.mounted) return;
    GamePopup.show(context, 'No se pudo abrir el CV: $e',
        color: Colors.redAccent, icon: Icons.error_outline);
  }
}
