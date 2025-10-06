import 'package:filevo/components/NavigationBar .dart';
import 'package:filevo/views/folders/folders_view.dart';
import 'package:filevo/views/home/home_view.dart';
import 'package:filevo/views/profile/profile_view.dart';
import 'package:filevo/views/settings/settings_view.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selected = 0;

  // قائمة الصفحات
  final List<Widget> _pages = [
    HomeView(),                    // index 0 - Home
    FoldersPage(),                 // index 1 - Folders
    ProfilePage(),                 // index 2 - Profile
    SettingsPage(),                // index 3 - Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[selected], // عرض الصفحة حسب الـ index المختار
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4D62D5),
              Color(0xFF28336F),
            ],
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
          shape: CircleBorder(),
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // هنا تقدر تفتح صفحة جديدة أو تعمل action معين
              print('Add button pressed');
            },
            borderRadius: BorderRadius.circular(30),
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: SizedBox(
          height: 80,
          child: MyBottomBar(
            selectedIndex: selected,
            onTap: (index) {
              setState(() {
                selected = index; // تغيير الصفحة
              });
            },
          ),
        ),
      ),
    );
  }
}

// // صفحة Folders (مثال)
// class FoldersPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff28336f),
//       body: Center(
//         child: Text(
//           'Folders Page',
//           style: TextStyle(color: Colors.white, fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

// // صفحة Profile (مثال)
// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff28336f),
//       body: Center(
//         child: Text(
//           'Profile Page',
//           style: TextStyle(color: Colors.white, fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

// // صفحة Settings (مثال)
// class SettingsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff28336f),
//       body: Center(
//         child: Text(
//           'Settings Page',
//           style: TextStyle(color: Colors.white, fontSize: 24),
//         ),
//       ),
//     );
//   }
// }