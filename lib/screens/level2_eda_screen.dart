import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
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
    'Provolone',
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
    final donutCard = _ParticipacionCard(counts: counts);

    final mainContent = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              topCard,
              const SizedBox(height: 12),
              donutCard,
              const SizedBox(height: 12),
              chartCard,
              const SizedBox(height: 12),
              recoCard,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    topCard,
                    const SizedBox(height: 12),
                    donutCard,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    chartCard,
                    const SizedBox(height: 12),
                    recoCard,
                  ],
                ),
              ),
            ],
          );

    final buttonAlignment = isMobile ? Alignment.center : Alignment.centerRight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EDA interactiva'),
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
                  onPressed: () {
                    context.read<AppState>().setLevelCompleted(2);
                    Navigator.pushNamed(context, '/level3');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Ir al Inventario'),
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
    final hasData = series.any((value) => value > 0);
    final maxCount =
        series.isEmpty ? 0 : series.reduce((a, b) => a > b ? a : b);
    final safeMax = maxCount <= 0 ? 1.0 : maxCount.toDouble();
    final interval = safeMax <= 5 ? 1.0 : (safeMax / 5).ceilToDouble();
    final chartMaxY = hasData ? safeMax + interval : safeMax;

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
            child: hasData
                ? BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      minY: 0,
                      maxY: chartMaxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.dividerColor.withValues(alpha: 0.18),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 32,
                            getTitlesWidget: (value, _) {
                              final n = value.round();
                              if (n < 0) {
                                return const SizedBox.shrink();
                              }
                              return Text('$n',
                                  style: theme.textTheme.bodySmall);
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (value, _) {
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
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Sin datos aún — jugá el Nivel 1 para registrar pedidos.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in labels)
                ActionChip(
                  avatar: const Text('🧀'),
                  label: Text('$label: ${counts[label] ?? 0}'),
                  onPressed: () => Navigator.pushNamed(context, '/level3'),
                  shape: StadiumBorder(
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParticipacionCard extends StatelessWidget {
  const _ParticipacionCard({required this.counts});

  final Map<String, int> counts;

  static const _palette = <Color>[
    Color(0xFFFFD166),
    Color(0xFFFFA8A8),
    Color(0xFFA0CED9),
    Color(0xFF98D8AA),
    Color(0xFFE0BBE4),
    Color(0xFFFFC4D6),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = Level2EdaScreen.ordenQuesos
        .map((name) => MapEntry(name, counts[name] ?? 0))
        .toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final hasData = total > 0;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final sections = <PieChartSectionData>[];

    if (hasData) {
      for (var i = 0; i < entries.length; i++) {
        final value = entries[i].value;
        if (value <= 0) continue;
        final percent = (value / total) * 100;
        sections.add(
          PieChartSectionData(
            color: _palette[i % _palette.length],
            value: value.toDouble(),
            title: percent >= 10
                ? '${percent.toStringAsFixed(0)}%'
                : '${percent.toStringAsFixed(1)}%',
            titleStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.brown.shade800,
                ) ??
                TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown.shade800,
                ),
            radius: isMobile ? 54 : 64,
          ),
        );
      }
    }

    final cardDecoration = BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participación por queso',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isMobile ? 180 : 200,
            child: hasData
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: isMobile ? 34 : 42,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                      sections: sections,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Sin datos aún — jugá el juego para ver participación.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          if (hasData)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entries
                  .where((entry) => entry.value > 0)
                  .map((entry) {
                final percent = (entry.value / total) * 100;
                final label = percent >= 10
                    ? '${percent.toStringAsFixed(0)}%'
                    : '${percent.toStringAsFixed(1)}%';
                return Chip(
                  label: Text('🧀 ${entry.key}: $label'),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.25),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            )
          else
            Text(
              'Jugá al menos una partida para habilitar este gráfico.',
              style: theme.textTheme.bodySmall,
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
