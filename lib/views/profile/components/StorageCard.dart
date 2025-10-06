import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class StorageCard extends StatelessWidget {
  const StorageCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // قيم الأقسام
    final double images = 0.06;
    final double videos = 0.15;
    final double audio = 0.10;
    final double compressed = 0.08;
    final double applications = 0.12;
    final double documents = 0.18;
    final double code = 0.07;
    final double other = 0.05;

    // مجموع الاستخدام
    final double totalUsed = images + videos + audio + compressed + applications + documents + code + other;
    final int usedPercentage = (totalUsed * 100).round();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0,
        ),
      ),
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 20.0,
          tablet: 24.0,
          desktop: 28.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الدائرة
              Expanded(
                flex: 2,
                child: CustomPaint(
                  size: Size(120, 120),
                  painter: StorageCirclePainter(
                    images: images,
                    videos: videos,
                    audio: audio,
                    compressed: compressed,
                    applications: applications,
                    documents: documents,
                    code: code,
                    other: other,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$usedPercentage%',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 24.0,
                              tablet: 28.0,
                              desktop: 32.0,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Color(0xff28336f),
                          ),
                        ),
                        Text(
                          'Used',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 12.0,
                              tablet: 14.0,
                              desktop: 16.0,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 20),

              // Legend
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem('Images', Color(0xFF4285F4), Icons.image),
                              SizedBox(height: 6),
                              _buildLegendItem('Videos', Color(0xFFEA4335), Icons.videocam),
                              SizedBox(height: 6),
                              _buildLegendItem('Audio', Color(0xFF34A853), Icons.audiotrack),
                              SizedBox(height: 6),
                              _buildLegendItem('Compressed', Color(0xFFFF6D00), Icons.folder_zip),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem('Applications', Color(0xFF9C27B0), Icons.apps),
                              SizedBox(height: 6),
                              _buildLegendItem('Documents', Color(0xFF795548), Icons.description),
                              SizedBox(height: 6),
                              _buildLegendItem('Code', Color(0xFF009688), Icons.code),
                              SizedBox(height: 6),
                              _buildLegendItem('Other', Color(0xFF607D8B), Icons.more_horiz),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Text(
            'Storage Overview',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 18.0,
                tablet: 20.0,
                desktop: 22.0,
              ),
              fontWeight: FontWeight.bold,
              color: Color(0xff28336f),
            ),
          ),

          SizedBox(height: 16),
          Text(
            'Used storage: ',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 14.0,
                tablet: 15.0,
                desktop: 16.0,
              ),
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Stack(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Color(0xFF4285F4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(left: 10, child: Container(height: 30, width: 30, decoration: BoxDecoration(color: Color(0xFFEA4335), shape: BoxShape.circle))),
                    Positioned(left: 20, child: Container(height: 30, width: 30, decoration: BoxDecoration(color: Color(0xFF34A853), shape: BoxShape.circle))),
                    Positioned(left: 30, child: Container(height: 30, width: 30, decoration: BoxDecoration(color: Color(0xFFFF6D00), shape: BoxShape.circle))),
                    Positioned(left: 40, child: Container(height: 30, width: 30, decoration: BoxDecoration(color: Color(0xFF9C27B0), shape: BoxShape.circle))),
                    Positioned(left: 50, child: Container(height: 30, width: 30, decoration: BoxDecoration(color: Color(0xFF795548), shape: BoxShape.circle))),
                    Positioned(left: 60, child: Container(height: 30, width: 30, decoration: BoxDecoration(color: Color(0xFF009688), shape: BoxShape.circle))),
                    Positioned(left: 70, child: Container(height: 30, width: 30, decoration: BoxDecoration(color: Color(0xFF607D8B), shape: BoxShape.circle))),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                '149GB / 165GB',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 16.0,
                    tablet: 18.0,
                    desktop: 20.0,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Color(0xff28336f),
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.settings, color: Color(0xff28336f), size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(icon, color: Colors.white, size: 10),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStackCircle(double left, Color color) {
    return Positioned(
      left: left,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class StorageCirclePainter extends CustomPainter {
  final double images;
  final double videos;
  final double audio;
  final double compressed;
  final double applications;
  final double documents;
  final double code;
  final double other;

  StorageCirclePainter({
    required this.images,
    required this.videos,
    required this.audio,
    required this.compressed,
    required this.applications,
    required this.documents,
    required this.code,
    required this.other,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 15.0;

    // الخلفية الرمادية
    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double startAngle = -math.pi / 2;

    final segments = [
      {'value': images, 'color': Color(0xFF4285F4)},
      {'value': videos, 'color': Color(0xFFEA4335)},
      {'value': audio, 'color': Color(0xFF34A853)},
      {'value': compressed, 'color': Color(0xFFFF6D00)},
      {'value': applications, 'color': Color(0xFF9C27B0)},
      {'value': documents, 'color': Color(0xFF795548)},
      {'value': code, 'color': Color(0xFF009688)},
      {'value': other, 'color': Color(0xFF607D8B)},
    ];

    double totalUsed = segments.fold(0.0, (sum, seg) => sum + (seg['value'] as double));

    for (var segment in segments) {
      final double value = segment['value'] as double;
      if (value > 0) {
        final paint = Paint()
          ..color = segment['color'] as Color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
          startAngle,
          2 * math.pi * value,
          false,
          paint,
        );

        startAngle += 2 * math.pi * value;
      }
    }

    // رسم الفري سبيس تلقائيًا
    final double freeSpace = 1.0 - totalUsed;
    if (freeSpace > 0) {
      final paint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        2 * math.pi * freeSpace,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
