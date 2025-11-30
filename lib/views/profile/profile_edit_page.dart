import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8EFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xff28336f),
        title: const Text('Profile'),
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
                    label: 'Username',
                    value: profileController.userData?['data']?['name'] ?? '—',
                    onTap: () => _showEditDialog(
                      context: context,
                      title: 'Edit Username',
                      initialValue:
                          profileController.userData?['data']?['name'] ?? '',
                      onSave: (value) =>
                          profileController.updateLoggedUserData(name: value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Email Field
                  _EditableFieldCard(
                    label: 'Email',
                    value: profileController.userData?['data']?['email'] ?? '—',
                    onTap: () => _showEditDialog(
                      context: context,
                      title: 'Edit Email',
                      initialValue:
                          profileController.userData?['data']?['email'] ?? '',
                      onSave: (value) =>
                          profileController.updateLoggedUserData(email: value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Password Field
                  _EditableFieldCard(
                    label: 'Password',
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
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isEmpty) return;

              final success = await onSave(value);
              if (!ctx.mounted) return;

              if (success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Failed to update')),
                );
              }
            },
            child: const Text('Save'),
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
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordCtrl,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordCtrl,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Passwords do not match')),
                );
                return;
              }

              final success = await profileController
                  .updateLoggedUserPassword(newPasswordCtrl.text.trim());

              if (!ctx.mounted) return;

              if (success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Password updated')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(profileController.errorMessage ??
                        '❌ Failed to update'),
                  ),
                );
              }
            },
            child: const Text('Change Password'),
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
