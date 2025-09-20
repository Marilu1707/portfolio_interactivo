import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class DiagnosticData {
  final Map<String, int> pedidosPorQueso;
  final Map<String, int> stockPorQueso;

  const DiagnosticData({
    this.pedidosPorQueso = const {},
    this.stockPorQueso = const {},
  });
}

class CheckResult {
  final String name;
  final String details;
  final bool ok;
  final bool warning;

  const CheckResult({
    required this.name,
    required this.details,
    required this.ok,
    this.warning = false,
  });
}

class AppDiagnostics {
  static const _assetsToCheck = <String>[
    'assets/img/raton_menu.png',
    'assets/img/raton_inventario.png',
    'assets/img/ab_mouse.png',
    'assets/icons/favicon.png',
    'assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf',
  ];

  static const _routesToCheck = <String>[
    '/', '/level1', '/level2', '/level3', '/level4', '/dashboard',
  ];

  static Future<List<CheckResult>> run({
    required BuildContext context,
    DiagnosticData data = const DiagnosticData(),
    Map<String, WidgetBuilder>? routes,
  }) async {
    final List<CheckResult> out = [];
    // Capture routes map before any async gaps to avoid using BuildContext afterwards
    final routeMap = routes ?? _tryObtainRoutesFromContext(context);

    // 1) Assets
    for (final path in _assetsToCheck) {
      final ok = await _canLoadAsset(path);
      out.add(CheckResult(
        name: 'Asset: $path',
        details: ok ? 'Cargó correctamente' : 'No se pudo cargar (404/pubspec)',
        ok: ok,
      ));
    }

    // 2) Rutas
    for (final r in _routesToCheck) {
      final ok = routeMap.containsKey(r);
      out.add(CheckResult(
        name: 'Ruta: $r',
        details: ok ? 'Definida en routes' : 'No encontrada en routes',
        ok: ok,
      ));
    }

    // 3) Mailto
    final mailUri = Uri(
      scheme: 'mailto',
      path: 'mlujanmassironi@gmail.com',
      query: 'subject=Contacto%20Portfolio&body=Hola%20Maril%C3%BA,',
    );
    bool mailOk = false;
    try { mailOk = await canLaunchUrl(mailUri); } catch (_) {}
    out.add(CheckResult(
      name: 'Email (mailto:)',
      details: mailOk
          ? 'El dispositivo reporta soporte para mailto'
          : 'El entorno no reporta soporte. En Web iOS puede requerir interacción directa.',
      ok: mailOk,
      warning: !mailOk,
    ));

    // 4) Datos de gráficos
    if (data.pedidosPorQueso.isNotEmpty) {
      final total = data.pedidosPorQueso.values.fold<int>(0, (a, b) => a + b);
      out.add(CheckResult(
        name: 'Datos de gráficos',
        details: total > 0 ? 'Total de pedidos: $total' : 'Pedidos en 0',
        ok: total > 0,
        warning: total == 0,
      ));
    } else {
      out.add(const CheckResult(
        name: 'Datos de gráficos',
        details: 'Sin mapa pedidosPorQueso (opcional)',
        ok: true,
        warning: true,
      ));
    }

    // 5) Inventario
    if (data.stockPorQueso.isNotEmpty) {
      final neg = data.stockPorQueso.entries.where((e) => e.value < 0).toList();
      out.add(CheckResult(
        name: 'Inventario',
        details: neg.isEmpty
            ? 'Stocks válidos (>=0)'
            : 'Negativos: ${neg.map((e) => '${e.key}:${e.value}').join(', ')}',
        ok: neg.isEmpty,
      ));
    } else {
      out.add(const CheckResult(
        name: 'Inventario',
        details: 'Sin mapa stockPorQueso (opcional)',
        ok: true,
        warning: true,
      ));
    }

    // 6) PWA (recordatorio)
    if (kIsWeb) {
      out.add(const CheckResult(
        name: 'PWA / SPA',
        details: 'El hosting debe redirigir todas las rutas a /index.html para la app de una sola página.',
        ok: true,
        warning: true,
      ));
    }

    return out;
  }

  static Future<void> showDialogResults(BuildContext context, { DiagnosticData data = const DiagnosticData() }) async {
    final nav = Navigator.of(context);
    final routes = _tryObtainRoutesFromContext(context);
    final results = await run(context: context, data: data, routes: routes);
    final oks = results.where((r) => r.ok && !r.warning).length;
    final warns = results.where((r) => r.warning).length;
    final fails = results.where((r) => !r.ok && !r.warning).length;

    if (!nav.mounted) return;
    await showDialog(
      context: nav.context,
      builder: (_) => AlertDialog(
        title: Text('Diagnóstico — OK:$oks  ⚠️:$warns  ❌:$fails'),
        content: SizedBox(
          width: 480,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(height: 8),
            itemBuilder: (_, i) {
              final r = results[i];
              final icon = r.ok
                  ? (r.warning ? Icons.warning_amber_rounded : Icons.check_circle_rounded)
                  : Icons.error_rounded;
              final color = r.ok
                  ? (r.warning ? Colors.amber[700] : Colors.green[600])
                  : Colors.red[600];
              return ListTile(
                dense: true,
                leading: Icon(icon, color: color),
                title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(r.details),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  static Future<bool> _canLoadAsset(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Map<String, WidgetBuilder> _tryObtainRoutesFromContext(BuildContext context) {
    final widget = context.findAncestorWidgetOfExactType<MaterialApp>();
    return widget?.routes ?? <String, WidgetBuilder>{};
  }
}
