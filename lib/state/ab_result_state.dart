import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ABResultState extends ChangeNotifier {
  static const _k = 'ab_last_result_v1_json';
  Map<String, dynamic>? last;

  Future<void> save(Map<String, dynamic> r) async {
    last = r;
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(r));
    notifyListeners();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_k);
    if (s == null || s.isEmpty) return;
    try {
      last = jsonDecode(s) as Map<String, dynamic>;
      notifyListeners();
    } catch (_) {
      // ignore malformed
    }
  }
}

