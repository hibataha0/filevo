import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/config/api_config.dart';
import 'package:provider/provider.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/constants/app_colors.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  String? _localImagePath;

  Future<void> _pickImageFromGallery() async {
    try {
      // ✅ طلب الصلاحيات قبل اختيار الصورة
      if (Platform.isAndroid) {
        // ✅ للـ Android 13+ نستخدم photos
        // ✅ للـ Android القديم نستخدم storage
        var status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
          if (!status.isGranted) {
            // ✅ جرب storage للـ Android القديم
            var storageStatus = await Permission.storage.status;
            if (!storageStatus.isGranted) {
              storageStatus = await Permission.storage.request();
            }
            if (!storageStatus.isGranted && !status.isGranted) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).mustAllowPhotosAccess),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
              return;
            }
          }
        }
      }

      // ✅ استخدام image_picker لاختيار الصورة (أفضل من file_picker للصور)
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // ✅ تقليل الجودة قليلاً لتوفير المساحة
        maxWidth: 1024, // ✅ تحديد الحد الأقصى للعرض
        maxHeight: 1024, // ✅ تحديد الحد الأقصى للارتفاع
      );

      if (pickedFile == null) {
        print('❌ No file selected');
        return;
      }

      final imagePath = pickedFile.path;
      print('✅ Selected image path: $imagePath');

      // ✅ التحقق من وجود الملف
      final file = File(imagePath);
      if (!await file.exists()) {
        print('❌ File does not exist: $imagePath');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).fileNotFound),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      print('✅ File exists, size: ${await file.length()} bytes');

      setState(() {
        _localImagePath = imagePath;
      });

      print('📤 Starting to upload profile image...');

      // ✅ استخدام ProfileController بدلاً من UserService مباشرة
      final profileController = Provider.of<ProfileController>(
        context,
        listen: false,
      );
      final success = await profileController.uploadProfileImage(
        imageFile: file,
      );

      print('📥 Upload result: $success');

      if (!mounted) return;

      if (success) {
        print('✅ Upload successful');

        // ✅ مسح الصورة المحلية بعد نجاح الرفع لاستخدام الصورة من الـ backend
        if (mounted) {
          setState(() {
            _localImagePath = null; // ✅ مسح الصورة المحلية
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).profileImageUploadedSuccessfully),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          final errorMsg =
              profileController.errorMessage ??
              S.of(context).failedToUploadProfileImage;
          print('❌ Upload failed: $errorMsg');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        print('❌ Error uploading profile image: $e');
        print('❌ Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).errorUploadingProfileImage(e.toString()),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // ✅ طلب صلاحية الكاميرا
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).mustAllowCameraAccess),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // ✅ استخدام image_picker لالتقاط صورة من الكاميرا
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // ✅ تقليل الجودة قليلاً لتوفير المساحة
        maxWidth: 1024, // ✅ تحديد الحد الأقصى للعرض
        maxHeight: 1024, // ✅ تحديد الحد الأقصى للارتفاع
      );

      if (pickedFile == null) {
        print('❌ No image captured');
        return;
      }

      final imagePath = pickedFile.path;
      print('✅ Captured image path: $imagePath');

      // ✅ التحقق من وجود الملف
      final file = File(imagePath);
      if (!await file.exists()) {
        print('❌ File does not exist: $imagePath');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).fileNotFound),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      print('✅ File exists, size: ${await file.length()} bytes');

      setState(() {
        _localImagePath = imagePath;
      });

      print('📤 Starting to upload profile image...');

      // ✅ استخدام ProfileController بدلاً من UserService مباشرة
      final profileController = Provider.of<ProfileController>(
        context,
        listen: false,
      );
      final success = await profileController.uploadProfileImage(
        imageFile: file,
      );

      print('📥 Upload result: $success');

      if (success) {
        print('✅ Upload successful');

        // ✅ مسح الصورة المحلية بعد نجاح الرفع لاستخدام الصورة من الـ backend
        if (mounted) {
          setState(() {
            _localImagePath = null; // ✅ مسح الصورة المحلية
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).profileImageUploadedSuccessfully),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        print('❌ Upload failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${S.of(context).failedToUploadProfileImage}: ${profileController.errorMessage ?? S.of(context).unknownError}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _pickImageFromCamera: $e');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${S.of(context).error}: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
      }
    }
  }

  void _showImageSourceDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardColor(isDarkMode),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: AppColors.getTextPrimary(isDarkMode),
                  ),
                  title: Text(
                    S.of(context).chooseFromGallery,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: AppColors.getTextPrimary(isDarkMode),
                  ),
                  title: Text(
                    S.of(context).takePhotoFromCamera,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.cancel,
                    color: AppColors.error,
                  ),
                  title: Text(
                    S.of(context).cancel,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ بناء URL كامل للصورة من اسم الملف (للـ backward compatibility)
  String? _buildImageUrl(String? profileImg) {
    if (profileImg == null || profileImg.isEmpty) {
      return null;
    }

    // ✅ إذا كان URL كامل، استخدمه مباشرة
    if (profileImg.startsWith('http://') || profileImg.startsWith('https://')) {
      return profileImg;
    }

    // ✅ بناء URL من base URL + path
    String cleanPath = profileImg.replaceAll(r'\', '/').replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // ✅ إذا كان اسم الملف فقط (مثل: user-xxx.jpeg)، استخدمه مباشرة
    // ✅ الـ backend قد يخدم الملفات من root أو من uploads/
    if (!cleanPath.contains('/') && cleanPath.startsWith('user-')) {
      // ✅ استخدام اسم الملف مباشرة (كما في file_details_page.dart)
      // ✅ الـ backend يجب أن يخدم الملفات من uploads/ تلقائياً
      cleanPath = cleanPath;
    }

    // ✅ إزالة /api/v1 من base URL للحصول على base فقط
    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    final baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;

    // ✅ بناء URL كامل (الـ backend يخدم الملفات من uploads/users/)
    final imageUrl = '$baseClean/uploads/users/$cleanPath';
    print('🖼️ Building profile image URL:');
    print('  - Original: $profileImg');
    print('  - Clean path: $cleanPath');
    print('  - Base: $baseClean');
    print('  - Final URL: $imageUrl');

    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    String? profileImageUrl;

    // ✅ محاولة الحصول على رابط الصورة من بيانات المستخدم
    if (profileController.userData != null) {
      final userData = profileController.userData;
      // ✅ قراءة profileImgUrl أولاً (من الباك إند الجديد)
      // ✅ إذا لم يكن موجوداً، استخدم profileImg وابني URL (للـ backward compatibility)
      final profileImgUrl = userData?['profileImgUrl'] as String?;
      final profileImg = userData?['profileImg'] as String?;

      print('🔍 Checking profile image:');
      print('  - userData keys: ${userData?.keys.toList()}');
      print('  - profileImgUrl: $profileImgUrl');
      print('  - profileImg: $profileImg');

      // ✅ استخدام profileImgUrl إذا كان موجوداً، وإلا بناء URL من profileImg
      profileImageUrl = profileImgUrl?.toString() ?? _buildImageUrl(profileImg);

      print('🖼️ Final profile image URL: $profileImageUrl');
    } else {
      print('⚠️ userData is null');
    }

    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 57.5,
            backgroundColor: Colors.grey[300],
            child: _localImagePath != null
                ? ClipOval(
                    child: Image.file(
                      File(_localImagePath!),
                      width: 115,
                      height: 115,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Error loading local image: $error');
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white70,
                        );
                      },
                    ),
                  )
                : profileImageUrl != null && profileImageUrl.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      width: 115,
                      height: 115,
                      fit: BoxFit.cover,
                      httpHeaders: {'Accept': 'image/*'},
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        print('❌ Error loading network image: $error');
                        print('❌ URL: $url');

                        // ✅ في حالة فشل تحميل الصورة، عرض أيقونة افتراضية
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white70,
                        );
                      },
                    ),
                  )
                : Container(
                    // ✅ صورة افتراضية بدون شكل - دائرة ملونة فقط
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[400],
                    ),
                    width: 115,
                    height: 115,
                  ),
          ),
          // ✅ عرض loading من ProfileController
          if (profileController.isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          Positioned(
            right: -8,
            bottom: 0,
            child: SizedBox(
              height: 35,
              width: 35,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: AppColors.getCardColor(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
                onPressed: profileController.isLoading
                    ? null
                    : _showImageSourceDialog,
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.getTextPrimary(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
