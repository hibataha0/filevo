import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(widget.icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          // إذا كان Password ضيف زر 👁
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}






// import 'package:flutter/material.dart';

// class CustomTextField extends StatefulWidget {
//   final String hintText;
//   final IconData icon;
//   final bool isPassword;
//   final TextEditingController? controller;

//   const CustomTextField({
//     Key? key,
//     required this.hintText,
//     required this.icon,
//     this.isPassword = false,
//     this.controller,
//   }) : super(key: key);

//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> {
//   bool _obscureText = true;

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     // responsive max width
//     double fieldWidth;
//     if (screenWidth > 1000) {
//       fieldWidth = 500; // حد أقصى بالويب الكبير
//     } else if (screenWidth > 600) {
//       fieldWidth = screenWidth * 0.6; // تابلت
//     } else {
//       fieldWidth = screenWidth * 0.85; // موبايل
//     }

//     return Center( // يخليهم بالنص عالويب
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: fieldWidth,
//         ),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: widget.controller,
//             obscureText: widget.isPassword ? _obscureText : false,
//             decoration: InputDecoration(
//               hintText: widget.hintText,
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               prefixIcon: Icon(widget.icon, color: Colors.grey),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(vertical: 18),
//               // زر 👁 إذا كان Password
//               suffixIcon: widget.isPassword
//                   ? IconButton(
//                       icon: Icon(
//                         _obscureText ? Icons.visibility_off : Icons.visibility,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureText = !_obscureText;
//                         });
//                       },
//                     )
//                   : null,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
