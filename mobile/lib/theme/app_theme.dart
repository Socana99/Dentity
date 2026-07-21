import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual único de Dentity. Al definir todo aquí, cada Card,
/// TextFormField, Chip, botón, AppBar y TabBar de la app se ve consistente
/// automáticamente, sin tener que repetir estilos en cada pantalla.
class AppTheme {
  AppTheme._();

  // Paleta "DentalSoft - Suave y Moderna".
  static const seed =
      Color(0xFFA7C7E7); // Azul cielo suave (identidad primaria)
  static const lavender =
      Color(0xFFC5A3E0); // Lavanda suave (identidad secundaria)
  static const coral =
      Color(0xFFF4A261); // Coral cálido (acento / "en progreso")
  static const bg = Color(0xFFF0F4F8); // Fondo de la app
  static const textDark = Color(0xFF444444); // Texto principal
  static const ctaGradient = [Color(0xFFBA8BFF), Color(0xFFD9B4FF)];

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      secondary: lavender,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      // Texto general: Plus Jakarta Sans (versátil y muy legible).
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        // Títulos: Sora (geométrica, con más carácter que el texto general).
        titleTextStyle: GoogleFonts.sora(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: GoogleFonts.sora(
            textStyle: base.textTheme.titleLarge,
            fontWeight: FontWeight.w700,
            color: scheme.primary),
        titleMedium: GoogleFonts.sora(
            textStyle: base.textTheme.titleMedium,
            fontWeight: FontWeight.w700,
            color: textDark),
        labelLarge:
            base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(color: textDark),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(color: textDark),
      ),
      // --- Claymorphism: superficies muy redondeadas que se ven "infladas"
      // gracias a una sombra suave y difusa (en vez de bordes duros), y
      // campos de texto "hundidos" (rellenos, sin borde) para dar
      // sensación de profundidad tipo plastilina/arcilla.
      cardTheme: CardThemeData(
        elevation: 10,
        shadowColor: scheme.primary.withOpacity(0.22),
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.primary.withOpacity(0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.primary.withOpacity(0.8)),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: scheme.primary,
        backgroundColor: scheme.primary.withOpacity(0.08),
        labelStyle: const TextStyle(
            fontSize: 12.5, color: textDark, fontWeight: FontWeight.w500),
        secondaryLabelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        elevation: 3,
        pressElevation: 1,
        shadowColor: scheme.primary.withOpacity(0.3),
        shape: const StadiumBorder(side: BorderSide.none),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        checkmarkColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          elevation: 6,
          shadowColor: scheme.primary.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          backgroundColor: Colors.white,
          side: BorderSide.none,
          elevation: 3,
          shadowColor: scheme.primary.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: coral,
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.white,
      ),
      dividerTheme: DividerThemeData(color: scheme.primary.withOpacity(0.1)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      visualDensity: VisualDensity.comfortable,
    );
  }

  /// Colores consistentes para avatares con iniciales de paciente.
  static Color avatarColorFor(String seedText) {
    const palette = [
      seed,
      coral,
      lavender,
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFF10B981),
    ];
    final idx = seedText.isEmpty ? 0 : seedText.codeUnitAt(0) % palette.length;
    return palette[idx];
  }
}
