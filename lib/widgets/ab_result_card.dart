import 'package:flutter/material.dart';

import '../models/ab_test_result.dart';
import 'kawaii_card.dart';

class AbResultCard extends StatelessWidget {
  final AbTestResult result;

  const AbResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final diff = result.diff;
    final lift = result.lift;
    final confiable = result.pValue < result.alpha;
    final confPct = ((1 - result.alpha) * 100).toStringAsFixed(0);

    return KawaiiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A/B Test — Resumen',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _kv('Conversión A (Control)', _pct(result.pControl)),
          _kv('Conversión B (Tratamiento)', _pct(result.pTreatment)),
          const Divider(height: 24),
          _kv('Diferencia de conversión (B–A)', _pct(diff, signed: true)),
          _kv(
            'Mejora relativa vs A',
            lift.isFinite && !lift.isNaN ? _pct(lift, signed: true) : '—',
          ),
          _kv(
            'Rango esperado de la diferencia ($confPct%)',
            '${_pct(result.ciLow)}  a  ${_pct(result.ciHigh)}',
          ),
          _kv('Probabilidad de azar', _prob(result.pValue)),
          _kv('Intensidad de la diferencia', result.zScore.toStringAsFixed(2)),
          _kv('¿Resultado confiable al $confPct%?', confiable ? 'Sí' : 'No'),
        ],
      ),
    );
  }

  static Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(k)),
          Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static String _pct(double x, {bool signed = false}) {
    final v = (x * 100);
    if (v.isNaN) return '—';
    final formatted = '${v.toStringAsFixed(1)}%';
    if (!signed) return formatted;
    return v > 0 ? '+$formatted' : formatted;
  }

  static String _prob(double p) {
    if (p.isNaN) return '—';
    if (p < 0.001) return '< 0.1%';
    return '${(p * 100).toStringAsFixed(2)}%';
  }
}
