import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/kawaii_toast.dart';

import '../state/app_state.dart';
import '../services/ml_service.dart';

/// Nivel 4 — Predicción ML (online)
/// Muestra un recomendador que aprende en vivo (LR online + SGD)
/// tomando contexto simple y el label de cada intento.
class Level4MlPredictionScreen extends StatefulWidget {
  const Level4MlPredictionScreen({super.key});

  @override
  State<Level4MlPredictionScreen> createState() =>
      _Level4MlPredictionScreenState();
}

class _Level4MlPredictionScreenState extends State<Level4MlPredictionScreen> {
  static const ordenQuesos = <String>[
    'Mozzarella',
    'Cheddar',
    'Parmesano',
    'Gouda',
    'Brie',
    'Azul'
  ];

  // Features controlados desde la UI
  double racha = 2;
  double tiempoMs = 6000;
  int hora = 13;
  double stockProm = 10;

  // Salida del modelo
  double? probPredicha;
  String? textoSugerencia;
  String? quesoSugerido;

  @override
  void initState() {
    super.initState();
    // carga eventos previos y reconstruye el modelo
    MlService.instance.init();
  }

  Future<void> _predecir(AppState? app) async {
    final sugerido = MlService.instance.suggest(
      streak: racha.toInt(),
      avgMs: tiempoMs,
      hour: hora,
      stock: stockProm,
    );
    final p = MlService.instance.predictProba(
      streak: racha.toInt(),
      avgMs: tiempoMs,
      hour: hora,
      stock: stockProm,
      cheese: sugerido,
    );
    setState(() {
      quesoSugerido = sugerido;
      probPredicha = p;
      textoSugerencia =
          'Sugerencia: ofrecé $sugerido (p≈${(p * 100).toStringAsFixed(1)}%).';
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.mounted ? context.read<AppState?>() : null;
    final isMobile = MediaQuery.of(context).size.width < 700;

    final params = _ParametrosCard(
      racha: racha.toInt(),
      tiempoMs: tiempoMs,
      quesoIdx: 0,
      hora: hora,
      stockProm: stockProm,
      onRacha: (v) => setState(() => racha = v.toDouble()),
      onTiempo: (v) => setState(() => tiempoMs = v),
      onQueso: (_) {},
      onHora: (v) => setState(() => hora = v),
      onStock: (v) => setState(() => stockProm = v),
      onPredecir: () => _predecir(app),
    );

    final result = _ResultadoCard(
      probPredicha: probPredicha,
      sugerencia: textoSugerencia,
    );

    final aprender = (quesoSugerido == null)
        ? const SizedBox.shrink()
        : _AprenderCard(
            texto: '¿Cómo salió la última sugerencia ($quesoSugerido)?',
            onAprender: (ok) async {
              await MlService.instance.learn(
                streak: racha.toInt(),
                avgMs: tiempoMs,
                hour: hora,
                stock: stockProm,
                cheeseShown: quesoSugerido!,
                converted: ok ? 1 : 0,
                wastePenalty: !ok,
              );
              if (!mounted) return;
              if (ok) {
                KawaiiToast.success('🧀 Aprendido: conversión con $quesoSugerido');
              } else {
                KawaiiToast.warn('Aprendido: no convirtió con $quesoSugerido');
              }
              return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(ok
                        ? '✓ Aprendido: conversión con $quesoSugerido'
                        : '× Aprendido: no convirtió con $quesoSugerido')),
              );
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivel 4 — Predicción ML (online)'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    params,
                    const SizedBox(height: 12),
                    result,
                    const SizedBox(height: 12),
                    aprender
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: params),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          result,
                          const SizedBox(height: 12),
                          aprender
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/level5'),
            icon: const Icon(Icons.arrow_right_alt_rounded),
            label: const Text('Siguiente nivel'),
          ),
        ),
      ),
    );
  }
}

class _ParametrosCard extends StatelessWidget {
  final int racha;
  final double tiempoMs;
  final int quesoIdx; // mantenemos la API original (no se usa aquí)
  final int hora;
  final double stockProm;
  final ValueChanged<int> onRacha;
  final ValueChanged<double> onTiempo;
  final ValueChanged<int> onQueso;
  final ValueChanged<int> onHora;
  final ValueChanged<double> onStock;
  final VoidCallback onPredecir;

  static const _quesos = <String>[
    'Mozzarella',
    'Cheddar',
    'Parmesano',
    'Gouda',
    'Brie',
    'Azul'
  ];

  const _ParametrosCard({
    required this.racha,
    required this.tiempoMs,
    required this.quesoIdx,
    required this.hora,
    required this.stockProm,
    required this.onRacha,
    required this.onTiempo,
    required this.onQueso,
    required this.onHora,
    required this.onStock,
    required this.onPredecir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Racha de aciertos'),
            Slider(
              min: 0,
              max: 10,
              divisions: 10,
              value: racha.toDouble(),
              label: '$racha',
              onChanged: (v) => onRacha(v.round()),
            ),
            const SizedBox(height: 8),
            const Text('Tiempo promedio por pedido (ms)'),
            Slider(
              min: 500,
              max: 15000,
              divisions: 29,
              value: tiempoMs,
              label: tiempoMs.toStringAsFixed(0),
              onChanged: onTiempo,
            ),
            const SizedBox(height: 8),
            const Text('Hora del día (0–23)'),
            Slider(
              min: 0,
              max: 23,
              divisions: 23,
              value: hora.toDouble(),
              label: '$hora h',
              onChanged: (v) => onHora(v.toInt()),
            ),
            const SizedBox(height: 8),
            const Text('Stock promedio visible'),
            Slider(
              min: 0,
              max: 20,
              value: stockProm,
              label: stockProm.toStringAsFixed(1),
              onChanged: onStock,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onPredecir,
                icon: const Icon(Icons.insights),
                label: const Text('Predecir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final double? probPredicha;
  final String? sugerencia;

  const _ResultadoCard({
    required this.probPredicha,
    required this.sugerencia,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = probPredicha != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: hasResult
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultado de la predicción',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Probabilidad de conversión: ${(probPredicha! * 100).toStringAsFixed(1)} %',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sugerencia ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Cómo se calculó:',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Usamos un modelo de regresión logística online que aprende con tus jugadas '
                      '(racha, tiempo, queso, hora, stock). Se calibra en vivo con cada intento.',
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listo para predecir',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ajustá los parámetros y tocá “Predecir” para estimar la probabilidad '
                      'de acierto del próximo pedido.',
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AprenderCard extends StatelessWidget {
  final String texto;
  final void Function(bool ok) onAprender;
  const _AprenderCard({required this.texto, required this.onAprender});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texto,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => onAprender(true),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Convirtió'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => onAprender(false),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('No convirtió'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
