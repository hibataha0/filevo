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
import 'package:shimmer/shimmer.dart';

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
  bool _hasInitialized = false; // ✅ flag لمنع الاستدعاء المتكرر

  @override
  void initState() {
    super.initState();
    // ✅ جلب البيانات مرة واحدة فقط عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadProfileData();
    });
  }

  // ✅ دالة لجلب بيانات البروفايل مرة واحدة فقط
  void _loadProfileData() {
    if (_hasInitialized) return; // ✅ منع الاستدعاء المتكرر
    _hasInitialized = true;

    final controller = context.read<ProfileController>();
    
    // ✅ جلب بيانات المستخدم إذا كانت غير موجودة
    if (controller.userData == null || controller.userName == null) {
      controller.getLoggedUserData().then((_) {
        if (!mounted) return;
        // ✅ بعد جلب بيانات المستخدم، جلب معلومات التخزين
        if (controller.storageInfo == null) {
          controller.getStorageInfo();
        }
        // ✅ تحديث StorageCard بعد جلب البيانات
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _storageCardKey.currentState?.refresh();
          }
        });
      });
    } else {
      // ✅ إذا كانت بيانات المستخدم موجودة، جلب معلومات التخزين فقط
      if (controller.storageInfo == null) {
        controller.getStorageInfo();
      }
      // ✅ تحديث StorageCard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _storageCardKey.currentState?.refresh();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ لا نستدعي أي شيء هنا لتجنب الـ infinite loop
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
            _buildShimmerLoading(isDarkMode)
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
                    decoration: BoxDecoration(
                      color: AppColors.getBackground(isDarkMode),
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
                        final controller = context.read<ProfileController>();
                        controller.getStorageInfo();
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

  // ✅ بناء shimmer loading للصفحة
  Widget _buildShimmerLoading(bool isDarkMode) {
    return Column(
      children: [
        // ✅ Header shimmer
        Container(
          padding: const EdgeInsets.only(top: 60, bottom: 30),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Profile picture shimmer
              Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDarkMode),
                highlightColor: AppColors.getShimmerHighlight(isDarkMode),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(isDarkMode),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ✅ Username shimmer
              Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDarkMode),
                highlightColor: AppColors.getShimmerHighlight(isDarkMode),
                child: Container(
                  width: 150,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(isDarkMode),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ✅ Content shimmer
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getBackground(isDarkMode),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // ✅ Storage card shimmer
                _buildStorageCardShimmer(),
                const SizedBox(height: 25),
                // ✅ Favorites section shimmer
                _buildFavoritesSectionShimmer(),
                const SizedBox(height: 25),
                // ✅ Starred folders section shimmer
                _buildStarredFoldersSectionShimmer(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ بناء shimmer لبطاقة التخزين
  Widget _buildStorageCardShimmer() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: AppColors.getShimmerBase(isDarkMode),
      highlightColor: AppColors.getShimmerHighlight(isDarkMode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.getShimmerBase(isDarkMode),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.getShimmerBase(isDarkMode),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.getShimmerBase(isDarkMode),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.getShimmerBase(isDarkMode),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ بناء shimmer لقسم المفضلة
  Widget _buildFavoritesSectionShimmer() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDarkMode),
                highlightColor: AppColors.getShimmerHighlight(isDarkMode),
                child: Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(isDarkMode),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDarkMode),
                highlightColor: AppColors.getShimmerHighlight(isDarkMode),
                child: Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(isDarkMode),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        // ✅ Files grid shimmer
        Shimmer.fromColors(
          baseColor: AppColors.getShimmerBase(isDarkMode),
          highlightColor: AppColors.getShimmerHighlight(isDarkMode),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              6,
              (index) => Container(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(isDarkMode),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ بناء shimmer لقسم المجلدات المفضلة
  Widget _buildStarredFoldersSectionShimmer() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDarkMode),
                highlightColor: AppColors.getShimmerHighlight(isDarkMode),
                child: Container(
                  width: 140,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(isDarkMode),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDarkMode),
                highlightColor: AppColors.getShimmerHighlight(isDarkMode),
                child: Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(isDarkMode),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        // ✅ Folders grid shimmer
        Shimmer.fromColors(
          baseColor: AppColors.getShimmerBase(isDarkMode),
          highlightColor: AppColors.getShimmerHighlight(isDarkMode),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              6,
              (index) => Container(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(isDarkMode),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
