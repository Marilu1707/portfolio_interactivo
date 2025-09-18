import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/cheese_rating.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';
import '../data/country_es.dart';
import '../utils/number_es.dart';

// Nivel 2 (EDA): tabla de rankings y gráfico por países

class Level2EdaScreen extends StatefulWidget {
  const Level2EdaScreen({super.key});

  @override
  State<Level2EdaScreen> createState() => _Level2EdaScreenState();
}

class _Level2EdaScreenState extends State<Level2EdaScreen> {
  static const bg = KawaiiTheme.bg;
  static const card = KawaiiTheme.card;

  bool loading = true;
  List<CheeseRating> ratings = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Cargamos ratings de ejemplo desde assets para completar la tabla
    final data = await DataService.loadCheeseRatings();
    data.sort((a, b) => b.score.compareTo(a.score));
    setState(() {
      ratings = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final topCountries = app.topCountries(5);
    final maxY = topCountries.isEmpty ? 1.0 : topCountries.first.value.toDouble().clamp(1, 9999);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Nivel 2 — Exploración de datos'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _Card(child: _buildTop10())),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _H3('Países con mayor puntaje (por pedidos)'),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: BarChart(
                                        BarChartData(
                                          minY: 0,
                                          alignment: BarChartAlignment.spaceAround,
                                          borderData: FlBorderData(show: false),
                                          gridData: FlGridData(show: true, horizontalInterval: (maxY / 4).clamp(1, 999)),
                                          titlesData: FlTitlesData(
                                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 32,
                                                getTitlesWidget: (v, _) => Text(fmtInt(v.toInt()), style: const TextStyle(fontSize: 10)),
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 36,
                                                getTitlesWidget: (x, _) {
                                                  final i = x.toInt();
                                                  if (i < 0 || i >= topCountries.length) return const SizedBox();
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 6),
                                                    child: Text(topCountries[i].key, style: const TextStyle(fontSize: 11)),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          barGroups: [
                                            for (int i = 0; i < topCountries.length; i++)
                                              BarChartGroupData(x: i, barRods: [
                                                BarChartRodData(
                                                  toY: topCountries[i].value.toDouble(),
                                                  width: 22,
                                                  color: const Color(0xFFFFC44D),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: topCountries
                                          .map((e) => Chip(label: Text('${e.key}: ${fmtInt(e.value)}')))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _Card(child: _buildConclusion(topCountries))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/level3'),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Siguiente nivel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTop10() {
    final top = [...ratings]..sort((a, b) => b.score.compareTo(a.score));
    final top10 = top.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _H3('Top de quesos'),
        const SizedBox(height: 8),
        Expanded(
          child: Material(
            color: Colors.white,
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
                columns: const [
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('País')),
                  DataColumn(label: Text('Puntaje')),
                ],
                rows: top10
                    .map((c) => DataRow(cells: [
                          DataCell(Text(_cheeseEs(c.name))),
                          DataCell(Text(toCountryEs(c.country))),
                          DataCell(Text(c.score.toStringAsFixed(1))),
                        ]))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Localiza nombres de queso puntuales para visualización
  String _cheeseEs(String name) {
    if (name.toLowerCase() == 'parmesan') return 'Parmesano';
    return name;
  }

  Widget _buildConclusion(List<MapEntry<String, int>> top) {
    String text;
    if (top.length < 2) {
      text = 'Todavía no hay suficientes pedidos. Jugá un poco más en el nivel 1.';
    } else {
      text = '${top[0].key} y ${top[1].key} lideran el puntaje por pedidos reales.\n'
          'Recomendación: destacá estilos de esos países en el menú base.';
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE79A).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: KawaiiTheme.onAccent)),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Level2EdaScreenState.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}
