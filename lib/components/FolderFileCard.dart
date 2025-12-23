import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:filevo/responsive.dart';

class FolderFileCard extends StatelessWidget {
  final String title;
  final int fileCount;
  final String size;
  final Color color;
  final VoidCallback? onTap;
  final bool showFileCount;
  final VoidCallback? onInfoTap; // ✅ callback لمعلومات المجلد
  final VoidCallback? onRenameTap; // ✅ callback لإعادة تسمية
  final VoidCallback? onDeleteTap; // ✅ callback للحذف
  final VoidCallback? onShareTap; // ✅ callback للمشاركة
  final VoidCallback? onOpenTap; // ✅ callback لفتح المجلد
  final VoidCallback? onDetailsTap; // ✅ callback لعرض تفاصيل الغرفة
  final VoidCallback? onCommentTap; // ✅ callback للتعليق على المجلد/الملف
  final VoidCallback? onFavoriteTap; // ✅ callback لإضافة/إزالة من المفضلة
  final VoidCallback? onMoveTap; // ✅ callback لنقل المجلد
  final VoidCallback? onRemoveFromRoomTap; // ✅ callback لإزالة المجلد من الغرفة
  final VoidCallback? onSaveTap; // ✅ callback لحفظ المجلد من الغرفة
  final VoidCallback? onDownloadTap; // ✅ callback لتحميل المجلد من الغرفة
  final VoidCallback? onProtectTap; // ✅ callback لقفل/إلغاء قفل المجلد
  final bool isStarred; // ✅ حالة المفضلة
  final Map<String, dynamic>? folderData; // ✅ بيانات المجلد الكاملة
  final String? sharedBy; // ✅ معلومات من شارك المجلد/الملف
  final String? roomId; // ✅ معرف الغرفة (لتمييز المجلدات المشتركة)

