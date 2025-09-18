import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

// Nivel 4 — A/B Test
// Calculadora de prueba Z para dos proporciones (control vs treatment).
// - Lee N y conversiones de cada grupo
// - Calcula tasas, Z-score y p-valor (bilateral)
// - Muestra si el resultado es significativo (p < 0.05)
class Level4AbTestScreen extends StatefulWidget {
  const Level4AbTestScreen({super.key});

  @override
  State<Level4AbTestScreen> createState() => _Level4AbTestScreenState();
}

class _Level4AbTestScreenState extends State<Level4AbTestScreen> {
  static const Color bg = Color(0xFFFFF9E8);
  static const Color accent = Color(0xFFFFE79A);
  static const Color onAccent = Color(0xFF5B4E2F);
  static const Color card = Colors.white;

  late final TextEditingController _nC;
  late final TextEditingController _xC;
  late final TextEditingController _nT;
  late final TextEditingController _xT;
  bool editarManual = false;

  AbResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState?>();
    _nC = TextEditingController(text: (app?.aN ?? 1).toString());
    _xC = TextEditingController(text: (app?.aConv ?? 0).toString());
    _nT = TextEditingController(text: (app?.bN ?? 1).toString());
    _xT = TextEditingController(text: (app?.bConv ?? 0).toString());
  }

  @override
  void dispose() {
    _nC.dispose();
    _xC.dispose();
    _nT.dispose();
    _xT.dispose();
    super.dispose();
  }

  // Completa inputs con los valores globales del juego (si no se edita manualmente)
  void _prefill(AppState app) {
    _nC.text = app.aN.toString();
    _xC.text = app.aConv.toString();
    _nT.text = app.bN.toString();
    _xT.text = app.bConv.toString();
  }

  // Parse seguro de enteros (tolera puntos y comas). Devuelve 0 si falla.
  int _pInt(String s) {
    final t = s.trim().replaceAll('.', '').replaceAll(',', '.');
    final v = int.tryParse(t) ?? 0;
    return v < 0 ? 0 : v;
  }

  // Calcula el test Z para dos proporciones y retorna resultado estructurado
  AbResult computeAB(int nC, int xC, int nT, int xT) {
    if (nC <= 0 || nT <= 0) return const AbResult(0, 0, 0, 1, false, false);
    final pC = (xC / nC).clamp(0.0, 1.0);
    final pT = (xT / nT).clamp(0.0, 1.0);
    final pPool = ((xC + xT) / (nC + nT)).clamp(0.0, 1.0);
    final se = math.sqrt((pPool * (1 - pPool)) * (1 / nC + 1 / nT));
    if (se == 0 || se.isNaN || se.isInfinite) {
      return const AbResult(0, 0, 0, 1, false, false);
    }
    final z = (pT - pC) / se;
    final p = 2 * (1 - _phiStd(z.abs())); // p-valor bilateral
    final isSig = p < 0.05;
    return AbResult(pC, pT, z, p, isSig, pT > pC);
  }

  // CDF de la normal estándar (Phi) usando erf: precisa y estable
  double _phiStd(double z) => 0.5 * (1 + _erf(z / _sqrt2));

  // Aproximación clásica de erf (Abramowitz & Stegun 7.1.26)
  double _erf(double x) {
    const p = 0.3275911;
    const a1 = 0.254829592, a2 = -0.284496736, a3 = 1.421413741,
        a4 = -1.453152027, a5 = 1.061405429;
    final sign = x < 0 ? -1.0 : 1.0;
    final ax = x.abs();
    final t = 1.0 / (1.0 + p * ax);
    final y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-ax * ax);
    return sign * y;
  }

  static const double _sqrt2 = 1.41421356237;

  // Handler del botón Calcular: valida inputs, computa y actualiza estado
  void _onCalc() {
    try {
      final app = context.read<AppState>();
      if (!editarManual) _prefill(app);

      final nC = _pInt(_nC.text);
      final xC = _pInt(_xC.text);
      final nT = _pInt(_nT.text);
      final xT = _pInt(_xT.text);

      if (nC <= 0 || nT <= 0) {
        setState(() { _error = 'N debe ser mayor a 0 en ambos grupos.'; _result = null; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('N debe ser mayor a 0 en ambos grupos.')),
        );
        return;
      }
      if (xC > nC || xT > nT) {
        setState(() { _error = 'Las conversiones no pueden superar N.'; _result = null; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las conversiones no pueden superar N.')),
        );
        return;
      }

      final res = computeAB(nC, xC, nT, xT);
      app.setAbTestResult(pC: res.pC, pT: res.pT, z: res.z, p: res.pValue);
      setState(() { _error = null; _result = res; });
    } catch (e) {
      setState(() { _error = 'Error inesperado al calcular: $e'; _result = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado al calcular: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!editarManual && (_nC.text.isEmpty && _nT.text.isEmpty)) {
      _prefill(app);
    }
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text('Nivel 4 - A/B Test 🧪'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Card de inputs
                  Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.brown.shade200.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'A/B Test',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.brown),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: '¿Cómo funciona?',
                              onPressed: _showAbHelp,
                              icon: const Icon(Icons.info_outline, color: Colors.brown),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Comparamos la tasa de conversión entre Control (A) y Treatment (B) usando prueba Z para dos proporciones (bilateral).',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _L4ColumnCard(
                                title: 'Control (A)',
                                fields: [
                                  _L4Field(controller: _nC, label: 'N usuarios', readOnly: !editarManual),
                                  _L4Field(controller: _xC, label: 'Conversiones', readOnly: !editarManual),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _L4ColumnCard(
                                title: 'Treatment (B)',
                                fields: [
                                  _L4Field(controller: _nT, label: 'N usuarios', readOnly: !editarManual),
                                  _L4Field(controller: _xT, label: 'Conversiones', readOnly: !editarManual),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _onCalc,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: onAccent,
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.brown.shade300, width: 1.8),
                            ),
                          ),
                          child: const Text('Calcular Z y p-valor', softWrap: true, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mensajes de error o resultados
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ] else if (_result != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.brown.shade200.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.shade200.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset('assets/img/ab_mouse.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 6,
                                  children: [
                                    _kv('Tasa de conversión',
                                        'Control ${(_result!.pC * 100).toStringAsFixed(1)}% - '
                                        'Treatment ${(_result!.pT * 100).toStringAsFixed(1)}%'),
                                    _kv('Z', _result!.z.toStringAsFixed(2)),
                                    _kv('p-valor', _result!.pValue.toStringAsFixed(3)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _result!.isSignificant
                                      ? (_result!.treatmentWins
                                          ? '✅ Significativo, Treatment gana'
                                          : '✅ Significativo, Control gana')
                                      : '❌ No significativo',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.brown),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 16),

                  // Acciones inferiores
                  Row(
                    children: [
                      Switch(value: editarManual, onChanged: (v) => setState(() => editarManual = v)),
                      const SizedBox(width: 8),
                      const Text('Editar manual'),
                      const Spacer(),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Final: Dashboard'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.brown.shade300, width: 2),
                            foregroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Renderiza un par clave-valor en una sola línea
  Widget _kv(String k, String v) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k  ', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.brown)),
        Text(v),
      ],
    );
  }

  // Diálogo de ayuda con la fórmula del test Z de dos proporciones
  void _showAbHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda A/B (Z para dos proporciones)'),
        content: const SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• p_C = x_C / n_C, p_T = x_T / n_T'),
              Text('• p^ = (x_C + x_T) / (n_C + n_T) (pooling)'),
              Text('• SE = sqrt(p^(1 - p^) * (1/n_C + 1/n_T))'),
              Text('• Z = (p_T - p_C) / SE'),
              SizedBox(height: 8),
              Text('Prueba bilateral: p = 2 · (1 - Φ(|Z|)). Si p < 0.05, es significativo.'),
              SizedBox(height: 6),
              Text('Supuestos: muestras independientes y n grandes (aprox. normal).'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

// Tarjeta reutilizable de inputs para cada grupo (A o B)
class _L4ColumnCard extends StatelessWidget {
  final String title;
  final List<_L4Field> fields;
  const _L4ColumnCard({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade200.withValues(alpha: 0.6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.brown)),
          const SizedBox(height: 10),
          ...fields.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: f)),
        ],
      ),
    );
  }
}

// TextField estilizado (solo números) con soporte de solo-lectura
class _L4Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  const _L4Field({required this.controller, required this.label, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.brown.shade200.withValues(alpha: 0.8), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.brown.shade400, width: 2),
        ),
      ),
    );
  }
}

// Estructura con los resultados del A/B
class AbResult {
  final double pC, pT, z, pValue;
  final bool isSignificant, treatmentWins;
  const AbResult(this.pC, this.pT, this.z, this.pValue, this.isSignificant, this.treatmentWins);
}

