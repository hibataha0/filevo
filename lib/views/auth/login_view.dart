import 'dart:ui' as ui;
import 'package:filevo/responsive.dart';
import 'package:filevo/views/auth/components/divider_with_text.dart';
import 'package:filevo/views/auth/components/social_login_buttons.dart';
import 'package:filevo/views/auth/components/validators.dart';
import 'package:filevo/views/auth/signup_view.dart';
import 'package:filevo/views/auth/components/custom_button.dart';
import 'package:filevo/views/auth/components/custom_textfiled.dart';
import 'package:filevo/views/auth/components/header_background.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  // دالة التحقق من صحة النموذج
  Future<void> _validateAndSubmit() async {
    final emailError = Validators.validateEmailOrUsername(_emailController.text);
    final passwordError = Validators.validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError == null && passwordError == null) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      
      print('Login attempt with:');
      print('Username/Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');

      final isSuccess = _emailController.text.isNotEmpty && 
                       _passwordController.text.isNotEmpty;
      
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacementNamed(context, 'Main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

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

  Widget _buildSignUpSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account? ',
          style: TextStyle(
            color: Colors.black45,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (e) => const SignUpPage(),
              ),
            );
          },
          child: Text(
            'Sign up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;

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
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 32.0,
                    tablet: 40.0,
                    desktop: 48.0,
                  ),
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
              
              SizedBox(height: isSmallScreen ? 5 : 10),
              
              // العنوان الفرعي
              Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 14.0,
                    tablet: 16.0,
                    desktop: 18.0,
                  ),
                  color: Colors.grey[1000],
                ),
              ),
              
              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 30.0,
                  tablet: 40.0,
                  desktop: 40.0,
                ),
              ),

              // حقل اسم المستخدم/البريد الإلكتروني
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 20.0,
                    tablet: 40.0,
                    desktop: 60.0,
                  ),
                ),
                child: _buildValidatedTextField(
                  controller: _emailController,
                  hintText: "Username or Email",
                  icon: Icons.person,
                  errorText: _emailError,
                ),
              ),
              
              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 30.0,
                  desktop: 40.0,
                ),
              ),

              // حقل كلمة المرور
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 20.0,
                    tablet: 40.0,
                    desktop: 60.0,
                  ),
                ),
                child: _buildValidatedTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  errorText: _passwordError,
                ),
              ),
              
              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 10.0,
                  tablet: 20.0,
                  desktop: 40.0,
                ),
              ),
              
              // نسيت كلمة المرور
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 20.0,
                    tablet: 40.0,
                    desktop: 60.0,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 14.0,
                        tablet: 15.0,
                        desktop: 16.0,
                      ),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
              
              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 40.0,
                  tablet: 50.0,
                  desktop: 60.0,
                ),
              ),
              
              // زر تسجيل الدخول
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 20.0,
                    tablet: 40.0,
                    desktop: 60.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 22.0,
                          tablet: 26.0,
                          desktop: 30.0,
                        ),
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
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 30.0,
                  tablet: 35.0,
                  desktop: 40.0,
                ),
              ),
              
              // قسم Sign in with
              const DividerWithText(
                text: 'Sign in with',
              ),
              
              const SizedBox(height: 25.0),
              
              // أيقونات التواصل الاجتماعي
              const SocialLoginButtons(),
              
              const SizedBox(height: 25.0),
              
              // رابط إنشاء حساب جديد
              _buildSignUpSection(context),
              
              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 30.0,
                  desktop: 40.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}