import 'dart:math';
import 'package:flutter/material.dart';

class StorageChartPainter extends CustomPainter {
  final double usedPercent;
  
  StorageChartPainter({this.usedPercent = 0.0});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - size.width * 0.06; // بدل 10 ثابت

    // النسب المئوية (نضمن أنها بين 0 و 1)
    final used = usedPercent.clamp(0.0, 1.0);
    final freePercent = 1.0 - used;

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
      2 * pi * used, // النسبة المستخدمة
      false,
      paint,
    );

    // --- الجزء الفارغ (Free) بتدرج ---
    if (freePercent > 0) {
      final freeGradient = SweepGradient(
        startAngle: -pi / 2 + (2 * pi * used),
        endAngle: -pi / 2 + (2 * pi),
        colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA), Color(0xFF00ACC1)],
      );

      final freeRect = Rect.fromCircle(center: center, radius: radius);
      paint.shader = freeGradient.createShader(freeRect);

      canvas.drawArc(
        freeRect,
        -pi / 2 + (2 * pi * used),
        2 * pi * freePercent,
        false,
        paint,
      );
    }

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is StorageChartPainter) {
      return oldDelegate.usedPercent != usedPercent;
    }
    return true;
  }
}
