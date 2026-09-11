import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// هوية الألوان مستوحاة من لوجو "أبو أروى"
/// كحلي أساسي + برتقالي كلون مساعد (Accent)
/// عند رفع ملف اللوجو الرسمي يمكن تعديل هذه القيم لتطابقه تمامًا (Hex Code دقيق)
class AppColors {
  static const Color primaryNavy = Color(0xFF1B3A5C);
  static const Color primaryNavyDark = Color(0xFF122A44);
  static const Color accentOrange = Color(0xFFE8804A);
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1D1D1D);
  static const Color textGray = Color(0xFF6B7280);
  static const Color danger = Color(0xFFD64545);
  static const Color success = Color(0xFF2E9E5B);
  static const Color border = Color(0xFFE3E6EA);
}

class AppTheme {
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.cairoTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryNavy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryNavy,
        primary: AppColors.primaryNavy,
        secondary: AppColors.accentOrange,
        surface: AppColors.cardWhite,
      ),
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryNavy, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
