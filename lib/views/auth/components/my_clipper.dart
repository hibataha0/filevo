
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
class SideShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    path_0.moveTo(-258.968, 170.541);
    path_0.cubicTo(
        -259.874, 204.334, -241.675, 251.123, -204.212, 242.675);
    path_0.cubicTo(
        -175.895, 236.29, -201.661, 204.154, -166.84, 185.981);
    path_0.cubicTo(
        -132.019, 167.807, -86.5901, 173.269, -64.8614, 203.192);
    path_0.cubicTo(
        -48.8608, 225.226, -77.2195, 246.254, -64.8614, 270.01);
    path_0.cubicTo(
        -36.4556, 324.615, 104.444, 312.594, 109.834, 252.799);
    path_0.cubicTo(
        113.407, 213.164, 58.2306, 207.401, 41.1728, 170.541);
    path_0.cubicTo(
        20.4472, 125.757, 62.936, 85.6182, 29.2946, 47.2812);
    path_0.cubicTo(
        3.85339, 18.2889, -25.2008, -8.84112, -64.8614, 2.73538);
    path_0.cubicTo(
        -116.369, 17.77, -15.6103, 104.234, -64.8614, 124.224);
    path_0.cubicTo(
        -87.7427, 133.511, -104.512, 127.469, -129.467, 124.224);
    path_0.cubicTo(
        -159.972, 120.257, -174.289, 95.4283, -204.212, 101.951);
    path_0.cubicTo(
        -240.481, 109.857, -258.092, 137.893, -258.968, 170.541);
    path_0.close();

    return path_0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}