import 'package:flutter/material.dart';

Future<void> descargarCV(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Descarga no soportada en esta plataforma.')),
  );
}

