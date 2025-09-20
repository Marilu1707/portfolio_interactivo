import 'package:flutter/material.dart';

import 'sound.dart' as sound;

class KawaiiToast {
  static void show(
    BuildContext context,
    String text, {
    IconData icon = Icons.check_circle,
    Color color = const Color(0xFF34A853),
    Duration duration = const Duration(milliseconds: 1600),
    bool success = true,
    Alignment alignment = Alignment.bottomCenter,
    EdgeInsets? margin,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final media = MediaQuery.maybeOf(context);
    final safeBottom = media?.viewPadding.bottom ?? 0;
    final resolvedMargin = margin ??
        EdgeInsets.only(left: 16, right: 16, bottom: 16 + safeBottom);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastOverlay(
        text: text,
        icon: icon,
        color: color,
        duration: duration,
        alignment: alignment,
        margin: resolvedMargin,
        onDismissed: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
    sound.playPopupSound(success: success);
  }
}

class _ToastOverlay extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Duration duration;
  final Alignment alignment;
  final EdgeInsets margin;
  final VoidCallback onDismissed;

  const _ToastOverlay({
    required this.text,
    required this.icon,
    required this.color,
    required this.duration,
    required this.alignment,
    required this.margin,
    required this.onDismissed,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 180),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  bool _removed = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) _close();
    });
  }

  void _close() {
    if (_removed) return;
    _removed = true;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: SafeArea(
        child: Align(
          alignment: widget.alignment,
          child: Padding(
            padding: widget.margin,
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}

