import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/views/profile/profile_edit_page.dart';
import 'package:filevo/views/profile/components/StorageCard.dart';
import 'package:filevo/views/profile/components/favorites_section.dart';
import 'package:filevo/views/profile/components/starred_folders_section.dart';
import 'package:filevo/views/profile/components/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ProfileController>();
      if (!controller.isLoading && controller.userName == null) {
        controller.getLoggedUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      body: Stack(
        children: [
          if (profileController.isLoading && profileController.userName == null)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ProfilePic(),
                      const SizedBox(height: 20),
                      Text(
                        profileController.userName ?? '—',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (profileController.userEmail != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          profileController.userEmail!,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9E9E9),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: const SingleChildScrollView(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          StorageCard(),
                          FavoritesSection(),
                          StarredFoldersSection(),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Positioned(
            top: 70,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final controller = context.read<ProfileController>();
                if (controller.userData == null) {
                  await controller.getLoggedUserData();
                }
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: controller,
                      child: const ProfileEditPage(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

