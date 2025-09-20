import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cheese_stat.dart';
import '../services/data_service.dart';
import '../data/cheese_catalog.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';
import '../state/orders_state.dart';
import '../services/ml_service.dart';
import '../utils/popup.dart';

// Pantalla Nivel 1 (Juego): simula pedidos y mide aciertos por queso.
class Level1GameScreen extends StatefulWidget {
  const Level1GameScreen({super.key});

  @override
  State<Level1GameScreen> createState() => _Level1GameScreenState();
}

class _Level1GameScreenState extends State<Level1GameScreen>
    with SingleTickerProviderStateMixin {
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

  // --- Progreso / fin de nivel ---
  static const int _maxOrders = 20; // rondas por nivel
  static const int _maxSeconds = 60; // tiempo máximo opcional
  int _orderCount = 0;
  int _hits = 0;
  int _miss = 0;
  Timer? _levelTimer;
  late int _secondsLeft;

  // Timer por pedido
  late final AnimationController _orderTimer; // 0→1
  final Duration orderDuration = const Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _init();
    _secondsLeft = _maxSeconds;
    _orderTimer = AnimationController(vsync: this, duration: orderDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _onOrderTimeout();
        }
      });
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _finishLevel(reason: 'Tiempo agotado');
      }
    });
  }

  @override
  void dispose() {
    _levelTimer?.cancel();
    _orderTimer.dispose();
    super.dispose();
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
    _startOrderTimer();
  }

  void _startOrderTimer() {
    _orderTimer
      ..reset()
      ..forward();
  }

  void _onOrderTimeout() {
    if (currentOrder == null) return;
    final orderNow = currentOrder!;
    final app = context.read<AppState>();
    final ordersState = context.read<OrdersState>();

    setState(() {
      // penalización similar a fallo
      score = score > 0 ? score - 5 : 0;
      streak = 0;
      feedback = 'Tiempo agotado';
      currentOrder = null;
    });

    // registrar demanda, reducir 1 unidad del pedido (desperdicio)
    unawaited(ordersState.addRequest(orderNow));
    app.useCheese(orderNow, success: true); // -1 unidad

    // popup centrado
    try {
      // ignore: deprecated_member_use
      HapticFeedback.selectionClick();
    } catch (_) {}
    Popup.show(context,
        type: PopupType.warning,
        title: 'Tiempo agotado',
        message: 'Se desperdició 1 de $orderNow');

    Future.delayed(const Duration(milliseconds: 900), _nextOrder);
  }

  // Registra el servicio, actualiza puntaje/racha y notifica al AppState
  Future<void> _serve(String chosen) async {
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
    // Registrar demanda real (lo que pidió el ratón) y lo servido
    await ordersState.addRequest(orderNow);
    await ordersState.addServe(chosen);
    if (!mounted) return;

    if (isCorrect) {
      Popup.show(context,
          type: PopupType.success,
          title: '¡Pedido correcto!',
          message: '+${10 + 2 * (streak - 1)} puntos • -1 de $chosen');
    } else {
      Popup.show(context,
          type: PopupType.error,
          title: 'Ups… pedido incorrecto',
          message: 'Se desperdiciaron 2 de $chosen');
    }

    

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

    // contadores de progreso
    _orderCount++;
    if (isCorrect) {
      _hits++;
    } else {
      _miss++;
    }

    // ¿se llegó a la última ronda?
    if (_orderCount >= _maxOrders) {
      _finishLevel(reason: 'Completaste las $_maxOrders órdenes');
    } else {
      Future.delayed(const Duration(milliseconds: 900), _nextOrder);
    }
  }

  void _finishLevel({required String reason}) {
    _orderTimer.stop();
    _levelTimer?.cancel();
    if (!mounted) return;
    final total = _orderCount == 0 ? 1 : _orderCount;
    final acc = (_hits * 100 / total).toStringAsFixed(1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Nivel completado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reason),
            const SizedBox(height: 8),
            Text('Pedidos: \u2009$_orderCount'),
            Text('Aciertos: \u2009$_hits'),
            Text('Errores: \u2009$_miss'),
            Text('Tasa de acierto: \u2009$acc%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartLevel();
            },
            child: const Text('Reintentar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/level2');
            },
            child: const Text('Ir al Nivel 2'),
          ),
        ],
      ),
    );
  }

  void _restartLevel() {
    setState(() {
      score = 0;
      streak = 0;
      _orderCount = 0;
      _hits = 0;
      _miss = 0;
      _secondsLeft = _maxSeconds;
      currentOrder = null;
      feedback = null;
    });
    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) _finishLevel(reason: 'Tiempo agotado');
    });
    _nextOrder();
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
                            _pill('Pedido  ${_orderCount + (currentOrder != null ? 1 : 0)}/$_maxOrders'),
                            const SizedBox(width: 12),
                            _pill('Tiempo  ${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}'),
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _orderCount / _maxOrders,
                          backgroundColor: Colors.brown.withValues(alpha: .1),
                          color: const Color(0xFFFFD166),
                          minHeight: 6,
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
                                _buildOrderHeader(),
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

  // (removido: _speech no se usa)

  Widget _cheeseChip(String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: currentOrder == null ? null : onTap,
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

  Widget _buildOrderHeader() {
    return AnimatedBuilder(
      animation: _orderTimer,
      builder: (context, _) {
        final remaining = orderDuration * (1.0 - _orderTimer.value);
        final secs = (remaining.inMilliseconds / 1000).ceil();
        final color = secs <= 3 ? Colors.red : Colors.brown;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    value: 1.0 - _orderTimer.value,
                    strokeWidth: 4,
                    color: color,
                  ),
                ),
                Text('$secs', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
              ],
            ),
            const SizedBox(width: 8),
            if (currentOrder != null)
              Text('¡Quiero ${_esAr(currentOrder!)}!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.brown, fontWeight: FontWeight.w700)),
          ],
        );
      },
    );
  }
}
