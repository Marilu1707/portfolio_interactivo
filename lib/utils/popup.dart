import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PopupType { success, error, warning, info }

class Popup {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required PopupType type,
    required String title,
    String? message,
    Duration duration = const Duration(milliseconds: 1600),
  }) {
    _hide();

    final color = switch (type) {
      PopupType.success => Colors.green,
      PopupType.error => Colors.red,
      PopupType.warning => Colors.amber,
      PopupType.info => Colors.blue,
    };

    final overlay = Overlay.of(context, rootOverlay: true);

    final animationCtrl = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );

    final scale = CurvedAnimation(parent: animationCtrl, curve: Curves.easeOutBack);
    final fade = CurvedAnimation(parent: animationCtrl, curve: Curves.easeOut);

    _entry = OverlayEntry(builder: (_) {
      final mq = MediaQuery.of(context);
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _hide,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: Container(color: Colors.black.withValues(alpha: 0.10)),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: mq.size.width * 0.86,
                      minWidth: 240,
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          color: Colors.black.withValues(alpha: 0.12),
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            switch (type) {
                              PopupType.success => Icons.check_rounded,
                              PopupType.error => Icons.close_rounded,
                              PopupType.warning => Icons.warning_rounded,
                              PopupType.info => Icons.info_rounded,
                            },
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: Theme.of(context).textTheme.titleMedium),
                              if (message != null && message.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });

    overlay.insert(_entry!);
    HapticFeedback.lightImpact();
    animationCtrl.forward();

    _timer = Timer(duration, () async {
      try {
        await animationCtrl.reverse();
      } catch (_) {}
      _hide();
    });
  }

  static void _hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}
