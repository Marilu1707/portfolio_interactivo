import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple smoke checks that can be invoked manually from main()
/// to verify assets, preferences, and basic wiring on Web.
class Smoke {
  static Future<void> run() async {
    await _assets();
    await _prefs();
  }

  static Future<void> _assets() async {
    const assetPath = 'assets/img/raton_menu.png';
    try {
      final bytes = await rootBundle.load(assetPath);
      dev.log('SMOKE assets: $assetPath bytes=${bytes.lengthInBytes}', name: 'smoke');
    } catch (e) {
      dev.log('SMOKE assets: FAILED to load $assetPath: $e', name: 'smoke', level: 1000);
    }
  }

  static Future<void> _prefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      const k = 'smoke_pref_key';
      await sp.setInt(k, 42);
      final v = sp.getInt(k);
      dev.log('SMOKE prefs: value=$v', name: 'smoke');
    } catch (e) {
      dev.log('SMOKE prefs: FAILED: $e', name: 'smoke', level: 1000);
    }
  }
}

