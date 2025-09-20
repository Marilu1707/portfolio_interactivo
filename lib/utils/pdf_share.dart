import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Genera un PDF simple y lo comparte/descarga con el plugin `printing`.
/// Incluye fuentes embebidas para evitar â€œPDF en blancoâ€ en mobile.
Future<void> shareSampleKawaiiPdf(BuildContext context) async {
  final bytes = await _generateSamplePdf();
  await Printing.sharePdf(bytes: bytes, filename: 'juego_kawaii.pdf');
}

Future<Uint8List> _generateSamplePdf() async {
  final doc = pw.Document();

  // Fuentes embebidas (evita PDF en blanco en ciertos viewers mobiles)
  final fontRegular = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Nido Mozzarella â€” Nido Muzzarella',
                style: pw.TextStyle(font: fontBold, fontSize: 22)),
            pw.SizedBox(height: 8),
            pw.Text(
              'GestionÃ¡ pedidos, stock y conversiÃ³n. Cada nivel enseÃ±a un concepto de negocios digitales.',
              style: pw.TextStyle(font: fontRegular, fontSize: 12),
            ),
            pw.SizedBox(height: 16),
            pw.Bullet(text: 'Nivel 1: Pedidos y desperdicio', style: pw.TextStyle(font: fontRegular)),
            pw.Bullet(text: 'Nivel 2: MÃ©tricas (puntaje, racha)', style: pw.TextStyle(font: fontRegular)),
            pw.Bullet(text: 'Nivel 3: Inventario y vencimientos', style: pw.TextStyle(font: fontRegular)),
            pw.Bullet(text: 'Nivel 4: PredicciÃ³n (regresiÃ³n logÃ­stica)', style: pw.TextStyle(font: fontRegular)),
            pw.Bullet(text: 'Nivel 5: A/B Test (prueba Z)', style: pw.TextStyle(font: fontRegular)),
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
                color: PdfColor.fromInt(0xFFFCE9A8),
              ),
              child: pw.Text(
                'Tip: en mobile usÃ¡ â€œCompartirâ€ y abrÃ­ con Adobe/Xodo si tu visor nativo no muestra el PDF.',
                style: pw.TextStyle(font: fontRegular),
              ),
            ),
          ],
        );
      },
    ),
  );

  return doc.save();
}
