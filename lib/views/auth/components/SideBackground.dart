
import 'package:filevo/views/auth/components/my_clipper.dart';
import 'package:flutter/material.dart';


class SideBackground extends StatelessWidget {
  const SideBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SideShapeClipper(),
      child: Container(
        width: 250,   // ممكن تتحكم بالحجم حسب التصميم
        height: 400,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff33BCB9), Color(0xff28336F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
