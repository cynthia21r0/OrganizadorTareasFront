import 'package:flutter/material.dart';
import 'app_accent.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─── Colores fijos del tema oscuro (sin acento) ──────────────────────────
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _darkCard = Color(0xFF1E293B);
  static const Color _darkCardAlt = Color(0xFF263548);
  static const Color _darkTextPrimary = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);

  // Helpers públicos para widgets que los necesitan directamente.
  static Color darkCard = _darkCard;
  static Color darkNavBg = _darkCard;
  static Color darkTextPrimary = _darkTextPrimary;
  static Color darkTextSecondary = _darkTextSecondary;
  static Color get darkAccent => AppAccent.azul.primary; // fallback estático

  // ─── Fábricas dinámicas ──────────────────────────────────────────────────

  static ThemeData lightThemeFor(AppAccent accent) {
    final primary = accent.primary;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: AppColors.fabPurple,
        surface: AppColors.background,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        iconTheme: IconThemeData(color: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData darkThemeFor(AppAccent accent) {
    final primary = accent.primary;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primary,
        primary: primary,
        secondary: AppColors.fabPurple,
        surface: _darkCard,
        onSurface: _darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        foregroundColor: _darkTextPrimary,
        centerTitle: false,
        iconTheme: IconThemeData(color: primary),
      ),
      cardColor: _darkCard,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCardAlt,
        hintStyle: const TextStyle(color: _darkTextSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: _darkTextPrimary,
        ),
        bodyMedium: TextStyle(color: _darkTextPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : _darkTextSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.35)
              : _darkCardAlt,
        ),
      ),
    );
  }

  // ─── Backwards-compat getters (usados antes del sistema de acentos) ──────
  static ThemeData get lightTheme => lightThemeFor(AppAccent.azul);
  static ThemeData get darkTheme => darkThemeFor(AppAccent.azul);
}
