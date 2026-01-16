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
  // static const Color priii = Colors.grey[500];

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

  // ✅ Shimmer Colors (للتحميل)
  static const Color shimmerBaseLight = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5); // Colors.grey[100]
  static const Color shimmerBaseDark = Color(0xFF424242); // Colors.grey[800]
  static const Color shimmerHighlightDark = Color(0xFF616161); // Colors.grey[700]

  // ✅ Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // Colors.black.withOpacity(0.1)
  static const Color shadowDark = Color(0x4D000000); // Colors.black.withOpacity(0.3)

  // ✅ Card Colors
  static const Color cardWhite = Color(0xFFFFFFFF); // Colors.white

  // ✅ Grey Shades (للنصوص والأيقونات)
  static const Color grey600 = Color(0xFF757575); // Colors.grey[600]

  // ✅ Storage Card Colors
  static const Color storageCircle = Color(0xFF26A69A); // لون الدائرة الداخلية
  static const Color storageUsedIndicator = Color(0xFF00BFA5); // لون مؤشر المساحة المستخدمة
  static const Color storageAvailableIndicator = Color(0xB3FFFFFF); // Colors.white.withOpacity(0.7)
  
  // ✅ Gradient Colors for Storage Card
  static const Color storageGradientStartLight = Color(0x99FFFFFF); // Colors.white.withOpacity(0.6)
  static const Color storageGradientEndLight = Color(0x00FFFFFF); // Colors.white.withOpacity(0.001)
  static const Color storageGradientStartDark = Color(0xE61E1E1E); // darkCardBackground.withOpacity(0.9)
  static const Color storageGradientEndDark = Color(0xB31E1E1E); // darkCardBackground.withOpacity(0.7)
  
  // ✅ Border Colors for Storage Card
  static const Color storageBorderLight = Color(0x33FFFFFF); // Colors.white.withOpacity(0.2)
  static const Color storageBorderDark = Color(0x1AFFFFFF); // Colors.white.withOpacity(0.1)
  
  // ✅ Text Colors for Storage Card
  static const Color storageTextLight = Color(0xFFFFFFFF); // Colors.white
  static const Color storageTextSecondaryLight = Color(0xCCFFFFFF); // Colors.white.withOpacity(0.8)

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

  // ✅ Helper methods للـ Shimmer
  static Color getShimmerBase(bool isDarkMode) {
    return isDarkMode ? shimmerBaseDark : shimmerBaseLight;
  }

  static Color getShimmerHighlight(bool isDarkMode) {
    return isDarkMode ? shimmerHighlightDark : shimmerHighlightLight;
  }

  // ✅ Helper methods للـ Shadows
  static Color getShadow(bool isDarkMode) {
    return isDarkMode ? shadowDark : shadowLight;
  }

  // ✅ Helper methods للـ Cards
  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? darkCardBackground : cardWhite;
  }

  // ✅ Helper methods للـ Storage Card Gradient
  static List<Color> getStorageGradient(bool isDarkMode) {
    return isDarkMode
        ? [storageGradientStartDark, storageGradientEndDark]
        : [storageGradientStartLight, storageGradientEndLight];
  }

  // ✅ Helper methods للـ Storage Card Border
  static Color getStorageBorder(bool isDarkMode) {
    return isDarkMode ? storageBorderDark : storageBorderLight;
  }

  // ✅ Helper methods للـ Storage Card Text
  static Color getStorageText(bool isDarkMode) {
    return isDarkMode ? darkTextPrimary : storageTextLight;
  }

  static Color getStorageTextSecondary(bool isDarkMode) {
    return isDarkMode ? darkTextSecondary : storageTextSecondaryLight;
  }

  static Color getStorageAvailableIndicator(bool isDarkMode) {
    return isDarkMode 
        ? Colors.white.withOpacity(0.5)
        : storageAvailableIndicator;
  }

  // ✅ Helper method للحصول على المود من context
  static bool isDarkMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }
}
