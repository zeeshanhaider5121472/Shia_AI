import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static bool isDark = true;

  static Color get bg =>
      isDark ? const Color(0xFF0B0E17) : const Color(0xFFF2F2F7);

  static Color get surface =>
      isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);

  static const accent = Color(0xFF818CF8);

  static Color get textPrimary =>
      isDark ? const Color(0xF0FFFFFF) : const Color(0xFF1C1C1E);

  static Color get textSecondary =>
      isDark ? const Color(0x99FFFFFF) : const Color(0xCC1C1C1E);

  static Color get textMuted =>
      isDark ? const Color(0x52FFFFFF) : const Color(0x991C1C1E);

  static Color get glass =>
      isDark ? const Color(0x0FFFFFFF) : const Color(0xD9FFFFFF);

  static Color get glassBorder =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0x1F000000);

  static Color get divider =>
      isDark ? const Color(0x14FFFFFF) : const Color(0x1F000000);
}

class AppStyles {
  static String fontFamily = 'Plus Jakarta Sans';
  static String arabicFontFamily = 'Amiri';
  static double fontScale = 1.0;

  static TextStyle heading({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) =>
      GoogleFonts.getFont(
        fontFamily,
        fontSize: size * fontScale,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.7,
  }) =>
      GoogleFonts.getFont(
        fontFamily,
        fontSize: size * fontScale,
        fontWeight: weight,
        color: color ?? AppColors.textSecondary,
        height: height,
      );

  static TextStyle caption({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) =>
      GoogleFonts.getFont(
        fontFamily,
        fontSize: size * fontScale,
        fontWeight: weight,
        color: color ?? AppColors.textMuted,
      );

  static TextStyle arabic({
    double size = 24,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 2.1,
  }) =>
      GoogleFonts.getFont(
        arabicFontFamily,
        fontSize: size * fontScale,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height,
      );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.getTextTheme(
            AppStyles.fontFamily, ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xF0FFFFFF)),
        ),
        colorScheme: const ColorScheme.dark(primary: AppColors.accent),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        textTheme: GoogleFonts.getTextTheme(
            AppStyles.fontFamily, ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          surface: Color(0xFFFFFFFF),
        ),
      );
}
