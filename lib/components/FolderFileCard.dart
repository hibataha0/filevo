import 'package:flutter/material.dart';

class FolderFileCard extends StatelessWidget {
  final String title;
  final int fileCount;
  final String size;
  final Color color;
  final VoidCallback? onTap;

  const FolderFileCard({
    Key? key,
    required this.title,
    required this.fileCount,
    required this.size,
    this.color = const Color(0xFF00BFA5),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;   // عرض الكارد
        final h = constraints.maxHeight;  // ارتفاع الكارد

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(w * 0.08),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w * 0.08),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // مهم! يخلي الكارد صغير حسب المحتوى
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.folder, color: color, size: w * 0.22),
                    Icon(Icons.more_vert, color: Colors.grey, size: w * 0.12),
                  ],
                ),
                SizedBox(height: h * 0.02), // بدل Spacer
                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: h * 0.03), // مسافة صغيرة بدل Spacer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$fileCount Files",
                      style: TextStyle(
                        fontSize: w * 0.10,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      size,
                      style: TextStyle(
                        fontSize: w * 0.10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
