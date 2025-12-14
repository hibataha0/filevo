import 'dart:async';
import 'dart:io';
import 'package:filevo/views/fileViewer/file_details_page.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/utils/room_permissions.dart';
import 'file_actions_service.dart';
import 'package:filevo/generated/l10n.dart';

class FilesGrid extends StatefulWidget {
  final List<Map<String, dynamic>> files;
  final void Function(Map<String, dynamic> file)? onFileTap;
  final String?
  roomId; // ✅ معرف الروم (اختياري) - لاستخدام getSharedFileDetailsInRoom
  final VoidCallback? onFileRemoved; // ✅ callback عند إزالة ملف من الغرفة
  final VoidCallback? onFileUpdated; // ✅ callback عند تحديث ملف

  const FilesGrid({
    super.key,
    required this.files,
    this.onFileTap,
    this.roomId,
    this.onFileRemoved,
    this.onFileUpdated,
  });

  @override
  State<FilesGrid> createState() => _FilesGridState();
}

class _FilesGridState extends State<FilesGrid> {
  // ✅ إضافة: Map لتتبع حالة النجمة لكل ملف
  final Map<String, bool> _starStates = {};

  // ✅ Cache للـ token لتجنب إعادة جلبها
  String? _cachedToken;
  bool _isLoadingToken = false;

  // ✅ بيانات الغرفة للتحقق من الصلاحيات
  Map<String, dynamic>? _roomData;

