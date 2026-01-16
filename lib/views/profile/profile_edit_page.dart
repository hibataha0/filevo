import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/views/profile/email_change_verification_page.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ProfileController>();

      if (controller.userData == null) {
        controller.getLoggedUserData();
        print("🔵 Fetching logged user data...");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final isLoading =
        profileController.isLoading && profileController.userData == null;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDarkMode),
      appBar: AppBar(
        backgroundColor: AppColors.getAppBar(isDarkMode),
        title: Text(S.of(context).profile),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.getPrimary(isDarkMode),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      '${S.of(context).edit} ${S.of(context).profile}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                  ),

                  // Username Field
                  _EditableFieldCard(
                    icon: Icons.person_outline,
                    label: S.of(context).username,
                    value: profileController.userName ?? '—',
                    onTap: () => _showEditDialog(
                      context: context,
                      title: S.of(context).editUsername,
                      initialValue: profileController.userName ?? '',
                      onSave: (value) async {
                        final result = await profileController
                            .updateLoggedUserData(name: value);
                        return result;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  _EditableFieldCard(
                    icon: Icons.email_outlined,
                    label: S.of(context).email,
                    value: profileController.userEmail ?? '—',
                    onTap: () => _showEditDialog(
                      context: context,
                      title: S.of(context).editEmail,
                      initialValue: profileController.userEmail ?? '',
                      isEmail: true,
                      onSave: (value) async {
                        final result = await profileController
                            .updateLoggedUserData(email: value);
                        return result;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  _EditableFieldCard(
                    icon: Icons.lock_outline,
                    label: S.of(context).password,
                    value: '••••••••',
                    onTap: () => _showPasswordDialog(context),
                  ),
                ],
              ),
            ),
    );
  }

  // -------------------------
  // EDIT TEXT DIALOG
  // -------------------------
  void _showEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    required Future<Map<String, dynamic>> Function(String value) onSave,
    bool isEmail = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getCardColor(isDarkMode),
        title: Text(
          title,
          style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.darkSurface),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.darkSurface),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.getPrimary(isDarkMode),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.getBackground(isDarkMode),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return S.of(context).fieldRequired;
              }
              if (isEmail) {
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(value.trim())) {
                  return S.of(context).validEmailRequired;
                }
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDarkMode),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final value = controller.text.trim();
              if (value.isEmpty) return;

              final result = await onSave(value);
              if (!ctx.mounted) return;

              print('🔵 ProfileEditPage: onSave result: $result');
              print('🔵 ProfileEditPage: result keys: ${result.keys.toList()}');
              print('🔵 ProfileEditPage: requiresVerification = ${result['requiresVerification']}');
              print('🔵 ProfileEditPage: isEmail = $isEmail');

              if (result['success'] == true) {
                // ✅ التحقق من وجود requiresVerification
                if (result['requiresVerification'] == true && isEmail) {
                  print('✅ ProfileEditPage: Opening email verification page');
                  Navigator.pop(ctx);
                  // ✅ فتح صفحة إدخال كود التحقق
                  final pendingEmail =
                      result['pendingEmail'] as String? ?? value;
                  print('✅ ProfileEditPage: pendingEmail = $pendingEmail');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailChangeVerificationPage(
                        pendingEmail: pendingEmail,
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${S.of(context).updatedSuccessfully}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } else {
                final profileController = Provider.of<ProfileController>(
                  context,
                  listen: false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['error'] as String? ??
                          profileController.errorMessage ??
                          S.of(context).failedToUpdate,
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(S.of(context).update),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // PASSWORD DIALOG
  // -------------------------
  void _showPasswordDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileController = Provider.of<ProfileController>(
      context,
      listen: false,
    );
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getCardColor(isDarkMode),
        title: Text(
          S.of(context).changePassword,
          style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordCtrl,
                style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
                decoration: InputDecoration(
                  labelText: '${S.of(context).currentPassword} *',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDarkMode),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkSurface),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkSurface),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.getPrimary(isDarkMode),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.getBackground(isDarkMode),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return S.of(context).currentPasswordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordCtrl,
                style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
                decoration: InputDecoration(
                  labelText: '${S.of(context).newPassword} *',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDarkMode),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkSurface),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkSurface),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.getPrimary(isDarkMode),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.getBackground(isDarkMode),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return S.of(context).newPasswordRequired;
                  }
                  if (value.length < 6) {
                    return S.of(context).passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordCtrl,
                style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
                decoration: InputDecoration(
                  labelText: '${S.of(context).confirmNewPassword} *',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDarkMode),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkSurface),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkSurface),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.getPrimary(isDarkMode),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.getBackground(isDarkMode),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return S.of(context).passwordConfirmationRequired;
                  }
                  if (value != newPasswordCtrl.text) {
                    return S.of(context).passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: AppColors.getTextPrimary(isDarkMode)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDarkMode),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final success = await profileController.updateLoggedUserPassword(
                currentPassword: currentPasswordCtrl.text.trim(),
                password: newPasswordCtrl.text.trim(),
                passwordConfirm: confirmPasswordCtrl.text.trim(),
              );

              if (!ctx.mounted) return;

              if (success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ ${S.of(context).passwordUpdatedSuccessfully}',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      profileController.errorMessage ??
                          S.of(context).failedToUpdatePassword,
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(S.of(context).changePassword),
          ),
        ],
      ),
    );
  }
}

// -------------------------
// CUSTOM CARD WIDGET
// -------------------------
class _EditableFieldCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditableFieldCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkSurface, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(isDarkMode),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDarkMode).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.getPrimary(isDarkMode),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Label and Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextSecondary(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
                ],
              ),
            ),
            // Edit Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.getTextSecondary(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }
}
