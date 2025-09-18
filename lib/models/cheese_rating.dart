// Modelo: rating de queso (nombre, país y puntaje promedio)
class CheeseRating {
  final String name;
  final String country;
  final double score;

  CheeseRating({required this.name, required this.country, required this.score});

  /// Crea un rating a partir de una fila CSV [nombre, país, score]
  factory CheeseRating.fromCsv(List<dynamic> row) {
    return CheeseRating(
      name: row[0].toString(),
      country: row[1].toString(),
      score: double.tryParse(row[2].toString()) ?? 0,
    );
  }
}
