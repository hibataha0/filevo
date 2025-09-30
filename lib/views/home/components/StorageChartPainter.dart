import 'dart:math';
import 'package:flutter/material.dart';

class StorageChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - size.width * 0.06; // بدل 10 ثابت

    // النسب المئوية
    final usedPercent = 0.6; // 60%
    final freePercent = 0.4; // 40%

    // نخلي الـ stroke يتناسب مع حجم الرسم
    final strokeW = size.width * 0.12; // 12% من العرض

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    // --- الجزء المستخدم (Used) ---
    paint.color = Color(0xFF00BFA5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // البداية من الأعلى
      2 * pi * usedPercent, // 60%
      false,
      paint,
    );

    // --- الجزء الفارغ (Free) بتدرج ---
    final freeGradient = SweepGradient(
      startAngle: -pi / 2 + (2 * pi * usedPercent),
      endAngle: -pi / 2 + (2 * pi),
      colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA), Color(0xFF00ACC1)],
    );

    final freeRect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = freeGradient.createShader(freeRect);

    canvas.drawArc(
      freeRect,
      -pi / 2 + (2 * pi * usedPercent),
      2 * pi * freePercent,
      false,
      paint,
    );

    // --- تأثير الإضاءة (Glow) ---
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 1.25 // أعرض شوي من stroke الأساسي
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.1);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
