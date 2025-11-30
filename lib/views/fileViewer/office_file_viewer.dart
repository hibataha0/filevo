import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OfficeFileViewer extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const OfficeFileViewer({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<OfficeFileViewer> createState() => _OfficeFileViewerState();
}

class _OfficeFileViewerState extends State<OfficeFileViewer> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final fileName = widget.fileName.toLowerCase();
    String viewerUrl;

    // ✅ استخدام Microsoft Office Online Viewer أو Google Docs Viewer
    final encodedUrl = Uri.encodeComponent(widget.fileUrl);

    if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      // ✅ Microsoft Office Online Viewer للـ Word
      viewerUrl = 'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      // ✅ Microsoft Office Online Viewer للـ Excel
      viewerUrl = 'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      // ✅ Microsoft Office Online Viewer للـ PowerPoint
      viewerUrl = 'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';
    } else {
      // ✅ Google Docs Viewer كبديل
      viewerUrl = 'https://docs.google.com/viewer?url=$encodedUrl&embedded=true';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = error.description ?? 'حدث خطأ أثناء تحميل الملف';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Color(0xff28336f),
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                        _initializeWebView();
                      },
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            )
          else if (_controller != null)
            WebViewWidget(controller: _controller!),
          if (_isLoading && _error == null)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

