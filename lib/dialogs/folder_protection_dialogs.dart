import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:provider/provider.dart';
import 'package:filevo/generated/l10n.dart';

/// 🔒 Dialog لتعيين حماية المجلد
Future<void> showSetFolderProtectionDialog(
  BuildContext context,
  String folderId,
  String folderName,
  bool isCurrentlyProtected,
  String? currentProtectionType,
  VoidCallback? onProtectionChanged,
) async {
  // ✅ إذا كان المجلد محمياً، استخدم الـ dialog البسيط لإزالة الحماية
  print('🔐 [showSetFolderProtectionDialog] Checking protection status:');
  print('   - isCurrentlyProtected: $isCurrentlyProtected');
  print('   - currentProtectionType: $currentProtectionType');

  if (isCurrentlyProtected) {
    // ✅ استخدام protectionType من البيانات أو افتراض 'password' إذا لم يكن محدداً
    final protectionType =
        (currentProtectionType != null && currentProtectionType != 'none')
        ? currentProtectionType
        : 'password'; // ✅ افتراض password إذا لم يكن محدداً

    print(
      '🔓 [showSetFolderProtectionDialog] Opening remove protection dialog with type: $protectionType',
    );

    await showRemoveFolderProtectionDialog(
      context,
      folderId,
      folderName,
      protectionType,
      onProtectionChanged,
    );
    return;
  }

  print('🔒 [showSetFolderProtectionDialog] Opening set protection dialog');

  // ✅ إذا لم يكن محمياً، استخدم الـ dialog العادي لتعيين الحماية
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showPassword = false;
  bool showConfirmPassword = false;
  String? errorMessage; // ✅ رسالة الخطأ
  final scaffoldContext = context; // ✅ حفظ الـ context الأصلي للـ Scaffold

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          isCurrentlyProtected
              ? S.of(context).unlockFolder
              : S.of(context).lockFolder,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).folderLabel(folderName),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                // ✅ فقط كلمة السر - بدون خيار البصمة
                Text(
                  S.of(context).enterPasswordToLockFolder,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ...[
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: S.of(context).passwordLabel,
                      hintText: S.of(context).enterPasswordHint,
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
                      labelText: S.of(context).confirmPasswordLabel,
                      hintText: S.of(context).reenterPasswordHint,
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
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ مسح رسالة الخطأ السابقة
              setState(() {
                errorMessage = null;
              });

              // ✅ تعيين حماية جديدة - فقط كلمة السر
              if (passwordController.text.isEmpty) {
                setState(() {
                  errorMessage = S.of(context).pleaseEnterPassword;
                });
                return;
              }

              if (passwordController.text.length < 4) {
                setState(() {
                  errorMessage = S.of(context).passwordMin4Chars;
                });
                return;
              }

              if (passwordController.text != confirmPasswordController.text) {
                setState(() {
                  errorMessage = S.of(context).passwordsDoNotMatch;
                });
                return;
              }

              // تفعيل الحماية - فقط كلمة السر
              final folderController = Provider.of<FolderController>(
                context,
                listen: false,
              );
              final success = await folderController.protectFolder(
                folderId: folderId,
                protectionType: 'password',
                password: passwordController.text,
              );

              if (success) {
                Navigator.pop(dialogContext);
                // ✅ عرض رسالة النجاح باستخدام الـ context الأصلي
                // ✅ استخدام WidgetsBinding للتأكد من أن الـ dialog تم إغلاقه والـ Scaffold جاهز
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    final messenger = ScaffoldMessenger.maybeOf(
                      scaffoldContext,
                    );
                    if (messenger != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(scaffoldContext).folderProtectionEnabled,
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                });
                // ✅ استخدام callback لإعادة تحميل البيانات
                if (onProtectionChanged != null) {
                  onProtectionChanged();
                }
              } else {
                setState(() {
                  errorMessage =
                      folderController.errorMessage ??
                      S.of(context).failedToEnableProtection;
                });
              }
            },
            child: Text(S.of(context).lockFolder),
          ),
        ],
      ),
    ),
  );
}

