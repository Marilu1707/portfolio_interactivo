import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/data_service.dart';
import '../models/cheese_stat.dart';
import '../state/app_state.dart';

// Pantalla Nivel 5 (Dashboard): resume métricas del juego y del A/B.
class Level5DashboardScreen extends StatefulWidget {
  const Level5DashboardScreen({super.key});

  @override
  State<Level5DashboardScreen> createState() => _Level5DashboardScreenState();
}

class _Level5DashboardScreenState extends State<Level5DashboardScreen> {
  static const bg = Color(0xFFFFF3D6);
  static const card = Color(0xFFFFF9E8);
  static const border = Color(0xFFD4B98D);
  static const brand = Color(0xFFFFC44D);
  static const textDark = Color(0xFF5B4E2F);

  bool loading = true;
  List<CheeseStat> fallbackStats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Carga datos de respaldo (para mostrar si no hubo juego)
  Future<void> _load() async {
    final data = await DataService.loadCheeseStats();
    data.sort((a, b) => b.share.compareTo(a.share));
    setState(() {
      fallbackStats = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: SingleChildScrollView(
                    child: Column(
                    children: [
                      // Ratón analista (avatar)
                      SizedBox(
                        height: 90,
                        child: Center(
                          child: Image.asset(
                            'assets/img/ab_mouse.png',
                            width: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, cons) {
                          final w = cons.maxWidth;
                          final cols = w > 1024 ? 3 : (w > 600 ? 2 : 1);
                          final gap = 16.0;
                          final itemW = (w - gap * (cols - 1)) / cols;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              SizedBox(
                                width: itemW,
                                child: _Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const _H3('Tasa de acierto'),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${(app.accuracy * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: itemW,
                                child: _Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const _H3('Quesos servidos'),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatK(app.totalServed),
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: itemW,
                                child: _Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const _H3('Top quesos'),
                                      const SizedBox(height: 8),
                                      ..._topCheeses(app).map((name) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            child: Row(children: [const Text('🧀  '), Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark)))]),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, cons) {
                          final w = cons.maxWidth;
                          final cols = w > 1024 ? 3 : (w > 600 ? 2 : 1);
                          final gap = 16.0;
                          final itemW = (w - gap * (cols - 1)) / cols;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              SizedBox(
                                width: cols == 1 ? w : itemW,
                                child: _Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const _H3('Resumen'),
                                      const SizedBox(height: 10),
                                      _metricRow('Tasa de acierto', '${(app.accuracy * 100).toStringAsFixed(1)}%'),
                                      const SizedBox(height: 8),
                                      if (app.hasAb)
                                        _metricRow('A/B', app.pValue! < 0.05 ? 'Treatment gana' : 'No significativo'),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: cols == 1 ? w : (cols == 2 ? itemW : itemW * 2 + gap),
                                child: _Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const _H3('Distribución de quesos'),
                                      const SizedBox(height: 10),
                                      ..._distributionBars(app),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: cols == 1 ? w : itemW,
                                child: _Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const _H3('Participación (torta)'),
                                      const SizedBox(height: 10),
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: _PieCheese(app: app, fallback: fallbackStats),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/'),
                              icon: const Icon(Icons.home_rounded),
                              label: const Text('Volver a Home'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.brown.shade300, width: 2),
                                foregroundColor: Colors.brown,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
    );
  }

  List<String> _topCheeses(AppState app) {
    if (app.servedByCheese.isNotEmpty) {
      final entries = app.servedByCheese.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return entries.take(2).map((e) => e.key).toList();
    }
    return fallbackStats.take(2).map((c) => c.name).toList();
  }

  List<Widget> _distributionBars(AppState app) {
    if (app.servedByCheese.isNotEmpty) {
      final total = app.servedByCheese.values.fold<int>(0, (a, b) => a + b);
      final entries = app.servedByCheese.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return entries
          .map((e) => _BarRow(label: e.key, value: total == 0 ? 0 : e.value / total))
          .toList();
    }
    return fallbackStats.map((c) => _BarRow(label: c.name, value: c.share / 100)).toList();
  }

  Widget _metricRow(String k, String v) {
    // Muestra una fila clave-valor de métrica
    return Row(
      children: [
        Expanded(
          child: Text(k, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark)),
        ),
        Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark)),
      ],
    );
  }

  String _formatK(int n) {
    if (n >= 1000) {
      final k = (n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1);
      return (n % 1000 == 0) ? '${k}k' : '${k}k';
    }
    return n.toString();
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Level5DashboardScreenState.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Level5DashboardScreenState.border, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _H3 extends StatelessWidget {
  final String text;
  const _H3(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _Level5DashboardScreenState.textDark),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value; // 0..1
  const _BarRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: _Level5DashboardScreenState.textDark)),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value.clamp(0, 1),
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: _Level5DashboardScreenState.brand,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.brown.shade200.withValues(alpha: 0.35), blurRadius: 3, offset: const Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieCheese extends StatelessWidget {
  final AppState app;
  final List<CheeseStat> fallback;
  const _PieCheese({required this.app, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> data = {};
    if (app.servedByCheese.isNotEmpty) {
      final total = app.servedByCheese.values.fold<int>(0, (a, b) => a + b);
      if (total == 0) return _empty(context);
      app.servedByCheese.forEach((k, v) {
        data[k] = v / total;
      });
    } else {
      final totalShare = fallback.fold<double>(0, (a, b) => a + b.share);
      if (totalShare == 0) return _empty(context);
      for (final c in fallback) {
        data[c.name] = c.share / 100.0;
      }
    }

    final palette = [
      Colors.amber.shade400,
      Colors.orange.shade400,
      Colors.pink.shade300,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.lime.shade600,
    ];

    final sections = <PieChartSectionData>[];
    int idx = 0;
    data.forEach((label, frac) {
      sections.add(
        PieChartSectionData(
          value: (frac * 100).clamp(0, 100).toDouble(),
          color: palette[idx % palette.length],
          title: '${(frac * 100).toStringAsFixed(1)}%',
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
          radius: 60,
        ),
      );
      idx++;
    });

    return PieChart(
      PieChartData(
        centerSpaceRadius: 32,
        sectionsSpace: 2,
        sections: sections,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text('Sin datos aún'),
    );
  }
}
