import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  final VoidCallback? onComplete;
  final Function(String storyId)? onStoryViewed;

  const StoryViewerScreen({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
    this.onComplete,
    this.onStoryViewed,
  }) : super(key: key);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentStoryIndex;
  late AnimationController _animationController;
  VideoPlayerController? _videoController;
  Timer? _progressTimer;
  bool _isPaused = false;

  // Story duration in seconds
  static const int imageDuration = 5;
  static const int videoDuration = 15;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: imageDuration),
    );

    _animationController.addStatusListener(_onAnimationStatusChanged);
    _loadStory();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _nextStory();
    }
  }

  Future<void> _loadStory() async {
    final story = widget.stories[_currentStoryIndex];

    // Mark story as viewed
    widget.onStoryViewed?.call(story.id);

    // Reset animation controller
    _animationController.reset();

    if (story.mediaType == 'video') {
      // Load video
      await _loadVideo(story.mediaUrl);
    } else {
      // Start image timer
      _animationController.duration = Duration(seconds: imageDuration);
      _animationController.forward();
    }
  }

  Future<void> _loadVideo(String videoUrl) async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _videoController!.initialize();
      await _videoController!.play();

      // Set animation duration to video duration
      final duration = _videoController!.value.duration.inSeconds;
      _animationController.duration = Duration(seconds: duration);
      _animationController.forward();

      // Listen for video completion
      _videoController!.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          _nextStory();
        }
      });

      setState(() {});
    } catch (e) {
      debugPrint('Error loading video: $e');
      _nextStory();
    }
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _loadStory();
    } else {
      _closeViewer();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _loadStory();
    }
  }

  void _pauseStory() {
    setState(() {
      _isPaused = true;
    });
    _animationController.stop();
    _videoController?.pause();
  }

  void _resumeStory() {
    setState(() {
      _isPaused = false;
    });
    _animationController.forward();
    _videoController?.play();
  }

  void _closeViewer() {
    widget.onComplete?.call();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoController?.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final tapPosition = details.globalPosition.dx;

          if (tapPosition < screenWidth / 3) {
            _previousStory();
          } else if (tapPosition > screenWidth * 2 / 3) {
            _nextStory();
          } else {
            if (_isPaused) {
              _resumeStory();
            } else {
              _pauseStory();
            }
          }
        },
        onLongPressStart: (_) => _pauseStory(),
        onLongPressEnd: (_) => _resumeStory(),
        child: Stack(
          children: [
            // Story content
            Center(
              child: story.mediaType == 'video' && _videoController != null
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : CachedNetworkImage(
                      imageUrl: story.mediaUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
            ),

            // Progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          double progress = 0.0;
                          if (index < _currentStoryIndex) {
                            progress = 1.0;
                          } else if (index == _currentStoryIndex) {
                            progress = _animationController.value;
                          }

                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header with user info
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: story.userAvatarUrl != null
                        ? CachedNetworkImageProvider(story.userAvatarUrl!)
                        : null,
                    child: story.userAvatarUrl == null
                        ? Text(story.userName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          story.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _closeViewer,
                  ),
                ],
              ),
            ),

            // Pause indicator
            if (_isPaused)
              const Center(
                child: Icon(
                  Icons.pause_circle_outline,
                  color: Colors.white,
                  size: 80,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Story {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String timeAgo;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.mediaUrl,
    required this.mediaType,
    required this.timeAgo,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] ?? 'Unknown',
      userAvatarUrl: json['user_avatar_url'],
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      timeAgo: json['time_ago'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
