// Modelo: participación (%) estimada de cada queso en consumo
class CheeseStat {
  final String name;
  final double share;

  CheeseStat({required this.name, required this.share});

  /// Crea una estadística desde CSV [nombre, share%]
  factory CheeseStat.fromCsv(List<dynamic> row) {
    return CheeseStat(
      name: row[0].toString(),
      share: double.tryParse(row[1].toString()) ?? 0.0,
    );
  }
}
