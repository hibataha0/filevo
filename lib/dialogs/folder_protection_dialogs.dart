import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:provider/provider.dart';

/// ✅ التحقق من دعم البصمة
Future<bool> _checkBiometricSupport() async {
  try {
    final LocalAuthentication localAuth = LocalAuthentication();
    final bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    final bool isDeviceSupported = await localAuth.isDeviceSupported();
    return canCheckBiometrics && isDeviceSupported;
  } catch (e) {
    return false;
  }
}

/// 🔒 Dialog لتعيين حماية المجلد
Future<void> showSetFolderProtectionDialog(
  BuildContext context,
  String folderId,
  String folderName,
  bool isCurrentlyProtected,
  String? currentProtectionType,
  VoidCallback? onProtectionChanged,
) async {
  String? selectedType;
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showPassword = false;
  bool showConfirmPassword = false;
  String? errorMessage; // ✅ رسالة الخطأ

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          isCurrentlyProtected
              ? 'إزالة حماية المجلد'
              : 'قفل المجلد',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المجلد: $folderName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              // ✅ عرض رسالة الخطأ داخل dialog
              if (errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
              if (!isCurrentlyProtected) ...[
                Text(
                  'اختر نوع الحماية:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                RadioListTile<String>(
                  title: Text('🔒 كلمة سر'),
                  value: 'password',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                FutureBuilder<bool>(
                  future: _checkBiometricSupport(),
                  builder: (context, snapshot) {
                    final isSupported = snapshot.data ?? false;
                    if (!isSupported) {
                      return SizedBox.shrink();
                    }
                    return RadioListTile<String>(
                      title: Text('👆 بصمة'),
                      value: 'biometric',
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                    );
                  },
                ),
                if (selectedType == 'password') ...[
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة السر',
                      hintText: 'أدخل كلمة السر (4 أحرف على الأقل)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة السر',
                      hintText: 'أعد إدخال كلمة السر',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'هل تريد إزالة الحماية من هذا المجلد؟',
                  style: TextStyle(fontSize: 16),
                ),
                if (currentProtectionType == 'password') ...[
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة السر الحالية',
                      hintText: 'أدخل كلمة السر لإزالة الحماية',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ مسح رسالة الخطأ السابقة
              setState(() {
                errorMessage = null;
              });

              if (!isCurrentlyProtected) {
                // تعيين حماية جديدة
                if (selectedType == null) {
                  setState(() {
                    errorMessage = 'يرجى اختيار نوع الحماية';
                  });
                  return;
                }

                if (selectedType == 'password') {
                  if (passwordController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'يرجى إدخال كلمة السر';
                    });
                    return;
                  }

                  if (passwordController.text.length < 4) {
                    setState(() {
                      errorMessage = 'كلمة السر يجب أن تكون 4 أحرف على الأقل';
                    });
                    return;
                  }

                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    setState(() {
                      errorMessage = 'كلمات السر غير متطابقة';
                    });
                    return;
                  }
                }

                // تفعيل الحماية
                final folderController =
                    Provider.of<FolderController>(context, listen: false);
                final success = await folderController.protectFolder(
                  folderId: folderId,
                  protectionType: selectedType!,
                  password: selectedType == 'password'
                      ? passwordController.text
                      : null,
                );

                if (success) {
                  Navigator.pop(dialogContext);
                  // ✅ استخدام callback فقط - لا نستخدم ScaffoldMessenger
                  if (onProtectionChanged != null) {
                    onProtectionChanged();
                  }
                } else {
                  setState(() {
                    errorMessage = folderController.errorMessage ??
                        'فشل تفعيل حماية المجلد';
                  });
                }
              } else {
                // إزالة الحماية
                final folderController =
                    Provider.of<FolderController>(context, listen: false);
                final success = await folderController.removeFolderProtection(
                  folderId: folderId,
                  password: currentProtectionType == 'password'
                      ? passwordController.text
                      : null,
                );

                if (success) {
                  Navigator.pop(dialogContext);
                  // ✅ استخدام callback فقط - لا نستخدم ScaffoldMessenger
                  if (onProtectionChanged != null) {
                    onProtectionChanged();
                  }
                } else {
                  setState(() {
                    errorMessage = folderController.errorMessage ??
                        'فشل إزالة حماية المجلد';
                  });
                }
              }
            },
            child: Text(isCurrentlyProtected ? 'إزالة الحماية' : 'قفل المجلد'),
          ),
        ],
      ),
    ),
  );
}

