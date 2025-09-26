import 'dart:ui' as ui;
import 'package:filevo/views/auth/components/divider_with_text.dart';
import 'package:filevo/views/auth/components/responsive.dart';
import 'package:filevo/views/auth/components/social_login_buttons.dart';
import 'package:filevo/views/auth/components/validators.dart';
import 'package:flutter/gestures.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/auth/components/custom_button.dart';
import 'package:filevo/views/auth/components/custom_textfiled.dart';
import 'package:filevo/views/auth/components/header_background.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  
  bool _isLoading = false;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _mobileError;

  // دالة التحقق من صحة النموذج
  Future<void> _validateAndSubmit() async {
    // استخدام الـ Validators للتحقق
    final usernameError = Validators.validateUsername(_usernameController.text);
    final emailError = Validators.validateEmail(_emailController.text);
    final passwordError = Validators.validatePassword(_passwordController.text);
    final mobileError = Validators.validatePhone(_mobileController.text);

    setState(() {
      _usernameError = usernameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _mobileError = mobileError;
    });

    // إذا لم يكن هناك أخطاء
    if (usernameError == null && emailError == null && 
        passwordError == null && mobileError == null) {
      setState(() {
        _isLoading = true;
      });

      // محاكاة عملية التسجيل (استبدل هذا بالاتصال الحقيقي بالAPI)
      await Future.delayed(const Duration(seconds: 2));
      
      print('Signup attempt with:');
      print('Username: ${_usernameController.text}');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Mobile: ${_mobileController.text}');

      // محاكاة نجاح التسجيل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isLoading = false;
      });
      
      // الانتقال للصفحة الرئيسية بعد التسجيل الناجح
      // Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // ويدجت خاصة لعرض CustomTextField مع رسالة الخطأ
  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          hintText: hintText,
          icon: icon,
          isPassword: isPassword,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  

 
 

 

  double getFieldFontSize() {
    return 16;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const HeaderBackground(),
              
              // العنوان الرئيسي
              Text(
                'Flievo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: const ui.Color.fromARGB(255, 0, 0, 0),
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              
              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 40
                    : Responsive.isTablet(context)
                        ? 30
                        : 20,
              ),
              
              // عنوان إنشاء الحساب
              Text( 
                'Create account',
                style: TextStyle(
                  fontSize: getBigFontSize(context),
                  color: Colors.grey[1000],
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 30
                    : Responsive.isTablet(context)
                        ? 20
                        : 10,
              ),
           
              // حقل اسم المستخدم
              _buildValidatedTextField(
                controller: _usernameController,
                hintText: "Username",
                icon: Icons.person,
                errorText: _usernameError,
              ),
              
              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 30
                    : Responsive.isTablet(context)
                        ? 20
                        : 10,
              ),
              
              // حقل البريد الإلكتروني
              _buildValidatedTextField(
                controller: _emailController,
                hintText: "Email",
                icon: Icons.email,
                errorText: _emailError,
              ),
              
              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 30
                    : Responsive.isTablet(context)
                        ? 20
                        : 10,
              ),
              
              // حقل كلمة المرور
              _buildValidatedTextField(
                controller: _passwordController,
                hintText: "Password",
                icon: Icons.lock,
                isPassword: true,
                errorText: _passwordError,
              ),
              
              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 40
                    : Responsive.isTablet(context)
                        ? 20
                        : 10,
              ),
              
              // حقل رقم الهاتف
              _buildValidatedTextField(
                controller: _mobileController,
                hintText: "Mobile",
                icon: Icons.phone,
                errorText: _mobileError,
              ),
              
              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 60
                    : Responsive.isTablet(context)
                        ? 50
                        : 20,
              ),

              // زر إنشاء الحساب
              Padding(
                padding: getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Create',
                      style: TextStyle(
                        fontSize: getBigFontSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : IconButtonGradient(
                            onPressed: _validateAndSubmit,
                          ),
                  ],
                ),
              ),
              
              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 50
                    : Responsive.isTablet(context)
                        ? 40
                        : 30,
              ),
 DividerWithText(
  text: 'Sign up with',
),
 const SizedBox(height: 25.0),
// أيقونات التواصل الاجتماعي
              const SocialLoginButtons(),
              // رابط تسجيل الدخول
              
              
              SizedBox(
                height: Responsive.isDesktop(context)
                    ? 50
                    : Responsive.isTablet(context)
                        ? 40
                        : 20,
              ),

              // نص الوسائط الاجتماعية
              // Text('Or create account using social media',
              //     style: TextStyle(
              //       color: Colors.grey[600],
              //     )),
        
              // SizedBox(height: Responsive.isDesktop(context) ? 25 : 20),

              _buildLoginSection(context),

              SizedBox(height: Responsive.isDesktop(context) ? 40 : 20),
            ],
          ),
        ),
      ),
    );
  }
}