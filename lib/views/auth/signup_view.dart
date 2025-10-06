import 'dart:ui' as ui;
import 'package:filevo/responsive.dart';
import 'package:filevo/views/auth/components/divider_with_text.dart';
import 'package:filevo/views/auth/components/responsive.dart';
import 'package:filevo/views/auth/components/social_login_buttons.dart';
import 'package:filevo/views/auth/components/validators.dart';
import 'package:filevo/views/auth/components/custom_button.dart';
import 'package:filevo/views/auth/components/custom_textfiled.dart';
import 'package:filevo/views/auth/components/header_background.dart';
import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart'; // ✅ استدعاء intl

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

  Future<void> _validateAndSubmit() async {
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

    if (usernameError == null && emailError == null && 
        passwordError == null && mobileError == null) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).accountCreatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

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

  Widget _buildLoginSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).alreadyHaveAccount,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            S.of(context).logIn,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
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
                S.of(context).appTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getTitleFontSize(context),
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
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 30.0,
                  desktop: 40.0,
                ),
              ),

              // عنوان إنشاء الحساب
              Text( 
                S.of(context).createAccount,
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getBigFontSize(context),
                  color: Colors.grey[1000],
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 10.0,
                  tablet: 20.0,
                  desktop: 30.0,
                ),
              ),
           
              // حقل اسم المستخدم
              Padding(
                padding: ResponsiveHelpers.getHorizontalPadding(context),
                child: _buildValidatedTextField(
                  controller: _usernameController,
                  hintText: S.of(context).username,
                  icon: Icons.person,
                  errorText: _usernameError,
                ),
              ),

              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 10.0,
                  tablet: 20.0,
                  desktop: 30.0,
                ),
              ),

              // حقل البريد الإلكتروني
              Padding(
                padding: ResponsiveHelpers.getHorizontalPadding(context),
                child: _buildValidatedTextField(
                  controller: _emailController,
                  hintText: S.of(context).email,
                  icon: Icons.email,
                  errorText: _emailError,
                ),
              ),

              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 10.0,
                  tablet: 20.0,
                  desktop: 30.0,
                ),
              ),

              // حقل كلمة المرور
              Padding(
                padding: ResponsiveHelpers.getHorizontalPadding(context),
                child: _buildValidatedTextField(
                  controller: _passwordController,
                  hintText: S.of(context).password,
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

              // حقل رقم الهاتف
              Padding(
                padding: ResponsiveHelpers.getHorizontalPadding(context),
                child: _buildValidatedTextField(
                  controller: _mobileController,
                  hintText: S.of(context).mobile,
                  icon: Icons.phone,
                  errorText: _mobileError,
                ),
              ),

              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 50.0,
                  desktop: 60.0,
                ),
              ),

              // زر إنشاء الحساب
              Padding(
                padding: ResponsiveHelpers.getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      S.of(context).create,
                      style: TextStyle(
                        fontSize: ResponsiveHelpers.getBigFontSize(context),
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
                  tablet: 40.0,
                  desktop: 50.0,
                ),
              ),

              // قسم Sign up with
              DividerWithText(
                text: S.of(context).signUpWith,
              ),

              const SizedBox(height: 25.0),

              // أيقونات التواصل الاجتماعي
              const SocialLoginButtons(),

              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 40.0,
                  desktop: 50.0,
                ),
              ),

              // رابط تسجيل الدخول
              _buildLoginSection(context),

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
