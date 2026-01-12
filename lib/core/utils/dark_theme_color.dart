import 'package:flutter/material.dart';

class DarkThemeColors {
  static const Color primaryColor = Color(0xFF22C55E); // Brighter green for dark theme visibility
  static const Color accentColor = Color(0xFFFBBF24); // Brighter gold/yellow for dark theme
  static const Color backgroundColor = Color(0xFF0F172A); // Dark slate background
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFF94A3B8); // Slate gray
  static const Color cardColor = Color(0xFF1E293B); // Dark card background
  static const Color sidebarColor = Color(0xFF1E293B); // Sidebar background
  static const Color navItemColor = Color(0xFF334155); // Navigation item background
  static const Color navItemActiveColor = Color(0xFF22C55E); // Active nav item (bright green)
  static const Color successColor = Color(0xFF22C55E); // Bright green for success
  static const Color warningColor = Color(0xFFFBBF24); // Bright gold for warning
  static const Color errorColor = Color(0xFFEF4444); // Bright red for error
  static const Color borderColor = Color(0xFF334155); // Border color
  static const Color snackbarBackgroundColor = Color(0xFF334155);
  static const Color snackbarTextColor = Colors.white;
  
  // Additional logo colors for specific use cases (adjusted for dark theme)
  static const Color logoRed = Color(0xFFEF4444); // Brighter red for dark theme
  static const Color logoBlack = Color(0xFF1F2937); // Dark gray instead of pure black
  static const Color logoGold = Color(0xFFFBBF24); // Bright gold for dark theme
  static const Color logoGreen = Color(0xFF22C55E); // Bright green for dark theme

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
      case 'logoGreen':
        return logoGreen;
      default:
        return primaryColor;
    }
  }
}