import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/auth/auth_controller.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/generated/l10n.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String? userId;

  const EmailVerificationPage({Key? key, required this.email, this.userId})
    : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60; // 60 ثانية
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  String _getVerificationCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyCode() async {
    final code = _getVerificationCode();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).pleaseEnter6DigitCode),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.verifyEmailCode(
      email: widget.email,
      verificationCode: code,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${S.of(context).accountActivatedSuccessfully}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // ✅ العودة إلى صفحة تسجيل الدخول
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? S.of(context).invalidVerificationCode),
            backgroundColor: Colors.red,
          ),
        );
        // ✅ مسح الحقول عند الخطأ
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    }
  }

  Future<void> _resendCode() async {
    if (_countdown > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).pleaseWaitBeforeResend(_countdown)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isResending = true;
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.resendVerificationCode(widget.email);

    setState(() {
      _isResending = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${S.of(context).verificationCodeSent}'),
            backgroundColor: Colors.green,
          ),
        );
        _startCountdown();
        // ✅ مسح الحقول
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authController.errorMessage ?? S.of(context).failedToResendCode,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // ✅ إذا تم إدخال جميع الأرقام، التحقق تلقائياً
    if (_getVerificationCode().length == 6) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).emailVerification),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // ✅ أيقونة
            Icon(Icons.email_outlined, size: 80, color: Colors.blue[300]),

            const SizedBox(height: 24),

            // ✅ العنوان
            Text(
              S.of(context).emailVerification,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 24.0,
                  tablet: 28.0,
                  desktop: 32.0,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ الرسالة
            Text(
              S.of(context).verificationCodeSentTo(widget.email),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 40),

            // ✅ حقول إدخال الكود
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  height: 60,
                  child: TextField(
                    controller: _codeControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onCodeChanged(index, value),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ✅ زر التحقق
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      S.of(context).verify,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // ✅ زر إعادة الإرسال
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).didNotReceiveCode,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 14.0,
                      tablet: 16.0,
                      desktop: 18.0,
                    ),
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isResending || _countdown > 0
                      ? null
                      : _resendCode,
                  child: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _countdown > 0
                              ? S.of(context).resendWithCountdown(_countdown)
                              : S.of(context).resend,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
