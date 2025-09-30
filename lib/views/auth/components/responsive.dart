import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';

/// دوال مساعدة للتعامل مع الأحجام المتجاوبة
class ResponsiveHelpers {
  
  /// حجم خط العنوان الرئيسي (نسبة من عرض الشاشة)
  static double getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    final percentage = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.12,
      tablet: 0.06,
      desktop: 0.05,
    );
    
    return width * percentage;
  }

  /// حجم خط العنوان الفرعي (نسبة من عرض الشاشة)
  static double getSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    final percentage = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.035,
      tablet: 0.06,
      desktop: 0.015,
    );
    
    return width * percentage;
  }

  /// حجم خط كبير مع حد أقصى وأدنى
  static double getBigFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    final percentage = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.08,
      tablet: 0.04,
      desktop: 0.03,
    );
    
    final size = width * percentage;
    return size.clamp(14.0, 24.0);
  }

  /// Padding متجاوب من الجانب الأيمن
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    final percentage = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.05,
      tablet: 0.08,
      desktop: 0.10,
    );
    
    return EdgeInsets.only(right: width * percentage);
  }

  /// حجم خط ثابت للحقول
  static double getFieldFontSize() {
    return 16.0;
  }

  /// عرض الصورة الجانبية (نسبة من عرض الشاشة)
  static double getSideImageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    final percentage = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.6,
      tablet: 0.4,
      desktop: 0.3,
    );
    
    return width * percentage;
  }

  /// ارتفاع الصورة الجانبية (نسبة من ارتفاع الشاشة)
  static double getSideImageHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    final percentage = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.2,
      tablet: 0.25,
      desktop: 0.3,
    );
    
    return height * percentage;
  }

  /// Padding عام متجاوب (أفقي)
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 20.0,
        tablet: 40.0,
        desktop: 60.0,
      ),
    );
  }

  /// Padding عام متجاوب (عمودي)
  static EdgeInsets getVerticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 10.0,
        tablet: 15.0,
        desktop: 20.0,
      ),
    );
  }

  /// Padding شامل
  static EdgeInsets getAllPadding(BuildContext context) {
    return EdgeInsets.all(
      ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 20.0,
        tablet: 40.0,
        desktop: 60.0,
      ),
    );
  }

  /// مسافة عمودية متجاوبة
  static double getVerticalSpacing(BuildContext context) {
    return ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 30.0,
      desktop: 40.0,
    );
  }

  /// مسافة أفقية متجاوبة
  static double getHorizontalSpacing(BuildContext context) {
    return ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 15.0,
      desktop: 20.0,
    );
  }
}

// ملاحظة: يمكنك استخدام هذه الدوال مباشرة بدون إنشاء instance
// مثال:
// Text(
//   'Hello',
//   style: TextStyle(
//     fontSize: ResponsiveHelpers.getTitleFontSize(context),
//   ),
// )