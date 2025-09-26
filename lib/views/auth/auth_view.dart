// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // // import model
// // import 'package:filevo/models/auth/auth_model.dart';
// // // import controller
// // import 'package:filevo/controllers/auth/auth_controller.dart';

// // class AuthView extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     AuthController viewController = AuthController();
// //     return ChangeNotifierProvider<AuthModel>(
// //       create: (context) => AuthModel.instance(),
// //       child: Consumer<AuthModel>(
// //         builder: (context, viewModel, child) {
// //           return Container(
// //               //TODO Add layout or component here
// //               );
// //         },
// //       ),
// //     );
// //   }






// import 'dart:ui' as ui;
// import 'package:filevo/views/auth/components/custom_textfiled.dart';
// import 'package:flutter/material.dart';
// import 'package:filevo/responsive.dart';
// import 'package:filevo/views/auth/components/header_background.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // ✅ تهيئة مباشرة بدون late
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   @override
//   void dispose() {
//     // ضروري نفرغ الكونترولر لما تتسكر الصفحة
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Responsive(
//         mobile: _buildLayout(context, 0.08),
//         tablet: _buildLayout(context, 0.15),
//         desktop: _buildLayout(context, 0.25),
//       ),
//     );
//   }

//   // Layout عام بدل التكرار
//   Widget _buildLayout(BuildContext context, double paddingPercent) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Stack(
//       children: [
//         const HeaderBackground(),
//         Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: screenWidth * paddingPercent),
//             child: _buildLoginForm(context),
//           ),
//         ),
//       ],
//     );
//   }

//   // نموذج تسجيل الدخول
//   Widget _buildLoginForm(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     // دوال حسابية لتحديد الأحجام
//     double getTitleFontSize() => (screenWidth * 0.12).clamp(0, 70);
//     double getSubtitleFontSize() => (screenWidth * 0.035).clamp(0, 18);
//     double getButtonFontSize() => (screenWidth * 0.04).clamp(0, 19);
//     double getFieldFontSize() => (screenWidth * 0.035).clamp(0, 17);
//     double getFieldPadding() => (screenWidth * 0.03).clamp(0, 16);
//     double getFormWidth() => (screenWidth * 0.8).clamp(0, 500);

//     return Center(
//       child: Container(
//         width: getFormWidth(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 10),
//             Text(
//               "Filevo",
//               style: TextStyle(
//                 fontSize: getTitleFontSize(),
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Log in to your account",
//               style: TextStyle(
//                 fontSize: getSubtitleFontSize(),
//                 color: Colors.black.withOpacity(0.7),
//               ),
//             ),
//             const SizedBox(height: 60),

//             // Username
//             CustomTextField(
//   hintText: "Username",
//   prefixIcon: Icons.person,
// ),

// CustomTextField(
//   hintText: "Password",
//   isPassword: true,
//   prefixIcon: Icons.lock,
// ),

//             const SizedBox(height: 20),

//             // Password
//             // CustomTextField(
//             //   labelText: "Password",
//             //   isPassword: true,
//             //   fontSize: getFieldFontSize(),
//             //   controller: passwordController,
//             // ),
//             const SizedBox(height: 15),

//             // Forgot password
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   "Forgot your password?",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: getFieldFontSize() - 1,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Login button
//             SizedBox(
//               width: 120,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: getFieldPadding()),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   backgroundColor: const Color(0xFF28336F),
//                 ),
//                 onPressed: () {
//                   // منطق تسجيل الدخول
//                   print("Username: ${usernameController.text}");
//                   print("Password: ${passwordController.text}");
//                 },
//                 child: Text(
//                   "Login",
//                   style: TextStyle(
//                     fontSize: getButtonFontSize(),
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // }