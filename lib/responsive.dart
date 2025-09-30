import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

class ResponsiveUtils {
  // الحصول على نوع الشاشة
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenType.mobile;
    } else if (width < 1024) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  // فحص نوع الشاشة
  static bool isMobile(BuildContext context) =>
      getScreenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenType(context) == ScreenType.desktop;

  // الحصول على قيمة responsive
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  // دالة إضافية مفيدة: الحصول على قيمة مع fallback للـ tablet
  static T getResponsiveWidget<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop;
    }
  }
}
