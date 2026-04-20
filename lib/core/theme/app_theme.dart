import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const Color _signalOrange = Color(0xFFF97316);
  static const Color _circuitTeal = Color(0xFF14B8A6);
  static const Color _inkDark = Color(0xFF09111D);
  static const Color _fogLight = Color(0xFFF5F1E8);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _signalOrange,
      brightness: brightness,
    );
    final colorScheme = baseScheme.copyWith(
      primary: _signalOrange,
      secondary: _circuitTeal,
      surface: isDark ? const Color(0xFF111A28) : const Color(0xFFFDF8F0),
      onSurface: isDark ? const Color(0xFFF8F5EF) : const Color(0xFF121A24),
      outline: isDark ? const Color(0xFF2A3950) : const Color(0xFFD3C9BB),
      surfaceContainerHighest: isDark
          ? const Color(0xFF172232)
          : const Color(0xFFF1E9DD),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
    );

    final bodyTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final displayTheme = GoogleFonts.spaceGroteskTextTheme(bodyTheme);

    return base.copyWith(
      textTheme: displayTheme.copyWith(
        displayLarge: displayTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -2.8,
          height: 0.94,
        ),
        displaySmall: displayTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.6,
          height: 0.98,
        ),
        headlineMedium: displayTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        titleLarge: displayTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: bodyTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
        ),
        bodyLarge: bodyTheme.bodyLarge?.copyWith(height: 1.55),
        bodyMedium: bodyTheme.bodyMedium?.copyWith(height: 1.48),
        labelLarge: bodyTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF121C2B).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.86),
        hintStyle: bodyTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.46),
        ),
        labelStyle: bodyTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.74),
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: colorScheme.onSurface.withValues(alpha: 0.68),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.70 : 0.62),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.82),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF111A28)
            : const Color(0xFF16202E),
        contentTextStyle: bodyTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: bodyTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.68 : 0.54),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: bodyTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: isDark
            ? const Color(0xFF172232)
            : const Color(0xFFF0E7DB),
        selectedColor: colorScheme.primary.withValues(alpha: 0.16),
        labelStyle: bodyTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerColor: colorScheme.outline.withValues(alpha: isDark ? 0.42 : 0.60),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
      cardTheme: CardThemeData(
        color: isDark
            ? const Color(0xFF111A28).withValues(alpha: 0.86)
            : Colors.white.withValues(alpha: 0.82),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      canvasColor: isDark ? _inkDark : _fogLight,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.34 : 0.10),
    );
  }

  static List<Color> pageGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const <Color>[Color(0xFF080D16), Color(0xFF0D1522), Color(0xFF152232)]
        : const <Color>[
            Color(0xFFF6F1E8),
            Color(0xFFECE4D8),
            Color(0xFFF8F5EE),
          ];
  }

  static List<Color> accentGradient(String accentHex) {
    final accent = Color(int.parse(accentHex.replaceFirst('#', '0xFF')));
    return <Color>[
      accent,
      Color.lerp(accent, _signalOrange, 0.35) ?? _signalOrange,
      Color.lerp(accent, _circuitTeal, 0.28) ?? _circuitTeal,
    ];
  }
}
