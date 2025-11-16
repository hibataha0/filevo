import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';

class VideoViewer extends StatefulWidget {
  final String url;
  const VideoViewer({Key? key, required this.url}) : super(key: key);

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  double _playbackSpeed = 1.0;
  bool _isFullScreen = false;
  bool _showControls = true;
  List<double> _availableSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  List<String> _availableQualities = ['تلقائي', '1080p', '720p', '480p', '360p'];
  
  // متغيرات الترجمة
  List<SubtitleItem> _availableSubtitles = [];
  String? _selectedSubtitle;
  bool _showSubtitles = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _setupControlsTimer();
    _loadSubtitles();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.url);
      await _controller.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
        allowFullScreen: false,
        allowMuting: true,
        showControls: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade400,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        autoInitialize: true,
        subtitle: _buildSubtitles(),
        subtitleBuilder: (context, subtitle) => Container(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4.0,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }

      _controller.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'فشل تحميل الفيديو: $e';
        });
      }
    }
  }

  // تحميل الترجمات المتاحة
  void _loadSubtitles() {
    // في التطبيق الحقيقي، يمكن جلب هذه القائمة من السيرفر
    setState(() {
      _availableSubtitles = [
        SubtitleItem(id: 'none', name: 'بدون ترجمة', language: 'لا شيء'),
        SubtitleItem(id: 'ar', name: 'العربية', language: 'العربية'),
        SubtitleItem(id: 'en', name: 'English', language: 'الإنجليزية'),
        SubtitleItem(id: 'fr', name: 'Français', language: 'الفرنسية'),
        SubtitleItem(id: 'es', name: 'Español', language: 'الإسبانية'),
      ];
      _selectedSubtitle = 'none';
    });
  }

  // بناء قائمة الترجمات (في التطبيق الحقيقي، ستأتي من ملفات SRT/VTT)
  Subtitles _buildSubtitles() {
    if (!_showSubtitles || _selectedSubtitle == 'none') {
      return  Subtitles([]);
    }

    // هذه أمثلة للترجمات - في التطبيق الحقيقي ستقرأ من ملف
    final subtitles = <Subtitle>[];
    
    if (_selectedSubtitle == 'ar') {
      // ترجمة عربية افتراضية
      subtitles.addAll([
        Subtitle(
          index: 0,
          start: const Duration(seconds: 0),
          end: const Duration(seconds: 5),
          text: 'مرحباً بك في مشغل الفيديو',
        ),
        Subtitle(
          index: 1,
          start: const Duration(seconds: 5),
          end: const Duration(seconds: 10),
          text: 'يمكنك التحكم في الترجمة والإعدادات',
        ),
        Subtitle(
          index: 2,
          start: const Duration(seconds: 10),
          end: const Duration(seconds: 15),
          text: 'استمتع بمشاهدة الفيديو',
        ),
      ]);
    } else if (_selectedSubtitle == 'en') {
      // ترجمة إنجليزية افتراضية
      subtitles.addAll([
        Subtitle(
          index: 0,
          start: const Duration(seconds: 0),
          end: const Duration(seconds: 5),
          text: 'Welcome to the video player',
        ),
        Subtitle(
          index: 1,
          start: const Duration(seconds: 5),
          end: const Duration(seconds: 10),
          text: 'You can control subtitles and settings',
        ),
        Subtitle(
          index: 2,
          start: const Duration(seconds: 10),
          end: const Duration(seconds: 15),
          text: 'Enjoy watching the video',
        ),
      ]);
    }

    return Subtitles(subtitles);
  }

  void _setupControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls && _isFullScreen) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _setupControlsTimer();
    }
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
    _setupControlsTimer();
  }

  void _changeSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _controller.setPlaybackSpeed(speed);
    });
    _setupControlsTimer();
  }

  void _changeQuality(String quality) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تغيير الجودة إلى $quality')),
    );
    _setupControlsTimer();
  }

  void _changeSubtitle(String? subtitleId) {
    setState(() {
      _selectedSubtitle = subtitleId;
      _showSubtitles = subtitleId != 'none';
      // تحديث ChewieController بالترجمة الجديدة
      _chewieController?.subtitle = _buildSubtitles();
    });
    _setupControlsTimer();
    
    if (subtitleId == 'none') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إيقاف الترجمة')),
      );
    } else {
      final subtitle = _availableSubtitles.firstWhere(
        (item) => item.id == subtitleId,
        orElse: () => SubtitleItem(id: '', name: '', language: ''),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تفعيل الترجمة: ${subtitle.name}')),
      );
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _showControls = true;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
    _setupControlsTimer();
  }

  void _seekForward() {
    final newPosition = _controller.value.position + const Duration(seconds: 10);
    if (newPosition < _controller.value.duration) {
      _controller.seekTo(newPosition);
    }
    _setupControlsTimer();
  }

  void _seekBackward() {
    final newPosition = _controller.value.position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _controller.seekTo(newPosition);
    }
    _setupControlsTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds";
  }

  void _showSubtitleSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات الترجمة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // اختيار اللغة
            const Text(
              'اختر لغة الترجمة:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSubtitles.map((subtitle) {
                final isSelected = _selectedSubtitle == subtitle.id;
                return ChoiceChip(
                  label: Text(
                    subtitle.name,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    _changeSubtitle(subtitle.id);
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.grey[800],
                  selectedColor: Colors.blue,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // إعدادات إضافية للترجمة
            if (_showSubtitles && _selectedSubtitle != 'none') ...[
              const Text(
                'إعدادات إضافية:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.white),
                title: const Text(
                  'تكبير حجم الخط',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                onTap: () {
                  _showFontSizeSettings();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.color_lens, color: Colors.white),
                title: const Text(
                  'لون الترجمة',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                onTap: () {
                  _showColorSettings();
                },
              ),
            ],
            
            const SizedBox(height: 20),
            
            // زر الإغلاق
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSettings() {
    // يمكن إضافة إعدادات حجم الخط هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة إعدادات حجم الخط قريباً')),
    );
  }

  void _showColorSettings() {
    // يمكن إضافة إعدادات الألوان هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة إعدادات الألوان قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text('عرض الفيديو'),
              backgroundColor: const Color(0xff28336f),
              actions: [
                // زر الترجمة
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.subtitles, color: Colors.white),
                      if (_showSubtitles && _selectedSubtitle != 'none')
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '●',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _showSubtitleSettings,
                ),
                PopupMenuButton<String>(
                  onSelected: _changeQuality,
                  itemBuilder: (context) => _availableQualities
                      .map((quality) => PopupMenuItem(
                            value: quality,
                            child: Text(quality),
                          ))
                      .toList(),
                  icon: const Icon(Icons.hd, color: Colors.white),
                ),
                PopupMenuButton<double>(
                  onSelected: _changeSpeed,
                  itemBuilder: (context) => _availableSpeeds
                      .map((speed) => PopupMenuItem(
                            value: speed,
                            child: Text("${speed}x"),
                          ))
                      .toList(),
                  icon: const Icon(Icons.speed, color: Colors.white),
                ),
              ],
            ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _initializeVideo,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: _toggleControls,
                  child: Stack(
                    children: [
                      // الفيديو مع Chewie
                      if (_chewieController != null)
                        Chewie(controller: _chewieController!),

                      // شريط التحكم العلوي
                      if (_isFullScreen && _showControls)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () {
                                    if (_isFullScreen) {
                                      _toggleFullScreen();
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                                const Spacer(),
                                // زر الترجمة في وضع ملء الشاشة
                                IconButton(
                                  icon: Stack(
                                    children: [
                                      const Icon(Icons.subtitles, color: Colors.white),
                                      if (_showSubtitles && _selectedSubtitle != 'none')
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Text(
                                              '●',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  onPressed: _showSubtitleSettings,
                                ),
                                PopupMenuButton<String>(
                                  onSelected: _changeQuality,
                                  itemBuilder: (context) => _availableQualities
                                      .map((quality) => PopupMenuItem(
                                            value: quality,
                                            child: Text(quality),
                                          ))
                                      .toList(),
                                  icon: const Icon(Icons.hd, color: Colors.white),
                                ),
                                PopupMenuButton<double>(
                                  onSelected: _changeSpeed,
                                  itemBuilder: (context) => _availableSpeeds
                                      .map((speed) => PopupMenuItem(
                                            value: speed,
                                            child: Text("${speed}x"),
                                          ))
                                      .toList(),
                                  icon: const Icon(Icons.speed, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // شريط التحكم السفلي
                      if (_showControls || !_isFullScreen)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildControls(),
                        ),

                      // أزرار التحكم المركزية
                      if (_isFullScreen && _showControls)
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _seekBackward,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _togglePlayPause,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _seekForward,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: const Icon(
                                      Icons.forward_10,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildControls() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط التقدم
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: position.inMilliseconds.toDouble().clamp(
                        0,
                        duration.inMilliseconds.toDouble(),
                      ),
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _controller.seekTo(Duration(milliseconds: value.toInt()));
                  },
                  onChangeStart: (_) {
                    setState(() {
                      _showControls = true;
                    });
                  },
                  onChangeEnd: (_) {
                    _setupControlsTimer();
                  },
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white54,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),

          // أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الجانب الأيسر: التشغيل والسرعة
              Row(
                children: [
                  IconButton(
                    iconSize: 28,
                    color: Colors.white,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "${_playbackSpeed}x",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),

              // الجانب الأيمن: الترجمة وملء الشاشة
              Row(
                children: [
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.subtitles, color: Colors.white, size: 24),
                        if (_showSubtitles && _selectedSubtitle != 'none')
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '●',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 6,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showSubtitleSettings,
                  ),
                  IconButton(
                    onPressed: _toggleFullScreen,
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }
}

class SubtitleItem {
  final String id;
  final String name;
  final String language;

  SubtitleItem({
    required this.id,
    required this.name,
    required this.language,
  });
}