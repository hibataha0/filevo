import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:filevo/components/NavigationBar%20.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/views/folders/folders_view.dart';
import 'package:filevo/views/home/home_view.dart';
import 'package:filevo/views/profile/profile_view.dart';
import 'package:filevo/views/settings/settings_view.dart';
import 'package:filevo/services/storage_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selected = 0;
  String? _token;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadToken(); // تحميل التوكن
    _pages = [
      HomeView(),
      FoldersPage(),
      ProfilePage(),
      SettingsPage(),
    ];
  }

  // تحميل التوكن من التخزين
  Future<void> _loadToken() async {
    final token = await StorageService.getToken();
    setState(() {
      _token = token;
    });
    print('🔑 Token: ${_token != null ? "موجود ✅" : "مش موجود ❌"}');
  }

  // رفع ملف واحد أو عدة ملفات
  Future<void> _uploadFilesOrSingle() async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ سجل دخول أولاً')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null && result.files.isNotEmpty) {
      List<File> files = result.paths.map((path) => File(path!)).toList();

      final fileController = Provider.of<FileController>(context, listen: false);

      if (files.length == 1) {
        // ملف واحد
        bool success = await fileController.uploadSingleFile(
          file: files[0],
          token: _token!,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).upload_success),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${fileController.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // عدة ملفات
       final response = await fileController.uploadMultipleFiles(
  files: files,
  token: _token!,
);

if (response['files'] != null && (response['files'] as List).isNotEmpty) {
  // عملية ناجحة
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('✅ ${response['message'] ?? 'تم رفع الملفات بنجاح'}'),
      backgroundColor: Colors.green,
    ),
  );
} else {
  // فشل
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('❌ ${fileController.errorMessage ?? response['message'] ?? 'فشل في رفع الملفات'}'),
      backgroundColor: Colors.red,
    ),
  );
}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[selected],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Consumer<FileController>(
        builder: (context, fileController, child) {
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4D62D5), Color(0xFF28336F)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: fileController.isLoading ? null : _uploadFilesOrSingle,
                borderRadius: BorderRadius.circular(30),
                child: fileController.isLoading
                    ? Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: SizedBox(
          height: 80,
          child: MyBottomBar(
            selectedIndex: selected,
            onTap: (index) {
              setState(() {
                selected = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

