import 'package:filevo/generated/l10n.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/services/file_service.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;
import 'package:filevo/constants/app_colors.dart';

class StorageCard extends StatefulWidget {
  final VoidCallback? onRefresh;

  const StorageCard({Key? key, this.onRefresh}) : super(key: key);

  @override
  State<StorageCard> createState() => StorageCardState();
}

class StorageCardState extends State<StorageCard> {
  final FileService _fileService = FileService();
  bool _isLoading = true;
  bool _isLoadingData = false; // ✅ flag لمنع الاستدعاء المتكرر
  Map<String, double> _categoryPercentages = {};
  Map<String, int> _categorySizes = {}; // ✅ أحجام كل تصنيف بالبايت
  int _totalSize = 0;
  int _usedSize = 0;
  int _totalStorage = 1 * 1024 * 1024 * 1024; // 5GB بالبايت (افتراضي)
  int _totalAppStorage = 0; // ✅ المساحة الإجمالية المستخدمة في التطبيق
  bool _showTotalAppStorage =
      false; // ✅ flag لعرض/إخفاء المساحة الإجمالية للتطبيق

  // دالة عامة لتحديث البيانات (يمكن استدعاؤها من الخارج)
  void refresh() {
    if (mounted && !_isLoadingData) {
      _loadStorageData();
    }
  }

  @override
  void didUpdateWidget(StorageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ لا نستدعي _loadStorageData هنا لتجنب الـ infinite loop
    // ✅ يمكن استدعاء refresh() يدوياً إذا لزم الأمر
  }

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    if (!mounted || _isLoadingData) return; // ✅ منع الاستدعاء المتكرر

    setState(() {
      _isLoading = true;
      _isLoadingData = true; // ✅ تعيين flag
    });

