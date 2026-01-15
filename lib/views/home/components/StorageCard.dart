import 'package:flutter/material.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/home/components/StorageChartPainter.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/generated/l10n.dart';

class StorageCard extends StatefulWidget {
  const StorageCard({super.key});

  @override
  State<StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends State<StorageCard> {
  @override
  void initState() {
    super.initState();
    // ✅ جلب معلومات المساحة من ProfileController عند تحميل الـ widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final profileController = context.read<ProfileController>();
        // ✅ دائماً نجلب معلومات المساحة للتأكد من أنها محدثة
        profileController.getStorageInfo(forceRefresh: true);
      }
    });
  }

  // ✅ دالة لتحويل البايت إلى GB
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ جلب معلومات المساحة من ProfileController (نفس البيانات المستخدمة في صفحة البروفايل)
    final profileController = context.watch<ProfileController>();
    final storageInfo = profileController.storageInfo;
    
    // ✅ طباعة للتحقق من البيانات
    print('🏠 [HomeStorageCard] Building with storageInfo: $storageInfo');
    
    // ✅ القيم الافتراضية (10 GB كحد أقصى)
    final int totalStorage = storageInfo?['limit'] as int? ?? (10 * 1024 * 1024 * 1024); // 10 GB
    final int usedStorage = storageInfo?['used'] as int? ?? 0;
    
    print('🏠 [HomeStorageCard] totalStorage: ${_formatBytes(totalStorage)}, usedStorage: ${_formatBytes(usedStorage)}');
    
    // ✅ استخدام البيانات المنسقة من storageInfo أو تنسيقها محلياً
    final String usedFormatted = storageInfo?['usedFormatted'] as String? ?? _formatBytes(usedStorage);
    // ✅ المساحة المتاحة = المساحة الكلية (10 GB) - المساحة المستخدمة
    final int availableStorage = totalStorage - usedStorage;
    // ✅ عرض المساحة المتاحة دائماً كـ 10.00 GB - المساحة المستخدمة (أو فقط "10.00 GB" إذا كانت المساحة المستخدمة صغيرة)
    final String availableFormatted = _formatBytes(totalStorage); // ✅ دائماً 10.00 GB
    
    // ✅ حساب النسبة المئوية بشكل صحيح من usedStorage / totalStorage
    final double percentageValue = usedStorage > 0 && totalStorage > 0
        ? (usedStorage / totalStorage) * 100.0
        : 0.0;
    final String percentageText = percentageValue.toStringAsFixed(1);
    
    print('🏠 [HomeStorageCard] percentageValue: $percentageValue%, percentageText: $percentageText%');
    // قياسات ري̆سبونسف
    final margin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 20.0,
      desktop: 32.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 20.0,
      desktop: 32.0,
    );
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
    final chartSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 120.0,
      tablet: 140.0,
      desktop: 160.0,
    );
    final innerCircleSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );
    final iconSizeSmall = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 10.0,
      tablet: 12.0,
      desktop: 14.0,
    );
    final textSizeLabel = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    final textSizeValue = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 6.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    // عرض الكارد ديناميكي حسب الجهاز
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: screenWidth * 0.95,
      tablet: screenWidth * 0.7,
      desktop: screenWidth * 0.5,
    );

    return Center(
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.6),
              Colors.white.withOpacity(0.001),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // المركزية عمودي
          mainAxisAlignment:
              MainAxisAlignment.center, // ← المركزية أفقياً داخل الكارد
          children: [
            // الدايرة
            Container(
              width: chartSize,
              height: chartSize,
              child: CustomPaint(
                painter: StorageChartPainter(usedPercent: percentageValue / 100.0),
                child: Center(
                  child: Container(
                    width: innerCircleSize,
                    height: innerCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF26A69A),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$percentageText%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: textSizeValue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            usedFormatted,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: textSizeLabel * 0.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing * 3),

            // النصوص
            Column(
              mainAxisAlignment: MainAxisAlignment.center, // ← المركزية عمودياً
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: iconSizeSmall,
                      height: iconSizeSmall,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(width: spacing),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).storageAvailable,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: textSizeLabel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          availableFormatted,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: textSizeValue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: spacing * 2.5),
                Row(
                  children: [
                    Container(
                      width: iconSizeSmall,
                      height: iconSizeSmall,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00BFA5),
                      ),
                    ),
                    SizedBox(width: spacing),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).storageUsed,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: textSizeLabel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          usedFormatted,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: textSizeValue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
