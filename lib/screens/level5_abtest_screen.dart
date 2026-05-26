import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ab_test_result.dart';
import '../state/ab_result_state.dart';
import '../state/app_state.dart';
import '../utils/help_sheet.dart';
import '../widgets/help_modal.dart';
import '../widgets/ab_result_card.dart';
import '../widgets/kawaii_card.dart';

class AbTestScreen extends StatefulWidget {
  const AbTestScreen({super.key});

  @override
  State<AbTestScreen> createState() => _AbTestScreenState();
}

class _AbTestScreenState extends State<AbTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cNController = TextEditingController(text: '100');
  final _cXController = TextEditingController(text: '25');
  final _tNController = TextEditingController(text: '100');
  final _tXController = TextEditingController(text: '30');

  double _alpha = 0.05;
  AbTestResult? _result;
  bool _normalApproxOk = true;

  static const _alphaOptions = <double>[0.10, 0.05, 0.01];

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
    final isNarrow = MediaQuery.of(context).size.width < 720;
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('A/B Test'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Ver ayuda',
            icon: const Icon(Icons.help_outline),
            onPressed: () => showHelpSheet(
              context,
              child: const HelpModal(
                title: 'Nivel 5 — Test A/B',
                whatIs: 'Herramienta para comparar dos estrategias de venta con datos reales.',
                howToUse: 'Ingresá los resultados de los grupos A y B para ver si la diferencia es estadísticamente significativa.',
                whyItMatters: 'Validar experimentos antes de implementar cambios permanentes en el negocio.',
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Compará la conversión entre Control (A) y Tratamiento (B). '
                    'Ingresá muestras enteras y validamos el Z test de dos proporciones.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  KawaiiCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurar muestras',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Form(
                          key: _formKey,
                          child: isNarrow
                              ? Column(
                                  children: [
                                    _buildSampleCard(
                                      title: 'Control (A)',
                                      nController: _cNController,
                                      xController: _cXController,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSampleCard(
                                      title: 'Tratamiento (B)',
                                      nController: _tNController,
                                      xController: _tXController,
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildSampleCard(
                                        title: 'Control (A)',
                                        nController: _cNController,
                                        xController: _cXController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSampleCard(
                                        title: 'Tratamiento (B)',
                                        nController: _tNController,
                                        xController: _tXController,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Confianza estadística',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            for (final value in _alphaOptions)
                              ChoiceChip(
                                label: Text('${((1 - value) * 100).toStringAsFixed(0)}%'),
                                selected: _alpha == value,
                                onSelected: (_) => setState(() => _alpha = value),
                                labelStyle: theme.textTheme.bodyMedium,
                                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.18),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _onCalculate,
                          icon: const Icon(Icons.calculate_rounded),
                          label: const Text('Calcular Z y probabilidad de azar'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFFEF9F27),
                            foregroundColor: const Color(0xFF4A2E1A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (result != null) ...[
                    const SizedBox(height: 20),
                    AbResultCard(result: result),
                    if (!_normalApproxOk) ...[
                      const SizedBox(height: 12),
                      KawaiiCard(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Atención: alguna celda tiene menos de 5 casos. '
                                'El test Z puede subestimar la significancia; considerá una prueba exacta.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _ActionRow(
                      onSave: _saveResult,
                      onDashboard: _openDashboard,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSampleCard({
    required String title,
    required TextEditingController nController,
    required TextEditingController xController,
  }) {
    return KawaiiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nController,
            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Color(0xFF8B6343)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFEF9F27), width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFE8D9C0), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
            labelText: 'N usuarios',
            hintText: 'Ej.: 120',
          ),
            validator: (value) {
              final n = int.tryParse(value ?? '');
              if (n == null || n <= 0) {
                return 'Usá un número mayor a 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: xController,
            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Color(0xFF8B6343)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFEF9F27), width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFE8D9C0), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
            labelText: 'Conversiones',
            hintText: 'Ej.: 30',
          ),
            validator: (value) {
              final conv = int.tryParse(value ?? '');
              if (conv == null || conv < 0) {
                return 'Usá un entero ≥ 0';
              }
              final n = int.tryParse(nController.text);
              if (n != null && conv > n) {
                return 'No puede superar el total';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _onCalculate() {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _result = null);
      return;
    }

    final nA = int.parse(_cNController.text);
    final cA = int.parse(_cXController.text);
    final nB = int.parse(_tNController.text);
    final cB = int.parse(_tXController.text);

    final pA = cA / nA;
    final pB = cB / nB;
    final pooled = (cA + cB) / (nA + nB);
    final se = math.sqrt(pooled * (1 - pooled) * (1 / nA + 1 / nB));
    final diff = pB - pA;
    final z = se == 0 ? 0.0 : diff / se;
    final pValue = 2 * (1 - _normCdf(z.abs()));
    final critical = _criticalByAlpha(_alpha);
    final ciLow = diff - critical * se;
    final ciHigh = diff + critical * se;
    final lift = pA == 0 ? double.nan : diff / (pA == 0 ? 1e-9 : pA);

    // Cohen's h — effect size for two proportions
    final h = (2 * math.asin(math.sqrt(pB)) - 2 * math.asin(math.sqrt(pA))).abs();

    final approxOk = _checkApproximation(nA, pA, nB, pB);

    setState(() {
      _normalApproxOk = approxOk;
      _result = AbTestResult(
        nControl: nA,
        convControl: cA,
        nTreatment: nB,
        convTreatment: cB,
        pControl: pA,
        pTreatment: pB,
        diff: diff,
        lift: lift,
        zScore: z,
        pValue: pValue,
        ciLow: ciLow,
        ciHigh: ciHigh,
        alpha: _alpha,
        significant: pValue < _alpha,
        cohensH: h,
        timestamp: DateTime.now(),
      );
    });
  }

  bool _checkApproximation(int nA, double pA, int nB, double pB) {
    final values = [
      nA * pA,
      nA * (1 - pA),
      nB * pB,
      nB * (1 - pB),
    ];
    return values.every((v) => v >= 5);
  }

  double _criticalByAlpha(double alpha) {
    switch (alpha) {
      case 0.10:
        return 1.6449;
      case 0.01:
        return 2.5758;
      default:
        return 1.96;
    }
  }

  double _normCdf(double z) {
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

  Future<void> _saveResult() async {
    final result = _result;
    if (result == null) return;
    final abState = context.read<ABResultState>();
    await abState.save(result);
    if (!mounted) return;
    context.read<AppState>().setLevelCompleted(5);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guardamos el resultado en el Dashboard 🧀'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openDashboard() {
    final result = _result;
    if (result == null) return;
    context.read<AppState>().setLevelCompleted(5);
    Navigator.pushNamed(context, '/dashboard');
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onDashboard;

  const _ActionRow({required this.onSave, required this.onDashboard});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final children = <Widget>[
      FilledButton.icon(
        onPressed: onSave,
        icon: const Icon(Icons.save_alt_rounded),
        label: const Text('Guardar en Dashboard'),
      ),
      OutlinedButton.icon(
        onPressed: onDashboard,
        icon: const Icon(Icons.analytics_outlined),
        label: const Text('Ir al Dashboard'),
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        children[0],
        const SizedBox(width: 16),
        children[1],
      ],
    );
  }
}
