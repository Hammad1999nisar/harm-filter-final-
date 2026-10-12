import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HarmFilter design system.
///
/// Palette — a modern, trustworthy indigo/violet with a teal accent, plus
/// semantic colours for the three classes:
///   • Hate Speech        → red
///   • Offensive Language → amber
///   • Neither            → green
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5B4EE9); // indigo-violet
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color accent = Color(0xFF14B8A6); // teal

  // Semantic (class) colours
  static const Color hate = Color(0xFFE5484D); // red
  static const Color offensive = Color(0xFFF5A524); // amber
  static const Color neither = Color(0xFF30A46C); // green

  // Light surfaces
  static const Color lightBg = Color(0xFFF6F6FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A2E);

  // Dark surfaces
  static const Color darkBg = Color(0xFF0F1020);
  static const Color darkCard = Color(0xFF1B1C31);
  static const Color darkText = Color(0xFFECECF5);

  /// Colour for a given class label.
  static Color forLabel(String label) {
    switch (label) {
      case 'Hate Speech':
        return hate;
      case 'Offensive Language':
        return offensive;
      default:
        return neither;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: isDark ? AppColors.darkCard : AppColors.lightCard,
    );

    final Color bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final Color text = isDark ? AppColors.darkText : AppColors.lightText;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}
