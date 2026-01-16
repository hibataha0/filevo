import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/auth/auth_controller.dart';
import 'package:filevo/generated/l10n.dart'; // ملف الترجمات
import 'package:filevo/constants/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // التحقق من الحقول
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar(S.of(context).pleaseFillAllFields, AppColors.warning);
      return;
    }

    if (password.length < 6) {
      _showSnackBar(S.of(context).passwordTooShort, AppColors.warning);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar(S.of(context).passwordsDoNotMatch, AppColors.warning);
      return;
    }

    final authController = context.read<AuthController>();

    setState(() => _isLoading = true);
    authController.clearMessages();

    bool success = await authController.resetPassword(
      email: widget.email,
      newPassword: password,
      confirmPassword: confirmPassword,
    );

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar(
        authController.successMessage ?? S.of(context).passwordResetSuccess,
        AppColors.success,
      );

      // الانتقال للشاشة الرئيسية بعد نجاح العملية
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      _showSnackBar(
        authController.errorMessage ?? S.of(context).passwordResetFailed,
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
                S.of(context).resetPasswordTitle,
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
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.getPrimary(isDarkMode),
                          size: 70,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          S.of(context).createNewPassword,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          S.of(context).enterNewPasswordFor(widget.email),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextSecondary(isDarkMode),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // New Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(isDarkMode),
                          ),
                          decoration: InputDecoration(
                            labelText: S.of(context).newPassword,
                            labelStyle: TextStyle(
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                            filled: true,
                            fillColor: AppColors.getCardColor(isDarkMode),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.getTextSecondary(isDarkMode),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
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
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(isDarkMode),
                          ),
                          decoration: InputDecoration(
                            labelText: S.of(context).confirmPassword,
                            labelStyle: TextStyle(
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                            filled: true,
                            fillColor: AppColors.getCardColor(isDarkMode),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.getTextSecondary(isDarkMode),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
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
                          onSubmitted: (_) => _resetPassword(),
                        ),

                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            S.of(context).passwordAtLeast6Chars,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                    const SizedBox(height: 30),

                    // Reset Button
                    GestureDetector(
                      onTap: _isLoading ? null : _resetPassword,
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
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  S.of(context).resetPasswordTitle,
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

                    // Back Button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        S.of(context).backToVerification,
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
