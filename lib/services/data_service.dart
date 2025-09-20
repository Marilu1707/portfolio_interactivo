import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/cheese_stat.dart';
import '../models/cheese_rating.dart';
import '../models/inventory_item.dart';
import '../data/cheese_catalog.dart';

// Servicio de datos: carga archivos CSV desde assets.

class DataService {
  /// Carga los datos de consumo de quesos desde assets/data/cheese_consumption.csv
  static Future<List<CheeseStat>> loadCheeseStats() async {
    try {
      final raw = await rootBundle.loadString('assets/data/cheese_consumption.csv');
      final rows = const CsvToListConverter().convert(raw, eol: '\n');
      // Agrega participaciones por id normalizado y limita a kAllowedIds
      final Map<String, double> shareById = { for (final id in kAllowedIds) id: 0 };
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        final name = row[0].toString();
        final share = double.tryParse(row[1].toString()) ?? 0.0;
        final id = normalizeCheese(name);
        if (kAllowedIds.contains(id)) {
          shareById[id] = (shareById[id] ?? 0) + share;
        }
      }
      // Devuelve con nombres en español desde el catálogo
      final out = <CheeseStat>[];
      shareById.forEach((id, share) {
        final c = cheeseById(id);
        if (c != null) out.add(CheeseStat(name: c.nombre, share: share));
      });
      return out;
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando consumo: $e');
      return <CheeseStat>[];
    }
  }

  /// Carga ratings por queso (nombre, país, score)
  static Future<List<CheeseRating>> loadCheeseRatings() async {
    try {
      final raw = await rootBundle.loadString('assets/data/cheese_ratings.csv');
      final rows = const CsvToListConverter().convert(raw, eol: '\n');
      final Map<String, double> scoreById = {};
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        final name = row[0].toString();
        final score = double.tryParse(row[2].toString()) ?? 0.0;
        final id = normalizeCheese(name);
        if (kAllowedIds.contains(id)) {
          // promediado simple: si hay duplicados sumar (usamos score más alto)
          scoreById[id] = (scoreById[id] ?? 0.0).clamp(0, 10);
          if (score > (scoreById[id] ?? 0)) scoreById[id] = score;
        }
      }
      final out = <CheeseRating>[];
      scoreById.forEach((id, score) {
        final c = cheeseById(id);
        if (c != null) out.add(CheeseRating(name: c.nombre, country: c.pais, score: score));
      });
      return out;
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando ratings: $e');
      return <CheeseRating>[];
    }
  }

  /// Carga inventario con ID, nombre y fecha de caducidad (YYYY-MM-DD).
  /// El stock inicial se fija en 30 al parsear cada fila (ver InventoryItem.fromCsv).
  static Future<List<InventoryItem>> loadInventory() async {
    // Si existe CSV, lo ignoramos: inventario semilla fijo con 6 quesos
    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 365));
    final out = <InventoryItem>[];
    var id = 1;
    for (final c in kCheeses) {
      out.add(InventoryItem(
        id: id++,
        name: c.nombre,
        stock: 30,
        expiry: expiry,
        reorderPoint: 30,
      ));
    }
    return out;
  }

  // Utilidades para conteos/EDA con ids normalizados
  static List<String> mapPedidosToIds(List<String> pedidosRaw) {
    final ids = <String>[];
    for (final p in pedidosRaw) {
      final id = normalizeCheese(p);
      if (kAllowedIds.contains(id)) ids.add(id);
    }
    return ids;
  }

  static Map<String, int> countByCheese(List<String> ids) {
    final m = {for (final id in kAllowedIds) id: 0};
    for (final id in ids) {
      if (m.containsKey(id)) m[id] = (m[id] ?? 0) + 1;
    }
    return m;
  }

  static Map<String, int> scoreByCountry(List<String> ids) {
    final m = <String, int>{};
    for (final id in ids) {
      final c = cheeseById(id);
      if (c == null) continue;
      m[c.pais] = (m[c.pais] ?? 0) + 1;
    }
    return m;
  }
}
