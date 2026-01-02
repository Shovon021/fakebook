import 'package:flutter/material.dart';
import '../widgets/story_widget.dart';
import '../widgets/create_post_widget.dart';
import '../widgets/post_card.dart';
import '../widgets/reels_list.dart';
import '../widgets/memories_widget.dart';
import '../widgets/facebook_shimmer.dart';
import '../data/dummy_data.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const HomeScreenShimmer();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _isLoading = false);
      },
      child: ListView(
        children: [
          // Stories
          StoryWidget(stories: DummyData.stories),
          _buildDivider(isDark),
          // Create post
          CreatePostWidget(currentUser: DummyData.currentUser),
          _buildDivider(isDark),
          // Memories
          const MemoriesWidget(),
          _buildDivider(isDark),
          // Posts
          ...DummyData.posts.asMap().entries.map((entry) {
            final index = entry.key;
            final post = entry.value;
            // Insert Reels after the first post
            if (index == 1) {
              return Column(
                children: [
                  PostCard(post: post),
                  _buildDivider(isDark),
                  ReelsList(reels: DummyData.reels),
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
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 8,
      color: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
    );
  }
}
