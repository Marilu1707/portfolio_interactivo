import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../ml/online_logreg.dart';
import '../ml/features.dart';

class EventRow {
  final int streak;
  final double avgMs;
  final int hour;
  final double stock;
  final String cheese; // shown/offered
  final int converted; // 1/0
  final bool wastePenalty;

  EventRow({
    required this.streak,
    required this.avgMs,
    required this.hour,
    required this.stock,
    required this.cheese,
    required this.converted,
    this.wastePenalty = false,
  });

  Map<String, dynamic> toJson() => {
        'streak': streak,
        'avgMs': avgMs,
        'hour': hour,
        'stock': stock,
        'cheese': cheese,
        'converted': converted,
        'wastePenalty': wastePenalty,
      };

  static EventRow fromJson(Map<String, dynamic> m) => EventRow(
        streak: (m['streak'] ?? 0) as int,
        avgMs: ((m['avgMs'] ?? 0) as num).toDouble(),
        hour: (m['hour'] ?? 0) as int,
        stock: ((m['stock'] ?? 0) as num).toDouble(),
        cheese: (m['cheese'] ?? 'Mozzarella') as String,
        converted: (m['converted'] ?? 0) as int,
        wastePenalty: (m['wastePenalty'] ?? false) as bool,
      );
}

class MlService {
  MlService._();
  static final MlService instance = MlService._();
  static const _key = 'ml_events_v1';

  final OnlineLogReg model = OnlineLogReg(Features.dimension, lr: 0.05, l2: 1e-4);
  final List<EventRow> _events = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final List<dynamic> arr = jsonDecode(raw) as List<dynamic>;
      _events
        ..clear()
        ..addAll(arr.map(
            (e) => EventRow.fromJson(Map<String, dynamic>.from(e as Map))));
      // Rebuild model by replaying updates
      for (final ev in _events) {
        final x = Features.build(
          streak: ev.streak,
          avgMs: ev.avgMs,
          hour: ev.hour,
          stock: ev.stock,
          cheese: ev.cheese,
          wastePenalty: ev.wastePenalty,
        );
        model.update(x, ev.converted);
      }
    } catch (_) {
      // ignore malformed
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_events.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  /// Choose best cheese given context (greedy by predicted prob).
  String suggest({
    required int streak,
    required double avgMs,
    required int hour,
    required double stock,
    bool wastePenalty = false,
  }) {
    const cheeses = [
      'Mozzarella',
      'Cheddar',
      'Provolone',
      'Gouda',
      'Brie',
      'Azul',
    ];
    double best = -1;
    String bestC = cheeses.first;
    for (final c in cheeses) {
      final x = Features.build(
        streak: streak,
        avgMs: avgMs,
        hour: hour,
        stock: stock,
        cheese: c,
        wastePenalty: wastePenalty,
      );
      final p = model.predictProba(x);
      if (p > best) {
        best = p;
        bestC = c;
      }
    }
    return bestC;
  }

  double predictProba({
    required int streak,
    required double avgMs,
    required int hour,
    required double stock,
    required String cheese,
    bool wastePenalty = false,
  }) {
    final x = Features.build(
      streak: streak,
      avgMs: avgMs,
      hour: hour,
      stock: stock,
      cheese: cheese,
      wastePenalty: wastePenalty,
    );
    return model.predictProba(x);
  }

  Future<void> learn({
    required int streak,
    required double avgMs,
    required int hour,
    required double stock,
    required String cheeseShown,
    required int converted,
    bool wastePenalty = false,
  }) async {
    final x = Features.build(
      streak: streak,
      avgMs: avgMs,
      hour: hour,
      stock: stock,
      cheese: cheeseShown,
      wastePenalty: wastePenalty,
    );
    model.update(x, converted);
    _events.add(EventRow(
      streak: streak,
      avgMs: avgMs,
      hour: hour,
      stock: stock,
      cheese: cheeseShown,
      converted: converted,
      wastePenalty: wastePenalty,
    ));
    await _persist();
  }
}
