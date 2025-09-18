import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../data/cheese_country_es.dart';

// Estado global de la app: puntajes del juego, inventario y resultados de A/B.

class AppState extends ChangeNotifier {
  // Rondas y conteos
  final List<GameRound> rounds = [];
  final Map<String, int> servedByCheese = {};
  final Map<String, int> servedByCountry = {
    for (final c in kCountriesEs) c: 0,
  };
  int totalServed = 0;
  int correct = 0;
  int wrong = 0;

  // A/B buckets (contadores de muestra y conversiones)
  int aN = 0, aConv = 0;
  int bN = 0, bConv = 0;

  // Inventario en memoria (clave = nombre)
  final Map<String, InventoryItem> inventory = {};

  // Resultado A/B para dashboard
  double? pC, pT, zScore, pValue;
  bool hasAb = false;

  // Carga inventario inicial desde CSV
  void initInventory(List<InventoryItem> seed) {
    inventory.clear();
    for (final it in seed) {
      inventory[it.name] = it;
    }
    notifyListeners();
  }

  // Registra un servicio/jugada y actualiza métricas y buckets A/B.
  void recordServe({
    required String order,
    required String chosen,
    required bool isCorrect,
    required String bucketAB, // "A" o "B"
  }) {
    final now = DateTime.now();
    rounds.add(GameRound(order: order, chosen: chosen, bucket: bucketAB, isCorrect: isCorrect, ts: now));
    totalServed += 1;
    servedByCheese.update(chosen, (v) => v + 1, ifAbsent: () => 1);

    if (isCorrect) {
      correct += 1;
      final country = kCheeseCountryEs[chosen] ?? 'Otro';
      servedByCountry.update(country, (v) => v + 1, ifAbsent: () => 1);
      final item = inventory[chosen];
      if (item != null) {
        item.stock = (item.stock - 1).clamp(0, 1 << 31);
      }
    } else {
      wrong += 1;
    }

    if (bucketAB == 'A') {
      aN += 1; if (isCorrect) aConv += 1;
    } else {
      bN += 1; if (isCorrect) bConv += 1;
    }

    notifyListeners();
  }

  // Repone stock de un queso (si existe)
  void restock(String cheese, int qty) {
    if (qty == 0) return;
    final item = inventory[cheese];
    if (item != null) {
      item.stock += qty;
      notifyListeners();
    }
  }

  // Setea resultado del A/B para el dashboard
  void setAbTestResult({required double pC, required double pT, required double z, required double p}) {
    this.pC = pC; this.pT = pT; zScore = z; pValue = p; hasAb = true; notifyListeners();
  }

  // Tasa de acierto global
  double get accuracy => totalServed == 0 ? 0 : correct / totalServed;

  // Top K quesos por cantidad servida
  List<CheeseCount> topCheeses(int k) {
    final list = servedByCheese.entries
        .map((e) => CheeseCount(e.key, e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list.take(k).toList();
  }

  // Top K países por cantidad servida
  List<MapEntry<String, int>> topCountries([int k = 5]) {
    final list = servedByCountry.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list.take(k).toList();
  }
}

class GameRound {
  final String order;
  final String chosen;
  final String bucket;
  final bool isCorrect;
  final DateTime ts;
  GameRound({required this.order, required this.chosen, required this.bucket, required this.isCorrect, required this.ts});
}

class CheeseCount {
  final String name;
  final int count;
  CheeseCount(this.name, this.count);
}
