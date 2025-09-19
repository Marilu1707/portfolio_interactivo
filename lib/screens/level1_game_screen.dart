import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cheese_stat.dart';
import '../services/data_service.dart';
import '../data/cheese_catalog.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';
import '../state/orders_state.dart';
import '../services/ml_service.dart';

// Pantalla Nivel 1 (Juego): simula pedidos y mide aciertos por queso.
class Level1GameScreen extends StatefulWidget {
  const Level1GameScreen({super.key});

  @override
  State<Level1GameScreen> createState() => _Level1GameScreenState();
}

class _Level1GameScreenState extends State<Level1GameScreen> {
  static const Color bg = KawaiiTheme.bg;
  static const Color card = KawaiiTheme.card;

  final _rng = Random();
  List<CheeseStat> stats = [];
  bool loading = true;

  int score = 0;
  int streak = 0;
  String? currentOrder;
  String? _currentBucket; // "A" o "B"
  String? feedback;
  DateTime? _orderStart;
  // Mapeo de display es-AR
  String _esAr(String name) => name;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // Carga datos de referencia y arranca la primera orden
  Future<void> _init() async {
    final data = await DataService.loadCheeseStats();
    data.sort((a, b) => b.share.compareTo(a.share));
    setState(() {
      stats = data;
      loading = false;
    });
    _nextOrder();
  }

  String _weightedOrder() {
    final total = stats.fold<double>(0, (a, b) => a + b.share);
    var r = _rng.nextDouble() * total;
    for (final s in stats) {
      if (r < s.share) return s.name;
      r -= s.share;
    }
    return stats.isNotEmpty ? stats.last.name : 'Mozzarella';
  }

  // Selecciona el prÃ³ximo pedido (ponderado por share) y bucket A/B
  void _nextOrder() {
    if (stats.isEmpty) return;
    setState(() {
      currentOrder = _weightedOrder();
      _currentBucket = _rng.nextBool() ? 'A' : 'B';
      feedback = null;
      _orderStart = DateTime.now();
    });
  }

  // Registra el servicio, actualiza puntaje/racha y notifica al AppState
  void _serve(String chosen) {
    if (currentOrder == null) return;
    final orderNow = currentOrder!;
    final isCorrect = (chosen == orderNow);

    setState(() {
      if (isCorrect) {
        streak += 1;
        final gained = 10 + 2 * (streak - 1);
        score += gained;
        feedback = '¡Bien! +$gained';
      } else {
        score = score > 0 ? score - 5 : 0;
        streak = 0;
        feedback = 'Ups... -5 🗑️';
      }
      currentOrder = null;
    });

    final app = context.read<AppState>();
    final ordersState = context.read<OrdersState>();

    app.useCheese(chosen, success: isCorrect);
    app.recordServe(
      order: orderNow,
      chosen: chosen,
      isCorrect: isCorrect,
      bucketAB: _currentBucket ?? 'A',
    );
    ordersState.addOrder(chosen);

    final messenger = ScaffoldMessenger.of(context);
    final snackMessage = isCorrect
        ? '✅ Pedido correcto, se descontó 1 de $chosen'
        : '❌ Pedido incorrecto, se desperdiciaron 2 de $chosen 🗑️';
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(snackMessage)));

    // Aprendizaje online (Nivel 4): registrar evento y actualizar modelo
    try {
      final elapsedMs = _orderStart == null
          ? 0.0
          : DateTime.now().difference(_orderStart!).inMilliseconds.toDouble();
      final inv = app.inventory.values.toList();
      final avgStock = inv.isEmpty
          ? 0.0
          : inv.map((e) => e.stock).fold<int>(0, (a, b) => a + b) /
              inv.length;
      MlService.instance.learn(
        streak: streak,
        avgMs: elapsedMs,
        hour: DateTime.now().hour,
        stock: avgStock.toDouble(),
        cheeseShown: chosen,
        converted: isCorrect ? 1 : 0,
        wastePenalty: !isCorrect,
      );
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 900), _nextOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Nivel 1 — Nido Mozzarella'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pedidos',
                            style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.brown,
                                    ) ??
                                const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.brown),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _pill('Puntaje  $score'),
                            const SizedBox(width: 12),
                            _pill('Racha  $streak'),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/level2'),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Siguiente nivel'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  'NIVEL 1',
                                  style: TextStyle(
                                    letterSpacing: 2,
                                    color: Colors.brown,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Restaurante Kawaii',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.brown,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (currentOrder != null)
                                  _speech('¡Quiero ${_esAr(currentOrder!)}!'),
                                if (currentOrder == null)
                                  const SizedBox(height: 32),
                                const SizedBox(height: 16),
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0B8),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/img/mouse_kawaii.png',
                                    width: 120,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stack) =>
                                        const Icon(Icons.pets,
                                            size: 84, color: Colors.brown),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (feedback != null)
                                  Chip(
                                    label: Text(feedback!),
                                    backgroundColor: const Color(0xFFFFE79A),
                                    labelStyle: const TextStyle(
                                        color: KawaiiTheme.onAccent,
                                        fontWeight: FontWeight.w700),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: kCheeses
                              .map((c) =>
                                  _cheeseChip(c.nombre, () => _serve(c.nombre)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.brown.shade200.withValues(alpha: 0.6), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: Colors.brown)),
    );
  }

  Widget _speech(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.brown.shade200.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.brown.shade200.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Text(text,
          softWrap: true,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.brown)),
    );
  }

  Widget _cheeseChip(String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.local_pizza),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
            color: Colors.brown.shade200.withValues(alpha: 0.6), width: 1.6),
        foregroundColor: Colors.brown,
        backgroundColor: const Color(0xFFFFF8E7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
    );
  }
}
