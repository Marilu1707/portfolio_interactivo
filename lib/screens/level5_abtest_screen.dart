import 'dart:math' as math;
import 'package:flutter/material.dart';

class Level5AbTestScreen extends StatefulWidget {
  const Level5AbTestScreen({super.key});

  @override
  State<Level5AbTestScreen> createState() => _Level5AbTestScreenState();
}

class _Level5AbTestScreenState extends State<Level5AbTestScreen> {
  final _cNController = TextEditingController(text: '100');
  final _cXController = TextEditingController(text: '25');
  final _tNController = TextEditingController(text: '100');
  final _tXController = TextEditingController(text: '30');

  String _summary = 'Ingresá los valores y tocá "Calcular".';

  @override
  void dispose() {
    _cNController.dispose();
    _cXController.dispose();
    _tNController.dispose();
    _tXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.science_outlined),
            const SizedBox(width: 8),
            Text('Nivel 5 — A/B Test', style: theme.textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ayuda',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, c) {
            final isNarrow = c.maxWidth < 760;
            final form = _buildPanels(isNarrow);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Compará la tasa de conversión de Control (A) vs Tratamiento (B) con Z para dos proporciones (prueba bilateral).',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (isNarrow) ...[
                  form[0],
                  const SizedBox(height: 12),
                  form[1],
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: form[0]),
                      const SizedBox(width: 16),
                      Expanded(child: form[1]),
                    ],
                  ),
                const SizedBox(height: 16),
                Align(
                  child: ElevatedButton(
                    onPressed: _onCalculate,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Text('Calcular Z y p-valor'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_summary, style: theme.textTheme.titleMedium),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildPanels(bool compact) {
    Widget card({
      required String title,
      required TextEditingController nCtrl,
      required TextEditingController xCtrl,
    }) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: nCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'N usuarios',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: xCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Conversiones',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final control = card(title: 'Control (A)', nCtrl: _cNController, xCtrl: _cXController);
    final treatment = card(title: 'Tratamiento (B)', nCtrl: _tNController, xCtrl: _tXController);
    return [control, treatment];
  }

  void _onCalculate() {
    final nC = int.tryParse(_cNController.text) ?? 0;
    final xC = int.tryParse(_cXController.text) ?? 0;
    final nT = int.tryParse(_tNController.text) ?? 0;
    final xT = int.tryParse(_tXController.text) ?? 0;

    if (nC <= 0 || nT <= 0 || xC < 0 || xT < 0 || xC > nC || xT > nT) {
      setState(() { _summary = 'Revisá los datos: N>0 y 0 ≤ conversiones ≤ N.'; });
      return;
    }
    final pC = xC / nC;
    final pT = xT / nT;
    final pHat = (xC + xT) / (nC + nT);
    final se = math.sqrt(pHat * (1 - pHat) * (1 / nC + 1 / nT));
    final z = (pT - pC) / se;
    final p = 2 * (1 - _phi(z.abs()));
    final sig = p < 0.05;
    final gana = sig ? (pT > pC ? '¡Gana Tratamiento (B)!' : '¡Gana Control (A)!') : 'No significativo (p ≥ 0,05).';
    setState(() {
      _summary = 'Tasa Control: ${(pC * 100).toStringAsFixed(1)}% — '
                 'Tasa Tratamiento: ${(pT * 100).toStringAsFixed(1)}%\n'
                 'Z = ${z.toStringAsFixed(2)} — p-valor = ${p.toStringAsFixed(3)}\n'
                 '$gana';
    });
  }

  // CDF aproximada Normal(0,1)
  double _phi(double z) {
    const p = 0.2316419;
    const b1 = 0.319381530;
    const b2 = -0.356563782;
    const b3 = 1.781477937;
    const b4 = -1.821255978;
    const b5 = 1.330274429;
    final t = 1.0 / (1.0 + p * z);
    final poly = b1 * t + b2 * math.pow(t, 2) + b3 * math.pow(t, 3) + b4 * math.pow(t, 4) + b5 * math.pow(t, 5);
    final nd = (1 / math.sqrt(2 * math.pi)) * math.exp(-0.5 * z * z);
    return 1 - nd * poly;
  }

  void _showHelp(BuildContext context) {
    final nC = int.tryParse(_cNController.text) ?? 0;
    final xC = int.tryParse(_cXController.text) ?? 0;
    final nT = int.tryParse(_tNController.text) ?? 0;
    final xT = int.tryParse(_tXController.text) ?? 0;
    final pC = nC > 0 ? xC / nC : 0.0;
    final pT = nT > 0 ? xT / nT : 0.0;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ayuda A/B (Z para dos proporciones)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                _MiniBars(pC: pC, pT: pT),
                const SizedBox(height: 12),
                const Text('• p_C = x_C / n_C,  p_T = x_T / n_T'),
                const Text('• p̂ (pooling) = (x_C + x_T) / (n_C + n_T)'),
                const Text('• SE = sqrt( p̂ * (1 - p̂) * (1/n_C + 1/n_T) )'),
                const Text('• Z = (p_T - p_C) / SE'),
                const SizedBox(height: 8),
                const Text('Prueba bilateral: p = 2 · (1 − Φ(|Z|)). Si p < 0,05 es significativo.'),
                const SizedBox(height: 8),
                const Text('Supuestos: muestras independientes y tamaños grandes (aprox. normal).'),
                const SizedBox(height: 16),
                const Text(
                  'Ejemplo: si Control tiene 100 usuarios y 25 convierten (p_C = 0.25) y '
                  'Tratamiento tiene 100 y 30 convierten (p_T = 0.30), Z y p-valor indican si la '
                  'diferencia es real o casual.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  final double pC;
  final double pT;
  const _MiniBars({required this.pC, required this.pT});

  @override
  Widget build(BuildContext context) {
    final maxH = 120.0;
    final hC = (pC.clamp(0.0, 1.0) * maxH).toDouble();
    final hT = (pT.clamp(0.0, 1.0) * maxH).toDouble();
    Widget bar(String label, double h, Color color) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: maxH,
              width: 60,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: h,
                  width: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        bar('Control (A)\n${(pC*100).toStringAsFixed(1)}%', hC, Colors.blue),
        bar('Tratamiento (B)\n${(pT*100).toStringAsFixed(1)}%', hT, Colors.green),
      ],
    );
  }
}



