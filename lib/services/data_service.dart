import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/cheese_stat.dart';
import '../models/cheese_rating.dart';
import '../models/inventory_item.dart';

// Servicio de datos: carga archivos CSV desde assets.

class DataService {
  /// Carga los datos de consumo de quesos desde assets/data/cheese_consumption.csv
  static Future<List<CheeseStat>> loadCheeseStats() async {
    try {
      final raw = await rootBundle.loadString('assets/data/cheese_consumption.csv');
      final rows = const CsvToListConverter().convert(raw, eol: '\n');
      final out = <CheeseStat>[];
      for (var i = 1; i < rows.length; i++) {
        out.add(CheeseStat.fromCsv(rows[i]));
      }
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
      final out = <CheeseRating>[];
      for (var i = 1; i < rows.length; i++) {
        out.add(CheeseRating.fromCsv(rows[i]));
      }
      return out;
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando ratings: $e');
      return <CheeseRating>[];
    }
  }

  /// Carga inventario con ID, nombre y fecha de caducidad (YYYY-MM-DD).
  /// El stock inicial se fija en 10 al parsear cada fila (ver InventoryItem.fromCsv).
  static Future<List<InventoryItem>> loadInventory() async {
    try {
      final raw = await rootBundle.loadString('assets/data/cheese_inventory.csv');
      final rows = const CsvToListConverter().convert(raw, eol: '\n');
      final out = <InventoryItem>[];
      for (var i = 1; i < rows.length; i++) {
        out.add(InventoryItem.fromCsv(rows[i]));
      }
      return out;
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando inventario: $e');
      return <InventoryItem>[];
    }
  }
}
