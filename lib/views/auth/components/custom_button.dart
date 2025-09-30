import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';

class IconButtonGradient extends StatelessWidget {
  const IconButtonGradient({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Responsive width
    final buttonWidth = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 45.0,
      tablet: 50.0,
      desktop: 60.0,
    );

    // Responsive height
    final buttonHeight = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 35.0,
      tablet: 50.0,
      desktop: 60.0,
    );

    // Icon size responsive
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFED6EA0),
                Color(0xFF8E54E9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}