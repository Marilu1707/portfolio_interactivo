import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/player_state.dart';

/// Pantalla de bienvenida: pide el nombre del jugador.
/// Si ya hay un nombre guardado, redirige directamente al home.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const bg = Color(0xFFFFF9E8);
  static const accent = Color(0xFFFFE79A);
  static const onAccent = Color(0xFF5B4E2F);

  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final player = context.read<PlayerState>();
      if (player.hasPlayer) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _comenzar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await context.read<PlayerState>().setName(_ctrl.text);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(color: accent, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/img/raton_menu.png',
                        width: 76,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Text('🧀', style: TextStyle(fontSize: 42)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '\u00a1Bienvenido/a a Nido Mozzarella!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w900, color: onAccent, height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Atend\u00e9 pedidos, analiz\u00e1 datos y sub\u00ed de nivel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: onAccent, fontSize: 15),
                    ),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _ctrl,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _comenzar(),
                      decoration: InputDecoration(
                        labelText: '\u00bfCon qu\u00e9 nombre quer\u00e9s jugar?',
                        hintText: 'Ej: Mozzarella Fan',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (v) {
                        final trimmed = (v ?? '').trim();
                        if (trimmed.length < 2) return 'Ingres\u00e1 al menos 2 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _loading ? null : _comenzar,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD76B),
                          foregroundColor: onAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: onAccent),
                              )
                            : const Text('Comenzar',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
