import 'package:filevo/generated/l10n.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/services/file_service.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class StorageCard extends StatefulWidget {
  final VoidCallback? onRefresh;
  
  const StorageCard({Key? key, this.onRefresh}) : super(key: key);

  @override
  State<StorageCard> createState() => StorageCardState();
}

class StorageCardState extends State<StorageCard> {
  final FileService _fileService = FileService();
  bool _isLoading = true;
  Map<String, double> _categoryPercentages = {};
  int _totalSize = 0;
  int _usedSize = 0;
  int _totalStorage = 1 * 1024 * 1024 * 1024; // 5GB بالبايت (افتراضي)

  // دالة عامة لتحديث البيانات (يمكن استدعاؤها من الخارج)
  void refresh() {
    if (mounted) {
      _loadStorageData();
    }
  }

  @override
  void didUpdateWidget(StorageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إذا تغير onRefresh callback، قد نحتاج لتحديث البيانات
    if (widget.onRefresh != oldWidget.onRefresh && mounted) {
      _loadStorageData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final statsData = await _fileService.getCategoriesStats(token: token);
      
      if (!mounted) return;
      
      if (statsData != null && statsData['categories'] != null) {
        final categories = statsData['categories'] as List;
        final totals = statsData['totals'] as Map<String, dynamic>?;
        
        // حساب الحجم الكلي المستخدم
        _usedSize = totals?['totalSize'] as int? ?? 0;
        
        // حساب الحجم الكلي (يمكن جعله من إعدادات المستخدم أو افتراضي)
        // إذا كان هناك totalStorage في البيانات، استخدمه
        if (totals != null && totals['totalStorage'] != null) {
          _totalStorage = totals['totalStorage'] as int;
        }
        
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
          final categoryName = categoryMapping[categoryNameLower] ?? categoryNameLower;
          final totalSize = category['totalSize'] as int? ?? 0;
          categorySizes[categoryName] = totalSize;
        }
        
        // ✅ حساب النسب المئوية بناءً على الحجم الكلي (totalStorage)
        // هذا يضمن أن المساحة المتبقية تظهر بشكل صحيح
        if (_totalStorage > 0) {
          for (var entry in categorySizes.entries) {
            // النسبة من الحجم الكلي
            percentages[entry.key] = entry.value / _totalStorage;
          }
        }
        
        // ✅ التأكد من وجود جميع التصنيفات حتى لو كانت 0
        final defaultCategories = ['images', 'videos', 'audio', 'compressed', 'applications', 'documents', 'code', 'other'];
        for (var cat in defaultCategories) {
          if (!percentages.containsKey(cat)) {
            percentages[cat] = 0.0;
          }
        }
        
        if (!mounted) return;
        setState(() {
          _categoryPercentages = percentages;
          _isLoading = false;
        });
      } else {
        // إذا لم تكن هناك بيانات، استخدم القيم الافتراضية
        if (!mounted) return;
        setState(() {
          _categoryPercentages = {
            'images': 0.06,
            'videos': 0.15,
            'audio': 0.10,
            'compressed': 0.08,
            'applications': 0.12,
            'documents': 0.18,
            'code': 0.07,
            'other': 0.05,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading storage data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // دالة لتحويل البايت إلى GB
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    // قيم الأقسام من البيانات أو القيم الافتراضية
    final double images = _categoryPercentages['images'] ?? 0.0;
    final double videos = _categoryPercentages['videos'] ?? 0.0;
    final double audio = _categoryPercentages['audio'] ?? 0.0;
    final double compressed = _categoryPercentages['compressed'] ?? 0.0;
    final double applications = _categoryPercentages['applications'] ?? 0.0;
    final double documents = _categoryPercentages['documents'] ?? 0.0;
    final double code = _categoryPercentages['code'] ?? 0.0;
    final double other = _categoryPercentages['other'] ?? 0.0;

    // ✅ حساب النسبة المئوية المستخدمة من الحجم الكلي
    final int usedPercentage = _usedSize > 0 && _totalStorage > 0 
        ? ((_usedSize / _totalStorage) * 100).round()
        : 0;

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$usedPercentage%',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 24.0,
                              tablet: 28.0,
                              desktop: 32.0,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Color(0xff28336f),
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
                            color: Colors.grey[600],
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
                              _buildLegendItem(S.of(context).images, Color(0xFF4285F4), Icons.image),
                              SizedBox(height: 6),
                              _buildLegendItem(S.of(context).videos, Color(0xFFEA4335), Icons.videocam),
                              SizedBox(height: 6),
                              _buildLegendItem(S.of(context).audio, Color(0xFF34A853), Icons.audiotrack),
                              SizedBox(height: 6),
                              _buildLegendItem(S.of(context).compressed, Color(0xFFFF6D00), Icons.folder_zip),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(S.of(context).applications, Color(0xFF9C27B0), Icons.apps),
                              SizedBox(height: 6),
                              _buildLegendItem(S.of(context).documents, Color(0xFF795548), Icons.description),
                              SizedBox(height: 6),
                              _buildLegendItem(S.of(context).code, Color(0xFF009688), Icons.code),
                              SizedBox(height: 6),
                              _buildLegendItem(S.of(context).other, Color(0xFF607D8B), Icons.more_horiz),
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
                                color: Color(0xFF9C27B0), // Applications - Purple
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
                          color: Color(0xff28336f),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Color(0xff28336f), size: 20),
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

  Widget _buildLegendItem(String label, Color color, IconData icon) {
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
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStackCircle(double left, Color color) {
    return Positioned(
      left: left,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
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

  StorageCirclePainter({
    required this.images,
    required this.videos,
    required this.audio,
    required this.compressed,
    required this.applications,
    required this.documents,
    required this.code,
    required this.other,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 15.0;

    // ✅ رسم خلفية رمادية خفيفة للدائرة كاملة (للعرض فقط)
    final bgPaint = Paint()
      ..color = Colors.grey[200]! // رمادي فاتح جداً
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double startAngle = -math.pi / 2;

    // ✅ ترتيب الأقسام حسب الحجم (من الأكبر للأصغر) لعرض أفضل
    final segments = [
      {'value': images, 'color': Color(0xFF4285F4), 'name': 'images'},
      {'value': videos, 'color': Color(0xFFEA4335), 'name': 'videos'},
      {'value': audio, 'color': Color(0xFF34A853), 'name': 'audio'},
      {'value': compressed, 'color': Color(0xFFFF6D00), 'name': 'compressed'},
      {'value': applications, 'color': Color(0xFF9C27B0), 'name': 'applications'},
      {'value': documents, 'color': Color(0xFF795548), 'name': 'documents'},
      {'value': code, 'color': Color(0xFF009688), 'name': 'code'},
      {'value': other, 'color': Color(0xFF607D8B), 'name': 'other'},
    ];

    // ✅ ترتيب الأقسام حسب الحجم (من الأكبر للأصغر)
    segments.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    // ✅ حساب مجموع الاستخدام
    double totalUsed = segments.fold(0.0, (sum, seg) => sum + (seg['value'] as double));

    // ✅ رسم الأقسام المرتبة (حتى لو كانت صغيرة جداً، سنرسمها إذا كانت > 0)
    for (var segment in segments) {
      final double value = segment['value'] as double;
      // ✅ رسم الأقسام التي لها قيمة أكبر من 0 (حتى لو كانت صغيرة)
      if (value > 0) {
        final paint = Paint()
          ..color = segment['color'] as Color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
          startAngle,
          2 * math.pi * value,
          false,
          paint,
        );

        startAngle += 2 * math.pi * value;
      }
    }

    // ✅ المساحة الفارغة لا تُرسم (شفافة) لتظهر الخلفية
    // لا نرسم المساحة المتبقية - ستكون شفافة تلقائياً
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
