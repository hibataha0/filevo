import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// تم تحويلها إلى كلاس Widget مستقل وقابل لإعادة الاستخدام
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  // تم نقل دالة _socialIcon إلى هنا وجعلها خاصة بالكلاس
  Widget _socialIcon(String assetPath) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: ClipOval(
        child: Container(
          width: 30, // تم تكبير الحجم قليلاً ليتناسب مع التصميم
          height: 30,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(0), // إعادة الـ Padding لشكل أفضل
            child: SvgPicture.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تم نقل محتوى دالة _buildSocialLogin إلى هنا
    return Column(
      children: [
        // Text(
        //   'Or create account using social media',
        //   style: TextStyle(color: Colors.grey[600]),
        // ),
        // const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon('assets/images/facebook.svg'),
            const SizedBox(width: 20),
            _socialIcon('assets/images/twitter.svg'),
            const SizedBox(width: 20),
            _socialIcon('assets/images/google.svg'),
          ],
        ),
      ],
    );
  }
}
