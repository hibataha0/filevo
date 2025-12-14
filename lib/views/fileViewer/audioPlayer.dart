import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerPage extends StatefulWidget {
  final String audioUrl;
  final String fileName;
  const AudioPlayerPage({
    Key? key,
    required this.audioUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _speed = 1.0;
  PlayerState _playerState = PlayerState.stopped;
  bool _isSeeking = false; // إضافة علامة للتحديد أثناء السحب

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    try {
      // إعداد المستمعين أولاً
      _player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _playerState = state;
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _player.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _player.onPositionChanged.listen((position) {
        // لا تحديث الموضع أثناء السحب
        if (mounted && !_isSeeking) {
          setState(() {
            _position = position;
          });
        }
      });

      // تحميل الملف الصوتي
      print('جاري تحميل الملف: ${widget.audioUrl}');

      // ✅ التحقق من أن audioUrl هو URL أم مسار ملف محلي
      final isLocalFile =
          widget.audioUrl.startsWith('/') ||
          widget.audioUrl.startsWith('file://') ||
          !widget.audioUrl.startsWith('http');

      Source source;
      if (isLocalFile) {
        // ✅ استخدام DeviceFileSource للملفات المحلية
        final filePath = widget.audioUrl.startsWith('file://')
            ? widget.audioUrl.replaceFirst('file://', '')
            : widget.audioUrl;
        print('📁 Using local file: $filePath');
        source = DeviceFileSource(filePath);
      } else {
        // ✅ استخدام UrlSource للـ URLs
        print('🌐 Using URL: ${widget.audioUrl}');
        source = UrlSource(widget.audioUrl);
      }

      await _player.setSource(source);

      // الحصول على المدة بعد تحميل الملف
      final duration = await _player.getDuration();
      if (duration != null) {
        if (mounted) {
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('تعذر الحصول على مدة الملف الصوتي');
      }
    } catch (e) {
      print('❌ خطأ في تحميل الملف الصوتي: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playAudio() async {
    try {
      print('جاري تشغيل الملف الصوتي');

      // إذا كان المشغل في حالة stopped، نحتاج إلى إعادة تعيين المصدر
      if (_playerState == PlayerState.stopped) {
        // ✅ التحقق من نوع المصدر (محلي أم URL)
        final isLocalFile =
            widget.audioUrl.startsWith('/') ||
            widget.audioUrl.startsWith('file://') ||
            !widget.audioUrl.startsWith('http');

        Source source;
        if (isLocalFile) {
          final filePath = widget.audioUrl.startsWith('file://')
              ? widget.audioUrl.replaceFirst('file://', '')
              : widget.audioUrl;
          source = DeviceFileSource(filePath);
        } else {
          source = UrlSource(widget.audioUrl);
        }

        await _player.setSource(source);
      }

      await _player.resume();
    } catch (e) {
      print('❌ خطأ في التشغيل: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      _showErrorSnackBar('فشل تشغيل الملف الصوتي');
    }
  }

  Future<void> _pauseAudio() async {
    try {
      await _player.pause();
    } catch (e) {
      print('❌ خطأ في الإيقاف: $e');
      _showErrorSnackBar('فشل إيقاف الملف الصوتي');
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _player.stop();
      if (mounted) {
        setState(() {
          _position = Duration.zero;
        });
      }
    } catch (e) {
      print('❌ خطأ في التوقف: $e');
      _showErrorSnackBar('فشل إيقاف الملف الصوتي');
    }
  }

  Future<void> _seekAudio(double value) async {
    try {
      final newPosition = Duration(seconds: value.toInt());
      await _player.seek(newPosition);

      // تحديث الموضع مباشرة بعد السحب
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    } catch (e) {
      print('❌ خطأ في التقدم: $e');
      _showErrorSnackBar('فشل التقدم في الملف');
    }
  }

  void _onSliderChangeStart(double value) {
    setState(() {
      _isSeeking = true;
    });
    // لا نقوم بإيقاف التشغيل تلقائياً أثناء السحب
  }

  void _onSliderChangeEnd(double value) async {
    setState(() {
      _isSeeking = false;
    });
    await _seekAudio(value);

    // إذا كان التشغيل نشطاً قبل السحب، نستأنف التشغيل
    if (_isPlaying) {
      await _playAudio();
    }
  }

  Future<void> _changeSpeed(double speed) async {
    try {
      await _player.setPlaybackRate(speed);
      if (mounted) {
        setState(() {
          _speed = speed;
        });
      }
    } catch (e) {
      print('❌ خطأ في تغيير السرعة: $e');
      _showErrorSnackBar('فشل تغيير سرعة التشغيل');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return "00:00";
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _retryLoading() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _position = Duration.zero;
        _isPlaying = false;
        _playerState = PlayerState.stopped;
      });
    }
    await _setupAudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
        backgroundColor: const Color(0xff28336f),
        actions: [
          if (_hasError)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoading,
              tooltip: 'إعادة تحميل',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل الملف الصوتي...'),
                ],
              ),
            )
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'فشل تحميل الملف الصوتي',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تأكد من اتصال الإنترنت وصحة الرابط',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _retryLoading,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة الملف الصوتي مع تأثير
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blueAccent.withOpacity(0.8),
                          Colors.purpleAccent.withOpacity(0.6),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.audiotrack,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // اسم الملف
                  Text(
                    widget.fileName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 30),

                  // شريط التقدم
                  Column(
                    children: [
                      // التوقيت
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // السلايدر
                      Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        value: _position.inSeconds
                            .clamp(0, _duration.inSeconds)
                            .toDouble(),
                        onChanged: (value) {
                          // تحديث الواجهة فقط أثناء السحب
                          setState(() {
                            _position = Duration(seconds: value.toInt());
                          });
                        },
                        onChangeStart: _onSliderChangeStart,
                        onChangeEnd: _onSliderChangeEnd,
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.grey[300],
                        thumbColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // أزرار التحكم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زر إعادة التشغيل
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.replay),
                        color: Colors.grey[700],
                        onPressed: _stopAudio,
                        tooltip: 'إعادة التشغيل من البداية',
                      ),
                      const SizedBox(width: 20),

                      // زر التشغيل/الإيقاف الرئيسي
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.purpleAccent],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: IconButton(
                          iconSize: 50,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _isPlaying ? _pauseAudio : _playAudio,
                          tooltip: _isPlaying ? 'إيقاف' : 'تشغيل',
                        ),
                      ),
                      const SizedBox(width: 20),

                      // زر التوقف
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.stop),
                        color: Colors.grey[700],
                        onPressed: _stopAudio,
                        tooltip: 'توقف',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // إعدادات السرعة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.speed, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              'سرعة التشغيل:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButton<double>(
                            value: _speed,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blueAccent,
                            ),
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                            items: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                                .map(
                                  (speed) => DropdownMenuItem(
                                    value: speed,
                                    child: Text(
                                      '${speed}x',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _changeSpeed(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // حالة التشغيل
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isPlaying
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isPlaying
                          ? '🎵 جاري التشغيل...'
                          : _playerState == PlayerState.paused
                          ? '⏸️ متوقف مؤقتاً'
                          : '⏹️ متوقف',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isPlaying ? Colors.green : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
