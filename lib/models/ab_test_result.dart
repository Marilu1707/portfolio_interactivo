import 'dart:convert';

class AbTestResult {
  final int nControl;
  final int convControl;
  final int nTreatment;
  final int convTreatment;
  final double pControl;
  final double pTreatment;
  final double diff;
  final double lift;
  final double zScore;
  final double pValue;
  final double ciLow;
  final double ciHigh;
  final double alpha;
  final bool significant;
  final DateTime timestamp;

  const AbTestResult({
    required this.nControl,
    required this.convControl,
    required this.nTreatment,
    required this.convTreatment,
    required this.pControl,
    required this.pTreatment,
    required this.diff,
    required this.lift,
    required this.zScore,
    required this.pValue,
    required this.ciLow,
    required this.ciHigh,
    required this.alpha,
    required this.significant,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'nControl': nControl,
        'convControl': convControl,
        'nTreatment': nTreatment,
        'convTreatment': convTreatment,
        'pControl': pControl,
        'pTreatment': pTreatment,
        'diff': diff,
        'lift': lift,
        'zScore': zScore,
        'pValue': pValue,
        'ciLow': ciLow,
        'ciHigh': ciHigh,
        'alpha': alpha,
        'significant': significant,
        'timestamp': timestamp.toIso8601String(),
      };

  String encode() => jsonEncode(toJson());

  factory AbTestResult.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      final lower = value?.toString().toLowerCase();
      if (lower == null) return false;
      return lower == 'true' || lower == 'sí' || lower == 'si';
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll('%', '').replaceAll(',', '.');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    final ciRaw = json['ci']?.toString();
    double? parsedCiLow;
    double? parsedCiHigh;
    if (ciRaw != null && ciRaw.isNotEmpty) {
      final sanitized = ciRaw.replaceAll('[', '').replaceAll(']', '');
      final parts = sanitized.split(',');
      if (parts.isNotEmpty) parsedCiLow = parseDouble(parts.first.trim());
      if (parts.length > 1) parsedCiHigh = parseDouble(parts.last.trim());
    }

    return AbTestResult(
      nControl: parseInt(json['nControl'] ?? json['nA']),
      convControl: parseInt(json['convControl'] ?? json['cA']),
      nTreatment: parseInt(json['nTreatment'] ?? json['nB']),
      convTreatment: parseInt(json['convTreatment'] ?? json['cB']),
      pControl: parseDouble(json['pControl'] ?? json['pA']),
      pTreatment: parseDouble(json['pTreatment'] ?? json['pB']),
      diff: parseDouble(json['diff']),
      lift: parseDouble(json['lift']),
      zScore: parseDouble(json['zScore'] ?? json['z']),
      pValue: parseDouble(json['pValue'] ?? json['p']),
      ciLow: parseDouble(json['ciLow']) == 0.0 && parsedCiLow != null
          ? parsedCiLow
          : parseDouble(json['ciLow'] ?? parsedCiLow),
      ciHigh: parseDouble(json['ciHigh']) == 0.0 && parsedCiHigh != null
          ? parsedCiHigh
          : parseDouble(json['ciHigh'] ?? parsedCiHigh),
      alpha: parseDouble(json['alpha'] ?? 0.05),
      significant: parseBool(json['significant'] ?? json['sig']),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
