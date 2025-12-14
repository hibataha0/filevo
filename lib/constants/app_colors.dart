import 'package:flutter/material.dart';

/// ✅ ملف الألوان الثابتة للتطبيق
/// نظام ألوان متناسق - جميع الألوان ثابتة ويتم الوصول إليها من Theme

class AppColors {
  // ✅ اللون الأساسي للتطبيق (Primary Brand Color)
  static const Color brandPrimary = Color(0xFF28336F);

  // ✅ Light Mode Colors - نظام متناسق
  static const Color lightPrimary = Color(0xFF28336F);
  static const Color lightPrimaryVariant = Color(0xFF1A2550);
  static const Color lightSecondary = Color(0xFF4A90E2);
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F9FB);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightAppBar = Color(0xFF28336F);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // ✅ Dark Mode Colors - نظام متناسق
  static const Color darkPrimary = Color(0xFF4A90E2);
  static const Color darkPrimaryVariant = Color(0xFF5BA0F2);
  static const Color darkSecondary = Color(0xFF6BA3E8);
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkCardBackground = Color(0xFF1A1F2E);
  static const Color darkSurface = Color(0xFF1E2532);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF2D3748);
  static const Color darkAppBar = Color(0xFF1A1F2E);
  static const Color darkBorder = Color(0xFF2D3748);

  // ✅ Common Colors (ثابتة في كلا المودين)
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF4A90E2);

  // ✅ ألوان الظلال
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
}

/// ✅ Extension للوصول السهل للألوان من Theme
extension AppThemeColors on BuildContext {
  // ✅ الألوان الأساسية
  Color get appPrimary => Theme.of(this).colorScheme.primary;
  Color get appSecondary => Theme.of(this).colorScheme.secondary;
  Color get appBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get appCardBackground => Theme.of(this).cardColor;
  Color get appSurface => Theme.of(this).colorScheme.surface;

  // ✅ ألوان النصوص
  Color get appTextPrimary => Theme.of(this).textTheme.bodyLarge!.color!;
  Color get appTextSecondary => Theme.of(this).textTheme.bodySmall!.color!;

  // ✅ ألوان أخرى
  Color get appDivider => Theme.of(this).dividerColor;
  Color get appBorder => Theme.of(this).brightness == Brightness.dark
      ? AppColors.darkBorder
      : AppColors.lightBorder;

  // ✅ ألوان الحالة (ثابتة)
  Color get appError => AppColors.error;
  Color get appSuccess => AppColors.success;
  Color get appWarning => AppColors.warning;
  Color get appInfo => AppColors.info;

  // ✅ Helper للتحقق من الوضع الداكن
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
