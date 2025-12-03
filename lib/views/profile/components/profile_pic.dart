import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/config/api_config.dart';
import 'package:provider/provider.dart';

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
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted && !photosStatus.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('يجب السماح بالوصول إلى الصور'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
        }
      }

      // ✅ استخدام file_picker لاختيار الصورة
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        print('❌ No file selected');
        return;
      }

      final pickedFile = result.files.first;
      if (pickedFile.path == null) {
        print('❌ File path is null');
        return;
      }

      final imagePath = pickedFile.path!;
      print('✅ Selected image path: $imagePath');
      
      // ✅ التحقق من وجود الملف
      final file = File(imagePath);
      if (!await file.exists()) {
        print('❌ File does not exist: $imagePath');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الملف غير موجود'),
              backgroundColor: Colors.red,
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
      final profileController = Provider.of<ProfileController>(context, listen: false);
      final success = await profileController.uploadProfileImage(imageFile: file);
      
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
            const SnackBar(
              content: Text('✅ تم رفع الصورة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileController.errorMessage ?? 'فشل رفع الصورة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            const SnackBar(
              content: Text('يجب السماح بالوصول إلى الكاميرا'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // ✅ استخدام file_picker مع الكاميرا (إذا كان مدعوماً)
      // ملاحظة: file_picker لا يدعم الكاميرا مباشرة، سنستخدم المعرض فقط
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى استخدام "اختيار من المعرض" لاختيار الصورة'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('Error in _pickImageFromCamera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('إلغاء'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ بناء URL كامل للصورة
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
    final baseClean = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    
    // ✅ بناء URL كامل
    final imageUrl = '$baseClean/$cleanPath';
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
      final profileImg = userData?['profileImg'] as String?;
      
      print('🔍 Checking profile image:');
      print('  - userData: $userData');
      print('  - profileImg: $profileImg');
      
      profileImageUrl = _buildImageUrl(profileImg);
      
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
                          httpHeaders: {
                            'Accept': 'image/*',
                          },
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print('❌ Error loading network image: $error');
                            print('❌ URL: $url');
                            
                            // ✅ محاولة استخدام مسارات بديلة
                            if (url != null) {
                              final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
                              final baseClean = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
                              
                              // ✅ استخراج اسم الملف من URL
                              final fileName = url.split('/').last;
                              
                              // ✅ جرب مسارات مختلفة
                              final alternatives = [
                                '$baseClean/uploads/users/$fileName',
                                '$baseClean/uploads/$fileName',
                                '$baseClean/$fileName',
                                '$baseClean/api/v1/users/profile-image/$fileName',
                              ];
                              
                              print('🔄 Trying alternative URLs...');
                              for (var altUrl in alternatives) {
                                if (altUrl != url) {
                                  print('  - Trying: $altUrl');
                                  return ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: altUrl,
                                      width: 115,
                                      height: 115,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) {
                                        return const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white70,
                                        );
                                      },
                                    ),
                                  );
                                }
                              }
                            }
                            
                            return const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white70,
                            );
                          },
                        ),
                      )
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: "https://i.postimg.cc/0jqKB6mS/Profile-Image.png",
                          width: 115,
                          height: 115,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print('❌ Error loading default image: $error');
                            return const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white70,
                            );
                          },
                        ),
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
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: profileController.isLoading ? null : _showImageSourceDialog,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
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