  const FolderFileCard({
    Key? key,
    required this.title,
    required this.fileCount,
    required this.size,
    this.color = const Color(0xFF28336F),
    this.onTap,
    this.showFileCount = true,
    this.onInfoTap,
    this.onRenameTap,
    this.onDeleteTap,
    this.onShareTap,
    this.onOpenTap,
    this.onDetailsTap,
    this.onCommentTap,
    this.onFavoriteTap,
    this.onMoveTap,
    this.onRemoveFromRoomTap,
    this.onSaveTap,
    this.onDownloadTap,
    this.onProtectTap,
    this.isStarred = false,
    this.folderData,
    this.sharedBy,
    this.roomId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // ✅ التحقق إذا كان هذا غرفة
        final isRoom = folderData != null && folderData!['type'] == 'room';

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(w * 0.08),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w * 0.08),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: isRoom
                ? _buildRoomCard(context, w, h)
                : _buildNormalCard(context, w, h),
          ),
        );
      },
    );
  }

  // ✅ بناء كارد الغرفة بتصميم خاص
  Widget _buildRoomCard(BuildContext context, double w, double h) {
    // ✅ تدرج لوني جميل للغرف
    final roomGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF28336F), // الأزرق الداكن
        Color(0xFF3B4A8A), // أزرق فاتح قليلاً
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ Header مع أيقونة وتدرج لوني
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(w * 0.06),
              decoration: BoxDecoration(
                gradient: roomGradient,
                borderRadius: BorderRadius.circular(w * 0.06),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF28336F).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.meeting_room_rounded,
                color: Colors.white,
                size: w * 0.18,
              ),
            ),
            // ✅ زر 3 نقاط
            GestureDetector(
              onTap: () {
                if (onDetailsTap != null) {
                  _showContextMenu(context);
                }
              },
              child: Container(
                padding: EdgeInsets.all(w * 0.03),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey[700],
                  size: w * 0.10,
                ),
              ),
            ),
          ],
        ),

        // ✅ اسم الغرفة
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF28336F),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // ✅ معلومات الغرفة
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.015), // ✅ تقليل المسافة
            // ✅ عدد العناصر (ملفات + مجلدات)
            if (showFileCount)
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(w * 0.02),
                    decoration: BoxDecoration(
                      color: Color(0xFF28336F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(w * 0.02),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: w * 0.07,
                      color: Color(0xFF28336F),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: Text(
                      _formatItemsCount(context),
                      style: TextStyle(
                        fontSize: w * 0.09,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1, // ✅ سطر واحد فقط
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            SizedBox(height: h * 0.008), // ✅ تقليل المسافة
            // ✅ عدد الأعضاء
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: w * 0.08,
                  color: Colors.grey[600],
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: Text(
                    size, // هذا يحتوي على عدد الأعضاء
                    style: TextStyle(
                      fontSize: w * 0.09,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ✅ بناء الكارد العادي (للمجلدات والملفات)
  Widget _buildNormalCard(BuildContext context, double w, double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.folder, color: color, size: w * 0.22),
            // ✅ زر 3 نقاط - يفتح قائمة منبثقة من الأسفل
            GestureDetector(
              onTap: () {
                if (onOpenTap != null ||
                    onInfoTap != null ||
                    onRenameTap != null ||
                    onShareTap != null ||
                    onMoveTap != null ||
                    onDeleteTap != null ||
                    onDetailsTap != null ||
                    onCommentTap != null ||
                    onRemoveFromRoomTap != null ||
                    onSaveTap != null ||
                    onDownloadTap != null ||
                    onProtectTap != null) {
                  _showContextMenu(context);
                }
              },
              child: Icon(Icons.more_vert, color: Colors.grey, size: w * 0.12),
            ),
          ],
        ),

        Text(
          title,
          style: TextStyle(fontSize: w * 0.12, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showFileCount)
                  Text(
                    "$fileCount  ${S.of(context).files}",
                    style: TextStyle(
                      fontSize: w * 0.10,
                      color: Colors.grey[600],
                    ),
                  ),
                if (!showFileCount) SizedBox.shrink(),
                Text(
                  size,
                  style: TextStyle(fontSize: w * 0.10, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ✅ تنسيق عدد العناصر (ملفات + مجلدات)
  String _formatItemsCount(BuildContext context) {
    // ✅ محاولة جلب البيانات من folderData أولاً (للغرف، folderData = item)
    int? filesCount;
    int? foldersCount;

    if (folderData != null) {
      // ✅ للغرف، البيانات موجودة مباشرة في folderData
      // ✅ محاولة جلب filesCount و foldersCount من folderData
      final filesCountValue = folderData!['filesCount'];
      final foldersCountValue = folderData!['foldersCount'];

      print(
        'filesCountValue: $filesCountValue, foldersCountValue: $foldersCountValue',
      );
      // ✅ تحويل إلى int بشكل آمن
      if (filesCountValue != null) {
        if (filesCountValue is int) {
          filesCount = filesCountValue;
        } else if (filesCountValue is num) {
          filesCount = filesCountValue.toInt();
        } else if (filesCountValue is String) {
          filesCount = int.tryParse(filesCountValue) ?? 0;
        }
      }

      if (foldersCountValue != null) {
        if (foldersCountValue is int) {
          foldersCount = foldersCountValue;
        } else if (foldersCountValue is num) {
          foldersCount = foldersCountValue.toInt();
        } else if (foldersCountValue is String) {
          foldersCount = int.tryParse(foldersCountValue) ?? 0;
        }
      }

      // ✅ إذا لم تكن موجودة في folderData، حاول جلبها من room
      if (filesCount == null || foldersCount == null) {
        final room = folderData!['room'] as Map<String, dynamic>?;
        if (room != null) {
          // ✅ محاولة جلب filesCount و foldersCount من room
          if (filesCount == null) {
            final roomFilesCount = room['filesCount'];
            if (roomFilesCount != null) {
              if (roomFilesCount is int) {
                filesCount = roomFilesCount;
              } else if (roomFilesCount is num) {
                filesCount = roomFilesCount.toInt();
              } else if (roomFilesCount is String) {
                filesCount = int.tryParse(roomFilesCount) ?? 0;
              }
            } else if (room['files'] is List) {
              // ✅ إذا لم يكن filesCount موجوداً، احسبه من array
              filesCount = (room['files'] as List).length;
            }
          }

          if (foldersCount == null) {
            final roomFoldersCount = room['foldersCount'];
            if (roomFoldersCount != null) {
              if (roomFoldersCount is int) {
                foldersCount = roomFoldersCount;
              } else if (roomFoldersCount is num) {
                foldersCount = roomFoldersCount.toInt();
              } else if (roomFoldersCount is String) {
                foldersCount = int.tryParse(roomFoldersCount) ?? 0;
              }
            } else if (room['folders'] is List) {
              // ✅ إذا لم يكن foldersCount موجوداً، احسبه من array
              foldersCount = (room['folders'] as List).length;
            }
          }
        }
      }
    }

    // ✅ حساب الإجمالي
    int finalTotal;
    if (filesCount != null && foldersCount != null) {
      finalTotal = filesCount + foldersCount;
    } else if (filesCount != null) {
      // ✅ إذا كان filesCount موجوداً فقط
      finalTotal = filesCount;
    } else if (foldersCount != null) {
      // ✅ إذا كان foldersCount موجوداً فقط
      finalTotal = foldersCount;
    } else {
      // ✅ إذا لم تكن هناك تفاصيل، استخدم fileCount (الذي يحتوي على الإجمالي)
      finalTotal = fileCount;
    }

    // ✅ عرض عدد العناصر فقط بدون تفاصيل
    if (finalTotal == 0) {
      return S.of(context).noItems;
    } else if (finalTotal == 1) {
      return S.of(context).oneItem;
    } else {
      return "$finalTotal  ${S.of(context).item}";
    }
  }

  // ✅ عرض قائمة منبثقة من الأسفل
  void _showContextMenu(BuildContext context) {
    // ✅ تحديد إذا كان category (من folderData)
    final isCategory = folderData != null && folderData!['type'] == 'category';
    // ✅ تحديد إذا كان room (من folderData)
    final isRoom = folderData != null && folderData!['type'] == 'room';

    if (isCategory) {
      // ✅ قائمة خاصة للـ categories
      _showCategoryMenu(context);
    } else if (isRoom) {
      // ✅ قائمة خاصة للغرف
      _showRoomMenu(context);
    } else if (roomId != null) {
      // ✅ قائمة منفصلة للمجلدات المشتركة في الغرف
      _showSharedFolderMenu(context);
    } else {
      // ✅ قائمة المجلدات العادية
      _showNormalFolderMenu(context);
    }
  }

  // ✅ قائمة خاصة للـ categories
  void _showCategoryMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ✅ قائمة خيارات الـ categories
            if (onOpenTap != null)
              _buildMenuItem(
                context,
                icon: Icons.open_in_new,
                title: S.of(context).open,
                onTap: () {
                  Navigator.pop(context);
                  onOpenTap?.call();
                },
              ),

            if (onInfoTap != null)
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: S.of(context).viewDetails,
                onTap: () {
                  Navigator.pop(context);
                  onInfoTap?.call();
                },
              ),

            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ قائمة خاصة للغرف
  void _showRoomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ✅ قائمة خيارات الغرف
            if (onOpenTap != null)
              _buildMenuItem(
                context,
                icon: Icons.open_in_new,
                title: S.of(context).open,
                onTap: () {
                  Navigator.pop(context);
                  onOpenTap?.call();
                },
              ),

            if (onDetailsTap != null)
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: S.of(context).viewInfo,
                onTap: () {
                  Navigator.pop(context);
                  onDetailsTap?.call();
                },
              ),

            if (onRenameTap != null)
              _buildMenuItem(
                context,
                icon: Icons.edit,
                title: S.of(context).update,
                onTap: () {
                  Navigator.pop(context);
                  onRenameTap?.call();
                },
              ),

            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ قائمة المجلدات المشتركة في الغرف
  void _showSharedFolderMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ✅ قائمة خيارات المجلدات المشتركة
            if (onOpenTap != null)
              _buildMenuItem(
                context,
                icon: Icons.open_in_new,
                title: S.of(context).open,
                onTap: () {
                  Navigator.pop(context);
                  onOpenTap?.call();
                },
              ),

            if (onInfoTap != null)
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: S.of(context).viewDetails,
                onTap: () {
                  Navigator.pop(context);
                  onInfoTap?.call();
                },
              ),

            if (onCommentTap != null)
              _buildMenuItem(
                context,
                icon: Icons.comment,
                title: S.of(context).comments,
                iconColor: Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  onCommentTap?.call();
                },
              ),

            if (onFavoriteTap != null) ...[
              Divider(height: 1),
              _buildMenuItem(
                context,
                icon: isStarred ? Icons.star : Icons.star_border,
                title: isStarred
                    ? S.of(context).folderAddedToFavorites
                    : S.of(context).folderRemovedFromFavorites,
                iconColor: Colors.amber[700],
                onTap: () {
                  Navigator.pop(context);
                  onFavoriteTap?.call();
                },
              ),
            ],

            if (onSaveTap != null)
              _buildMenuItem(
                context,
                icon: Icons.save,
                title: S.of(context).saveToMyAccount,
                iconColor: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  onSaveTap?.call();
                },
              ),

            if (onDownloadTap != null)
              _buildMenuItem(
                context,
                icon: Icons.download,
                title: S.of(context).download,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  onDownloadTap?.call();
                },
              ),

            if (onRemoveFromRoomTap != null) ...[
              Divider(height: 1),
              _buildMenuItem(
                context,
                icon: Icons.link_off,
                title: S.of(context).removeFromRoom,
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  onRemoveFromRoomTap?.call();
                },
              ),
            ],

            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ قائمة المجلدات العادية
  void _showNormalFolderMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 24.0,
                  desktop: 28.0,
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Handle bar
              Container(
                margin: EdgeInsets.only(
                  top: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 12.0,
                    tablet: 14.0,
                    desktop: 16.0,
                  ),
                  bottom: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 8.0,
                    tablet: 10.0,
                    desktop: 12.0,
                  ),
                ),
                width: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 40.0,
                  tablet: 50.0,
                  desktop: 60.0,
                ),
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 4.0,
                  tablet: 5.0,
                  desktop: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ✅ قائمة خيارات المجلدات العادية - قابلة للتمرير
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onOpenTap != null)
                        _buildMenuItem(
                          context,
                          icon: Icons.open_in_new,
                          title: S.of(context).open,
                          onTap: () {
                            Navigator.pop(context);
                            onOpenTap?.call();
                          },
                        ),

                      if (onInfoTap != null)
                        _buildMenuItem(
                          context,
                          icon: Icons.info_outline,
                          title: S.of(context).viewDetails,
                          onTap: () {
                            Navigator.pop(context);
                            onInfoTap?.call();
                          },
                        ),

                      if (onRenameTap != null)
                        _buildMenuItem(
                          context,
                          icon: Icons.edit,
                          title: S.of(context).update,
                          onTap: () {
                            Navigator.pop(context);
                            onRenameTap?.call();
                          },
                        ),

                      if (onShareTap != null)
                        _buildMenuItem(
                          context,
                          icon: Icons.share,
                          title: S.of(context).share,
                          onTap: () {
                            Navigator.pop(context);
                            onShareTap?.call();
                          },
                        ),

                      // if (onDownloadTap != null && roomId == null)
                      //   _buildMenuItem(
                      //     context,
                      //     icon: Icons.download,
                      //     title: 'تحميل',
                      //     iconColor: Colors.blue,
                      //     onTap: () {
                      //       Navigator.pop(context);
                      //       onDownloadTap?.call();
                      //     },
                      //   ),
                      if (onMoveTap != null)
                        _buildMenuItem(
                          context,
                          icon: Icons.drive_file_move_rounded,
                          title: S.of(context).move,
                          iconColor: Colors.purple,
                          onTap: () {
                            Navigator.pop(context);
                            onMoveTap?.call();
                          },
                        ),

                      if (onFavoriteTap != null)
                        _buildMenuItem(
                          context,
                          icon: isStarred ? Icons.star : Icons.star_border,
                          title: isStarred
                              ? S.of(context).folderAddedToFavorites
                              : S.of(context).folderRemovedFromFavorites,
                          iconColor: Colors.amber[700],
                          onTap: () {
                            Navigator.pop(context);
                            onFavoriteTap?.call();
                          },
                        ),

                      if (onProtectTap != null) ...[
                        Divider(height: 1),
                        _buildMenuItem(
                          context,
                          icon: folderData?['isProtected'] == true
                              ? Icons.lock_open
                              : Icons.lock,
                          title: folderData?['isProtected'] == true
                              ? 'إلغاء قفل المجلد'
                              : 'قفل المجلد',
                          iconColor: Colors.orange[700],
                          onTap: () {
                            Navigator.pop(context);
                            onProtectTap?.call();
                          },
                        ),
                      ],
                      if (onDeleteTap != null) ...[
                        Divider(height: 1),
                        _buildMenuItem(
                          context,
                          icon: Icons.delete,
                          title: S.of(context).delete,
                          textColor: Colors.red,
                          iconColor: Colors.red,
                          onTap: () {
                            Navigator.pop(context);
                            onDeleteTap?.call();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 12.0,
                  desktop: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final containerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final fontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    return ListTile(
      leading: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey[700])!.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.grey[700], size: iconSize),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
