import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ab_test_result.dart';

class ABResultState extends ChangeNotifier {
  static const _k = 'ab_last_result_v1_json';
  AbTestResult? last;

  Future<void> save(AbTestResult r) async {
    last = r;
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, r.encode());
    notifyListeners();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_k);
    if (s == null || s.isEmpty) return;
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) {
        last = AbTestResult.fromJson(decoded);
      }
      notifyListeners();
    } catch (_) {
      // ignore malformed
    }
  }
}

