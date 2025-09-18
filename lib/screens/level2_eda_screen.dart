import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

/// Nivel 2 — Exploración de datos (mobile‑first)
/// Lee datos reales desde AppState y muestra:
/// 1) Top de quesos (tabla por puntaje base)
/// 2) Quesos con mayor cantidad de pedidos (barras)
/// 3) Recomendación (globo + ratón ab_mouse.png)
class Level2EdaScreen extends StatelessWidget {
  const Level2EdaScreen({super.key});

  /// Orden fijo de quesos en UI (barras y chips)
  static const List<String> ordenQuesos = [
    'Mozzarella', 'Cheddar', 'Parmesano', 'Gouda', 'Brie', 'Azul'
  ];

  /// Genera la lista ordenada por puntaje base (descendente) para la tabla.
  List<MapEntry<String, double>> topPorPuntaje(AppState s) {
    final list = s.puntajeBase.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// Devuelve la serie de pedidos en el orden fijo.
  List<int> seriesPedidos(AppState s) =>
      ordenQuesos.map((q) => s.servedByCheese[q] ?? 0).toList();

  /// Construye el texto de recomendación según el top de pedidos.
  String buildRecomendacion(AppState s) {
    final counts = seriesPedidos(s);
    final maxVal = counts.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) {
      return 'Todavía no hay suficientes pedidos. Juguemos un poco más 😉';
    }
    final indicesTop = <int>[];
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] == maxVal) indicesTop.add(i);
    }
    if (indicesTop.length == 1) {
      final q = ordenQuesos[indicesTop.first];
      return 'Recomendación: destacá $q en el menú base.';
    }
    final q1 = ordenQuesos[indicesTop[0]];
    final q2 = ordenQuesos[indicesTop[1]];
    return 'Recomendación: mantené variedad; $q1 y $q2 compiten parejo.';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Secciones (tarjetas) en mobile se apilan; en desktop se distribuyen.
    final topCard = _TopQuesosCard(top: topPorPuntaje(s));
    final chartCard = _PedidosChartCard(series: seriesPedidos(s));
    final recoCard = _RecomendacionCard(texto: buildRecomendacion(s));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivel 2 — Exploración de datos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
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
                ),
        ),
      ),
    );
  }
}

/// Construye la tarjeta de "Top de quesos" mostrando nombre y puntaje.
/// Ordena por puntaje descendente para resaltar los mejores primero.
class _TopQuesosCard extends StatelessWidget {
  final List<MapEntry<String, double>> top;
  const _TopQuesosCard({required this.top});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Text('Top de quesos',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Tabla compacta de 2 columnas (Nombre | Puntaje)
          for (final e in top)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Expanded(child: Text(e.key, softWrap: true)),
                  Text(e.value.toStringAsFixed(1)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Tarjeta con barras "Quesos con mayor cantidad de pedidos" y chips debajo.
class _PedidosChartCard extends StatelessWidget {
  const _PedidosChartCard({required this.series});
  final List<int> series; // en orden fijo: Mozzarella..Azul

  static const labels = Level2EdaScreen.ordenQuesos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // maxValue no se usa en fl_chart directamente; lo omitimos

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
          Text('Quesos con mayor cantidad de pedidos',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                minY: 0,
                barTouchData: BarTouchData(enabled: true),
                gridData: FlGridData(show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(labels[i],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall),
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
          // Chips como OutlinedButton para legibilidad en móvil
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < labels.length; i++)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Text('🧀'),
                  label: Text('${labels[i]}: ${series[i]}'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de recomendación con fondo amarillo + imagen del ratón.
class _RecomendacionCard extends StatelessWidget {
  final String texto;
  const _RecomendacionCard({required this.texto});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final content = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Recomendación',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(texto, softWrap: true),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/img/ab_mouse.png', height: 84, fit: BoxFit.contain),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/img/ab_mouse.png', height: 84, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recomendación',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
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
