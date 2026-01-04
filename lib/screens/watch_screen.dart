import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  final PageController _pageController = PageController();
  final VideoService _videoService = VideoService();
  
  List<VideoModel> _videos = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentIndex = 0;
  int _currentPage = 1;
  
  // Map of video controllers - lazy loaded
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Randomize starting page (1-5) for variety
    _currentPage = (DateTime.now().millisecondsSinceEpoch % 5) + 1;
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await _videoService.getPopularVideos(page: _currentPage);
    if (mounted) {
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
      // Pre-initialize first video
      if (_videos.isNotEmpty) {
        _initController(0);
      }
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    _currentPage++;
    
    final moreVideos = await _videoService.getPopularVideos(page: _currentPage);
    if (mounted && moreVideos.isNotEmpty) {
      setState(() {
        _videos.addAll(moreVideos);
      });
    }
    _isLoadingMore = false;
  }

  Future<void> _initController(int index) async {
    if (index < 0 || index >= _videos.length) return;
    if (_controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_videos[index].videoUrl),
    );
    _controllers[index] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(1.0); // Enable sound
      if (index == _currentIndex && mounted) {
        controller.play();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  void _disposeController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]?.dispose();
      _controllers.remove(index);
    }
  }

  void _onPageChanged(int index) {
    // Pause old video
    _controllers[_currentIndex]?.pause();
    
    setState(() {
      _currentIndex = index;
    });

    // Play new video
    if (_controllers.containsKey(index)) {
      _controllers[index]?.play();
    } else {
      _initController(index);
    }

    // Pre-load next video
    if (index + 1 < _videos.length) {
      _initController(index + 1);
    }

    // Load more videos when near end (3 videos before end)
    if (index >= _videos.length - 3) {
      _loadMoreVideos();
    }

    // Dispose far away videos to save memory
    for (final key in _controllers.keys.toList()) {
      if ((key - index).abs() > 2) {
        _disposeController(key);
      }
    }
    
    HapticFeedback.selectionClick();
  }


  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_videos.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'No videos available',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return _buildVideoPage(index);
        },
      ),
    );
  }

  Widget _buildVideoPage(int index) {
    final video = _videos[index];
    final controller = _controllers[index];
    final isInitialized = controller?.value.isInitialized ?? false;

    return GestureDetector(
      onTap: () {
        // Toggle play/pause
        if (controller != null && isInitialized) {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
          setState(() {});
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or Thumbnail
          if (isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            )
          else
            // Show thumbnail while loading
            CachedNetworkImage(
              imageUrl: video.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
            ),

          // Loading indicator
          if (!isInitialized)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Pause icon overlay
          if (isInitialized && !(controller?.value.isPlaying ?? true))
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // User info and description (bottom left)
          Positioned(
            bottom: 80,
            left: 16,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      video.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (video.description.isNotEmpty)
                  Text(
                    video.description,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Right side action buttons
          Positioned(
            bottom: 100,
            right: 12,
            child: Column(
              children: [
                _buildActionButton(Icons.favorite, '${(index + 1) * 1234}', () {}),
                const SizedBox(height: 20),
                _buildActionButton(Icons.chat_bubble, '${(index + 1) * 56}', () {}),
                const SizedBox(height: 20),
                _buildActionButton(Icons.share, 'Share', () {}),
              ],
            ),
          ),

          // Progress bar at bottom
          if (isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
