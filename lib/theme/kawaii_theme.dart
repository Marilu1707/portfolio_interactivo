import 'package:flutter/material.dart';

/// Tema central kawaii pastel para toda la app.
class KawaiiTheme {
  // Paleta
  static const Color bg = Color(0xFFFFF9E8);        // crema
  static const Color accent = Color(0xFFFFE79A);    // amarillo pastel
  static const Color onAccent = Color(0xFF5B4E2F);  // marrón cálido
  static const Color card = Colors.white;
  static const Color border = Color(0xFFD7C6A8);

  static ThemeData materialTheme() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        surface: bg,
      ),
    );

    return base.copyWith(
      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: onAccent,
        titleTextStyle: TextStyle(
          color: onAccent,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),

      // Textos
      textTheme: base.textTheme.apply(
        bodyColor: Colors.brown,  // tono cálido en lugar de negro puro
        displayColor: Colors.brown,
      ).copyWith(
        headlineMedium: const TextStyle(
          fontSize: 28, fontWeight: FontWeight.w900, color: Colors.brown),
        titleLarge: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: Colors.brown),
        bodyMedium: const TextStyle(height: 1.3),
      ),

      // Botón elevado (primario)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD76B),
          foregroundColor: onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // Botón outlined (secundario)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onAccent,
          side: const BorderSide(color: onAccent, width: 1.6),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Chips
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: card,
        side: BorderSide(color: Colors.brown.shade200.withValues(alpha: 0.5)),
        selectedColor: accent,
        labelStyle: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
        shape: StadiumBorder(
          side: BorderSide(color: Colors.brown.shade200.withValues(alpha: 0.5)),
        ),
      ),

      // Tarjetas
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      // Inputs (Level 4)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: const TextStyle(color: Colors.brown),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.brown.shade200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.brown.shade400, width: 2),
        ),
      ),

      // Dividers y bordes suaves
      dividerColor: border,
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Iconos
      iconTheme: const IconThemeData(color: onAccent),
    );
  }
}
