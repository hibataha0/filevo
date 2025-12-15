import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/generated/l10n.dart';

/// ✅ Widget لاختيار المجلد الهدف (للرفع أو الإنشاء)
class FolderSelectionDialog extends StatefulWidget {
  final String title;
  final String? excludeFolderId;
  final String? excludeParentId;
  final Function(String?) onSelect;

  const FolderSelectionDialog({
    Key? key,
    required this.title,
    this.excludeFolderId,
    this.excludeParentId,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<FolderSelectionDialog> createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends State<FolderSelectionDialog> {
  List<Map<String, dynamic>> _currentFolders = [];
  List<Map<String, String?>> _breadcrumb = []; // [{id: null, name: 'الجذر'}]
  bool _isLoading = false;
  String? _currentFolderId;

  @override
  void initState() {
    super.initState();
    _breadcrumb.add({'id': null, 'name': S.of(context).root});
    // ✅ تأخير بسيط لضمان أن الـ widget تم بناؤه بالكامل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRootFolders();
    });
  }

  // ✅ جلب المجلدات الجذرية
  Future<void> _loadRootFolders() async {
    if (!mounted) {
      print('⚠️ FolderSelectionDialog: Not mounted, skipping _loadRootFolders');
      return;
    }

    print('📁 FolderSelectionDialog: Loading root folders...');
    setState(() {
      _isLoading = true;
      _currentFolderId = null;
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      print('📁 FolderSelectionDialog: Calling getAllFolders...');
      final response = await folderController.getAllFolders(
        page: 1,
        limit: 100,
      );

      print('📁 FolderSelectionDialog: Response received: ${response != null}');
      if (response != null) {
        print('📁 FolderSelectionDialog: Response keys: ${response.keys}');
      }

      if (!mounted) {
        print('⚠️ FolderSelectionDialog: Not mounted after getAllFolders');
        return;
      }

      if (response != null && response['folders'] != null) {
        final folders = List<Map<String, dynamic>>.from(
          response['folders'] ?? [],
        );
        print('📁 FolderSelectionDialog: Found ${folders.length} folders');

        // ✅ تصفية المجلدات المستبعدة
        final filteredFolders = folders.where((f) {
          final fId = f['_id']?.toString();
          return fId != widget.excludeFolderId && fId != widget.excludeParentId;
        }).toList();

        print(
          '📁 FolderSelectionDialog: Filtered to ${filteredFolders.length} folders',
        );

        if (mounted) {
          setState(() {
            _currentFolders = filteredFolders;
            _isLoading = false;
          });
          print(
            '✅ FolderSelectionDialog: State updated with ${filteredFolders.length} folders',
          );
        }
      } else {
        print('⚠️ FolderSelectionDialog: No folders in response');
        if (mounted) {
          setState(() {
            _currentFolders = [];
            _isLoading = false;
          });
          print('✅ FolderSelectionDialog: State updated with empty folders');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error loading root folders: $e');
      print('❌ Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _currentFolders = [];
          _isLoading = false;
        });
        print('✅ FolderSelectionDialog: State updated after error');
      }
    }
  }

  // ✅ جلب المجلدات الفرعية لمجلد معين
  Future<void> _loadSubfolders(String folderId, String folderName) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentFolderId = folderId;
    });

    // ✅ إضافة المجلد إلى breadcrumb
    if (mounted) {
      setState(() {
        _breadcrumb.add({'id': folderId, 'name': folderName});
      });
    }

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      // ✅ جلب جميع المجلدات الفرعية بدون pagination (limit كبير)
      final response = await folderController.getFolderContents(
        folderId: folderId,
        page: 1,
        limit: 1000, // ✅ limit كبير لضمان جلب جميع المجلدات
      );

      if (!mounted) return;

      // ✅ محاولة جلب المجلدات الفرعية من response
      List<Map<String, dynamic>> subfolders = [];

      if (response != null) {
        // ✅ محاولة من subfolders مباشرة (الأولوية)
        if (response['subfolders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['subfolders'] ?? [],
          );
        }
        // ✅ محاولة من contents (إذا كان موجوداً)
        else if (response['contents'] != null) {
          final contents = List<Map<String, dynamic>>.from(
            response['contents'] ?? [],
          );
          subfolders = contents
              .where((item) => item['type'] == 'folder')
              .toList();
        }
      }

      // ✅ تصفية المجلدات المستبعدة
      final filteredFolders = subfolders.where((f) {
        final fId = f['_id']?.toString();
        return fId != widget.excludeFolderId && fId != widget.excludeParentId;
      }).toList();

