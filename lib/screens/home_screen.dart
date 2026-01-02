import 'package:flutter/material.dart';
import '../widgets/story_widget.dart';
import '../widgets/create_post_widget.dart';
import '../widgets/post_card.dart';
import '../widgets/reels_list.dart';
import '../widgets/memories_widget.dart';
import '../widgets/facebook_shimmer.dart';
import '../services/post_service.dart';
import '../services/story_service.dart';
import '../providers/current_user_provider.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/reel_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenContent();
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final PostService _postService = PostService();
  final StoryService _storyService = StoryService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = currentUserProvider.currentUserOrDefault;

    return StreamBuilder<List<PostModel>>(
      stream: _postService.getPostsStream(),
      builder: (context, postSnapshot) {
        // Show shimmer while loading
        if (postSnapshot.connectionState == ConnectionState.waiting) {
          return const HomeScreenShimmer();
        }

        final posts = postSnapshot.data ?? [];

        // If no posts yet, show empty state with create post
        if (posts.isEmpty) {
          return _buildEmptyState(context, currentUser, isDark);
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Trigger rebuild to refresh streams
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            children: [
              // Stories - Use StreamBuilder
              StreamBuilder<List<StoryModel>>(
                stream: _storyService.getActiveStoriesStream(),
                builder: (context, storySnapshot) {
                  final stories = storySnapshot.data ?? [];
                  return StoryWidget(stories: stories);
                },
              ),
              _buildDivider(isDark),
              
              // Create post
              CreatePostWidget(currentUser: currentUser),
              _buildDivider(isDark),
              
              // Memories
              const MemoriesWidget(),
              _buildDivider(isDark),
              
              // Posts
              ...posts.asMap().entries.map((entry) {
                final index = entry.key;
                final post = entry.value;
                
                // Insert Reels placeholder after the first post
                if (index == 1) {
                  return Column(
                    children: [
                      PostCard(post: post),
                      _buildDivider(isDark),
                      ReelsList(reels: _getPlaceholderReels()), // TODO: Create ReelsService
                      _buildDivider(isDark),
                    ],
                  );
                }
                return Column(
                  children: [
                    PostCard(post: post),
                    _buildDivider(isDark),
                  ],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic currentUser, bool isDark) {
    return ListView(
      children: [
        StreamBuilder<List<StoryModel>>(
          stream: _storyService.getActiveStoriesStream(),
          builder: (context, storySnapshot) {
            final stories = storySnapshot.data ?? [];
            return StoryWidget(stories: stories);
          },
        ),
        _buildDivider(isDark),
        CreatePostWidget(currentUser: currentUser),
        _buildDivider(isDark),
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.post_add,
                size: 64,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first post!',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder until ReelsService is created
  List<ReelModel> _getPlaceholderReels() {
    return [
      ReelModel(
        id: '1',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1611162616475-46b635cb6868',
        viewsCount: 1000,
        userName: 'User',
        userAvatar: 'https://i.imgur.com/K3Z3gM9.jpeg',
      ),
    ];
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 8,
      color: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
    );
  }
}
