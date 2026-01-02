import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            // End of stories, close viewer
            Navigator.of(context).pop();
          }
        });
      }
    });

    _loadStory(story: widget.stories[_currentIndex]);
  }

  void _loadStory({required StoryModel story}) {
    _animController.stop();
    _animController.reset();
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      // Tap left - go back
      if (_currentIndex - 1 >= 0) {
        setState(() {
          _currentIndex -= 1;
        });
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _loadStory(story: widget.stories[_currentIndex]);
      }
    } else {
      // Tap right - go forward
      if (_currentIndex + 1 < widget.stories.length) {
        setState(() {
          _currentIndex += 1;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _loadStory(story: widget.stories[_currentIndex]);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final UserModel user = story.user;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe down to close
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Handle navigation via taps
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final currentStory = widget.stories[index];
                return Stack(
                    fit: StackFit.expand,
                    children: [
                        if (currentStory.imageUrl != null)
                             CachedNetworkImage(
                                imageUrl: currentStory.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(color: Colors.white)),
                                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                            )
                        else
                             Container(
                                color: Colors.grey[800],
                                child: const Center(
                                    child: Text("Story Content", style: TextStyle(color: Colors.white))
                                ),
                             ),
                         // Gradient Overlay for text readability
                         Container(
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [
                                 Colors.black.withValues(alpha: 0.6),
                                 Colors.transparent,
                                 Colors.transparent,
                                 Colors.black.withValues(alpha: 0.4),
                               ],
                               begin: Alignment.topCenter,
                               end: Alignment.bottomCenter,
                               stops: const [0.0, 0.2, 0.8, 1.0],
                             ),
                           ),
                         ),
                    ],
                );
              },
            ),
            // Progress Bars
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                children: widget.stories.asMap().entries.map((entry) {
                   return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: LinearProgressIndicator(
                          value: entry.key == _currentIndex
                              ? _animController.value
                              : (entry.key < _currentIndex ? 1.0 : 0.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 2,
                        ),
                      ),
                   );
                }).toList(),
              ),
            ),
             // Animated Builder for smooth progress bar update
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                   return Row(
                    children: widget.stories.asMap().entries.map((entry) {
                       return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: LinearProgressIndicator(
                              value: entry.key == _currentIndex
                                  ? _animController.value
                                  : (entry.key < _currentIndex ? 1.0 : 0.0),
                              backgroundColor: Colors.transparent, // Background handled by the static row
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 2,
                            ),
                          ),
                       );
                    }).toList(),
                  );
                },
              ),
            ),

            // User Info
            Positioned(
              top: 65,
              left: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '2h', // Helper logic can be added for real time
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
             // Close Button
            Positioned(
              top: 65,
              right: 16,
              child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
              ),
            ),
             // Bottom Reply Field
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Row(
                 children: [
                     Expanded(
                         child: Container(
                             height: 50,
                             padding: const EdgeInsets.symmetric(horizontal: 16),
                             decoration: BoxDecoration(
                                 border: Border.all(color: Colors.white),
                                 borderRadius: BorderRadius.circular(25),
                             ),
                             alignment: Alignment.centerLeft,
                             child: Text(
                                 "Reply to ${user.name}...",
                                 style: const TextStyle(color: Colors.white),
                             ),
                         ),
                     ),
                     const SizedBox(width: 10),
                     const Icon(Icons.thumb_up, color: Colors.white, size: 28),
                     const SizedBox(width: 10),
                     const Icon(Icons.favorite, color: Colors.white, size: 28),
                     const SizedBox(width: 10),
                     const Icon(Icons.emoji_emotions, color: Colors.white, size: 28),
                 ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
