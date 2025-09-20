import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../state/orders_state.dart';

/// Nivel 2 — Exploración de datos (mobile-first)
/// Lee pedidos reales persistidos y muestra:
/// 1) Top de quesos (puntaje normalizado por pedidos)
/// 2) Quesos con mayor cantidad de pedidos (barras)
/// 3) Recomendación (globo + ratón ab_mouse.png)
class Level2EdaScreen extends StatelessWidget {
  const Level2EdaScreen({super.key});

  /// Orden fijo de quesos en UI (barras y chips)
  static const List<String> ordenQuesos = [
    'Mozzarella',
    'Cheddar',
    'Parmesano',
    'Gouda',
    'Brie',
    'Azul',
  ];

  /// Ordena los quesos por cantidad de pedidos (descendente).
  List<MapEntry<String, int>> ordenarPorPedidos(Map<String, int> counts) {
    final list = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// Serie de pedidos en el orden fijo para el gráfico.
  List<int> seriesPedidos(Map<String, int> counts) =>
      ordenQuesos.map((q) => counts[q] ?? 0).toList();

  /// Recomendación basada en los pedidos reales.
  String buildRecomendacion(Map<String, int> counts) {
    if (counts.values.every((value) => value == 0)) {
      return 'Todavía no hay suficientes pedidos. Juguemos un poco más 😉';
    }

    final ordered = ordenarPorPedidos(counts);
    final top = ordered.first;
    final second = ordered.length > 1 ? ordered[1] : null;

    if (second != null && second.value == top.value) {
      return 'Recomendación: mantené variedad; ${top.key} y ${second.key} compiten parejo.';
    }

    if (second == null || second.value == 0) {
      return 'Recomendación: destacá ${top.key} en el menú base.';
    }

    return 'Recomendación: priorizá ${top.key}, seguido por ${second.key}.';
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersState>();
    // Usar DEMANDA (lo que pidió el ratón)
    final counts = orders.requestedByCheese;
    // Puntuación normalizada basada en DEMANDA
    final scores = orders.scores();
    final sorted = ordenarPorPedidos(counts);
    final isMobile = MediaQuery.of(context).size.width < 700;

    final topCard = _TopQuesosCard(sorted: sorted, scores: scores);
    final chartCard = _PedidosChartCard(
      series: seriesPedidos(counts),
      counts: counts,
    );
    final recoCard = _RecomendacionCard(texto: buildRecomendacion(counts));

    final mainContent = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              topCard,
              const SizedBox(height: 12),
              chartCard,
              const SizedBox(height: 12),
              recoCard,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: topCard),
              const SizedBox(width: 16),
              Expanded(child: chartCard),
              const SizedBox(width: 16),
              Expanded(child: recoCard),
            ],
          );

    final buttonAlignment = isMobile ? Alignment.center : Alignment.centerRight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivel 2 — Exploración de datos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              mainContent,
              const SizedBox(height: 24),
              Align(
                alignment: buttonAlignment,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/level3'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Ir al Nivel 3'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE082),
                    foregroundColor: const Color(0xFF5B4E2F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tabla con pedidos reales y puntajes normalizados (0-5).
class _TopQuesosCard extends StatelessWidget {
  const _TopQuesosCard({required this.sorted, required this.scores});

  final List<MapEntry<String, int>> sorted;
  final Map<String, double> scores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = sorted.any((entry) => entry.value > 0);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top de quesos',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          if (!hasData)
            Text(
              'Todavía no hay pedidos registrados.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...sorted.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key, softWrap: true)),
                    Text(
                      '${entry.value} pedidos · ${(scores[entry.key] ?? 0).toStringAsFixed(1)}⭐',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PedidosChartCard extends StatelessWidget {
  const _PedidosChartCard({required this.series, required this.counts});

  final List<int> series;
  final Map<String, int> counts;

  static const labels = Level2EdaScreen.ordenQuesos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount =
        series.isEmpty ? 0 : series.reduce((a, b) => a > b ? a : b);
    final maxY = (maxCount == 0 ? 1 : maxCount).toDouble();
    final interval = maxY <= 5 ? 1.0 : (maxY / 5).ceilToDouble();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quesos con mayor cantidad de pedidos',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                minY: 0,
                maxY: maxY + 1,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true, interval: interval, reservedSize: 28),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < labels.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: series[i].toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in labels)
                ActionChip(
                  avatar: const Icon(Icons.local_pizza_outlined, size: 18),
                  label: Text('$label: ${counts[label] ?? 0}'),
                  onPressed: () => Navigator.pushNamed(context, '/level3'),
                  shape: StadiumBorder(
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de Recomendación con fondo amarillo + imagen del ratón.
class _RecomendacionCard extends StatelessWidget {
  const _RecomendacionCard({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final content = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Recomendación',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(texto, softWrap: true),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/img/ab_mouse.png',
                    height: 84, fit: BoxFit.contain),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/img/ab_mouse.png',
                  height: 84, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recomendación',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(texto, softWrap: true),
                  ],
                ),
              ),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCE9A8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}
