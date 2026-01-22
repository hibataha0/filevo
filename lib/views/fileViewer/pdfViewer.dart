import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/services/screen_protection_service.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String fileName;
  final bool isOneTimeShare; // ✅ للملفات المشتركة لمرة واحدة

  const PdfViewerPage({
    Key? key,
    required this.pdfUrl,
    required this.fileName,
    this.isOneTimeShare = false,
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
  WebViewController? webViewController;
  bool isFullScreen = false;
  bool showNavigationBar = true;
  bool hasError = false;
  bool showSearchBar = false;
  bool useWebView = false; // ✅ خيار استخدام WebView للعرض المباشر
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  // متغيرات البحث
  List<String> _searchSuggestions = [];
  bool _isSearching = false;

  // ✅ متغيرات عرض النص والتظليل
  bool _showTextMode = false; // عرض النص بدلاً من PDF
  String _extractedText = ''; // النص المستخرج من PDF
  bool _isExtractingText = false;
  List<TextRange> _highlightedRanges = []; // النطاقات المظللة
  TextSelection? _currentSelection; // التحديد الحالي
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ تفعيل الحماية من السكرين شوت والريكورد للملفات المشتركة لمرة واحدة
    if (widget.isOneTimeShare) {
      ScreenProtectionService.enableProtection();
    }
    _loadPdf();
  }

  @override
  void dispose() {
    // ✅ إلغاء تفعيل الحماية عند إغلاق المشاهد
    if (widget.isOneTimeShare) {
      ScreenProtectionService.disableProtection();
    }
    _searchController.dispose();
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf({bool preferWebView = false}) async {
    try {
      print('📄 Loading PDF from: ${widget.pdfUrl}');

      // ✅ إذا كان preferWebView = true (مثل عند البحث)، استخدم WebView مباشرة
      if (preferWebView) {
        print('🌐 Using WebView directly for search support...');
        if (mounted) {
          setState(() {
            useWebView = true;
            isLoading = false;
          });
          _initializeWebView();
          return;
        }
      }

      // ✅ التحقق من أن pdfUrl هو مسار ملف محلي أم URL
      final isLocalFile =
          widget.pdfUrl.startsWith('/') ||
          widget.pdfUrl.startsWith('file://') ||
          !widget.pdfUrl.startsWith('http');

      if (isLocalFile && !widget.pdfUrl.startsWith('http')) {
        // ✅ مسار ملف محلي - استخدمه مباشرة
        print('📁 Using local file path: ${widget.pdfUrl}');
        final file = File(
          widget.pdfUrl.startsWith('file://')
              ? widget.pdfUrl.replaceFirst('file://', '')
              : widget.pdfUrl,
        );

        if (await file.exists()) {
          if (mounted) {
            setState(() {
              localPath = file.path;
              isLoading = false;
            });
          }
          return;
        } else {
          throw Exception(S.of(context).localFileNotFound(file.path));
        }
      }

      // ✅ تحميل PDF من URL
      print('📥 Downloading PDF from URL to local storage...');

      // ✅ الحصول على التوكن وإضافته إلى الـ headers
      final token = await StorageService.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('✅ [PdfViewer] Token added to request headers');
      } else {
        print('⚠️ [PdfViewer] No token found, request may fail');
      }

      final response = await http
          .get(Uri.parse(widget.pdfUrl), headers: headers)
          .timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        // ✅ التحقق من أن الملف PDF صالح
        final bytes = response.bodyBytes;
        if (bytes.length < 4) {
          throw Exception(S.of(context).invalidPdfFile);
        }

        final signature = String.fromCharCodes(bytes.sublist(0, 4));
        if (signature != '%PDF') {
          print('⚠️ File signature: $signature (expected %PDF)');
          print('⚠️ File may not be a valid PDF, attempting to open anyway...');
          // ✅ قد يكون الملف مشفر أو في صيغة خاصة
        } else {
          print('✅ PDF signature verified: %PDF');

          // ✅ التحقق الإضافي من صحة PDF (قراءة بعض البيانات)
          try {
            // ✅ محاولة قراءة version من البايتات (عادة في السطر الأول)
            final header = String.fromCharCodes(bytes.sublist(0, 100));
            if (!header.contains('PDF-')) {
              print('⚠️ PDF header may be invalid');
            }
          } catch (e) {
            print('⚠️ Could not verify PDF header: $e');
          }
        }

        final dir = await getTemporaryDirectory();
        final file = File(
          "${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf",
        );
        await file.writeAsBytes(bytes);

        print(
          '✅ PDF downloaded successfully to: ${file.path} (${bytes.length} bytes)',
        );

        if (mounted) {
          setState(() {
            localPath = file.path;
            useWebView = false;
            isLoading = false;
          });
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print("❌ Error loading PDF: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).failedToLoadPdfFile(e.toString())),
            action: SnackBarAction(
              label: S.of(context).retry,
              onPressed: _retryLoading,
            ),
          ),
        );
      }
    }
  }

  // ✅ محاولة استخدام WebView كـ fallback عند فشل flutter_pdfview
  Future<void> _tryWebViewFallback() async {
    try {
      print('🌐 Trying WebView fallback for PDF...');
      if (mounted) {
        setState(() {
          isLoading = true;
          hasError = false;
          useWebView = true;
        });
        _initializeWebView();
      }
    } catch (e) {
      print('❌ WebView fallback failed: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
          useWebView = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).failedToOpenFile(e.toString())),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: S.of(context).retry,
              onPressed: _retryLoading,
            ),
          ),
        );
      }
    }
  }

  void _initializeWebView() async {
    // ✅ تحميل PDF محلياً أولاً (مع التوكن) ثم عرضه في WebView
    // ✅ هذا ضروري لأن PDF.js لا يمكنه إرسال Authorization headers
    print('🌐 Initializing WebView - downloading PDF first...');

    try {
      // ✅ الحصول على التوكن وإضافته إلى الـ headers
      final token = await StorageService.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('✅ [PdfViewer] Token added to WebView download headers');
      } else {
        print('⚠️ [PdfViewer] No token found for WebView download');
      }

      // ✅ تحميل PDF محلياً
      final response = await http
          .get(Uri.parse(widget.pdfUrl), headers: headers)
          .timeout(Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final localFile = File(
        "${dir.path}/webview_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );
      await localFile.writeAsBytes(bytes);

      print('✅ PDF downloaded for WebView: ${localFile.path}');

      // ✅ استخدام الملف المحلي في WebView
      final localFileUrl = 'file://${localFile.path}';
      final encodedUrl = Uri.encodeComponent(localFileUrl);

      // ✅ استخدام نسخة مستقرة من PDF.js من CDN
      // ✅ إضافة #toolbar=0 لإخفاء شريط الأدوات الافتراضي
      final pdfJsUrl =
          'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encodedUrl#toolbar=0';

      print('🌐 Initializing WebView with PDF.js');
      print('  - Local PDF path: ${localFile.path}');
      print('  - PDF.js URL: $pdfJsUrl');

      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  isLoading = progress < 100;
                });
              }
            },
            onPageStarted: (String url) {
              print('📄 WebView page started: $url');
              if (mounted) {
                setState(() {
                  isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              print('✅ WebView page finished: $url');
              if (mounted) {
                setState(() {
                  isLoading = false;
                });

                // ✅ التأكد من أن PDF.js جاهز
                webViewController?.runJavaScript('''
                (function() {
                  if (window.PDFViewerApplication) {
                    console.log('PDF.js is ready');
                  } else {
                    console.log('Waiting for PDF.js...');
                    setTimeout(function() {
                      if (window.PDFViewerApplication) {
                        console.log('PDF.js loaded');
                      }
                    }, 1000);
                  }
                })();
              ''');
              }
            },
            onWebResourceError: (WebResourceError error) {
              print(
                '❌ WebView Error: ${error.description} (Code: ${error.errorCode})',
              );
              // ✅ إذا فشل WebView، حاول التحميل المحلي
              if (mounted && error.errorCode != -3) {
                // -3 = navigation cancelled
                _fallbackToLocalDownload();
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(pdfJsUrl));
    } catch (e) {
      print('❌ Error initializing WebView: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).failedToLoadPdfForDisplay(e.toString()),
            ),
            action: SnackBarAction(
              label: S.of(context).retry,
              onPressed: () {
                _initializeWebView();
              },
            ),
          ),
        );
      }
    }
  }

  // ✅ Fallback: تحميل PDF محلياً إذا فشل WebView
  Future<void> _fallbackToLocalDownload() async {
    print('📥 Falling back to local download...');
    try {
      // ✅ الحصول على التوكن وإضافته إلى الـ headers
      final token = await StorageService.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('✅ [PdfViewer] Token added to fallback request headers');
      } else {
        print('⚠️ [PdfViewer] No token found for fallback request');
      }

      final response = await http
          .get(Uri.parse(widget.pdfUrl), headers: headers)
          .timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File(
          "${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf",
        );
        await file.writeAsBytes(bytes);

        if (mounted) {
          setState(() {
            localPath = file.path;
            useWebView = false;
            isLoading = false;
            hasError = false;
          });
        }
      }
    } catch (e) {
      print('❌ Fallback download failed: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
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

  /// ✅ تبديل بين عرض PDF وعرض النص
  Future<void> _toggleTextMode() async {
    if (!_showTextMode) {
      // ✅ تحويل إلى وضع النص - استخراج النص من PDF
      await _extractTextFromPdf();
    }
    setState(() {
      _showTextMode = !_showTextMode;
    });
  }

  /// ✅ استخراج النص من PDF
  Future<void> _extractTextFromPdf() async {
    if (_extractedText.isNotEmpty) {
      return; // ✅ النص مستخرج بالفعل
    }

    if (localPath == null) return;

    setState(() {
      _isExtractingText = true;
    });

    try {
      // ✅ ملاحظة: حزمة pdf لا تدعم استخراج النص مباشرة
      // سنستخدم طريقة بديلة - عرض الملف كـ text selectable
      // يمكن استخدام مكتبة أخرى مثل pdf_text أو syncfusion_pdf

      setState(() {
        _extractedText =
            '${S.of(context).extractingTextFromPdf}\n\n${S.of(context).pdfTextExtractionNote}\n\n${S.of(context).pdfTextExtractionNote2}';
        _isExtractingText = false;
      });
    } catch (e) {
      print('❌ خطأ في استخراج النص: $e');
      setState(() {
        _extractedText =
            '${S.of(context).failedToExtractTextFromPdf}\n\n${S.of(context).canViewPdfAndSearch}';
        _isExtractingText = false;
      });
    }
  }

  /// ✅ إضافة تظليل للنص المحدد
  void _highlightSelectedText() {
    if (_currentSelection == null || !_currentSelection!.isValid) {
      return;
    }

    final range = TextRange(
      start: _currentSelection!.start,
      end: _currentSelection!.end,
    );

    setState(() {
      _highlightedRanges.add(range);
      _currentSelection = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).textHighlighted),
        duration: Duration(seconds: 2),
      ),
    );
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

  // ✅ دالة البحث - عرض رسالة توضيحية
  void _performSearch(String text) {
    if (text.isEmpty) {
      setState(() {
        _searchSuggestions.clear();
        _isSearching = false;
      });
      return;
    }

    // ✅ flutter_pdfview لا يدعم البحث بشكل مباشر
    // ✅ عرض رسالة توضيحية للمستخدم
    setState(() {
      _isSearching = true;
      _searchSuggestions = [
        'البحث في PDF غير متاح حالياً',
        'flutter_pdfview لا يدعم البحث بشكل مباشر',
        'يمكنك فتح الملف في تطبيق خارجي للبحث',
      ];
    });

    // ✅ عرض SnackBar مع خيار فتح في تطبيق خارجي
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).searchInPdfNotAvailableMessage),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSearchHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text(S.of(context).searchInPdf),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).forAdvancedSearchFeature),
            SizedBox(height: 12),
            Text('• Syncfusion Flutter PDF Viewer'),
            Text('• PDF.js مع WebView'),
            Text('• حزم PDF متقدمة أخرى'),
            SizedBox(height: 12),
            Text(S.of(context).currentVersionSupports),
            Text('✓ تصفح الصفحات'),
            Text('✓ وضعية ملء الشاشة'),
            Text('✓ شريط التنقل'),
            Text('✓ عرض اسم الملف'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).ok),
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
      appBar: isFullScreen
          ? null
          : AppBar(
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
                      S.of(context).pageOf(currentPage + 1, pages),
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
                    tooltip: S.of(context).retry,
                  ),
                // // زر البحث
                // if (localPath != null)
                //   IconButton(
                //     icon: const Icon(Icons.search),
                //     onPressed: _toggleSearchBar,
                //     tooltip: S.of(context).searchInDocument,
                //   ),
                // ✅ زر عرض النص/PDF
                // if (localPath != null)
                //   IconButton(
                //     icon: Icon(_showTextMode ? Icons.picture_as_pdf : Icons.text_fields),
                //     onPressed: _toggleTextMode,
                //     tooltip: _showTextMode ? 'عرض PDF' : 'عرض النص',
                //   ),
                // زر إظهار/إخفاء شريط التنقل (فقط للعرض المحلي)
                if ((localPath != null || useWebView) &&
                    pages > 1 &&
                    !useWebView)
                  IconButton(
                    icon: Icon(
                      showNavigationBar
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleNavigationBar,
                    tooltip: showNavigationBar
                        ? S.of(context).hideNavBar
                        : S.of(context).showNavBar,
                  ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: toggleFullScreen,
                  tooltip: S.of(context).fullScreenMode,
                ),
              ],
            ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(S.of(context).loadingFile),
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
            Text(
              S.of(context).failedToLoadPdf,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryLoading,
              child: Text(S.of(context).retry),
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
            Text(
              S.of(context).fileNotLoaded,
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryLoading,
              child: Text(S.of(context).retry),
            ),
          ],
        ),
      );
    }

    // ✅ إذا كان وضع عرض النص مفعلاً
    if (_showTextMode) {
      return _buildTextView();
    }

    return Stack(
      children: [
        // ✅ عرض PDF باستخدام WebView (إذا فشل flutter_pdfview)
        if (useWebView && webViewController != null)
          WebViewWidget(controller: webViewController!)
        // ✅ عرض PDF محلياً باستخدام flutter_pdfview
        else if (localPath != null)
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
                print('❌ PDF Error: $error');
                if (mounted) {
                  // ✅ عرض رسالة خطأ واضحة مع خيارات
                  final errorMessage = error.toString().toLowerCase();
                  String userMessage = S.of(context).errorLoadingFile("");

                  if (errorMessage.contains('corrupted') ||
                      errorMessage.contains('not in pdf format') ||
                      errorMessage.contains('cannot create document')) {
                    userMessage = S.of(context).pdfCorruptedOrEncrypted;

                    // ✅ محاولة استخدام WebView مع PDF.js كـ fallback
                    print('🔄 Attempting fallback to WebView with PDF.js...');
                    _tryWebViewFallback();
                    return; // ✅ لا نعرض رسالة خطأ إذا كنا نحاول WebView
                  }

                  setState(() {
                    hasError = true;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(userMessage),
                      duration: Duration(seconds: 5),
                      action: SnackBarAction(
                        label: S.of(context).retry,
                        onPressed: _retryLoading,
                      ),
                    ),
                  );
                }
              },
              onPageError: (page, error) {
                print('❌ Error on page $page: $error');
                if (mounted) {
                  // ✅ إذا كان الخطأ في الصفحة الأولى، قد يكون الملف تالف
                  if (page == 0) {
                    setState(() {
                      hasError = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          S
                              .of(context)
                              .pdfCorruptedAtPage(
                                (page ?? 0).toString(),
                                error.toString(),
                              ),
                        ),
                        duration: Duration(seconds: 5),
                        action: SnackBarAction(
                          label: S.of(context).retry,
                          onPressed: _retryLoading,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),

        // شريط البحث
        if (showSearchBar)
          Positioned(top: 0, left: 0, right: 0, child: _buildSearchBar()),

        // شريط التنقل السفلي (فقط للعرض المحلي، WebView له أدواته الخاصة)
        if (showNavigationBar && !isFullScreen && pages > 1 && !useWebView)
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                    icon: const Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                    ),
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
                    hintText: S.of(context).searchInDocument,
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
                  onChanged: (text) {
                    _performSearch(text);
                  },
                  onSubmitted: (text) {
                    _performSearch(text);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // ✅ زر البحث التالي (إذا كان WebView نشط)
              if (useWebView)
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      webViewController?.runJavaScript('''
                        if (window.PDFViewerApplication && window.PDFViewerApplication.findBar) {
                          window.PDFViewerApplication.findBar.findNextButton.click();
                        }
                      ''');
                    }
                  },
                  tooltip: S.of(context).next,
                ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: _showSearchHelp,
                tooltip: S.of(context).searchHelp,
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSearchBar,
                tooltip: S.of(context).closeSearch,
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
                  Text(
                    S.of(context).searchSuggestions,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._searchSuggestions
                      .map(
                        (suggestion) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(suggestion)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          if (_isSearching && _searchSuggestions.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                S.of(context).searching,
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

  /// ✅ بناء واجهة عرض النص مع التظليل
  Widget _buildTextView() {
    if (_isExtractingText) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(S.of(context).extractingText),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ✅ شريط الأدوات
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.highlight),
                onPressed:
                    _currentSelection != null && _currentSelection!.isValid
                    ? _highlightSelectedText
                    : null,
                tooltip: S.of(context).highlightSelectedText,
              ),
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  setState(() {
                    _highlightedRanges.clear();
                  });
                },
                tooltip: S.of(context).removeAllHighlights,
              ),
              const Spacer(),
              Text(
                '${_highlightedRanges.length} ${S.of(context).highlights}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        // ✅ عرض النص
        Expanded(
          child: _extractedText.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.text_fields,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(S.of(context).textNotExtractedYet),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _extractTextFromPdf,
                        child: Text(S.of(context).extractText),
                      ),
                    ],
                  ),
                )
              : _buildSelectableText(),
        ),
      ],
    );
  }

  /// ✅ بناء نص قابل للتحديد مع التظليل
  Widget _buildSelectableText() {
    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText.rich(
          TextSpan(children: _buildTextSpans()),
          style: const TextStyle(fontSize: 16, height: 1.5),
          onSelectionChanged: (selection, cause) {
            setState(() {
              _currentSelection = selection;
            });
          },
        ),
      ),
    );
  }

  /// ✅ بناء TextSpan مع التظليلات
  List<TextSpan> _buildTextSpans() {
    if (_extractedText.isEmpty) return [];

    final spans = <TextSpan>[];
    int currentIndex = 0;

    // ✅ ترتيب التظليلات حسب الموضع
    final sortedRanges = List<TextRange>.from(_highlightedRanges)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final range in sortedRanges) {
      // ✅ النص قبل التظليل
      if (range.start > currentIndex) {
        spans.add(
          TextSpan(text: _extractedText.substring(currentIndex, range.start)),
        );
      }

      // ✅ النص المظلل
      spans.add(
        TextSpan(
          text: _extractedText.substring(range.start, range.end),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentIndex = range.end;
    }

    // ✅ النص المتبقي
    if (currentIndex < _extractedText.length) {
      spans.add(TextSpan(text: _extractedText.substring(currentIndex)));
    }

    return spans.isEmpty ? [TextSpan(text: _extractedText)] : spans;
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                          S.of(context).pageOf(pages, currentPage + 1),
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
                        tooltip: S.of(context).firstPage,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _goToPreviousPage,
                        tooltip: S.of(context).previousPage,
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
                        tooltip: S.of(context).next,
                      ),
                      IconButton(
                        icon: const Icon(Icons.last_page),
                        onPressed: _goToLastPage,
                        tooltip: S.of(context).lastPage,
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
