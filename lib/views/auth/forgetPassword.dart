import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/auth/auth_controller.dart';
import 'package:filevo/views/auth/verify_code_view.dart';
import 'package:filevo/generated/l10n.dart'; // ملف الترجمة
import 'package:filevo/constants/app_colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar(S.of(context).enterEmail, AppColors.warning);
      return;
    }

    if (!email.contains('@')) {
      _showSnackBar(S.of(context).validEmail, AppColors.warning);
      return;
    }

    final authController = context.read<AuthController>();

    setState(() => _isLoading = true);
    authController.clearMessages();

    bool success = await authController.forgotPassword(email);

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar(
        authController.successMessage ?? S.of(context).codeSent,
        AppColors.success,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCodePage(email: email),
          ),
        );
      }
    } else {
      _showSnackBar(
        authController.errorMessage ?? S.of(context).failedSendCode,
        AppColors.error,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Builder(
        builder: (context) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            backgroundColor: AppColors.getBackground(isDarkMode),
            appBar: AppBar(
              backgroundColor: AppColors.getAppBar(isDarkMode),
              elevation: 0,
              title: Text(
                S.of(context).resetPassword,
                style: TextStyle(
                  color: AppColors.getTextPrimary(isDarkMode),
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme: IconThemeData(
                color: AppColors.getTextPrimary(isDarkMode),
              ),
              centerTitle: true,
            ),
            body: Consumer<AuthController>(
              builder: (context, authController, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.getPrimary(isDarkMode),
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          S.of(context).forgotPasswordTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDarkMode),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          S.of(context).forgotPasswordSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextSecondary(isDarkMode),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _emailController,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(isDarkMode),
                          ),
                          decoration: InputDecoration(
                            labelText: S.of(context).email,
                            labelStyle: TextStyle(
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                            filled: true,
                            fillColor: AppColors.getCardColor(isDarkMode),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppColors.getPrimary(isDarkMode),
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSubmitted: (_) => _sendCode(),
                        ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _isLoading ? null : _sendCode,
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
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  S.of(context).sendCode,
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        S.of(context).backToLogin,
                        style: TextStyle(
                          color: AppColors.getPrimary(isDarkMode),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
