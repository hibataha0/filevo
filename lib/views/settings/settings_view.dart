import 'package:filevo/main.dart';
import 'package:filevo/views/settings/components/settings_item.dart';
import 'package:filevo/views/settings/components/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _selectedLocale = const Locale('en'); // 🔹 اللغة الحالية

  void _showLanguageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).chooseLanguage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(S.of(context).english),
                trailing: _selectedLocale.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLocale = const Locale('en');
                  });
                  MyApp.setLocale(context, const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(S.of(context).arabic),
                trailing: _selectedLocale.languageCode == 'ar'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLocale = const Locale('ar');
                  });
                  MyApp.setLocale(context, const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      body: Padding(
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
              child: Text(
                S.of(context).settings,
                style: const TextStyle(
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

                      SettingsSection(
                        title: S.of(context).general,
                        items: [
                          SettingsItem(
                            icon: Icons.settings_outlined,
                            title: S.of(context).generalSettings,
                            subtitle: S.of(context).basicAppSettings,
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: S.of(context).darkMode,
                            subtitle: S.of(context).switchThemes,
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {},
                              activeColor: const Color(0xff28336f),
                            ),
                            onTap: () {},
                          ),
                          // 🔹 خيار اللغة المعدّل
                          SettingsItem(
                            icon: Icons.language,
                            title: S.of(context).language,
                            subtitle: _selectedLocale.languageCode == 'en'
                                ? S.of(context).english
                                : S.of(context).arabic,
                            onTap: () => _showLanguageMenu(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SettingsSection(
                        title: S.of(context).preferences,
                        items: [
                          SettingsItem(
                            icon: Icons.notifications_outlined,
                            title: S.of(context).notifications,
                            subtitle: S.of(context).manageNotifications,
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.storage,
                            title: S.of(context).storage,
                            subtitle: S.of(context).manageStorageSettings,
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.security,
                            title: S.of(context).privacySecurity,
                            subtitle: S.of(context).privacySettings,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SettingsSection(
                        title: S.of(context).support,
                        items: [
                          SettingsItem(
                            icon: Icons.description_outlined,
                            title: S.of(context).legalPolicies,
                            subtitle: S.of(context).termsPrivacyPolicy,
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.help_outline,
                            title: S.of(context).helpSupport,
                            subtitle: S.of(context).getHelpSupport,
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.info_outline,
                            title: S.of(context).about,
                            subtitle: S.of(context).appVersion("1.0.0"),
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
                          title: Text(
                            S.of(context).logout,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          subtitle: Text(
                            S.of(context).signOut,
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

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
