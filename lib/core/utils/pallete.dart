import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/widgets/custom_typography/typography.dart';

/// =======================================
/// RealTime Capital Brand Colors
/// =======================================
class RealTimeColors {
  // Primary Brand Colors (from logo)
  static const Color primaryGreen = Color(0xFF38A169); // Logo green stroke
  static const Color darkGreen = Color(0xFF2F855A); // Darker green variant
  static const Color lightGreen = Color(0xFFC6F6D5); // Soft green background

  static const Color logoBlack = Color(0xFF1F2933); // "Real" text
  static const Color softBlack = Color(0xFF374151); // Subtitles
  static const Color logoWhite = Color(0xFFFFFFFF); // Background

  // Neutral / UI Greys
  static const Color grey100 = Color(0xFFF9FAFB);
  static const Color grey200 = Color(0xFFF3F4F6);
  static const Color grey300 = Color(0xFFE5E7EB);
  static const Color grey400 = Color(0xFFD1D5DB);
  static const Color grey500 = Color(0xFF9CA3AF);
  static const Color grey600 = Color(0xFF6B7280);
  static const Color grey700 = Color(0xFF4B5563);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Status Colors (Finance-safe)
  static const Color success = primaryGreen;
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
}

/// =======================================
/// App Color Abstraction
/// =======================================
class AppColors {
  static const Color backgroundColor = RealTimeColors.logoWhite;
  static const Color primaryColor = RealTimeColors.primaryGreen;
  static const Color secondaryColor = RealTimeColors.darkGreen;
  static const Color accentColor = RealTimeColors.primaryGreen;

  static const Color cardColor = RealTimeColors.grey100;
  static const Color surfaceColor = RealTimeColors.logoWhite;

  static const Color textColor = RealTimeColors.logoBlack;
  static const Color subtextColor = RealTimeColors.grey600;
  static const Color borderColor = RealTimeColors.grey300;

  static const Color successColor = RealTimeColors.success;
  static const Color warningColor = RealTimeColors.warning;
  static const Color errorColor = RealTimeColors.error;
}

/// =======================================
/// App Theme
/// =======================================
class Pallete {
  static ThemeData appTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    primaryColor: AppColors.primaryColor,

    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.accentColor,
      surface: AppColors.surfaceColor,
      background: AppColors.backgroundColor,
      error: AppColors.errorColor,
      onPrimary: RealTimeColors.logoWhite,
      onSecondary: RealTimeColors.logoWhite,
      onSurface: AppColors.textColor,
      onBackground: AppColors.textColor,
      onError: RealTimeColors.logoWhite,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceColor,
      foregroundColor: AppColors.textColor,
      iconTheme: const IconThemeData(color: AppColors.textColor),
      titleTextStyle: CustomTypography.nunitoTextTheme.titleMedium?.copyWith(
        color: AppColors.textColor,
        fontWeight: FontWeight.bold,
      ),
      elevation: 1,
      shadowColor: RealTimeColors.grey200,
    ),

    cardColor: AppColors.cardColor,

    textTheme: CustomTypography.nunitoTextTheme.apply(
      bodyColor: AppColors.textColor,
      displayColor: AppColors.textColor,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: RealTimeColors.logoWhite,
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: BorderSide(color: AppColors.primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.errorColor),
      ),
    ),

    dividerColor: AppColors.borderColor,
    iconTheme: IconThemeData(color: AppColors.textColor),
  );
}
