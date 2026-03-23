import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const green      = Color(0xFF2E7D32);
  static const greenDark  = Color(0xFF1B5E20);
  static const greenMid   = Color(0xFF4CAF50);
  static const greenLight = Color(0xFFE8F5E9);
  static const greenFaint = Color(0xFFF7FBF7);
  static const white      = Color(0xFFFFFFFF);
  static const bg         = Color(0xFFF6FAF6);
  static const ink        = Color(0xFF0F1A10);
  static const inkMid     = Color(0xFF3D4D3E);
  static const inkLight   = Color(0xFF8A9E8B);
  static const border     = Color(0xFFE2EDE2);
  static const red        = Color(0xFFC62828);
  static const amber      = Color(0xFFE65100);
  static const yellow     = Color(0xFFF57F17);
}

Color statusColor(double fill) {
  if (fill >= 90) return AppColors.red;
  if (fill >= 70) return AppColors.amber;
  if (fill >= 40) return AppColors.yellow;
  return AppColors.green;
}

String statusLabel(double fill) {
  if (fill >= 90) return 'Critical';
  if (fill >= 70) return 'High';
  if (fill >= 40) return 'Medium';
  return 'Low';
}

String statusMessage(double fill) {
  if (fill >= 90) return 'Needs immediate collection';
  if (fill >= 70) return 'Schedule collection soon';
  if (fill >= 40) return 'Monitor closely';
  return 'Plenty of space';
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: GoogleFonts.dmSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.greenFaint,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return GoogleFonts.dmMono(
          fontSize: 10,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w500
              : FontWeight.w400,
        );
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 48),
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
