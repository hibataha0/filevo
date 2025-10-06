import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import model
import 'package:filevo/models/settings/settings_model.dart';
// import controller
import 'package:filevo/controllers/settings/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      body: Padding(
        // 🔹 نفس اللي في HomeView: يمنع اللون الأزرق من الظهور خلف البار
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Column(
          children: [
            // 🔹 العنوان العلوي
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 🔹 المحتوى الأبيض السفلي القابل للسكرول
            Expanded(
              child: Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                color: const Color(0xFFE9E9E9),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      _buildSettingsSection(
                        title: "General",
                        items: [
                          _buildSettingsItem(
                            icon: Icons.settings_outlined,
                            title: "General Settings",
                            subtitle: "Basic app settings",
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: "Dark Mode",
                            subtitle: "Switch between themes",
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {},
                              activeColor: const Color(0xff28336f),
                            ),
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.language,
                            title: "Language",
                            subtitle: "English",
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildSettingsSection(
                        title: "Preferences",
                        items: [
                          _buildSettingsItem(
                            icon: Icons.notifications_outlined,
                            title: "Notifications",
                            subtitle: "Manage notifications",
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.storage,
                            title: "Storage",
                            subtitle: "Manage storage settings",
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.security,
                            title: "Privacy & Security",
                            subtitle: "Privacy settings",
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildSettingsSection(
                        title: "Support",
                        items: [
                          _buildSettingsItem(
                            icon: Icons.description_outlined,
                            title: "Legal & Policies",
                            subtitle: "Terms of service & privacy policy",
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.help_outline,
                            title: "Help & Support",
                            subtitle: "Get help and support",
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.info_outline,
                            title: "About",
                            subtitle: "App version 1.0.0",
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // 🔹 زر تسجيل الخروج
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          subtitle: Text(
                            "Sign out from your account",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.red,
                            size: 16,
                          ),
                          onTap: () {},
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),

 SizedBox(height: 100),                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== الدوال المساعدة ======

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff28336f),
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xff28336f).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xff28336f),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
    );
    
  }
}
