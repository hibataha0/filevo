import 'package:filevo/views/auth/components/my_clipper.dart';
import 'package:flutter/material.dart';

class HeaderBackground extends StatelessWidget {
  const HeaderBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF28336F), Color(0xFF225878)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