/// 🔓 Dialog بسيط لإزالة حماية المجلد
Future<bool> showRemoveFolderProtectionDialog(
  BuildContext context,
  String folderId,
  String folderName,
  String protectionType, // "password" | "biometric"
  VoidCallback? onProtectionRemoved,
) async {
  bool? successResult;
  final passwordController = TextEditingController();
  bool showPassword = false;
  final LocalAuthentication localAuth = LocalAuthentication();
  String? errorMessage;
  final scaffoldContext = context; // ✅ حفظ الـ context الأصلي للـ Scaffold

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_open, color: Colors.orange),
            SizedBox(width: 10),
            Text(S.of(context).unlockFolder),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).removeProtectionQuestion,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    labelText: S.of(context).currentPasswordLabel,
                    hintText: S.of(context).enterPasswordToRemoveProtection,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
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
                      await _removeProtection(
                        scaffoldContext,
                        folderId,
                        password: value,
                        dialogContext: dialogContext,
                        setState: setState,
                        setErrorMessage: (msg) {
                          setState(() {
                            errorMessage = msg;
                          });
                        },
                        setResult: (success) {
                          successResult = success;
                        },
                        onProtectionRemoved: onProtectionRemoved,
                      );
                    }
                  },
                ),
              ] else if (protectionType == 'biometric') ...[
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.fingerprint, size: 64, color: Colors.blue),
                      SizedBox(height: 20),
                      Text(
                        S.of(context).useFingerprintToAccess,
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
                await _removeProtectionWithBiometric(
                  scaffoldContext,
                  folderId,
                  dialogContext: dialogContext,
                  localAuth: localAuth,
                  setState: setState,
                  setErrorMessage: (msg) {
                    setState(() {
                      errorMessage = msg;
                    });
                  },
                  setResult: (success) {
                    successResult = success;
                  },
                  onProtectionRemoved: onProtectionRemoved,
                );
              },
              icon: Icon(Icons.fingerprint),
              label: Text(S.of(context).verifyWithFingerprint),
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
                    errorMessage = S.of(context).pleaseEnterPassword;
                  });
                  return;
                }

                await _removeProtection(
                  scaffoldContext,
                  folderId,
                  password: passwordController.text,
                  dialogContext: dialogContext,
                  setState: setState,
                  setErrorMessage: (msg) {
                    setState(() {
                      errorMessage = msg;
                    });
                  },
                  setResult: (success) {
                    successResult = success;
                  },
                  onProtectionRemoved: onProtectionRemoved,
                );
              },
              child: Text(S.of(context).unlockFolder),
            ),
          TextButton(
            onPressed: () {
              successResult = false;
              Navigator.pop(dialogContext);
            },
            child: Text(S.of(context).cancel),
          ),
        ],
      ),
    ),
  );

  return successResult ?? false;
}

/// 🔓 إزالة الحماية
Future<void> _removeProtection(
  BuildContext context,
  String folderId, {
  String? password,
  required BuildContext dialogContext,
  required StateSetter setState,
  required Function(String) setErrorMessage,
  required Function(bool) setResult,
  VoidCallback? onProtectionRemoved,
}) async {
  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );

  final success = await folderController.removeFolderProtection(
    folderId: folderId,
    password: password,
  );

  if (success) {
    setResult(true);
    Navigator.pop(dialogContext);
    // ✅ عرض رسالة النجاح باستخدام الـ context الأصلي
    // ✅ استخدام Future.delayed مع WidgetsBinding للتأكد من أن الـ dialog تم إغلاقه بالكامل
    Future.delayed(Duration(milliseconds: 50), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(S.of(context).folderProtectionDisabled),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      });
    });
    if (onProtectionRemoved != null) {
      onProtectionRemoved();
    }
  } else {
    setResult(false);
    setErrorMessage(
      folderController.errorMessage ?? S.of(context).failedToRemoveProtection,
    );
  }
}

