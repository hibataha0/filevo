import 'package:flutter/material.dart';

/// ✅ ملف الألوان الثابتة للتطبيق
/// يدعم Light Mode و Dark Mode

class AppColors {
  // ✅ Light Mode Colors
  static const Color lightPrimary = Color(0xff28336f);
  static const Color lightBackground = Color(0xFFE9E9E9);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightSurface = Color(0xFFF8EFFE);
  static const Color lightAppBar = Color(0xff28336f);
  static const Color priii = Color(0xFF00BFA5);

  // ✅ Dark Mode Colors
  static const Color darkPrimary = Color(0xFF1E88E5);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkAppBar = Color(0xFF1E1E1E);

  // ✅ Common Colors (تستخدم في كلا المودين)
  static const Color accent = Color(0xFF4285F4);
  static const Color error = Color(0xFFEA4335);
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFF6D00);

  // ✅ Helper method للحصول على الألوان حسب المود
  static Color getPrimary(bool isDarkMode) {
    return isDarkMode ? darkPrimary : lightPrimary;
  }

  static Color getBackground(bool isDarkMode) {
    return isDarkMode ? darkBackground : lightBackground;
  }

  static Color getCardBackground(bool isDarkMode) {
    return isDarkMode ? darkCardBackground : lightCardBackground;
  }

  static Color getTextPrimary(bool isDarkMode) {
    return isDarkMode ? darkTextPrimary : lightTextPrimary;
  }

  static Color getTextSecondary(bool isDarkMode) {
    return isDarkMode ? darkTextSecondary : lightTextSecondary;
  }

  static Color getSurface(bool isDarkMode) {
    return isDarkMode ? darkSurface : lightSurface;
  }

  static Color getAppBar(bool isDarkMode) {
    return isDarkMode ? darkAppBar : lightAppBar;
  }

  // ✅ Helper method للحصول على المود من context
  static bool isDarkMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }
}
