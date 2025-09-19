import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersState extends ChangeNotifier {
  static const _kKeyPrefix = 'orders_counts';
  static const List<String> _defaultCheeses = [
    'Parmesano',
    'Brie',
    'Mozzarella',
    'Cheddar',
    'Gouda',
    'Azul',
  ];

  final Map<String, int> _counts = {
    for (final cheese in _defaultCheeses) cheese: 0,
  };

  Map<String, int> get counts => Map.unmodifiable(_counts);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final cheese in _counts.keys) {
      _counts[cheese] = prefs.getInt('$_kKeyPrefix:$cheese') ?? 0;
    }
    notifyListeners();
  }

  Future<void> addOrder(String cheese) async {
    if (!_counts.containsKey(cheese)) return;
    _counts[cheese] = (_counts[cheese] ?? 0) + 1;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _counts.entries) {
      await prefs.setInt('$_kKeyPrefix:${entry.key}', entry.value);
    }
  }

  Map<String, double> scores({int maxStars = 5}) {
    if (_counts.values.every((value) => value == 0)) {
      return _counts.map((key, value) => MapEntry(key, 0));
    }
    final maxCount = _counts.values.reduce((a, b) => a > b ? a : b);
    return _counts
        .map((key, value) => MapEntry(key, (value / maxCount) * maxStars));
  }
}
