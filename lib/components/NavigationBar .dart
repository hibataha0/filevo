import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MyBottomBar extends StatelessWidget {
  final Function(int) onTap;
  final int selectedIndex;

  MyBottomBar({required this.onTap, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    return Container(
      color: Colors.transparent, // خلفية شفافة
      height: 80,
      child: Stack(
        children: [
          // الشكل المخصص للبار
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(width, 80),
              painter: RPSCustomPainter(),
            ),
          ),
          
          // الأيقونات السفلية
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildItem(Icons.home_outlined, 0),
                  _buildItem(Icons.folder_outlined, 1),
                  SizedBox(width: 40), // مكان للزر العائم
                  _buildItem(Icons.person_outline_outlined, 2),
                  _buildItem(Icons.settings_outlined, 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, int index) {
    Color color = selectedIndex == index ? Color(0xFF00BFA5) : Colors.black;
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.9437939, 0);
    path_0.cubicTo(size.width * 0.9748361, size.height * 0.04268200, size.width, size.height * 0.1343150, size.width, size.height * 0.3000000);
    path_0.lineTo(size.width, size.height * 0.7000000);
    path_0.cubicTo(size.width, size.height * 0.8656850, size.width * 0.9748361, size.height, size.width * 0.9437939, size.height);
    path_0.lineTo(size.width * 0.04918033, size.height);
    path_0.cubicTo(size.width * 0.01813857, size.height, size.width * -0.007025761, size.height * 0.8656850, size.width * -0.007025761, size.height * 0.7000000);
    path_0.lineTo(size.width * -0.007025761, size.height * 0.3000000);
    path_0.cubicTo(size.width * -0.007025761, size.height * 0.1343150, size.width * 0.01813857, 0, size.width * 0.04918033, 0);
    path_0.lineTo(size.width * 0.3512881, 0);
    path_0.cubicTo(size.width * 0.4426230, size.height * 0.08750000, size.width * 0.4397681, size.height * 0.4000000, size.width * 0.4964871, size.height * 0.4000000);
    path_0.cubicTo(size.width * 0.5600117, size.height * 0.4000000, size.width * 0.5444965, size.height * 0.1000000, size.width * 0.6416862, 0);
    path_0.lineTo(size.width * 0.9437939, 0);
    path_0.close();
    
    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Colors.white.withOpacity(1.0);
    
    // إضافة ظل للبار
    canvas.drawShadow(path_0, Colors.grey.withOpacity(0.3), 10.0, true);
    canvas.drawPath(path_0, paint_0_fill);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}