import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/generated/l10n.dart';

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
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8EFFE),
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkAppBar : AppColors.lightAppBar,
        title: Text(S.of(context).profile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Username Field
                  _EditableFieldCard(
                    label: S.of(context).username,
                    value: profileController.userName ?? '—',
                    onTap: () => _showEditDialog(
                      context: context,
                      title: S.of(context).editUsername,
                      initialValue: profileController.userName ?? '',
                      onSave: (value) =>
                          profileController.updateLoggedUserData(name: value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Email Field
                  _EditableFieldCard(
                    label: S.of(context).email,
                    value: profileController.userEmail ?? '—',
                    onTap: () => _showEditDialog(
                      context: context,
                      title: S.of(context).editEmail,
                      initialValue: profileController.userEmail ?? '',
                      isEmail: true,
                      onSave: (value) =>
                          profileController.updateLoggedUserData(email: value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Password Field
                  _EditableFieldCard(
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
    required Future<bool> Function(String value) onSave,
    bool isEmail = false,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return S.of(context).fieldRequired;
              }
              if (isEmail) {
                final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              final value = controller.text.trim();
              if (value.isEmpty) return;

              final success = await onSave(value);
              if (!ctx.mounted) return;

              if (success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ ${S.of(context).updatedSuccessfully}')),
                );
              } else {
                final profileController = Provider.of<ProfileController>(context, listen: false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(profileController.errorMessage ?? '❌ Failed to update'),
                  ),
                );
              }
            },
            child: Text(S.of(context).create),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // PASSWORD DIALOG
  // -------------------------
  void _showPasswordDialog(BuildContext context) {
    final profileController =
        Provider.of<ProfileController>(context, listen: false);
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).changePassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordCtrl,
                decoration: InputDecoration(
                  labelText: '${S.of(context).currentPassword} *',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return S.of(context).currentPasswordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordCtrl,
                decoration: InputDecoration(
                  labelText: '${S.of(context).newPassword} *',
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordCtrl,
                decoration: InputDecoration(
                  labelText: '${S.of(context).confirmNewPassword} *',
                  border: OutlineInputBorder(),
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
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
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
                  SnackBar(content: Text('✅ ${S.of(context).passwordUpdatedSuccessfully}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(profileController.errorMessage ??
                        '❌ Failed to update password'),
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
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditableFieldCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                const Icon(Icons.edit, color: Colors.black45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
