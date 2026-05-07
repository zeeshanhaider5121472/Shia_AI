import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0B0E17);
  static const surface = Color(0xFF111827);
  static const accent = Color(0xFF818CF8);
  static const accentSoft = Color(0xFF6366F1);
  static const textPrimary = Color(0xF0FFFFFF);
  static const textSecondary = Color(0x99FFFFFF);
  static const textMuted = Color(0x52FFFFFF);
  static const glass = Color(0x0FFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);
  static const divider = Color(0x14FFFFFF);
}

class AppStyles {
  // ── English: Plus Jakarta Sans (modern, geometric, clean) ──
  static TextStyle heading({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.7,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textSecondary,
        height: height,
      );

  static TextStyle caption({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textMuted,
      );

  // ── Arabic: Amiri (beautiful Naskh, perfect for Quran)
  //    Swap 'Amiri' with 'Al Qalam Quran Majeed' if you add the custom font ──
  static TextStyle arabic({
    double size = 24,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 2.1,
  }) =>
      GoogleFonts.amiri(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height,
      );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
      );
}