/// 🔐 Dialog للتحقق من الوصول لمجلد محمي
/// Returns: Map with 'success' (bool) and 'password' (String?) if success
Future<Map<String, dynamic>> showVerifyFolderAccessDialog(
  BuildContext context,
  String folderId,
  String folderName,
  String protectionType, // "password" | "biometric"
) async {
  bool? successResult;
  String? verifiedPassword; // ✅ كلمة السر المستخدمة في التحقق
  final passwordController = TextEditingController();
  bool showPassword = false;
  final LocalAuthentication localAuth = LocalAuthentication();
  String? errorMessage; // ✅ رسالة الخطأ

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 10),
            Text('مجلد محمي'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المجلد "$folderName" محمي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              // ✅ عرض رسالة الخطأ داخل dialog
              if (errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
              if (protectionType == 'password') ...[
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة السر',
                    hintText: 'أدخل كلمة السر',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      setState(() {
                        errorMessage = null;
                      });
                      await _verifyAccess(
                        context,
                        folderId,
                        password: value,
                        biometricToken: null,
                        dialogContext: dialogContext,
                        setState: setState,
                        setErrorMessage: (msg) {
                          setState(() {
                            errorMessage = msg;
                          });
                        },
                        setResult: (success, password) {
                          successResult = success;
                          if (success && password != null) {
                            verifiedPassword = password;
                          }
                        },
                      );
                    }
                  },
                ),
              ] else if (protectionType == 'biometric') ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fingerprint,
                        size: 64,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'استخدم البصمة للوصول',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (protectionType == 'biometric')
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  errorMessage = null;
                });
                await _verifyBiometric(
                  context,
                  folderId,
                  dialogContext: dialogContext,
                  localAuth: localAuth,
                  setState: setState,
                  setErrorMessage: (msg) {
                    setState(() {
                      errorMessage = msg;
                    });
                  },
                  setResult: (success, password) {
                    successResult = success;
                    if (success && password != null) {
                      verifiedPassword = password;
                    }
                  },
                );
              },
              icon: Icon(Icons.fingerprint),
              label: Text('التحقق بالبصمة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          if (protectionType == 'password')
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  errorMessage = null;
                });

                if (passwordController.text.isEmpty) {
                  setState(() {
                    errorMessage = 'يرجى إدخال كلمة السر';
                  });
                  return;
                }

                await _verifyAccess(
                  context,
                  folderId,
                  password: passwordController.text,
                  biometricToken: null,
                  dialogContext: dialogContext,
                  setState: setState,
                  setErrorMessage: (msg) {
                    setState(() {
                      errorMessage = msg;
                    });
                  },
                  setResult: (success, password) {
                    successResult = success;
                    if (success && password != null) {
                      verifiedPassword = password;
                    }
                  },
                );
              },
              child: Text('فتح'),
            ),
          TextButton(
            onPressed: () {
              successResult = false;
              Navigator.pop(dialogContext);
            },
            child: Text('إلغاء'),
          ),
        ],
      ),
    ),
  );

  return {
    'success': successResult ?? false,
    'password': verifiedPassword,
  };
}

/// 🔐 التحقق من الوصول
Future<void> _verifyAccess(
  BuildContext context,
  String folderId, {
  String? password,
  String? biometricToken,
  required BuildContext dialogContext,
  required StateSetter setState,
  required Function(String) setErrorMessage,
  required Function(bool, String?) setResult, // ✅ إرجاع success و password
}) async {
  final folderController =
      Provider.of<FolderController>(context, listen: false);

  final success = await folderController.verifyFolderAccess(
    folderId: folderId,
    password: password,
    biometricToken: biometricToken,
  );

  if (success) {
    setResult(true, password); // ✅ إرجاع success و password
    Navigator.pop(dialogContext);
  } else {
    // ✅ عرض رسالة الخطأ داخل dialog
    setResult(false, null);
    setErrorMessage(folderController.errorMessage ?? 'كلمة السر غير صحيحة');
  }
}

/// 👆 التحقق بالبصمة
Future<void> _verifyBiometric(
  BuildContext context,
  String folderId, {
  required BuildContext dialogContext,
  required LocalAuthentication localAuth,
  required StateSetter setState,
  required Function(String) setErrorMessage,
  required Function(bool, String?) setResult, // ✅ إرجاع success و password
}) async {
  try {
    // التحقق من توفر البصمة
    final bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    final bool isDeviceSupported = await localAuth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      setErrorMessage('البصمة غير متاحة على هذا الجهاز');
      return;
    }

    // التحقق من البصمة
    final bool didAuthenticate = await localAuth.authenticate(
      localizedReason: 'يرجى التحقق من البصمة للوصول للمجلد',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (didAuthenticate) {
      // إرسال token للباك إند (في التطبيق الحقيقي، قد تحتاج لتوقيع token)
      final folderController =
          Provider.of<FolderController>(context, listen: false);

      final success = await folderController.verifyFolderAccess(
        folderId: folderId,
        password: null,
        biometricToken: 'biometric_verified_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (success) {
        setResult(true, null); // ✅ البصمة لا تحتاج password
        Navigator.pop(dialogContext);
      } else {
        setResult(false, null);
        setErrorMessage(folderController.errorMessage ?? 'فشل التحقق بالبصمة');
      }
    }
  } catch (e) {
    setErrorMessage('خطأ في التحقق بالبصمة: ${e.toString()}');
  }
}

