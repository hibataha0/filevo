import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';
import 'package:filevo/constants/app_colors.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double? thickness;
  final Color? dividerColor;
  final TextStyle? textStyle;
  final double? horizontalPadding;

  const DividerWithText({
    super.key,
    required this.text,
    this.thickness,
    this.dividerColor,
    this.textStyle,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Responsive thickness للخط
    final lineThickness = thickness ?? ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.7,
      tablet: 0.8,
      desktop: 1.0,
    );

    // Responsive padding حول النص
    final textPadding = horizontalPadding ?? ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 12.0,
      desktop: 15.0,
    );

    // Responsive font size
    final fontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 15.0,
      desktop: 16.0,
    );

    final defaultDividerColor = dividerColor ?? AppColors.darkSurface;
    final defaultTextColor = textStyle?.color ?? AppColors.getTextSecondary(isDarkMode);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 20.0,
          tablet: 40.0,
          desktop: 60.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(
              thickness: lineThickness,
              color: defaultDividerColor.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: textPadding,
            ),
            child: Text(
              text,
              style: textStyle ?? TextStyle(
                color: defaultTextColor,
                fontSize: fontSize,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: lineThickness,
              color: defaultDividerColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}