  @override
  void initState() {
    super.initState();
    _initializeStarStates();
    _loadToken();
    // ✅ تأجيل تحميل بيانات الغرفة حتى بعد اكتمال البناء الأولي
    if (widget.roomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRoomData();
      });
    }
  }

  // ✅ جلب بيانات الغرفة للتحقق من الصلاحيات
  Future<void> _loadRoomData() async {
    if (widget.roomId == null || !mounted) return;

    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final response = await roomController.getRoomById(widget.roomId!);

      if (mounted) {
        setState(() {
          _roomData = response?['room'];
        });
      }
    } catch (e) {
      print('Error loading room data: $e');
    }
  }

  // ✅ جلب token مرة واحدة عند التهيئة
  Future<void> _loadToken() async {
    if (_cachedToken == null && !_isLoadingToken) {
      _isLoadingToken = true;
      _cachedToken = await StorageService.getToken();
      _isLoadingToken = false;
    }
  }

  @override
  void didUpdateWidget(FilesGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ تحديث الحالات عند تغيير القائمة
    print(
      '🔍 [FilesGridView1] didUpdateWidget called - oldWidget.files.length: ${oldWidget.files.length}, widget.files.length: ${widget.files.length}',
    );
    print(
      '🔍 [FilesGridView1] oldWidget.files == widget.files: ${oldWidget.files == widget.files}',
    );
    if (oldWidget.files != widget.files) {
      print(
        '🔍 [FilesGridView1] Files list changed, calling _initializeStarStates',
      );
      _initializeStarStates();
    } else {
      print(
        '🔍 [FilesGridView1] Files list unchanged, but checking if star states need update',
      );
      // ✅ حتى لو كانت القائمة نفسها، قد تكون قيم isStarred تغيرت
      _initializeStarStates();
    }
  }

  // ✅ إضافة: تهيئة حالات النجمة من البيانات
  void _initializeStarStates() {
    print(
      '🔍 [FilesGridView1] Initializing star states for ${widget.files.length} files',
    );
    bool hasChanges = false;
    for (var file in widget.files) {
      final fileId = file['originalData']?['_id'];
      if (fileId != null) {
        // ✅ قراءة isStarred من originalData مع fallback إلى القيمة في الملف مباشرة
        final originalData = file['originalData'] as Map<String, dynamic>?;
        final isStarred =
            originalData?['isStarred'] ?? file['isStarred'] ?? false;
        final oldValue = _starStates[fileId];
        print(
          '🔍 [FilesGridView1] File $fileId - isStarred from originalData: ${originalData?['isStarred']}, from file: ${file['isStarred']}, final: $isStarred, oldValue: $oldValue',
        );
        // ✅ تحديث _starStates دائماً عند إعادة التهيئة لضمان المزامنة
        if (oldValue != isStarred) {
          _starStates[fileId] = isStarred;
          hasChanges = true;
          print(
            '🔍 [FilesGridView1] Updated _starStates[$fileId] = $isStarred',
          );
        }
      } else {
        print('🔍 [FilesGridView1] File has no _id: ${file.keys}');
      }
    }
    // ✅ إعادة بناء الـ widget إذا كانت هناك تغييرات
    if (hasChanges && mounted) {
      print('🔍 [FilesGridView1] Calling setState due to star state changes');
      setState(() {});
    } else {
      print(
        '🔍 [FilesGridView1] No changes or not mounted. hasChanges: $hasChanges, mounted: $mounted',
      );
    }
  }

  // ✅ Cache لـ thumbnails الفيديو لمنع إعادة التوليد عند scroll
  final Map<String, String?> _thumbnailCache = {};

  Future<String?> _getVideoThumbnail(String videoUrl) async {
    // ✅ التحقق من cache أولاً
    if (_thumbnailCache.containsKey(videoUrl)) {
      final cachedPath = _thumbnailCache[videoUrl];
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return cachedPath; // ✅ إرجاع thumbnail من cache
        }
      }
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        quality: 75,
        timeMs: 1000, // ✅ أخذ thumbnail من الثانية الأولى
      );

      // ✅ حفظ في cache
      if (thumbnailPath != null) {
        _thumbnailCache[videoUrl] = thumbnailPath;
      }

      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail: $e');
      _thumbnailCache[videoUrl] =
          null; // ✅ حفظ null في cache لتجنب إعادة المحاولة
      return null;
    }
  }

  void _handleMenuAction(String action, Map<String, dynamic> file) {
    if (!mounted) return;

    final fileController = Provider.of<FileController>(context, listen: false);

    switch (action) {
      case 'open':
        FileActionsService.openFile(file, widget.onFileTap);
        break;
      case 'info':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileDetailsPage(
              fileId: file['originalData']['_id'],
              roomId: widget.roomId, // ✅ تمرير roomId إذا كان موجوداً
            ),
          ),
        );
        break;
      case 'download':
        // ✅ تحميل الملف
        FileActionsService.downloadFile(context, file);
        break;
      case 'comments':
        if (widget.roomId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomCommentsPage(
                roomId: widget.roomId!,
                targetType: 'file',
                targetId: file['originalData']['_id'],
              ),
            ),
          );
        }
        break;
      case 'edit':
        // ✅ فتح صفحة التحرير والانتظار للنتيجة
        // ✅ تمرير roomId إذا كان موجوداً
        print('🔍 [FilesGridView1] Edit file - roomId: ${widget.roomId}');
        FileActionsService.editFile(context, file, roomId: widget.roomId)
            .then((result) {
              // ✅ إذا تم تحديث الملف، استدعي callback لإعادة تحميل البيانات
              if (result == true && widget.onFileUpdated != null) {
                print(
                  '✅ [FilesGridView1] File updated, calling onFileUpdated callback',
                );
                // ✅ استخدام Future.microtask لتأجيل الاستدعاء وتجنب التعليق
                Future.microtask(() {
                  if (mounted && widget.onFileUpdated != null) {
                    widget.onFileUpdated!();
                  }
                });
              }
            })
            .catchError((error) {
              print('❌ [FilesGridView1] Error in editFile: $error');
            });
        break;
      case 'share':
        FileActionsService.shareFile(context, file);
        break;
      case 'move':
        // ✅ نقل الملف
        _showMoveFileDialog(file);
        break;
      case 'favorite':
        FileActionsService.toggleStar(
          context,
          fileController,
          file,
          onToggle: () {
            final fileId = file['originalData']?['_id'];
            if (fileId != null && mounted) {
              setState(() {
                // ✅ قراءة القيمة المحدثة من originalData مباشرة
                final updatedIsStarred =
                    file['originalData']['isStarred'] ?? false;
                _starStates[fileId] = updatedIsStarred;

                // ✅ تحديث البيانات في widget.files أيضاً لضمان استمرار التحديث
                final fileIndex = widget.files.indexWhere((f) {
                  final fId = f['originalData']?['_id']?.toString();
                  return fId == fileId.toString();
                });
                if (fileIndex != -1) {
                  final fileOriginalData =
                      widget.files[fileIndex]['originalData'];
                  if (fileOriginalData is Map<String, dynamic>) {
                    fileOriginalData['isStarred'] = updatedIsStarred;
                  }
                }

                print(
                  '🎨 UI Updated - Star state for $fileId: $updatedIsStarred',
                );
              });
            }
          },
        );
        break;
      case 'unshare':
        FileActionsService.unshareFile(context, fileController, file);
        break;
      case 'delete':
        FileActionsService.deleteFile(context, fileController, file);
        break;
    }
  }

  /// ✅ بناء قائمة الملفات المشتركة في الغرف
  List<PopupMenuEntry<String>> _buildSharedFileMenuItems(
    Map<String, dynamic> file,
    bool isStarred,
  ) {
    return [
      _buildMenuItem(
        'open',
        Icons.open_in_new_rounded,
        S.of(context).open,
        Colors.blue,
      ),
      _buildMenuItem(
        'info',
        Icons.info_outline_rounded,
        S.of(context).viewDetails,
        Colors.teal,
      ),
      _buildMenuItem(
        'download',
        Icons.download_rounded,
        S.of(context).download,
        Colors.blue,
      ),
      _buildMenuItem(
        'comments',
        Icons.comment_rounded,
        S.of(context).comments,
        Color(0xFFF59E0B),
      ),
      const PopupMenuDivider(),
      // ✅ إزالة خيار "إضافة إلى المفضلة" من الملفات المشتركة في الروم
      _buildMenuItem(
        'save',
        Icons.save_rounded,
        S.of(context).saveToMyAccount,
        Colors.green,
      ),
      const PopupMenuDivider(),
      // ✅ إضافة خيار "إزالة من الغرفة" دائماً
      // ✅ التحقق من الصلاحيات يتم في _handleSharedFileMenuAction
      _buildMenuItem(
        'remove_from_room',
        Icons.link_off_rounded,
        S.of(context).removeFromRoom,
        Colors.red,
      ),
    ];
  }

  /// ✅ بناء قائمة الملفات العادية
  List<PopupMenuEntry<String>> _buildNormalFileMenuItems(
    Map<String, dynamic> file,
    bool isStarred,
  ) {
    return [
      _buildMenuItem(
        'open',
        Icons.open_in_new_rounded,
        S.of(context).open,
        Colors.blue,
      ),
      _buildMenuItem(
        'info',
        Icons.info_outline_rounded,
        S.of(context).viewInfo,
        Colors.teal,
      ),
      _buildMenuItem(
        'download',
        Icons.download_rounded,
        S.of(context).download,
        Colors.blue,
      ),
      _buildMenuItem(
        'edit',
        Icons.edit_rounded,
        S.of(context).edit,
        Colors.orange,
      ),
      _buildMenuItem(
        'share',
        Icons.share_rounded,
        S.of(context).share,
        Colors.green,
      ),
      _buildMenuItem(
        'move',
        Icons.drive_file_move_rounded,
        S.of(context).move,
        Colors.purple,
      ),
      _buildMenuItem(
        'favorite',
        isStarred ? Icons.star_rounded : Icons.star_border_rounded,
        isStarred
            ? S.of(context).removeFromFavorites
            : S.of(context).addToFavorites,
        Colors.amber[700]!,
      ),
      const PopupMenuDivider(),
      _buildMenuItem(
        'delete',
        Icons.delete_outline_rounded,
        S.of(context).delete,
        Colors.red,
      ),
    ];
  }

  /// ✅ معالجة إجراءات الملفات المشتركة في الغرف
  void _handleSharedFileMenuAction(String action, Map<String, dynamic> file) {
    if (!mounted) return;

    final fileController = Provider.of<FileController>(context, listen: false);

    switch (action) {
      case 'open':
        FileActionsService.openFile(file, widget.onFileTap);
        break;
      case 'info':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileDetailsPage(
              fileId: file['originalData']['_id'],
              roomId: widget.roomId,
            ),
          ),
        );
        break;
      case 'download':
        // ✅ تحميل ملف مشترك في الروم
        if (widget.roomId != null) {
          final fileId = file['originalData']?['_id'] ?? file['fileId'];
          final fileName =
              file['name'] ??
              file['originalName'] ??
              file['originalData']?['name'];
          if (fileId != null) {
            final roomController = Provider.of<RoomController>(
              context,
              listen: false,
            );
            FileActionsService.downloadRoomFile(
              context,
              roomController,
              widget.roomId!,
              fileId,
              fileName,
            );
          }
        }
        break;
      case 'comments':
        if (widget.roomId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomCommentsPage(
                roomId: widget.roomId!,
                targetType: 'file',
                targetId: file['originalData']['_id'],
              ),
            ),
          );
        }
        break;
      case 'favorite':
        print(
          '⭐ [FilesGridView1] Toggle star called for file: ${file['originalData']?['_id']}',
        );
        FileActionsService.toggleStar(
          context,
          fileController,
          file,
          onToggle: () {
            print('⭐ [FilesGridView1] onToggle callback called');
            final fileId = file['originalData']?['_id'];
            print('⭐ [FilesGridView1] fileId: $fileId, mounted: $mounted');
            if (fileId != null && mounted) {
              // ✅ قراءة القيمة المحدثة من originalData مباشرة
              final updatedIsStarred =
                  file['originalData']['isStarred'] ?? false;
              print('⭐ [FilesGridView1] updatedIsStarred: $updatedIsStarred');

              setState(() {
                _starStates[fileId] = updatedIsStarred;
                print(
                  '⭐ [FilesGridView1] _starStates[$fileId] = $updatedIsStarred',
                );

                // ✅ تحديث البيانات في widget.files أيضاً لضمان استمرار التحديث
                final fileIndex = widget.files.indexWhere((f) {
                  final fId = f['originalData']?['_id']?.toString();
                  return fId == fileId.toString();
                });
                if (fileIndex != -1) {
                  final fileOriginalData =
                      widget.files[fileIndex]['originalData'];
                  if (fileOriginalData is Map<String, dynamic>) {
                    fileOriginalData['isStarred'] = updatedIsStarred;
                    print(
                      '⭐ [FilesGridView1] Updated widget.files[$fileIndex][\'originalData\'][\'isStarred\'] = $updatedIsStarred',
                    );
                  }
                } else {
                  print('⭐ [FilesGridView1] File not found in widget.files');
                }

                print(
                  '🎨 UI Updated - Star state for $fileId: $updatedIsStarred',
                );
              });

              // ✅ لا نستدعي onFileRemoved هنا لأن التحديث الفوري كافٍ
              // ✅ سيتم إعادة تحميل البيانات عند إعادة فتح الصفحة
            } else {
              print(
                '⭐ [FilesGridView1] fileId is null or widget is not mounted',
              );
            }
          },
        );
        break;
      case 'save':
        _saveFileFromRoom(file);
        break;
      case 'remove_from_room':
        // ✅ التحقق من الصلاحيات قبل إزالة الملف
        if (_roomData != null) {
          RoomPermissions.canRemoveFiles(_roomData!).then((canRemove) {
            if (canRemove) {
              _showRemoveFileFromRoomDialog(file);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '❌ فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم إزالة الملفات',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        } else {
          // ✅ إذا لم تكن بيانات الغرفة محملة، حاول تحميلها أولاً
          _loadRoomData().then((_) {
            if (_roomData != null) {
              RoomPermissions.canRemoveFiles(_roomData!).then((canRemove) {
                if (canRemove) {
                  _showRemoveFileFromRoomDialog(file);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '❌ فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم إزالة الملفات',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            }
          });
        }
        break;
    }
  }

  /// ✅ عرض dialog لتأكيد إزالة الملف من الغرفة
  void _showRemoveFileFromRoomDialog(Map<String, dynamic> file) {
    final fileName =
        file['name']?.toString() ??
        file['originalName']?.toString() ??
        S.of(context).file;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).removeFileFromRoom),
        content: Text(S.of(context).removeFileFromRoomConfirm(fileName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _removeFileFromRoom(file);
            },
            child: Text(
              S.of(context).remove,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ حفظ الملف من الغرفة إلى حساب المستخدم
  Future<void> _saveFileFromRoom(Map<String, dynamic> file) async {
    if (widget.roomId == null) return;

    final fileId = file['originalData']?['_id'] ?? file['fileId'];
    if (fileId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ معرف الملف غير موجود'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // ✅ عرض dialog لاختيار المجلد (اختياري)
    final targetFolderId = await _showSaveFileDialog();

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 16),
                Text('جاري حفظ الملف...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.saveFileFromRoom(
        roomId: widget.roomId!,
        fileId: fileId,
        parentFolderId: targetFolderId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم حفظ الملف في حسابك بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل حفظ الملف'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✅ عرض dialog لاختيار المجلد لحفظ الملف
  Future<String?> _showSaveFileDialog() async {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _FolderNavigationDialog(
        title: 'اختر مجلد لحفظ الملف',
        excludeFolderId: null,
        excludeParentId: null,
        onSelect: (targetFolderId) {
          Navigator.pop(modalContext, targetFolderId);
        },
      ),
    );
  }

  /// ✅ إزالة الملف من الغرفة
  Future<void> _removeFileFromRoom(Map<String, dynamic> file) async {
    if (widget.roomId == null) return;

    final fileId = file['originalData']?['_id'] ?? file['fileId'];
    if (fileId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ معرف الملف غير موجود'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.unshareFileFromRoom(
        roomId: widget.roomId!,
        fileId: fileId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${S.of(context).fileRemovedFromRoom}'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ إعادة تحميل البيانات بعد إزالة الملف
          if (widget.onFileRemoved != null) {
            widget.onFileRemoved!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roomController.errorMessage ??
                    '❌ ${S.of(context).failedToRemoveFile}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✅ دالة لعرض dialog لاختيار المجلد الهدف لنقل الملف - نفس folder_contents_page.dart
  void _showMoveFileDialog(Map<String, dynamic> file) async {
    // ✅ حفظ context الأصلي قبل فتح الـ modal
    final scaffoldContext = context;

    final originalData = file['originalData'] ?? file;
    final fileId = originalData['_id']?.toString();
    final fileName =
        file['name'] as String? ?? originalData['name'] as String? ?? 'ملف';
    final currentParentId = originalData['parentFolderId']?.toString();

    if (fileId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text(S.of(context).fileIdNotFound)));
      }
      return;
    }

    if (!scaffoldContext.mounted) return;

    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _FolderNavigationDialog(
        title: 'نقل الملف: $fileName',
        excludeFolderId:
            null, // ✅ الملف ليس مجلداً، لذا لا نحتاج لاستبعاد أي مجلد
        excludeParentId:
            currentParentId, // ✅ استبعاد المجلد الحالي فقط (لتجنب النقل لنفس المكان)
        onSelect: (targetFolderId) {
          Navigator.pop(modalContext);
          if (scaffoldContext.mounted) {
            _moveFile(fileId, targetFolderId, fileName);
          }
        },
      ),
    );
  }

  /// ✅ دالة لنقل الملف
  Future<void> _moveFile(
    String fileId,
    String? targetFolderId,
    String fileName,
  ) async {
    if (!mounted) return;

    final fileController = Provider.of<FileController>(context, listen: false);
    final token = await StorageService.getToken();

    if (token == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text(S.of(context).movingFile),
          ],
        ),
        // duration: Duration(seconds: 30),
      ),
    );

    final success = await fileController.moveFile(
      fileId: fileId,
      token: token,
      targetFolderId: targetFolderId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${S.of(context).fileMovedSuccessfully}'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ إعادة تحميل البيانات إذا كان هناك callback
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fileController.errorMessage ??
                  '❌ ${S.of(context).failedToMoveFile}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return const Color(0xFF4CAF50);
      case 'video':
        return const Color(0xFFE91E63);
      case 'pdf':
        return const Color(0xFFF44336);
      case 'audio':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'audio':
        return Icons.audio_file_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).noFiles,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).startAddingFiles,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.files.length,
      shrinkWrap: true, // ✅ للسماح بالاستخدام داخل ScrollView
      physics: const NeverScrollableScrollPhysics(), // ✅ منع التمرير المزدوج
      // ✅ إعدادات cache للـ GridView لمنع إعادة التحميل عند Scroll
      cacheExtent: 500, // ✅ الاحتفاظ بـ 500 بكسل من الصور المحملة خارج الشاشة
      addAutomaticKeepAlives: true, // ✅ الاحتفاظ بالـ widgets محملة
      addRepaintBoundaries: true, // ✅ تحسين الأداء
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final file = widget.files[index];
        final fileName = file['name'] ?? 'ملف بدون اسم';
        final fileUrl = file['url'] ?? '';
        final fileType = file['type'] ?? 'file';
        final isOneTimeShare = file['isOneTimeShare'] == true;
        final fileId = file['originalData']?['_id']?.toString();
        final isStarred = fileId != null
            ? (_starStates[fileId] ??
                  file['originalData']?['isStarred'] ??
                  false)
            : (file['originalData']?['isStarred'] ?? false);

        // ✅ استخدام key مع fileId و isStarred و URL لضمان إعادة بناء الـ widget عند تغيير الصورة
        // ✅ إضافة URL إلى key لضمان إعادة بناء الـ widget عند تغيير URL (بعد التعديل)
        final fileUrlKey = fileUrl
            .split('?')
            .first; // ✅ استخدام URL بدون query params كجزء من key
        return KeyedSubtree(
          key: ValueKey('${fileId}_${isStarred}_$fileUrlKey'),
          child: _buildFileCard(
            fileType,
            fileUrl,
            fileName,
            file,
            isOneTimeShare,
          ),
        );
      },
    );
  }

  Widget _buildFileCard(
    String fileType,
    String fileUrl,
    String fileName,
    Map<String, dynamic> file,
    bool isOneTimeShare,
  ) {
    // ✅ الحصول على حالة النجمة من الـ state المحلي
    final fileId = file['originalData']?['_id'];
    // ✅ قراءة isStarred من _starStates أولاً (الأحدث)، ثم من originalData
    final cachedIsStarred = fileId != null ? _starStates[fileId] : null;
    final originalIsStarred = file['originalData']?['isStarred'];

    // ✅ استخدام _starStates أولاً (الأحدث من setState)، ثم originalData
    final isStarred = cachedIsStarred ?? originalIsStarred ?? false;

    // ✅ تحديث _starStates إذا كانت القيمة في originalData موجودة ومختلفة
    if (fileId != null &&
        originalIsStarred != null &&
        cachedIsStarred == null) {
      _starStates[fileId] = originalIsStarred;
    }

    return GestureDetector(
      onTap: () => widget.onFileTap?.call(file),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: widget.roomId != null && isOneTimeShare
                        ? _buildOneTimeShareIndicatorForSharedFiles(fileType)
                        : _buildFileContent(
                            fileType,
                            fileUrl,
                            fileName,
                            isOneTimeShare,
                          ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      itemBuilder: (context) {
                        // ✅ قائمة منفصلة للملفات المشتركة في الغرف
                        if (widget.roomId != null) {
                          return _buildSharedFileMenuItems(file, isStarred);
                        } else {
                          // ✅ قائمة الملفات العادية
                          return _buildNormalFileMenuItems(file, isStarred);
                        }
                      },
                      onSelected: (value) {
                        if (widget.roomId != null) {
                          _handleSharedFileMenuAction(value, file);
                        } else {
                          _handleMenuAction(value, file);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),
                  // ✅ عرض مؤشر "مشارك لمرة واحدة" لجميع الملفات المشتركة لمرة واحدة
                  if (file['isOneTimeShare'] == true) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_clock_rounded,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'مشارك لمرة واحدة',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  // ✅ عرض معلومات إضافية للملفات المشتركة في الروم
                  if (file['sharedBy'] != null ||
                      file['category'] != null ||
                      file['createdAt'] != null ||
                      (file['isOneTimeShare'] == true &&
                          file['shareStatus'] != null)) ...[
                    const SizedBox(height: 6),
                    // ✅ حالة الملف المشترك لمرة واحدة (لصاحب الملف فقط)
                    if (file['isOneTimeShare'] == true &&
                        file['shareStatus'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: file['shareStatus'] == 'viewed_by_all'
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                file['shareStatus'] == 'viewed_by_all'
                                    ? Icons.check_circle_outline
                                    : Icons.access_time,
                                size: 10,
                                color: file['shareStatus'] == 'viewed_by_all'
                                    ? Colors.green.shade700
                                    : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                file['shareStatus'] == 'viewed_by_all'
                                    ? S.of(context).viewedByAll
                                    : S.of(context).active,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: file['shareStatus'] == 'viewed_by_all'
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // ✅ معلومات إضافية لصاحب الملف (للملفات المشتركة لمرة واحدة)
                    if (file['isOneTimeShare'] == true &&
                        file['shareStatus'] != null) ...[
                      if (file['accessCount'] != null &&
                          file['accessCount'] > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 10,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${S.of(context).accessed}: ${file['accessCount']}${file['totalEligibleMembers'] != null ? ' / ${file['totalEligibleMembers']}' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (file['viewedByAllAt'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 10,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${S.of(context).completed}: ${_formatDate(file['viewedByAllAt'])}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    // ✅ التصنيف
                    if (file['category'] != null &&
                        file['category'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 11,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                file['category'].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // ✅ من شارك الملف
                    if (file['sharedBy'] != null &&
                        file['sharedBy'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 11,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${S.of(context).sharedBy}: ${file['sharedBy']}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // ✅ تاريخ الإنشاء
                    if (file['createdAt'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatDate(file['createdAt']),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // ✅ تاريخ التعديل
                    if (file['updatedAt'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 11,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${S.of(context).modified}: ${_formatDate(file['updatedAt'])}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFileContent(
    String fileType,
    String fileUrl,
    String fileName,
    bool isOneTimeShare,
  ) {
    // ✅ إذا كان الملف مشترك لمرة واحدة (صور وفيديو)، لا نعرض الصور المصغرة
    // ✅ نعرض أيقونة بدلاً من الصورة المصغرة
    if (isOneTimeShare &&
        (fileType.toLowerCase() == 'image' ||
            fileType.toLowerCase() == 'video')) {
      // ✅ عرض أيقونة مع نص "مشارك لمرة واحدة"
      return _buildOneTimeShareIndicator(fileType);
    }

    // ✅ إذا كان الملف مشترك في غرفة (shared file) وليس one-time share
    // ✅ نستخدم دالة منفصلة للملفات المشتركة
    if (widget.roomId != null && !isOneTimeShare) {
      // ✅ للملفات المشتركة في الغرف، نعرض المحتوى العادي
      switch (fileType.toLowerCase()) {
        case 'image':
          return _buildImageContent(fileUrl);
        case 'video':
          return _buildVideoContent(fileUrl, fileName);
        case 'pdf':
          return _buildIconContent(
            Icons.picture_as_pdf_rounded,
            const Color(0xFFF44336),
          );
        case 'audio':
          return _buildIconContent(
            Icons.audio_file_rounded,
            const Color(0xFF9C27B0),
          );
        default:
          return _buildIconContent(
            Icons.insert_drive_file_rounded,
            const Color(0xFF607D8B),
          );
      }
    }

    // ✅ للملفات الأخرى (PDF، صوت، نص، إلخ) نعرض الأيقونة العادية
    switch (fileType.toLowerCase()) {
      case 'image':
        return _buildImageContent(fileUrl);
      case 'video':
        return _buildVideoContent(fileUrl, fileName);
      case 'pdf':
        return _buildIconContent(
          Icons.picture_as_pdf_rounded,
          const Color(0xFFF44336),
        );
      case 'audio':
        return _buildIconContent(
          Icons.audio_file_rounded,
          const Color(0xFF9C27B0),
        );
      default:
        return _buildIconContent(
          Icons.insert_drive_file_rounded,
          const Color(0xFF607D8B),
        );
    }
  }

  /// ✅ بناء مؤشر للملفات المشتركة لمرة واحدة (للملفات العادية)
  Widget _buildOneTimeShareIndicator(String fileType) {
    IconData icon;
    Color color;

    switch (fileType.toLowerCase()) {
      case 'image':
        icon = Icons.image_rounded;
        color = Colors.blue;
        break;
      case 'video':
        icon = Icons.video_library_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ أيقونة الملف
          Icon(icon, size: 64, color: color.withOpacity(0.6)),
          const SizedBox(height: 12),
          // ✅ أيقونة المشاركة لمرة واحدة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade300, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_clock_rounded,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  'مشارك لمرة واحدة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ بناء مؤشر للملفات المشتركة لمرة واحدة (للملفات المشتركة في الغرف)
  Widget _buildOneTimeShareIndicatorForSharedFiles(String fileType) {
    IconData icon;
    Color color;

    switch (fileType.toLowerCase()) {
      case 'image':
        icon = Icons.image_rounded;
        color = Colors.blue;
        break;
      case 'video':
        icon = Icons.video_library_rounded;
        color = Colors.red;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        color = const Color(0xFFF44336);
        break;
      case 'audio':
        icon = Icons.audiotrack_rounded;
        color = Colors.purple;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        color = const Color(0xFF607D8B);
        break;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // ✅ حساب الأحجام بشكل responsive بناءً على المساحة المتاحة
          final availableHeight = constraints.maxHeight;
          final iconSize = availableHeight > 120
              ? 64.0
              : (availableHeight > 80 ? 48.0 : 40.0);
          final spacing = availableHeight > 120
              ? 12.0
              : (availableHeight > 80 ? 8.0 : 6.0);
          final padding = EdgeInsets.symmetric(
            horizontal: 12,
            vertical: availableHeight > 120
                ? 6.0
                : (availableHeight > 80 ? 4.0 : 3.0),
          );
          final fontSize = availableHeight > 120
              ? 11.0
              : (availableHeight > 80 ? 10.0 : 9.0);
          final iconBadgeSize = availableHeight > 120
              ? 16.0
              : (availableHeight > 80 ? 14.0 : 12.0);
          final verticalPadding = availableHeight > 120
              ? 16.0
              : (availableHeight > 80 ? 12.0 : 8.0);

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: verticalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ أيقونة الملف
                  Icon(icon, size: iconSize, color: color.withOpacity(0.6)),
                  SizedBox(height: spacing),
                  // ✅ أيقونة المشاركة لمرة واحدة
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth:
                            constraints.maxWidth -
                            16, // 16 = horizontal padding * 2
                      ),
                      padding: padding,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_clock_rounded,
                            size: iconBadgeSize,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'مشارك لمرة واحدة',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageContent(String url) {
    // ✅ التحقق من أن url هو URL أم مسار ملف محلي
    final isLocalFile = url.startsWith('/') || url.startsWith('file://');

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: isLocalFile ? _buildLocalImage(url) : _buildNetworkImage(url),
    );
  }

  Widget _buildLocalImage(String filePath) {
    final path = filePath.startsWith('file://')
        ? filePath.replaceFirst('file://', '')
        : filePath;
    final file = File(path);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey.shade50,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.data == true) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'فشل التحميل',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.grey.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'الملف غير موجود',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildNetworkImage(String url) {
    // ✅ إذا كان URL يحتوي على /api/ (endpoint)، نحتاج token
    final needsToken = url.contains('/api/');

    // ✅ إذا كان token مطلوباً ولم يكن موجوداً، نستخدم FutureBuilder
    if (needsToken && _cachedToken == null) {
      return FutureBuilder<String?>(
        future: () async {
          await _loadToken();
          return _cachedToken;
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.grey.shade50,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final token = snapshot.data ?? _cachedToken;
          return _buildCachedNetworkImage(
            url,
            token != null ? {'Authorization': 'Bearer $token'} : null,
          );
        },
      );
    }

    // ✅ استخدام token من cache مباشرة
    Map<String, String>? httpHeaders;
    if (needsToken && _cachedToken != null) {
      httpHeaders = {'Authorization': 'Bearer $_cachedToken'};
    }

    return _buildCachedNetworkImage(url, httpHeaders);
  }

  Widget _buildCachedNetworkImage(
    String url,
    Map<String, String>? httpHeaders,
  ) {
    // ✅ استخدام ValueKey دائماً بناءً على URL الكامل لضمان إعادة بناء الـ widget عند تغيير URL
    // ✅ هذا مهم جداً: بدون ValueKey، Flutter لا يعيد بناء الـ widget حتى لو تغير URL
    // ✅ ValueKey مع URL الكامل (مع timestamp) يضمن أن كل تحديث يتم إعادة بناء الـ widget
    final imageKey = ValueKey(url);

    // ✅ للصور: استخدام URL كامل مع timestamp كـ cacheKey
    // ✅ هذا يضمن أن كل تحديث يتم تحميله كصورة جديدة
    final cacheKey = url; // ✅ استخدام URL الكامل دائماً (يحتوي على timestamp)

    return CachedNetworkImage(
      key:
          imageKey, // ✅ إضافة key دائماً لضمان إعادة بناء الـ widget عند تغيير URL
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // ✅ إضافة headers إذا كان token مطلوباً
      httpHeaders: httpHeaders,
      // ✅ إعدادات Cache
      // ✅ للصور المشتركة: استخدام URL كامل مع timestamp كـ cacheKey
      // ✅ للصور غير المشتركة: استخدام URL بدون query parameters
      cacheKey: cacheKey,
      maxWidthDiskCache: 800, // ✅ تقليل حجم الصورة المحفوظة
      maxHeightDiskCache: 800,
      memCacheWidth: 400, // ✅ تحسين استخدام الذاكرة
      memCacheHeight: 400,
      fadeInDuration: const Duration(milliseconds: 200), // ✅ تأثير fade-in سلس
      fadeOutDuration: const Duration(milliseconds: 100),
      // ✅ إظهار placeholder فقط عند أول تحميل
      placeholder: (context, url) => Container(
        color: Colors.grey.shade50,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      // ✅ إظهار placeholder فوري من cache بدون إعادة تحميل
      placeholderFadeInDuration: const Duration(milliseconds: 100),
      errorWidget: (context, url, error) {
        print('❌ Error loading image: $error');
        print('❌ URL: $url');
        return Container(
          color: Colors.grey.shade50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'فشل التحميل',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoContent(String url, String fileName) {
    return FutureBuilder<String?>(
      future: _getVideoThumbnail(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey.shade50,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.file(
                  File(snapshot.data!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFE91E63),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return _buildIconContent(
            Icons.video_library_rounded,
            const Color(0xFFE91E63),
          );
        }
      },
    );
  }

  Widget _buildIconContent(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: color),
        ),
      ),
    );
  }

  // ✅ تنسيق التاريخ
  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }
}

// ✅ Widget للتنقل داخل المجلدات عند النقل - نفس folder_contents_page.dart
class _FolderNavigationDialog extends StatefulWidget {
  final String title;
  final String? excludeFolderId;
  final String? excludeParentId;
  final Function(String?) onSelect;

  const _FolderNavigationDialog({
    required this.title,
    this.excludeFolderId,
    this.excludeParentId,
    required this.onSelect,
  });

  @override
  State<_FolderNavigationDialog> createState() =>
      _FolderNavigationDialogState();
}

class _FolderNavigationDialogState extends State<_FolderNavigationDialog> {
  List<Map<String, dynamic>> _currentFolders = [];
  List<Map<String, String?>> _breadcrumb = []; // [{id: null, name: 'الجذر'}]
  bool _isLoading = false;
  String? _currentFolderId;

  @override
  void initState() {
    super.initState();
    _breadcrumb.add({'id': null, 'name': 'الجذر'});
    _loadRootFolders();
  }

  // ✅ جلب المجلدات الجذرية
  Future<void> _loadRootFolders() async {
    setState(() {
      _isLoading = true;
      _currentFolderId = null;
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      final response = await folderController.getAllFolders(
        page: 1,
        limit: 100,
      );

      if (response != null && response['folders'] != null) {
        final folders = List<Map<String, dynamic>>.from(
          response['folders'] ?? [],
        );

        // ✅ تصفية المجلدات المستبعدة
        final filteredFolders = folders.where((f) {
          final fId = f['_id']?.toString();
          return fId != widget.excludeFolderId && fId != widget.excludeParentId;
        }).toList();

        setState(() {
          _currentFolders = filteredFolders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentFolders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading root folders: $e');
      setState(() {
        _currentFolders = [];
        _isLoading = false;
      });
    }
  }

  // ✅ جلب المجلدات الفرعية لمجلد معين
  Future<void> _loadSubfolders(String folderId, String folderName) async {
    setState(() {
      _isLoading = true;
      _currentFolderId = folderId;
    });

    // ✅ إضافة المجلد إلى breadcrumb
    setState(() {
      _breadcrumb.add({'id': folderId, 'name': folderName});
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      // ✅ جلب جميع المجلدات الفرعية (limit كبير لضمان جلب جميع المجلدات)
      final response = await folderController.getFolderContents(
        folderId: folderId,
        page: 1,
        limit: 1000, // ✅ limit كبير لضمان جلب جميع المجلدات الفرعية
      );

      print('📁 Response for folder $folderId: ${response?.keys}');
      print('📁 Full response: $response');

      // ✅ محاولة جلب المجلدات الفرعية من response
      List<Map<String, dynamic>> subfolders = [];

      if (response != null) {
        // ✅ محاولة من subfolders مباشرة (الأولوية) - هذا يحتوي على جميع المجلدات الفرعية
        if (response['subfolders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['subfolders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from subfolders field',
          );
        }
        // ✅ إذا لم تكن موجودة، جرب من contents (لكن هذا قد يكون محدود بـ pagination)
        if (subfolders.isEmpty && response['contents'] != null) {
          final contents = List<Map<String, dynamic>>.from(
            response['contents'] ?? [],
          );
          subfolders = contents
              .where((item) => item['type'] == 'folder')
              .toList();
          print('📁 Found ${subfolders.length} subfolders from contents field');
        }

        // ✅ إذا لم نجد أي مجلدات، جرب من folders مباشرة (fallback)
        if (subfolders.isEmpty && response['folders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['folders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from folders field (fallback)',
          );
        }
      }

      print(
        '📁 Total found: ${subfolders.length} subfolders for folder $folderId ($folderName)',
      );

      // ✅ تصفية المجلدات المستبعدة
      final filteredFolders = subfolders.where((f) {
        final fId = f['_id']?.toString();
        return fId != widget.excludeFolderId && fId != widget.excludeParentId;
      }).toList();

      setState(() {
        _currentFolders = filteredFolders;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading subfolders: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      setState(() {
        _currentFolders = [];
        _isLoading = false;
      });

      // ✅ إظهار رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).errorLoadingSubfolders}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ العودة إلى مجلد سابق
  void _navigateToFolder(String? folderId) {
    if (folderId == null) {
      // ✅ العودة للجذر
      setState(() {
        _breadcrumb = [
          {'id': null, 'name': 'الجذر'},
        ];
      });
      _loadRootFolders();
    } else {
      // ✅ العودة لمجلد معين
      final index = _breadcrumb.indexWhere((b) => b['id'] == folderId);
      if (index >= 0) {
        setState(() {
          _breadcrumb = _breadcrumb.sublist(0, index + 1);
        });

        if (folderId == null) {
          _loadRootFolders();
        } else {
          final folderName = _breadcrumb.last['name'] ?? 'مجلد';
          _loadSubfolders(folderId, folderName);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.drive_file_move_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ✅ Breadcrumb
          if (_breadcrumb.length > 1)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _breadcrumb.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == _breadcrumb.length - 1;

                          return GestureDetector(
                            onTap: isLast
                                ? null
                                : () => _navigateToFolder(item['id']),
                            child: Row(
                              children: [
                                if (index > 0) ...[
                                  Icon(
                                    Icons.chevron_left,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                ],
                                Text(
                                  item['name'] ?? 'الجذر',
                                  style: TextStyle(
                                    color: isLast ? Colors.purple : Colors.blue,
                                    fontWeight: isLast
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    decoration: isLast
                                        ? null
                                        : TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Content
          Expanded(
            child: Column(
              children: [
                // ✅ خيار "اختيار الجذر" (إذا كنا في الجذر)
                if (_currentFolderId == null)
                  ListTile(
                    leading: Icon(Icons.home_rounded, color: Colors.blue),
                    title: Text(S.of(context).moveToRoot),
                    subtitle: Text(S.of(context).moveToRootDescription),
                    onTap: () => widget.onSelect(null),
                  ),
                // ✅ خيار "اختيار المجلد الحالي" (إذا كنا داخل مجلد)
                if (_currentFolderId != null)
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      '${S.of(context).selectFolder} "${_breadcrumb.last['name'] ?? S.of(context).folderNameHint}"',
                    ),
                    subtitle: Text(S.of(context).selectFolderDescription),
                    onTap: () => widget.onSelect(_currentFolderId),
                  ),
                // ✅ Divider بين الخيارات وقائمة المجلدات
                Divider(),

                // ✅ قائمة المجلدات
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _currentFolders.isEmpty
                      ? Center(
                          child: Text(
                            _currentFolderId == null
                                ? S.of(context).noFoldersAvailable
                                : S.of(context).noSubfolders,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _currentFolders.length,
                          itemBuilder: (context, index) {
                            final folder = _currentFolders[index];
                            final folderId = folder['_id']?.toString();
                            final folderName =
                                folder['name'] ?? 'مجلد بدون اسم';

                            return InkWell(
                              onTap: () {
                                // ✅ فتح المجلد لعرض المجلدات الفرعية
                                if (folderId != null) {
                                  print(
                                    '📂 Opening folder: $folderId ($folderName)',
                                  );
                                  _loadSubfolders(folderId, folderName);
                                } else {
                                  print(
                                    '⚠️ Folder ID is null for folder: $folderName',
                                  );
                                }
                              },
                              child: ListTile(
                                leading: Icon(
                                  Icons.folder_rounded,
                                  color: Colors.orange,
                                ),
                                title: Text(folderName),
                                subtitle: Text(
                                  '${folder['filesCount'] ?? 0} ملف',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ✅ زر اختيار المجلد (checkmark)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          // ✅ اختيار المجلد مباشرة
                                          widget.onSelect(folderId);
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // ✅ أيقونة chevron للإشارة إلى إمكانية فتح المجلد
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
