import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Datos “mock” para mostrar el ejemplo.
/// Si ya tenés tu AppState con métricas reales, reemplazá estos mapas.
final Map<String, double> puntajeBasePorQueso = {
  'Mozzarella': 3.8,
  'Parmesano': 4.6,
  'Gouda': 3.3,
  'Brie': 3.9,
  'Azul': 3.5,
  'Cheddar': 4.1,
};

/// Cantidad de pedidos del juego (se deberían actualizar en tiempo real).
final Map<String, int> pedidosPorQueso = {
  'Mozzarella': 0,
  'Parmesano': 1,
  'Gouda': 1,
  'Brie': 0,
  'Azul': 0,
  'Cheddar': 0,
};

/// Ejemplo de cálculo de “puntaje ajustado” = puntaje base * (1 + pedidos/totalPedidos)
Map<String, double> puntajeAjustado(Map<String, double> base, Map<String, int> pedidos) {
  final total = pedidos.values.fold<int>(0, (a, b) => a + b);
  // Para evitar división por cero
  final ajuste = total == 0 ? 0.0 : (total / 10.0); // podés tunear este factor
  return {
    for (final entry in base.entries)
      entry.key: (entry.value * (1.0 + (pedidos[entry.key]! == 0 ? 0.0 : ajuste))).toDouble()
  };
}

/// Pantalla principal Nivel 2 (responsive)
class Level2EdaMobile extends StatelessWidget {
  const Level2EdaMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = puntajeAjustado(puntajeBasePorQueso, pedidosPorQueso);

    // Ordenamos por puntaje ajustado (desc)
    final topOrdenado = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Recomendar los dos mejores
    final destacados = topOrdenado.take(2).map((e) => e.key).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        // Contenido apilado si es móvil; en filas si es desktop
        final content = isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RecomendacionBubble(destacados: destacados),
                  const SizedBox(height: 12),
                  _TopQuesosCard(topOrdenado: topOrdenado),
                  const SizedBox(height: 12),
                  _GraficoCard(scores: scores),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TopQuesosCard(topOrdenado: topOrdenado)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        _RecomendacionBubble(destacados: destacados),
                        const SizedBox(height: 12),
                        _GraficoCard(scores: scores),
                      ],
                    ),
                  ),
                ],
              );

        return Scaffold(
          backgroundColor: const Color(0xFFFCF5E9),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCF5E9),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Nivel 2 — Exploración de datos',
              style: TextStyle(
                color: Color(0xFF5B4636),
                fontWeight: FontWeight.w700,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF5B4636)),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: content,
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4C84A),
                  foregroundColor: const Color(0xFF5B4636),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/level3');
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Siguiente nivel',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Globo de recomendación (arriba)
class _RecomendacionBubble extends StatelessWidget {
  const _RecomendacionBubble({required this.destacados});

  final List<String> destacados;

  @override
  Widget build(BuildContext context) {
    final textoDestacados =
        destacados.isEmpty ? 'Aún sin datos suficientes.' : '${destacados.join(' y ')} lideran por pedidos.';

    return Card(
      color: const Color(0xFFFFF0C9),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ratoncito
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                'assets/img/ab_mouse.png',
                height: 56,
                fit: BoxFit.contain,
              ),
            ),
            // texto
            Expanded(
              child: Text(
                '$textoDestacados\nRecomendación: destacá esos quesos en el menú.',
                style: const TextStyle(
                  color: Color(0xFF5B4636),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card “Top de quesos”
class _TopQuesosCard extends StatelessWidget {
  const _TopQuesosCard({required this.topOrdenado});

  final List<MapEntry<String, double>> topOrdenado;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TituloCard(texto: 'Top de quesos'),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...topOrdenado.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_food_beverage, size: 18, color: Color(0xFF5B4636)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          color: Color(0xFF5B4636),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      e.value.toStringAsFixed(1),
                      style: const TextStyle(color: Color(0xFF5B4636)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// Card con gráfico (barras en móvil; en desktop podés cambiar a torta si querés)
class _GraficoCard extends StatelessWidget {
  const _GraficoCard({required this.scores});

  final Map<String, double> scores;

  @override
  Widget build(BuildContext context) {
    // Para móvil usamos barras verticales (simple y legible).
    final categorias = scores.keys.toList();
    final valores = scores.values.toList();

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TituloCard(texto: 'Puntaje ajustado por pedidos'),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= categorias.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Transform.rotate(
                              angle: -0.6, // leve inclinación para móviles
                              child: Text(
                                categorias[i],
                                style: const TextStyle(fontSize: 11, color: Color(0xFF5B4636)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(categorias.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: valores[i],
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFFF4C84A),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Chips debajo con los valores (mejoran la legibilidad en cel).
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categorias.map((q) {
                return Chip(
                  backgroundColor: const Color(0xFFFFF0C9),
                  label: Text(
                    '$q: ${scores[q]!.toStringAsFixed(1)}',
                    style: const TextStyle(color: Color(0xFF5B4636)),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TituloCard extends StatelessWidget {
  const _TituloCard({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Color(0xFF5B4636),
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

