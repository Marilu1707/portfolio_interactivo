import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/cheese_rating.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';
import '../data/country_es.dart';
import '../utils/number_es.dart';
import '../data/cheese_catalog.dart';

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

  // Tabla fija con los 6 quesos oficiales del juego
  Widget _buildTopOficial() {
    final Map<String, double> scoreByName = {
      for (final r in ratings) _cheeseEs(r.name): r.score,
    };
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
                rows: [
                  for (final c in kCheeses)
                    DataRow(cells: [
                      DataCell(Text(c.nombre)),
                      DataCell(Text(c.pais)),
                      DataCell(Text((scoreByName[c.nombre] ?? 0.0).toStringAsFixed(1))),
                    ]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
    const labels = ['Mozzarella','Parmesano','Gouda','Brie','Azul','Cheddar'];
    final counts = [for (final l in labels) (app.servedByCheese[l] ?? 0)];
    final maxY = (counts.isEmpty ? 1 : counts.reduce((a,b)=> a>b?a:b)).toDouble().clamp(1, 9999);
    final isMobile = KawaiiTheme.isMobile(context);

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
                            Expanded(child: _Card(child: _buildTopOficial())),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _H3('Países con mayor puntaje (por pedidos)'),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: isMobile ? 4 / 3 : 16 / 9,
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
                                                reservedSize: isMobile ? 28 : 32,
                                                getTitlesWidget: (v, _) => Text(fmtInt(v.toInt()), style: const TextStyle(fontSize: 10)),
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: isMobile ? 28 : 36,
                                                getTitlesWidget: (x, _) {
                                                  final i = x.toInt();
                                                  if (i < 0 || i >= labels.length) return const SizedBox();
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 6),
                                                    child: Text(labels[i], style: TextStyle(fontSize: isMobile ? 10 : 11), overflow: TextOverflow.ellipsis),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          barGroups: [
                                            for (int i = 0; i < labels.length; i++)
                                              BarChartGroupData(x: i, barRods: [
                                                BarChartRodData(
                                                  toY: counts[i].toDouble(),
                                                  width: 22,
                                                  color: const Color(0xFFFFC44D),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ]),
                                          ],
                                        ),
                                      ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [for (int i=0;i<labels.length;i++) Chip(label: Text('${labels[i]}: ${fmtInt(counts[i])}'))],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _Card(child: _buildConclusionCheeses(labels, counts))),
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
  Widget _buildConclusionCheeses(List<String> labels, List<int> counts) {
    String text;
    if (counts.every((c) => c == 0)) {
      text = 'Todavía no hay suficientes pedidos. Jugá un poco más en el nivel 1.';
    } else {
      final max = counts.reduce((a,b)=> a>b?a:b);
      final idxs = [for (int i=0;i<counts.length;i++) if (counts[i]==max) i];
      final leaders = idxs.map((i)=>labels[i]).toList();
      text = '${leaders.join(' y ')} lidera/n por pedidos.\nRecomendación: destacá ese queso en el menú.';
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
