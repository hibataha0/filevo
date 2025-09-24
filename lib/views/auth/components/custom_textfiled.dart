import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.fontSize = 16,
    this.prefixIcon,
  });

  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final double fontSize;
  final IconData? prefixIcon;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // حجم الخط مع حد أقصى
    double actualFontSize = widget.fontSize;
    if (actualFontSize > 24) actualFontSize = 24;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.isPassword ? _obscureText : false,
          style: TextStyle(fontSize: actualFontSize),
          enableInteractiveSelection: widget.isPassword ? false : true,
          contextMenuBuilder: widget.isPassword
              ? (context, editableTextState) => const SizedBox.shrink()
              : null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: actualFontSize * 0.9,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

            // أيقونة على الشمال
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: Colors.grey[600])
                : null,

            // زر إظهار/إخفاء الباسورد
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
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
    );
  }
}
