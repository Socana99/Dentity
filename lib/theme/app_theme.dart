import 'package:flutter/material.dart';

/// Tema visual único de SmileVault. Al definir todo aquí, cada Card,
/// TextFormField, Chip, botón, AppBar y TabBar de la app se ve consistente
/// automáticamente, sin tener que repetir estilos en cada pantalla.
class AppTheme {
  AppTheme._();

  // Paleta de marca: turquesa/menta (salud dental) + acento coral cálido.
  static const seed = Color(0xFF0EA5A0);
  static const accent = Color(0xFFFF7A59);
  static const bg = Color(0xFFF4FAF9);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      secondary: accent,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary),
        titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        labelLarge: base.textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.primary.withOpacity(0.08)),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.primary.withOpacity(0.8)),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: scheme.primary,
        backgroundColor: scheme.primary.withOpacity(0.08),
        labelStyle: const TextStyle(fontSize: 12.5),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: StadiumBorder(side: BorderSide(color: scheme.primary.withOpacity(0.2))),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.18),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        dividerColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.white,
      ),
      dividerTheme: DividerThemeData(color: scheme.primary.withOpacity(0.1)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      visualDensity: VisualDensity.comfortable,
    );
  }

  /// Colores consistentes para avatares con iniciales de paciente.
  static Color avatarColorFor(String seedText) {
    const palette = [
      Color(0xFF0EA5A0), Color(0xFFFF7A59), Color(0xFF6366F1),
      Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF10B981),
    ];
    final idx = seedText.isEmpty ? 0 : seedText.codeUnitAt(0) % palette.length;
    return palette[idx];
  }
}
