import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/constants/app_colors.dart';

class EmailChangeVerificationPage extends StatefulWidget {
  final String pendingEmail;

  const EmailChangeVerificationPage({
    Key? key,
    required this.pendingEmail,
  }) : super(key: key);

  @override
  State<EmailChangeVerificationPage> createState() => _EmailChangeVerificationPageState();
}

class _EmailChangeVerificationPageState extends State<EmailChangeVerificationPage> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).pleaseEnter6DigitCode),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final profileController = Provider.of<ProfileController>(context, listen: false);
    final success = await profileController.verifyEmailChange(
      verificationCode: code,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${S.of(context).emailChangedSuccessfully}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        // ✅ العودة إلى صفحة تعديل الملف الشخصي
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profileController.errorMessage ?? S.of(context).invalidVerificationCode,
            ),
            backgroundColor: AppColors.error,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.getBackground(isDarkMode),
      appBar: AppBar(
        title: Text(S.of(context).emailVerification),
        backgroundColor: AppColors.getAppBar(isDarkMode),
        foregroundColor: AppColors.getTextPrimary(isDarkMode),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // ✅ أيقونة
            Icon(
              Icons.email_outlined,
              size: 80,
              color: AppColors.getPrimary(isDarkMode),
            ),

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
                color: AppColors.getTextPrimary(isDarkMode),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ الرسالة
            Text(
              '${S.of(context).verificationCodeSentTo} ${widget.pendingEmail}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
                color: AppColors.getTextSecondary(isDarkMode),
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.getCardColor(isDarkMode),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.getPrimary(isDarkMode),
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
                backgroundColor: AppColors.getPrimary(isDarkMode),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // ✅ رسالة العد التنازلي
            Text(
              _countdown > 0
                  ? 'يمكنك إعادة إرسال الكود بعد $_countdown ثانية'
                  : 'لم تستلم الكود؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
                ),
                color: AppColors.getTextSecondary(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
