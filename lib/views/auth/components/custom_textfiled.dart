import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive max width للحقل النصي
    final fieldWidth = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: screenWidth * 0.85,
      tablet: screenWidth * 0.6,
      desktop: 500.0,
    );

    // Responsive margin
    final horizontalMargin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 30.0,
      desktop: 40.0,
    );

    // Responsive content padding
    final verticalPadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 15.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    // Responsive border radius
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 25.0,
      tablet: 28.0,
      desktop: 30.0,
    );

    // Responsive icon size
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: fieldWidth,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 14.0,
                tablet: 15.0,
                desktop: 16.0,
              ),
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 15.0,
                  desktop: 16.0,
                ),
              ),
              prefixIcon: Icon(
                widget.icon,
                color: Colors.grey,
                size: iconSize,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: verticalPadding,
              ),
              // زر 👁 إذا كان Password
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: iconSize,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}