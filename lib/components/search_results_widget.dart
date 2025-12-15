import 'package:flutter/material.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/generated/l10n.dart';

/// Widget مشترك لعرض نتائج البحث (ملفات ومجلدات)
class SearchResultsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String? searchQuery;
  final bool isLoading;
  final bool isGridView;
  final Function(bool) onViewToggle;
  final Function(Map<String, dynamic>)? onFileTap;
  final Function(Map<String, dynamic>)? onFolderTap;

  const SearchResultsWidget({
    Key? key,
    required this.results,
    this.searchQuery,
    this.isLoading = false,
    this.isGridView = true,
    required this.onViewToggle,
    this.onFileTap,
    this.onFolderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(S.of(context).searching),
          ],
        ),
      );
    }

    if (results.isEmpty && searchQuery != null && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              ' "${S.of(context).noResultsFor}  $searchQuery "',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              S.of(context).tryDifferentKeywords,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              S.of(context).searchYourFiles,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // معلومات البحث
        Container(
          padding: EdgeInsets.all(16),
          color: AppColors.accent.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${S.of(context).foundText} ${results.length} ${S.of(context).resultWord}${searchQuery != null ? ' ${S.of(context).forSearch} "$searchQuery"' : ''}',
                  style: TextStyle(color: AppColors.accent, fontSize: 14),
                ),
              ),
              IconButton(
                icon: Icon(isGridView ? Icons.list : Icons.grid_view),
                onPressed: () => onViewToggle(!isGridView),
                tooltip: isGridView
                    ? S.of(context).tooltipListView
                    : S.of(context).tooltipGridView,
              ),
            ],
          ),
        ),
        // عرض النتائج
        Expanded(
          child: isGridView
              ? _buildSearchResultsGrid(context)
              : _buildSearchResultsList(context),
        ),
      ],
    );
  }

  Widget _buildSearchResultsGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildSearchResultCard(context, item);
      },
    );
  }

  Widget _buildSearchResultsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSearchResultCard(context, item, isList: true),
        );
      },
    );
  }

  Widget _buildSearchResultCard(
    BuildContext context,
    Map<String, dynamic> item, {
    bool isList = false,
  }) {
    final searchType =
        item['searchType']?.toString() ?? item['type']?.toString();
    final isFolder = searchType == 'folder' || item['category'] != null;

    if (isFolder) {
      return _buildFolderCard(context, item, isList: isList);
    } else {
      return _buildFileCard(context, item, isList: isList);
    }
  }

  Widget _buildFolderCard(
    BuildContext context,
    Map<String, dynamic> folder, {
    bool isList = false,
  }) {
    final folderName =
        folder['title']?.toString() ??
        folder['name']?.toString() ??
        S.of(context).unnamedFolder;
    final folderType = folder['type']?.toString() ?? 'folder';
    final isCategory = folderType == 'category';

    return GestureDetector(
      onTap: () {
        if (onFolderTap != null) {
          onFolderTap!(folder);
        }
      },
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
        child: isList
            ? _buildFolderListCard(folderName, isCategory)
            : _buildFolderGridCard(folderName, isCategory),
      ),
    );
  }

  Widget _buildFolderGridCard(String folderName, bool isCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                isCategory ? Icons.category : Icons.folder,
                size: 48,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            folderName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderListCard(String folderName, bool isCategory) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              isCategory ? Icons.category : Icons.folder,
              size: 32,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            folderName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(
    BuildContext context,
    Map<String, dynamic> file, {
    bool isList = false,
  }) {
    final fileName = file['name']?.toString() ?? S.of(context).unnamedfile;
    final filePath = file['path']?.toString() ?? '';
    final fileId = file['_id']?.toString() ?? file['id']?.toString();
    final fileType = _getFileType(fileName);
    final fileSize = _formatSize(file['size']);
    final createdAt = file['createdAt'];
    final category = file['category']?.toString();
    final isStarred = file['isStarred'] ?? false;

    // بناء URL
    String fileUrl;
    if (filePath.isNotEmpty) {
      fileUrl = _getFileUrl(filePath);
    } else if (fileId != null && fileId.isNotEmpty) {
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final downloadPath = ApiEndpoints.downloadFile(fileId);
      fileUrl = "$baseUrl$downloadPath";
    } else {
      fileUrl = '';
    }

    return GestureDetector(
      onTap: () {
        if (onFileTap != null) {
          onFileTap!(file);
        } else {
          _handleFileTap(context, file);
        }
      },
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
        child: isList
            ? _buildListCard(
                fileName,
                fileType,
                fileUrl,
                fileSize,
                createdAt,
                category,
                isStarred,
              )
            : _buildGridCard(
                fileName,
                fileType,
                fileUrl,
                fileSize,
                createdAt,
                category,
                isStarred,
              ),
      ),
    );
  }

  Widget _buildGridCard(
    String fileName,
    String fileType,
    String fileUrl,
    String fileSize,
    dynamic createdAt,
    String? category,
    bool isStarred,
  ) {
    return Column(
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
                child: _buildFilePreview(fileType, fileUrl, fileName),
              ),
              if (isStarred)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
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
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 11,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDate(createdAt),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(
    String fileName,
    String fileType,
    String fileUrl,
    String fileSize,
    dynamic createdAt,
    String? category,
    bool isStarred,
  ) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildFilePreview(fileType, fileUrl, fileName),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (isStarred)
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.insert_drive_file,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fileSize,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview(String fileType, String fileUrl, String fileName) {
    switch (fileType.toLowerCase()) {
      case 'image':
        if (fileUrl.isNotEmpty) {
          final needsToken = fileUrl.contains('/api/');
          return FutureBuilder<Map<String, String>?>(
            future: needsToken ? _getImageHeaders() : Future.value(null),
            builder: (context, snapshot) {
              return CachedNetworkImage(
                imageUrl: fileUrl,
                fit: BoxFit.cover,
                httpHeaders: snapshot.data,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                ),
              );
            },
          );
        }
        return _buildFileIcon(Icons.image, Colors.blue);
      case 'pdf':
        return _buildFileIcon(Icons.picture_as_pdf, Colors.red);
      case 'video':
        return _buildFileIcon(Icons.video_library, Colors.purple);
      case 'audio':
        return _buildFileIcon(Icons.audiotrack, Colors.orange);
      default:
        return _buildFileIcon(Icons.insert_drive_file, Colors.grey);
    }
  }

  Widget _buildFileIcon(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: color),
        ),
      ),
    );
  }

  String _getFileType(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return 'pdf';
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif'))
      return 'image';
    if (name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.mkv'))
      return 'video';
    if (name.endsWith('.mp3') || name.endsWith('.wav') || name.endsWith('.m4a'))
      return 'audio';
    return 'file';
  }

  String _formatSize(dynamic size) {
    if (size == null) return '—';
    try {
      final bytes = size is int ? size : int.tryParse(size.toString()) ?? 0;
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1073741824)
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } catch (e) {
      return '—';
    }
  }

  Future<Map<String, String>?> _getImageHeaders() async {
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return null;
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }

  String _getFileUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }

    String cleanPath = path.replaceAll(r'\', '/').replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    String baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    String finalUrl = '$baseClean/$cleanPath';

    return finalUrl;
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool _isValidPdf(List<int> bytes) {
    try {
      if (bytes.length < 4) return false;
      final signature = String.fromCharCodes(bytes.sublist(0, 4));
      return signature == '%PDF';
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleFileTap(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    String? filePath = file['path'] as String?;
    String? fileId = file['_id']?.toString() ?? file['id']?.toString();

    String url;
    if ((filePath == null || filePath.isEmpty) &&
        (fileId != null && fileId.isNotEmpty)) {
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final downloadPath = ApiEndpoints.downloadFile(fileId);
      url = "$baseUrl$downloadPath";
    } else if (filePath != null && filePath.isNotEmpty) {
      url = _getFileUrl(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileLinkNotAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isValidUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).invalidLink),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fileName = file['name']?.toString() ?? S.of(context).unnamedfile;
    final name = fileName.toLowerCase();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).mustLoginFirst),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Range': 'bytes=0-511'},
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.bodyBytes;
        final isPdf = _isValidPdf(bytes);
        final contentType =
            response.headers['content-type']?.toLowerCase() ?? '';

        bool isImageFile() {
          return name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.png') ||
              name.endsWith('.gif') ||
              name.endsWith('.bmp') ||
              name.endsWith('.webp') ||
              contentType.startsWith('image/');
        }

        bool isVideoFile() {
          return name.endsWith('.mp4') ||
              name.endsWith('.mov') ||
              name.endsWith('.mkv') ||
              name.endsWith('.avi') ||
              name.endsWith('.wmv') ||
              contentType.startsWith('video/');
        }

        bool isAudioFile() {
          return name.endsWith('.mp3') ||
              name.endsWith('.wav') ||
              name.endsWith('.m4a') ||
              name.endsWith('.aac') ||
              contentType.startsWith('audio/');
        }

        if (name.endsWith('.pdf') && isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
            ),
          );
        } else if (isVideoFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        } else if (isImageFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: url, fileId: fileId ?? ''),
            ),
          );
        } else if (TextViewerPage.isTextFile(fileName) ||
            contentType.startsWith('text/')) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: CircularProgressIndicator()),
          );
          try {
            final fullResponse = await http.get(
              Uri.parse(url),
              headers: {'Authorization': 'Bearer $token'},
            );
            if (!context.mounted) return;
            Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(fullResponse.bodyBytes);

              // ✅ استخراج fileId من بيانات الملف
              final fileId = file['_id']?.toString() ?? file['id']?.toString();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TextViewerPage(
                    filePath: tempFile.path,
                    fileName: fileName,
                    fileId: fileId,
                    fileUrl: url,
                  ),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    S.of(context).errorLoadingTextFile(e.toString()),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else if (isAudioFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: fileName),
            ),
          );
        } else {
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: token,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).fileNotAvailableError('${response.statusCode}'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorLoadingFile(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
