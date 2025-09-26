// lib/widgets/divider_with_text.dart
import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double thickness;
  final Color dividerColor;
  final TextStyle? textStyle;
  final double horizontalPadding;

  const DividerWithText({
    super.key,
    required this.text,
    this.thickness = 0.7,
    this.dividerColor = Colors.grey,
    this.textStyle,
    this.horizontalPadding = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: thickness,
            color: dividerColor.withOpacity(0.5),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: horizontalPadding,
          ),
          child: Text(
            text,
            style: textStyle ?? const TextStyle(
              color: Color.fromARGB(115, 2, 2, 2),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: thickness,
            color: dividerColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}