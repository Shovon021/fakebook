import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/story_widget.dart';
import '../widgets/create_post_widget.dart';
import '../widgets/post_card.dart';
import '../widgets/reels_list.dart';
import '../widgets/facebook_shimmer.dart';
import '../widgets/empty_states.dart';
import '../services/post_service.dart';
import '../services/story_service.dart';
import '../providers/current_user_provider.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/reel_model.dart';
import '../models/user_model.dart';

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

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    setState(() {}); // Trigger rebuild to refresh streams
    await Future.delayed(const Duration(milliseconds: 800)); // Minimum shimmer time
  }

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
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF1877F2),
            child: ListView(
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
                const SizedBox(height: 60),
                EmptyStates.noPosts(
                  onCreatePost: () {
                    // Focus on create post or navigate
                  },
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF1877F2),
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
                      const ReelsList(),
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

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 8,
      color: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
