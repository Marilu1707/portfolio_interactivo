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

  // Progreso por nivel
  bool level1Cleared = false;

  // Puntajes base por queso para EDA (Nivel 2)
  // Nota: si tenés una fuente CSV, podés popular esto en el init.
  final Map<String, double> puntajeBase = const {
    'Parmesano': 4.6,
    'Brie': 3.9,
    'Gouda': 3.3,
    'Mozzarella': 3.8,
    'Cheddar': 3.5,
    'Azul': 3.2,
  };

  // A/B buckets (contadores de muestra y conversiones)
  int aN = 0, aConv = 0;
  int bN = 0, bConv = 0;

  // Variante activa del juego para A/B ("A" = control, "B" = tratamiento)
  String variante = 'A';

  // Tiempos por variante (ms) para métricas adicionales
  final List<int> tiemposA = [];
  final List<int> tiemposB = [];

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
    rounds.add(GameRound(
        order: order,
        chosen: chosen,
        bucket: bucketAB,
        isCorrect: isCorrect,
        ts: now));
    totalServed += 1;
    servedByCheese.update(chosen, (v) => v + 1, ifAbsent: () => 1);

    if (isCorrect) {
      correct += 1;
      final country = kCheeseCountryEs[chosen] ?? 'Otro';
      servedByCountry.update(country, (v) => v + 1, ifAbsent: () => 1);
    } else {
      wrong += 1;
    }

    if (bucketAB == 'A') {
      aN += 1;
      if (isCorrect) aConv += 1;
    } else {
      bN += 1;
      if (isCorrect) bConv += 1;
    }

    notifyListeners();
  }

  void markLevel1Cleared() {
    if (level1Cleared) return;
    level1Cleared = true;
    notifyListeners();
  }

  // ----- API alternativa para A/B solicitada en el brief -----
  // Equivalencias con contadores existentes (para no duplicar estado)
  int get usuariosA => aN;
  int get conversionesA => aConv;
  int get usuariosB => bN;
  int get conversionesB => bConv;

  void registrarUsuario() {
    if (variante == 'A') {
      aN += 1;
    } else {
      bN += 1;
    }
    notifyListeners();
  }

  void registrarConversion() {
    if (variante == 'A') {
      aConv += 1;
    } else {
      bConv += 1;
    }
    notifyListeners();
  }

  void registrarTiempoPedido(Duration t) {
    final ms = t.inMilliseconds;
    if (variante == 'A') {
      tiemposA.add(ms);
    } else {
      tiemposB.add(ms);
    }
    notifyListeners();
  }

  double tasaA() => usuariosA == 0 ? 0 : conversionesA / usuariosA;
  double tasaB() => usuariosB == 0 ? 0 : conversionesB / usuariosB;
  double promedioMsA() =>
      tiemposA.isEmpty ? 0 : tiemposA.reduce((a, b) => a + b) / tiemposA.length;
  double promedioMsB() =>
      tiemposB.isEmpty ? 0 : tiemposB.reduce((a, b) => a + b) / tiemposB.length;

  /// Usa stock cuando sale un queso del inventario.
  /// Si falló el pedido, contamos desperdicio y baja 2 unidades.
  void useCheese(String cheese, {required bool success}) {
    final item = inventory[cheese];
    if (item == null) {
      return;
    }
    final amount = success ? 1 : 2;
    item.stock = (item.stock - amount).clamp(0, 1 << 31);
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
  void setAbTestResult(
      {required double pC,
      required double pT,
      required double z,
      required double p}) {
    this.pC = pC;
    this.pT = pT;
    zScore = z;
    pValue = p;
    hasAb = true;
    notifyListeners();
  }

  // Tasa de acierto global
  double get accuracy => totalServed == 0 ? 0 : correct / totalServed;

  // Alias para compatibilidad con pantallas que esperan 'pedidosPorQueso'
  Map<String, int> get pedidosPorQueso => servedByCheese;

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
  GameRound(
      {required this.order,
      required this.chosen,
      required this.bucket,
      required this.isCorrect,
      required this.ts});
}

class CheeseCount {
  final String name;
  final int count;
  CheeseCount(this.name, this.count);
}
