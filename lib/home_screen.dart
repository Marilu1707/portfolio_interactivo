// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  // Links de contacto (sin email)
  static const _gitHub = 'https://github.com/Marilu1707';
  static const _linkedIn = 'https://www.linkedin.com/in/maria-lujan-massironi';
  // El PDF ya lo tenés en assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf
  static const _cvAssetPath = 'assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nido Mozzarella — Data Science'),
        centerTitle: false,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Encabezado / Hero
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hola, soy Marilú ??',
                              style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Data Science + Full stack — convierto datos en decisiones.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _PrimaryButton(
                                label: 'Comenzar Nivel 1',
                                icon: Icons.play_arrow_rounded,
                                onTap: () => Navigator.pushNamed(context, '/level1'),
                              ),
                              _ChipButton(
                                label: 'Ver Dashboard',
                                icon: Icons.space_dashboard_outlined,
                                onTap: () => Navigator.pushNamed(context, '/dashboard'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 24),
                      // Ilustración (podés poner la que más te guste)
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: Image.asset(
                          'assets/img/ab_mouse.png', // existe en tu proyecto
                          fit: BoxFit.contain,
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tarjetas de niveles (incluye 4=ML y 5=A/B)
              _Section(
                title: 'Niveles',
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.start,
                  children: [
                    _LevelCard(
                      title: 'Nivel 1',
                      subtitle: 'Restaurante',
                      icon: Icons.restaurant_rounded,
                      onTap: () => Navigator.pushNamed(context, '/level1'),
                    ),
                    _LevelCard(
                      title: 'Nivel 2',
                      subtitle: 'EDA',
                      icon: Icons.bar_chart_rounded,
                      onTap: () => Navigator.pushNamed(context, '/level2'),
                    ),
                    _LevelCard(
                      title: 'Nivel 3',
                      subtitle: 'Inventario',
                      icon: Icons.inventory_2_rounded,
                      onTap: () => Navigator.pushNamed(context, '/level3'),
                    ),
                    _LevelCard(
                      title: 'Nivel 4',
                      subtitle: 'Predicción ML',
                      icon: Icons.insights_rounded,
                      onTap: () => Navigator.pushNamed(context, '/level4'),
                    ),
                    _LevelCard(
                      title: 'Nivel 5',
                      subtitle: 'A/B Test',
                      icon: Icons.science_rounded,
                      onTap: () => Navigator.pushNamed(context, '/level5'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Acceso directo al Dashboard
              _Section(
                title: 'Panel',
                child: _BigDashButton(
                  label: 'Abrir Dashboard',
                  icon: Icons.space_dashboard_rounded,
                  onTap: () => Navigator.pushNamed(context, '/dashboard'),
                ),
              ),

              const SizedBox(height: 20),

              // Contacto (sin Email)
              _Section(
                title: 'Contacto',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ChipButton(
                      label: 'GitHub',
                      icon: Icons.code_rounded,
                      onTap: () => launchUrlString(_gitHub,
                          mode: LaunchMode.externalApplication),
                    ),
                    _ChipButton(
                      label: 'LinkedIn',
                      icon: Icons.person_outline_rounded,
                      onTap: () => launchUrlString(_linkedIn,
                          mode: LaunchMode.externalApplication),
                    ),
                    _ChipButton(
                      label: 'Descargar CV',
                      icon: Icons.download_rounded,
                      onTap: () => launchUrlString(
                        // En web funciona sirviendo el asset estático
                        _cvAssetPath,
                        mode: LaunchMode.platformDefault,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Footer mini
              Center(
                child: Text(
                  '© ${DateTime.now().year} Marilú — Data Science & Fullstack ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- UI helpers ----------

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
    }
}

class _BigDashButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _BigDashButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

