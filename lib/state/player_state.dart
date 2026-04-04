import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste el nombre del jugador y su historial acumulado entre sesiones.
class PlayerState extends ChangeNotifier {
  static const _kName = 'player_name';
  static const _kTotalScore = 'total_score';
  static const _kTotalOrders = 'total_orders';
  static const _kOrdersByCheese = 'orders_by_cheese';
  static const _kAvgResponseMs = 'avg_response_ms';
  static const _kLastPlayed = 'last_played';
  static const _kStreak = 'streak';

  String _playerName = '';
  int _totalScore = 0;
  int _totalOrders = 0;
  Map<String, int> _ordersByCheese = {};
  double _avgResponseMs = 6000;
  DateTime? _lastPlayed;
  int _streak = 0;

  String get playerName => _playerName;
  bool get hasPlayer => _playerName.isNotEmpty;
  int get totalScore => _totalScore;
  int get totalOrders => _totalOrders;
  Map<String, int> get ordersByCheese => Map.unmodifiable(_ordersByCheese);
  double get avgResponseMs => _avgResponseMs;
  DateTime? get lastPlayed => _lastPlayed;
  int get streak => _streak;

  String? get topCheese {
    if (_ordersByCheese.isEmpty) return null;
    return _ordersByCheese.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _playerName = prefs.getString(_kName) ?? '';
    _totalScore = prefs.getInt(_kTotalScore) ?? 0;
    _totalOrders = prefs.getInt(_kTotalOrders) ?? 0;
    _avgResponseMs = prefs.getDouble(_kAvgResponseMs) ?? 6000;
    _streak = prefs.getInt(_kStreak) ?? 0;
    final raw = prefs.getString(_kOrdersByCheese);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _ordersByCheese = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {
        _ordersByCheese = {};
      }
    }
    final lastStr = prefs.getString(_kLastPlayed);
    if (lastStr != null) {
      _lastPlayed = DateTime.tryParse(lastStr);
    }
    notifyListeners();
  }

  Future<void> setName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _playerName = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, trimmed);
    notifyListeners();
  }

  Future<void> recordGameSession({
    required int sessionScore,
    required int sessionOrders,
    required Map<String, int> cheeseMap,
    required double sessionAvgMs,
    required int sessionStreak,
  }) async {
    if (sessionOrders <= 0) return;
    final prevOrders = _totalOrders;
    _totalScore += sessionScore;
    _totalOrders += sessionOrders;
    for (final entry in cheeseMap.entries) {
      _ordersByCheese[entry.key] = (_ordersByCheese[entry.key] ?? 0) + entry.value;
    }
    if (_totalOrders > 0) {
      _avgResponseMs =
          (_avgResponseMs * prevOrders + sessionAvgMs * sessionOrders) /
              _totalOrders;
    }
    _streak = sessionStreak;
    _lastPlayed = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_kTotalScore, _totalScore),
      prefs.setInt(_kTotalOrders, _totalOrders),
      prefs.setDouble(_kAvgResponseMs, _avgResponseMs),
      prefs.setInt(_kStreak, _streak),
      prefs.setString(_kLastPlayed, _lastPlayed!.toIso8601String()),
      prefs.setString(_kOrdersByCheese, jsonEncode(_ordersByCheese)),
    ]);
    notifyListeners();
  }

  Future<void> logout() async {
    _playerName = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kName);
    notifyListeners();
  }
}
