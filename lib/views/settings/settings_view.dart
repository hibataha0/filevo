import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/main.dart';
import 'package:filevo/services/user_cache_service.dart';
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
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(isDarkMode),
          title: Text(
            S.of(context).logout,
            style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
          ),
          content: Text(
            S.of(context).signOut,
            style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: AppColors.getTextSecondary(isDarkMode)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                S.of(context).logout,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final authController = context.read<AuthController>();
      final profileController = context.read<ProfileController>();

      // 🔹 1. إرسال request للـ backend
      await authController.logout();

      // 🔹 2. مسح cache المستخدم
      UserCacheService().clearCache();

      // 🔹 3. مسح بيانات المستخدم من ProfileController
      profileController.clearUserData();

      // 🔹 4. حذف token و userId
      await StorageService.deleteToken();
      await StorageService.deleteUserId();

      // 🔹 5. إظهار SnackBar تأكيد
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).logoutSuccess),
            backgroundColor: AppColors.success,
          ),
        );

        // 🔹 6. إعادة التوجيه لشاشة تسجيل الدخول مع مسح الـ navigation stack
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('LogInPage', (route) => false);
      }
    }
  }

  void _showLanguageMenu(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getCardColor(isDarkMode),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).chooseLanguage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDarkMode),
                ),
              ),
              Divider(color: AppColors.darkSurface),
              ListTile(
                leading: Icon(
                  Icons.language,
                  color: AppColors.getTextSecondary(isDarkMode),
                ),
                title: Text(
                  S.of(context).english,
                  style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
                ),
                trailing: _selectedLocale.languageCode == 'en'
                    ? Icon(Icons.check, color: AppColors.getPrimary(isDarkMode))
                    : null,
                onTap: () {
                  setState(() => _selectedLocale = const Locale('en'));
                  MyApp.setLocale(context, const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.language,
                  color: AppColors.getTextSecondary(isDarkMode),
                ),
                title: Text(
                  S.of(context).arabic,
                  style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
                ),
                trailing: _selectedLocale.languageCode == 'ar'
                    ? Icon(Icons.check, color: AppColors.getPrimary(isDarkMode))
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
                style: TextStyle(
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
                    color: AppColors.getBackground(themeController.isDarkMode),
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
                                    builder: (context) {
                                      final isDarkMode =
                                          Theme.of(context).brightness ==
                                          Brightness.dark;
                                      return AlertDialog(
                                        backgroundColor: AppColors.getCardColor(
                                          isDarkMode,
                                        ),
                                        title: Text(
                                          S.of(context).trash,
                                          style: TextStyle(
                                            color: AppColors.getTextPrimary(
                                              isDarkMode,
                                            ),
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.insert_drive_file,
                                                color:
                                                    AppColors.getTextSecondary(
                                                      isDarkMode,
                                                    ),
                                              ),
                                              title: Text(
                                                S.of(context).deletedFiles,
                                                style: TextStyle(
                                                  color:
                                                      AppColors.getTextPrimary(
                                                        isDarkMode,
                                                      ),
                                                ),
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
                                              leading: Icon(
                                                Icons.folder,
                                                color:
                                                    AppColors.getTextSecondary(
                                                      isDarkMode,
                                                    ),
                                              ),
                                              title: Text(
                                                S.of(context).deletedFolders,
                                                style: TextStyle(
                                                  color:
                                                      AppColors.getTextPrimary(
                                                        isDarkMode,
                                                      ),
                                                ),
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
                                      );
                                    },
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
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                S.of(context).logout,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                              subtitle: Text(
                                S.of(context).signOut,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.error.withOpacity(0.7),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.error,
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
