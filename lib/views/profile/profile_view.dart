import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/views/profile/profile_edit_page.dart';
import 'package:filevo/views/profile/components/StorageCard.dart';
import 'package:filevo/views/profile/components/favorites_section.dart';
import 'package:filevo/views/profile/components/starred_folders_section.dart';
import 'package:filevo/views/profile/components/profile_pic.dart';
import 'package:filevo/controllers/ThemeController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<StorageCardState> _storageCardKey =
      GlobalKey<StorageCardState>();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ تحديث بيانات المستخدم عند العودة للصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = context.read<ProfileController>();
        // ✅ تحديث البيانات إذا كانت قديمة أو غير موجودة
        if (controller.userData == null || controller.userName == null) {
          controller.getLoggedUserData();
        }
        // ✅ تحديث بيانات التخزين أيضاً
        _storageCardKey.currentState?.refresh();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final themeController = context.watch<ThemeController>();
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkAppBar
          : AppColors.lightAppBar,
      body: Stack(
        children: [
          if (profileController.isLoading && profileController.userName == null)
            const Center(child: CircularProgressIndicator(color: Colors.white))
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
                      // if (profileController.userEmail != null) ...[
                      //   const SizedBox(height: 6),
                      //   Text(
                      //     profileController.userEmail!,
                      //     style: const TextStyle(color: Colors.white70, fontSize: 14),
                      //   ),
                      // ],
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF121212)
                          : const Color(0xFFE9E9E9),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SmartRefresher(
                      controller: _refreshController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      onRefresh: () async {
                        _storageCardKey.currentState?.refresh();
                        await Future.delayed(const Duration(milliseconds: 500));
                        _refreshController.refreshCompleted();
                      },
                      header: const WaterDropHeader(),
                      child: ListView(
                        padding: const EdgeInsets.all(20.0),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        children: [
                          StorageCard(key: _storageCardKey),
                          FavoritesSection(),
                          StarredFoldersSection(),
                          const SizedBox(height: 100),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: controller,
                      child: const ProfileEditPage(),
                    ),
                  ),
                );
                // تحديث بيانات التخزين عند العودة من صفحة التعديل
                if (mounted) {
                  _storageCardKey.currentState?.refresh();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
