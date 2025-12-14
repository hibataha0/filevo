import 'package:flutter/material.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/api_endpoints.dart';

/// ✅ Widget لعرض نتائج البحث (مجلدات + ملفات)
class SearchResultsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filteredFolders;
  final List<Map<String, dynamic>> searchFilesResults;
  final bool isSearchLoadingFiles;
  final bool isFilesGridView;
  final Function(bool) onViewChanged;
  final Function(Map<String, dynamic>) onFolderTap;
  final Function(Map<String, dynamic>) onFileTap;
  final Function() onFileRemoved;
  final Function(String) getFileUrlForSearch;
  final Function(String) getFileTypeForSearch;
  final Function(int) formatBytesForSearch;

  const SearchResultsWidget({
    Key? key,
    required this.filteredFolders,
    required this.searchFilesResults,
    required this.isSearchLoadingFiles,
    required this.isFilesGridView,
    required this.onViewChanged,
    required this.onFolderTap,
    required this.onFileTap,
    required this.onFileRemoved,
    required this.getFileUrlForSearch,
    required this.getFileTypeForSearch,
    required this.formatBytesForSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ فصل الملفات عن المجلدات
    final searchFiles = <Map<String, dynamic>>[];
    final searchFolders = <Map<String, dynamic>>[];

    // ✅ إضافة المجلدات والتصنيفات
    try {
      searchFolders.addAll(
        filteredFolders.map((folder) {
          return {
            ...folder,
            'title':
                folder['title']?.toString() ?? folder['name']?.toString() ?? '',
            'type': folder['type']?.toString() ?? 'folder',
          };
        }),
      );
    } catch (e) {
      print('❌ Error adding folders to search results: $e');
    }

    // ✅ تحويل الملفات إلى format مناسب لـ FilesGrid
    try {
      searchFiles.addAll(
        searchFilesResults.map((file) {
          final fileName = file['name']?.toString() ?? 'ملف بدون اسم';
          final filePath = file['path']?.toString() ?? '';
          final fileId = file['_id']?.toString() ?? file['id']?.toString();
          final size = file['size'];

          // ✅ بناء URL للصورة
          String imageUrl;
          if (fileId != null && fileId.isNotEmpty) {
            final baseUrl = ApiConfig.baseUrl;
            final viewPath = ApiEndpoints.viewFile(fileId);
            imageUrl = "$baseUrl$viewPath";
          } else if (filePath.isNotEmpty && filePath.trim().isNotEmpty) {
            imageUrl = getFileUrlForSearch(filePath.trim());
          } else {
            imageUrl = '';
          }

          // ✅ بناء originalData مع جميع الحقول من الباك إند
          final originalData = {
            ...file,
            '_id': fileId,
            'name': fileName,
            'path': filePath,
            'size': size,
            'relevanceScore': file['relevanceScore'] ?? 0.0,
            'searchType': file['searchType'] ?? 'text',
            'imageDescription': file['imageDescription'],
            'imageObjects': file['imageObjects'] ?? [],
            'imageScene': file['imageScene'],
            'imageColors': file['imageColors'] ?? [],
            'imageMood': file['imageMood'],
            'imageText': file['imageText'],
            'audioTranscript': file['audioTranscript'],
            'videoTranscript': file['videoTranscript'],
            'videoScenes': file['videoScenes'] ?? [],
            'videoDescription': file['videoDescription'],
            'extractedText': file['extractedText'],
            'summary': file['summary'],
            'description': file['description'],
            'tags': file['tags'] ?? [],
          };

          return {
            'name': fileName,
            'url': imageUrl,
            'type': getFileTypeForSearch(fileName),
            'size': formatBytesForSearch(
              (size != null && size is int)
                  ? size
                  : (size != null && size is num)
                  ? size.toInt()
                  : 0,
            ),
            'createdAt': file['createdAt'],
            'path': filePath,
            'originalData': originalData,
            'originalName': fileName,
            '_id': fileId,
          };
        }),
      );
    } catch (e) {
      print('❌ Error adding files to search results: $e');
    }

    final totalResults = searchFiles.length + searchFolders.length;

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 25.0,
              tablet: 30.0,
              desktop: 35.0,
            ),
          ),
        ),
      ),
      color: const Color(0xFFE9E9E9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // ✅ معلومات البحث
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'نتائج البحث: $totalResults نتيجة',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 24.0,
                        tablet: 28.0,
                        desktop: 32.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff28336f),
                    ),
                  ),
                  ViewToggleButtons(
                    isGridView: isFilesGridView,
                    onViewChanged: onViewChanged,
                  ),
                ],
              ),
              SizedBox(height: 20),
              // ✅ عرض النتائج
              if (isSearchLoadingFiles && searchFilesResults.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (totalResults == 0)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد نتائج للبحث',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else ...[
                // ✅ عرض المجلدات أولاً
                if (searchFolders.isNotEmpty) ...[
                  Text(
                    'المجلدات (${searchFolders.length})',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 18.0,
                        tablet: 20.0,
                        desktop: 22.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff28336f),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (isFilesGridView)
                    FilesGridView(
                      items: searchFolders,
                      showFileCount: true,
                      onItemTap: onFolderTap,
                    )
                  else
                    FilesListView(
                      items: searchFolders,
                      itemMargin: EdgeInsets.only(bottom: 10),
                      showMoreOptions: true,
                      onItemTap: onFolderTap,
                    ),
                  SizedBox(height: 32),
                ],
                // ✅ عرض الملفات
                if (searchFiles.isNotEmpty) ...[
                  Text(
                    'الملفات (${searchFiles.length})',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 18.0,
                        tablet: 20.0,
                        desktop: 22.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff28336f),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (isFilesGridView)
                    FilesGrid(
                      files: searchFiles,
                      onFileTap: onFileTap,
                      onFileRemoved: onFileRemoved,
                    )
                  else
                    FilesListView(
                      items: searchFiles.map((f) {
                        return {
                          'title': f['name'] ?? 'ملف بدون اسم',
                          'size': f['size'] ?? '0 B',
                          'path': f['path'],
                          'createdAt': f['createdAt'],
                          'originalName': f['originalName'] ?? f['name'],
                          '_id': f['_id']?.toString(),
                          'originalData': f['originalData'] ?? f,
                        };
                      }).toList(),
                      itemMargin: const EdgeInsets.only(bottom: 10),
                      showMoreOptions: true,
                      onItemTap: (item) {
                        onFileTap(item['originalData'] ?? item);
                      },
                    ),
                ],
              ],
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}





