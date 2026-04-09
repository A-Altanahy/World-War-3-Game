import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  const AudioPlayerWidget({Key? key, required this.audioPath}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final path = widget.audioPath;
      if (path.startsWith('/') || path.startsWith('\\') || (path.length > 1 && path[1] == ':')) {
        await _audioPlayer.setFilePath(path);
      } else {
        String assetPath = path;
        if (!assetPath.startsWith('assets/')) {
          assetPath = 'assets/questions/$assetPath';
        }
        await _audioPlayer.setAsset(assetPath);
      }
      _audioPlayer.durationStream.listen((d) {
        if (mounted && d != null) setState(() => _duration = d);
      });
      _audioPlayer.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _audioPlayer.pause();
              _audioPlayer.seek(Duration.zero);
            }
          });
        }
      });
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.error, color: AppTheme.warningRed),
            SizedBox(width: 8),
            Text('خطأ في تحميل المقطع الصوتي', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: AppTheme.primaryNeon,
              size: 36,
            ),
            onPressed: () {
              if (_isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play();
              }
            },
          ),
          Expanded(
            child: Slider(
              value: _position.inMilliseconds.toDouble(),
              max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
              activeColor: AppTheme.primaryNeon,
              inactiveColor: Colors.white24,
              onChanged: (val) {
                _audioPlayer.seek(Duration(milliseconds: val.toInt()));
              },
            ),
          ),
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final bool tapAnywhereToToggle;
  final bool showProgressBar;
  final bool allowScrubbing;

  const VideoPlayerWidget({
    Key? key,
    required this.videoPath,
    this.tapAnywhereToToggle = true,
    this.showProgressBar = true,
    this.allowScrubbing = true,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final path = widget.videoPath;
    if (path.startsWith('/') || path.startsWith('\\') || (path.length > 1 && path[1] == ':')) {
      _controller = VideoPlayerController.file(File(path));
    } else {
      String assetPath = path;
      if (!assetPath.startsWith('assets/')) {
        assetPath = 'assets/questions/$assetPath';
      }
      _controller = VideoPlayerController.asset(assetPath);
    }
    
    _controller.initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      }).catchError((e) {
        if (mounted) setState(() => _hasError = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        color: AppTheme.surfaceDark,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: AppTheme.warningRed, size: 48),
              SizedBox(height: 8),
              Text('خطأ في تحميل الفيديو', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        height: 200,
        color: AppTheme.surfaceDark,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryNeon),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.tapAnywhereToToggle
                  ? () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    }
                  : null,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: AnimatedOpacity(
              opacity: _controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          if (widget.showProgressBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: widget.allowScrubbing,
                colors: const VideoProgressColors(
                  playedColor: AppTheme.primaryNeon,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.black45,
                ),
              ),
            )
        ],
      ),
    );
  }
}
