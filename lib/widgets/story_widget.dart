import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story_model.dart';
import '../theme/app_theme.dart';
import '../screens/story_viewer_screen.dart';

class StoryWidget extends StatelessWidget {
  final List<StoryModel> stories;

  const StoryWidget({
    super.key,
    required this.stories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 210,
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return _buildStoryCard(context, story, isDark);
        },
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryModel story, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (!story.isOwnStory) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoryViewerScreen(
                stories: stories.where((s) => !s.isOwnStory).toList(),
                initialIndex: stories.where((s) => !s.isOwnStory).toList().indexOf(story),
              ),
            ),
          );
        }
      },
      child: Container(
        width: 115,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: story.isOwnStory
                  ? _buildCreateStoryCard(story, isDark)
                  : _buildUserStoryCard(story, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateStoryCard(StoryModel story, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF3A3B3C) : Colors.white,
      child: Column(
        children: [
          // Top part with user photo
          Expanded(
            flex: 7,
            child: CachedNetworkImage(
              imageUrl: story.user.avatarUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person),
              ),
            ),
          ),
          // Bottom part with add button and text
          Expanded(
            flex: 4,
            child: Container(
              color: isDark ? const Color(0xFF242526) : Colors.white,
              child: Column(
                children: [
                  // Plus button overlapping the image
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF242526) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.facebookBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Create story',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStoryCard(StoryModel story, bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Story image
        CachedNetworkImage(
          imageUrl: story.imageUrl ?? story.user.avatarUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image),
          ),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.6),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.isViewed 
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF405DE6), Color(0xFF5851DB), Color(0xFF833AB4), Color(0xFFC13584), Color(0xFFE1306C), Color(0xFFFD1D1D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: story.isViewed ? Colors.grey[400] : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: isDark ? const Color(0xFF242526) : Colors.white,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(
                  story.user.avatarUrl,
                ),
              ),
            ),
          ),
        ),
        // Name
        Positioned(
          left: 8,
          right: 8,
          bottom: 12,
          child: Text(
            story.user.name.split(' ').first,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
