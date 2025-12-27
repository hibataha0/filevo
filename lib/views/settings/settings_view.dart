import 'package:filevo/main.dart';
import 'package:filevo/views/settings/AboutPage.dart';
import 'package:filevo/views/settings/HelpSupportPage.dart';
import 'package:filevo/views/settings/LegalPolicyPage.dart';
import 'package:filevo/views/settings/NotificationsPage.dart';
import 'package:filevo/views/settings/PrivacySecurityPage.dart';
import 'package:filevo/views/settings/StoragePage%20.dart';
import 'package:filevo/views/settings/components/settings_item.dart';
import 'package:filevo/views/settings/components/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/auth/auth_controller.dart';
import 'package:filevo/views/settings/trash_files_page.dart';
import 'package:filevo/views/settings/trash_folders_page.dart';
import 'package:filevo/views/settings/activity_log_page.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/activity_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/controllers/ThemeController.dart';
import 'package:filevo/constants/app_colors.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _selectedLocale = const Locale('en');

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).logout),
          content: Text(S.of(context).signOut),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                S.of(context).logout,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final authController = context.read<AuthController>();
      await authController.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).logoutSuccess),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('LogInPage', (route) => false);
      }
    }
  }

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
                  setState(() => _selectedLocale = const Locale('en'));
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
                  setState(() => _selectedLocale = const Locale('ar'));
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
    final themeController = context.watch<ThemeController>();
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkAppBar
          : AppColors.lightAppBar,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
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

            Expanded(
              child: Consumer<ThemeController>(
                builder: (context, themeController, child) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    color: themeController.isDarkMode
                        ? const Color(0xFF121212)
                        : const Color(0xFFE9E9E9),
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
                              Consumer<ThemeController>(
                                builder: (context, themeController, child) {
                                  return SettingsItem(
                                    icon: Icons.dark_mode_outlined,
                                    title: S.of(context).darkMode,
                                    subtitle: S.of(context).switchThemes,
                                    trailing: Switch(
                                      value: themeController.isDarkMode,
                                      onChanged: (value) {
                                        print('🔄 Toggling theme to: $value');
                                        themeController.toggleTheme(value);
                                      },
                                      activeColor: AppColors.lightAppBar,
                                    ),
                                    onTap: () {
                                      themeController.toggleTheme(
                                        !themeController.isDarkMode,
                                      );
                                    },
                                  );
                                },
                              ),
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
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsPage(),
                                  ),
                                ),
                              ),
                              SettingsItem(
                                icon: Icons.storage,
                                title: S.of(context).storage,
                                subtitle: S.of(context).manageStorageSettings,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StoragePage(),
                                  ),
                                ),
                              ),
                              SettingsItem(
                                icon: Icons.security,
                                title: S.of(context).privacySecurity,
                                subtitle: S.of(context).privacySettings,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacySecurityPage(),
                                  ),
                                ),
                              ),

                              /// 🔥 خيار المحذوفات هنا
                              SettingsItem(
                                icon: Icons.delete_outline,
                                title: S.of(context).trash,
                                subtitle: S
                                    .of(context)
                                    .viewDeletedFilesAndFolders,
                                onTap: () async {
                                  final token = await StorageService.getToken();

                                  if (token == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          S.of(context).tokenNotFound,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // عرض قائمة للاختيار بين الملفات والمجلدات
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(S.of(context).trash),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.insert_drive_file,
                                            ),
                                            title: Text(
                                              S.of(context).deletedFiles,
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      TrashFilesPage(
                                                        token: token,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.folder),
                                            title: Text(
                                              S.of(context).deletedFolders,
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ChangeNotifierProvider(
                                                        create: (_) =>
                                                            FolderController(),
                                                        child:
                                                            const TrashFoldersPage(),
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SettingsItem(
                                icon: Icons.history,
                                title: S.of(context).activityLog,
                                subtitle: S.of(context).viewAllActivities,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChangeNotifierProvider(
                                        create: (_) => ActivityController(),
                                        child: const ActivityLogPage(),
                                      ),
                                    ),
                                  );
                                },
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
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LegalPolicyPage(),
                                  ),
                                ),
                              ),
                              SettingsItem(
                                icon: Icons.help_outline,
                                title: S.of(context).helpSupport,
                                subtitle: S.of(context).getHelpSupport,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HelpSupportPage(),
                                  ),
                                ),
                              ),
                              SettingsItem(
                                icon: Icons.info_outline,
                                title: S.of(context).about,
                                subtitle: S.of(context).appVersion("1.0.0"),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AboutPage(),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 60),

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
                              onTap: () => _handleLogout(context),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
