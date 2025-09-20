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
import '../utils/kawaii_toast.dart';

// Pantalla Nivel 1 (Juego): simula pedidos y mide aciertos por queso.
class Level1GameScreen extends StatefulWidget {
  const Level1GameScreen({super.key});

  @override
  State<Level1GameScreen> createState() => _Level1GameScreenState();
}

class _Level1GameScreenState extends State<Level1GameScreen>
    with SingleTickerProviderStateMixin {
  // SingleTickerProvider permite animar el temporizador circular por pedido.
  static const Color bg = KawaiiTheme.bg;
  static const Color card = KawaiiTheme.card;

  final _rng = Random();
  List<CheeseStat> stats = [];
  bool loading = true;

  // Marcadores del juego en curso.
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

  // Timer por pedido: anima de 0→1 y dispara timeout.
  late final AnimationController _orderTimer; // 0→1
  final Duration orderDuration = const Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _init();
    // Cuenta regresiva global del nivel.
    _secondsLeft = _maxSeconds;
    _orderTimer = AnimationController(vsync: this, duration: orderDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _onOrderTimeout();
        }
      });
    // Timer global que controla el tiempo límite del nivel.
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
    // Lee métricas históricas y ordena por participación para ponderar pedidos.
    final data = await DataService.loadCheeseStats();
    data.sort((a, b) => b.share.compareTo(a.share));
    setState(() {
      stats = data;
      loading = false;
    });
    _nextOrder();
  }

  String _weightedOrder() {
    // Suma total de participación para seleccionar un queso proporcionalmente.
    final total = stats.fold<double>(0, (a, b) => a + b.share);
    var r = _rng.nextDouble() * total;
    for (final s in stats) {
      if (r < s.share) return s.name;
      r -= s.share;
    }
    return stats.isNotEmpty ? stats.last.name : 'Mozzarella';
  }

  // Selecciona el próximo pedido (ponderado por share) y bucket A/B
  void _nextOrder() {
    if (!mounted || stats.isEmpty) return;

    _orderTimer
      ..stop()
      ..reset();

    final orderName = _weightedOrder();
    final app = context.read<AppState>();
    final ordersState = context.read<OrdersState>();

    if (app.isOutOfStock(orderName)) {
      setState(() {
        score = score > 0 ? score - 1 : 0;
        streak = 0;
        feedback = 'Sin stock de $orderName… -1';
        currentOrder = null;
      });

      unawaited(ordersState.addRequest(orderName));
      _orderCount++;
      _miss++;

      KawaiiToast.show(
        context,
        'No queda $orderName. -1 punto y pasamos al siguiente pedido.',
        color: Colors.orange,
        icon: Icons.info_outline,
        duration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
        success: false,
      );

      if (_orderCount >= _maxOrders) {
        _finishLevel(reason: 'Se completaron las $_maxOrders órdenes (sin stock disponible)');
      } else {
        Future.delayed(const Duration(milliseconds: 750), () {
          if (mounted) _nextOrder();
        });
      }
      return;
    }

    setState(() {
      currentOrder = orderName;
      _currentBucket = _rng.nextBool() ? 'A' : 'B';
      feedback = null;
      _orderStart = DateTime.now();
    });
    _startOrderTimer();
  }

  void _startOrderTimer() {
    // Reinicia la animación para el temporizador circular.
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
      // Penalización similar a fallo para no dejar pedidos sin atender.
      score = score > 0 ? score - 5 : 0;
      streak = 0;
      feedback = 'Tiempo agotado';
      currentOrder = null;
    });

    // Registrar demanda y reducir stock porque el pedido se desperdició.
    unawaited(ordersState.addRequest(orderNow));
    app.restock(orderNow, -1); // -1 unidad

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

  void _onPickCheese(BuildContext context, String cheese) {
    if (currentOrder == null) return;
    final app = context.read<AppState>();
    final item = app.inventory[cheese];
    if (item == null || item.stock <= 0) {
      _handleNoStock(context, cheese);
      return;
    }

    final ok = app.tryServe(cheese);
    if (!ok) {
      _handleNoStock(context, cheese);
      return; // no evalúes el pedido
    }

    // Continúa con la evaluación asíncrona del pedido.
    unawaited(_serve(cheese));
  }

  void _handleNoStock(BuildContext context, String cheese) {
    if (currentOrder == null) return;
    final orderNow = currentOrder!;
    final ordersState = context.read<OrdersState>();

    setState(() {
      // Penaliza y pasa a la siguiente orden si no hay inventario.
      score = score > 0 ? score - 1 : 0;
      streak = 0;
      feedback = 'Sin stock de $cheese... -1';
      currentOrder = null;
    });

    KawaiiToast.show(
      context,
      'Ups... no queda $cheese. -1 punto y seguimos con el próximo pedido.',
      color: Colors.orange,
      icon: Icons.info_outline,
      duration: const Duration(seconds: 2),
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      success: false,
    );

    unawaited(ordersState.addRequest(orderNow));

    // Actualiza contadores globales de progreso.
    _orderCount++;
    _miss++;

    if (_orderCount >= _maxOrders) {
      _finishLevel(reason: 'Completaste las $_maxOrders órdenes');
    } else {
      Future.delayed(const Duration(milliseconds: 900), _nextOrder);
    }
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

    // Guarda la jugada para estadísticas globales y experimento A/B.
    app.recordServe(
      order: orderNow,
      chosen: chosen,
      isCorrect: isCorrect,
      bucketAB: _currentBucket ?? 'A',
    );
    if (!isCorrect) {
      app.restock(chosen, -1);
    }
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

    

    // Aprendizaje online (Nivel 4): registrar evento y actualizar modelo.
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
    // Detiene timers y muestra el resumen final.
    _orderTimer.stop();
    _levelTimer?.cancel();
    if (!mounted) return;
    final app = context.read<AppState>();
    final goalReached = _orderCount >= _maxOrders;
    if (goalReached) {
      app.markLevel1Cleared();
    }
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
              context.read<AppState>().setLevelCompleted(1);
              Navigator.pushNamed(context, '/level3');
            },
            child: const Text('Ir al Inventario'),
          ),
        ],
      ),
    );
  }

  void _restartLevel() {
    // Reinicia puntuaciones y contadores para comenzar de cero.
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
    final appState = context.watch<AppState>();
    final canProceed = appState.level1Cleared;
    final remainingOrders = (_maxOrders - _orderCount).clamp(0, _maxOrders);
    final String lockedMessage = remainingOrders > 0
        ? 'Jugá ${remainingOrders == 1 ? '1 pedido más' : '$remainingOrders pedidos más'} para desbloquear el Inventario. Mientras tanto, revisá el resumen en la EDA.'
        : 'Completá las $_maxOrders órdenes para habilitar el Inventario.';
    final orderDisplay = _orderCount + (currentOrder != null ? 1 : 0);
    final timeDisplay =
        '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}';
    final statsEntries = [
      MapEntry('Pedido', '$orderDisplay/$_maxOrders'),
      MapEntry('Tiempo', timeDisplay),
      MapEntry('Puntaje', '$score'),
      MapEntry('Racha', '$streak'),
    ];
    final inventoryValues = appState.inventory.values;
    final allOutOfStock =
        inventoryValues.isNotEmpty && inventoryValues.every((e) => e.stock <= 0);

    // Contenedor principal del nivel con tablero, pedidos y acciones.
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Nido Mozzarella'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Estado rápido del nivel: orden actual, tiempo, score.
                        _buildStatsOverview(context, statsEntries),
                        const SizedBox(height: 16),
                        // Muestra progreso global respecto a las 20 órdenes.
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
                          // Tarjeta principal del nivel con pedido activo.
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  'Nido Mozzarella',
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
                          // Listado de opciones de queso a elegir.
                          children: kCheeses
                              .map((c) => _cheeseChip(context, appState, c.nombre))
                              .toList(),
                        ),
                        if (allOutOfStock) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.inventory_2_outlined),
                              label: const Text(
                                  'No tenés más quesos → Ir a Inventario'),
                              onPressed: () => Navigator.pushNamed(context, '/level3'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<AppState>().setLevelCompleted(1);
                  if (canProceed) {
                    Navigator.pushNamed(context, '/level3');
                  } else {
                    Navigator.pushNamed(context, '/level2');
                  }
                },
                icon: Icon(
                  canProceed
                      ? Icons.inventory_2_outlined
                      : Icons.assessment_outlined,
                ),
                label: Text(canProceed ? 'Ir a Inventario' : 'Ir al resumen'),
                style: FilledButton.styleFrom(
                  backgroundColor: canProceed
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.8),
                  foregroundColor: canProceed
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                ),
              ),
            ),
            if (!canProceed) ...[
              const SizedBox(height: 8),
              Text(
                lockedMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
                softWrap: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(
      BuildContext context, List<MapEntry<String, String>> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = stats
            .map((entry) => _statCard(context, entry.key, entry.value))
            .toList();
        final spacing = 12.0;
        final available = constraints.maxWidth;
        final columns = available >= 640 ? 4 : 2;
        final tileWidth =
            ((available - spacing * (columns - 1)) / columns).clamp(140.0, available);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: cards
              .map((card) => SizedBox(width: tileWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final accent = Colors.brown;
    final baseColor = theme.colorScheme.surface;
    final cardColor = Color.lerp(baseColor, Colors.white, 0.2) ?? baseColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ) ??
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: accent,
                ) ??
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
          ),
        ],
      ),
    );
  }

  // (removido: _speech no se usa)

  Widget _cheeseChip(BuildContext context, AppState app, String cheese) {
    final outOfStock = app.isOutOfStock(cheese);
    final disabled = currentOrder == null;
    final border = Colors.brown.shade200
        .withValues(alpha: outOfStock ? 0.3 : 0.6);
    final textColor = outOfStock
        ? Colors.brown.withValues(alpha: 0.55)
        : Colors.brown;
    final iconColor = outOfStock
        ? Colors.brown.withValues(alpha: 0.45)
        : Colors.brown;
    final bgColor = outOfStock
        ? const Color(0xFFF4E6D8)
        : const Color(0xFFFFF8E7);

    // Cada chip representa un queso servible desde el inventario.
    return ActionChip(
      label: Text(
        cheese,
        style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      ),
      avatar: Text(
        '🧀',
        style: TextStyle(
          fontSize: 16,
          color: iconColor,
        ),
      ),
      onPressed: disabled ? null : () => _onPickCheese(context, cheese),
      backgroundColor: bgColor,
      shape: StadiumBorder(side: BorderSide(color: border, width: 1.4)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  Widget _buildOrderHeader() {
    return AnimatedBuilder(
      animation: _orderTimer,
      builder: (context, _) {
        final remaining = orderDuration * (1.0 - _orderTimer.value);
        final secs = (remaining.inMilliseconds / 1000).ceil();
        final color = secs <= 3 ? Colors.red : Colors.brown;
        // Cabecera con temporizador regresivo y pedido actual.
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
