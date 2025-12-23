import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:filevo/services/folder_protection_service.dart';

// 🔑 GlobalKey للوصول للـ ScaffoldMessenger من أي مكان
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// ✅ Dialog لتعيين حماية المجلد (كلمة سر أو بصمة)
class SetFolderProtectionDialog extends StatefulWidget {
  final String folderId;
  final String folderName;
  final bool isCurrentlyProtected;
  final String? currentProtectionType;

  const SetFolderProtectionDialog({
    Key? key,
    required this.folderId,
    required this.folderName,
    this.isCurrentlyProtected = false,
    this.currentProtectionType,
  }) : super(key: key);

  @override
  State<SetFolderProtectionDialog> createState() =>
      _SetFolderProtectionDialogState();
}

class _SetFolderProtectionDialogState extends State<SetFolderProtectionDialog> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedProtectionType = 'password';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrentlyProtected) {
      _selectedProtectionType = widget.currentProtectionType ?? 'password';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _setProtection() async {
    if (_selectedProtectionType == 'password') {
      if (_passwordController.text.isEmpty) {
        _showSnackBar(
          '⚠️ يرجى إدخال كلمة السر',
          backgroundColor: Colors.orange,
        );
        return;
      }
      if (_passwordController.text.length < 4) {
        _showSnackBar(
          '⚠️ كلمة السر يجب أن تكون 4 أحرف على الأقل',
          backgroundColor: Colors.orange,
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar('⚠️ كلمة السر غير متطابقة', backgroundColor: Colors.red);
        return;
      }
    }

    setState(() => _isLoading = true);

    final result = await FolderProtectionService.setFolderProtection(
      folderId: widget.folderId,
      password: _selectedProtectionType == 'password'
          ? _passwordController.text
          : null,
      protectionType: _selectedProtectionType,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackBar(result['message'] ?? '✅ تم تفعيل الحماية بنجاح');
      Navigator.pop(context, true);
    } else {
      _showSnackBar(
        result['message'] ?? '❌ فشل تفعيل الحماية',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _testBiometric() async {
    final localAuth = LocalAuthentication();
    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        _showSnackBar(
          '❌ البصمة غير مدعومة على هذا الجهاز',
          backgroundColor: Colors.red,
        );
        return;
      }

      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'يرجى التحقق من البصمة لتفعيل حماية المجلد',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        _showSnackBar('✅ تم التحقق من البصمة بنجاح');
      } else {
        _showSnackBar('❌ فشل التحقق من البصمة', backgroundColor: Colors.red);
      }
    } catch (e) {
      _showSnackBar('❌ خطأ: ${e.toString()}', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue[700], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isCurrentlyProtected
                          ? 'تعديل حماية المجلد'
                          : 'قفل المجلد',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.folderName,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Text(
                'نوع الحماية:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 20),
                    SizedBox(width: 8),
                    Text('كلمة سر'),
                  ],
                ),
                value: 'password',
                groupValue: _selectedProtectionType,
                onChanged: (value) {
                  setState(() => _selectedProtectionType = value!);
                },
              ),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.fingerprint, size: 20),
                    SizedBox(width: 8),
                    Text('بصمة'),
                  ],
                ),
                value: 'biometric',
                groupValue: _selectedProtectionType,
                onChanged: (value) {
                  setState(() => _selectedProtectionType = value!);
                },
              ),
              const SizedBox(height: 24),
              if (_selectedProtectionType == 'password') ...[
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة السر',
                    hintText: 'أدخل كلمة السر',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة السر',
                    hintText: 'أعد إدخال كلمة السر',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _testBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('اختبار البصمة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _setProtection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('حفظ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Dialog التحقق من كلمة السر / البصمة عند فتح مجلد
class VerifyFolderAccessDialog extends StatefulWidget {
  final String folderId;
  final String folderName;
  final String protectionType; // 'password' or 'biometric'

  const VerifyFolderAccessDialog({
    Key? key,
    required this.folderId,
    required this.folderName,
    required this.protectionType,
  }) : super(key: key);

  @override
  State<VerifyFolderAccessDialog> createState() =>
      _VerifyFolderAccessDialogState();
}

class _VerifyFolderAccessDialogState extends State<VerifyFolderAccessDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = '⚠️ يرجى إدخال كلمة السر');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await FolderProtectionService.verifyFolderAccess(
      folderId: widget.folderId,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true && result['hasAccess'] == true) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMessage = result['message'] ?? '❌ كلمة السر غير صحيحة';
      });
    }
  }

  Future<void> _verifyBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final localAuth = LocalAuthentication();
    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = '❌ البصمة غير مدعومة على هذا الجهاز';
        });
        return;
      }

      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'يرجى التحقق من البصمة للوصول إلى المجلد',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        final result = await FolderProtectionService.verifyFolderAccess(
          folderId: widget.folderId,
          biometricToken:
              'biometric_verified_${DateTime.now().millisecondsSinceEpoch}',
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['success'] == true && result['hasAccess'] == true) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = result['message'] ?? '❌ فشل التحقق';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '❌ فشل التحقق من البصمة';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '❌ خطأ: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: Colors.orange[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المجلد محمي',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.folderName,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (widget.protectionType == 'password') ...[
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة السر',
                  hintText: 'أدخل كلمة السر',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _verifyPassword(),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _verifyBiometric,
                  icon: const Icon(Icons.fingerprint, size: 24),
                  label: const Text(
                    'التحقق بالبصمة',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                if (widget.protectionType == 'password') ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('فتح'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
