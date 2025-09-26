 // ... (جميع دوال الـ get... هنا كما هي)
  import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';

double getTitleFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Responsive.isDesktop(context)) {
      return width * 0.05;
    } else if (Responsive.isTablet(context)) {
      return width * 0.06;
    } else {
      return width * 0.12;
    }
  }

  double getSubtitleFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Responsive.isDesktop(context)) {
      return width * 0.015;
    } else if (Responsive.isTablet(context)) {
      return width * 0.06;
    } else {
      return width * 0.035;
    }
  }

  double getBigFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double size;
    if (Responsive.isDesktop(context)) {
      size = width * 0.03;
    } else if (Responsive.isTablet(context)) {
      size = width * 0.04;
    } else {
      size = width * 0.08;
    }

    return size.clamp(14, 24);
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Responsive.isDesktop(context)) {
      return EdgeInsets.only(right: width * 0.1);
    } else if (Responsive.isTablet(context)) {
      return EdgeInsets.only(right: width * 0.08);
    } else {
      return EdgeInsets.only(right: width * 0.05);
    }
  }

  double getFieldFontSize() {
    return 16;
  }

  double getSideImageWidth(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return MediaQuery.of(context).size.width * 0.3;
    } else if (Responsive.isTablet(context)) {
      return MediaQuery.of(context).size.width * 0.4;
    } else {
      return MediaQuery.of(context).size.width * 0.6;
    }
  }

  double getSideImageHeight(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return MediaQuery.of(context).size.height * 0.3;
    } else if (Responsive.isTablet(context)) {
      return MediaQuery.of(context).size.height * 0.25;
    } else {
      return MediaQuery.of(context).size.height * 0.2;
    }
  }
