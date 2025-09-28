import 'dart:math';

import 'package:flutter/material.dart';

class StorageChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // النسب المئوية
    final usedPercent = 0.6; // 60%
    final freePercent = 0.4; // 40%

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // رسم الجزء المستخدم (Used) - اللون الأخضر
    paint.color = Color(0xFF00BFA5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // البداية من الأعلى
      2 * pi * usedPercent, // 60% من الدائرة
      false,
      paint,
    );

    // رسم الجزء الفارغ (Free) - تدرج أزرق-أخضر
    final freeGradient = SweepGradient(
      startAngle: -pi / 2 + (2 * pi * usedPercent),
      endAngle: -pi / 2 + (2 * pi),
      colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA), Color(0xFF00ACC1)],
    );

    final freeRect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = freeGradient.createShader(freeRect);

    canvas.drawArc(
      freeRect,
      -pi / 2 + (2 * pi * usedPercent), // البداية بعد انتهاء الجزء المستخدم
      2 * pi * freePercent, // 40% من الدائرة
      false,
      paint,
    );

    // إضافة تأثير الإضاءة
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
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