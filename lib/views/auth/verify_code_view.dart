// views/auth/verify_code_page.dart
import 'package:filevo/views/auth/ResetPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';
import 'package:filevo/controllers/auth/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:filevo/generated/l10n.dart'; // استدعاء ملف الترجمة

class VerifyCodePage extends StatefulWidget {
  final String email;
  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  String _code = "";
  bool _isVerifying = false;
  bool _isResending = false;
  Key _verificationKey = UniqueKey();

  void _verifyCode() async {
    if (_code.length != 6) {
      _showSnackBar(S.of(context).enter6DigitCode, Colors.orange);
      return;
    }

    final authController = context.read<AuthController>();
    setState(() => _isVerifying = true);
    authController.clearMessages();

    bool success = await authController.verifyResetCode(_code);

    setState(() => _isVerifying = false);

    if (success) {
      _showSnackBar(authController.successMessage ?? S.of(context).codeVerified, Colors.green);

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      }
    } else {
      _showSnackBar(authController.errorMessage ?? S.of(context).invalidOrExpiredCode, Colors.red);
    }
  }

  void _resendCode() async {
    final authController = context.read<AuthController>();
    setState(() => _isResending = true);
    authController.clearMessages();

    bool success = await authController.forgotPassword(widget.email);

    setState(() => _isResending = false);

    if (success) {
      setState(() {
        _code = "";
        _verificationKey = UniqueKey();
      });

      _showSnackBar(authController.successMessage ?? S.of(context).codeResent, Colors.green);
    } else {
      _showSnackBar(authController.errorMessage ?? S.of(context).failedResendCode, Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            S.of(context).verifyCodeTitle,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: Consumer<AuthController>(
          builder: (context, authController, child) {
            return Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 90,
                    color: Color(0xFF6A5AE0),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).enterCodeToEmail(widget.email),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  VerificationCodeField(
                    key: _verificationKey,
                    length: 6,
                    onFilled: (value) => setState(() => _code = value),
                    size: const Size(30, 60),
                    spaceBetween: 16,
                    matchingPattern: RegExp(r'^\d+$'),
                  ),
                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _isVerifying ? null : _verifyCode,
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5AE0), Color(0xFF8A7CFD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A5AE0).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Center(
                        child: _isVerifying
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                S.of(context).verify,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: _isResending ? null : _resendCode,
                    child: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF6A5AE0),
                            ),
                          )
                        : Text(
                            S.of(context).resendCode,
                            style: const TextStyle(
                              color: Color(0xFF6A5AE0),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
