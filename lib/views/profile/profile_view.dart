import 'package:filevo/views/profile/components/StorageCard.dart';
import 'package:filevo/views/profile/components/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
// import model
import 'package:filevo/models/profile/profile_model.dart';
// import controller
import 'package:filevo/controllers/profile/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      body: Column(
        children: [
          // الجزء العلوي الأزرق
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfilePic(),
                const SizedBox(height: 20),
                const Text(
                  "Hiba Taha",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // البطاقة البيضاء التي تمتد لباقي الصفحة
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color:const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    StorageCard(),
                    // // محتوى البطاقة البيضاء
                    // _buildProfileItem(Icons.person_outline, "المعلومات الشخصية"),
                    // const SizedBox(height: 15),
                    // _buildProfileItem(Icons.security, "الأمان"),
                    // const SizedBox(height: 15),
                    // _buildProfileItem(Icons.notifications, "الإشعارات"),
                    // const SizedBox(height: 15),
                    // _buildProfileItem(Icons.settings, "الإعدادات"),
                    // const SizedBox(height: 15),
                    // _buildProfileItem(Icons.help_outline, "المساعدة والدعم"),
                    // const SizedBox(height: 15),
                    // _buildProfileItem(Icons.info_outline, "عن التطبيق"),
                    // const SizedBox(height: 25),
                    // _buildProfileItem(Icons.logout, "تسجيل الخروج", isLogout: true),
                    
                    // مساحة إضافية في الأسفل
 SizedBox(height: 100),                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

} 