/// 👆 إزالة الحماية بالبصمة
Future<void> _removeProtectionWithBiometric(
  BuildContext context,
  String folderId, {
  required BuildContext dialogContext,
  required LocalAuthentication localAuth,
  required StateSetter setState,
  required Function(String) setErrorMessage,
  required Function(bool) setResult,
  VoidCallback? onProtectionRemoved,
}) async {
  try {
    final bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    final bool isDeviceSupported = await localAuth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      setErrorMessage(S.of(context).fingerprintNotAvailable);
      return;
    }

    final bool didAuthenticate = await localAuth.authenticate(
      localizedReason: S.of(context).pleaseVerifyFingerprint,
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (didAuthenticate) {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      final success = await folderController.removeFolderProtection(
        folderId: folderId,
        password: null,
      );

      if (success) {
        setResult(true);
        Navigator.pop(dialogContext);
        // ✅ عرض رسالة النجاح باستخدام الـ context الأصلي
        // ✅ استخدام Future.delayed مع WidgetsBinding للتأكد من أن الـ dialog تم إغلاقه بالكامل
        Future.delayed(Duration(milliseconds: 50), () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              final messenger = ScaffoldMessenger.maybeOf(context);
              if (messenger != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).folderProtectionDisabled),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          });
        });
        if (onProtectionRemoved != null) {
          onProtectionRemoved();
        }
      } else {
        setResult(false);
        setErrorMessage(
          folderController.errorMessage ??
              S.of(context).failedToRemoveProtection,
        );
      }
    }
  } catch (e) {
    setErrorMessage(S.of(context).fingerprintVerificationError(e.toString()));
  }
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
            Text(S.of(context).protectedFolder),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).folderIsProtected(folderName),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          S.of(context).incorrectPassword,
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
                    labelText: S.of(context).passwordLabel,
                    hintText: S.of(context).enterPassword,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
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
                      Icon(Icons.fingerprint, size: 64, color: Colors.blue),
                      SizedBox(height: 20),
                      Text(
                        S.of(context).useFingerprintToAccess,
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
              label: Text(S.of(context).verifyWithFingerprint),
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
                    errorMessage = S.of(context).pleaseEnterPassword;
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
              child: Text(S.of(context).open),
            ),
          TextButton(
            onPressed: () {
              successResult = false;
              Navigator.pop(dialogContext);
            },
            child: Text(S.of(context).cancel),
          ),
        ],
      ),
    ),
  );

  return {'success': successResult ?? false, 'password': verifiedPassword};
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
  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );

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

    // ✅ عرض رسالة الخطأ داخل dialog
    setResult(false, null);
    setErrorMessage(
      folderController.errorMessage ?? S.of(context).incorrectPassword,
    );
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
      setErrorMessage(S.of(context).fingerprintNotAvailable);
      return;
    }

    // التحقق من البصمة
    final bool didAuthenticate = await localAuth.authenticate(
      localizedReason: S.of(context).pleaseVerifyFingerprint,
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (didAuthenticate) {
      // إرسال token للباك إند (في التطبيق الحقيقي، قد تحتاج لتوقيع token)
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      final success = await folderController.verifyFolderAccess(
        folderId: folderId,
        password: null,
        biometricToken:
            'biometric_verified_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (success) {
        setResult(true, null); // ✅ البصمة لا تحتاج password
        Navigator.pop(dialogContext);
      } else {
        setResult(false, null);
        setErrorMessage(
          folderController.errorMessage ??
              S.of(context).failedToVerifyFingerprint,
        );
      }
    }
  } catch (e) {
    setErrorMessage(S.of(context).fingerprintVerificationError(e.toString()));
  }
}
