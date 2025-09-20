import 'dart:math';

class Features {
  static const _cheeses = [
    'Mozzarella',
    'Cheddar',
    'Provolone',
    'Gouda',
    'Brie',
    'Azul',
  ];

  static int get dimension => 8 + _cheeses.length;

  /// Build the 14-dim feature vector described in the brief.
  static List<double> build({
    required int streak,
    required double avgMs,
    required int hour,
    required double stock,
    required String cheese,
    double recentWinRateForCheese = 0.5,
    bool wastePenalty = false,
  }) {
    final st = streak.clamp(0, 5).toDouble();
    final ms = log(1 + max(0.0, avgMs));
    final hsin = sin(2 * pi * (hour % 24) / 24);
    final hcos = cos(2 * pi * (hour % 24) / 24);
    final s = (stock / 20.0).clamp(0.0, 1.0);

    final oneHot = _cheeses.map((c) => c == cheese ? 1.0 : 0.0).toList();

    return [
      1.0, // bias
      st,
      ms,
      hsin,
      hcos,
      s,
      recentWinRateForCheese,
      wastePenalty ? 1.0 : 0.0,
      ...oneHot,
    ];
  }
}
