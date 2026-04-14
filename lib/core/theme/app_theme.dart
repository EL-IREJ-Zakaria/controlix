import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const Color _brandBlue = Color(0xFF3B82F6);
  static const Color _brandPurple = Color(0xFF7C3AED);
  static const Color _brandCyan = Color(0xFF06B6D4);
  static const Color _lightSurface = Color(0xFFF4F7FB);
  static const Color _darkSurface = Color(0xFF07111F);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandBlue,
      brightness: brightness,
      primary: _brandBlue,
      secondary: _brandPurple,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
    );

    final textTheme = GoogleFonts.soraTextTheme(base.textTheme).apply(
      bodyColor: isDark ? Colors.white : const Color(0xFF0F172A),
      displayColor: isDark ? Colors.white : const Color(0xFF0F172A),
    );

    return base.copyWith(
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.78),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark
              ? Colors.white.withValues(alpha: 0.55)
              : const Color(0xFF64748B),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.55),
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.78),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF111C2D)
            : const Color(0xFF0F172A),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          backgroundColor: _brandBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.08),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.86),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
      canvasColor: isDark ? _darkSurface : _lightSurface,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.42 : 0.12),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static List<Color> pageGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const <Color>[Color(0xFF040B17), Color(0xFF071425), Color(0xFF0B1832)]
        : const <Color>[
            Color(0xFFF4F7FB),
            Color(0xFFE9F1FF),
            Color(0xFFF5EEFF),
          ];
  }

  static List<Color> accentGradient(String accentHex) {
    final accent = Color(int.parse(accentHex.replaceFirst('#', '0xFF')));
    return <Color>[
      accent,
      Color.lerp(accent, _brandPurple, 0.5) ?? _brandPurple,
      Color.lerp(accent, _brandCyan, 0.3) ?? _brandCyan,
    ];
  }
}
