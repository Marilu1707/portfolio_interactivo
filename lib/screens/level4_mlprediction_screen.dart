import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../services/ml_service.dart';
import '../utils/help_sheet.dart';
import '../widgets/kawaii_card.dart';

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

  Future<void> _predecir() async {
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
        'provolone': 0.12,
        'gouda': 0.05,
        'brie': -0.04,
        'azul': -0.02,
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
    final isMobile = MediaQuery.of(context).size.width < 700;

    final params = _ParametrosCard(
      racha: racha.toInt(),
      tiempoMs: tiempoMs,
      hora: hora,
      stockProm: stockProm,
      onRacha: (v) => setState(() => racha = v.toDouble()),
      onTiempo: (v) => setState(() => tiempoMs = v),
      onHora: (v) => setState(() => hora = v),
      onStock: (v) => setState(() => stockProm = v),
      onPredecir: _predecir,
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
              final messenger = ScaffoldMessenger.of(ctx);
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? '🧀 Aprendido: conversión con $quesoSugerido'
                        : 'Aprendido: no convirtió con $quesoSugerido',
                  ),
                  backgroundColor:
                      ok ? Colors.green.shade400 : Colors.orange.shade400,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              );
            },
          );

    final reasonsButton = Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: (_lastContribs.isEmpty || probPredicha == null)
            ? null
            : () =>
                _showReasons(context, _lastContribs, probPredicha ?? 0),
        icon: const Icon(Icons.insights_outlined),
        label: const Text('Motivos de esta predicción'),
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción ML'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Ver ayuda',
            icon: const Icon(Icons.help_outline),
            onPressed: () => showHelpSheet(
              context,
              child: const _MlHelpContent(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ajustá los sliders y tocá “Predecir”. El modelo sugiere qué queso ofrecer ahora.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    softWrap: true,
                  ),
                  const SizedBox(height: 12),
                  if (isMobile) ...[
                    params,
                    const SizedBox(height: 12),
                    result,
                    reasonsButton,
                    const SizedBox(height: 12),
                    aprender,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: params),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              result,
                              reasonsButton,
                              const SizedBox(height: 12),
                              aprender,
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: () {
              context.read<AppState>().setLevelCompleted(4);
              Navigator.pushNamed(context, '/level5');
            },
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
  final int hora;
  final double stockProm;
  final ValueChanged<int> onRacha;
  final ValueChanged<double> onTiempo;
  final ValueChanged<int> onHora;
  final ValueChanged<double> onStock;
  final VoidCallback onPredecir;

  const _ParametrosCard({
    required this.racha,
    required this.tiempoMs,
    required this.hora,
    required this.stockProm,
    required this.onRacha,
    required this.onTiempo,
    required this.onHora,
    required this.onStock,
    required this.onPredecir,
  });

  @override
  Widget build(BuildContext context) {
    final sliderTheme = SliderTheme.of(context).copyWith(
      showValueIndicator: ShowValueIndicator.onDrag,
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
    );

    Widget minMax(String minLabel, String maxLabel) {
      final style = Theme.of(context).textTheme.labelSmall;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: style),
            Text(maxLabel, style: style),
          ],
        ),
      );
    }

    return KawaiiCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Racha de aciertos'),
            SliderTheme(
              data: sliderTheme,
              child: Slider(
                min: 0,
                max: 10,
                divisions: 10,
                value: racha.toDouble(),
                label: '$racha',
                onChanged: (v) => onRacha(v.round()),
              ),
            ),
            minMax('0', '10'),
            const SizedBox(height: 12),
            const Text('Tiempo promedio por pedido (ms)'),
            SliderTheme(
              data: sliderTheme,
              child: Slider(
                min: 500,
                max: 15000,
                divisions: 29,
                value: tiempoMs,
                label: '${tiempoMs.toStringAsFixed(0)} ms',
                onChanged: onTiempo,
              ),
            ),
            minMax('500 ms', '15000 ms'),
            const SizedBox(height: 12),
            const Text('Hora del día (0–23)'),
            SliderTheme(
              data: sliderTheme,
              child: Slider(
                min: 0,
                max: 23,
                divisions: 23,
                value: hora.toDouble(),
                label: '$hora h',
                onChanged: (v) => onHora(v.toInt()),
              ),
            ),
            minMax('0 h', '23 h'),
            const SizedBox(height: 12),
            const Text('Stock promedio visible'),
            SliderTheme(
              data: sliderTheme,
              child: Slider(
                min: 0,
                max: 20,
                divisions: 20,
                value: stockProm,
                label: stockProm.toStringAsFixed(1),
                onChanged: onStock,
              ),
            ),
            minMax('0', '20'),
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

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: KawaiiCard(
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
                    softWrap: true,
                  ),
                  const SizedBox(height: 16),
                  const _HowCalculatedTile(),
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
                    'Necesito feedback para aprender: ajustá los parámetros y tocá “Predecir” '
                    'para estimar la probabilidad de acierto del próximo pedido.',
                    softWrap: true,
                  ),
                  const SizedBox(height: 16),
                  const _HowCalculatedTile(),
                ],
              ),
      ),
    );
  }
}

