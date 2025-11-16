// // file_viewers_and_utils.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:http/http.dart' as http;

// // ================= Image Viewer =================
// class ImageViewer extends StatelessWidget {
//   final String url;
//   const ImageViewer({Key? key, required this.url}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('عرض الصورة')),
//       body: Center(child: Image.network(url)),
//     );
//   }
// }

// // ================= PDF Viewer =================
// class PDFViewer extends StatelessWidget {
//   final String url;
//   const PDFViewer({Key? key, required this.url}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('عرض PDF')),
//       body: PDFView(filePath: url),
//     );
//   }
// }

// // ================= Video Viewer =================
// class VideoViewer extends StatefulWidget {
//   final String url;
//   const VideoViewer({Key? key, required this.url}) : super(key: key);

//   @override
//   State<VideoViewer> createState() => _VideoViewerState();
// }

// class _VideoViewerState extends State<VideoViewer> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.url)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('عرض الفيديو')),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }

// // ================= File Viewer Utils =================
// class FileViewerUtils {
//   static final List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
//   static final List<String> pdfExtensions = ['pdf'];
//   static final List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];

//   /// دالة لتحديد نوع الملف حسب الامتداد
//   static String getFileType(String fileName) {
//     final ext = fileName.split('.').last.toLowerCase();
//     if (imageExtensions.contains(ext)) return 'image';
//     if (pdfExtensions.contains(ext)) return 'pdf';
//     if (videoExtensions.contains(ext)) return 'video';
//     return 'other';
//   }

//   /// دالة لتحميل الملف مؤقتًا على الجهاز
//   static Future<String> downloadFile(String url, String filename) async {
//     final response = await http.get(Uri.parse(url));
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$filename');
//     await file.writeAsBytes(response.bodyBytes);
//     return file.path;
//   }

//   /// دالة لفتح الملف حسب نوعه
//   static Future<void> openFile(BuildContext context, Map file) async {
//     final url = file['url'] ?? '';
//     final name = file['name'] ?? '';
//     if (url.isEmpty) return;

//     final type = getFileType(name);

//     if (type == 'image') {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => ImageViewer(url: url)));
//     } else if (type == 'pdf') {
//       final path = await downloadFile(url, name);
//       Navigator.push(context, MaterialPageRoute(builder: (_) => PDFViewer(url: path)));
//     } else if (type == 'video') {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => VideoViewer(url: url)));
//     } else {
//       final path = await downloadFile(url, name);
//       OpenFilex.open(path);
//     }
//   }
// }