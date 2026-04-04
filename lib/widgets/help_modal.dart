import 'package:flutter/material.dart';
import '../utils/help_sheet.dart';

/// Widget reutilizable de ayuda contextual.
/// Usar con [showHelpSheet] o con [showHelpModal].
class HelpModal extends StatelessWidget {
  final String title;
  final String whatIs;
  final String howToUse;
  final String whyItMatters;

  const HelpModal({
    super.key,
    required this.title,
    required this.whatIs,
    required this.howToUse,
    required this.whyItMatters,
  });

  static const _brown = Color(0xFF5B4E2F);
  static const _accent = Color(0xFFFFE79A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _brown,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        _HelpSection(
          icon: Icons.info_outline_rounded,
          label: 'Qu\u00e9 es',
          text: whatIs,
        ),
        const SizedBox(height: 16),
        _HelpSection(
          icon: Icons.touch_app_rounded,
          label: 'C\u00f3mo se usa',
          text: howToUse,
        ),
        const SizedBox(height: 16),
        _HelpSection(
          icon: Icons.insights_rounded,
          label: 'Para qu\u00e9 sirve',
          text: whyItMatters,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFD76B),
              foregroundColor: _brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Entendido',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _HelpSection({
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: HelpModal._accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: HelpModal._brown),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: HelpModal._brown,
                ),
              ),
              const SizedBox(height: 4),
              Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
