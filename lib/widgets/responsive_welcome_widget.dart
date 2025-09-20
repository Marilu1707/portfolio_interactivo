import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data model describing the welcome summary for Marilú's mindfulness hub.
class MindfulWelcomeData {
  const MindfulWelcomeData({
    required this.userName,
    required this.dayProgress,
    required this.totalDays,
    required this.completedTasks,
    required this.totalTasks,
    required this.moodLabel,
    required this.moodEmoji,
    required this.moodDescription,
    required this.pet,
    required this.memoryMissions,
    required this.activeRoutines,
    required this.streakDays,
  });

  /// Convenience sample configuration with the narrative requested.
  static final MindfulWelcomeData demo = MindfulWelcomeData(
    userName: 'Marilú',
    dayProgress: 5,
    totalDays: 7,
    completedTasks: 3,
    totalTasks: 5,
    moodLabel: 'Serenidad',
    moodEmoji: '🌙',
    moodDescription:
        'Te sentís calma y enfocada. Tomate unos minutos para celebrar tu avance.',
    pet: VirtualPet(
      name: 'Luma',
      species: 'Dragón turquesa',
      emoji: '🐉',
      level: 4,
      affection: 0.76,
      energy: 0.58,
      message: 'Quiere jugar Memorizar parejas para ganar más estrellitas.',
    ),
    memoryMissions: <MemoryMission>[
      MemoryMission(
        title: 'Memorizar parejas',
        type: 'Visual',
        difficulty: 'Fácil/Medio/Difícil',
        exp: 15,
        emoji: '🧠',
      ),
      MemoryMission(
        title: '¿Qué cambió?',
        type: 'Atención visual',
        difficulty: 'Medio',
        exp: 20,
        emoji: '🔍',
      ),
      MemoryMission(
        title: 'Sudoku pastel',
        type: 'Lógica',
        difficulty: 'Medio/Alto',
        exp: 25,
        emoji: '🧩',
      ),
      MemoryMission(
        title: 'Rompecabezas kawaii',
        type: 'Visual y espacial',
        difficulty: 'Todos',
        exp: 20,
        emoji: '🦊',
      ),
      MemoryMission(
        title: 'Sopa de letras zen',
        type: 'Vocabulario',
        difficulty: 'Medio',
        exp: 15,
        emoji: '🔠',
      ),
    ],
    activeRoutines: <String>[
      'Respiración guiada de 3 minutos',
      'Registro de gratitud',
      'Pausa activa con estiramientos',
    ],
    streakDays: 12,
  );

  final String userName;
  final int dayProgress;
  final int totalDays;
  final int completedTasks;
  final int totalTasks;
  final String moodLabel;
  final String moodEmoji;
  final String moodDescription;
  final VirtualPet pet;
  final List<MemoryMission> memoryMissions;
  final List<String> activeRoutines;
  final int streakDays;
}

class VirtualPet {
  const VirtualPet({
    required this.name,
    required this.species,
    required this.emoji,
    required this.level,
    required this.affection,
    required this.energy,
    required this.message,
  });

  final String name;
  final String species;
  final String emoji;
  final int level;
  final double affection;
  final double energy;
  final String message;
}

class MemoryMission {
  const MemoryMission({
    required this.title,
    required this.type,
    required this.difficulty,
    required this.exp,
    required this.emoji,
  });

  final String title;
  final String type;
  final String difficulty;
  final int exp;
  final String emoji;
}

/// Responsive welcome panel that adapts between mobile and desktop layouts.
class ResponsiveWelcomePanel extends StatelessWidget {
  ResponsiveWelcomePanel({
    super.key,
    MindfulWelcomeData? data,
  }) : data = data ?? MindfulWelcomeData.demo;

  final MindfulWelcomeData data;

  static const Color _bgDark = Color(0xFF1B1A38);
  static const Color _lavender = Color(0xFFC4A9E7);
  static const Color _turquoise = Color(0xFFB1E5E1);
  static const Color _softBlue = Color(0xFFAEC8FF);
  static const Color _pastelPink = Color(0xFFFFD6E8);

