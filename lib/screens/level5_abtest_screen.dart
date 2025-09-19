import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/ab_result_state.dart';

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

  double? _z, _pTwo, _pA, _pB, _diff, _ciL, _ciH, _lift;
  bool _sig = false;

  String _summary = 'IngresÃ¡ los valores y tocÃ¡ â€œCalcularâ€.';

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
        backgroundColor: const Color(0xFFFFE082),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nivel 5 — A/B Test'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
            icon: const Icon(Icons.analytics),
            label: const Text('Ir al Dashboard'),
            style: TextButton.styleFrom(foregroundColor: Colors.brown),
          ),
          if (_pTwo != null)
            TextButton.icon(
              onPressed: () async {
                final result = {
                  'nA': _cNController.text,
                  'cA': _cXController.text,
                  'pA': _pA?.toStringAsFixed(4),
                  'nB': _tNController.text,
                  'cB': _tXController.text,
                  'pB': _pB?.toStringAsFixed(4),
                  'diff': _diff?.toStringAsFixed(4),
                  'lift': _lift == null ? '—' : '${(_lift! * 100).toStringAsFixed(1)}%',
                  'z': _z?.toStringAsFixed(3),
                  'p': _pTwo?.toStringAsFixed(4),
                  'ci': _ciL == null || _ciH == null
                      ? '—'
                      : '[${(_ciL! * 100).toStringAsFixed(1)}%, ${(_ciH!*100).toStringAsFixed(1)}%]',
                  'sig': _sig ? 'Sí' : 'No',
                  'alpha': '0.05',
                  'note': 'Resultado guardado desde Nivel A/B',
                };
                await context.read<ABResultState>().save(result);
                if (context.mounted) {
                  Navigator.pushNamed(context, '/dashboard');
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Enviar al Dashboard'),
            ),
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
                  'ComparÃ¡ la tasa de conversiÃ³n de Control (A) vs Tratamiento (B) con Z para dos proporciones (prueba bilateral).',
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
                  color: theme.colorScheme.surfaceVariant.withOpacity(.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(_summary, style: theme.textTheme.titleMedium), if(_pTwo!=null) const SizedBox(height:10), if(_pTwo!=null) Text("Detalle: pA=${( (_pA??0)*100).toStringAsFixed(1)}% · pB=${( (_pB??0)*100).toStringAsFixed(1)}% · Δ=${( (_diff??0)*100).toStringAsFixed(1)}% · Lift=${_lift==null?"—":"${((_lift??0)*100).toStringAsFixed(1)}%"} · IC95%=[${( (_ciL??0)*100).toStringAsFixed(1)}%, ${( (_ciH??0)*100).toStringAsFixed(1)}%] · p=${(_pTwo??0).toStringAsFixed(4)}")]),
                  ),
                ),
                if (_pTwo != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = {
                          'nA': _cNController.text,
                          'cA': _cXController.text,
                          'pA': _pA?.toStringAsFixed(4),
                          'nB': _tNController.text,
                          'cB': _tXController.text,
                          'pB': _pB?.toStringAsFixed(4),
                          'diff': _diff?.toStringAsFixed(4),
                          'lift': _lift == null ? '—' : '${(_lift! * 100).toStringAsFixed(1)}%',
                          'z': _z?.toStringAsFixed(3),
                          'p': _pTwo?.toStringAsFixed(4),
                          'ci': _ciL == null || _ciH == null
                              ? '—'
                              : '[${(_ciL! * 100).toStringAsFixed(1)}%, ${(_ciH!*100).toStringAsFixed(1)}%]',
                          'sig': _sig ? 'Sí' : 'No',
                          'alpha': '0.05',
                          'note': 'Resultado guardado desde Nivel A/B',
                        };
                        await context.read<ABResultState>().save(result);
                        if (!mounted) return;
                        Navigator.pushNamed(context, '/dashboard');
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Ir al Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE082),
                        foregroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
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
      setState(() {
        _summary = 'Revisá los datos: N > 0 y 0 ≤ conversiones ≤ N.';
        _pTwo = null;
      });
      return;
    }
    final pC = xC / nC;
    final pT = xT / nT;
    final pHat = (xC + xT) / (nC + nT);
    final se = math.sqrt(pHat * (1 - pHat) * (1 / nC + 1 / nT));
    final z = (pT - pC) / (se == 0 ? 1e-9 : se);
    final p = 2 * (1 - _phi(z.abs()));
    final sig = p < 0.05;
    const z95 = 1.96;
    final diff = pT - pC;
    final ciL = diff - z95 * se;
    final ciH = diff + z95 * se;
    final lift = pC == 0 ? null : diff / pC;

    final gana = sig
        ? (pT > pC ? '¡Gana Tratamiento (B)! 🎉' : '¡Gana Control (A)! 🎉')
        : 'No significativo (p ≥ 0,05).';

    setState(() {
      _z = z;
      _pTwo = p;
      _pA = pC;
      _pB = pT;
      _diff = diff;
      _ciL = ciL;
      _ciH = ciH;
      _lift = lift;
      _sig = sig;
      _summary =
          'Tasa A: ${(pC * 100).toStringAsFixed(1)}% · '
          'Tasa B: ${(pT * 100).toStringAsFixed(1)}%\n'
          'Z = ${z.toStringAsFixed(2)} · p-valor = ${p.toStringAsFixed(3)}\n'
          '$gana';
    });
  }// CDF aproximada Normal(0,1)
  double _phi(double z) {
    const p = 0.2316419;
    const b1 = 0.319381530;
    const b2 = -0.356563782;
    const b3 = 1.781477937;
    const b4 = -1.821255978;
    const b5 = 1.330274429;
    final t = 1.0 / (1.0 + p * z);
    final poly = b1 * t +
        b2 * math.pow(t, 2) +
        b3 * math.pow(t, 3) +
        b4 * math.pow(t, 4) +
        b5 * math.pow(t, 5);
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
              children: const [
                Text(
                  'Ayuda A/B (Z para dos proporciones)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                // El mini grÃ¡fico se agrega abajo (fuera de const)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Para que el mini grÃ¡fico se muestre con los valores actuales,
// puedes llamar a _MiniBars dentro del bottom sheet (sin const):
void showHelpContent(BuildContext context, double pC, double pT) {}










