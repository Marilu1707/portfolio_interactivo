import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/download_cv.dart';

// Pantalla Home: presentación, niveles, skills y contacto.
class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  // Paleta kawaii
  static const bg = Color(0xFFFFF9E8);
  static const accent = Color(0xFFFFE79A);
  static const onAccent = Color(0xFF5B4E2F);
  static const card = Colors.white;

  // Links reales
  static const githubUrl = 'https://github.com/Marilu1707';
  static const linkedinUrl = 'https://www.linkedin.com/in/maria-lujan-massironi/';
  static const email = 'mlujanmassironi@gmail.com';

  static Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> _openEmail({
    required String to,
    String subject = '',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_self',
      );
    }
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
      body: LayoutBuilder(
        builder: (context, c) {
          final isMobile = c.maxWidth < 720;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    Container(
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.all(22),
                      child: Builder(builder: (context) {
                        final left = Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Hola, soy Marilu 👋',
                                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: onAccent)),
                              SizedBox(height: 8),
                              Text('Data Science + Full stack — convierto datos en decisiones.',
                                  style: TextStyle(fontSize: 18, color: onAccent)),
                              SizedBox(height: 8),
                              Text('Descubrí mis habilidades jugando por niveles.', style: TextStyle(color: onAccent)),
                            ],
                          ),
                        );

                        final mouseCircle = Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2CC), // amarillo pastel pedido
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/raton_menu.png',
                            width: 110,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) => Image.asset(
                              'assets/img/raton_menu.png',
                              width: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) => const Text('🐭', style: TextStyle(fontSize: 72)),
                            ),
                          ),
                        );

                        final children = isMobile
                            ? <Widget>[
                                Center(child: mouseCircle),
                                const SizedBox(height: 16),
                                left,
                              ]
                            : <Widget>[
                                left,
                                const SizedBox(width: 24),
                                mouseCircle,
                              ];

                        return Flex(
                          direction: isMobile ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: children,
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/level1'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD76B),
                            foregroundColor: onAccent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Empezar nivel 1', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        OutlinedButton(
                          onPressed: () => _open(githubUrl),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: onAccent),
                            foregroundColor: onAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Ver más proyectos'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Sobre mí / Skills / Educación
                    Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _HomeCard(
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _H3('Sobre mí'),
                                SizedBox(height: 8),
                                Text(
                                  'Estudiante de Negocios Digitales (UADE). Me formé en análisis de datos, marketing y desarrollo web. '
                                  'Capacitaciones en Python, Django, React.js y SQL. Me interesa combinar tecnología, eficiencia operativa y enfoque '
                                  'estratégico para crear soluciones simples y efectivas.',
                                ),
                                SizedBox(height: 12),
                                _Dot('📊 Análisis de datos (Python, SQL, EDA)'),
                                _Dot('💻 Desarrollo web (Django, React.js)'),
                                _Dot('🚀 Orientación a resultados + mejora de procesos.'),
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
                                _H3('Skills + Stack'),
                                SizedBox(height: 8),
                                _Chips(['EDA','Python','SQL','scikit-learn','Dashboards','Django','React.js','Flutter (UI)','Git']),
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
                                _H3('Educación y cursos'),
                                SizedBox(height: 8),
                                _Chips([
                                  '🎓 UADE — Lic. en Negocios Digitales (en curso)',
                                  '🧩 React.js Developer — Educación IT (2024)',
                                  '🐍 Python Avanzado — Educación IT (2024)',
                                  '🗄️ Bases de Datos y SQL — Educación IT (2023)',
                                  '🌐 Marketing Digital — CoderHouse (2024)',
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Niveles
                    const _H3('Niveles'),
                    const SizedBox(height: 10),
                    Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(child: _LevelTile(emoji: '🐭', title: 'Nivel 1', subtitle: 'Juego', onTap: () => Navigator.pushNamed(context, '/level1'))),
                        SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
                        Expanded(child: _LevelTile(emoji: '📊', title: 'Nivel 2', subtitle: 'EDA', onTap: () => Navigator.pushNamed(context, '/level2'))),
                        SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
                        Expanded(child: _LevelTile(emoji: '📦', title: 'Nivel 3', subtitle: 'Inventario', onTap: () => Navigator.pushNamed(context, '/level3'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(child: _LevelTile(emoji: '🧪', title: 'Nivel 4', subtitle: 'A/B Test', onTap: () => Navigator.pushNamed(context, '/level4'))),
                        SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
                        Expanded(child: _LevelTile(emoji: '📈', title: 'Final', subtitle: 'Panel', onTap: () => Navigator.pushNamed(context, '/dashboard'))),
                      ],
                    ),

                    const SizedBox(height: 22),
                    const _H3('Contacto'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _contactBtn(
                          Icons.email_rounded,
                          'Email',
                          () => _openEmail(
                            to: email,
                            subject: 'Consulta desde portfolio',
                            body: '¡Hola Marilú! Te escribo por...',
                          ),
                        ),
                        _contactBtn(Icons.business_rounded, 'LinkedIn', () => _open(linkedinUrl)),
                        _contactBtn(Icons.code_rounded, 'GitHub', () => _open(githubUrl)),
                        _contactBtn(Icons.picture_as_pdf_rounded, 'Descargar CV', () => descargarCV(context)),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFFFE7A6), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Text('© 2025 Marilu — Data Science & Storytelling', style: TextStyle(color: onAccent)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Botón de contacto reutilizable
  static Widget _contactBtn(IconData i, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(i),
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

// Tarjeta contenedora con estilo Kawaii
class _HomeCard extends StatelessWidget {
  final Widget child;
  const _HomeCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeDesktop.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
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

// Píldoras multilínea: reemplazo de Chip para no truncar
class _Chips extends StatelessWidget {
  final List<String> items;
  const _Chips(this.items);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxPillWidth = c.maxWidth < 600 ? c.maxWidth * 0.9 : 320.0;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((t) => ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxPillWidth),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.brown.shade200.withOpacity(0.5)),
                      ),
                      child: Text(
                        t,
                        softWrap: true,
                        style: const TextStyle(height: 1.2),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  final String text;
  const _Dot(this.text);
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

class _LevelTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _LevelTile({required this.emoji, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: HomeDesktop.onAccent)),
        subtitle: Text(subtitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.brown.shade200.withOpacity(0.4))),
      ),
    );
  }
}

class EduPill extends StatelessWidget {
  final String emoji;
  final String text;
  const EduPill({super.key, required this.emoji, required this.text});
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 560),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.brown.shade200.withOpacity(0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
