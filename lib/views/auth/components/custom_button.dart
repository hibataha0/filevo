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
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive width
    double buttonWidth;
    if (Responsive.isDesktop(context)) {
      buttonWidth = 60;
    } else if (Responsive.isTablet(context)) {
      buttonWidth = 50;
    } else {
      buttonWidth = 45;
    }

    // Responsive height
    double buttonHeight;
    if (Responsive.isDesktop(context)) {
      buttonHeight = 60;
    } else if (Responsive.isTablet(context)) {
      buttonHeight = 50;
    } else {
      buttonHeight = 35;
    }

    // Icon size responsive
    double iconSize;
    if (Responsive.isDesktop(context)) {
      iconSize = 28;
    } else if (Responsive.isTablet(context)) {
      iconSize = 24;
    } else {
      iconSize = 20;
    }

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
