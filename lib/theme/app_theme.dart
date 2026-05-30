import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0D0A07);
  static const sand = Color(0xFFC8A96E);
  static const gold = Color(0xFFF5C518);
  static const water = Color(0xFF4AABDB);
  static const anima = Color(0xFF2E6EFF);
  static const danger = Color(0xFFE84545);
  static const enemyHit = Color(0xFFF0D060);
  static const poison = Color(0xFF4CAF50);
  static const thirst = Color(0xFFFF8C00);
  static const bossPhase2 = Color(0xFFFF4500);
  static const disabled = Color(0xFF555555);
  static const text = Color(0xFFF0E8D8);
  static const subtext = Color(0xFF9E8E78);
  static const panelBg = Color(0xFF1A1208);
  static const panelBorder = Color(0xFF4A3820);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.water,
          surface: AppColors.panelBg,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.cinzel(
              fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gold),
          titleLarge: GoogleFonts.cinzel(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
          titleMedium: GoogleFonts.cinzel(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
          bodyLarge:
              GoogleFonts.notoSans(fontSize: 15, color: AppColors.text),
          bodyMedium:
              GoogleFonts.notoSans(fontSize: 13, color: AppColors.subtext),
          labelLarge: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text),
        ),
      );

  static TextStyle title(
          {double size = 24,
          Color color = AppColors.gold,
          double spacing = 2}) =>
      GoogleFonts.cinzel(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: spacing);

  static TextStyle body(
          {double size = 14, Color color = AppColors.text}) =>
      GoogleFonts.notoSans(fontSize: size, color: color);

  static TextStyle damage({bool isCrit = false}) => GoogleFonts.cinzel(
      fontSize: isCrit ? 28 : 22,
      fontWeight: FontWeight.w900,
      color: AppColors.danger);

  static TextStyle enemyDamage({bool isCrit = false}) => GoogleFonts.cinzel(
      fontSize: isCrit ? 26 : 20,
      fontWeight: FontWeight.w900,
      color: AppColors.enemyHit);
}
