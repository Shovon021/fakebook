import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../models/reel_model.dart';

class ReelsViewerScreen extends StatefulWidget {
  final List<ReelModel> reels;
  final int initialIndex;

  const ReelsViewerScreen({
    super.key,
    required this.reels,
    this.initialIndex = 0,
  });

  @override
  State<ReelsViewerScreen> createState() => _ReelsViewerScreenState();
}

class _ReelsViewerScreenState extends State<ReelsViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Reels',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.reels.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return _ReelPage(
            reel: widget.reels[index],
            isActive: index == _currentIndex,
          );
        },
      ),
    );
  }
}

class _ReelPage extends StatefulWidget {
  final ReelModel reel;
  final bool isActive;

  const _ReelPage({
    required this.reel,
    required this.isActive,
  });

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false; // Internal play state requested by user interaction (tap to pause)
  // Logic: Real state is combined (isActive + !isPausedByUser)
  
  bool _isLiked = false;
  bool _showHeartAnimation = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    
    // Heart Animation Setup
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
         Future.delayed(const Duration(milliseconds: 100), () {
           if (mounted) {
             setState(() => _showHeartAnimation = false);
             _heartAnimationController.reset();
           }
         });
      }
    });

    _isLiked = widget.reel.isLiked;
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl));
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true; // Default to playing
        });
        if (widget.isActive) {
          _videoController.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void didUpdateWidget(_ReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && _isInitialized) {
      if (widget.isActive) {
        if (_isPlaying) _videoController.play();
      } else {
        _videoController.pause();
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      _isLiked = true;
      _showHeartAnimation = true;
    });
    _heartAnimationController.forward();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoController.play();
      } else {
        _videoController.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video
          if (_isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            // Thumbnail while loading
            CachedNetworkImage(
              imageUrl: widget.reel.thumbUrl,
              fit: BoxFit.cover,
            ),
          
          // Play/Pause Icon overlay (only if paused explicitly)
          if (!_isPlaying && _isInitialized)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black54,
                  Colors.black87,
                ],
                stops: [0.0, 0.6, 0.8, 1.0],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: CachedNetworkImageProvider(widget.reel.user.avatarUrl),
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.reel.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  widget.reel.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Music Ticker
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Original Audio - ${widget.reel.user.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Side Actions
          Positioned(
            right: 8,
            bottom: 30, // move up a bit to clear bottom nav area if needed (though extended)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAction(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _isLiked ? (widget.reel.likesCount + 1).toString() : widget.reel.likesCount.toString(),
                  color: _isLiked ? Colors.red : Colors.white,
                  onTap: () => setState(() => _isLiked = !_isLiked),
                ),
                const SizedBox(height: 20),
                _buildAction(
                  icon: Icons.chat_bubble_outline,
                  label: widget.reel.commentsCount.toString(),
                  color: Colors.white,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _buildAction(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: Colors.white,
                  onTap: () {},
                ),
                 const SizedBox(height: 20),
                _buildAction(
                  icon: Icons.more_horiz,
                  label: '',
                  color: Colors.white,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Double Tap Heart Animation
          if (_showHeartAnimation)
            Center(
              child: ScaleTransition(
                scale: _heartScaleAnimation,
                child: const Icon(
                  Icons.favorite,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

