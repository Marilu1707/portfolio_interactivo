// Modelo: ítem de inventario con stock y fecha de caducidad
class InventoryItem {
  final int id;
  final String name;
  int stock;
  DateTime expiry; // parsed from YYYY-MM-DD
  int reorderPoint;

  InventoryItem({
    required this.id,
    required this.name,
    required this.stock,
    required this.expiry,
    this.reorderPoint = 30,
  });

  /// Construye desde CSV [id, nombre, stock_ignorado, YYYY-MM-DD].
  /// Forzamos stock inicial = 30 (según requisitos de UX).
  factory InventoryItem.fromCsv(List<dynamic> row) {
    return InventoryItem(
      id: int.tryParse(row[0].toString()) ?? 0,
      name: row[1].toString(),
      // Arranca siempre con 30 unidades, ignorando el CSV
      stock: 30,
      expiry: DateTime.tryParse(row[3].toString()) ?? DateTime.now().add(const Duration(days: 365)),
      reorderPoint: 30,
    );
  }

  InventoryItem copyWith({
    int? stock,
    DateTime? expiry,
    int? reorderPoint,
  }) {
    return InventoryItem(
      id: id,
      name: name,
      stock: stock ?? this.stock,
      expiry: expiry ?? this.expiry,
      reorderPoint: reorderPoint ?? this.reorderPoint,
    );
  }
}
