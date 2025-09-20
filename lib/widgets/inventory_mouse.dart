import 'package:flutter/material.dart';
import '../utils/game_popup.dart';

class InventoryMouseItem {
  final String name;
  final int stock;
  const InventoryMouseItem({required this.name, required this.stock});
}

class InventoryMouse extends StatefulWidget {
  final List<InventoryMouseItem> items;
  final int lowThreshold;
  final VoidCallback? onTap;
  const InventoryMouse({super.key, required this.items, this.lowThreshold = 3, this.onTap});

  @override
  State<InventoryMouse> createState() => _InventoryMouseState();
}

class _InventoryMouseState extends State<InventoryMouse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _wiggle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _wiggle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.07, end: 0.07), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.07, end: -0.07), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/img/inventario_mouse.png'), context);
      _updateAnim();
    });
  }

  @override
  void didUpdateWidget(covariant InventoryMouse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnim();
  }

  void _updateAnim() {
    final hasLow = widget.items.any((e) => e.stock <= widget.lowThreshold);
    if (hasLow) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  void _handleTap() {
    final bajos = widget.items.where((e) => e.stock <= widget.lowThreshold).toList();
    final total = widget.items.length;
    final msg = bajos.isEmpty
        ? 'Todo ok: stock suficiente en $total productos.'
        : 'Stock bajo (${bajos.length}): ${bajos.map((e) => e.name).join(', ')}';
    if (mounted) {
      if (bajos.isEmpty) {
        GamePopup.show(context, msg, color: Colors.green, icon: Icons.check_circle);
      } else {
        GamePopup.show(context, msg, color: Colors.orange, icon: Icons.warning_amber_rounded);
      }
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _wiggle,
        builder: (_, child) => Transform.rotate(
          angle: _controller.isAnimating ? _wiggle.value : 0.0,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB78F6A).withValues(alpha: 0.35), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/img/inventario_mouse.png', height: 56),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ratón de Depósito', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5B4636))),
                  Text(
                    widget.items.any((e) => e.stock <= widget.lowThreshold)
                        ? '¡Atención! Hay stock bajo'
                        : 'Todo en orden 🧀',
                    style: const TextStyle(color: Color(0xFF5B4636)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