  TextStyle _titleStyle(BuildContext context) {
    return GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize ?? 26,
      height: 1.25,
    );
  }

  TextStyle _bodyStyle(BuildContext context) {
    return GoogleFonts.nunito(
      color: Colors.white.withValues(alpha: 0.84),
      fontSize: 15,
      height: 1.45,
    );
  }

  TextStyle _captionStyle(BuildContext context) {
    return GoogleFonts.nunito(
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;
        final padding = EdgeInsets.symmetric(
          horizontal: isDesktop ? 48 : 24,
          vertical: isDesktop ? 32 : 24,
        );

        final content = isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildMainColumn(context, isDesktop),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: _buildPetAndStats(context, isDesktop),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainColumn(context, isDesktop),
                  const SizedBox(height: 24),
                  _buildPetAndStats(context, isDesktop),
                ],
              );

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgDark, Color(0xFF22214E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: padding,
              child: content,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainColumn(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeHeader(context, isDesktop),
        const SizedBox(height: 24),
        _buildDaySummary(context, isDesktop),
        const SizedBox(height: 24),
        _buildMemoryMissions(context, isDesktop),
        const SizedBox(height: 24),
        _buildActiveRoutines(context, isDesktop),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : 24),
      decoration: _frostedDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, ${data.userName} 👋', style: _titleStyle(context)),
                    const SizedBox(height: 8),
                    Text(
                      data.moodDescription,
                      style: _bodyStyle(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _MoodBadge(
                label: data.moodLabel,
                emoji: data.moodEmoji,
                accentColor: _lavender,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _AnimatedProgressBar(
            value: data.completedTasks / math.max(1, data.totalTasks).toDouble(),
            title: 'Rutinas completadas',
            subtitle: '${data.completedTasks}/${data.totalTasks} de hoy',
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            gradient: const LinearGradient(
              colors: [_pastelPink, _softBlue],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummary(BuildContext context, bool isDesktop) {
    final largeNumberStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: isDesktop ? 46 : 38,
    );
    final labelStyle = _captionStyle(context);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          width: isDesktop ? 220 : double.infinity,
          gradient: const LinearGradient(
            colors: [_lavender, _softBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Día ${data.dayProgress} de ${data.totalDays}',
                  style: _captionStyle(context)),
              const SizedBox(height: 16),
              Text('${((data.dayProgress / data.totalDays) * 100).round()}%',
                  style: largeNumberStyle),
              const SizedBox(height: 4),
              Text('Tu aventura mindful progresa suave y constante.',
                  style: _bodyStyle(context)),
            ],
          ),
        ),
        _StatCard(
          width: isDesktop ? 220 : double.infinity,
          gradient: const LinearGradient(
            colors: [_turquoise, _pastelPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Racha activa', style: labelStyle),
              const SizedBox(height: 16),
              Text('${data.streakDays} días', style: largeNumberStyle),
              const SizedBox(height: 4),
              Text('Mantené la magia cuidando tus hábitos diarios.',
                  style: _bodyStyle(context)),
            ],
          ),
        ),
        _StatCard(
          width: isDesktop ? 220 : double.infinity,
          gradient: const LinearGradient(
            colors: [_pastelPink, _lavender],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mascota feliz', style: labelStyle),
              const SizedBox(height: 16),
              Text('Nivel ${data.pet.level}', style: largeNumberStyle),
              const SizedBox(height: 4),
              Text('Alimenta a ${data.pet.name} para desbloquear nuevos fondos.',
                  style: _bodyStyle(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryMissions(BuildContext context, bool isDesktop) {
    final cards = data.memoryMissions
        .map((mission) => _MemoryMissionCard(
              mission: mission,
              accentColor: _turquoise,
              badgeColor: _softBlue,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Misiones de memoria', style: _titleStyle(context)),
        const SizedBox(height: 12),
        Text(
          'Elegí uno de los mini juegos para hoy. Sumá EXP y mimos para tu mascota.',
          style: _bodyStyle(context),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isDesktop
                ? 3
                : constraints.maxWidth > 500
                    ? 2
                    : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isDesktop ? 1.25 : 1.15,
              ),
              itemBuilder: (context, index) => cards[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActiveRoutines(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: _frostedDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Rutina mindful de hoy', style: _titleStyle(context)),
              const Spacer(),
              Icon(Icons.more_horiz, color: Colors.white.withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 16),
          for (final routine in data.activeRoutines) ...[
            _RoutineTile(title: routine),
            const SizedBox(height: 12),
          ],
          Text(
            'Tip: intercalá misiones cortas con respiraciones profundas para reforzar la memoria.',
            style: _bodyStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPetAndStats(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VirtualPetCard(
          pet: data.pet,
          backgroundGradient: const LinearGradient(
            colors: [_turquoise, _lavender],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        const SizedBox(height: 24),
        _WellbeingCard(
          accentColor: _pastelPink,
          softBlue: _softBlue,
          bodyStyle: _bodyStyle(context),
          captionStyle: _captionStyle(context),
        ),
      ],
    );
  }

  BoxDecoration _frostedDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      boxShadow: const [
        BoxShadow(
          blurRadius: 18,
          color: Color(0x33000000),
          offset: Offset(0, 12),
        ),
      ],
    );
  }
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({
    required this.label,
    required this.emoji,
    required this.accentColor,
  });

  final String label;
  final String emoji;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Color(0x33000000),
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.gradient,
  });

  final double value;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Gradient gradient;

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = GoogleFonts.nunito(
      color: Colors.white.withValues(alpha: 0.72),
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.title, style: titleStyle),
            const Spacer(),
            Text(widget.subtitle, style: subtitleStyle),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 14,
            decoration: BoxDecoration(color: widget.backgroundColor),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: widget.value.clamp(0.0, 1.0) * _animation.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: widget.gradient),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.child,
    required this.gradient,
    required this.width,
  });

  final Widget child;
  final Gradient gradient;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 12),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _MemoryMissionCard extends StatelessWidget {
  const _MemoryMissionCard({
    required this.mission,
    required this.accentColor,
    required this.badgeColor,
  });

  final MemoryMission mission;
  final Color accentColor;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );
    final subtitleStyle = GoogleFonts.nunito(
      color: Colors.white.withValues(alpha: 0.8),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(mission.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(mission.title, style: titleStyle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              mission.type,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Nivel sugerido: ${mission.difficulty}', style: subtitleStyle),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.stars_rounded,
                  color: accentColor.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text('+${mission.exp} EXP',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              Icon(Icons.play_arrow_rounded,
                  color: Colors.white.withValues(alpha: 0.9)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF8CA6FF), Color(0xFFB7B6FF)],
              ),
            ),
            child: const Center(
              child: Text(
                '✨',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Icon(Icons.check_circle,
              color: Colors.white.withValues(alpha: 0.55)),
        ],
      ),
    );
  }
}

class _VirtualPetCard extends StatelessWidget {
  const _VirtualPetCard({
    required this.pet,
    required this.backgroundGradient,
  });

  final VirtualPet pet;
  final Gradient backgroundGradient;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 22,
    );
    final subtitleStyle = GoogleFonts.nunito(
      color: Colors.white.withValues(alpha: 0.8),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: backgroundGradient,
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 14),
            color: Color(0x33000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${pet.emoji} Hola, soy ${pet.name}', style: titleStyle),
          const SizedBox(height: 6),
          Text(pet.species, style: subtitleStyle),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PetIndicator(
                  label: 'Cariño',
                  value: pet.affection,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PetIndicator(
                  label: 'Energía',
                  value: pet.energy,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            pet.message,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetIndicator extends StatelessWidget {
  const _PetIndicator({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: color.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$percentage%',
          style: GoogleFonts.nunito(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WellbeingCard extends StatelessWidget {
  const _WellbeingCard({
    required this.accentColor,
    required this.softBlue,
    required this.bodyStyle,
    required this.captionStyle,
  });

  final Color accentColor;
  final Color softBlue;
  final TextStyle bodyStyle;
  final TextStyle captionStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [accentColor.withValues(alpha: 0.9), softBlue.withValues(alpha: 0.9)],
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 12),
            color: Color(0x33000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🪄 Energía del día', style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          )),
          const SizedBox(height: 12),
          Text(
            'Tu energía está en nivel equilibrado. Sumá momentos de descanso entre misiones para potenciar la memoria.',
            style: bodyStyle,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Próxima pausa recomendada', style: captionStyle),
                const SizedBox(height: 6),
                Text('15:30 — Respiración 4-7-8 y té favorito',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