      if (mounted) {
        setState(() {
          _currentFolders = filteredFolders;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading subfolders: $e');
      if (mounted) {
        setState(() {
          _currentFolders = [];
          _isLoading = false;
        });
      }
    }
  }

  // ✅ العودة إلى المجلد السابق
  void _navigateBack() {
    if (_breadcrumb.length <= 1) return; // ✅ لا يمكن العودة من الجذر

    setState(() {
      _breadcrumb.removeLast();
      final previousBreadcrumb = _breadcrumb.last;
      final previousId = previousBreadcrumb['id'];

      if (previousId == null) {
        _loadRootFolders();
      } else {
        // ✅ نحتاج اسم المجلد السابق - يمكننا حفظه في breadcrumb
        final previousName = previousBreadcrumb['name'] ?? S.of(context).folder;
        _loadSubfolders(previousId, previousName);
      }
    });
  }

  // ✅ اختيار المجلد الهدف
  void _selectFolder(String? folderId, String folderName) {
    print(
      '📁 FolderSelectionDialog: Selecting folder: $folderId ($folderName)',
    );
    // ✅ استدعاء callback أولاً
    widget.onSelect(folderId);
    // ✅ ثم إغلاق الـ dialog وإرجاع القيمة
    if (mounted) {
      final valueToReturn = folderId ?? 'ROOT';
      print('📁 FolderSelectionDialog: Returning value: $valueToReturn');
      Navigator.of(context).pop(valueToReturn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ✅ Header مع breadcrumb
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          print(
                            '📁 FolderSelectionDialog: Close button pressed',
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  // ✅ Breadcrumb
                  if (_breadcrumb.length > 1)
                    Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _breadcrumb.length,
                        itemBuilder: (context, index) {
                          final item = _breadcrumb[index];
                          final isLast = index == _breadcrumb.length - 1;
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: isLast
                                    ? null
                                    : () {
                                        // ✅ العودة إلى هذا المستوى
                                        while (_breadcrumb.length > index + 1) {
                                          _breadcrumb.removeLast();
                                        }
                                        if (index == 0) {
                                          _loadRootFolders();
                                        } else {
                                          final prevItem =
                                              _breadcrumb[index - 1];
                                          final prevId = prevItem['id'];
                                          if (prevId == null) {
                                            _loadRootFolders();
                                          } else {
                                            _loadSubfolders(
                                              prevId,
                                              prevItem['name'] ??
                                                  S.of(context).folder,
                                            );
                                          }
                                        }
                                      },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLast
                                        ? Colors.blue[100]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['name'] ?? S.of(context).root,
                                    style: TextStyle(
                                      color: isLast
                                          ? Colors.blue[900]
                                          : Colors.grey[700],
                                      fontWeight: isLast
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            // ✅ قائمة المجلدات
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            S.of(context).loadingFolders,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : _currentFolders.isEmpty
                  ? Column(
                      children: [
                        // ✅ خيار اختيار الجذر (إذا كنا في الجذر ولا توجد مجلدات)
                        if (_currentFolderId == null) ...[
                          ListTile(
                            leading: Icon(
                              Icons.home_rounded,
                              color: Colors.blue,
                            ),
                            title: Text(S.of(context).root),
                            subtitle: Text(S.of(context).uploadCreateInRoot),
                            onTap: () {
                              print(
                                '📁 FolderSelectionDialog: Root selected (empty folders)',
                              );
                              _selectFolder(null, S.of(context).root);
                            },
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                            ),
                          ),
                          Divider(),
                        ],
                        // ✅ خيار اختيار المجلد الحالي (إذا كنا داخل مجلد فرعي)
                        if (_currentFolderId != null &&
                            _breadcrumb.length > 1) ...[
                          ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text(
                              S
                                  .of(context)
                                  .selectFolderName(
                                    _breadcrumb.last['name'] ??
                                        S.of(context).folder,
                                  ),
                            ),
                            subtitle: Text(
                              S.of(context).uploadCreateInThisFolder,
                            ),
                            onTap: () {
                              final currentFolder = _breadcrumb.last;
                              final currentFolderId = currentFolder['id'];
                              final currentFolderName =
                                  currentFolder['name'] ?? S.of(context).folder;
                              print(
                                '📁 FolderSelectionDialog: Current folder selected (empty subfolders): $currentFolderId ($currentFolderName)',
                              );
                              if (currentFolderId != null &&
                                  currentFolderId.toString().isNotEmpty) {
                                _selectFolder(
                                  currentFolderId.toString(),
                                  currentFolderName,
                                );
                              }
                            },
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          Divider(),
                        ],
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _currentFolderId == null
                                      ? S.of(context).noRootFolders
                                      : S.of(context).noSubfolders,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 8),
                                if (_currentFolderId == null)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                    ),
                                    child: Text(
                                      S.of(context).uploadToRootHint,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  TextButton(
                                    onPressed: () {
                                      // ✅ إعادة تحميل المجلدات الفرعية للمجلد الحالي
                                      final currentFolder = _breadcrumb.last;
                                      _loadSubfolders(
                                        _currentFolderId!,
                                        currentFolder['name'] ??
                                            S.of(context).folder,
                                      );
                                    },
                                    child: Text(S.of(context).retry),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount:
                          _currentFolders.length +
                          2, // +1 للجذر +1 للمجلد الحالي (إذا كنا داخل مجلد)
                      itemBuilder: (context, index) {
                        // ✅ خيار "الجذر" في البداية
                        if (index == 0) {
                          return ListTile(
                            leading: Icon(
                              Icons.home_rounded,
                              color: Colors.blue,
                            ),
                            title: Text(S.of(context).root),
                            subtitle: Text(S.of(context).uploadCreateInRoot),
                            onTap: () {
                              print('📁 FolderSelectionDialog: Root selected');
                              _selectFolder(null, S.of(context).root);
                            },
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                            ),
                          );
                        }

                        // ✅ خيار اختيار المجلد الحالي (إذا كنا داخل مجلد فرعي)
                        if (index == 1 &&
                            _currentFolderId != null &&
                            _breadcrumb.length > 1) {
                          final currentFolder = _breadcrumb.last;
                          final currentFolderId = currentFolder['id'];
                          final currentFolderName =
                              currentFolder['name'] ?? S.of(context).folder;

                          return ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text(
                              S.of(context).selectFolderName(currentFolderName),
                            ),
                            subtitle: Text(
                              S.of(context).uploadCreateInThisFolder,
                            ),
                            onTap: () {
                              print(
                                '📁 FolderSelectionDialog: Current folder selected: $currentFolderId ($currentFolderName)',
                              );
                              if (currentFolderId != null &&
                                  currentFolderId.isNotEmpty) {
                                _selectFolder(
                                  currentFolderId,
                                  currentFolderName,
                                );
                              }
                            },
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          );
                        }

                        // ✅ تعديل الفهرس للمجلدات (إذا كان هناك خيار المجلد الحالي)
                        final folderIndex =
                            (_currentFolderId != null && _breadcrumb.length > 1)
                            ? index - 2
                            : index - 1;

                        // ✅ التحقق من أن الفهرس صحيح
                        if (folderIndex < 0 ||
                            folderIndex >= _currentFolders.length) {
                          return SizedBox.shrink();
                        }

                        final folder = _currentFolders[folderIndex];
                        final folderId = folder['_id']?.toString();
                        final folderName =
                            folder['name']?.toString() ??
                            S.of(context).unnamedFolder;

                        print(
                          '📁 FolderSelectionDialog: Building folder item: $folderId ($folderName)',
                        );
                        print(
                          '📁 FolderSelectionDialog: Folder data keys: ${folder.keys.toList()}',
                        );
                        print(
                          '📁 FolderSelectionDialog: Folder _id type: ${folder['_id']?.runtimeType}',
                        );
                        print(
                          '📁 FolderSelectionDialog: Folder _id value: ${folder['_id']}',
                        );

                        return ListTile(
                          leading: Icon(
                            Icons.folder_rounded,
                            color: Colors.orange,
                          ),
                          title: Text(folderName),
                          subtitle: Text(
                            '${folder['filesCount'] ?? 0} ${S.of(context).file}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ✅ زر اختيار المجلد مباشرة
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  print(
                                    '📁 FolderSelectionDialog: Folder selected via check button: $folderId ($folderName)',
                                  );
                                  if (folderId != null && folderId.isNotEmpty) {
                                    _selectFolder(folderId, folderName);
                                  } else {
                                    print(
                                      '⚠️ FolderSelectionDialog: folderId is null or empty!',
                                    );
                                  }
                                },
                                tooltip: S.of(context).selectFolderTooltip,
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            // ✅ عند الضغط على المجلد، نفتحه لعرض المجلدات الفرعية
                            print(
                              '📁 FolderSelectionDialog: Opening folder: $folderId ($folderName)',
                            );
                            if (folderId != null && folderId.isNotEmpty) {
                              _loadSubfolders(folderId, folderName);
                            }
                          },
                          onLongPress: () {
                            // ✅ عند الضغط الطويل، نختار المجلد مباشرة
                            print(
                              '📁 FolderSelectionDialog: Folder selected via long press: $folderId ($folderName)',
                            );
                            if (folderId != null && folderId.isNotEmpty) {
                              _selectFolder(folderId, folderName);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
