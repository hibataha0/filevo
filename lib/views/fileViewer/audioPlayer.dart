import 'package:filevo/generated/l10n.dart';
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
  bool _isSeeking = false; // علامة للتحديد أثناء السحب

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    try {
      // إعداد المستمعين
      _player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _playerState = state;
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _player.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      });

      _player.onPositionChanged.listen((position) {
        if (mounted && !_isSeeking) setState(() => _position = position);
      });

      // تحديد نوع المصدر
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

      final duration = await _player.getDuration();
      if (duration != null) {
        if (mounted) {
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(S.of(context).audioDurationError);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      print('❌ Audio load error: $e');
    }
  }

  Future<void> _playAudio() async {
    try {
      if (_playerState == PlayerState.stopped) {
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
      if (mounted) setState(() => _hasError = true);
      _showErrorSnackBar(S.of(context).audioPlayError);
    }
  }

  Future<void> _pauseAudio() async {
    try {
      await _player.pause();
    } catch (e) {
      _showErrorSnackBar(S.of(context).audioPauseError);
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _player.stop();
      if (mounted) setState(() => _position = Duration.zero);
    } catch (e) {
      _showErrorSnackBar(S.of(context).audioPauseError);
    }
  }

  Future<void> _seekAudio(double value) async {
    try {
      final newPosition = Duration(seconds: value.toInt());
      await _player.seek(newPosition);
      if (mounted) setState(() => _position = newPosition);
    } catch (e) {
      _showErrorSnackBar(S.of(context).audioSeekError);
    }
  }

  void _onSliderChangeStart(double value) => setState(() => _isSeeking = true);

  void _onSliderChangeEnd(double value) async {
    setState(() => _isSeeking = false);
    await _seekAudio(value);
    if (_isPlaying) await _playAudio();
  }

  Future<void> _changeSpeed(double speed) async {
    try {
      await _player.setPlaybackRate(speed);
      if (mounted) setState(() => _speed = speed);
    } catch (e) {
      _showErrorSnackBar(S.of(context).audioSpeedChangeError);
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
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _retryLoading() async {
    if (mounted)
      setState(() {
        _isLoading = true;
        _hasError = false;
        _position = Duration.zero;
        _isPlaying = false;
        _playerState = PlayerState.stopped;
      });
    await _setupAudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
              tooltip: s.retry,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(s.loadingAudio),
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
                  Text(
                    s.audioLoadFailed,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.checkInternet,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _retryLoading,
                    icon: const Icon(Icons.refresh),
                    label: Text(s.retry),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة الملف
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

                  // Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds
                        .clamp(0, _duration.inSeconds)
                        .toDouble(),
                    onChanged: (value) => setState(
                      () => _position = Duration(seconds: value.toInt()),
                    ),
                    onChangeStart: _onSliderChangeStart,
                    onChangeEnd: _onSliderChangeEnd,
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[300],
                    thumbColor: Colors.blueAccent,
                  ),

                  const SizedBox(height: 30),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.replay),
                        color: Colors.grey[700],
                        onPressed: _stopAudio,
                        tooltip: s.restart,
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
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
                          tooltip: _isPlaying ? s.pause : s.play,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.stop),
                        color: Colors.grey[700],
                        onPressed: _stopAudio,
                        tooltip: s.stop,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Speed
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
                        Row(
                          children: [
                            Icon(Icons.speed, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              S.of(context).playbackSpeedLabel,
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
                              if (value != null) _changeSpeed(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

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
                          ? s.playingStatus
                          : _playerState == PlayerState.paused
                          ? s.pausedStatus
                          : s.stoppedStatus,
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
