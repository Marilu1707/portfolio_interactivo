import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/game_popup.dart';

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

  // Features controlados desde la UI
  double racha = 2;
  double tiempoMs = 6000;
  int hora = 13;
  double stockProm = 10;

  // Salida del modelo
  double? probPredicha;
  String? textoSugerencia;
  String? quesoSugerido;
  Map<String, double> _lastContribs = const {};

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
      // Contribuciones explicativas simples (no afectan el modelo real)
      const betas = <String, double>{
        'bias': -0.2,
        'racha': 0.15,
        'tiempo': 0.02,
        'hora': -0.03,
        'stock': 0.25,
        'mozzarella': 0.02,
        'cheddar': 0.10,
        'parmesano': 0.08,
        'gouda': 0.05,
        'brie': -0.04,
        'azul': -0.06,
      };
      final cheeseKey = sugerido.toLowerCase();
      _lastContribs = <String, double>{
        'Sesgo (base)': betas['bias']!,
        'Racha': (racha.toInt()).toDouble() * betas['racha']!,
        'Tiempo de juego (ms)': tiempoMs * betas['tiempo']!,
        'Hora del día': hora.toDouble() * betas['hora']!,
        'Stock visible': stockProm * betas['stock']!,
        'Queso: $sugerido': betas[cheeseKey] ?? 0.0,
      };
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
              final ctx = context; // cache BuildContext for proper guard
              await MlService.instance.learn(
                streak: racha.toInt(),
                avgMs: tiempoMs,
                hour: hora,
                stock: stockProm,
                cheeseShown: quesoSugerido!,
                converted: ok ? 1 : 0,
                wastePenalty: !ok,
              );
              if (!ctx.mounted) return;
              if (ok) {
                GamePopup.show(ctx,
                    '🧀 Aprendido: conversión con $quesoSugerido',
                    color: Colors.green, icon: Icons.check_circle, success: true);
              } else {
                GamePopup.show(ctx,
                    'Aprendido: no convirtió con $quesoSugerido',
                    color: Colors.orange, icon: Icons.warning_amber_rounded, success: false);
              }
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivel 4 — Predicción ML (online)'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '¿Cómo funciona?',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHowItWorks(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ajustá los sliders y tocá “Predecir”. El modelo sugiere qué queso ofrecer ahora.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    params,
                    const SizedBox(height: 12),
                    result,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: (_lastContribs.isEmpty || probPredicha == null)
                            ? null
                            : () => _showReasons(context, _lastContribs, probPredicha ?? 0),
                        icon: const Icon(Icons.insights_outlined),
                        label: const Text('Motivos de esta predicción'),
                      ),
                    ),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: (_lastContribs.isEmpty || probPredicha == null)
                                  ? null
                                  : () => _showReasons(context, _lastContribs, probPredicha ?? 0),
                              icon: const Icon(Icons.insights_outlined),
                              label: const Text('Motivos de esta predicción'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          aprender
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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

  // Lista de quesos removida por no usarse aquí (evita warnings).

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

// Bullets helper
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

void _showHowItWorks(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('¿Qué hace este modelo?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'Predice la probabilidad de conversión ahora mismo y sugiere el queso con mayor probabilidad.',
              ),
              SizedBox(height: 12),
              Text('Cómo funciona:', style: TextStyle(fontWeight: FontWeight.w600)),
              _Bullet('Modelo: regresión logística online (aprende en tiempo real).'),
              _Bullet('Features: racha, tiempo de juego, queso actual, hora del día, stock visible.'),
              _Bullet('Salida: probabilidad entre 0–100% y recomendación del queso con p más alta.'),
              _Bullet('Actualización: cada vez que marcás “Convirtió/No convirtió”, el modelo se recalibra.'),
              SizedBox(height: 12),
              Text('Interpretación:', style: TextStyle(fontWeight: FontWeight.w600)),
              _Bullet('Si p≥50% no garantiza venta, solo indica mayor probabilidad que el azar.'),
              _Bullet('Úsalo para priorizar — no reemplaza criterio humano.'),
              SizedBox(height: 12),
              Text('Limitaciones:', style: TextStyle(fontWeight: FontWeight.w600)),
              _Bullet('Al inicio sabe poco: necesita feedback para mejorar.'),
              _Bullet('Sesgos si los datos de entrada son poco variados.'),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showReasons(BuildContext context, Map<String, double> contribs, double p) {
  final absSum = contribs.values.map((e) => e.abs()).fold<double>(0, (a, b) => a + b);
  final normalized = <String, double>{
    for (final e in contribs.entries) e.key: (absSum == 0 ? 0 : (e.value / absSum) * 100),
  };
  final items = normalized.entries.toList()
    ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (c) {
      final theme = Theme.of(c);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Motivos de esta predicción', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('p ≈ ${(p * 100).toStringAsFixed(1)} % — aportes relativos por variable (positivos ayudan, negativos restan).'),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: items.map((e) {
                      final sign = e.value >= 0 ? 1.0 : -1.0;
                      final width = e.value.abs().clamp(0, 100);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.key, style: theme.textTheme.bodyMedium),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        Container(height: 10, color: theme.colorScheme.surfaceContainerHighest),
                                        LayoutBuilder(
                                          builder: (ctx, cons) {
                                            final half = cons.maxWidth / 2;
                                            final barW = (width / 100.0) * half;
                                            return Stack(children: [
                                              Positioned(
                                                left: sign > 0 ? half : (half - barW),
                                                width: barW,
                                                height: 10,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: sign > 0
                                                        ? theme.colorScheme.primary.withValues(alpha: .75)
                                                        : theme.colorScheme.error.withValues(alpha: .75),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: half - 1,
                                                right: half - 1,
                                                height: 10,
                                                child: Container(width: 2, color: theme.colorScheme.outlineVariant),
                                              ),
                                            ]);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 56,
                              child: Text(
                                '${e.value >= 0 ? '+' : '-'}${e.value.abs().toStringAsFixed(1)}%',
                                textAlign: TextAlign.right,
                                style: theme.textTheme.labelMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.pop(c),
                icon: const Icon(Icons.check),
                label: const Text('Listo'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
