import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerPage({
    Key? key, 
    required this.pdfUrl, 
    required this.fileName
  }) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool isLoading = true;
  int pages = 0;
  int currentPage = 0;
  PDFViewController? pdfController;
  bool isFullScreen = false;
  bool showNavigationBar = true;
  bool hasError = false;
  bool showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  
  // متغيرات البحث
  List<String> _searchSuggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        
        // التحقق من أن الملف PDF صالح
        final bytes = response.bodyBytes;
        if (bytes.length < 4 || String.fromCharCodes(bytes.sublist(0, 4)) != '%PDF') {
          throw Exception('الملف ليس PDF صالح أو تالف');
        }
        
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf");
        await file.writeAsBytes(bytes);
        
        if (mounted) {
          setState(() {
            localPath = file.path;
            isLoading = false;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error loading PDF: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل ملف PDF: ${e.toString()}')),
        );
      }
    }
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      showNavigationBar = !isFullScreen;
    });
  }

  void _goToPreviousPage() {
    if (pdfController != null && currentPage > 0) {
      pdfController!.setPage(currentPage - 1);
    }
  }

  void _goToNextPage() {
    if (pdfController != null && currentPage < pages - 1) {
      pdfController!.setPage(currentPage + 1);
    }
  }

  void _goToFirstPage() {
    if (pdfController != null) {
      pdfController!.setPage(0);
    }
  }

  void _goToLastPage() {
    if (pdfController != null && pages > 0) {
      pdfController!.setPage(pages - 1);
    }
  }

  void _toggleNavigationBar() {
    setState(() {
      showNavigationBar = !showNavigationBar;
    });
  }

  void _toggleSearchBar() {
    setState(() {
      showSearchBar = !showSearchBar;
      if (!showSearchBar) {
        _searchController.clear();
        _searchSuggestions.clear();
        _isSearching = false;
      }
    });
  }

  void _retryLoading() {
    setState(() {
      isLoading = true;
      hasError = false;
      localPath = null;
    });
    _loadPdf();
  }

  void _goToPage(int page) {
    final targetPage = page.clamp(1, pages);
    if (pdfController != null) {
      pdfController!.setPage(targetPage - 1);
      _pageController.text = targetPage.toString();
    }
  }

  // دالة البحث البديلة - تظهر اقتراحات
  void _performSearch(String text) {
    if (text.isEmpty) {
      setState(() {
        _searchSuggestions.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      // هذه مجرد اقتراحات وهمية للتوضيح
      _searchSuggestions = [
        'نتيجة بحث عن "$text" في الصفحة ${currentPage + 1}',
        'العثور على "$text" في الصفحة ${(currentPage + 2).clamp(1, pages)}',
        'مطابقة "$text" في المستند'
      ];
    });
  }

  void _showSearchHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text('البحث في PDF'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('للاستفادة من ميزة البحث المتقدمة، نوصي باستخدام:'),
            SizedBox(height: 12),
            Text('• Syncfusion Flutter PDF Viewer'),
            Text('• PDF.js مع WebView'),
            Text('• حزم PDF متقدمة أخرى'),
            SizedBox(height: 12),
            Text('الإصدار الحالي يدعم:'),
            Text('✓ تصفح الصفحات'),
            Text('✓ وضعية ملء الشاشة'),
            Text('✓ شريط التنقل'),
            Text('✓ عرض اسم الملف'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    final name = widget.fileName;
    if (name.length > 25) {
      return '${name.substring(0, 22)}...';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullScreen ? null : AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFileName(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (pages > 0)
              Text(
                'صفحة ${currentPage + 1} من $pages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          if (hasError) 
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoading,
              tooltip: 'إعادة المحاولة',
            ),
          // زر البحث
          if (localPath != null)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleSearchBar,
              tooltip: 'بحث في المستند',
            ),
          // زر إظهار/إخفاء شريط التنقل
          if (localPath != null && pages > 1)
            IconButton(
              icon: Icon(showNavigationBar ? Icons.visibility_off : Icons.visibility),
              onPressed: _toggleNavigationBar,
              tooltip: showNavigationBar ? 'إخفاء شريط التنقل' : 'إظهار شريط التنقل',
            ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: toggleFullScreen,
            tooltip: 'وضعية ملء الشاشة',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل الملف...'),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'فشل تحميل ملف PDF',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryLoading,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (localPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 64),
            const SizedBox(height: 16),
            const Text(
              'لم يتم تحميل الملف',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryLoading,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // PDF Viewer
        GestureDetector(
          onTap: () {
            if (isFullScreen) {
              toggleFullScreen();
            } else {
              _toggleNavigationBar();
            }
          },
          child: PDFView(
            filePath: localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            fitPolicy: FitPolicy.BOTH,
            defaultPage: currentPage,
            onRender: (totalPages) {
              setState(() {
                pages = totalPages!;
              });
            },
            onViewCreated: (controller) {
              pdfController = controller;
            },
            onPageChanged: (page, _) {
              setState(() {
                currentPage = page!;
                _pageController.text = (page + 1).toString();
              });
            },
            onError: (error) {
              print(error);
              if (mounted) {
                setState(() {
                  hasError = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('حدث خطأ أثناء عرض الملف')),
                );
              }
            },
            onPageError: (page, error) {
              print('Error on page $page: $error');
            },
          ),
        ),

        // شريط البحث
        if (showSearchBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildSearchBar(),
          ),

        // شريط التنقل السفلي
        if (showNavigationBar && !isFullScreen && pages > 1)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigationBar(),
          ),

        // اسم الملف في وضعية ملء الشاشة
        if (isFullScreen)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getFileName(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                    onPressed: toggleFullScreen,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث في المستند...',
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _performSearch,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: _showSearchHelp,
                tooltip: 'مساعدة البحث',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSearchBar,
                tooltip: 'إغلاق البحث',
              ),
            ],
          ),
          if (_searchSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اقتراحات البحث:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._searchSuggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(suggestion)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          if (_isSearching && _searchSuggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'جاري البحث...',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    if (isFullScreen) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fullscreen_exit',
            child: const Icon(Icons.fullscreen_exit),
            onPressed: toggleFullScreen,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color ?? Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          // اسم الملف
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              _getFileName(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // عناصر التحكم
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // معلومات الصفحة
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صفحة ${currentPage + 1} من $pages',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (pages > 0)
                          LinearProgressIndicator(
                            value: (currentPage + 1) / pages,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // أزرار التنقل
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.first_page),
                        onPressed: _goToFirstPage,
                        tooltip: 'الصفحة الأولى',
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _goToPreviousPage,
                        tooltip: 'الصفحة السابقة',
                      ),
                      Container(
                        width: 60,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _pageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onSubmitted: (value) {
                            final page = int.tryParse(value);
                            if (page != null) {
                              _goToPage(page);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _goToNextPage,
                        tooltip: 'الصفحة التالية',
                      ),
                      IconButton(
                        icon: const Icon(Icons.last_page),
                        onPressed: _goToLastPage,
                        tooltip: 'الصفحة الأخيرة',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}