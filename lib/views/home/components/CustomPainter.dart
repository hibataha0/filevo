

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.5293, size.height * 0.9601);
    path_0.cubicTo(
      size.width * 0.4904, size.height * 0.9945,
      size.width * 0.4094, size.height * 1.0047,
      size.width * 0.3548, size.height * 0.9782
    );
    path_0.cubicTo(
      size.width * 0.2294, size.height * 0.9172,
      size.width * 0.1327, size.height * 0.8387,
      size.width * 0.0745, size.height * 0.7499
    );
    path_0.cubicTo(
      size.width * 0.0012, size.height * 0.6379,
      size.width * -0.0068, size.height * 0.5153,
      size.width * 0.0517, size.height * 0.4005
    );
    path_0.cubicTo(
      size.width * 0.1102, size.height * 0.2857,
      size.width * 0.2322, size.height * 0.1846,
      size.width * 0.3994, size.height * 0.1125
    );
    path_0.cubicTo(
      size.width * 0.5319, size.height * 0.0553,
      size.width * 0.6874, size.height * 0.0186,
      size.width * 0.8505, size.height * 0.0055
    );
    path_0.cubicTo(
      size.width * 0.9217, size.height * -0.0003,
      size.width * 0.9804, size.height * 0.0332,
      size.width * 0.9810, size.height * 0.0741
    );
    path_0.lineTo(size.width * 0.9870, size.height * 0.5334);
    path_0.cubicTo(
      size.width * 0.9871, size.height * 0.5479,
      size.width * 0.9800, size.height * 0.5620,
      size.width * 0.9660, size.height * 0.5741
    );
    path_0.lineTo(size.width * 0.5293, size.height * 0.9601);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.shader = ui.Gradient.linear(
      Offset(size.width * 0.6104, size.height * 0.3481),
      Offset(size.width * 0.4156, size.height * 0.9593),
      [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.01)],
      [0.01, 1]
    );
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.5293, size.height * 0.9601);
    path_1.cubicTo(
      size.width * 0.4904, size.height * 0.9945,
      size.width * 0.4094, size.height * 1.0047,
      size.width * 0.3548, size.height * 0.9782
    );
    path_1.cubicTo(
      size.width * 0.2294, size.height * 0.9172,
      size.width * 0.1327, size.height * 0.8387,
      size.width * 0.0745, size.height * 0.7499
    );
    path_1.cubicTo(
      size.width * 0.0012, size.height * 0.6379,
      size.width * -0.0068, size.height * 0.5153,
      size.width * 0.0517, size.height * 0.4005
    );
    path_1.cubicTo(
      size.width * 0.1102, size.height * 0.2857,
      size.width * 0.2322, size.height * 0.1846,
      size.width * 0.3994, size.height * 0.1125
    );
    path_1.cubicTo(
      size.width * 0.5319, size.height * 0.0553,
      size.width * 0.6874, size.height * 0.0186,
      size.width * 0.8505, size.height * 0.0055
    );
    path_1.cubicTo(
      size.width * 0.9217, size.height * -0.0003,
      size.width * 0.9804, size.height * 0.0332,
      size.width * 0.9810, size.height * 0.0741
    );
    path_1.lineTo(size.width * 0.9870, size.height * 0.5334);
    path_1.cubicTo(
      size.width * 0.9871, size.height * 0.5479,
      size.width * 0.9800, size.height * 0.5620,
      size.width * 0.9660, size.height * 0.5741
    );
    path_1.lineTo(size.width * 0.5293, size.height * 0.9601);
    path_1.close();

    Paint paint_1_stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
    paint_1_stroke.shader = ui.Gradient.linear(
      Offset(size.width * 0.8701, size.height * 0.0556),
      Offset(size.width * 0.4026, size.height * 0.9185),
      [Color(0xff0F0F0F).withOpacity(1), Color(0xff151515).withOpacity(0)],
      [0, 1]
    );
    canvas.drawPath(path_1, paint_1_stroke);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);

    Path path_2 = Path();
    path_2.moveTo(size.width * 0.5293, size.height * 0.9601);
    path_2.cubicTo(
      size.width * 0.4904, size.height * 0.9945,
      size.width * 0.4094, size.height * 1.0047,
      size.width * 0.3548, size.height * 0.9782
    );
    path_2.cubicTo(
      size.width * 0.2294, size.height * 0.9172,
      size.width * 0.1327, size.height * 0.8387,
      size.width * 0.0745, size.height * 0.7499
    );
    path_2.cubicTo(
      size.width * 0.0012, size.height * 0.6379,
      size.width * -0.0068, size.height * 0.5153,
      size.width * 0.0517, size.height * 0.4005
    );
    path_2.cubicTo(
      size.width * 0.1102, size.height * 0.2857,
      size.width * 0.2322, size.height * 0.1846,
      size.width * 0.3994, size.height * 0.1125
    );
    path_2.cubicTo(
      size.width * 0.5319, size.height * 0.0553,
      size.width * 0.6874, size.height * 0.0186,
      size.width * 0.8505, size.height * 0.0055
    );
    path_2.cubicTo(
      size.width * 0.9217, size.height * -0.0003,
      size.width * 0.9804, size.height * 0.0332,
      size.width * 0.9810, size.height * 0.0741
    );
    path_2.lineTo(size.width * 0.9870, size.height * 0.5334);
    path_2.cubicTo(
      size.width * 0.9871, size.height * 0.5479,
      size.width * 0.9800, size.height * 0.5620,
      size.width * 0.9660, size.height * 0.5741
    );
    path_2.lineTo(size.width * 0.5293, size.height * 0.9601);
    path_2.close();

    Paint paint_2_stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
    paint_2_stroke.shader = ui.Gradient.linear(
      Offset(size.width * 0.9481, size.height * 0.0333),
      Offset(size.width * 0.4026, size.height * 0.9667),
      [Color(0xff28336F).withOpacity(1), Colors.white.withOpacity(0.7)],
      [0, 1]
    );
    canvas.drawPath(path_2, paint_2_stroke);

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_2, paint_2_fill);

    Path path_3 = Path();
    path_3.moveTo(size.width * 0.5293, size.height * 0.9601);
    path_3.cubicTo(
      size.width * 0.4904, size.height * 0.9945,
      size.width * 0.4094, size.height * 1.0047,
      size.width * 0.3548, size.height * 0.9782
    );
    path_3.cubicTo(
      size.width * 0.2294, size.height * 0.9172,
      size.width * 0.1327, size.height * 0.8387,
      size.width * 0.0745, size.height * 0.7499
    );
    path_3.cubicTo(
      size.width * 0.0012, size.height * 0.6379,
      size.width * -0.0068, size.height * 0.5153,
      size.width * 0.0517, size.height * 0.4005
    );
    path_3.cubicTo(
      size.width * 0.1102, size.height * 0.2857,
      size.width * 0.2322, size.height * 0.1846,
      size.width * 0.3994, size.height * 0.1125
    );
    path_3.cubicTo(
      size.width * 0.5319, size.height * 0.0553,
      size.width * 0.6874, size.height * 0.0186,
      size.width * 0.8505, size.height * 0.0055
    );
    path_3.cubicTo(
      size.width * 0.9217, size.height * -0.0003,
      size.width * 0.9804, size.height * 0.0332,
      size.width * 0.9810, size.height * 0.0741
    );
    path_3.lineTo(size.width * 0.9870, size.height * 0.5334);
    path_3.cubicTo(
      size.width * 0.9871, size.height * 0.5479,
      size.width * 0.9800, size.height * 0.5620,
      size.width * 0.9660, size.height * 0.5741
    );
    path_3.lineTo(size.width * 0.5293, size.height * 0.9601);
    path_3.close();

    Paint paint_3_stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
    paint_3_stroke.shader = ui.Gradient.linear(
      Offset(size.width * 0.9221, size.height * 0.0407),
      Offset(size.width * 0.3961, size.height * 0.9852),
      [Colors.white.withOpacity(1), Colors.white.withOpacity(0)],
      [0, 1]
    );
    canvas.drawPath(path_3, paint_3_stroke);

    Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
    paint_3_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_3, paint_3_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}



// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:flutter/material.dart';

// class StorageCard extends StatelessWidget {
//   const StorageCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 50.0, left: 70.0),
//       child: Center(
//         child: Stack(
//           clipBehavior: Clip.none, // يخلي الأجزاء اللي برا الكادر تبين
//           children: [
//             // ✅ الكارد الزجاجي أولاً
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20.0),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
//                 child: Container(
//                   width: 250,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomRight,
//                       end: Alignment.topLeft,
//                       colors: [
//                         Colors.white.withOpacity(0.4),
//                         Colors.white.withOpacity(0.001),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(25.0),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1.0,
//                     ),
//                   ),
//                   child: const Center(
//                     child: Text(
//                       "Storage",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // ✅ الدائرة بعد الكارد (رح تبين فوقه)
//             Positioned(
//               left: -80,
//               top: 30,
//               child: Container(
//                 width: 150,
//                 height: 150,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Color( 0xFF25BBB6),
//                 ),
//               ),
//             ),

           
//           ],
//         ),
//       ),
//     );
//   }
// }
