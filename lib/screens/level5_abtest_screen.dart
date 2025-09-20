import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String _summary = 'Ingresá los valores y tocá “Calcular”.';

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
          if (_pTwo != null)
            TextButton.icon(
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, '/dashboard');
              },
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
                final ab = context.read<ABResultState>();
                await ab.save(result);
                if (!context.mounted) return;
                Navigator.pushNamed(context, '/dashboard');
              },
              icon: const Icon(Icons.send),
              label: const Text('Enviar al Dashboard'),
            ),
          IconButton(
            tooltip: '¿Cómo funciona?',
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: const Color(0xFFFFD54F),
                      foregroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Calcular Z y p-valor'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
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
                        final ab = context.read<ABResultState>();
                        await ab.save(result);
                        if (!context.mounted) return;
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
    InputDecoration dec(String label) => InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        );

    final List<TextInputFormatter> digits =
        <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

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
                inputFormatters: digits,
                textInputAction: TextInputAction.next,
                decoration: dec('N usuarios'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: xCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                textInputAction: TextInputAction.done,
                decoration: dec('Conversiones'),
                onSubmitted: (_) => _onCalculate(),
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
    // cerrar teclado en móvil
    FocusScope.of(context).unfocus();
    final nC = int.tryParse(_cNController.text) ?? 0;
    final xC = int.tryParse(_cXController.text) ?? 0;
    final nT = int.tryParse(_tNController.text) ?? 0;
    final xT = int.tryParse(_tXController.text) ?? 0;

    if (nC <= 0 || nT <= 0 || xC < 0 || xT < 0 || xC > nC || xT > nT) {
      if (!mounted) return;
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

    // Supuestos (np >= 5 y n(1-p) >= 5) para aproximación normal
    final m1 = nC * pC, m2 = nC * (1 - pC), m3 = nT * pT, m4 = nT * (1 - pT);
    final normalOk = [m1, m2, m3, m4].every((v) => v >= 5);

    final gana = sig
        ? (pT > pC ? '✅ B gana' : '✅ A gana')
        : 'ℹ️ No significativo';

    if (!mounted) return;
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
      final notaSup = normalOk
          ? ''
          : '\nAtención: tamaños pequeños (np<5), el test Z puede no ser válido; considerá exacto de Fisher.';
      _summary =
          'Tasa A: ${(pC * 100).toStringAsFixed(1)}% · '
          'Tasa B: ${(pT * 100).toStringAsFixed(1)}%\n'
          'Z = ${z.toStringAsFixed(2)} · p-valor = ${p.toStringAsFixed(3)}\n'
          '$gana$notaSup';
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
              children: [
                const Text('Cómo funciona la prueba A/B',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                const Text('Usamos una Z para dos proporciones (bilateral, α = 0,05).'),
                const SizedBox(height: 8),
                const Text('Fórmulas:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                SelectableText(
                  'pA = xA / nA,   pB = xB / nB\n'
                  'p̂ = (xA + xB) / (nA + nB)\n'
                  'SE = sqrt( p̂(1−p̂)(1/nA + 1/nB) )\n'
                  'Z = (pB − pA) / SE\n'
                  'p-valor = 2 · (1 − Φ(|Z|))\n'
                  'IC95%(pB−pA) = (pB−pA) ± 1.96·SE',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Con tus valores actuales: pA=${(pC * 100).toStringAsFixed(1)}%, '
                  'pB=${(pT * 100).toStringAsFixed(1)}%. '
                  'Tocá “Calcular” para ver Z, p-valor, IC y lift.',
                ),
                const SizedBox(height: 16),
                const Text('Buenas prácticas:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const _Bullet('Definí la métrica antes de empezar.'),
                const _Bullet('Evitá cortar la prueba por mirar el p-valor.'),
                const _Bullet('Asegurá tamaño muestral suficiente.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// (removido: _MiniBars no se usa)

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
