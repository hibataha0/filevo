
import 'package:flutter/material.dart';

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    path_0.moveTo(91.9756, 118.946);
    path_0.cubicTo(54.6807, 117.406, 45.3404, 74.8318, 8.04627, 73.2746);
    path_0.cubicTo(4.51657, 73.1272, -1, 73.2746, -1, 73.2746);
    path_0.lineTo(-1, 0);
    path_0.lineTo(size.width, 0);
    path_0.cubicTo(size.width, 0, size.width * 0.93, 43.327, size.width * 0.85, 59.7238);
    path_0.cubicTo(size.width * 0.74, 89.6039, size.width * 0.63, 43.3626, size.width * 0.49, 59.7238);
    path_0.cubicTo(size.width * 0.38, 72.9649, size.width * 0.35, 120.832, 91.9756, 118.946);
    path_0.close();

    return path_0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
