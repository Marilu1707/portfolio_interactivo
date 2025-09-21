import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersState extends ChangeNotifier {
  static const _kKeyReq = 'orders_requested';
  static const _kKeySrv = 'orders_served';
  static const _kLegacyKey = 'orders_counts';

  static const List<String> _defaultCheeses = [
    'Provolone',
    'Brie',
    'Mozzarella',
    'Cheddar',
    'Gouda',
    'Parmesano',
  ];

  final Map<String, int> _requested = {
    for (final cheese in _defaultCheeses) cheese: 0,
  };
  final Map<String, int> _served = {
    for (final cheese in _defaultCheeses) cheese: 0,
  };

  Map<String, int> get requestedByCheese => Map.unmodifiable(_requested);
  Map<String, int> get servedByCheese => Map.unmodifiable(_served);

  // Back-compat: some code may still read `counts` as demand
  Map<String, int> get counts => requestedByCheese;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Load requested/served if present
    for (final cheese in _defaultCheeses) {
      _requested[cheese] = prefs.getInt('$_kKeyReq:$cheese') ?? 0;
      _served[cheese] = prefs.getInt('$_kKeySrv:$cheese') ?? 0;
    }

    // Migrar datos legacy (Parmesano → Provolone, Blue → Parmesano)
    final legacyParmesanoReq = prefs.getInt('$_kKeyReq:Parmesano') ?? 0;
    final legacyParmesanoSrv = prefs.getInt('$_kKeySrv:Parmesano') ?? 0;
    if (legacyParmesanoReq > 0) {
      _requested['Provolone'] = (_requested['Provolone'] ?? 0) + legacyParmesanoReq;
      await prefs.remove('$_kKeyReq:Parmesano');
    }
    if (legacyParmesanoSrv > 0) {
      _served['Provolone'] = (_served['Provolone'] ?? 0) + legacyParmesanoSrv;
      await prefs.remove('$_kKeySrv:Parmesano');
    }
    final legacyBlueReq = prefs.getInt('$_kKeyReq:Blue') ?? 0;
    final legacyBlueSrv = prefs.getInt('$_kKeySrv:Blue') ?? 0;
    if (legacyBlueReq > 0) {
      _requested['Parmesano'] = (_requested['Parmesano'] ?? 0) + legacyBlueReq;
      await prefs.remove('$_kKeyReq:Blue');
    }
    if (legacyBlueSrv > 0) {
      _served['Parmesano'] = (_served['Parmesano'] ?? 0) + legacyBlueSrv;
      await prefs.remove('$_kKeySrv:Blue');
    }
    // Migrate legacy `_counts` (served) if both maps are empty
    final legacySum = _defaultCheeses
        .map((c) => prefs.getInt('$_kLegacyKey:$c') ?? 0)
        .fold<int>(0, (a, b) => a + b);
    final reqSum = _requested.values.fold<int>(0, (a, b) => a + b);
    final srvSum = _served.values.fold<int>(0, (a, b) => a + b);
    if (legacySum > 0 && reqSum == 0 && srvSum == 0) {
      for (final cheese in _defaultCheeses) {
        final v = prefs.getInt('$_kLegacyKey:$cheese') ?? 0;
        _served[cheese] = v;
      }
      await _saveServed();
    }
    notifyListeners();
  }

  Future<void> addRequest(String cheese) async {
    if (!_requested.containsKey(cheese)) return;
    _requested[cheese] = (_requested[cheese] ?? 0) + 1;
    await _saveRequested();
    notifyListeners();
  }

  Future<void> addServe(String cheese) async {
    if (!_served.containsKey(cheese)) return;
    _served[cheese] = (_served[cheese] ?? 0) + 1;
    await _saveServed();
    notifyListeners();
  }

  // Back-compat: treat `addOrder` as a served event
  Future<void> addOrder(String cheese) => addServe(cheese);

  Future<void> _saveRequested() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _requested.entries) {
      await prefs.setInt('$_kKeyReq:${entry.key}', entry.value);
    }
  }

  Future<void> _saveServed() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _served.entries) {
      await prefs.setInt('$_kKeySrv:${entry.key}', entry.value);
    }
  }

  int get totalRequested =>
      _requested.values.fold<int>(0, (a, b) => a + b);
  int get totalServed => _served.values.fold<int>(0, (a, b) => a + b);

  Map<String, double> scores({int maxStars = 5}) {
    // Compute stars from requested (demand)
    if (_requested.values.every((value) => value == 0)) {
      return _requested.map((key, value) => MapEntry(key, 0));
    }
    final maxCount = _requested.values.reduce((a, b) => a > b ? a : b);
    return _requested
        .map((key, value) => MapEntry(key, (value / maxCount) * maxStars));
  }
}
