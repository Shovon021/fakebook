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

    // 1. Group stories by User ID
    final Map<String, List<StoryModel>> groupedStories = {};
    for (final story in stories) {
      if (!groupedStories.containsKey(story.user.id)) {
        groupedStories[story.user.id] = [];
      }
      groupedStories[story.user.id]!.add(story);
    }

    // 2. Create Display List (Thumbnails)
    final displayCards = <StoryModel>[];

    // A. "Create Story" Card (Always first)
    if (currentUser != null) {
      displayCards.add(StoryModel(
        id: 'create',
        user: currentUser,
        isOwnStory: true,
        createdAt: DateTime.now(),
      ));
    }

    // B. "Your Story" Card (If exists)
    if (currentUser != null && groupedStories.containsKey(currentUser.id)) {
      final myStories = groupedStories[currentUser.id]!;
      // Use the latest story as thumbnail
      displayCards.add(myStories.last.copyWith(isOwnStory: true));
    }

    // C. Friends' Stories Cards
    groupedStories.forEach((userId, userStories) {
      if (userId != currentUser?.id) {
         // Add latest story as thumbnail
         displayCards.add(userStories.last);
      }
    });

    // 3. Prepare Full Viewer List (Flattened & Sorted for navigation)
    // We want: [All My Stories, ...FriendA Stories, ...FriendB Stories]
    final fullViewerList = <StoryModel>[];
    
    // Add my stories first
    if (currentUser != null && groupedStories.containsKey(currentUser.id)) {
      fullViewerList.addAll(groupedStories[currentUser.id]!);
    }
    
    // Add friends stories
    groupedStories.forEach((userId, userStories) {
      if (userId != currentUser?.id) {
        fullViewerList.addAll(userStories);
      }
    });

    return Container(
      height: 210,
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: displayCards.length,
        itemBuilder: (context, index) {
          final card = displayCards[index];
          return _buildStoryCard(context, card, isDark, fullViewerList);
        },
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryModel story, bool isDark, List<StoryModel> allStories) {
    return GestureDetector(
      onTap: () {
        if (story.id == 'create') {
          _createStory(context);
        } else {
          // Find the index of the first story for this user in the full viewer list
          // This allows opening the viewer at the correct position while keeping all stories
          final initialIndex = allStories.indexWhere((s) => s.user.id == story.user.id);
          
          if (initialIndex != -1) {
             Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StoryViewerScreen(
                  stories: allStories,
                  initialIndex: initialIndex,
                ),
              ),
            );
          }
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
              child: story.id == 'create'
                  ? _buildCreateStoryCard(story, isDark)
                  // For "Your Story" card, we treat it as a normal user story card but with special labeling
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
            story.isOwnStory ? 'Your Story' : story.user.name.split(' ').first,
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
