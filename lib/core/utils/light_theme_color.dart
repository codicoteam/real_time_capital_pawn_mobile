import 'package:flutter/material.dart';

class LightThemeColors {
  static const Color primaryColor = Color(0xFF1B7F3C); // Green from logo
  static const Color accentColor = Color(0xFFE8B923); // Gold/Yellow from logo
  static const Color backgroundColor = Color(0xFFF8FAFC); // Light slate background
  static const Color textColor = Color(0xFF0F172A); // Dark text
  static const Color secondaryTextColor = Color(0xFF64748B); // Slate gray
  static const Color cardColor = Color(0xFFFFFFFF); // White card background
  static const Color sidebarColor = Color(0xFFFFFFFF); // White sidebar background
  static const Color navItemColor = Color(0xFFF1F5F9); // Light navigation item background
  static const Color navItemActiveColor = Color(0xFF1B7F3C); // Active nav item (green from logo)
  static const Color successColor = Color(0xFF1B7F3C); // Green from logo for success
  static const Color warningColor = Color(0xFFE8B923); // Gold/Yellow from logo for warning
  static const Color errorColor = Color(0xFFDC2626); // Red from logo
  static const Color borderColor = Color(0xFFE2E8F0); // Light border color
  static const Color snackbarBackgroundColor = Color(0xFFFFFFFF);
  static const Color snackbarTextColor = Colors.black;
  
  // Additional logo colors for specific use cases
  static const Color logoRed = Color(0xFFDC2626); // Red from logo
  static const Color logoBlack = Color(0xFF000000); // Black from logo
  static const Color logoGold = Color(0xFFE8B923); // Gold/Yellow from logo

  static Color getColor(String colorType) {
    switch (colorType) {
      case 'background':
        return backgroundColor;
      case 'text':
        return textColor;
      case 'secondaryText':
        return secondaryTextColor;
      case 'card':
        return cardColor;
      case 'border':
        return borderColor;
      case 'primary':
        return primaryColor;
      case 'warning':
        return warningColor;
      case 'error':
        return errorColor;
      case 'success':
        return successColor;
      case 'accent':
        return accentColor;
      case 'logoRed':
        return logoRed;
      case 'logoBlack':
        return logoBlack;
      case 'logoGold':
        return logoGold;
      default:
        return primaryColor;
    }
  }
}