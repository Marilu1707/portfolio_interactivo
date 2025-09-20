import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../state/ab_result_state.dart';
import '../state/orders_state.dart';

const _kCheeseLabels = <String>['Mozzarella', 'Cheddar', 'Parmesano', 'Gouda', 'Brie', 'Azul'];

class Level5DashboardScreen extends StatefulWidget {
  const Level5DashboardScreen({super.key});

  @override
  State<Level5DashboardScreen> createState() => _Level5DashboardScreenState();
}

class _Level5DashboardScreenState extends State<Level5DashboardScreen> {
  // Paleta “pro kawaii” (beige/amarillo/marrón)
  static const bg = Color(0xFFFFF6E5);
  static const brand = Color(0xFFFFD166);
  static const textDark = Color(0xFF6B4E16);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final app = context.read<AppState>();
      final level = app.lastLevelCompleted;
      if (level != null) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Nivel completado'),
            content: Text('Completaste el Nivel $level. ¡Bien hecho!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        app.clearLastLevelCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final today = DateFormat('dd MMM yyyy', 'es_AR').format(DateTime.now());
    final servedEntries = app.servedByCheese.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCheese = servedEntries.isNotEmpty ? servedEntries.first.key : null;
    final rawAccuracy = app.accuracy;
    final accuracy = rawAccuracy.isFinite && rawAccuracy > 0 ? rawAccuracy : 0.0;
    final totalServed = app.totalServed > 0 ? app.totalServed : 0;
    final topCheeseDisplay = topCheese == null ? '—' : '🧀 $topCheese';
    final hasServedData = servedEntries.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Panel de Control',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textDark),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: LayoutBuilder(builder: (context, cons) {
                final isWide = cons.maxWidth >= 1000;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header compacto
                    kawaiiCard(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Panel de Control',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Hoy', style: TextStyle(color: textDark)),
                              Text(
                                today,
                                style: const TextStyle(
                                  color: textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/img/ab_mouse.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // KPIs
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: isWide ? 300 : cons.maxWidth,
                          child: KpiTile(
                            label: 'Tasa de acierto',
                            value: '${(accuracy * 100).toStringAsFixed(1)}%',
                            icon: Icons.verified,
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 300 : cons.maxWidth,
                          child: KpiTile(
                            label: 'Quesos servidos',
                            value: _formatK(totalServed),
                            icon: Icons.restaurant,
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 300 : cons.maxWidth,
                          child: KpiTile(
                            label: 'Top queso',
                            value: topCheeseDisplay,
                            icon: Icons.emoji_food_beverage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Pedidos vs Servidos (cumplimiento)
                    Builder(builder: (context) {
                      final orders = context.watch<OrdersState>();
                      return kawaiiCard(
                        child: _DemandVsServed(
                          requested: orders.requestedByCheese,
                          served: orders.servedByCheese,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    // Último A/B (si hay)
                    Builder(builder: (context) {
                      final ab = context.watch<ABResultState?>()?.last;
                      if (ab == null) return const SizedBox.shrink();
                      return kawaiiCard(
                        child: ListTile(
                          leading: const Icon(Icons.science),
                          title: const Text('Último A/B Test'),
                          subtitle: Text(
                            'pA: ${ab['pA']} · pB: ${ab['pB']} · p: ${ab['p']} · sig: ${ab['sig']}',
                          ),
                          trailing: Text('Lift: ${ab['lift']}'),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    // Gráficos
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: isWide ? (cons.maxWidth - 24) * .6 : cons.maxWidth,
                          child: kawaiiCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📊 Distribución por queso',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _Bars(app: app),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (cons.maxWidth - 24) * .38 : cons.maxWidth,
                          child: kawaiiCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Participación (donut)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(height: 180, child: _PieCheese(app: app)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Insights
                    kawaiiCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Insights',
                            style: TextStyle(fontWeight: FontWeight.w700, color: textDark),
                          ),
                          const SizedBox(height: 8),
                          if (!hasServedData)
                            const Text('• Aún no hay datos. Jugá un nivel para comenzar.')
                          else if (topCheese != null)
                            Text('• $topCheese es el más pedido.'),
                          ..._lowStockInsights(app),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Volver a Home'),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatK(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  List<Widget> _lowStockInsights(AppState app) {
    final items = app.inventory.values.toList();
    if (items.isEmpty) return [];
    final lows = items.where((i) => i.stock < 20).toList();
    if (lows.isEmpty) return [];
    lows.sort((a, b) => a.stock.compareTo(b.stock));
    final top3 = lows.take(3).map((i) {
      final status = _statusText(i.stock);
      return '• $status en ${i.name} (${i.stock})';
    });
    return top3.map((t) => Text(t)).toList();
  }

  String _statusText(int stock) {
    if (stock < 10) return 'Stock crítico';
    if (stock < 20) return 'Stock medio';
    return 'Stock ok';
  }
}

// Card base kawaii pro
Widget kawaiiCard({required Widget child}) => Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.brown.withValues(alpha: .08),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );

// KPI tile
class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const KpiTile({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return kawaiiCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE082),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _Level5DashboardScreenState.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: _Level5DashboardScreenState.textDark)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: _Level5DashboardScreenState.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Gráfico de barras (usa tus datos reales)
class _Bars extends StatelessWidget {
  final AppState app;
  const _Bars({required this.app});

  @override
  Widget build(BuildContext context) {
    const labels = _kCheeseLabels;
    final series = labels.map((q) => app.servedByCheese[q] ?? 0).toList();
    final hasData = series.any((v) => v > 0);

    if (!hasData) {
      return _ChartPlaceholder(
        message: 'Sin datos aún — jugá un nivel para ver pedidos por queso.',
        labels: labels,
        valueSuffix: '',
      );
    }

    final maxY = series.reduce((a, b) => a > b ? a : b).toDouble();
    final safeMaxY = maxY == 0 ? 1.0 : maxY;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: safeMaxY,
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: (safeMaxY <= 5 ? 1.0 : (safeMaxY / 5).ceilToDouble()),
                getTitlesWidget: (value, meta) {
                  final n = value.round();
                  if (n < 0) return const SizedBox.shrink();
                  return Text('$n', style: Theme.of(context).textTheme.bodySmall);
                },
              ),
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
                    child: Transform.rotate(
                      angle: -0.6,
                      child: Text(labels[i],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall),
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
                    color: _Level5DashboardScreenState.brand,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// (Removed unused widgets: _H3 and _BarRow)

class _PieCheese extends StatelessWidget {
  final AppState app;
  const _PieCheese({required this.app});

  @override
  Widget build(BuildContext context) {
    final entries = app.servedByCheese.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) {
      return _ChartPlaceholder(
        message: 'Sin datos aún — jugá un nivel para ver participación por queso.',
        labels: _kCheeseLabels,
        valueSuffix: '%',
        height: 180,
      );
    }

    final total = entries.fold<int>(0, (a, b) => a + b.value);
    if (total <= 0) {
      return _ChartPlaceholder(
        message: 'Sin datos aún — jugá un nivel para ver participación por queso.',
        labels: _kCheeseLabels,
        valueSuffix: '%',
        height: 180,
      );
    }

    final palette = [
      _Level5DashboardScreenState.brand,
      const Color(0xFFFFE082),
      const Color(0xFFFFE49D),
      const Color(0xFFFFDFA6),
      const Color(0xFFFFC44D),
      const Color(0xFFFFD166),
    ];

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final frac = entry.value / total;
      sections.add(
        PieChartSectionData(
          value: (frac * 100).clamp(0, 100).toDouble(),
          color: palette[i % palette.length],
          title: '${(frac * 100).toStringAsFixed(1)}%',
          titleStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
          radius: 60,
        ),
      );
    }

    return PieChart(
      PieChartData(
        centerSpaceRadius: 32,
        sectionsSpace: 2,
        sections: sections,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final String message;
  final List<String> labels;
  final String valueSuffix;
  final double? height;

  const _ChartPlaceholder({
    required this.message,
    required this.labels,
    this.valueSuffix = '',
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final suffix = valueSuffix;
    final valueText = suffix.isEmpty ? '0' : '0$suffix';
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in labels)
                Chip(
                  label: Text('$label: $valueText'),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(widthFactor: 1, child: content),
        ),
      );
    }

    return SizedBox(width: double.infinity, child: content);
  }
}

class _DemandVsServed extends StatelessWidget {
  final Map<String, int> requested;
  final Map<String, int> served;
  const _DemandVsServed({required this.requested, required this.served});

  static const labels = _kCheeseLabels;

  @override
  Widget build(BuildContext context) {
    final hasAnyData =
        requested.values.any((v) => v > 0) || served.values.any((v) => v > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pedidos vs Servidos (cumplimiento)',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _Level5DashboardScreenState.textDark,
          ),
        ),
        const SizedBox(height: 10),
        if (!hasAnyData)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Sin datos aún — jugá un nivel para ver resultados.'),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 40,
              columns: const [
                DataColumn(label: Text('Queso')),
                DataColumn(label: Text('Pedidos')),
                DataColumn(label: Text('Servidos')),
                DataColumn(label: Text('Cumpl.')),
              ],
              rows: [
                for (final q in labels)
                  _row(
                    q,
                    (requested[q] ?? 0),
                    (served[q] ?? 0),
                  )
              ],
            ),
          ),
      ],
    );
  }

  DataRow _row(String q, int req, int srv) {
    final hasReq = req > 0;
    final ratio = hasReq ? (srv / req) : 0.0;
    final pct = hasReq ? '${(ratio * 100).toStringAsFixed(0)}%' : '—';
    final chipColor = _ratioColor(ratio, hasReq);
    return DataRow(
      cells: [
        DataCell(Text(q)),
        DataCell(Text('$req')),
        DataCell(Text('$srv')),
        DataCell(
          Chip(
            label: Text(
              pct,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            backgroundColor: chipColor,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Color _ratioColor(double ratio, bool hasReq) {
    if (!hasReq) return Colors.grey.shade400;
    if (ratio >= 1.0) return const Color(0xFF2E7D32); // verde
    if (ratio >= 0.7) return const Color(0xFFF9A825); // ámbar
    return const Color(0xFFC62828); // rojo
  }
}
