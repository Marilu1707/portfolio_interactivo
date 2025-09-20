import 'package:flutter/material.dart';

import '../widgets/responsive_welcome_widget.dart';

/// Showcase screen for the responsive welcome panel requested by Marilú.
class MindfulWelcomeScreen extends StatelessWidget {
  const MindfulWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A38),
      body: ResponsiveWelcomePanel(),
    );
  }
}
