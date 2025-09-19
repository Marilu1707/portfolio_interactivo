import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/kawaii_toast.dart';
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
    KawaiiToast.error('No se pudo abrir el CV: $e');
  }
}
