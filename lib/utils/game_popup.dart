import 'package:flutter/material.dart';
import 'sound.dart' as sound;

class GamePopup {
  static void show(
    BuildContext context,
    String message, {
    Color color = Colors.brown,
    IconData? icon,
    Duration? duration,
    bool success = true,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _PopupOverlay(
        message: message,
        color: color,
        icon: icon,
        duration: duration ?? const Duration(seconds: 2),
        onDone: () {
          try {
            entry.remove();
          } catch (_) {}
        },
      ),
    );

    overlay.insert(entry);
    // Reproduce un beep sutil (web) si es posible
    sound.playPopupSound(success: success);
  }
}

class _PopupOverlay extends StatefulWidget {
  final String message;
  final Color color;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDone;
  const _PopupOverlay({
    required this.message,
    required this.color,
    this.icon,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_PopupOverlay> createState() => _PopupOverlayState();
}

class _PopupOverlayState extends State<_PopupOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Programar fade-out suave antes de retirar el overlay
    final stay = widget.duration - const Duration(milliseconds: 200);
    final stayMs = stay.inMilliseconds.clamp(0, 2000);
    Future.delayed(Duration(milliseconds: stayMs), () async {
      if (!mounted) return;
      await _ctrl.animateBack(0.0,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: FadeTransition(
              opacity: _opacity,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null)
                      Icon(widget.icon, color: Colors.white, size: 26),
                    if (widget.icon != null) const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
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
