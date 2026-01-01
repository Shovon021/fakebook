import 'package:flutter/material.dart';
import '../widgets/story_widget.dart';
import '../widgets/create_post_widget.dart';
import '../widgets/post_card.dart';
import '../data/dummy_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenContent();
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        children: [
          // Stories
          StoryWidget(stories: DummyData.stories),
          _buildDivider(isDark),
          // Create post
          CreatePostWidget(currentUser: DummyData.currentUser),
          _buildDivider(isDark),
          // Posts
          ...DummyData.posts.map((post) => Column(
            children: [
              PostCard(post: post),
              _buildDivider(isDark),
            ],
          )),
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
