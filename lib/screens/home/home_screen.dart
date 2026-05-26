import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_portfolio/utils/download_cv.dart';
import 'package:flutter_portfolio/state/player_state.dart';
import 'package:provider/provider.dart';

/// Home: hero + CTA “Jugar ahora”, secciones de Juego (arriba),
/// Datos del juego (abajo), Sobre mí y Contacto.
/// - Sin “nivel …” en los títulos (solo nombres).
/// - Sin “panel mindful”.
/// - Sin bloque “Yo / …” viejo.
/// - Cards con emoji de queso 🧀 (sin assets binarios).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Paleta kawaii
  static const bg = Color(0xFFFFF9E8);
  static const accent = Color(0xFFFFE79A);
  static const onAccent = Color(0xFF5B4E2F);
  static const card = Colors.white;

  // Links
  static const githubUrl = 'https://github.com/Marilu1707';
  static const linkedinUrl = 'https://www.linkedin.com/in/maria-lujan-massironi/';

  static Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAboutSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HomeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _H3('✨ Sobre mí'),
              SizedBox(height: 8),
              Text(
                'Estudiante de Ingeniería en Inteligencia Artificial (UP) con base en Negocios Digitales (UADE) y foco en Data Analytics. '
                'Construyo pipelines de análisis end-to-end en SQL y Python, diseño dashboards en Power BI y Tableau, '
                'y desarrollo aplicaciones de datos full-stack desplegadas en producción. Inglés C1.',
              ),
              SizedBox(height: 12),
              _Dot('Análisis de datos (SQL, Python, Pandas, EDA)'),
              _Dot('BI y visualización (Power BI, Tableau, dashboards ejecutivos)'),
              _Dot('Desarrollo (Django, Flutter, REST APIs, Git)'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildResponsiveCardsRow(
          isMobile: isMobile,
          cards: const [
            _HomeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _H3('🛠️ Skills'),
                  SizedBox(height: 8),
                  _Chips([
                    '🗄️ SQL (CTEs, Window Functions)',
                    '🐍 Python (Pandas, Scikit-learn)',
                    '📊 Power BI (DAX, Power Query)',
                    '📈 Tableau',
                    '🧪 A/B Testing (Z-test)',
                    '🤖 ML (Regresión Logística, SGD)',
                    '📉 EDA & Estadística Descriptiva',
                    '🎨 Django',
                    '📱 Flutter',
                    '🔗 Git/GitHub',
                    '🤖 IA Generativa',
                    '📋 Excel Avanzado',
                  ]),
                ],
              ),
            ),
            _HomeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _H3('🎓 Educación'),
                  SizedBox(height: 8),
                  _Chips([
                    '🎓 UP — Ing. en Inteligencia Artificial (inicio 08/2026)',
                    '🎓 UADE — Lic. en Negocios Digitales (20 materias)',
                    '📊 Diplomatura Data Science — Coderhouse (11/18)',
                    '🐍 Python Avanzado — Educación IT (2024)',
                    '🎨 Desarrollo Web Django — Educación IT (2024)',
                    '🔗 Git Colaborativo — Educación IT (2024)',
                    '🗄️ Bases de Datos y SQL — Educación IT (2023)',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveCardsRow({required bool isMobile, required List<Widget> cards}) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
    
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: player.hasPlayer
            ? Text('Hola, ${player.playerName}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: onAccent, fontSize: 18))
            : const Text('María Luján Massironi — Data Science'),
        actions: [
          if (player.hasPlayer)
            IconButton(
              tooltip: 'Cambiar jugador',
              icon: const Icon(Icons.person_outline_rounded, color: onAccent),
              onPressed: () async {
                await context.read<PlayerState>().logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/welcome');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, cons) {
            final isMobile = cons.maxWidth < 720;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(context, isMobile),
                      const SizedBox(height: 16),

                      // Sobre mí + Skills + Educación
                      _buildAboutSection(isMobile),
                      const SizedBox(height: 24),

                      // Sección Jugar (Nido Mozzarella, Inventario)
                      const _H3('🕹️ Jugar'),
                      const SizedBox(height: 10),
                      _CardsSection(
                        isMobile: isMobile,
                        children: [
                          _LevelCard.emoji(
                            emoji: '🧀',
                            title: 'Nido Mozzarella',
                            subtitle: 'Atendé pedidos y sumá puntos',
                            onTap: () => Navigator.pushNamed(context, '/level1'),
                          ),
                          _LevelCard.emoji(
                            emoji: '📦',
                            title: 'Inventario',
                            subtitle: 'Gestioná y reponé quesos',
                            onTap: () => Navigator.pushNamed(context, '/level3'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sección Datos del juego (EDA, ML, Dashboard)
                      const _H3('📊 Datos del juego'),
                      const SizedBox(height: 10),
                      _CardsSection(
                        isMobile: isMobile,
                        children: [
                          _LevelCard(
                            icon: Icons.bar_chart_rounded,
                            title: 'EDA interactiva',
                            subtitle: 'Stats descriptivas, distribución y tendencias',
                            onTap: () => Navigator.pushNamed(context, '/level2'),
                          ),
                          _LevelCard(
                            icon: Icons.auto_graph,
                            title: 'Predicción ML',
                            subtitle: 'Logistic Regression online (SGD + L2)',
                            onTap: () => Navigator.pushNamed(context, '/level4'),
                          ),
                          _LevelCard(
                            icon: Icons.space_dashboard_rounded,
                            title: 'Dashboard',
                            subtitle: 'KPIs, insights automáticos y métricas ML',
                            onTap: () => Navigator.pushNamed(context, '/dashboard'),
                          ),
                          _LevelCard(
                            icon: Icons.compare_arrows_rounded,
                            title: 'A/B Test',
                            subtitle: "Z-test, p-value, CI y Cohen's h",
                            onTap: () => Navigator.pushNamed(context, '/level5'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Contacto
                      _HomeCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _H3('Contacto'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _contactBtn(Icons.business_rounded, 'LinkedIn', () => _open(linkedinUrl)),
                                _contactBtn(Icons.code_rounded, 'GitHub', () => _open(githubUrl)),
                                _contactBtn(
                                  Icons.picture_as_pdf_rounded,
                                  'Descargar CV',
                                  () async {
                                    final ok = await descargarCV();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok ? 'Abriendo CV…' : 'No se logró abrir el CV.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Footer
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE7A6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '© 2025 María Luján Massironi — Data Analytics & AI',
                          style: TextStyle(color: onAccent, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- Secciones helpers ----------

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    final left = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hola, soy María Luján Massironi',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: onAccent)),
          const SizedBox(height: 8),
          const Text('Data Analytics · IA · Desarrollo Full-Stack',
              style: TextStyle(fontSize: 18, color: onAccent)),
          const SizedBox(height: 8),
          const Text('Explorá mi portfolio interactivo de Data Science.',
              style: TextStyle(color: onAccent)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/level1'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFD76B),
              foregroundColor: onAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Explorar Portfolio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ),
        ],
      ),
    );

    final mouseCircle = Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2CC),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/img/raton_menu.png',
        width: 110,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: onAccent,
        ),
      ),
    );

    final children = isMobile
        ? <Widget>[left, const SizedBox(height: 16), Center(child: mouseCircle)]
        : <Widget>[left, const SizedBox(width: 24), mouseCircle];

    return Container(
      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(22),
      child: Flex(direction: isMobile ? Axis.vertical : Axis.horizontal, crossAxisAlignment: CrossAxisAlignment.center, children: children),
    );
  }


  // Botón de contacto
  static Widget _contactBtn(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: onAccent,
        side: const BorderSide(color: onAccent),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ---------- Widgets base ----------

class _HomeCard extends StatelessWidget {
  final Widget child;
  const _HomeCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeScreen.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _CardsSection extends StatelessWidget {
  final List<Widget> children;
  final bool isMobile;
  const _CardsSection({required this.children, required this.isMobile});

  @override
  Widget build(BuildContext context) {
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
    return Wrap(spacing: 14, runSpacing: 14, children: children);
  }
}

class _H3 extends StatelessWidget {
  final String text;
  const _H3(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: HomeScreen.onAccent));
  }
}

/// Pills multilínea 
class _Chips extends StatelessWidget {
  final List<String> items;
  const _Chips(this.items);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final maxPillWidth = cons.maxWidth < 600 ? cons.maxWidth * 0.9 : 320.0;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((text) => ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxPillWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.brown.shade200.withValues(alpha: 0.5)),
                    ),
                    child: Text(text, softWrap: true, style: const TextStyle(height: 1.2)),
                  ),
                ))
            .toList(),
      );
    });
  }
}

class _Dot extends StatelessWidget {
  final String text;
  const _Dot(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ]),
    );
  }
}

/// Tarjeta clickeable para sección/flujo.
/// Uso versión .emoji para mostrar un 🍕 / 🧀 / 📊 sin assets.
class _LevelCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LevelCard._({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  factory _LevelCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _LevelCard._(
      leading: Icon(icon, size: 30, color: HomeScreen.onAccent),
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  factory _LevelCard.emoji({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _LevelCard._(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

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
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: HomeScreen.onAccent)),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
