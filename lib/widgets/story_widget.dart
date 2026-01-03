import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';
import '../screens/story_viewer_screen.dart';
import '../services/storage_service.dart';
import '../services/story_service.dart';
import '../providers/current_user_provider.dart';

class StoryWidget extends StatelessWidget {
  final List<StoryModel> stories;

  const StoryWidget({
    super.key,
    required this.stories,
  });

  Future<void> _createStory(BuildContext context) async {
    final currentUser = currentUserProvider.currentUser;
    if (currentUser == null) return;

    final storageService = StorageService();
    final storyService = StoryService();

    // Pick image
    final file = await storageService.pickImageFromGallery();
    if (file == null) return;

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.facebookBlue),
        ),
      );
    }

    try {
      // Upload image
      final imageUrl = await storageService.uploadImage(
        file: file,
        folder: 'fakebook/stories/${currentUser.id}',
      );

      if (imageUrl != null) {
        // Create story
        await storyService.createStory(
          userId: currentUser.id,
          imageUrl: imageUrl,
        );
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story posted!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post story: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = currentUserProvider.currentUser;
    
    // Build list with Create Story card first, then other stories
    final displayStories = <StoryModel>[];
    
    // Find if current user has any stories
    final userOwnStories = stories.where((s) => s.user.id == currentUser?.id).toList();
    
    // Add "Create Story" card (or user's own story if they have one)
    if (currentUser != null) {
      if (userOwnStories.isNotEmpty) {
        // Show user's own story with "Your Story" indicator
        displayStories.add(userOwnStories.first.copyWith(isOwnStory: true));
      } else {
        // Show "Create Story" placeholder
        displayStories.add(StoryModel(
          id: 'create',
          user: currentUser,
          isOwnStory: true,
          createdAt: DateTime.now(),
        ));
      }
    }
    
    // Add other users' stories
    for (final story in stories) {
      if (story.user.id != currentUser?.id) {
        displayStories.add(story);
      }
    }
    
    return Container(
      height: 210,
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: displayStories.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: displayStories.length,
              itemBuilder: (context, index) {
                final story = displayStories[index];
                return _buildStoryCard(context, story, isDark, displayStories);
              },
            ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryModel story, bool isDark, List<StoryModel> allStories) {
    return GestureDetector(
      onTap: () {
        if (story.isOwnStory) {
          // Create story
          _createStory(context);
        } else {
          // View stories
          final viewableStories = allStories.where((s) => !s.isOwnStory).toList();
          final index = viewableStories.indexOf(story);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoryViewerScreen(
                stories: viewableStories,
                initialIndex: index >= 0 ? index : 0,
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
            child: ImageHelper.getNetworkImage(
              imageUrl: story.user.avatarUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
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
        ImageHelper.getNetworkImage(
          imageUrl: story.imageUrl ?? story.user.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
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
                backgroundImage: ImageHelper.getImageProvider(
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