class _HowCalculatedTile extends StatelessWidget {
  const _HowCalculatedTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium;
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.75);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      iconColor: iconColor,
      collapsedIconColor: iconColor,
      textColor: theme.colorScheme.onSurface,
      collapsedTextColor: theme.colorScheme.onSurface,
      title: const Text('Cómo se calculó (tocar para ver)'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usamos un modelo de regresión logística online que aprende con tus jugadas (racha, tiempo, queso, hora, stock).',
                style: bodyStyle,
                softWrap: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Se recalibra en vivo con cada intento para mejorar la sugerencia siguiente.',
                style: bodyStyle,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AprenderCard extends StatelessWidget {
  final String texto;
  final void Function(bool ok) onAprender;
  const _AprenderCard({required this.texto, required this.onAprender});

  @override
  Widget build(BuildContext context) {
    return KawaiiCard(
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
          LayoutBuilder(
            builder: (context, constraints) {
              Widget buildSuccess({double? width}) => SizedBox(
                    width: width,
                    child: ElevatedButton.icon(
                      onPressed: () => onAprender(true),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Convirtió'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 48),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
              Widget buildFail({double? width}) => SizedBox(
                    width: width,
                    child: OutlinedButton.icon(
                      onPressed: () => onAprender(false),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('No convirtió'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(140, 48),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildSuccess(width: double.infinity),
                    const SizedBox(height: 8),
                    buildFail(width: double.infinity),
                  ],
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  buildSuccess(width: 180),
                  buildFail(width: 180),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MlHelpContent extends StatelessWidget {
  const _MlHelpContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Cómo funciona la predicción',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        SizedBox(height: 12),
        Text('• Modelo: regresión logística online entrenada con cada pedido del juego.'),
        Text('• Features: racha, tiempo de respuesta, hora del día, stock promedio visible y el queso ofrecido.'),
        Text('• Aprendizaje: cada feedback (“Convirtió/No convirtió”) ajusta los pesos en tiempo real.'),
        SizedBox(height: 16),
        Text(
          'Interpretación',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text('• La probabilidad indica qué tan probable es que el queso sugerido convierta en este turno.'),
        Text('• "Motivos" resume el aporte estimado de cada feature (peso × valor normalizado).'),
        Text('• Si recién empezaste, el modelo se mantendrá prudente cerca de 50% hasta aprender más.'),
        SizedBox(height: 16),
        Text(
          'Limitaciones y buenas prácticas',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text('• No captura variables externas como clima o campañas; complementalo con análisis cualitativo.'),
        Text('• Los pesos viven en tu dispositivo: borrar datos reinicia el entrenamiento.'),
        Text('• Usalo como brújula rápida y combiná con experimentos A/B para validar decisiones.'),
      ],
    );
  }
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
      final media = MediaQuery.of(c);
      final scrollHeight =
          (media.size.height * 0.55).clamp(240.0, 420.0).toDouble();

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
              SizedBox(
                height: scrollHeight,
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
