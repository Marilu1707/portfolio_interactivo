import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/download_cv.dart';

/// Home: hero + CTA “Jugar ahora”, secciones de Juego (arriba),
/// Datos del juego (abajo), Sobre mí y Contacto.
/// - Sin “nivel …” en los títulos (solo nombres).
/// - Sin “panel mindful”.
/// - Sin bloque “Yo / …” viejo.
/// - Cards con emoji de queso 🧀 (sin assets binarios).
class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

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

  // Botón reutilizable “Jugar ahora”
  Widget _playButton(BuildContext context, {bool expanded = false}) {
    final btn = FilledButton(
      onPressed: () => Navigator.pushNamed(context, '/level1'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFFFD76B),
        foregroundColor: onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text('Jugar ahora', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Marilú — Data Science'),
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

                      // === JUGAR (arriba) ===
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

                      // CTA grande “Jugar ahora”
                      _HomeCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _H3('🎮 Jugar ahora'),
                            const SizedBox(height: 8),
                            const Text(
                              'Entrá a “Nido Mozzarella” y atendé pedidos en un juego kawaii. '
                              'Cada partida genera datos reales para el análisis y el dashboard.',
                            ),
                            const SizedBox(height: 16),
                            _playButton(context, expanded: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === DATOS DEL JUEGO (abajo) ===
                      const _H3('📊 Datos del juego'),
                      const SizedBox(height: 10),
                      _CardsSection(
                        isMobile: isMobile,
                        children: [
                          _LevelCard.emoji(
                            emoji: '📈',
                            title: 'EDA interactiva',
                            subtitle: 'Explorá participación por queso',
                            onTap: () => Navigator.pushNamed(context, '/level2'),
                          ),
                          _LevelCard.emoji(
                            emoji: '🤖',
                            title: 'Predicción ML',
                            subtitle: 'Modelo online que aprende en vivo',
                            onTap: () => Navigator.pushNamed(context, '/level4'),
                          ),
                          _LevelCard.emoji(
                            emoji: '📊',
                            title: 'Dashboard & A/B',
                            subtitle: 'KPIs + experimento con Z-test',
                            onTap: () => Navigator.pushNamed(context, '/dashboard'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sobre mí
                      _buildAboutSection(context, isMobile),
                      const SizedBox(height: 24),

                      // Contacto
                      const _H3('📬 Contacto'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _contactBtn(Icons.business_rounded, 'LinkedIn', () => _open(linkedinUrl)),
                          _contactBtn(Icons.code_rounded, 'GitHub', () => _open(githubUrl)),
                          _contactBtn(Icons.picture_as_pdf_rounded, 'Descargar CV', () => descargarCV(context)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Footer + CTA extra
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _playButton(context, expanded: true),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE7A6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text('© 2025 Marilú — Data Science & Fullstack', style: TextStyle(color: onAccent)),
                          ),
                        ],
                      ),
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
          const Text('👋 Hola, soy Marilú',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: onAccent)),
          const SizedBox(height: 8),
          const Text('Data Science + Full stack — convierto datos en decisiones.',
              style: TextStyle(fontSize: 18, color: onAccent)),
          const SizedBox(height: 8),
          const Text('Descubrí mis habilidades jugando por secciones.',
              style: TextStyle(color: onAccent)),
          const SizedBox(height: 20),
          _playButton(context),
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
      child: const Text('🧀', style: TextStyle(fontSize: 68)), // emoji, sin asset binario
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

  Widget _buildAboutSection(BuildContext context, bool isMobile) {
    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _HomeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _H3('✨ Sobre mí'),
                SizedBox(height: 8),
                Text(
                  'Estudiante de Negocios Digitales (UADE). Me formé en análisis de datos, marketing y desarrollo web. '
                  'Capacitaciones en Python, Django, React.js y SQL. Combino tecnología + eficiencia operativa + enfoque estratégico '
                  'para crear soluciones simples y efectivas.',
                ),
                SizedBox(height: 12),
                _Dot('Análisis de datos (Python, SQL, EDA)'),
                _Dot('Desarrollo web (Django, React.js)'),
                _Dot('Orientación a resultados + mejora de procesos.'),
              ],
            ),
          ),
        ),
        SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
        Expanded(
          child: _HomeCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H3('🛠️ Skills + Stack'),
                SizedBox(height: 8),
                _Chips([
                  '🐍 Python',
                  '🗄️ SQL',
                  '📊 EDA',
                  '⚛️ React.js',
                  '🎨 Django',
                  '🤖 scikit-learn',
                  '📈 Dashboards',
                  '📱 Flutter (UI)',
                  '🔗 Git',
                ]),
              ],
            ),
          ),
        ),
        SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
        Expanded(
          child: _HomeCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H3('🎓 Educación y cursos'),
                SizedBox(height: 8),
                _Chips([
                  '🎓 UADE — Lic. en Negocios Digitales (en curso)',
                  '🎓 React.js — Educación IT (2024)',
                  '🎓 Python Avanzado — Educación IT (2024)',
                  '🎓 Bases de Datos y SQL — Educación IT (2023)',
                  '🎓 Marketing Digital — CoderHouse (2024)',
                ]),
              ],
            ),
          ),
        ),
      ],
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
        color: HomeDesktop.card,
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
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: HomeDesktop.onAccent));
  }
}

/// Píldoras multilínea (no truncan)
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

  const _LevelCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  factory _LevelCard.emoji({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _LevelCard(
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: HomeDesktop.onAccent)),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