    try {
      // ✅ محاولة استخدام البيانات من ProfileController أولاً (إذا كانت متاحة)
      bool useUserData = false;
      try {
        if (mounted) {
          final profileController = Provider.of<ProfileController>(
            context,
            listen: false,
          );
          final userData = profileController.userData;

          if (userData != null && userData['storageLimit'] != null) {
            // ✅ استخدام البيانات من userData مباشرة
            _totalStorage =
                (userData['storageLimit'] as int?) ??
                (10 * 1024 * 1024 * 1024); // 10 GB افتراضي
            _usedSize =
                (userData['usedStorage'] as int?) ??
                (userData['storageUsed'] as int?) ??
                0;
            print('✅ [StorageCard] Using data from ProfileController.userData');
            print('   - storageLimit: $_totalStorage');
            print('   - usedSize: $_usedSize');
            useUserData = true;
          }
        }
      } catch (e) {
        print('⚠️ [StorageCard] Error getting data from ProfileController: $e');
        // ✅ إذا فشل جلب البيانات من ProfileController، جلب من API
      }

      // ✅ إذا لم تكن البيانات متاحة في userData، جلب من API
      if (!useUserData) {
        final storageResult = await _fileService.getStorageInfo();

        if (!mounted) return;

        if (storageResult['success'] == true &&
            storageResult['storage'] != null) {
          final storage = storageResult['storage'] as Map<String, dynamic>;

          // ✅ استخدام البيانات من getStorageInfo
          _totalStorage =
              storage['limit'] as int? ??
              (10 * 1024 * 1024 * 1024); // 10 GB افتراضي
          _usedSize = storage['used'] as int? ?? 0;
        } else {
          // ✅ إذا فشل جلب البيانات، استخدم القيم الافتراضية
          _totalStorage = 10 * 1024 * 1024 * 1024; // 10 GB افتراضي
          _usedSize = 0;
        }
      }

      if (!mounted) return;

      if (_totalStorage > 0) {
        // ✅ جلب المساحة الإجمالية المستخدمة في التطبيق
        try {
          final totalStorageResult = await _fileService.getTotalStorageInfo();
          if (totalStorageResult['success'] == true &&
              totalStorageResult['totalStorage'] != null) {
            final totalStorage =
                totalStorageResult['totalStorage'] as Map<String, dynamic>;
            _totalAppStorage = totalStorage['totalUsed'] as int? ?? 0;
            _showTotalAppStorage = true;
          }
        } catch (e) {
          print('⚠️ [StorageCard] Error getting total app storage: $e');
          // ✅ إذا فشل جلب المساحة الإجمالية، لا نعرضها
          _showTotalAppStorage = false;
        }

        // ✅ جلب إحصائيات التصنيفات أيضاً للشارت
        final token = await StorageService.getToken();
        if (token != null) {
          final statsData = await _fileService.getCategoriesStats(token: token);

          if (!mounted) return;

          if (statsData != null && statsData['categories'] != null) {
            final categories = statsData['categories'] as List;

            // حساب النسب المئوية لكل تصنيف
            final Map<String, double> percentages = {};
            final Map<String, int> categorySizes = {};

            // جمع أحجام التصنيفات
            // ✅ تحويل أسماء التصنيفات من الـ backend إلى التنسيق المتوقع
            final Map<String, String> categoryMapping = {
              'images': 'images',
              'videos': 'videos',
              'audio': 'audio',
              'documents': 'documents',
              'compressed': 'compressed',
              'applications': 'applications',
              'code': 'code',
              'others': 'other', // ✅ تحويل "Others" إلى "other"
            };

            for (var category in categories) {
              final categoryNameRaw = category['category'] as String;
              final categoryNameLower = categoryNameRaw.toLowerCase();
              // ✅ استخدام الـ mapping أو الاسم مباشرة
              final categoryName =
                  categoryMapping[categoryNameLower] ?? categoryNameLower;
              final totalSize = category['totalSize'] as int? ?? 0;
              categorySizes[categoryName] = totalSize;
            }

            // ✅ حساب النسب المئوية بناءً على الحجم الكلي (_totalStorage)
            // هذا يضمن أن الدائرة تعرض المساحة المستخدمة والمساحة الفارغة
            if (_totalStorage > 0) {
              for (var entry in categorySizes.entries) {
                // النسبة من الحجم الكلي (لإظهار المساحة الفارغة أيضاً)
                percentages[entry.key] = entry.value / _totalStorage;
              }
            }

            // ✅ طباعة القيم للتحقق
            print('🔍 [StorageCard] Category sizes and percentages:');
            print('   - _totalStorage: ${_formatBytes(_totalStorage)}');
            print('   - _usedSize: ${_formatBytes(_usedSize)}');
            int totalCategoriesSize = 0;
            categorySizes.forEach((key, size) {
              final percent = percentages[key] ?? 0.0;
              totalCategoriesSize += size;
              print(
                '   - $key: ${_formatBytes(size)} (${(percent * 100).toStringAsFixed(4)}%)',
              );
            });
            print(
              '   - Total categories size: ${_formatBytes(totalCategoriesSize)}',
            );

            // ✅ التأكد من وجود جميع التصنيفات حتى لو كانت 0
            final defaultCategories = [
              'images',
              'videos',
              'audio',
              'compressed',
              'applications',
              'documents',
              'code',
              'other',
            ];
            for (var cat in defaultCategories) {
              if (!percentages.containsKey(cat)) {
                percentages[cat] = 0.0;
              }
            }

            if (!mounted) return;
            setState(() {
              _categoryPercentages = percentages;
              _categorySizes = categorySizes; // ✅ حفظ أحجام التصنيفات
              _isLoading = false;
              _isLoadingData = false; // ✅ إعادة تعيين flag
            });
            return;
          } else {
            // ✅ إذا لم تكن هناك بيانات تصنيفات، استخدم قيم افتراضية فارغة
            if (!mounted) return;
            setState(() {
              _categoryPercentages = {
                'images': 0.0,
                'videos': 0.0,
                'audio': 0.0,
                'compressed': 0.0,
                'applications': 0.0,
                'documents': 0.0,
                'code': 0.0,
                'other': 0.0,
              };
              _categorySizes = {}; // ✅ إعادة تعيين أحجام التصنيفات
              _isLoading = false;
              _isLoadingData = false; // ✅ إعادة تعيين flag
            });
            return;
          }
        }

        // ✅ إذا لم يتم جلب token، استخدم قيم افتراضية
        if (!mounted) return;
        setState(() {
          _categoryPercentages = {
            'images': 0.0,
            'videos': 0.0,
            'audio': 0.0,
            'compressed': 0.0,
            'applications': 0.0,
            'documents': 0.0,
            'code': 0.0,
            'other': 0.0,
          };
          _isLoading = false;
          _isLoadingData = false; // ✅ إعادة تعيين flag
        });
      } else {
        // ✅ إذا فشل جلب معلومات المساحة، استخدم القيم الافتراضية
        if (!mounted) return;
        setState(() {
          _totalStorage = 10 * 1024 * 1024 * 1024; // 10 GB افتراضي
          _usedSize = 0;
          _categoryPercentages = {
            'images': 0.0,
            'videos': 0.0,
            'audio': 0.0,
            'compressed': 0.0,
            'applications': 0.0,
            'documents': 0.0,
            'code': 0.0,
            'other': 0.0,
          };
          _isLoading = false;
          _isLoadingData = false; // ✅ إعادة تعيين flag
        });
      }
    } catch (e) {
      print('Error loading storage data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingData = false; // ✅ إعادة تعيين flag
      });
    }
  }

  // دالة لتحويل البايت إلى GB
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // ✅ قيم الأقسام كنسب من _totalStorage (0.0 إلى 1.0)
    final double images = _categoryPercentages['images'] ?? 0.0;
    final double videos = _categoryPercentages['videos'] ?? 0.0;
    final double audio = _categoryPercentages['audio'] ?? 0.0;
    final double compressed = _categoryPercentages['compressed'] ?? 0.0;
    final double applications = _categoryPercentages['applications'] ?? 0.0;
    final double documents = _categoryPercentages['documents'] ?? 0.0;
    final double code = _categoryPercentages['code'] ?? 0.0;
    final double other = _categoryPercentages['other'] ?? 0.0;

    // ✅ حساب النسبة المئوية المستخدمة من الحجم الكلي
    // ✅ استخدام toStringAsFixed(1) لعرض رقم عشري واحد بدلاً من round() لتجنب 0%
    final String usedPercentageText = _usedSize > 0 && _totalStorage > 0
        ? ((_usedSize / _totalStorage) * 100).toStringAsFixed(1)
        : '0.0';
    final double usedPercentageValue = _usedSize > 0 && _totalStorage > 0
        ? (_usedSize / _totalStorage) * 100
        : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0,
        ),
      ),
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 20.0,
          tablet: 24.0,
          desktop: 28.0,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDarkMode),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الدائرة
              Expanded(
                flex: 2,
                child: CustomPaint(
                  size: Size(120, 120),
                  painter: StorageCirclePainter(
                    images: images,
                    videos: videos,
                    audio: audio,
                    compressed: compressed,
                    applications: applications,
                    documents: documents,
                    code: code,
                    other: other,
                    totalCapacity: 1.0, // ✅ السعة الكاملة (1.0 = 100%)
                    usedPercentage:
                        usedPercentageValue /
                        100.0, // ✅ النسبة المستخدمة (0.0 إلى 1.0)
                    isDarkMode: isDarkMode,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$usedPercentageText%',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 24.0,
                              tablet: 28.0,
                              desktop: 32.0,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppColors.getPrimary(isDarkMode),
                          ),
                        ),
                        Text(
                          S.of(context).used,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 12.0,
                              tablet: 14.0,
                              desktop: 16.0,
                            ),
                            color: AppColors.getTextSecondary(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 20),

              // Legend
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(
                                S.of(context).images,
                                Color(0xFF4285F4),
                                Icons.image,
                                'images',
                              ),
                              SizedBox(height: 6),
                              _buildLegendItem(
                                S.of(context).videos,
                                Color(0xFFEA4335),
                                Icons.videocam,
                                'videos',
                              ),
                              SizedBox(height: 6),
                              _buildLegendItem(
                                S.of(context).audio,
                                Color(0xFF34A853),
                                Icons.audiotrack,
                                'audio',
                              ),
                              SizedBox(height: 6),
                              _buildLegendItem(
                                S.of(context).compressed,
                                Color(0xFFFF6D00),
                                Icons.folder_zip,
                                'compressed',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(
                                S.of(context).applications,
                                Color(0xFF9C27B0),
                                Icons.apps,
                                'applications',
                              ),
                              SizedBox(height: 6),
                              _buildLegendItem(
                                S.of(context).documents,
                                Color(0xFF795548),
                                Icons.description,
                                'documents',
                              ),
                              SizedBox(height: 6),
                              _buildLegendItem(
                                S.of(context).code,
                                Color(0xFF009688),
                                Icons.code,
                                'code',
                              ),
                              SizedBox(height: 6),
                              _buildLegendItem(
                                S.of(context).other,
                                Color(0xFF607D8B),
                                Icons.more_horiz,
                                'other',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Text(
            S.of(context).storageOverview,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 18.0,
                tablet: 20.0,
                desktop: 22.0,
              ),
              fontWeight: FontWeight.bold,
              color: Color(0xff28336f),
            ),
          ),

          SizedBox(height: 16),
          Text(
            S.of(context).usedStorage,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 14.0,
                tablet: 15.0,
                desktop: 16.0,
              ),
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 8),
          _isLoading
              ? _buildShimmerLoading()
              : Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Stack(
                        children: [
                          // ✅ عرض جميع الدوائر دائماً بغض النظر عن وجود ملفات
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Color(0xFF4285F4), // Images - Blue
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFFEA4335), // Videos - Red
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFF34A853), // Audio - Green
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 30,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF6D00), // Compressed - Orange
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 40,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFF9C27B0,
                                ), // Applications - Purple
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 50,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFF795548), // Documents - Brown
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 60,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFF009688), // Code - Teal
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 70,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFF607D8B), // Other - Grey
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_formatBytes(_usedSize)} / ${_formatBytes(_totalStorage)}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context,
                            mobile: 14.0,
                            tablet: 16.0,
                            desktop: 18.0,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPrimary(isDarkMode),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.getPrimary(isDarkMode),
                        size: 20,
                      ),
                      onPressed: _loadStorageData,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      tooltip: 'Refresh storage data',
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    IconData icon,
    String categoryKey,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final categorySize = _categorySizes[categoryKey] ?? 0;
    final categorySizeFormatted = _formatBytes(categorySize);

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(icon, color: Colors.white, size: 10),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextPrimary(isDarkMode),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // SizedBox(width: 4),
        // Text(
        //   categorySizeFormatted,
        //   style: TextStyle(
        //     fontSize: 11,
        //     color: Colors.grey[600],
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildStackCircle(double left, Color color) {
    return Positioned(
      left: left,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  // ✅ بناء shimmer loading لبطاقة التخزين
  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StorageCirclePainter extends CustomPainter {
  final double images;
  final double videos;
  final double audio;
  final double compressed;
  final double applications;
  final double documents;
  final double code;
  final double other;
  final double totalCapacity;
  final double usedPercentage; // ✅ النسبة المستخدمة الإجمالية (0.0 إلى 1.0)
  final bool isDarkMode;

  StorageCirclePainter({
    required this.images,
    required this.videos,
    required this.audio,
    required this.compressed,
    required this.applications,
    required this.documents,
    required this.code,
    required this.other,
    required this.totalCapacity,
    this.usedPercentage = 0.0, // ✅ افتراضي 0.0
    this.isDarkMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 18.0;

    double startAngle = -math.pi / 2;

    // ✅ استخدام usedPercentage إذا كانت متاحة (أكثر دقة)
    // ✅ وإلا استخدام مجموع النسب
    final double used = usedPercentage > 0.0
        ? usedPercentage
        : (images +
              videos +
              audio +
              compressed +
              applications +
              documents +
              code +
              other);

    final double free = math.max(0.0, totalCapacity - used);

    // ✅ طباعة للتحقق
    print('🎨 [StorageCirclePainter] Drawing chart:');
    print('   - usedPercentage: $usedPercentage');
    print('   - used (calculated): $used');
    print('   - free: $free');
    print('   - totalCapacity: $totalCapacity');
    print('   - images: $images, videos: $videos, audio: $audio');

    // ✅ إنشاء قائمة بالأقسام المستخدمة فقط (بدون Free)
    final usedSegments = [
      if (images > 0)
        {'value': images, 'color': const Color(0xFF4285F4), 'name': 'Images'},
      if (videos > 0)
        {'value': videos, 'color': const Color(0xFFEA4335), 'name': 'Videos'},
      if (audio > 0)
        {'value': audio, 'color': const Color(0xFF34A853), 'name': 'Audio'},
      if (compressed > 0)
        {
          'value': compressed,
          'color': const Color(0xFFFF6D00),
          'name': 'Compressed',
        },
      if (applications > 0)
        {
          'value': applications,
          'color': const Color(0xFF9C27B0),
          'name': 'Apps',
        },
      if (documents > 0)
        {'value': documents, 'color': const Color(0xFF795548), 'name': 'Docs'},
      if (code > 0)
        {'value': code, 'color': const Color(0xFF009688), 'name': 'Code'},
      if (other > 0)
        {'value': other, 'color': const Color(0xFF607D8B), 'name': 'Other'},
    ];

    // ✅ حساب مجموع الأقسام المستخدمة
    final double totalUsed = usedSegments.fold(
      0.0,
      (sum, seg) => sum + (seg['value'] as double),
    );

    // ✅ إذا كان الاستخدام صغير جداً، نستخدم جزء من الدائرة فقط (مثلاً 30%) لعرض الأقسام بشكل أوضح
    final double visualUsedPortion = totalUsed > 0.0 && totalUsed < 0.05
        ? 0.30 // ✅ استخدام 30% من الدائرة لعرض الأقسام الصغيرة بشكل أوضح
        : math.min(
            1.0,
            totalUsed,
          ); // ✅ إذا كان الاستخدام كبير، نستخدم النسبة الفعلية

    // ✅ رسم خلفية رمادية للدائرة الكاملة
    final bgPaint = Paint()
      ..color = AppColors.getShimmerBase(isDarkMode)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // ✅ رسم الأقسام المستخدمة
    if (usedSegments.isNotEmpty && totalUsed > 0) {
      double segmentStartAngle = -math.pi / 2;

      for (var segment in usedSegments) {
        final double value = segment['value'] as double;
        final String name = segment['name'] as String;

        // ✅ حساب النسبة من الأقسام المستخدمة (وليس من السعة الكاملة)
        final double segmentRatio = value / totalUsed;

        // ✅ حساب زاوية القوس بناءً على visualUsedPortion
        double sweepAngle = 2 * math.pi * visualUsedPortion * segmentRatio;

        // ✅ حد أدنى بصري للقوس (حوالي 0.1 راديان = 5.7 درجة)
        if (sweepAngle < 0.1) {
          sweepAngle = 0.1;
        }

        // ✅ رسم القوس
        final paint = Paint()
          ..color = segment['color'] as Color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
          segmentStartAngle,
          sweepAngle,
          false,
          paint,
        );

        segmentStartAngle += sweepAngle;
      }
    }

    // ✅ لا نرسم المساحة الفارغة لأنها ستكون الخلفية الرمادية
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
