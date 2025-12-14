import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

/// صفحة محرر الفيديو باستخدام video_editor
class VideoEditorPage extends StatefulWidget {
  final File videoFile;

  const VideoEditorPage({super.key, required this.videoFile});

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  VideoEditorController? _controller;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _errorMessage;
  String _selectedMode = 'Trim'; // Trim أو Cover

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// تهيئة الفيديو
  Future<void> _initializeVideo() async {
    try {
      if (!await widget.videoFile.exists()) {
        setState(() {
          _errorMessage = 'الملف غير موجود';
          _isLoading = false;
        });
        return;
      }

      // ✅ تهيئة VideoEditorController
      // نستخدم مدة كبيرة جداً كحد أقصى للسماح بأي مدة فيديو
      _controller = VideoEditorController.file(
        widget.videoFile,
        minDuration: const Duration(seconds: 1),
        maxDuration: const Duration(hours: 24), // 24 ساعة كحد أقصى
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تحميل الفيديو: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// تصدير الفيديو المقطوع
  Future<void> _exportVideo() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // ✅ video_editor يوفر الأوامر فقط، نحتاج إلى استخدام FFmpeg مباشرة
      // TODO: إضافة FFmpeg package لتنفيذ الأمر
      // في الوقت الحالي، سنعيد الملف الأصلي مع معلومات Trim
      final outputFile = widget.videoFile;
      
      // ✅ يمكن استخدام VideoFFmpegVideoEditorConfig للحصول على أمر FFmpeg
      // final config = VideoFFmpegVideoEditorConfig(...);

      if (await outputFile.exists()) {
        final fileSize = await outputFile.length();

        if (fileSize > 0) {
          if (mounted) {
            Navigator.pop(context, outputFile);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('الفيديو المحفوظ فارغ'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isExporting = false;
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل تصدير الفيديو'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isExporting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تصدير الفيديو: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// تنسيق المدة
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null || _controller == null || !_controller!.initialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'فشل تحميل الفيديو',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ شريط الأدوات العلوي
            _buildTopToolbar(),

            // ✅ معاينة الفيديو
            Expanded(
              flex: 3,
              child: _buildVideoPreview(),
            ),

            // ✅ خيارات التحرير (Trim / Cover)
            _buildEditModeSelector(),

            // ✅ Timeline مع Trim
            Expanded(
              flex: 2,
              child: _buildTimeline(),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء شريط الأدوات العلوي
  Widget _buildTopToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ أزرار التحكم العامة
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: _isExporting ? null : _exportVideo,
                tooltip: 'تصدير',
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: Colors.grey),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.white),
                onPressed: null,
                tooltip: 'تراجع',
              ),
              IconButton(
                icon: const Icon(Icons.redo, color: Colors.white),
                onPressed: null,
                tooltip: 'إعادة',
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: Colors.grey),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.crop, color: Colors.white),
                onPressed: () {
                  // TODO: إضافة ميزة Crop
                },
                tooltip: 'قص',
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: Colors.grey),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.folder, color: Colors.white),
                onPressed: () {
                  // TODO: فتح الملفات
                },
                tooltip: 'الملفات',
              ),
            ],
          ),
          // ✅ حالة التصدير
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// بناء معاينة الفيديو
  Widget _buildVideoPreview() {
    return Container(
      color: Colors.black,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (_controller?.video.value.isPlaying ?? false) {
              _controller?.video.pause();
            } else {
              _controller?.video.play();
            }
          },
          child: _controller != null
              ? AspectRatio(
                  aspectRatio: _controller!.video.value.aspectRatio,
                  child: VideoPlayer(_controller!.video),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),
      ),
    );
  }

  /// بناء محدد وضع التحرير
  Widget _buildEditModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModeButton(
            icon: Icons.content_cut,
            label: 'Trim',
            isSelected: _selectedMode == 'Trim',
            onTap: () {
              setState(() {
                _selectedMode = 'Trim';
              });
            },
          ),
          const SizedBox(width: 32),
          _buildModeButton(
            icon: Icons.image,
            label: 'Cover',
            isSelected: _selectedMode == 'Cover',
            onTap: () {
              setState(() {
                _selectedMode = 'Cover';
              });
            },
          ),
        ],
      ),
    );
  }

  /// بناء زر وضع التحرير
  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء Timeline
  Widget _buildTimeline() {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // ✅ معلومات الوقت
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_controller?.trimmedDuration ?? Duration.zero),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_formatDuration(_controller?.startTrim ?? Duration.zero)} / ${_formatDuration(_controller?.endTrim ?? Duration.zero)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ✅ Timeline مخصص باستخدام VideoEditorController
          Expanded(
            child: _buildCustomTimeline(),
          ),
          // ✅ علامات الوقت
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                9,
                (index) => Text(
                  '${index * 3}s',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء Timeline مخصص
  Widget _buildCustomTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ Range Slider للتحكم في Trim
          _controller != null
              ? RangeSlider(
                  values: RangeValues(
                    _controller!.startTrim.inMilliseconds.toDouble(),
                    _controller!.endTrim.inMilliseconds.toDouble(),
                  ),
                  min: 0,
                  max: _controller!.video.value.duration.inMilliseconds.toDouble(),
                  onChanged: (values) {
                    setState(() {
                      _controller?.updateTrim(
                        values.start,
                        values.end,
                      );
                    });
                  },
                  activeColor: Colors.yellow,
                  inactiveColor: Colors.grey[700],
                )
              : const SizedBox(),
          const SizedBox(height: 8),
          // ✅ معلومات الوقت
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_controller?.startTrim ?? Duration.zero),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                _formatDuration(_controller?.endTrim ?? Duration.zero),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
