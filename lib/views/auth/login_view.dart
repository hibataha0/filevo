import 'dart:ui' as ui;
import 'package:filevo/views/auth/components/header_background.dart';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;

    double getTitleFontSize() {
      double size = screenWidth * 0.12;
      return size > 60 ? 60 : size;
    }

    double getSubtitleFontSize() {
      double size = screenWidth * 0.04;
      return size > 18 ? 18 : size;
    }

    double getFieldFontSize() {
      return 16;
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // الخلفية بالرسم
          const HeaderBackground(),


          SafeArea(child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: isSmallScreen ? 20 : 40,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isSmallScreen ? 10 : 20),
              // Text(
              //   "Filevo",
              //   style: TextStyle(
              //     fontSize: getTitleFontSize(),
              //     fontWeight: FontWeight.bold,
              //     color: const ui.Color.fromARGB(255, 0, 0, 0),
              //     shadows: [
              //       Shadow(
              //         blurRadius: 10.0,
              //         color: Colors.black26,
              //         offset: Offset(2.0, 2.0),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: isSmallScreen ? 5 : 10),
              // Text(
              //   "Log in to your account",
              //   style: TextStyle(
              //     fontSize: getSubtitleFontSize(),
              //     color: const ui.Color.fromARGB(179, 0, 0, 0),
              //     shadows: [
              //       Shadow(
              //         blurRadius: 8.0,
              //         color: Colors.black26,
              //         offset: Offset(1.0, 1.0),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: isSmallScreen ? 40 : 60),


            ]          ),
            
          ))
          // المحتوى فوق الخلفية
          // Center(
          //   child: SingleChildScrollView(
          //     padding: const EdgeInsets.symmetric(horizontal: 30),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         const SizedBox(height: 10),

          //         // 
          //         const Text(
          //           "Filevo",
          //           style: TextStyle(
          //             fontSize: 40,
          //             fontWeight: FontWeight.bold,
          //             color: Color.fromARGB(255, 0, 0, 0),
          //           ),
          //         ),
          //         const SizedBox(height: 10),
          //         const Text(
          //           "Log in to your account",
          //           style: TextStyle(fontSize: 16, color: Color.fromARGB(179, 0, 0, 0)),
          //         ),
          //         const SizedBox(height: 60),

          //         // Username
          //         Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(30),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black12,
          //                 blurRadius: 10,
          //                 offset: Offset(0, 4),
          //               ),
          //             ],
          //           ),
          //           child: TextField(
          //             decoration: InputDecoration(
          //               prefixIcon: Icon(Icons.person, color: Colors.grey),
          //               hintText: "Username",
          //               border: InputBorder.none,
          //               contentPadding: const EdgeInsets.symmetric(
          //                 vertical: 15,
          //                 horizontal: 20,
          //               ),
          //             ),
          //           ),
          //         ),
          //         const SizedBox(height: 20),

          //         // Password
          //         Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(30),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black12,
          //                 blurRadius: 10,
          //                 offset: Offset(0, 4),
          //               ),
          //             ],
          //           ),
          //           child: TextField(
          //             obscureText: true,
          //             decoration: InputDecoration(
          //               prefixIcon: Icon(Icons.lock, color: Colors.grey),
          //               hintText: "Password",
          //               border: InputBorder.none,
          //               contentPadding: const EdgeInsets.symmetric(
          //                 vertical: 15,
          //                 horizontal: 20,
          //               ),
          //             ),
          //           ),
          //         ),
          //         const SizedBox(height: 15),

          //         // Forgot password
          //         Align(
          //           alignment: Alignment.centerRight,
          //           child: TextButton(
          //             onPressed: () {},
          //             child: const Text(
          //               "Forgot your password?",
          //               style: TextStyle(color: Colors.grey),
          //             ),
          //           ),
          //         ),

          //         const SizedBox(height: 30),

          //         // زر تسجيل الدخول
          //         SizedBox(
          //           width: double.infinity,
          //           child: ElevatedButton(
          //             style: ElevatedButton.styleFrom(
             
          //               padding: const EdgeInsets.symmetric(vertical: 15),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(30),
          //               ),
          //               backgroundColor: const Color(0xFF28336F),
          //             ),
          //             onPressed: () {},
          //             child: const Text(
          //               "Login",
          //               style: TextStyle(fontSize: 18, color: Colors.white),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}