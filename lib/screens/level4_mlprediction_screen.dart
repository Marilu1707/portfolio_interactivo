// lib/screens/level4_mlprediction_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Si ya tenés tu AppState en otro path, ajustá este import:
import '../state/app_state.dart';

/// Nivel 4 — Predicción ML (Regresión logística simple)
/// ---------------------------------------------------
/// Objetivo: estimar la probabilidad de “acierto/conversión”
/// del próximo pedido en base a features simples del juego
/// (racha de aciertos, tiempo promedio, queso elegido, hora, stock).
///
/// - UI mobile-first con controles (sliders/dropdown).
/// - Botón “Predecir” -> calcula prob. con una regresión logística
///   con coeficientes de ejemplo (podés calibrarlos más adelante).
/// - Muestra probabilidad (%) y una sugerencia de queso
///   basada en los pedidos reales (AppState.pedidosPorQueso).
class Level4MlPredictionScreen extends StatefulWidget {
  const Level4MlPredictionScreen({super.key});

  @override
  State<Level4MlPredictionScreen> createState() =>
      _Level4MlPredictionScreenState();
}

class _Level4MlPredictionScreenState extends State<Level4MlPredictionScreen> {
  // Orden fijo de quesos en toda la app
  static const ordenQuesos = <String>[
    'Mozzarella',
    'Cheddar',
    'Parmesano',
    'Gouda',
    'Brie',
    'Azul',
  ];

  // ---------- Features (con valores iniciales razonables) ----------
  double racha = 2;        // racha de aciertos (0..10)
  double tiempoMs = 6000;  // tiempo promedio (ms) (1000..15000)
  int quesoIdx = 0;        // índice del queso seleccionado (0..5)
  int hora = 13;           // hora del día (0..23)
  double stockProm = 10;   // stock promedio visible (0..20)

  // ---------- Salidas ----------
  double? probPredicha; // 0..1
  String? sugerencia;   // texto explicando qué conviene ofrecer

  // ---------- Coeficientes del modelo (de ejemplo) ----------
  // p = sigmoid(b0 + b1*racha + b2*tiempo + b3(queso) + b4*horaNorm + b5*stock)
  // Ajustá estos coeficientes a medida que tengas datos reales.
  final double b0 = -1.2;
  final double bRacha = 0.25;
  final double bTiempo = -0.00015; // penaliza tiempos altos
  final List<double> bQueso = [0.10, 0.08, 0.12, 0.05, 0.06, 0.04]; // por queso
  final double bHora = 0.30;      // efecto de “hora” tras normalizar
  final double bStock = 0.04;     // más stock, más chances

  // Sigmoide para la regresión logística
  double _sigmoid(double z) => 1 / (1 + math.exp(-z));

  // Normalización simple de hora a [-1, 1] (centrada en 12)
  double _horaNorm(int h) => ((h - 12) / 12.0).clamp(-1.0, 1.0);

  // Construye la recomendación rápida según pedidos reales (AppState)
  String _buildSugerencia(AppState? s) {
    if (s == null || s.pedidosPorQueso.isEmpty) {
      return 'Sugerencia: ofrecé Mozzarella para empezar (sin datos suficientes).';
    }
    String mejor = ordenQuesos.first;
    int max = -1;
    for (final q in ordenQuesos) {
      final v = s.pedidosPorQueso[q] ?? 0;
      if (v > max) {
        max = v;
        mejor = q;
      }
    }
    return 'Sugerencia: ofrecé $mejor (mayor demanda histórica en tu juego).';
  }

  // Calcula la probabilidad con los features actuales
  void _predecir(AppState? s) {
    final xRacha = racha;                // ya está en escala 0..10
    final xTiempo = tiempoMs;            // ms
    final xQueso = bQueso[quesoIdx];     // efecto directo por tipo de queso
    final xHora = _horaNorm(hora);       // [-1, 1]
    final xStock = stockProm;            // 0..20 (ajustar si usás otro rango)

    final z = b0 +
        bRacha * xRacha +
        bTiempo * xTiempo +
        xQueso +
        bHora * xHora +
        bStock * xStock;

    final p = _sigmoid(z);
    setState(() {
      probPredicha = p;
      sugerencia = _buildSugerencia(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si usás Provider, tomamos AppState. Si no, queda null y no se rompe.
    final app = context.mounted ? context.read<AppState?>() : null;

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivel 4 — Predicción ML'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile ? _buildMobile(app) : _buildDesktop(app),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/level5'),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Ir al Nivel 5 (A/B Test)'),
          ),
        ),
      ),
    );
  }

  // ---------- Layouts ----------

  Widget _buildMobile(AppState? s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InputsCard(
          racha: racha,
          tiempoMs: tiempoMs,
          quesoIdx: quesoIdx,
          hora: hora,
          stockProm: stockProm,
          onRacha: (v) => setState(() => racha = v),
          onTiempo: (v) => setState(() => tiempoMs = v),
          onQueso: (v) => setState(() => quesoIdx = v),
          onHora: (v) => setState(() => hora = v),
          onStock: (v) => setState(() => stockProm = v),
          onPredecir: () => _predecir(s),
        ),
        const SizedBox(height: 12),
        _ResultadoCard(probPredicha: probPredicha, sugerencia: sugerencia),
      ],
    );
  }

  Widget _buildDesktop(AppState? s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _InputsCard(
            racha: racha,
            tiempoMs: tiempoMs,
            quesoIdx: quesoIdx,
            hora: hora,
            stockProm: stockProm,
            onRacha: (v) => setState(() => racha = v),
            onTiempo: (v) => setState(() => tiempoMs = v),
            onQueso: (v) => setState(() => quesoIdx = v),
            onHora: (v) => setState(() => hora = v),
            onStock: (v) => setState(() => stockProm = v),
            onPredecir: () => _predecir(s),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ResultadoCard(probPredicha: probPredicha, sugerencia: sugerencia),
        ),
      ],
    );
  }
}

/// ---------- Widgets de UI ----------

class _InputsCard extends StatelessWidget {
  final double racha;
  final double tiempoMs;
  final int quesoIdx;
  final int hora;
  final double stockProm;
  final ValueChanged<double> onRacha;
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
    'Azul',
  ];

  const _InputsCard({
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
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.w700);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parámetros del modelo', style: labelStyle),
            const SizedBox(height: 12),

            // Racha
            Text('Racha de aciertos: ${racha.toInt()}'),
            Slider(
              min: 0,
              max: 10,
              value: racha,
              onChanged: onRacha,
            ),
            const SizedBox(height: 8),

            // Tiempo promedio
            Text('Tiempo promedio por pedido (ms): ${tiempoMs.toInt()}'),
            Slider(
              min: 1000,
              max: 15000,
              value: tiempoMs,
              onChanged: onTiempo,
            ),
            const SizedBox(height: 8),

            // Queso
            Text('Queso del próximo pedido (estimado):'),
            const SizedBox(height: 4),
            DropdownButton<int>(
              value: quesoIdx,
              items: List.generate(
                _quesos.length,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(_quesos[i]),
                ),
              ),
              onChanged: (v) => onQueso(v ?? 0),
            ),
            const SizedBox(height: 8),

            // Hora
            Text('Hora del día: $hora h'),
            Slider(
              min: 0,
              max: 23,
              divisions: 23,
              value: hora.toDouble(),
              onChanged: (v) => onHora(v.toInt()),
            ),
            const SizedBox(height: 8),

            // Stock
            Text('Stock promedio visible: ${stockProm.toStringAsFixed(1)}'),
            Slider(
              min: 0,
              max: 20,
              value: stockProm,
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
                      'Usamos una regresión logística simple con tus parámetros '
                      '(racha, tiempo, queso, hora, stock). Podés calibrar los coeficientes '
                      'según resultados reales para mejorar la precisión.',
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
